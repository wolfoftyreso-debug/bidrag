/**
 * Kvittotjänsten (verifikationsunderlag). Separat lager mellan betalning och
 * e-post: betalningen är den auktoritativa händelsen; kvittot utfärdas i
 * SAMMA databastransaktion som bekräftelsen (dubbla callbacks kan aldrig ge
 * två kvitton — unikt på paymentId), och mailet är efterhandsarbete som kan
 * skickas om utan att röra vare sig betalning eller upplåsning.
 *
 * Beloppen fryses i öre tillsammans med momssats och säljaruppgifter vid
 * utfärdandet — kvittot förblir korrekt även om pris eller sats ändras senare.
 */
import { eq, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { payments, receipts } from '../db/schema.ts';
import { config } from '../config.ts';
import { audit } from '../audit.ts';
import { sendEmail } from './email.ts';

type Tx = Parameters<Parameters<typeof db.transaction>[0]>[0];
export type PaymentRow = typeof payments.$inferSelect;
export type ReceiptRow = typeof receipts.$inferSelect;

/**
 * Priset är inklusive moms. Nettot beräknas genom att baka ur momsen och
 * avrunda till helt öre; momsbeloppet är differensen så att netto + moms
 * alltid är exakt lika med totalen (ingen öresdiff i bokföringen).
 */
export function computeVat(grossMinor: number, rateBps: number): { netMinor: number; vatMinor: number } {
  const netMinor = Math.round((grossMinor * 10_000) / (10_000 + rateBps));
  return { netMinor, vatMinor: grossMinor - netMinor };
}

function productDescription(payment: PaymentRow): string {
  if (payment.kind === 'document_pack') {
    if ((payment.credits ?? 0) >= 99) return 'Dokumentförberedelse — alla dokument för en ansökan';
    if ((payment.credits ?? 0) === 3) return 'Dokumentförberedelse — upp till 3 dokument';
    return 'Dokumentförberedelse — ett dokument';
  }
  return 'Personlig bidragsanalys — engångsupplåsning';
}

/**
 * Utfärda kvitto för en bekräftad betalning, inne i bekräftelsens transaktion.
 * Idempotent: finns kvittot redan (dubbel callback) returneras det befintliga.
 */
export async function issueReceipt(tx: Tx, payment: PaymentRow): Promise<ReceiptRow> {
  const [existing] = await tx.select().from(receipts).where(eq(receipts.paymentId, payment.id)).limit(1);
  if (existing) return existing;

  const { rows } = await tx.execute(sql`select nextval('receipt_number_seq') as n`);
  const seq = Number((rows[0] as { n: string | number }).n);
  const year = (payment.confirmedAt ?? new Date()).getFullYear();
  const { netMinor, vatMinor } = computeVat(payment.amountMinor, config.vatRateBps);

  const [receipt] = await tx
    .insert(receipts)
    .values({
      tenantId: payment.tenantId,
      paymentId: payment.id,
      paymentRef: payment.id,
      receiptNumber: `BS-${year}-${String(seq).padStart(6, '0')}`,
      productDescription: productDescription(payment),
      amountGrossMinor: payment.amountMinor,
      amountNetMinor: netMinor,
      vatAmountMinor: vatMinor,
      vatRateBps: config.vatRateBps,
      currency: payment.currency,
      paymentMethod: payment.provider,
      paymentStatus: 'confirmed',
      sellerName: config.sellerName,
      sellerOrgNumber: config.sellerOrgNumber,
      sellerVatNumber: config.sellerVatNumber,
      email: payment.receiptEmail,
    })
    .returning();
  return receipt!;
}

const kr = (minor: number) => `${(minor / 100).toLocaleString('sv-SE', { minimumFractionDigits: 2 })} kr`;
const METHOD_LABEL: Record<string, string> = { swish: 'Swish', mock: 'Simulerad betalning (utveckling)' };

/** Komplett kvitto/verifikationstext — inte ett "tack för betalningen"-mail. */
export function receiptDocument(r: ReceiptRow): string {
  const vatPercent = (r.vatRateBps / 100).toLocaleString('sv-SE', { minimumFractionDigits: 2 });
  const lines = [
    'KVITTO',
    '',
    `Kvittonummer:      ${r.receiptNumber}`,
    `Köp-ID:            ${r.paymentRef}`,
    `Datum:             ${r.issuedAt.toLocaleString('sv-SE', { timeZone: 'Europe/Stockholm' })}`,
    '',
    `Säljare:           ${r.sellerName}`,
    ...(r.sellerOrgNumber ? [`Organisationsnr:   ${r.sellerOrgNumber}`] : []),
    ...(r.sellerVatNumber ? [`Momsreg.nr:        ${r.sellerVatNumber}`] : []),
    '',
    `Produkt:           ${r.productDescription}`,
    `Betalningsmetod:   ${METHOD_LABEL[r.paymentMethod] ?? r.paymentMethod}`,
    `Betalningsstatus:  ${r.paymentStatus === 'confirmed' ? 'Genomförd' : r.paymentStatus}`,
    `Återbetalning:     ${r.refundStatus === 'none' ? 'Nej' : r.refundStatus}`,
    '',
    `Belopp exkl. moms: ${kr(r.amountNetMinor)}`,
    `Moms (${vatPercent} %):   ${kr(r.vatAmountMinor)}`,
    `Totalt (${r.currency}):      ${kr(r.amountGrossMinor)}`,
    '',
    'Detta kvitto gäller upplåsning av en personlig bidragsanalys på Bidrag.se.',
    'Analysen är en vägledning och inte ett myndighetsbeslut.',
  ];
  return lines.join('\n');
}

/**
 * Skicka (eller skicka om) kvittomailet. Saknas e-postadress markeras kvittot
 * ärligt som väntande — adressen kan kompletteras i efterhand.
 */
export async function sendReceiptEmail(receiptId: string): Promise<'sent' | 'skipped' | 'failed' | 'no_email'> {
  const [r] = await db.select().from(receipts).where(eq(receipts.id, receiptId)).limit(1);
  if (!r) throw Object.assign(new Error('receipt not found'), { statusCode: 404 });
  if (!r.email) return 'no_email';

  const outcome = await sendEmail({
    to: r.email,
    subject: `Kvitto ${r.receiptNumber} — Bidrag.se`,
    text: receiptDocument(r),
    tenantId: r.tenantId,
  });
  await db
    .update(receipts)
    .set({ emailStatus: outcome, emailSentAt: outcome === 'sent' ? new Date() : null })
    .where(eq(receipts.id, receiptId));
  await audit({
    tenantId: r.tenantId,
    actorType: 'system',
    action: `receipt.email_${outcome}`,
    entityType: 'receipt',
    entityId: r.id,
    after: { receiptNumber: r.receiptNumber, to: r.email },
  });
  return outcome;
}
