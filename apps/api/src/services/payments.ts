/**
 * Betalningens sanningskedja, delad av alla providrar:
 *
 *   verifierad betalning → payment.state=confirmed + kvitto (SAMMA transaktion)
 *   → upplåsning observerbar → kvittomail (efterhandsarbete, blockerar aldrig)
 *
 * state='pending'-villkoret i UPDATE:n gör kedjan idempotent: dubbla
 * callbacks, samtidig polling och webhook, eller retries kan aldrig bekräfta
 * två gånger eller ge två kvitton.
 *
 * För Swish gäller dessutom: callbacken är osignerad och behandlas aldrig som
 * sanning — verifyswishPayment hämtar status server-till-server över mTLS och
 * jämför belopp/valuta innan något bekräftas.
 */
import { and, eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { payments } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { issueReceipt, sendReceiptEmail, type PaymentRow, type ReceiptRow } from './receipts.ts';
import { retrievePaymentRequest, swishConfigured, toInstructionUUID } from './integrations/swish.ts';

export interface ConfirmOutcome {
  payment: PaymentRow;
  receipt: ReceiptRow;
}

/**
 * Bekräfta en väntande betalning och utfärda kvittot atomiskt.
 * Returnerar null om betalningen inte (längre) är pending — no-op, aldrig fel.
 */
export async function confirmPendingPayment(
  paymentId: string,
  scope: { provider?: string; tenantId?: string } = {},
): Promise<ConfirmOutcome | null> {
  return db.transaction(async (tx) => {
    const conditions = [eq(payments.id, paymentId), eq(payments.state, 'pending')];
    if (scope.provider) conditions.push(eq(payments.provider, scope.provider));
    if (scope.tenantId) conditions.push(eq(payments.tenantId, scope.tenantId));
    const rows = await tx
      .update(payments)
      .set({ state: 'confirmed', confirmedAt: new Date() })
      .where(and(...conditions))
      .returning();
    if (rows.length === 0) return null;
    const receipt = await issueReceipt(tx, rows[0]!);
    return { payment: rows[0]!, receipt };
  });
}

export async function failPendingPayment(paymentId: string, reason: string): Promise<void> {
  const rows = await db
    .update(payments)
    .set({ state: 'failed' })
    .where(and(eq(payments.id, paymentId), eq(payments.state, 'pending')))
    .returning({ tenantId: payments.tenantId });
  if (rows.length > 0) {
    await audit({
      tenantId: rows[0]!.tenantId,
      actorType: 'system',
      action: 'payment.failed',
      entityType: 'payment',
      entityId: paymentId,
      after: { reason },
    });
  }
}

/**
 * Verifiera en Swish-betalning mot Swish (mTLS) och agera på den VERIFIERADE
 * statusen. Anropas från webhooken och från statuspollingen — båda vägarna är
 * bara väckningar; den här funktionen är domaren. Returnerar aktuellt state.
 */
export async function verifySwishPayment(payment: PaymentRow): Promise<'pending' | 'confirmed' | 'failed'> {
  if (payment.state !== 'pending') return payment.state as 'confirmed' | 'failed';
  if (payment.provider !== 'swish' || !swishConfigured()) return 'pending';

  const status = await retrievePaymentRequest(payment.providerReference ?? toInstructionUUID(payment.id));

  if (status.status === 'PAID') {
    // Beloppskontroll: Swish anger SEK i kronor med decimaler.
    const paidMinor = Math.round(status.amount * 100);
    if (paidMinor !== payment.amountMinor || status.currency !== payment.currency) {
      await failPendingPayment(payment.id, `belopp/valuta avviker: ${status.amount} ${status.currency}`);
      return 'failed';
    }
    const outcome = await confirmPendingPayment(payment.id, { provider: 'swish' });
    if (outcome) {
      await audit({
        tenantId: payment.tenantId,
        actorType: 'system',
        action: 'payment.confirmed',
        entityType: 'payment',
        entityId: payment.id,
        after: { provider: 'swish', paymentReference: status.paymentReference, receiptNumber: outcome.receipt.receiptNumber },
      });
      await sendReceiptEmail(outcome.receipt.id);
    }
    return 'confirmed';
  }
  if (status.status === 'DECLINED' || status.status === 'ERROR' || status.status === 'CANCELLED') {
    await failPendingPayment(payment.id, `swish status ${status.status}${status.errorCode ? ` (${status.errorCode})` : ''}`);
    return 'failed';
  }
  return 'pending'; // CREATED — användaren har inte betalat ännu.
}
