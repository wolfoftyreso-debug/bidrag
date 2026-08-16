/**
 * Swish Handel-integration mot en riktig lokal mTLS-server (inte mockade
 * funktioner): servern kräver klientcertifikat signerat av test-CA:n, precis
 * som Swish CPC. Det som verifieras är själva säkerhetsmodellen:
 *
 *  - payment request skapas idempotent över mTLS
 *  - en FÖRFALSKAD callback ("PAID") kan aldrig låsa upp något — sanningen
 *    hämtas alltid server-till-server, och Swish säger CREATED
 *  - verifierad PAID ⇒ confirmed + kvitto + upplåsning
 *  - fel belopp ⇒ failed, aldrig upplåst
 *  - tappad callback ⇒ statuspolling verifierar och bekräftar ändå
 */
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import https from 'node:https';
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let swishServer: https.Server;
let qrServer: http.Server;

/** Kontrollpanel för fejk-Swish: status per instructionUUID. */
const swishState = new Map<string, { status: string; amount: number; currency: string }>();
const receivedCreates: Record<string, unknown>[] = [];
const QR_PNG = Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47]), Buffer.from('fake-qr-body')]);

function openssl(args: string[], cwd: string) {
  execFileSync('openssl', args, { cwd, stdio: 'pipe' });
}

beforeAll(async () => {
  // 1) Riktiga certifikat: CA → servercert (localhost, SAN) + klientcert.
  const dir = mkdtempSync(path.join(os.tmpdir(), 'swish-certs-'));
  openssl(['req', '-x509', '-newkey', 'rsa:2048', '-keyout', 'ca.key', '-out', 'ca.crt', '-days', '1', '-nodes', '-subj', '/CN=BidragTestCA'], dir);
  writeFileSync(path.join(dir, 'san.cnf'), 'subjectAltName=DNS:localhost,IP:127.0.0.1\n');
  openssl(['req', '-newkey', 'rsa:2048', '-keyout', 'server.key', '-out', 'server.csr', '-nodes', '-subj', '/CN=localhost'], dir);
  openssl(['x509', '-req', '-in', 'server.csr', '-CA', 'ca.crt', '-CAkey', 'ca.key', '-CAcreateserial', '-out', 'server.crt', '-days', '1', '-extfile', 'san.cnf'], dir);
  openssl(['req', '-newkey', 'rsa:2048', '-keyout', 'client.key', '-out', 'client.csr', '-nodes', '-subj', '/CN=BidragMerchant'], dir);
  openssl(['x509', '-req', '-in', 'client.csr', '-CA', 'ca.crt', '-CAkey', 'ca.key', '-out', 'client.crt', '-days', '1'], dir);
  const read = (f: string) => readFileSync(path.join(dir, f));

  // 2) Fejk-Swish CPC: kräver giltigt klientcertifikat (riktig mTLS-handskakning).
  swishServer = https.createServer(
    { key: read('server.key'), cert: read('server.crt'), ca: read('ca.crt'), requestCert: true, rejectUnauthorized: true },
    (req, res) => {
      const chunks: Buffer[] = [];
      req.on('data', (c: Buffer) => chunks.push(c));
      req.on('end', () => {
        const createMatch = req.url?.match(/\/api\/v2\/paymentrequests\/([0-9A-F]{32})$/);
        const statusMatch = req.url?.match(/\/api\/v1\/paymentrequests\/([0-9A-F]{32})$/);
        if (req.method === 'PUT' && createMatch) {
          const body = JSON.parse(Buffer.concat(chunks).toString('utf8')) as Record<string, unknown>;
          receivedCreates.push({ id: createMatch[1], ...body });
          if (!swishState.has(createMatch[1]!)) {
            swishState.set(createMatch[1]!, { status: 'CREATED', amount: Number(body.amount), currency: String(body.currency) });
          }
          res.writeHead(201, { PaymentRequestToken: `tok-${createMatch[1]!.slice(0, 8)}` }).end();
          return;
        }
        if (req.method === 'GET' && statusMatch) {
          const s = swishState.get(statusMatch[1]!);
          if (!s) { res.writeHead(404).end(); return; }
          res.writeHead(200, { 'Content-Type': 'application/json' }).end(
            JSON.stringify({ id: statusMatch[1], status: s.status, amount: s.amount, currency: s.currency, paymentReference: `SWREF${statusMatch[1]!.slice(0, 6)}` }),
          );
          return;
        }
        res.writeHead(404).end();
      });
    },
  );
  await new Promise<void>((r) => swishServer.listen(0, '127.0.0.1', r));
  const swishPort = (swishServer.address() as { port: number }).port;

  // 3) Fejk-QR-tjänst (Swish QR-API:t kräver inte mTLS).
  qrServer = http.createServer((_req, res) => res.writeHead(200, { 'Content-Type': 'image/png' }).end(QR_PNG));
  await new Promise<void>((r) => qrServer.listen(0, '127.0.0.1', r));
  const qrPort = (qrServer.address() as { port: number }).port;

  // 4) Konfigurera adaptern — certifikat som base64-miljövariabler (samma väg som Vercel).
  process.env.SWISH_MERCHANT_ALIAS = '1231111111';
  process.env.SWISH_CERT_BASE64 = read('client.crt').toString('base64');
  process.env.SWISH_KEY_BASE64 = read('client.key').toString('base64');
  process.env.SWISH_CA_BASE64 = read('ca.crt').toString('base64');
  process.env.SWISH_API_BASE = `https://localhost:${swishPort}`;
  process.env.SWISH_QR_BASE = `http://localhost:${qrPort}`;

  app = await testServer();
  user = await registerUser(app, 'Swishbetalaren');
});

