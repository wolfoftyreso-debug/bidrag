/**
 * Stripe-integration mot en lokal Stripe-emulator (POST/GET checkout sessions),
 * med RIKTIGA webhooksignaturer (HMAC-SHA256 över rå body). Det som verifieras
 * är säkerhets- och sanningsmodellen — samma nivå som Swish-testet:
 *
 *  - köp skapar en Checkout Session; klienten får en redirect-URL
 *  - en FÖRFALSKAD webhook (fel signatur) kan aldrig bekräfta något (400)
 *  - signerad completed+paid med rätt belopp ⇒ confirmed + kvitto + kredit
 *  - fel belopp i eventet ⇒ failed, aldrig upplåst
 *  - dubbel webhook ⇒ EN bekräftelse, ETT kvitto (idempotent)
 *  - tappad webhook ⇒ statuspolling verifierar server-till-server och bekräftar
 */
import http from 'node:http';
import crypto from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, createProfileAndProject, testServer, type TestUser } from './helpers.ts';

const WEBHOOK_SECRET = 'whsec_test_bidragskoll_stripe';
let app: FastifyInstance;
let user: TestUser;
let stripeServer: http.Server;

/** Emulatorns sessionstillstånd, per session-id. */
const sessions = new Map<string, { amount_total: number; currency: string; payment_status: string; status: string; metadata: Record<string, string> }>();

function readBody(req: http.IncomingMessage): Promise<string> {
  return new Promise((resolve) => {
    const chunks: Buffer[] = [];
    req.on('data', (c: Buffer) => chunks.push(c));
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
  });
}

/** Bygg en giltig stripe-signature-header för en rå payload. */
function sign(raw: string, secret = WEBHOOK_SECRET, at = Math.floor(Date.now() / 1000)): string {
  const sig = crypto.createHmac('sha256', secret).update(`${at}.${raw}`, 'utf8').digest('hex');
  return `t=${at},v1=${sig}`;
}

async function webhook(payload: unknown, header: string) {
  const raw = JSON.stringify(payload);
  return app.inject({
    method: 'POST',
    url: '/v1/webhooks/payments/stripe',
    payload: raw,
    headers: { 'content-type': 'application/json', 'stripe-signature': header },
  });
}

async function startPurchase(projectId: string): Promise<{ paymentId: string; sessionId: string; instructions: Record<string, unknown> }> {
  const res = await api(app, user, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true });
  expect(res.statusCode).toBe(201);
  const body = res.json() as { paymentId: string; instructions: Record<string, unknown> };
  // Emulatorn lagrar sessionen under paymentId i metadata; hitta dess id.
  const sessionId = [...sessions.entries()].find(([, s]) => s.metadata.paymentId === body.paymentId)?.[0];
  expect(sessionId).toBeTruthy();
  return { paymentId: body.paymentId, sessionId: sessionId!, instructions: body.instructions };
}

beforeAll(async () => {
  // Stripe-emulator: skapar/återger checkout sessions.
  stripeServer = http.createServer(async (req, res) => {
    const create = req.method === 'POST' && req.url === '/v1/checkout/sessions';
    const retrieveMatch = req.method === 'GET' && req.url?.match(/^\/v1\/checkout\/sessions\/([^/?]+)$/);
    if (create) {
      const form = Object.fromEntries(new URLSearchParams(await readBody(req)));
      const id = `cs_test_${crypto.randomBytes(8).toString('hex')}`;
      const amount = Number(form['line_items[0][price_data][unit_amount]']);
      const currency = String(form['line_items[0][price_data][currency]']);
      const session = { amount_total: amount, currency, payment_status: 'unpaid', status: 'open', metadata: { paymentId: String(form['metadata[paymentId]']) } };
      sessions.set(id, session);
      res.writeHead(200, { 'Content-Type': 'application/json' }).end(JSON.stringify({ id, url: `https://checkout.stripe.test/pay/${id}`, ...session, client_reference_id: session.metadata.paymentId }));
      return;
    }
    if (retrieveMatch) {
      const s = sessions.get(retrieveMatch[1]!);
      if (!s) { res.writeHead(404, { 'Content-Type': 'application/json' }).end('{"error":{"message":"no such session"}}'); return; }
      res.writeHead(200, { 'Content-Type': 'application/json' }).end(JSON.stringify({ id: retrieveMatch[1], ...s }));
      return;
    }
    res.writeHead(404).end();
  });
  await new Promise<void>((r) => stripeServer.listen(0, r));
  const port = (stripeServer.address() as { port: number }).port;

  process.env.STRIPE_SECRET_KEY = 'sk_test_bidragskoll';
  process.env.STRIPE_WEBHOOK_SECRET = WEBHOOK_SECRET;
  process.env.STRIPE_API_BASE = `http://127.0.0.1:${port}`;

  app = await testServer();
  user = await registerUser(app, 'Stripe-betalaren');
});

