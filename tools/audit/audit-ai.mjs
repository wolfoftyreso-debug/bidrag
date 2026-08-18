/**
 * OBEROENDE SLUTREVISION — live-prober mot körande system (inga fixar).
 * Verklig utlysning: Kulturrådets internationella resebidrag (kurerad ur
 * officiell källa). Avsiktliga fel injiceras; systemets faktiska beteende
 * registreras utan välvilliga antaganden.
 */
const API = 'http://localhost:3100';
let cookie = '';
async function call(method, path, body) {
  const res = await fetch(API + path, {
    method,
    headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie },
    body: body ? JSON.stringify(body) : undefined,
  });
  const setC = res.headers.getSetCookie?.() ?? [];
  if (setC.length) cookie = setC.map((c) => c.split(';')[0]).join('; ');
  const text = await res.text();
  let json = null; try { json = JSON.parse(text); } catch {}
  return { status: res.status, json, text };
}
const out = {};
const stamp = Date.now();

// ── Setup: professionell dansare (behörig för resebidraget) ──
await call('POST', '/v1/auth/register', { email: `rev-${stamp}@test.example`, password: 'revisions-losenord-123', displayName: 'Revisionspersona' });
const prof = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'R', applicantType: 'individual', country: 'SE', municipality: 'Malmö', facts: { 'person.professionalArtist': true } });
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Dansutbyte Kingston', intent: 'Residens och utbyte i Jamaica', totalBudgetMinor: 4000000, facts: { 'project.sector': 'culture', 'project.activityTypes': ['exchange'], 'project.hasInternationalComponent': true, 'project.bringsKnowledgeBack': true, 'project.targetGroups': ['professionals'] } });
const pid = proj.json.project.id;
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`);
await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
await call('POST', `/v1/projects/${pid}/matches`, {});
const m = await call('GET', `/v1/projects/${pid}/matches`);
const rows = m.json.matches;

// ── P1: Eligibility trevärde + UNKNOWN ≠ PASS ──
const travel = rows.find((r) => r.slug === 'kulturradet-internationellt-resebidrag-musik');
const erasmus = rows.find((r) => r.slug === 'erasmus-plus-ungdomsutbyten');
const unknowns = rows.filter((r) => r.eligibilityStatus === 'unknown');
out.P1 = {
  travel: travel?.eligibilityStatus,
  erasmusExcludedWithReason: erasmus ? { status: erasmus.eligibilityStatus, reason: erasmus.result.excludedBy?.[0]?.description ?? null } : 'EJ I SVARET',
  unknownCount: unknowns.length,
  unknownTreatedAsEligible: unknowns.some((r) => r.eligibilityStatus === 'eligible'),
  unknownHasQuestions: unknowns.every((r) => r.result.missingFacts.length > 0),
};

// ── P3A: perfekt ansökan → READY ──
const caseA = await call('POST', '/v1/applications', { projectId: pid, opportunityId: travel.opportunityId });
const caseAId = caseA.json.application.id;
const schemaRes = await call('GET', `/v1/applications/${caseAId}`);
const fields = schemaRes.json.schema?.fields ?? [];
const answers = {};
for (const f of fields) {
  if (!f.required) continue;
  answers[f.key] = f.type === 'number' || f.type === 'currency' ? 15000
    : f.type === 'percentage' ? 50 : f.type === 'boolean' || f.type === 'declaration' ? true
    : f.type === 'date' ? '2026-10-01' : f.type === 'date_range' ? ['2026-10-01', '2026-10-14']
    : f.type === 'select' ? (f.options?.[0]?.value ?? 'a') : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a']
    : 'Residens hos Kingston Dance Collective med två gemensamma föreställningar.';
}
await call('PATCH', `/v1/applications/${caseAId}`, { answers });
await call('POST', `/v1/applications/${caseAId}/budget-lines`, { category: 'travel', description: 'Flyg t/r', quantity: 1, unitCostMinor: 1200000 });
await call('POST', `/v1/applications/${caseAId}/budget-lines`, { category: 'accommodation', description: 'Boende 14 nätter', quantity: 14, unitCostMinor: 80000 });
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 820000, otherFundingMinor: 0, inKindMinor: 0 } });
let rev = await call('GET', `/v1/applications/${caseAId}/review`);
const missingEvidence = rev.json.review.evidence.filter((e) => e.status === 'MISSING');
// bifoga obligatorisk bevisning
for (const e of missingEvidence) {
  const boundary = '----audit1234';
  const pdf = `--${boundary}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${e.kind}\r\n--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${e.kind}.pdf"\r\nContent-Type: application/pdf\r\n\r\n%PDF-1.4\n%%EOF\n\r\n--${boundary}--\r\n`;
  const up = await fetch(`${API}/v1/documents`, { method: 'POST', headers: { cookie, 'content-type': `multipart/form-data; boundary=${boundary}` }, body: pdf });
  const doc = (await up.json()).document;
  await call('POST', `/v1/applications/${caseAId}/documents`, { documentId: doc.id, role: 'evidence' });
}
rev = await call('GET', `/v1/applications/${caseAId}/review`);
out.P3A = { status: rev.json.review.overallStatus, gaps: rev.json.review.gaps.length };

