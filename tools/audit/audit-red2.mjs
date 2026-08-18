/** Uppföljningsprober: R17 med korrekt tillståndssekvens + R12 komplett mall + R1 full. */
const API = 'http://localhost:3100';
let cookie = '';
async function call(method, path, body) {
  const res = await fetch(API + path, { method, headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie }, body: body ? JSON.stringify(body) : undefined });
  const setC = res.headers.getSetCookie?.() ?? [];
  if (setC.length) cookie = setC.map((c) => c.split(';')[0]).join('; ');
  const text = await res.text();
  let json = null; try { json = JSON.parse(text); } catch {}
  return { status: res.status, json, text };
}
async function uploadPdf(kind) {
  const b = '----red2';
  const pdf = `--${b}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${kind}\r\n--${b}\r\nContent-Disposition: form-data; name="file"; filename="${kind}.pdf"\r\nContent-Type: application/pdf\r\n\r\n%PDF-1.4\n%%EOF\n\r\n--${b}--\r\n`;
  const up = await fetch(`${API}/v1/documents`, { method: 'POST', headers: { cookie, 'content-type': `multipart/form-data; boundary=${b}` }, body: pdf });
  return (await up.json()).document;
}
const stamp = Date.now();
await call('POST', '/v1/auth/register', { email: `red2-${stamp}@test.example`, password: 'redteam-losenord-123', displayName: 'Vera Redteam' });
const prof = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'Vera Redteam', applicantType: 'individual', country: 'SE', municipality: 'Malmö', facts: { 'person.professionalArtist': true } });
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Dansutbyte Kingston', intent: 'Residens', totalBudgetMinor: 4000000, facts: { 'project.sector': 'culture', 'project.activityTypes': ['exchange'], 'project.hasInternationalComponent': true, 'project.bringsKnowledgeBack': true, 'project.targetGroups': ['professionals'] } });
const pid = proj.json.project.id;
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`);
await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
await call('POST', `/v1/projects/${pid}/matches`, {});
const m = await call('GET', `/v1/projects/${pid}/matches`);
const travel = m.json.matches.find((r) => r.slug === 'kulturradet-internationellt-resebidrag-musik');
const c = await call('POST', '/v1/applications', { projectId: pid, opportunityId: travel.opportunityId });
const id = c.json.application.id;
const det = await call('GET', `/v1/applications/${id}`);
const answers = {};
for (const f of det.json.schema?.fields ?? []) {
  if (!f.required) continue;
  answers[f.key] = f.type === 'number' || f.type === 'currency' ? 15000 : f.type === 'percentage' ? 50
    : f.type === 'boolean' || f.type === 'declaration' ? true : f.type === 'date' ? '2026-10-01'
    : f.type === 'date_range' ? ['2026-10-01', '2026-10-14'] : f.type === 'select' ? (f.options?.[0]?.value ?? 'a')
    : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a'] : 'Residens hos Kingston Dance Collective i oktober.';
}
await call('PATCH', `/v1/applications/${id}`, { answers });
await call('POST', `/v1/applications/${id}/budget-lines`, { category: 'travel', description: 'Flyg t/r', quantity: 1, unitCostMinor: 1300000 });
await call('POST', `/v1/applications/${id}/budget-lines`, { category: 'accommodation', description: 'Boende', quantity: 5, unitCostMinor: 80000 });
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });
let rev = await call('GET', `/v1/applications/${id}/review`);
for (const e of rev.json.review.evidence.filter((e) => e.status === 'MISSING')) {
  const doc = await uploadPdf(e.kind);
  await call('POST', `/v1/applications/${id}/documents`, { documentId: doc.id, role: 'evidence' });
}
// R17 korrekt: gå till READY_FOR_REVIEW först
await call('POST', `/v1/applications/${id}/transition`, { to: 'PREPARING' });
await call('POST', `/v1/applications/${id}/transition`, { to: 'READY_FOR_REVIEW' });
// bryt finansieringen → gaten ska vägra med granskningen i svaret
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 2600000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 } });
const t1 = await call('POST', `/v1/applications/${id}/transition`, { to: 'READY_TO_SUBMIT' });
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });
const t2 = await call('POST', `/v1/applications/${id}/transition`, { to: 'READY_TO_SUBMIT' });
console.log(JSON.stringify({
  R17: {
    blockedWhenBroken: t1.status,
    refusalCarriesReview: !!(t1.json?.review),
    refusalTopGap: t1.json?.review?.gaps?.[0]?.id ?? null,
    allowedWhenFixed: t2.status,
  },
}, null, 1));

// R12 komplett: ansokan-ekonomiskt-stod med ALLA obligatoriska svar
const pack = await call('POST', `/v1/projects/${pid}/document-pack`, { pack: 'single' });
await call('POST', `/v1/payments/${pack.json.paymentId}/mock-confirm`);
const g = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'ansokan-ekonomiskt-stod',
  answers: {
    fullName: 'Vera Redteam', address: 'Möllevångsgatan 3', postalCity: '214 20 Malmö', municipality: 'Malmö',
    householdAdults: 1, hasChildren: false, whatFor: 'Avgift för dansresidens.', amount: 15000,
    situation: 'Frilansande dansare med ojämn inkomst.', whyNeeded: 'Residenset infaller innan nästa uppdragsperiod börjar.',
  },
});
if (g.status !== 201) { console.log('R12 GEN FAIL', g.status, g.text.slice(0, 300)); }
else {
  const dl = await fetch(`${API}/v1/generated-documents/${g.json.document.id}/download?format=text`, { headers: { cookie } });
  const text = await dl.text();
  const FORBIDDEN = ['Bidrag.se', 'bidrag.se', ' AI ', 'genererad', 'generated', 'optimized', 'INTERNAL', 'score', 'prompt'];
  console.log(JSON.stringify({ R12_ansokan: { forbidden: FORBIDDEN.filter((f) => text.includes(f)), uuidLeak: /[0-9a-f]{8}-[0-9a-f]{4}/.test(text), hasTitle: text.startsWith('ANSÖKAN'), hasRecipient: text.includes('Till:') } }, null, 1));
}
