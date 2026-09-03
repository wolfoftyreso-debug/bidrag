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
import { trackEvent } from './events.ts';
import { db } from '../db/client.ts';
import { payments } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { issueReceipt, sendReceiptEmail, type PaymentRow, type ReceiptRow } from './receipts.ts';
import { retrievePaymentRequest, swishConfigured, toInstructionUUID } from './integrations/swish.ts';
import { retrieveCheckoutSession, stripeConfigured } from './integrations/stripe.ts';

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
  const outcome = await db.transaction(async (tx) => {
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
  if (outcome) {
    // Trattmått (BETA_READINESS B2) — utanför transaktionen, best effort.
    await trackEvent('betalning_bekraftad', {
      tenantId: outcome.payment.tenantId,
      props: { provider: outcome.payment.provider, amountMinor: outcome.payment.amountMinor, receipt: outcome.receipt.receiptNumber },
    });
  }
  return outcome;
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

/**
 * Verifiera en Stripe-betalning genom att hämta Checkout Session
 * server-till-server och agera på den VERIFIERADE statusen. Fallbacken när en
 * webhook tappas (statuspollingen efter redirect tillbaka). Samma beloppskoll
 * och idempotenta bekräftelse som webhooken; returnerar aktuellt state.
 */
export async function verifyStripePayment(payment: PaymentRow): Promise<'pending' | 'confirmed' | 'failed'> {
  if (payment.state !== 'pending') return payment.state as 'confirmed' | 'failed';
  if (payment.provider !== 'stripe' || !stripeConfigured() || !payment.providerReference) return 'pending';

  const session = await retrieveCheckoutSession(payment.providerReference);

  if (session.payment_status === 'paid') {
    if (session.amount_total !== payment.amountMinor || (session.currency ?? '').toUpperCase() !== payment.currency) {
      await failPendingPayment(payment.id, `belopp/valuta avviker: ${session.amount_total} ${session.currency}`);
      return 'failed';
    }
    await confirmStripePayment(payment.id, payment.tenantId, session.id);
    return 'confirmed';
  }
  if (session.status === 'expired') {
    await failPendingPayment(payment.id, 'stripe checkout session expired');
    return 'failed';
  }
  return 'pending'; // open/unpaid — användaren har inte betalat ännu.
}

/**
 * Bekräfta en Stripe-betalning atomiskt + kvittomail. Delas av den signerade
 * webhooken och statuspollingen; confirmPendingPayment gör det idempotent
 * (dubbel webhook/poll ⇒ en bekräftelse, ett kvitto).
 */
export async function confirmStripePayment(paymentId: string, tenantId: string, sessionId: string): Promise<void> {
  const outcome = await confirmPendingPayment(paymentId, { provider: 'stripe' });
  if (!outcome) return;
  await audit({
    tenantId,
    actorType: 'system',
    action: 'payment.confirmed',
    entityType: 'payment',
    entityId: paymentId,
    after: { provider: 'stripe', sessionId, receiptNumber: outcome.receipt.receiptNumber },
  });
  await sendReceiptEmail(outcome.receipt.id);
}
