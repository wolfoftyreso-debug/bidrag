/**
 * Simulerar Vercel: varje request går genom api/index.ts-handlern (inte
 * app.listen). Kör en hel köpresa för att bevisa att entryn fungerar.
 */
import http from 'node:http';

process.env.DATABASE_URL = 'postgres://postgres@localhost:5432/bidrag';
process.env.AUTH_SECRET = 'dev-secret-dev-secret-dev-secret-1234';
process.env.FIELD_ENCRYPTION_KEY = '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';
process.env.UPLOAD_DIR = './uploads';
process.env.PAYMENTS_MOCK_ENABLED = 'true';
process.env.CRON_SECRET = 'smoke-cron-secret';
process.env.LOG_LEVEL = 'silent';

const { default: handler } = await import('../api/index.ts');

const server = http.createServer((req, res) => handler(req, res));
await new Promise((r) => server.listen(3200, r));

const base = 'http://localhost:3200';
let cookie = '';

async function call(method, path, body, extraHeaders = {}) {
  const res = await fetch(base + path, {
    method,
    headers: { ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}), cookie, ...extraHeaders },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const setCookie = res.headers.getSetCookie?.() ?? [];
  for (const c of setCookie) if (c.startsWith('bidrag_access=')) cookie = c.split(';')[0];
  return { status: res.status, json: await res.json().catch(() => ({})) };
}

const health = await call('GET', '/healthz');
if (!health.json.ok) throw new Error('healthz failed');
console.log('OK: healthz genom handlern');

const reg = await call('POST', '/v1/auth/register', {
  email: `serverless-${Date.now()}@test.example`, password: 'mycket-sakert-losenord-123', displayName: 'Serverless',
});
if (reg.status !== 201) throw new Error(`register: ${reg.status}`);
console.log('OK: registrering (cookies fungerar genom handlern)');

const prof = await call('POST', '/v1/profiles', {
  kind: 'person', displayName: 'S', applicantType: 'individual', country: 'SE',
  facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
});
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Serverless', intent: 'test' });
const pid = proj.json.project.id;
await call('POST', `/v1/projects/${pid}/matches`, {});
const teaser = await call('GET', `/v1/projects/${pid}/matches`);
if (!teaser.json.locked) throw new Error('teaser saknas');
console.log('OK: matchning + teaser');

const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`, { email: 'sv@test.example', immediateDeliveryConsent: true });
console.log("unlock:", unlock.status, JSON.stringify(unlock.json).slice(0,200));
const confirm = await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
console.log("confirm:", confirm.status, JSON.stringify(confirm.json).slice(0,200));
if (!confirm.json.receipt?.receiptNumber) throw new Error('kvitto saknas');
const receipt = await call('GET', `/v1/projects/${pid}/receipt`);
if (receipt.json.receipt.vatAmountMinor !== 780) throw new Error('moms fel');
console.log(`OK: betalning + kvitto ${confirm.json.receipt.receiptNumber} genom handlern`);

const cronNoAuth = await call('POST', '/v1/internal/cron/deadline-scan');
if (cronNoAuth.status !== 401) throw new Error(`cron utan token: ${cronNoAuth.status}`);
const cron = await call('POST', '/v1/internal/cron/deadline-scan', undefined, { authorization: 'Bearer smoke-cron-secret' });
if (cron.status !== 200 || !cron.json.ok) throw new Error(`cron: ${cron.status}`);
console.log('OK: cron-endpoint (401 utan token, kör med token)');

server.close();
console.log('SERVERLESS SMOKE PASSED');
process.exit(0);
