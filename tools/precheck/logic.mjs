/**
 * Behörighetskontrollen (CONTENT_ENGINE F0 modul 4/5, produkt-som-SEO §16):
 * ett tunt lager på cores riktiga kriteriemotor. Samma modul körs
 *
 *   - i node av tools/genseo.mjs (bygger frågeset + statisk fallback per
 *     klusterhubb) och av tools/precheckcheck.mjs (vakten i verify), och
 *   - i webbläsaren (bundlad av esbuild till /assets/precheck.js) där
 *     användaren svarar och motorn räknar — inget skickas någonstans.
 *
 * Doktrin: frågorna är seedens EGNA intagsfrågor ordagrant (samma text som
 * produkten ställer) plus produktens födelseårsfråga när ett åldersfaktum
 * behövs (samma härledning som produkten: packages/core/src/facts.ts).
 * Utfallet är cores computeMatch — en bedömning, aldrig ett beslut.
 */
import { ageFromBirthYear, computeMatch, deriveAgeFacts } from '@bidrag/core';

/** = apps/web/src/i18n/locales/sv.ts 'ob.age.title' — produktens fråga, inte en ny. */
export const BIRTH_YEAR_QUESTION = 'Vilket år är du född?';
const AGE_FACTS = new Set(Object.keys(deriveAgeFacts(30)));

/**
 * Faktum som gör ett hårt kriterium utan fråga uppfyllt — klustersidan har
 * redan valt målgruppen ("Bidraget söks av privatpersoner"), så villkoret
 * visas som förutsättning i stället för att frågas.
 */
function satisfying(c) {
  if (c.op === 'eq') return c.expected;
  if (c.op === 'in' && Array.isArray(c.expected)) return c.expected[0];
  if (c.op === 'is_true') return true;
  if (c.op === 'is_false') return false;
  return undefined;
}

/**
 * Bygger verktygets data för ett kluster: frågorna (sorterade efter hur många
 * kriterier de avgör — produktens §7-ordning) och barnstöden med kriterier och
 * förutsättningar. `children` är redan upplösta objekt med slug/title/
 * authority/applicationUrl/sourceUrl/criteria/deadline-fält.
 */
export function buildPrecheck(kluster, children) {
  const byFact = new Map();
  let birthYear = null;
  let order = 0;
  for (const o of children) {
    for (const c of o.criteria ?? []) {
      if (!c.intakeQuestion) continue;
      if (AGE_FACTS.has(c.factPath)) {
        birthYear ??= { id: 'birthYear', type: 'birthYear', text: BIRTH_YEAR_QUESTION, factPaths: [], decides: 0, order: order++ };
        if (!birthYear.factPaths.includes(c.factPath)) birthYear.factPaths.push(c.factPath);
        birthYear.decides += 1;
        continue;
      }
      let q = byFact.get(c.factPath);
      if (!q) {
        q = { id: c.factPath, type: 'yesno', text: c.intakeQuestion, factPaths: [c.factPath], decides: 0, order: order++ };
        byFact.set(c.factPath, q);
      }
      q.decides += 1;
    }
  }
  const questions = [...byFact.values(), ...(birthYear ? [birthYear] : [])].sort((a, b) => b.decides - a.decides || a.order - b.order);
  return {
    path: kluster.path,
    headTerm: kluster.headTerm,
    questions: questions.map(({ order: _o, ...q }) => q),
    children: children.map((o) => ({
      slug: o.slug,
      title: o.title,
      authority: o.authority,
      applicationUrl: o.applicationUrl,
      sourceUrl: o.sourceUrl,
      deadlineModel: o.deadlineModel,
      closesAt: o.closesAt ?? null,
      estimatedEffortDays: o.estimatedEffortDays ?? null,
      preconditions: (o.criteria ?? []).filter((c) => c.kind === 'hard' && !c.intakeQuestion).map((c) => c.description),
      criteria: (o.criteria ?? []).map((c) => ({
        id: c.id, kind: c.kind, factPath: c.factPath, op: c.op, expected: c.expected ?? null,
        weight: c.weight ?? null, description: c.description, intakeQuestion: c.intakeQuestion ?? null,
      })),
    })),
  };
}

/**
 * Kör cores motor per barnstöd på användarens svar.
 * answers: { [questionId]: true | false | number | undefined } — undefined = obesvarat.
 * Returnerar per stöd: status 'ja' | 'nej' | 'utred', skäl (kriterier med utfall)
 * och obesvarade frågor (seedens text).
 */
export function evaluatePrecheck(data, answers, now = new Date()) {
  const facts = { 'applicant.country': 'SE' };
  for (const q of data.questions) {
    const v = answers[q.id];
    if (v === undefined || v === null) continue;
    if (q.type === 'birthYear') {
      const y = Number(v);
      if (Number.isFinite(y) && y > 1900 && y <= now.getFullYear()) Object.assign(facts, deriveAgeFacts(ageFromBirthYear(y, now)));
      continue;
    }
    if (typeof v === 'boolean') facts[q.id] = v;
  }
  const questionByFact = new Map();
  for (const q of data.questions) for (const fp of q.factPaths) questionByFact.set(fp, q);
  return data.children.map((o) => {
    const childFacts = { ...facts };
    for (const c of o.criteria) {
      if (c.kind === 'hard' && !c.intakeQuestion && childFacts[c.factPath] === undefined) {
        const s = satisfying(c);
        if (s !== undefined) childFacts[c.factPath] = s;
      }
    }
    const m = computeMatch({
      criteria: o.criteria.map((c) => ({ ...c, expected: c.expected ?? undefined, weight: c.weight ?? undefined, intakeQuestion: c.intakeQuestion ?? undefined })),
      facts: childFacts,
      evidenceRequirements: [],
      availableEvidenceKinds: [],
      referenceDate: now.toISOString(),
      deadline: o.closesAt ?? undefined,
      deadlineModel: o.deadlineModel,
      estimatedEffortDays: o.estimatedEffortDays ?? undefined,
    });
    const status = m.eligibilityStatus === 'excluded' ? 'nej' : m.eligibilityStatus === 'eligible' ? 'ja' : 'utred';
    const missing = [];
    for (const mf of m.missingFacts) {
      const q = questionByFact.get(mf.factPath);
      const text = q ? q.text : mf.question;
      if (!missing.includes(text)) missing.push(text);
    }
    return {
      slug: o.slug,
      title: o.title,
      authority: o.authority,
      applicationUrl: o.applicationUrl,
      sourceUrl: o.sourceUrl,
      status,
      confidence: m.confidence,
      reasons: m.explanation.filter((e) => e.outcome !== 'unknown' && !(e.kind === 'hard' && e.outcome === 'pass')).map((e) => ({ description: e.description, outcome: e.outcome, kind: e.kind })),
      preconditions: o.preconditions,
      missing,
    };
  });
}
