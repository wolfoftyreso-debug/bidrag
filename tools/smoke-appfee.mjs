// Rökttest av prismodellen: 402 utan kredit → köp 19 kr → bekräfta → 201 → 402 igen.
const B = 'http://localhost:3100';
let cookie = '';
const wait = (ms) => new Promise((r) => setTimeout(r, ms));

async function call(method, path, body) {
  const res = await fetch(B + path, {
    method,
    headers: { ...(body === undefined ? {} : { 'content-type': 'application/json' }), ...(cookie ? { cookie } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const setCookie = res.headers.getSetCookie?.() ?? [];
  const access = setCookie.find((c) => c.startsWith('bidrag_access='));
  if (access) cookie = access.split(';')[0];
  let json = null;
  try { json = await res.json(); } catch { /* tom kropp */ }
  return { status: res.status, json };
}

// Registrering med backoff (sim30 kan ha tömt rate-limiten).
let reg;
for (let i = 0; i < 8; i++) {
  reg = await call('POST', '/v1/auth/register', {
    email: `smoke-appfee-${Date.now()}@test.example`,
    password: 'mycket-sakert-losenord-123',
    displayName: 'Röktestaren',
  });
  if (reg.status === 201) break;
  console.log(`register ${reg.status} — väntar 20 s`);
  await wait(20_000);
}
if (reg.status !== 201) { console.error('FAIL register', reg.status); process.exit(1); }

const prof = await call('POST', '/v1/profiles', {
  kind: 'person', displayName: 'R', applicantType: 'individual', country: 'SE',
  municipality: 'Stockholm', facts: { 'person.professionalArtist': true },
});
const proj = await call('POST', '/v1/projects', {
  profileId: prof.json.profile.id, title: 'Rök', intent: 'dansutbyte internationellt',
  facts: { 'project.hasInternationalComponent': true, 'project.sector': 'culture' },
});
const prid = proj.json.project.id;

const unlock = await call('POST', `/v1/projects/${prid}/analysis-unlock`, { immediateDeliveryConsent: true });
const uconf = await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
console.log('analysis-unlock', unlock.status, '→ confirm', uconf.status, JSON.stringify(uconf.json).slice(0, 120));
await call('POST', `/v1/projects/${prid}/matches`, {});
const m = await call('GET', `/v1/projects/${prid}/matches`);
if (!m.json?.matches) { console.error('FAIL matches', m.status, JSON.stringify(m.json).slice(0, 200)); process.exit(1); }
const opp = m.json.matches.find((x) => x.slug === 'kulturradet-internationellt-resebidrag-musik');

const results = [];
const step1 = await call('POST', '/v1/applications', { projectId: prid, opportunityId: opp.opportunityId });
results.push(['utan kredit → 402', step1.status, JSON.stringify(step1.json)]);

const status = await call('GET', `/v1/projects/${prid}/unlock-status`);
results.push(['unlock-status applicationPriceMinor', status.json.applicationPriceMinor]);

const pur = await call('POST', `/v1/projects/${prid}/application-purchase`, { immediateDeliveryConsent: true });
results.push(['köp 19 kr → 201', pur.status, pur.json.amountMinor]);
const conf = await call('POST', `/v1/payments/${pur.json.paymentId}/mock-confirm`);
results.push(['mock-confirm → 200', conf.status, conf.json?.receipt?.receiptNumber]);

const step3 = await call('POST', '/v1/applications', { projectId: prid, opportunityId: opp.opportunityId });
results.push(['med kredit → 201', step3.status, step3.json?.application?.state]);

const step4 = await call('POST', '/v1/applications', { projectId: prid, opportunityId: opp.opportunityId });
results.push(['kredit förbrukad → 402', step4.status]);

const purchases = await call('GET', '/v1/purchases');
for (const p of purchases.json.purchases) results.push(['köp', p.kind, p.amountMinor, p.receiptNumber]);

for (const r of results) console.log(...r);
const ok = step1.status === 402 && pur.status === 201 && pur.json.amountMinor === 1900
  && step3.status === 201 && step4.status === 402 && status.json.applicationPriceMinor === 1900;
console.log(ok ? 'SMOKE OK' : 'SMOKE FAIL');
process.exit(ok ? 0 : 1);
