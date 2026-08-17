#!/usr/bin/env node
/**
 * Swish production-readiness test — körs mot en RIKTIG miljö (preview eller
 * produktion) när handelsavtal + certifikat finns i miljövariablerna.
 * Verifierar hela kedjan från milstolpens definition:
 *
 *   payment request skapas (mTLS) → QR levereras → [MÄNNISKA BETALAR i
 *   Swish-appen / MSS simulerar] → callback/polling → verifierad status →
 *   payment=confirmed → kvitto med löpnummer → upplåsning → kvittomail
 *
 * Användning:
 *   BASE_URL=https://preview.bidragskoll.se EMAIL=du@ex.se PASSWORD=... node scripts/swish-readiness.mjs
 *
 * Skriptet skapar konto/fixture via publika API:t, startar en riktig
 * Swish-betalning och pollar tills betalningen bekräftats eller timeout.
 * Mot MSS bekräftas betalningen automatiskt av simulatorn; i produktion
 * betalar en människa 39 kr på riktigt (och bör därefter återbetalas
 * manuellt i Swish-portalen — noteras i utskriften).
 */
const BASE = process.env.BASE_URL ?? 'http://localhost:3000';
const EMAIL = process.env.EMAIL ?? `swish-readiness-${Date.now()}@example.com`;
const PASSWORD = process.env.PASSWORD ?? `Readiness-${Date.now()}!`;
const TIMEOUT_MS = Number(process.env.TIMEOUT_MS ?? 180_000);

let cookie = '';
async function call(method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie },
    body: body ? JSON.stringify(body) : undefined,
  });
  for (const c of res.headers.getSetCookie?.() ?? []) {
    if (c.startsWith('bidrag_access=')) cookie = c.split(';')[0];
  }
  return { status: res.status, json: await res.json().catch(() => ({})), raw: res };
}
const fail = (msg) => { console.error(`✗ ${msg}`); process.exit(1); };
const ok = (msg) => console.log(`✓ ${msg}`);

// 1. Konto + fixture
const reg = await call('POST', '/v1/auth/register', { email: EMAIL, password: PASSWORD, displayName: 'Swish readiness' });
if (reg.status === 409) await call('POST', '/v1/auth/login', { email: EMAIL, password: PASSWORD });
else if (reg.status !== 201) fail(`registrering: ${reg.status}`);
ok(`inloggad som ${EMAIL}`);

const prof = await call('POST', '/v1/profiles', {
  kind: 'person', displayName: 'Readiness', applicantType: 'individual', country: 'SE',
  facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
});
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Swish readiness', intent: 'test' });
const projectId = proj.json.project.id;
await call('POST', `/v1/projects/${projectId}/matches`, {});
const teaser = await call('GET', `/v1/projects/${projectId}/matches`);
if (!teaser.json.locked) fail('teasern saknas — projektet är inte låst');
ok('analys skapad och låst (teaser)');

// 2. Riktig Swish-betalning
const unlock = await call('POST', `/v1/projects/${projectId}/analysis-unlock`, { email: EMAIL });
if (unlock.status === 503) fail('Swish är inte konfigurerat i den här miljön (503) — sätt SWISH_*-variablerna');
if (unlock.status !== 201) fail(`analysis-unlock: ${unlock.status} ${JSON.stringify(unlock.json)}`);
if (unlock.json.instructions.method !== 'swish') fail(`fel provider aktiv: ${unlock.json.instructions.method} (mock får inte vara aktiv här)`);
const paymentId = unlock.json.paymentId;
ok(`payment request skapad hos Swish (payment ${paymentId})`);
if (unlock.json.instructions.deepLink) console.log(`  app-länk: ${unlock.json.instructions.deepLink}`);

const qr = await fetch(`${BASE}/v1/payments/${paymentId}/qr`, { headers: { cookie } });
if (!qr.ok) fail(`QR-hämtning: ${qr.status}`);
const png = Buffer.from(await qr.arrayBuffer());
if (png[0] !== 0x89 || png[1] !== 0x50) fail('QR-svaret är inte en PNG');
ok(`QR-kod levererad (${png.length} byte) — skanna och betala nu om detta är en riktig miljö`);

// 3. Polling tills banken bekräftat (servern verifierar mot Swish vid varje poll)
const deadline = Date.now() + TIMEOUT_MS;
let state = 'pending';
while (Date.now() < deadline && state === 'pending') {
  await new Promise((r) => setTimeout(r, 3000));
  const s = await call('GET', `/v1/payments/${paymentId}/status`);
  state = s.json.state;
  if (state === 'confirmed') {
    ok(`betalning verifierad och bekräftad — kvitto ${s.json.receipt?.receiptNumber}`);
    break;
  }
  if (state === 'failed') fail('betalningen fick status failed (avvisad eller beloppsavvikelse)');
  process.stdout.write('  … väntar på betalning\r');
}
if (state !== 'confirmed') fail(`timeout efter ${TIMEOUT_MS} ms — betalningen bekräftades aldrig`);

// 4. Upplåsning + kvitto + moms
const matches = await call('GET', `/v1/projects/${projectId}/matches`);
if (!matches.json.matches) fail('analysen är inte upplåst efter bekräftad betalning');
ok('analysen upplåst');
const receipt = await call('GET', `/v1/projects/${projectId}/receipt`);
const r = receipt.json.receipt;
if (r.paymentMethod !== 'swish') fail(`kvittots betalmetod: ${r.paymentMethod}`);
if (r.amountNetMinor + r.vatAmountMinor !== r.amountGrossMinor) fail('momsmatten stämmer inte');
ok(`kvitto ${r.receiptNumber}: ${r.amountGrossMinor} öre varav moms ${r.vatAmountMinor} öre · mailstatus: ${r.emailStatus}`);

console.log('\nSWISH PRODUCTION-READINESS: PASSED');
console.log('OBS: om detta var en riktig betalning — återbetala 39 kr i Swish-portalen och verifiera kvittomailet i inkorgen.');
