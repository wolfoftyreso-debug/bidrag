// Fjärr-röktest av en DEPLOYAD miljö (Vercel preview/produktion eller lokal).
// Verifierar utifrån, som en riktig klient: hälsa, readiness, konto, intag,
// Open Discovery (matchningar visas GRATIS), 19 kr-köpet per ansökan, ansökan,
// kvitton.
//
//   BASE_URL=https://<projekt>-<hash>.vercel.app node tools/deploy-smoke.mjs
//   CRON_SECRET=... BASE_URL=... node tools/deploy-smoke.mjs   # + readiness
//
// Betalningar: i Vercel Preview (PAYMENTS_MOCK_ENABLED=true) körs hela
// köpkedjan. I produktion utan Swish-avtal svarar 19 kr-köpet ärligt 503 — det
// är FÖRVÄNTAT och röktestet godkänner då resten av systemet och säger det rakt.
// (Open Discovery: den enda betalytan är att FÖRBEREDA en ansökan, 19 kr;
// matchningarna är alltid gratis. Ingen analysupplåsning finns.)
const BASE = process.env.BASE_URL;
if (!BASE) { console.error('Sätt BASE_URL, t.ex. BASE_URL=https://bidragskoll.vercel.app'); process.exit(2); }
const CRON = process.env.CRON_SECRET ?? null;
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