// ── P4: claimkonflikt 500/450/600 i olika fält → upptäcks det? ──
await call('PATCH', `/v1/applications/${caseAId}`, { answers: {
  projekt_sammanfattning: 'Utbytet når 500 deltagare genom öppna klasser.',
  projekt_syfte: 'Planen omfattar 450 deltagare under residenset.',
  projekt_kunskap: 'Budgeten är dimensionerad för 600 deltagare.',
} });
rev = await call('GET', `/v1/applications/${caseAId}/review`);
out.P4 = {
  conflictDetected: rev.json.review.gaps.some((g) => g.area === 'consistency' || /motsäg|konflikt|contradiction/i.test(g.message)),
  status: rev.json.review.overallStatus,
};

// ── P5: teckengräns — 5000 tecken i fält med maxLength 4000 ──
await call('PATCH', `/v1/applications/${caseAId}`, { answers: { projekt_sammanfattning: 'x'.repeat(5000) } });
rev = await call('GET', `/v1/applications/${caseAId}/review`);
out.P5 = {
  overLimitFlagged: rev.json.review.gaps.some((g) => /tecken|läng|4000|max/i.test(g.message)),
  flagMessage: rev.json.review.gaps.find((g) => /tecken|läng|4000|max/i.test(g.message))?.message ?? null,
  status: rev.json.review.overallStatus,
};
await call('PATCH', `/v1/applications/${caseAId}`, { answers: { projekt_sammanfattning: 'Residens hos Kingston Dance Collective.' } });

// ── P3D: budgetmotsägelse — finansiering täcker inte budgeten + fel stödnivå ──
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 2600000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 } });
rev = await call('GET', `/v1/applications/${caseAId}/review`);
out.P3D = {
  status: rev.json.review.overallStatus,
  budgetGaps: rev.json.review.gaps.filter((g) => g.area === 'budget').map((g) => g.message),
};
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 820000, otherFundingMinor: 0, inKindMinor: 0 } });

// ── P3C: hårt behörighetsfel — ansökan på uteslutet stöd ──
const caseC = await call('POST', '/v1/applications', { projectId: pid, opportunityId: erasmus.opportunityId });
if (caseC.status === 201) {
  const revC = await call('GET', `/v1/applications/${caseC.json.application.id}/review`);
  out.P3C = {
    createAllowed: true,
    status: revC.json.review.overallStatus,
    criticalEligibility: revC.json.review.gaps.filter((g) => g.area === 'eligibility' && g.severity === 'CRITICAL').map((g) => ({ m: g.message, factual: g.requiresFactualChange })),
  };
} else {
  out.P3C = { createAllowed: false, status: caseC.status, error: caseC.json };
}

// ── P6: eligibility UNKNOWN — släpper gaten igenom? ──
const unknownOpp = unknowns.find((r) => r.result.missingFacts.length > 0);
if (unknownOpp) {
  const caseU = await call('POST', '/v1/applications', { projectId: pid, opportunityId: unknownOpp.opportunityId });
  const idU = caseU.json.application.id;
  const revU = await call('GET', `/v1/applications/${idU}/review`);
  const missingEv = revU.json.review.evidence.filter((e) => e.status === 'MISSING');
  for (const e of missingEv) {
    const boundary = '----audit5678';
    const pdf = `--${boundary}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${e.kind}\r\n--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${e.kind}.pdf"\r\nContent-Type: application/pdf\r\n\r\n%PDF-1.4\n%%EOF\n\r\n--${boundary}--\r\n`;
    const up = await fetch(`${API}/v1/documents`, { method: 'POST', headers: { cookie, 'content-type': `multipart/form-data; boundary=${boundary}` }, body: pdf });
    const doc = (await up.json()).document;
    await call('POST', `/v1/applications/${idU}/documents`, { documentId: doc.id, role: 'evidence' });
  }
  const revU2 = await call('GET', `/v1/applications/${idU}/review`);
  out.P6 = {
    slug: unknownOpp.slug,
    hasSchema: (await call('GET', `/v1/applications/${idU}`)).json.schema !== null,
    eligibility: revU2.json.review.eligibility.status,
    status: revU2.json.review.overallStatus,
    gapSeverities: [...new Set(revU2.json.review.gaps.map((g) => g.severity))],
  };
}

// ── P7: släpper tillståndsmaskinen READY_TO_SUBMIT trots uteslutning? ──
if (out.P3C?.createAllowed) {
  const idC = caseC.json.application.id;
  await call('POST', `/v1/applications/${idC}/transition`, { to: 'PREPARING' });
  const t1 = await call('POST', `/v1/applications/${idC}/transition`, { to: 'READY_FOR_REVIEW' });
  const t2 = await call('POST', `/v1/applications/${idC}/transition`, { to: 'READY_TO_SUBMIT' });
  out.P7 = { toReview: t1.status, toReadyToSubmit: t2.status, gateBlockedExcluded: t2.status !== 200 };
}

// ── P8: två olika utlysningar — styr regelverket beteendet? ──
const lok = rows.find((r) => r.slug === 'rf-lok-stod');
out.P8 = {
  travelRules: { evidence: travel.result.missingEvidence?.length ?? 0, criteria: travel.result.explanation.length },
  otherOpportunityDifferentCriteria: lok ? lok.result.explanation.length !== travel.result.explanation.length : 'LOK ej i spårfiltrerat svar (org-stöd, person-spår)',
};

console.log(JSON.stringify(out, null, 1));
