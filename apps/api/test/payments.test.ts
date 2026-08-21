/**
 * Analysupplåsning (§68): teasern visar värdet men aldrig detaljerna;
 * betalning → bekräftelse → full analys. Mockprovidern är tenant-skyddad
 * och kan aldrig aktiveras i produktion (config-villkor).
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;
let paymentId: string;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Betalaren');
  // Fixture UTAN auto-upplåsning — vi bygger den för hand.
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person', displayName: 'Min situation', applicantType: 'individual', country: 'SE',
    facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;
  const projectRes = await api(app, user, 'POST', '/v1/projects', {
    profileId: profile.id, title: 'Min ekonomiska situation', intent: 'test',
  });
  projectId = (projectRes.json() as { project: { id: string } }).project.id;
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
});

afterAll(async () => {
  await app.close();
});

describe('teaser före betalning', () => {
  it('shows counts and categories but never names, sources or questions', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    expect(res.statusCode).toBe(200);
    const body = res.json() as {
      locked: boolean; priceMinor: number; total: number;
      counts: { high: number; possible: number; needsInfo: number };
      rows: { likelihood: string; category: string }[];
    };
    expect(body.locked).toBe(true);
    expect(body.priceMinor).toBe(3900);
    expect(body.total).toBeGreaterThanOrEqual(3);
    expect(body.counts.high).toBeGreaterThanOrEqual(1); // bostadsbidrag: alla kända krav uppfyllda
    expect(body.rows.every((r) => ['high', 'possible', 'needs_info'].includes(r.likelihood))).toBe(true);

    // Inget läckage: inga stödnamn, myndigheter, slugs, källor eller frågor.
    const raw = res.body;
    for (const forbidden of ['Bostadsbidrag', 'Försäkringskassan', 'fk-bostadsbidrag', 'sourceUrl', 'missingFacts', 'kulturradet']) {
      expect(raw, `teasern läcker "${forbidden}"`).not.toContain(forbidden);
    }
  });

  it('locks the funding-stack behind the same purchase (402)', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/funding-stack`, { ownContributionMinor: 0 });
    expect(res.statusCode).toBe(402);
  });

  it('unlock-status reports locked with the price', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/unlock-status`);
    expect(res.json()).toMatchObject({ unlocked: false, priceMinor: 3900, currency: 'SEK' });
  });
});

describe('betalning → bekräftelse → kvitto → upplåsning', () => {
  it('refuses a purchase without explicit immediate-delivery consent (400, distansavtalslagen)', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`, { email: 'kvitto@test.example' });
    expect(res.statusCode).toBe(400);
    expect((res.json() as { error: string }).error).toBe('consent_required');
  });

  it('creates a pending payment with mock instructions and a receipt email', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`, { email: 'kvitto@test.example', immediateDeliveryConsent: true });
    expect(res.statusCode).toBe(201);
    const body = res.json() as { paymentId: string; amountMinor: number; instructions: { method: string; mockConfirmable: boolean; message: string } };
    paymentId = body.paymentId;
    expect(body.amountMinor).toBe(3900);
    expect(body.instructions.method).toBe('mock');
    expect(body.instructions.message).toContain('SIMULERAD');
  });

  it('another tenant cannot confirm someone else’s payment', async () => {
    const other = await registerUser(app, 'Annan');
    const res = await api(app, other, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(res.statusCode).toBe(404);
  });

  it('confirmation unlocks the full analysis and issues a receipt', async () => {
    const confirm = await api(app, user, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(confirm.statusCode).toBe(200);
    const confirmBody = confirm.json() as { unlocked: boolean; receipt: { receiptNumber: string; email: string } };
    expect(confirmBody.receipt.receiptNumber).toMatch(/^BS-\d{4}-\d{6}$/);
    expect(confirmBody.receipt.email).toBe('kvitto@test.example');

    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const body = res.json() as { matches?: { slug: string; sourceUrl: string }[]; locked?: boolean };
    expect(body.locked).toBeUndefined();
    expect(body.matches!.some((m) => m.slug === 'fk-bostadsbidrag-barnfamiljer')).toBe(true);
    expect(body.matches![0]!.sourceUrl).toContain('https://');

    const status = await api(app, user, 'GET', `/v1/projects/${projectId}/unlock-status`);
    expect((status.json() as { unlocked: boolean }).unlocked).toBe(true);
  });

  it('a second unlock attempt is idempotent — never charge twice', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`, { immediateDeliveryConsent: true });
    expect(res.statusCode).toBe(200);
    expect((res.json() as { alreadyUnlocked: boolean }).alreadyUnlocked).toBe(true);
  });

  it('a new project (new analysis) is locked again — one purchase per analysis', async () => {
    const profiles = await api(app, user, 'GET', '/v1/profiles');
    const profileId = (profiles.json() as { profiles: { id: string }[] }).profiles[0]!.id;
    const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId, title: 'Nytt projekt', intent: 'annat' });
    const newId = (projectRes.json() as { project: { id: string } }).project.id;
    await api(app, user, 'POST', `/v1/projects/${newId}/matches`, {});
    const res = await api(app, user, 'GET', `/v1/projects/${newId}/matches`);
    expect((res.json() as { locked?: boolean }).locked).toBe(true);
  });

  it('payment webhooks refuse honestly until a real provider is configured', async () => {
    const res = await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: {} });
    expect(res.statusCode).toBe(503);
  });
});

describe('kvitto/verifikationsunderlag', () => {
  it('freezes correct Swedish VAT math: 39,00 = 31,20 netto + 7,80 moms (25 %)', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/receipt`);
    expect(res.statusCode).toBe(200);
    const { receipt, document } = res.json() as {
      receipt: {
        receiptNumber: string; paymentRef: string; amountGrossMinor: number; amountNetMinor: number;
        vatAmountMinor: number; vatRateBps: number; paymentMethod: string; paymentStatus: string;
        refundStatus: string; email: string; sellerName: string;
      };
      document: string;
    };
    expect(receipt.amountGrossMinor).toBe(3900);
    expect(receipt.amountNetMinor).toBe(3120);
    expect(receipt.vatAmountMinor).toBe(780);
    expect(receipt.amountNetMinor + receipt.vatAmountMinor).toBe(receipt.amountGrossMinor);
    expect(receipt.vatRateBps).toBe(2500);
    expect(receipt.paymentRef).toBe(paymentId);
    expect(receipt.paymentStatus).toBe('confirmed');
    expect(receipt.refundStatus).toBe('none');

    // Ett riktigt verifikationsdokument — inte ett "tack för betalningen"-mail.
    // Säljaruppgifterna är Landvex AB:s riktiga (bokföringslagens krav på
    // verifikationen: säljarens namn, organisationsnummer och adress).
    for (const expected of ['KVITTO', 'Kvittonummer', 'Köp-ID', 'Moms (25,00 %)', '31,20 kr', '7,80 kr', '39,00 kr', 'Betalningsmetod', 'Återbetalning', 'Landvex AB', '559141-7042', 'SE559141704201', 'Antennvägen 2, 135 48 Tyresö']) {
      expect(document, `dokumentet saknar "${expected}"`).toContain(expected);
    }
  });

  it('a duplicate confirmation can never issue a second receipt', async () => {
    // Dubbel callback: betalningen är inte längre pending → no-op, ett kvitto.
    const res = await api(app, user, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(res.statusCode).toBe(404);
    const receiptRes = await api(app, user, 'GET', `/v1/projects/${projectId}/receipt`);
    expect(receiptRes.statusCode).toBe(200);
  });

  it('the receipt can be saved: downloadable PDF, tenant-scoped', async () => {
    const res = await api(app, user, 'GET', `/v1/payments/${paymentId}/receipt.pdf`);
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toBe('application/pdf');
    expect(res.headers['content-disposition']).toMatch(/^attachment; filename="kvitto-BS-\d{4}-\d{6}\.pdf"$/);
    expect(res.rawPayload.subarray(0, 5).toString('latin1')).toBe('%PDF-');

    // Främmande tenant: kvittot existerar inte (404), aldrig 403-läckage.
    const stranger = await registerUser(app, 'Främling Kvittosson');
    const foreign = await api(app, stranger, 'GET', `/v1/payments/${paymentId}/receipt.pdf`);
    expect(foreign.statusCode).toBe(404);
  });

  it('purchase without email: receipt issued as pending, email added afterwards, then resend works', async () => {
    // Nytt projekt, köp utan e-post ("jag missade fältet").
    const profiles = await api(app, user, 'GET', '/v1/profiles');
    const profileId = (profiles.json() as { profiles: { id: string }[] }).profiles[0]!.id;
    const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId, title: 'Utan e-post', intent: 'test' });
    const pid = (projectRes.json() as { project: { id: string } }).project.id;

    const create = await api(app, user, 'POST', `/v1/projects/${pid}/analysis-unlock`, { immediateDeliveryConsent: true });
    expect(create.statusCode).toBe(201);
    const newPaymentId = (create.json() as { paymentId: string }).paymentId;
    await api(app, user, 'POST', `/v1/payments/${newPaymentId}/mock-confirm`);

    // Omskick utan adress: ärligt 422, inte tyst ingenting.
    const resendFail = await api(app, user, 'POST', `/v1/payments/${newPaymentId}/resend-receipt`);
    expect(resendFail.statusCode).toBe(422);
    expect((resendFail.json() as { error: string }).error).toBe('no_email');

    // Komplettera adressen i efterhand → sparas på kvittot.
    const setEmail = await api(app, user, 'POST', `/v1/payments/${newPaymentId}/receipt-email`, { email: 'Sent.Ifylld@Test.Example' });
    expect(setEmail.statusCode).toBe(200);
    const receipt = await api(app, user, 'GET', `/v1/projects/${pid}/receipt`);
    expect((receipt.json() as { receipt: { email: string } }).receipt.email).toBe('sent.ifylld@test.example');

    // Omskicket svarar ärligt med utfallet — i testmiljön är kanalen en
    // avsiktligt död SMTP (failed). Kvittot är oavsett åtkomligt i kontot.
    const resend = await api(app, user, 'POST', `/v1/payments/${newPaymentId}/resend-receipt`);
    expect(resend.statusCode).toBe(200);
    expect(['sent', 'skipped', 'failed']).toContain((resend.json() as { emailOutcome: string }).emailOutcome);
  });

  it('receipt numbers are sequential and never reused', async () => {
    const r1 = await api(app, user, 'GET', `/v1/projects/${projectId}/receipt`);
    const n1 = (r1.json() as { receipt: { receiptNumber: string } }).receipt.receiptNumber;
    const profiles = await api(app, user, 'GET', '/v1/profiles');
    const profileId = (profiles.json() as { profiles: { id: string }[] }).profiles[0]!.id;
    const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId, title: 'Serie', intent: 'test' });
    const pid = (projectRes.json() as { project: { id: string } }).project.id;
    const create = await api(app, user, 'POST', `/v1/projects/${pid}/analysis-unlock`, { email: 'serie@test.example', immediateDeliveryConsent: true });
    const p2 = (create.json() as { paymentId: string }).paymentId;
    await api(app, user, 'POST', `/v1/payments/${p2}/mock-confirm`);
    const r2 = await api(app, user, 'GET', `/v1/projects/${pid}/receipt`);
    const n2 = (r2.json() as { receipt: { receiptNumber: string } }).receipt.receiptNumber;
    expect(n2).not.toBe(n1);
    expect(Number(n2.slice(-6))).toBeGreaterThan(Number(n1.slice(-6)));
  });

  it('other tenants can never read the receipt', async () => {
    const other = await registerUser(app, 'Utomstående');
    const res = await api(app, other, 'GET', `/v1/projects/${projectId}/receipt`);
    expect(res.statusCode).toBe(404);
  });
});

describe('Mina köp — kvittot är förstaklass i kontot (ingen e-post krävs)', () => {
  it('lists own purchases with receipt numbers and states', async () => {
    const res = await api(app, user, 'GET', '/v1/purchases');
    expect(res.statusCode).toBe(200);
    const { purchases } = res.json() as {
      purchases: { paymentId: string; state: string; amountMinor: number; receiptNumber: string | null; projectTitle: string | null }[];
    };
    expect(purchases.length).toBeGreaterThanOrEqual(3);
    const confirmed = purchases.filter((p) => p.state === 'confirmed');
    expect(confirmed.length).toBeGreaterThanOrEqual(3);
    expect(confirmed.every((p) => /^BS-\d{4}-\d{6}$/.test(p.receiptNumber ?? ''))).toBe(true);
    expect(confirmed.every((p) => p.amountMinor === 3900)).toBe(true);
  });

  it('serves the receipt document per payment, ownership checked server-side', async () => {
    const res = await api(app, user, 'GET', `/v1/payments/${paymentId}/receipt`);
    expect(res.statusCode).toBe(200);
    const { document } = res.json() as { document: string };
    expect(document).toContain('KVITTO');
    expect(document).toContain('Moms (25,00 %)');
    expect(document).toContain('Ångerrätt:         Upphörd');
  });

  it('IDOR: another tenant sees an empty purchase list and 404 on a known payment id', async () => {
    const other = await registerUser(app, 'Nyfiken');
    const list = await api(app, other, 'GET', '/v1/purchases');
    expect((list.json() as { purchases: unknown[] }).purchases).toHaveLength(0);
    // Känt betalnings-id från annan tenant: existerar inte (404, inte 403).
    const receipt = await api(app, other, 'GET', `/v1/payments/${paymentId}/receipt`);
    expect(receipt.statusCode).toBe(404);
    const status = await api(app, other, 'GET', `/v1/payments/${paymentId}/status`);
    expect(status.statusCode).toBe(404);
  });
});