afterAll(async () => {
  await app?.close();
  await new Promise<void>((r) => stripeServer.close(() => r()));
  delete process.env.STRIPE_SECRET_KEY;
  delete process.env.STRIPE_WEBHOOK_SECRET;
  delete process.env.STRIPE_API_BASE;
});

async function projectWithMatch(): Promise<{ projectId: string; opportunityId: string }> {
  const { project } = await createProfileAndProject(app, user);
  await api(app, user, 'POST', `/v1/projects/${project.id}/matches`, {});
  const m = await api(app, user, 'GET', `/v1/projects/${project.id}/matches`);
  const matches = (m.json() as { matches: { opportunityId: string }[] }).matches;
  return { projectId: project.id, opportunityId: matches[0]!.opportunityId };
}

describe('Stripe payment provider', () => {
  it('köp skapar en Checkout Session och ger en redirect-URL', async () => {
    const { projectId } = await projectWithMatch();
    const { instructions, sessionId } = await startPurchase(projectId);
    expect(instructions.method).toBe('stripe');
    expect(typeof instructions.redirectUrl).toBe('string');
    expect((instructions.redirectUrl as string)).toContain(sessionId);
    expect(sessions.get(sessionId)!.amount_total).toBe(1900);
    expect(sessions.get(sessionId)!.currency).toBe('sek');
  });

  it('förfalskad webhook (fel signatur) bekräftar ingenting', async () => {
    const { projectId } = await projectWithMatch();
    const { paymentId, sessionId } = await startPurchase(projectId);
    const event = { type: 'checkout.session.completed', data: { object: { id: sessionId, payment_status: 'paid', amount_total: 1900, currency: 'sek', metadata: { paymentId } } } };
    const forged = sign(JSON.stringify(event), 'fel-hemlighet');
    const res = await webhook(event, forged);
    expect(res.statusCode).toBe(400);
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    // Fortfarande obetald (emulatorsessionen är 'unpaid'); ingen upplåsning.
    expect((status.json() as { state: string }).state).toBe('pending');
  });

  it('signerad completed+paid med rätt belopp ⇒ confirmed + kvitto + kredit', async () => {
    const { projectId, opportunityId } = await projectWithMatch();
    const { paymentId, sessionId } = await startPurchase(projectId);
    const event = { type: 'checkout.session.completed', data: { object: { id: sessionId, payment_status: 'paid', amount_total: 1900, currency: 'sek', metadata: { paymentId } } } };
    const res = await webhook(event, sign(JSON.stringify(event)));
    expect(res.statusCode).toBe(200);

    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    const sbody = status.json() as { state: string; receipt?: { receiptNumber: string } };
    expect(sbody.state).toBe('confirmed');
    expect(sbody.receipt?.receiptNumber).toBeTruthy();

    // Krediten går att förbruka: ansökan skapas.
    const applied = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId });
    expect(applied.statusCode).toBe(201);
  });

  it('fel belopp i eventet ⇒ failed, aldrig upplåst', async () => {
    const { projectId } = await projectWithMatch();
    const { paymentId, sessionId } = await startPurchase(projectId);
    const event = { type: 'checkout.session.completed', data: { object: { id: sessionId, payment_status: 'paid', amount_total: 999, currency: 'sek', metadata: { paymentId } } } };
    const res = await webhook(event, sign(JSON.stringify(event)));
    expect(res.statusCode).toBe(200); // kvitteras, men bekräftar inte
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('failed');
  });

  it('dubbel webhook ⇒ en bekräftelse, ett kvitto (idempotent)', async () => {
    const { projectId } = await projectWithMatch();
    const { paymentId, sessionId } = await startPurchase(projectId);
    const event = { type: 'checkout.session.completed', data: { object: { id: sessionId, payment_status: 'paid', amount_total: 1900, currency: 'sek', metadata: { paymentId } } } };
    const header = sign(JSON.stringify(event));
    await webhook(event, header);
    await webhook(event, sign(JSON.stringify(event))); // ny signatur, samma event
    const purchases = await api(app, user, 'GET', '/v1/purchases');
    const rows = (purchases.json() as { purchases: { paymentId: string; receiptNumber: string | null }[] }).purchases.filter((p) => p.paymentId === paymentId);
    expect(rows.length).toBe(1);
    expect(rows[0]!.receiptNumber).toBeTruthy();
  });

  it('tappad webhook ⇒ statuspolling verifierar server-till-server och bekräftar', async () => {
    const { projectId } = await projectWithMatch();
    const { paymentId, sessionId } = await startPurchase(projectId);
    // Ingen webhook. Betalningen blir "paid" hos Stripe (emulatorn).
    sessions.get(sessionId)!.payment_status = 'paid';
    sessions.get(sessionId)!.status = 'complete';
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('confirmed');
  });
});
