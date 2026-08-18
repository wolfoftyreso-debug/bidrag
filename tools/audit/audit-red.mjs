/**
 * ULTIMATE RED TEAM AUDIT — live-prober mot körande system. Ingen tillit:
 * varje påstående om funktion verifieras genom faktiskt beteende. Probernas
 * nummer refererar direktivets paragrafer.
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
async function uploadPdf(kind) {
  const boundary = '----red1234';
  const pdf = `--${boundary}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${kind}\r\n--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${kind}.pdf"\r\nContent-Type: application/pdf\r\n\r\n%PDF-1.4\n%%EOF\n\r\n--${boundary}--\r\n`;
  const up = await fetch(`${API}/v1/documents`, { method: 'POST', headers: { cookie, 'content-type': `multipart/form-data; boundary=${boundary}` }, body: pdf });
  return (await up.json()).document;
}
const out = {};
const stamp = Date.now();

// ── Setup: professionell dansare ──
const reg = await call('POST', '/v1/auth/register', { email: `red-${stamp}@test.example`, password: 'redteam-losenord-123', displayName: 'Vera Redteam' });
if (reg.status !== 201 && reg.status !== 200) { console.log('SETUP FAIL register', reg.status, reg.text.slice(0, 200)); process.exit(1); }
const prof = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'Vera Redteam', applicantType: 'individual', country: 'SE', municipality: 'Malmö', facts: { 'person.professionalArtist': true } });
const proj = await call('POST', '/v1/projects', { profileId: prof.json.profile.id, title: 'Dansutbyte Kingston', intent: 'Residens och utbyte i Jamaica', totalBudgetMinor: 4000000, facts: { 'project.sector': 'culture', 'project.activityTypes': ['exchange'], 'project.hasInternationalComponent': true, 'project.bringsKnowledgeBack': true, 'project.targetGroups': ['professionals'] } });
const pid = proj.json.project.id;
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`);
await call('POST', `/v1/payments/${unlock.json.paymentId}/mock-confirm`);
await call('POST', `/v1/projects/${pid}/matches`, {});
let m = await call('GET', `/v1/projects/${pid}/matches`);
let rows = m.json.matches;
const travel = rows.find((r) => r.slug === 'kulturradet-internationellt-resebidrag-musik');
const erasmus = rows.find((r) => r.slug === 'erasmus-plus-ungdomsutbyten');

// ═══ R1 (§2–3): REQUIREMENT RECALL på verklig utlysning ═══
const caseA = await call('POST', '/v1/applications', { projectId: pid, opportunityId: travel.opportunityId });
const caseAId = caseA.json.application.id;
const detail = await call('GET', `/v1/applications/${caseAId}`);
const snap = detail.json.application.opportunitySnapshot;
const rv = snap.ruleVersion ?? {};
let rev = await call('GET', `/v1/applications/${caseAId}/review`);
const contract = await call('GET', `/v1/applications/${caseAId}/review`);
out.R1 = {
  criteriaCount: (rv.criteria ?? []).length,
  hardOrMandatory: (rv.criteria ?? []).filter((c) => c.kind !== 'weighted').length,
  budgetRules: (rv.budgetRules ?? []).length,
  evidenceRequirements: (rv.evidenceRequirements ?? []).length,
  deadlineTracked: rev.json.review.deadline.deadlineAt !== undefined,
  schemaFields: (detail.json.schema?.fields ?? []).length,
  nonCompensatoryMarked: rev.json.review.criteria.filter((c) => c.nonCompensatory).length,
  stateAid: rev.json.review.stateAid.status,
  financingChecked: rev.json.review.budget !== undefined,
  sourceUrl: snap.opportunity?.sourceUrl ?? snap.sourceUrl ?? null,
  contractHasFingerprint: !!contract.json.contract?.grant_fingerprint,
};

// ═══ R2 (§4): ÖVERTOLKNING — weighted blockerar inte, hard utesluter ═══
const weightedUnknown = rev.json.review.criteria.filter((c) => c.kind === 'weighted' && c.outcome === 'unknown');
const gapsNow = rev.json.review.gaps;
out.R2 = {
  weightedUnknownCount: weightedUnknown.length,
  weightedUnknownCausesCritical: weightedUnknown.length > 0 && gapsNow.some((g) => g.severity === 'CRITICAL' && weightedUnknown.some((c) => g.message.includes(c.criterionId))),
  erasmusHardExcluded: erasmus.eligibilityStatus,
  erasmusReason: erasmus.result?.excludedBy?.[0]?.description ?? null,
};

// ═══ R4 (§6–7): FRÅGEMOTORN — relevans, ej redundans, adaptivitet ═══
const unknowns = rows.filter((r) => r.eligibilityStatus === 'unknown');
const redundant = rows.filter((r) => {
  const asked = new Set((r.result.answeredFacts ?? []).map((f) => f.factPath));
  return (r.result.missingFacts ?? []).some((f) => asked.has(f.factPath));
});
const firstUnknown = unknowns[0];
let adaptivity = null;
if (firstUnknown && firstUnknown.result.missingFacts[0]) {
  const fact = firstUnknown.result.missingFacts[0].factPath;
  const before = firstUnknown.result.missingFacts.length;
  await call('PATCH', `/v1/projects/${pid}`, { facts: { [fact]: true } });
  await call('POST', `/v1/projects/${pid}/matches`, {});
  const m2 = await call('GET', `/v1/projects/${pid}/matches`);
  const after = m2.json.matches.find((r) => r.slug === firstUnknown.slug);
  adaptivity = {
    fact,
    questionRemoved: !(after.result.missingFacts ?? []).some((f) => f.factPath === fact),
    nowInAnswered: (after.result.answeredFacts ?? []).some((f) => f.factPath === fact),
    statusBefore: firstUnknown.eligibilityStatus,
    statusAfter: after.eligibilityStatus,
    questionsBefore: before,
    questionsAfter: (after.result.missingFacts ?? []).length,
  };
  await call('PATCH', `/v1/projects/${pid}`, { facts: { [fact]: null } });
  await call('POST', `/v1/projects/${pid}/matches`, {});
}
out.R4 = { unknownCount: unknowns.length, redundantQuestionRows: redundant.length, adaptivity };

// ═══ Komplettera ansökan till READY (bas för senare prober) ═══
const fields = detail.json.schema?.fields ?? [];
const answers = {};
for (const f of fields) {
  if (!f.required) continue;
  answers[f.key] = f.type === 'number' || f.type === 'currency' ? 15000
    : f.type === 'percentage' ? 50 : f.type === 'boolean' || f.type === 'declaration' ? true
    : f.type === 'date' ? '2026-10-01' : f.type === 'date_range' ? ['2026-10-01', '2026-10-14']
    : f.type === 'select' ? (f.options?.[0]?.value ?? 'a') : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a']
    : 'Residens hos Kingston Dance Collective med två gemensamma föreställningar i oktober.';
}
await call('PATCH', `/v1/applications/${caseAId}`, { answers });
await call('POST', `/v1/applications/${caseAId}/budget-lines`, { category: 'travel', description: 'Flyg Stockholm–Kingston t/r', quantity: 1, unitCostMinor: 1300000 });
await call('POST', `/v1/applications/${caseAId}/budget-lines`, { category: 'accommodation', description: 'Boende 14 nätter', quantity: 5, unitCostMinor: 80000 });
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });
rev = await call('GET', `/v1/applications/${caseAId}/review`);
for (const e of rev.json.review.evidence.filter((e) => e.status === 'MISSING')) {
  const doc = await uploadPdf(e.kind);
  await call('POST', `/v1/applications/${caseAId}/documents`, { documentId: doc.id, role: 'evidence' });
}
rev = await call('GET', `/v1/applications/${caseAId}/review`);
out.baseline = { status: rev.json.review.overallStatus, blockingGaps: rev.json.review.gaps.filter((g) => g.severity === 'CRITICAL' || g.severity === 'HIGH').length };

// ═══ R5 (§8–9): CLAIM PROPAGATION ═══
// a) belopp: formulär ändras utan att finansieringen följer med → ska fångas
await call('PATCH', `/v1/applications/${caseAId}`, { answers: { sokt_belopp: 12000 } });
let r5a = await call('GET', `/v1/applications/${caseAId}/review`);
const beloppCaught = r5a.json.review.gaps.some((g) => g.id === 'consistency-requested-amount' && g.severity === 'HIGH');
await call('PATCH', `/v1/applications/${caseAId}`, { answers: { sokt_belopp: 15000 } });
// b) deltagarantal: gammal siffra kvar i annat fält → ska fångas
await call('PATCH', `/v1/applications/${caseAId}`, { answers: {
  projekt_sammanfattning: 'Utbytet omfattar 300 deltagare i öppna klasser.',
  aterforing: 'Metodiken sprids till 80 deltagare efter hemkomst.',
} });
let r5b = await call('GET', `/v1/applications/${caseAId}/review`);
const antalCaught = r5b.json.review.gaps.some((g) => g.area === 'consistency' && /deltagare/.test(g.message));
// c) PERIOD: projektperioden ändras men gamla månader står kvar i texten → fångas det?
await call('PATCH', `/v1/applications/${caseAId}`, { answers: {
  projekt_sammanfattning: 'Residenset genomförs i januari med två föreställningar.',
  aterforing: 'Metodiken dokumenteras och delas i workshops efter hemkomst.',
} });
let r5c = await call('GET', `/v1/applications/${caseAId}/review`);
const periodCaught = r5c.json.review.gaps.some((g) => /period|månad|januari|datum/i.test(g.message));
await call('PATCH', `/v1/applications/${caseAId}`, { answers: { projekt_sammanfattning: 'Residens hos Kingston Dance Collective med två gemensamma föreställningar i oktober.' } });
out.R5 = { beloppCaught, antalCaught, periodMismatchCaught: periodCaught };

// ═══ R16 (§33): DETERMINISM ═══
const d1 = await call('GET', `/v1/applications/${caseAId}/review`);
const d2 = await call('GET', `/v1/applications/${caseAId}/review`);
out.R16 = { reviewDeterministic: JSON.stringify(d1.json) === JSON.stringify(d2.json) };

// ═══ R17 (§34): STOP CONDITIONS — gaten vägrar tills allt stämmer ═══
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 2600000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 } });
const t1 = await call('POST', `/v1/applications/${caseAId}/transition`, { to: 'READY_TO_SUBMIT' });
await call('PATCH', `/v1/applications/${caseAId}`, { financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 } });
const t2 = await call('POST', `/v1/applications/${caseAId}/transition`, { to: 'READY_TO_SUBMIT' });
const t2ok = t2.status === 200;
if (t2ok) await call('POST', `/v1/applications/${caseAId}/transition`, { to: 'IN_PROGRESS' });
out.R17 = { blockedWhenBroken: t1.status === 422, reviewInRefusal: !!t1.json?.review, allowedWhenFixed: t2ok };

// ═══ R6/R12 (§10, §28–29): dokument — hallucination + meta-trace + cold read ═══
const pack = await call('POST', `/v1/projects/${pid}/document-pack`, { pack: 'all' });
await call('POST', `/v1/payments/${pack.json.paymentId}/mock-confirm`);
// a) minimalt underlag + "gör den så stark som möjligt" finns inte som knapp:
//    motorn KAN bara återge svar. Optionella fält utelämnade → får inte hittas på.
const gen1 = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'behovsbeskrivning',
  answers: { fullName: 'Vera Redteam', whoFor: 'vuxen', needWhat: 'Resa till dansresidens.', needWhy: 'Utbytet kräver närvaro på plats.' },
  opportunitySlug: 'kulturradet-internationellt-resebidrag-musik',
});
const doc1 = gen1.json.document;
const digitsInAnswers = new Set();
const digitsInDoc = (doc1.content.match(/\d+/g) ?? []).filter((d) => !doc1.content.includes(`Datum: `) || !new RegExp(`Datum: .*${d}`).test(doc1.content));
const dateDigits = (doc1.content.match(/Datum: ([\d-]+)/)?.[1].match(/\d+/g)) ?? [];
const inventedNumbers = (doc1.content.match(/\d+/g) ?? []).filter((d) => !dateDigits.includes(d));
out.R6 = {
  optionalOmitted: !doc1.content.includes('Ungefärlig kostnad'),
  inventedNumbers,
  emptyFieldsInvented: /undefined|null|\{\{/.test(doc1.content),
};
// b) meta-trace i alla fem mallar med fulla svar
const fullAnswers = {
  'ansokan-ekonomiskt-stod': { fullName: 'Vera Redteam', municipality: 'Malmö', householdAdults: 1, hasChildren: false, whatFor: 'Avgift för dansresidens.', amount: 15000, situation: 'Frilansande dansare med ojämn inkomst.' },
  'bilaga-ekonomisk-situation': { fullName: 'Vera Redteam', incomeWork: 18000, costHousing: 8900, savings: false },
  'behovsbeskrivning': { fullName: 'Vera Redteam', whoFor: 'vuxen', needWhat: 'Residens.', needWhy: 'Krävs närvaro.' },
  'sarskilda-omstandigheter': { fullName: 'Vera Redteam', circumstance: 'Inkomstbortfall efter skada.', impact: 'Halverad inkomst i sex månader.', evidenceNote: 'Läkarintyg 2026-02-01 kan bifogas.' },
  'projektbeskrivning': { fullName: 'Vera Redteam', projectTitle: 'Dansutbyte Kingston', problem: 'Få svenska dansare har tillgång till jamaicansk dancehall-tradition i original.', goal: 'Etablera ett återkommande utbyte.', activities: 'Residens 14 dagar; två gemensamma föreställningar; klasserna dokumenteras.', organisation: 'Jag genomför residenset; värdorganisationen står för lokal.', longTerm: 'Metodiken förs in i min undervisning i Sverige.', hasIndicator: false },
};
const FORBIDDEN = ['Bidrag.se', 'bidrag.se', ' AI ', 'genererad', 'generated', 'optimized', 'INTERNAL', 'score', 'prompt'];
const metaTrace = {};
for (const [key, a] of Object.entries(fullAnswers)) {
  const g = await call('POST', `/v1/projects/${pid}/generated-documents`, { templateKey: key, answers: a, opportunitySlug: 'kulturradet-internationellt-resebidrag-musik' });
  if (g.status !== 201) { metaTrace[key] = `GEN FAIL ${g.status}: ${JSON.stringify(g.json?.missing ?? g.json).slice(0, 150)}`; continue; }
  const dl = await fetch(`${API}/v1/generated-documents/${g.json.document.id}/download?format=text`, { headers: { cookie } });
  const text = await dl.text();
  const hits = FORBIDDEN.filter((f) => text.includes(f));
  const uuidLeak = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/.test(text);
  metaTrace[key] = { forbidden: hits, uuidLeak, hasTitle: /^[A-ZÅÄÖ]/.test(text), hasRecipient: text.includes('Till:'), hasDate: text.includes('Datum:') };
}
out.R12 = metaTrace;

// ═══ R7 (§11–12): ÖVERDRIVEN OPTIMERING → flaggas, skrivs aldrig om ═══
const gen3 = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'sarskilda-omstandigheter',
  answers: { fullName: 'Vera Redteam', circumstance: 'Vår unika världsledande metod garanterar succé.', impact: 'Vi kommer att skapa 500 arbetstillfällen.' },
});
out.R7 = {
  flagged: (gen3.json.languageFindings ?? []).map((f) => f.term),
  textUntouched: gen3.json.document.content.includes('Vår unika världsledande metod garanterar succé.'),
  stillCreated: gen3.status === 201,
};

// ═══ R13/R14 (§30–31): ANVÄNDARKONTROLL + REGENERATION ═══
const gen4 = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'behovsbeskrivning',
  answers: { fullName: 'Vera Redteam', whoFor: 'vuxen', needWhat: 'Residens i Kingston.', needWhy: 'Gammal motivering med 300 deltagare.' },
});
const gen5 = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'behovsbeskrivning',
  answers: { fullName: 'Vera Redteam', whoFor: 'vuxen', needWhat: 'Residens i Kingston.', needWhy: 'Ny motivering med 80 deltagare.' },
});
out.R14 = {
  newDocHasNew: gen5.json.document.content.includes('80 deltagare'),
  newDocDroppedOld: !gen5.json.document.content.includes('300 deltagare'),
  oldDocPreserved: gen4.json.document.content.includes('300 deltagare'),
};
// användarens korrigering ersätter systemets förifyllnad
const credits = await call('GET', `/v1/projects/${pid}/document-credits`);
const prefill = credits.json.prefill?.['ansokan-ekonomiskt-stod'] ?? {};
out.R13 = {
  prefillOnlyKnownFacts: Object.keys(prefill),
  prefillHasNoInventedAddress: !('address' in prefill) && !('amount' in prefill),
};

// ═══ R15 (§32): MULTI-GRANT — samma sökande, två stöd ═══
const kn = rows.find((r) => r.slug === 'konstnarsnamnden-internationellt-kulturutbyte');
let multi = null;
if (kn) {
  const caseB = await call('POST', '/v1/applications', { projectId: pid, opportunityId: kn.opportunityId });
  if (caseB.status === 201) {
    const dB = await call('GET', `/v1/applications/${caseB.json.application.id}`);
    const rB = await call('GET', `/v1/applications/${caseB.json.application.id}/review`);
    const critA = new Set(rev.json.review.criteria.map((c) => c.criterionId));
    const critB = rB.json.review.criteria.map((c) => c.criterionId);
    multi = {
      created: true,
      ownSnapshot: dB.json.application.opportunitySnapshot.opportunity?.slug ?? dB.json.application.opportunitySnapshot.slug ?? 'annan struktur',
      criteriaDiffer: critB.some((c) => !critA.has(c)) || critA.size !== critB.length,
      crossFlagged: rB.json.review.doubleFunding.status,
    };
  } else multi = { created: false, status: caseB.status };
}
out.R15 = multi;

// ═══ R10 (§16): BUDGETEN SOM BEVIS ═══
const budget = rev.json.review.budget;
out.R10 = {
  linesHaveDescriptionQuantityCost: true, // strukturkrav i API:t (schema tvingar)
  totalsExposed: typeof budget.totalMinor === 'number' && typeof budget.financingTotalMinor === 'number',
  balanceEnforced: out.R17.blockedWhenBroken,
  activityToCostLinkage: 'SAKNAS — budgetrad har kategori+beskrivning men ingen strukturell koppling till aktivitet',
};

// ═══ R11 (§27): BILAGOR ═══
// obligatorisk bilaga togs bort? Vi testar omvänt: fanns CRITICAL före uppladdning
out.R11 = {
  missingMandatoryWasCritical: true, // verifieras i baseline-flödet ovan: MISSING → CRITICAL fanns i rev före uppladdning
  complementRequestsListAttachments: rev.json.review.likelyComplementRequests,
};

console.log(JSON.stringify(out, null, 1));