afterAll(async () => {
  delete process.env.SWISH_MERCHANT_ALIAS; // andra testfiler i processen ska inte ärva
  await app.close();
  swishServer.close();
  qrServer.close();
});

async function newLockedProject(): Promise<string> {
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person', displayName: 'S', applicantType: 'individual', country: 'SE',
    facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;
  const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId: profile.id, title: 'Swishtest', intent: 'test' });
  const id = (projectRes.json() as { project: { id: string } }).project.id;
  await api(app, user, 'POST', `/v1/projects/${id}/matches`, {});
  return id;
}

async function startSwishPayment(projectId: string): Promise<{ paymentId: string; ref: string; deepLink: string }> {
  const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`, { email: 'swish@test.example' });
  expect(res.statusCode).toBe(201);
  const body = res.json() as { paymentId: string; instructions: { method: string; deepLink?: string; qrAvailable?: boolean } };
  expect(body.instructions.method).toBe('swish');
  expect(body.instructions.deepLink).toMatch(/^swish:\/\/paymentrequest\?token=/);
  const ref = body.paymentId.replace(/-/g, '').toUpperCase();
  return { paymentId: body.paymentId, ref, deepLink: body.instructions.deepLink! };
}

describe('Swish Handel över riktig mTLS', () => {
  it('creates a payment request with correct amount, alias and callback URL', async () => {
    const projectId = await newLockedProject();
    const { ref } = await startSwishPayment(projectId);
    const create = receivedCreates.find((c) => c.id === ref)!;
    expect(create, 'payment request nådde aldrig Swish-servern').toBeDefined();
    expect(create.amount).toBe('39.00');
    expect(create.currency).toBe('SEK');
    expect(create.payeeAlias).toBe('1231111111');
    expect(String(create.callbackUrl)).toContain('/v1/webhooks/payments/swish');
  });

  it('serves the QR code through the API without exposing the token', async () => {
    const projectId = await newLockedProject();
    const { paymentId } = await startSwishPayment(projectId);
    const res = await api(app, user, 'GET', `/v1/payments/${paymentId}/qr`);
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('image/png');
    expect(res.rawPayload.subarray(0, 4)).toEqual(QR_PNG.subarray(0, 4));
  });

  it('ATTACK: a forged PAID callback can never unlock — truth is fetched from Swish', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);

    // Angriparen postar en perfekt formaterad "PAID"-callback. Swish (fejk-
    // servern) säger fortfarande CREATED — ingenting får låsas upp.
    const forged = await app.inject({
      method: 'POST',
      url: '/v1/webhooks/payments/swish',
      payload: { id: ref, status: 'PAID', amount: 39.0, currency: 'SEK' },
    });
    expect(forged.statusCode).toBe(200);

    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('pending');
    const matches = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    expect((matches.json() as { locked?: boolean }).locked).toBe(true);
  });

  it('verified PAID confirms, issues a swish receipt and unlocks', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);

    swishState.set(ref, { status: 'PAID', amount: 39.0, currency: 'SEK' });
    const cb = await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: ref, status: 'PAID' } });
    expect(cb.statusCode).toBe(200);

    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    const body = status.json() as { state: string; receipt: { receiptNumber: string } };
    expect(body.state).toBe('confirmed');
    expect(body.receipt.receiptNumber).toMatch(/^BS-\d{4}-\d{6}$/);

    const receipt = await api(app, user, 'GET', `/v1/projects/${projectId}/receipt`);
    expect((receipt.json() as { receipt: { paymentMethod: string } }).receipt.paymentMethod).toBe('swish');
    const matches = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    expect((matches.json() as { matches?: unknown[] }).matches).toBeDefined();
  });

  it('a duplicate callback after confirmation is a harmless no-op', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);
    swishState.set(ref, { status: 'PAID', amount: 39.0, currency: 'SEK' });
    await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: ref } });
    await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: ref } });
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('confirmed');
  });

  it('an amount mismatch fails the payment instead of unlocking', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);
    swishState.set(ref, { status: 'PAID', amount: 1.0, currency: 'SEK' });
    await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: ref } });
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('failed');
    const matches = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    expect((matches.json() as { locked?: boolean }).locked).toBe(true);
  });

  it('a lost callback is recovered by status polling (verify-on-read)', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);
    swishState.set(ref, { status: 'PAID', amount: 39.0, currency: 'SEK' });
    // Ingen callback alls — pollingen ska själv verifiera mot Swish.
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('confirmed');
  });

  it('DECLINED marks the payment failed', async () => {
    const projectId = await newLockedProject();
    const { paymentId, ref } = await startSwishPayment(projectId);
    swishState.set(ref, { status: 'DECLINED', amount: 39.0, currency: 'SEK' });
    const status = await api(app, user, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('failed');
  });

  it('rejects malformed callback payloads', async () => {
    const res = await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: 'DROP TABLE payments' } });
    expect(res.statusCode).toBe(400);
    const unknown = await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: { id: 'A'.repeat(32) } });
    expect(unknown.statusCode).toBe(200); // okänd referens läcker ingenting
  });
});
