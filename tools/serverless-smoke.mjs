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
// Open Discovery: matchningarna visas GRATIS — namngivna, aldrig låsta.
await call('POST', `/v1/projects/${pid}/matches`, {});
const matches = await call('GET', `/v1/projects/${pid}/matches`);
if (!Array.isArray(matches.json.matches) || matches.json.matches.length === 0) throw new Error('matchningar saknas');
console.log(`OK: Open Discovery — ${matches.json.matches.length} gratis matchningar genom handlern`);

// Den enda betalytan: förbered en ansökan (19 kr) → mock-confirm → kvitto med moms.
// F-INGEN-ANSÖKAN: välj ett stöd som faktiskt har en ansökan (tandvårdsbidraget m.fl. vägras ärligt med 409).
const opp = matches.json.matches.find((m) => m.requiresApplication !== false);
if (!opp) throw new Error('ingen matchning med ansökan att förbereda');
const gate = await call('POST', '/v1/applications', { projectId: pid, opportunityId: opp.opportunityId });
if (gate.status !== 402 || gate.json.priceMinor !== 1900) throw new Error(`402-gate: ${gate.status} ${gate.json.priceMinor}`);
const pur = await call('POST', `/v1/projects/${pid}/application-purchase`, { email: 'sv@test.example', immediateDeliveryConsent: true });
if (pur.status !== 201) throw new Error(`köp: ${pur.status} ${JSON.stringify(pur.json).slice(0, 160)}`);
const confirm = await call('POST', `/v1/payments/${pur.json.paymentId}/mock-confirm`);
if (!confirm.json.receipt?.receiptNumber) throw new Error('kvitto saknas');
const receipt = await call('GET', `/v1/projects/${pid}/receipt`);
if (receipt.json.receipt.vatAmountMinor !== 380) throw new Error(`moms fel: ${receipt.json.receipt.vatAmountMinor} (väntade 380 av 1900)`);
const app2 = await call('POST', '/v1/applications', { projectId: pid, opportunityId: opp.opportunityId });
if (app2.status !== 201) throw new Error(`ansökan med kredit: ${app2.status}`);
console.log(`OK: 402 → 19 kr-köp → kvitto ${confirm.json.receipt.receiptNumber} (moms 380 öre) → ansökan, genom handlern`);

const cronNoAuth = await call('POST', '/v1/internal/cron/deadline-scan');
if (cronNoAuth.status !== 401) throw new Error(`cron utan token: ${cronNoAuth.status}`);
const cron = await call('POST', '/v1/internal/cron/deadline-scan', undefined, { authorization: 'Bearer smoke-cron-secret' });
if (cron.status !== 200 || !cron.json.ok) throw new Error(`cron: ${cron.status}`);
console.log('OK: cron-endpoint (401 utan token, kör med token)');

server.close();
console.log('SERVERLESS SMOKE PASSED');
process.exit(0);
