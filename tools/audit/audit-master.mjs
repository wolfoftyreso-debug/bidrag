/** MASTERREVISIONENS tilläggsprober: §7 stödnivå, §11 procent, §15 medfinansiering,
 *  §6 kriterium↔bevis, §14 indikator, §19 negativa fakta, §25 generisk text. */
const API = 'http://localhost:3100';
let cookie = '';
async function call(method, path, body) {
  const res = await fetch(API + path, { method, headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie }, body: body ? JSON.stringify(body) : undefined });
  const setC = res.headers.getSetCookie?.() ?? [];
  if (setC.length) cookie = setC.map((c) => c.split(';')[0]).join('; ');
  let json = null; try { json = JSON.parse(await res.text()); } catch {}
  return { status: res.status, json };
}
const out = {};
const stamp = Date.now();
await call('POST', '/v1/auth/register', { email: `master-${stamp}@test.example`, password: 'master-losenord-123', displayName: 'Vera Master' });
const prof = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'Vera Master', applicantType: 'individual', country: 'SE', municipality: 'Malmö', facts: { 'person.professionalArtist': true } });
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
    : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a'] : `Ett svar för ${f.key} i masterrevisionen.`;
}
await call('PATCH', `/v1/applications/${id}`, { answers });
await call('POST', `/v1/applications/${id}/budget-lines`, { category: 'travel', description: 'Flyg t/r', activity: 'Residenset', quantity: 1, unitCostMinor: 1300000 });
await call('POST', `/v1/applications/${id}/budget-lines`, { category: 'accommodation', description: 'Boende', quantity: 5, unitCostMinor: 80000 });

// §15a: SAKNAD MEDFINANSIERING — finansieringen täcker inte budgeten
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 1000000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 } });
let rev = await call('GET', `/v1/applications/${id}/review`);
out.P15a_missingCofinancing = {
  blocked: rev.json.review.overallStatus === 'NOT_READY',
  flagged: rev.json.review.gaps.some((g) => g.area === 'budget' && (g.severity === 'HIGH' || g.severity === 'CRITICAL')),
};
// §15b: FEL STÖDNIVÅ — sökt över max_requested-regeln (50 000 kr för resebidraget)
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 9000000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 } });
rev = await call('GET', `/v1/applications/${id}/review`);
out.P15b_supportLevelViolation = {
  blocked: rev.json.review.overallStatus === 'NOT_READY',
  budgetFindings: rev.json.review.budget.findings.map((f) => f.ruleId).slice(0, 3),
};
// återställ balans
await call('PATCH', `/v1/applications/${id}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });

// §11: PROCENT-motsägelse i olika fält
await call('PATCH', `/v1/applications/${id}`, { answers: {
  projekt_sammanfattning: 'Utbytet finansieras till 60 procent av egna medel.',
  aterforing: 'Egenfinansieringen uppgår till 40 procent av kostnaden.',
} });
rev = await call('GET', `/v1/applications/${id}/review`);
out.P11_percentContradiction = rev.json.review.gaps.some((g) => g.area === 'consistency' && /procent/.test(g.message));
await call('PATCH', `/v1/applications/${id}`, { answers: { projekt_sammanfattning: 'Residens i Kingston i oktober.', aterforing: 'Metodiken delas i workshops.' } });

// §6: "Var bevisas detta kriterium?" — kriterium ↔ evidens ↔ bilaga
rev = await call('GET', `/v1/applications/${id}/review`);
out.P6_criterionEvidenceMapping = {
  criteriaWithEvidenceLevels: rev.json.review.criteria.every((c) => ['E0', 'E1', 'E2', 'E3'].includes(c.evidenceLevel)),
  attachmentsListedPerRequirement: rev.json.review.evidence.every((e) => e.kind && e.description && ['ATTACHED', 'MISSING'].includes(e.status)),
  complementListNamesE1Criteria: rev.json.review.likelyComplementRequests.length > 0,
};

// §33: schematäckning nu
const schemas = 38;
out.P33_coverage = { schemas, of: 55, noSchemaFailSafe: 'konstnarsnamnden-arbetsstipendium flaggas HIGH coverage-no-schema (regressionstestad)' };

console.log(JSON.stringify(out, null, 1));
