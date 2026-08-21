/** Verifiera: nya scheman aktiva, K3-flaggan släckt, korskontroller verkar. */
const API = 'http://localhost:3100';
let cookie = '';
async function call(method, path, body) {
  const res = await fetch(API + path, { method, headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie }, body: body ? JSON.stringify(body) : undefined });
  const setC = res.headers.getSetCookie?.() ?? [];
  if (setC.length) cookie = setC.map((c) => c.split(';')[0]).join('; ');
  let json = null; try { json = JSON.parse(await res.text()); } catch {}
  return { status: res.status, json };
}
const stamp = Date.now();
await call('POST', '/v1/auth/register', { email: `schema-${stamp}@test.example`, password: 'schema-losenord-123', displayName: 'Skema Testsson' });
const prof = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'Skema Testsson', applicantType: 'individual', country: 'SE', municipality: 'Norrköping', facts: {
  'person.householdType': 'alone', 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true,
  'person.incomeInsufficientForBasicNeeds': true, 'person.limitedSavings': true, 'person.paysHousingCost': true, 'person.housingCostMonthly': 8500,
} });
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Min situation', intent: 'test' });
const pid = proj.json.project.id;
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`, { immediateDeliveryConsent: true });
await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
await call('POST', `/v1/projects/${pid}/matches`, {});
const m = await call('GET', `/v1/projects/${pid}/matches`);
const out = {};
for (const slug of ['kommun-forsorjningsstod', 'fk-bostadsbidrag-barnfamiljer', 'majblomman-bidrag-barn']) {
  const row = m.json.matches.find((r) => r.slug === slug);
  if (!row) { out[slug] = 'EJ I SVARET'; continue; }
  // Prismodellen: varje ansökan i systemet kostar 19 kr — köp en kredit först.
  const pur = await call('POST', `/v1/projects/${pid}/application-purchase`, { immediateDeliveryConsent: true });
  await call('POST', `/v1/payments/${pur.json.paymentId}/mock-confirm`);
  const c = await call('POST', '/v1/applications', { projectId: pid, opportunityId: row.opportunityId });
  if (c.status !== 201) { out[slug] = `CASE FAIL ${c.status}`; continue; }
  const det = await call('GET', `/v1/applications/${c.json.application.id}`);
  const rev = await call('GET', `/v1/applications/${c.json.application.id}/review`);
  out[slug] = {
    hasSchema: det.json.schema !== null,
    fields: det.json.schema?.fields?.length ?? 0,
    noSchemaFlag: rev.json.review.gaps.some((g) => g.id === 'coverage-no-schema'),
    namePrefilAndProvenance: det.json.application.answers?.sokande_namn ?? null,
  };
}
console.log(JSON.stringify(out, null, 1));