let cookie = '';
async function call(method, path, body, extraHeaders = {}) {
  const res = await fetch(BASE + path, {
    method,
    headers: {
      ...(body === undefined ? {} : { 'content-type': 'application/json' }),
      ...(cookie ? { cookie } : {}),
      ...extraHeaders,
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const setCookie = res.headers.getSetCookie?.() ?? [];
  const access = setCookie.find((c) => c.startsWith('bidrag_access='));
  if (access) cookie = access.split(';')[0];
  let json = null;
  try { json = await res.json(); } catch { /* tom kropp */ }
  return { status: res.status, json };
}

let failures = 0;
function check(name, ok, detail = '') {
  console.log(`${ok ? 'OK  ' : 'FAIL'} ${name}${detail ? ` — ${detail}` : ''}`);
  if (!ok) failures++;
}

// 1. Hälsa
const health = await fetch(BASE + '/healthz').then((r) => r.status).catch(() => 0);
check('healthz svarar 200', health === 200, `fick ${health}`);
if (health !== 200) { console.error('Miljön svarar inte — avbryter.'); process.exit(1); }

// 2. Readiness (kräver CRON_SECRET; hoppas annars)
if (CRON) {
  const r = await call('GET', '/v1/internal/readiness', undefined, { authorization: `Bearer ${CRON}` });
  check('readiness svarar', r.status === 200, `status ${r.status}`);
  if (r.status === 200) {
    check('databasen är ready', r.json?.checks?.database?.status === 'ready', JSON.stringify(r.json?.checks?.database));
    console.log('     blockerare:', (r.json?.blockers ?? []).join(', ') || 'inga');
  }
} else {
  console.log('SKIP readiness (sätt CRON_SECRET för att kontrollera)');
}

// 3. Konto (registrerings-rate-limiten är ~10/min — backoff)
let reg;
for (let i = 0; i < 8; i++) {
  reg = await call('POST', '/v1/auth/register', {
    email: `deploy-smoke-${Date.now()}@test.example`,
    password: 'mycket-sakert-losenord-123',
    displayName: 'Deploy-röktestaren',
  });
  if (reg.status !== 429) break;
  console.log('     register 429 — väntar 20 s (rate limit)');
  await wait(20_000);
}
check('konto skapas', reg.status === 201, `status ${reg.status} ${JSON.stringify(reg.json).slice(0, 120)}`);
if (reg.status !== 201) process.exit(1);

// 4. Profil + projekt (intagets resultat i API-form)
const prof = await call('POST', '/v1/profiles', {
  kind: 'person', displayName: 'D', applicantType: 'individual', country: 'SE',
  municipality: 'Stockholm', facts: { 'person.professionalArtist': true },
});
check('profil skapas', prof.status === 201, `status ${prof.status}`);
const proj = await call('POST', '/v1/projects', {
  profileId: prof.json?.profile?.id, title: 'Deploy-rök', intent: 'dansutbyte internationellt',
  facts: { 'project.hasInternationalComponent': true, 'project.sector': 'culture' },
});
check('projekt skapas', proj.status === 201, `status ${proj.status}`);
const prid = proj.json?.project?.id;
if (!prid) process.exit(1);

// 5. Open Discovery: matchningarna visas GRATIS — namngivna, utan betalning.
await call('POST', `/v1/projects/${prid}/matches`, {});
const matchesRes = await call('GET', `/v1/projects/${prid}/matches`);
const matches = matchesRes.json?.matches;
check('Open Discovery: matchningar visas gratis (inga låsta/teaser)',
  matchesRes.status === 200 && Array.isArray(matches) && matches.length > 0,
  `${matches?.length ?? 0} matchningar`);
const opp = matches?.[0];
if (!opp) process.exit(1);

// 6. 402-gaten: att förbereda en ansökan kräver kredit (priset i kroppen).
const gate = await call('POST', '/v1/applications', { projectId: prid, opportunityId: opp.opportunityId });
check('ansökan utan kredit ger 402 med pris', gate.status === 402 && gate.json?.priceMinor === 1900,
  `status ${gate.status}, ${gate.json?.priceMinor} öre`);

// 7. Köpet av en ansökan (19 kr) — den ENDA betalytan. Två ärliga utfall:
//    503 no_payment_provider (produktion utan Swish) → godkänn resten och säg det.
//    201 (preview med mock) → kör hela kedjan.
const pur = await call('POST', `/v1/projects/${prid}/application-purchase`, { immediateDeliveryConsent: true });
if (pur.status === 503) {
  check('19 kr-köp utan betalprovider vägrar ärligt (503)', pur.json?.error === 'no_payment_provider', JSON.stringify(pur.json));
  console.log('\nDEPLOY-SMOKE OK (utan betalflöde) — miljön har ingen betalprovider,');
  console.log('vilket är förväntat i Production utan Swish-avtal. Kör mot en');
  console.log('preview-deploy (PAYMENTS_MOCK_ENABLED=true i Preview) för hela köpkedjan.');
  process.exit(failures ? 1 : 0);
}
check('ansökningsköp 19 kr startar (201)', pur.status === 201 && pur.json?.amountMinor === 1900,
  `status ${pur.status}, ${pur.json?.amountMinor} öre`);

// 8. Bekräfta betalningen. Mock i preview; riktig Swish kan inte bekräftas av skript.
const method = pur.json?.instructions?.method;
if (method !== 'mock') {
  console.log(`     betalmetod ${method} — riktig Swish kan inte bekräftas av ett skript; avslutar här.`);
  process.exit(failures ? 1 : 0);
}
const conf = await call('POST', `/v1/payments/${pur.json?.paymentId}/mock-confirm`);
check('mockbetalning 19 kr bekräftas med kvitto', conf.status === 200 && !!conf.json?.receipt?.receiptNumber,
  `kvitto ${conf.json?.receipt?.receiptNumber}`);

// 9. Ansökan skapas med krediten.
const app = await call('POST', '/v1/applications', { projectId: prid, opportunityId: opp.opportunityId });
check('ansökan skapas med kredit (201)', app.status === 201, `state ${app.json?.application?.state}`);

// 10. Kvittot i kontot.
const purchases = await call('GET', '/v1/purchases');
check('Mina köp listar köpet med kvittonummer',
  purchases.status === 200 && (purchases.json?.purchases ?? []).filter((p) => p.receiptNumber).length >= 1,
  `${(purchases.json?.purchases ?? []).length} köp`);

console.log(failures === 0 ? '\nDEPLOY-SMOKE OK — hela kedjan verifierad mot ' + BASE : `\nDEPLOY-SMOKE FAIL — ${failures} kontroller föll`);
process.exit(failures ? 1 : 0);
