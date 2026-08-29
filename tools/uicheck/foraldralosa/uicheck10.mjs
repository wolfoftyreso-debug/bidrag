/**
 * Granskningspanelen i webbläsare: skapa ansökan → Granska (NOT_READY med
 * prioriterade luckor) → komplettera via API → Granska igen (READY med
 * kriteriematris, evidensnivåer, INTERNAL_ESTIMATE och diligence).
 */
import { launchChromium, artifactsDir } from '../../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const S = artifactsDir;
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1200, height: 1100 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

// Konto + behörigt projekt + ansökan — via API i sidans kontext (samma cookies).
await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Granskningspersona');
await page.fill('#email', `gr-${stamp}@test.example`);
await page.fill('#password', 'gransknings-losenord-1');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');

const caseId = await page.evaluate(async () => {
  const call = async (m, u, b) => {
    const r = await fetch(u, { method: m, credentials: 'include', headers: b ? { 'Content-Type': 'application/json' } : {}, body: b ? JSON.stringify(b) : undefined });
    if (!r.ok) throw new Error(`${m} ${u} ${r.status}: ${await r.text()}`);
    return r.json();
  };
  const { profile } = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'G', applicantType: 'individual', country: 'SE', municipality: 'Malmö', facts: { 'person.professionalArtist': true } });
  const { project } = await call('POST', '/v1/projects', { profileId: profile.id, title: 'Dansutbyte', intent: 'Utbyte', facts: { 'project.sector': 'culture', 'project.activityTypes': ['exchange'], 'project.hasInternationalComponent': true, 'project.bringsKnowledgeBack': true, 'project.targetGroups': ['professionals'] } });
  const unlock = await call('POST', `/v1/projects/${project.id}/analysis-unlock`);
  await call('POST', `/v1/payments/${unlock.paymentId}/mock-confirm`);
  await call('POST', `/v1/projects/${project.id}/matches`, {});
  const { matches } = await call('GET', `/v1/projects/${project.id}/matches`);
  const travel = matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik');
  const { application } = await call('POST', '/v1/applications', { projectId: project.id, opportunityId: travel.opportunityId });
  return application.id;
});

// 1. Granska den tomma ansökan → NOT_READY med luckor.
await page.goto(`${BASE}/ansokningar/${caseId}`);
await page.waitForSelector('text=Granskning inför inlämning');
await page.click('button:has-text("Granska ansökan")');
await page.waitForSelector('text=Inte klar än');
const body1 = await page.innerText('body');
if (!/Kritisk|Hög/.test(body1)) { console.log('FEL: inga prioriterade luckor'); process.exit(1); }
console.log('1. Tom ansökan → "Inte klar än" med prioriterade luckor ✓');

// 2. Komplettera helt via API (fält, budget, finansiering, bevisning).
await page.evaluate(async (caseId) => {
  const call = async (m, u, b) => {
    const r = await fetch(u, { method: m, credentials: 'include', headers: b ? { 'Content-Type': 'application/json' } : {}, body: b ? JSON.stringify(b) : undefined });
    if (!r.ok) throw new Error(`${m} ${u} ${r.status}`);
    return r.json();
  };
  const d = await call('GET', `/v1/applications/${caseId}`);
  const answers = {};
  for (const f of d.schema?.fields ?? []) {
    if (!f.required) continue;
    answers[f.key] = f.type === 'currency' ? 15000 : f.type === 'number' ? 12000
      : f.type === 'boolean' || f.type === 'declaration' ? true
      : f.type === 'date' ? '2026-10-01' : f.type === 'date_range' ? ['2026-10-01', '2026-10-14']
      : f.type === 'select' ? (f.options?.[0]?.value ?? 'a') : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a']
      : 'Residens hos Kingston Dance Collective.';
  }
  await call('PATCH', `/v1/applications/${caseId}`, { answers });
  await call('POST', `/v1/applications/${caseId}/budget-lines`, { category: 'travel', description: 'Flyg t/r', quantity: 2, unitCostMinor: 850000 });
  await call('PATCH', `/v1/applications/${caseId}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });
  const rev = await call('GET', `/v1/applications/${caseId}/review`);
  for (const e of rev.review.evidence.filter((e) => e.status === 'MISSING')) {
    const boundary = '----ui10';
    const pdf = `--${boundary}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${e.kind}\r\n--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${e.kind}.pdf"\r\nContent-Type: application/pdf\r\n\r\n%PDF-1.4\n%%EOF\n\r\n--${boundary}--\r\n`;
    const up = await fetch('/v1/documents', { method: 'POST', credentials: 'include', headers: { 'content-type': `multipart/form-data; boundary=${boundary}` }, body: pdf });
    const { document } = await up.json();
    await call('POST', `/v1/applications/${caseId}/documents`, { documentId: document.id, role: 'evidence' });
  }
}, caseId);

// 3. Granska igen → READY med matris, evidensnivåer och diligence.
await page.click('button:has-text("Granska igen")');
await page.waitForSelector('text=Klar att lämna in');
await page.click('summary:has-text("Bedömning per kriterium")');
await page.waitForSelector('text=INTERNAL_ESTIMATE');
const body2 = await page.innerText('body');
for (const expected of ['kan inte vägas upp', 'E2', 'uppfylld enligt dina svar']) {
  if (!body2.includes(expected)) { console.log(`FEL: saknar "${expected}"`); process.exit(1); }
}
console.log('2. Komplett ansökan → "Klar att lämna in" + kriteriematris med E2 och INTERNAL_ESTIMATE ✓');

await page.click('summary:has-text("Det här kan handläggaren vilja kontrollera")');
const body3 = await page.innerText('body');
if (!body3.includes('E1')) { console.log('FEL: diligence saknar E1-hänvisning'); process.exit(1); }
console.log('3. Diligence-listan visar vad handläggaren kan begära ✓');

await page.screenshot({ path: `${S}/shot-granskning.png`, fullPage: true });
await browser.close();
console.log('UICHECK10 KLAR — granskningspanelen fungerar i webbläsaren.');
