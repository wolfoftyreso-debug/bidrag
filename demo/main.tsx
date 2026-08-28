/**
 * Bidragskoll.se — interaktivt demo. Kör den RIKTIGA matchningsmotorn
 * (@bidrag/core computeMatch) mot den riktiga kunskapsbasen (alla kurerade
 * stöd) helt i webbläsaren. Samma intag som produkten: en fråga per skärm.
 */
import React, { useEffect, useMemo, useRef, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { DOCUMENT_TEMPLATES, PERSONAL_INSTRUMENTS, businessRelevantSlugs, computeMatch,
  prefillAnswers, prefillFromCanonical, renderDocument, validateAnswers, validateDocumentAnswers,
  visibleFields, visibleQuestions,
  type AnswerValue, type Answers, type ApplicationFieldDef, type ApplicationSchemaDef,
  type DocAnswers, type DocQuestion, type DocumentTemplate } from '@bidrag/core';
import OPPORTUNITIES from './demo-opportunities.json';

type Facts = Record<string, unknown>;

interface Opp {
  applicationSchema?: ApplicationSchemaDef | null;
  evidenceRequirements?: { id: string; kind: string; description: string; mandatory: boolean }[];
  slug: string;
  title: string;
  authority: string;
  summary: string;
  instrumentType: string;
  applicantTypes: string[];
  maxAmountMinor: number | null;
  deadlineModel: string;
  closesAt: string | null;
  applicationUrl: string;
  applicationMethod: string;
  sourceUrl: string;
  estimatedEffortDays: number;
  criteria: never[];
  evidenceRequirements: never[];
}

const OPPS = OPPORTUNITIES as unknown as Opp[];
// Härledda räkningar — visas i UI:t i stället för hårdkodade siffror.
const OPP_COUNT = OPPS.length;
const AUTHORITY_COUNT = new Set(OPPS.map((o) => o.authority).filter(Boolean)).size;
// Relevanspolicyn (F-RELEVANS) delas med API:t via @bidrag/core — demon
// bundlar samma modul, så spårfiltren kan aldrig glida isär.
const PERSONAL = PERSONAL_INSTRUMENTS;
const INSTRUMENT: Record<string, string> = {
  public_grant: 'Statligt bidrag', eu_grant: 'EU-bidrag', scholarship: 'Stipendium', stipend: 'Stipendium',
  travel_grant: 'Resebidrag', project_grant: 'Projektbidrag', social_benefit: 'Ersättning', educational_support: 'Studiestöd', loan: 'Lån',
};

const fmtKr = (minor: number | null) => (minor == null ? null : `${(minor / 100).toLocaleString('sv-SE')} kr`);
const fmtDate = (iso: string | null) => (iso ? new Date(iso).toLocaleDateString('sv-SE', { day: 'numeric', month: 'short', year: 'numeric' }) : null);

// ── Intag: en fråga per skärm, adaptiv ──────────────────────────────────────

type StepId =
  | 'entry'
  | 'p-household' | 'p-children' | 'p-separated'
  | 'p-child-school' | 'p-child-costs' | 'p-child-leisure' | 'p-child-glasses' | 'p-child-travel'
  | 'p-age' | 'p-employment' | 'p-biz-form' | 'p-biz-sector' | 'p-capacity'
  | 'p-income' | 'p-savings' | 'p-housing' | 'p-housing-cost' | 'p-moving-abroad' | 'p-disability' | 'done'
  | 'pr-who' | 'pr-artist' | 'pr-sector'
  | 'pr-org-democratic' | 'pr-org-sports' | 'pr-org-youthshare' | 'pr-org-spread'
  | 'pr-activities' | 'pr-international' | 'pr-knowledge' | 'pr-youth';

interface A {
  track?: 'personal' | 'project';
  [k: string]: unknown;
}

function nextStep(s: StepId, a: A): StepId {
  switch (s) {
    case 'entry': return a.track === 'personal' ? 'p-household' : 'pr-who';
    case 'p-household': return 'p-children';
    case 'p-children': return a.children !== 'no' ? 'p-separated' : 'p-age';
    case 'p-separated': return 'p-child-school';
    case 'p-child-school': return 'p-child-costs';
    case 'p-child-costs': return a.childCostsStrain ? 'p-child-glasses' : 'p-child-leisure';
    case 'p-child-leisure': return 'p-child-glasses';
    case 'p-child-glasses': return a.childSchool !== 'none' ? 'p-child-travel' : 'p-age';
    case 'p-child-travel': return 'p-age';
    case 'p-age': return 'p-employment';
    case 'p-employment': return a.employment === 'sick' ? 'p-capacity' : a.employment === 'self_employed' ? 'p-biz-form' : 'p-income';
    case 'p-biz-form': return 'p-biz-sector';
    case 'p-biz-sector': return 'p-income';
    case 'p-capacity': return 'p-income';
    case 'p-income': return a.income === 'under15' ? 'p-savings' : 'p-housing';
    case 'p-savings': return 'p-housing';
    case 'p-housing': return a.paysHousing ? 'p-housing-cost' : 'p-moving-abroad';
    case 'p-housing-cost': return 'p-moving-abroad';
    case 'p-moving-abroad': return 'p-disability';
    case 'p-disability': return 'done';
    case 'pr-who': return a.who === 'individual' || a.who === 'informal_group' ? 'pr-artist' : 'pr-sector';
    case 'pr-artist': return 'pr-sector';
    case 'pr-sector': return a.who === 'association' ? 'pr-org-democratic' : 'pr-activities';
    case 'pr-org-democratic':
      if (a.sector === 'sports') return 'pr-org-sports';
      if (a.sector === 'youth' || a.sector === 'civil_society') return 'pr-org-youthshare';
      return 'pr-activities';
    case 'pr-org-sports': return 'pr-activities';
    case 'pr-org-youthshare': return 'pr-org-spread';
    case 'pr-org-spread': return 'pr-activities';
    case 'pr-activities': return 'pr-international';
    case 'pr-international': return a.international ? 'pr-knowledge' : 'pr-youth';
    case 'pr-knowledge': return 'pr-youth';
    case 'pr-youth': return 'done';
    default: return 'done';
  }
}

function buildFacts(a: A): Facts {
  const f: Facts = { 'applicant.country': 'SE' };
  if (a.track === 'personal') {
    f['applicant.type'] = 'individual';
    // F-RELEVANS: personspåret ÄR ett svar på sektorsfrågan — personen har
    // valt personligt stöd, inte projekt/företag. Utan detta faktum hamnade
    // sektorsgrindade stöd (jordbruk, kulturprojekt m.fl.) i "behöver
    // utredas" för alla. Undantag: egenföretagare — deras verksamhetssektor
    // är genuint okänd tills de svarat (F-EGEN-löftet om företagsgenomlysning
    // står kvar). Vaktas av tools/audit-relevans.mjs.
    if (a.employment !== 'self_employed') f['project.sector'] = 'personal';
    if (a.household) f['person.householdType'] = a.household;
    if (a.children) f['person.hasChildrenAtHome'] = a.children !== 'no';
    if (a.separated !== undefined) f['person.separatedParent'] = a.separated;
    if (a.birthYear) {
      const age = new Date().getFullYear() - (a.birthYear as number);
      f['person.ageYears'] = age;
      f['person.ageUnder29'] = age <= 28;
      f['person.age24Plus'] = age >= 24;
      f['person.age40OrYounger'] = age <= 40;
      f['person.age60Plus'] = age >= 60;
      f['person.age62Plus'] = age >= 62;
      f['person.age66Plus'] = age >= 66;
      f['person.age67Plus'] = age >= 67;
      f['person.ageBand'] = age < 20 ? 'under20' : age <= 28 ? '20-28' : age <= 65 ? '29-65' : '66plus';
    }
    if (a.childSchool) {
      f['person.childInCompulsorySchool'] = a.childSchool === 'grundskola' || a.childSchool === 'both';
      f['person.childInUpperSecondary'] = a.childSchool === 'gymnasiet' || a.childSchool === 'both';
    }
    if (a.childCostsStrain !== undefined || a.childMissedLeisure !== undefined) {
      f['person.childCostsStrain'] = Boolean(a.childCostsStrain || a.childMissedLeisure);
    }
    if (a.childNeedsGlasses !== undefined) f['person.childNeedsGlasses'] = a.childNeedsGlasses;
    if (a.childTravelHard !== undefined) {
      if (a.childSchool === 'grundskola' || a.childSchool === 'both') f['person.childSchoolDistanceQualifies'] = a.childTravelHard;
      if (!a.childTravelHard) { f['person.childSchoolDistanceQualifies'] = false; f['person.childGymnasiumLongTravel'] = false; }
    }
    if (a.employment) {
      f['person.employmentStatus'] = a.employment;
      if (a.employment === 'studying') f['person.isOrPlansStudying'] = true;
      f['person.receivesPension'] = a.employment === 'retired';
      // Den som just svarat "arbetar/studerar/pensionär" ska inte få frågan
      // "är du inskriven som arbetssökande?" — svaret är redan givet.
      f['person.registeredUnemployed'] = a.employment === 'unemployed';
      f['person.selfEmployed'] = a.employment === 'self_employed';
    }
    if (a.businessForm) f['person.businessForm'] = a.businessForm;
    // Egenföretagarens verksamhetssektor (F-RELEVANS): jordbruksstöden ska
    // antingen gälla på riktigt eller uteslutas ärligt — aldrig ligga kvar
    // som "behöver utredas"-brus.
    if (a.bizSector) f['project.sector'] = a.bizSector;
    // Art. 9 (red team RT03-S3): arbetsförmågefrågan är en hälsouppgift — samma
    // avböjandemönster som funktionsnedsättningsfrågan.
    if (a.capacityDeclined) f['person.sensitiveQuestionDeclined'] = true;
    else if (a.capacity !== undefined) f['person.reducedWorkCapacityLongTerm'] = a.capacity;
    f['person.consideringMovingAbroad'] = a.movingAbroad === true;
    // Funktionsnedsättningsspåret: samma gate-mönster som utvandringsspåret.
    // Art. 9: ett avböjt svar är INTE ett nej — faktumet lämnas osatt så att
    // stöden bakom gaten redovisas som "behöver utredas", och markören ser
    // till att hälsofrågan aldrig ställs igen.
    if (a.disabilityDeclined) {
      f['person.sensitiveQuestionDeclined'] = true;
    } else {
      f['person.disabilityOrLongTermIllnessInFamily'] = a.disabilityInFamily === true;
    }
    if (a.income) {
      f['person.lowHouseholdIncome'] = a.income === 'under15' || a.income === '15-25';
      if (a.income === 'under15') f['person.incomeInsufficientForBasicNeeds'] = true;
      // Över 40 000 kr/mån: försörjningsstödsfrågan ställs inte i onödan.
      if (a.income === 'over40') f['person.incomeInsufficientForBasicNeeds'] = false;
    }
    if (a.savings !== undefined) f['person.limitedSavings'] = a.savings;
    if (a.paysHousing !== undefined) f['person.paysHousingCost'] = a.paysHousing;
    if (typeof a.housingCost === 'number') f['person.housingCostMonthly'] = a.housingCost;
  } else {
    f['applicant.type'] = a.who ?? 'individual';
    if (a.artist !== undefined) f['person.professionalArtist'] = a.artist;
    if (a.sector) f['project.sector'] = a.sector;
    if (a.activities) f['project.activityTypes'] = a.activities;
    f['project.targetGroups'] = [...((a.youth ? ['youth'] : []) as string[]), 'professionals'];
    if (a.international !== undefined) f['project.hasInternationalComponent'] = a.international;
    if (a.knowledge !== undefined) f['project.bringsKnowledgeBack'] = a.knowledge;
    if (a.orgDemocratic !== undefined) f['organisation.democraticStructure'] = a.orgDemocratic;
    if (a.orgSportsFederation !== undefined) f['organisation.memberOfSportsFederation'] = a.orgSportsFederation;
    if (a.orgYouthShare !== undefined) f['organisation.youthMembersShareOver60'] = a.orgYouthShare;
    if (a.orgNationalSpread !== undefined) f['organisation.hasNationalSpread'] = a.orgNationalSpread;
  }
  return f;
}

// ── Matchning: den riktiga motorn ───────────────────────────────────────────

function runEngine(facts: Facts) {
  const now = new Date().toISOString();
  return OPPS.map((o) => ({
    opp: o,
    m: computeMatch({
      criteria: o.criteria,
      facts: facts as never,
      evidenceRequirements: o.evidenceRequirements,
      availableEvidenceKinds: [],
      referenceDate: now,
      deadline: o.closesAt,
      estimatedEffortDays: o.estimatedEffortDays,
    }),
  })).sort((x, y) => y.m.score - x.m.score);
}

// ── UI ──────────────────────────────────────────────────────────────────────

function Choice({ label, sub, onClick }: { label: string; sub?: string; onClick: () => void }) {
  return (
    <button className="choice" onClick={onClick}>
      <span className="choice-label">{label}</span>
      {sub && <span className="choice-sub">{sub}</span>}
    </button>
  );
}

function YesNo({ on }: { on: (v: boolean) => void }) {
  return (
    <div className="row">
      <button className="btn primary grow" onClick={() => on(true)}>Ja</button>
      <button className="btn grow" onClick={() => on(false)}>Nej</button>
    </div>
  );
}

function Q({ title, guidance, children }: { title: string; guidance?: string; children: React.ReactNode }) {
  return (
    <div className="card">
      <h1>{title}</h1>
      {guidance && <p className="guidance">{guidance}</p>}
      <div style={{ marginTop: '1rem' }}>{children}</div>
    </div>
  );
}

/**
 * F-LÄNK (användarfynd 2026-08-28: "kommer inte vidare när jag klickar"):
 * demon visas ofta i en sandlådad iframe (artefaktvyn) där webbläsaren tyst
 * vägrar öppna externa länkar — "Blocked opening '…' because the request was
 * made in a sandboxed frame whose 'allow-popups' permission is not set".
 * Överlämningen till myndigheten är produktens viktigaste steg och får aldrig
 * bli en död knapp (§42, inga återvändsgränder). Vi försöker öppna länken; går
 * det inte säger vi varför och visar adressen kopierbar i stället.
 *
 * Detta är ENDA stället i demon som renderar en utgående länk — nya länkar ska
 * gå genom UtLank, annars kan den döda knappen återuppstå.
 */
function UtLank({ href, className, children }: { href: string; className?: string; children: React.ReactNode }) {
  const [blocked, setBlocked] = useState(false);
  const [copied, setCopied] = useState(false);
  const faltet = useRef<HTMLInputElement | null>(null);

  const oppna = (e: React.MouseEvent) => {
    e.preventDefault();
    let fonster: Window | null = null;
    try { fonster = window.open(href, '_blank', 'noopener,noreferrer'); } catch { fonster = null; }
    if (!fonster) setBlocked(true);
  };

  const kopiera = async () => {
    try { await navigator.clipboard.writeText(href); setCopied(true); return; } catch { /* sandlådan kan neka */ }
    const el = faltet.current;
    if (!el) return;
    el.select();
    // execCommand är utfasat men enda vägen när Clipboard API är blockerat.
    // Misslyckas även det står adressen markerad och kan kopieras för hand.
    try { if (document.execCommand('copy')) setCopied(true); } catch { /* markeringen räcker */ }
  };

  return (
    <>
      <a className={className} href={href} target="_blank" rel="noreferrer" onClick={oppna}>{children}</a>
      {blocked && (
        // span, inte div: UtLank används också mitt i löpande text, och en div
        // inuti ett <p> stänger stycket i förtid. Blockformen kommer ur CSS.
        <span className="utlank-block" role="status">
          <span className="utlank-text">Den här vyn får inte öppna externa länkar — demon visas i en sandlåda. Adressen står här:</span>
          <span className="utlank-rad">
            <input ref={faltet} readOnly value={href} onFocus={(e) => e.currentTarget.select()} />
            <button className="btn small" onClick={kopiera}>{copied ? 'Kopierad ✓' : 'Kopiera'}</button>
          </span>
        </span>
      )}
    </>
  );
}

/* Illustrationer (designsystemet Signal, design/illustrationer/): geometriska
   figurer, max 3 färger ur paletten, kontur i --primary-deep, varm markrad.
   Inlinas här eftersom demon är en enda fil. aria-hidden — rubriken bär betydelsen. */
const ILL: Record<string, React.ReactNode> = {
  glodlampa: (
    <svg viewBox="0 0 96 96" aria-hidden="true">
      <rect x="16" y="76" width="64" height="3" rx="1.5" fill="#d5cfc0" /> <circle cx="48" cy="40" r="17" fill="#f5edd8" stroke="#8a6510" strokeWidth="2.5" /> <rect x="42" y="57" width="12" height="10" rx="2" fill="#0a3f78" /> <rect x="46.5" y="10" width="3" height="9" rx="1.5" fill="#8a6510" /> <rect x="70" y="20" width="9" height="3" rx="1.5" fill="#8a6510" transform="rotate(45 74 21)" /> <rect x="17" y="20" width="9" height="3" rx="1.5" fill="#8a6510" transform="rotate(-45 22 21)" />
    </svg>
  ),
  hus: (
    <svg viewBox="0 0 96 96" aria-hidden="true">
      <rect x="16" y="76" width="64" height="3" rx="1.5" fill="#d5cfc0" /> <rect x="26" y="44" width="44" height="33" rx="2" fill="#fffdf9" stroke="#0a3f78" strokeWidth="2.5" /> <polygon points="20,46 48,24 76,46" fill="#1273d4" /> <rect x="42" y="58" width="12" height="19" rx="1" fill="#0a3f78" /> <rect x="31" y="51" width="8" height="8" rx="1" fill="#e8f2fd" stroke="#0a3f78" strokeWidth="1.5" /> <rect x="58" y="51" width="8" height="8" rx="1" fill="#e8f2fd" stroke="#0a3f78" strokeWidth="1.5" />
    </svg>
  ),
  familj: (
    <svg viewBox="0 0 96 96" aria-hidden="true">
      <rect x="16" y="76" width="64" height="3" rx="1.5" fill="#d5cfc0" /> <circle cx="32" cy="30" r="9" fill="#1273d4" /> <rect x="22" y="42" width="20" height="34" rx="10" fill="#e8f2fd" stroke="#0a3f78" strokeWidth="2.5" /> <circle cx="62" cy="32" r="8" fill="#0a3f78" /> <rect x="53" y="43" width="18" height="33" rx="9" fill="#fffdf9" stroke="#0a3f78" strokeWidth="2.5" /> <circle cx="47" cy="56" r="6" fill="#6fb2f0" /> <rect x="41" y="63" width="12" height="13" rx="6" fill="#e8f2fd" stroke="#0a3f78" strokeWidth="2" />
    </svg>
  ),
};

/* Framhävd nyckelfråga (Signal): för frågorna som väger tyngst — max en per
   flödessteg, figuren speglar frågans ämne. */
function QFramhavd({ title, guidance, ill, children }: { title: string; guidance?: string; ill: keyof typeof ILL; children: React.ReactNode }) {
  return (
    <div className="fraga-framhavd">
      <span className="scen">{ILL[ill]}</span>
      <h1>{title}</h1>
      {guidance && <p className="guidance">{guidance}</p>}
      <div className="val">{children}</div>
    </div>
  );
}

function Likelihood({ m }: { m: ReturnType<typeof runEngine>[number]['m'] }) {
  const level = likelihoodOf(m);
  if (level === 'high') return <span className="badge success">hög sannolikhet</span>;
  if (level === 'possible') return <span className="badge success">möjlig</span>;
  return <span className="badge warning">behöver utredas</span>;
}

function MatchRow({ opp, m, facts, showScore, selected, onToggle }: { opp: Opp; m: ReturnType<typeof runEngine>[number]['m']; facts: Facts; showScore: boolean; selected?: boolean; onToggle?: () => void }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="match">
      {showScore && (
        <div className="score"><div className="n">{m.score}</div><div className="of">av 100</div></div>
      )}
      <div className="grow">
        <div>
          <button className="linkish" onClick={() => setOpen(!open)}>{opp.title}</button>{' '}
          <Likelihood m={m} />
        </div>
        <div className="meta">
          {opp.authority} · <span className="badge info">{INSTRUMENT[opp.instrumentType] ?? opp.instrumentType}</span>
          {fmtKr(opp.maxAmountMinor) && <> · upp till {fmtKr(opp.maxAmountMinor)}</>}
          {' · '}
          {opp.closesAt ? `stänger ${fmtDate(opp.closesAt)}` : opp.deadlineModel === 'rolling' ? 'löpande ansökan' : 'kommande omgång'}
        </div>
        {m.missingFacts.length > 0 && (
          <div className="meta warn">För att veta säkert: {m.missingFacts.slice(0, 2).map((f) => f.question).join(' · ')}</div>
        )}
        {/* F-VIDARE (användarfynd): vägen vidare ska vara en knapp på raden —
            markera de stöd du vill söka och gå vidare med "Nästa". */}
        {onToggle && (
          <div className="row" style={{ marginTop: '0.35rem' }}>
            <button className={`btn small${selected ? ' primary' : ''}`} onClick={onToggle}>
              {selected ? '✓ Vald — ingår i din plan' : 'Vill ansöka'}
            </button>
          </div>
        )}
        {open && (
          <div className="explain">
            <p className="meta">{opp.summary}</p>
            {m.explanation.map((e) => (
              <div key={e.criterionId} className="exp-item">
                <span className={`exp-ic ${e.outcome}`}>{e.outcome === 'pass' ? '✓' : e.outcome === 'fail' ? '✗' : '?'}</span>
                <span>{e.description}</span>
              </div>
            ))}
            <div className="srcline">
              Källa: <UtLank href={opp.sourceUrl}>{opp.sourceUrl}</UtLank> · AI-sammanställd — ej människogranskad,
              2026-08-13 — kontrollera alltid aktuella villkor hos källan. {opp.applicationMethod}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ── Open Discovery: upptäckt och resultat är gratis och inte låsta ──────────
// Samma modell som produkten: matchningarna visas direkt och kostnadsfritt.
// Det enda som kostar är att förbereda en ansökan (19 kr/ansökan).

function likelihoodOf(m: ReturnType<typeof runEngine>[number]['m']): 'high' | 'possible' | 'needs_info' {
  if (m.eligibilityStatus !== 'eligible') return 'needs_info';
  // "Hög" kräver att även viktande kriterier talar för (F3-kalibreringen).
  const weightedAgainst = m.explanation.some((e) => e.kind === 'weighted' && e.outcome === 'fail');
  if (m.confidence === 'high' && !weightedAgainst) return 'high';
  return 'possible';
}

function Results({ facts, track, onFact, onRestart, chosen, onToggle, onNext }: { facts: Facts; track: 'personal' | 'project'; onFact: (k: string, v: boolean) => void; onRestart: () => void; chosen: Set<string>; onToggle: (slug: string) => void; onNext: () => void }) {
  const results = useMemo(() => runEngine(facts), [facts]);
  // F1: samma spårrelevans som teasern — utanför spåret bara det som bedömts aktuellt.
  const inScope = track === 'project'
    ? results.filter((r) => !PERSONAL.has(r.opp.instrumentType) || r.m.eligibilityStatus === 'eligible')
    : results.filter((r) => PERSONAL.has(r.opp.instrumentType) || r.m.eligibilityStatus === 'eligible' || (facts['person.selfEmployed'] === true && businessRelevantSlugs(facts['project.sector']).has(r.opp.slug)));
  const relevant = inScope.filter((r) => r.m.eligibilityStatus !== 'excluded');
  const excluded = inScope.filter((r) => r.m.eligibilityStatus === 'excluded');
  const personal = relevant.filter((r) => PERSONAL.has(r.opp.instrumentType));
  const isSelfEmployed = facts['person.selfEmployed'] === true;
  const businessForm = facts['person.businessForm'];
  const business = isSelfEmployed ? relevant.filter((r) => businessRelevantSlugs(facts['project.sector']).has(r.opp.slug)) : [];
  const excludedBusiness = isSelfEmployed ? excluded.filter((r) => businessRelevantSlugs(facts['project.sector']).has(r.opp.slug)) : [];
  const fundingAll = relevant.filter((r) => !PERSONAL.has(r.opp.instrumentType) && !(isSelfEmployed && businessRelevantSlugs(facts['project.sector']).has(r.opp.slug)));
  const funding = personal.length > 0 ? fundingAll.filter((r) => r.m.eligibilityStatus === 'eligible') : fundingAll;
  const summarised = fundingAll.length - funding.length;
  // Företagsstöd som inte uppfylls visas inne i företagssektionen — inte dubbelt.
  const excludedShown = isSelfEmployed ? excluded.filter((r) => !businessRelevantSlugs(facts['project.sector']).has(r.opp.slug)) : excluded;

  // Varje följdfråga bär sin kontext: vilket stöd den avgör.
  interface QDetail { title: string; requirement: string; kind: string; sourceUrl: string }
  const questions = new Map<string, { q: string; titles: string[]; unknowns: number; personal: boolean; details: QDetail[] }>();
  for (const r of [...personal, ...business, ...fundingAll]) {
    const short = r.opp.title.split(' — ').pop() ?? r.opp.title;
    for (const f of r.m.missingFacts) {
      if (f.factPath === 'person.disabilityOrLongTermIllnessInFamily' && facts['person.sensitiveQuestionDeclined'] === true) continue;
      // Inforutan (F-INFO): kravtexten är det kurerade kriteriet självt.
      const crit = (r.opp.criteria as { id: string; description?: string; kind?: string }[]).find((c) => c.id === f.criterionId);
      const detail: QDetail = { title: short, requirement: crit?.description ?? f.question, kind: crit?.kind ?? 'mandatory', sourceUrl: r.opp.sourceUrl };
      const e = questions.get(f.factPath);
      if (e) {
        if (!e.titles.includes(short)) e.titles.push(short);
        if (!e.details.some((d) => d.title === short)) e.details.push(detail);
        if (r.m.eligibilityStatus === 'unknown') e.unknowns += 1;
        e.personal ||= PERSONAL.has(r.opp.instrumentType);
      } else {
        questions.set(f.factPath, { q: f.question, titles: [short], unknowns: r.m.eligibilityStatus === 'unknown' ? 1 : 0, personal: PERSONAL.has(r.opp.instrumentType), details: [detail] });
      }
    }
  }
  // Informationsvärde (§7): frågan som kan avgöra flest stöd ställs först.
  const allOpen = [...questions.entries()]
    .filter(([k]) => facts[k] === undefined)
    .sort(([, a], [, b]) => Number(b.personal) - Number(a.personal) || b.unknowns - a.unknowns || b.titles.length - a.titles.length);

  // F-STABIL (användarfynd): frågelistan är ett stabilt papper. En fråga som
  // visats STÅR KVAR på sin plats: besvarad tonas ner med svaret markerat
  // (och kan ändras direkt på raden), inaktuell märks "behövs inte längre".
  // Inget försvinner eller byter plats — nya frågor läggs alltid sist, så
  // många att högst 5 obesvarade visas åt gången.
  const qMeta = useRef(new Map<string, { q: string; titles: string[]; details: QDetail[] }>());
  for (const [k, q] of questions) qMeta.current.set(k, { q: q.q, titles: q.titles, details: q.details });
  // Inforutan "Därför ställs frågan" — öppen för högst en fråga åt gången.
  const [openInfo, setOpenInfo] = useState<string | null>(null);
  const [qOrder, setQOrder] = useState<string[]>(() => allOpen.slice(0, 5).map(([k]) => k));
  useEffect(() => {
    setQOrder((order) => {
      const next = [...order];
      for (const [k] of allOpen) {
        if (next.filter((p) => facts[p] === undefined).length >= 5) break;
        if (!next.includes(k)) next.push(k);
      }
      return next.length === order.length ? order : next;
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [facts]);

  // Dina svar: en besvarad fråga försvinner aldrig — den flyttar hit och kan
  // ändras när som helst; motorn räknar om direkt i webbläsaren.
  const answered = new Map<string, { q: string; value: boolean; titles: string[]; details: QDetail[] }>();
  for (const r of results) {
    const short = r.opp.title.split(' — ').pop() ?? r.opp.title;
    for (const f of r.m.answeredFacts ?? []) {
      if (typeof facts[f.factPath] !== 'boolean') continue;
      const crit = (r.opp.criteria as { id: string; description?: string; kind?: string }[]).find((c) => c.id === f.criterionId);
      const detail: QDetail = { title: short, requirement: crit?.description ?? f.question, kind: crit?.kind ?? 'mandatory', sourceUrl: r.opp.sourceUrl };
      const e = answered.get(f.factPath);
      if (e) {
        if (!e.titles.includes(short)) e.titles.push(short);
        if (!e.details.some((d) => d.title === short)) e.details.push(detail);
      } else answered.set(f.factPath, { q: f.question, value: facts[f.factPath] as boolean, titles: [short], details: [detail] });
    }
  }

  // F-INFO: myndighetstydlig fördjupning — därför ställs frågan, per stöd,
  // med kravtexten (det kurerade kriteriet) och officiell källa.
  const infoRuta = (details: QDetail[]) => (
    <div className="inforuta" role="note">
      <strong>Därför ställs frågan</strong>
      <ul>
        {details.map((d) => (
          <li key={d.title}>
            <strong>{d.title}</strong> {d.kind === 'weighted' ? 'väger in svaret i bedömningen (det är inget krav):' : 'har villkoret:'}{' '}
            <em>{d.requirement}</em> <UtLank href={d.sourceUrl}>(officiell källa)</UtLank>
          </li>
        ))}
      </ul>
      <span className="meta">Svaret används bara för din bedömning och går alltid att ändra. Slutligt beslut fattas alltid av myndigheten.</span>
    </div>
  );
  const infoKnapp = (id: string) => (
    <button type="button" className="info-knapp" aria-expanded={openInfo === id} aria-label="Varför ställs frågan?"
      title="Varför ställs frågan?" onClick={() => setOpenInfo(openInfo === id ? null : id)}>i</button>
  );

  return (
    <div>
      {qOrder.length > 0 && (
        <div className="card accent">
          <h2 style={{ marginBottom: '0.15rem' }}>Några frågor kvar ({allOpen.length})</h2>
          <p className="meta" style={{ margin: '0 0 0.4rem' }}>
            Svaren räknas om direkt · Besvarade frågor står kvar nedtonade och kan ändras — inget försvinner eller byter plats
            {allOpen.some(([k]) => !qOrder.includes(k)) ? ' · Fler frågor läggs till längst ner allteftersom' : ''}
          </p>
          {qOrder.map((path) => {
            const meta = qMeta.current.get(path);
            if (!meta) return null;
            const val = facts[path];
            const isAnswered = typeof val === 'boolean';
            const stillNeeded = questions.has(path);
            const gäller = `Gäller ${meta.titles.slice(0, 2).join(' och ')}${meta.titles.length > 2 ? ` + ${meta.titles.length - 2} till` : ''}`;
            return (
              <div key={path} className={`q-row${isAnswered || !stillNeeded ? ' q-row-dim' : ''}`}>
                <div className="q-context">{gäller}</div>
                <strong>{meta.q}</strong> {infoKnapp(path)}
                {openInfo === path && infoRuta(meta.details)}
                {isAnswered ? (
                  <div className="row" style={{ marginTop: '0.3rem', alignItems: 'center' }}>
                    <button className={`btn small${val === true ? ' primary' : ''}`} onClick={() => val !== true && onFact(path, true)}>Ja</button>
                    <button className={`btn small${val === false ? ' primary' : ''}`} onClick={() => val !== false && onFact(path, false)}>Nej</button>
                    <span className="meta" role="status">✓ Sparat — går att ändra</span>
                  </div>
                ) : stillNeeded ? (
                  <div className="row" style={{ marginTop: '0.3rem' }}>
                    <button className="btn small" onClick={() => onFact(path, true)}>Ja</button>
                    <button className="btn small" onClick={() => onFact(path, false)}>Nej</button>
                  </div>
                ) : (
                  <p className="meta" style={{ margin: '0.25rem 0 0' }}>Behövdes inte längre — dina andra svar avgjorde redan {meta.titles[0]}.</p>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* F-ÄNDRA (användarfynd): besvarade frågor ska synligt gå att ändra —
          sektionen är öppen som standard, inte hopfälld. */}
      {answered.size > 0 && (
        <details className="card" open id="dina-svar">
          <summary style={{ cursor: 'pointer', fontWeight: 600 }}>Dina svar ({answered.size}) — granska eller ändra</summary>
          <p className="guidance" style={{ marginTop: '0.5rem' }}>Ändrar du ett svar räknas hela analysen om direkt.</p>
          {[...answered.entries()].map(([path, q]) => (
            <div key={path} className="q-row">
              <div className="q-context">Gäller {q.titles.slice(0, 2).join(' och ')}{q.titles.length > 2 ? ` + ${q.titles.length - 2} till` : ''}</div>
              <strong>{q.q}</strong> {infoKnapp(`svar:${path}`)}
              {openInfo === `svar:${path}` && infoRuta(q.details)}
              <div className="row" style={{ marginTop: '0.3rem' }}>
                <button className={`btn small${q.value === true ? ' primary' : ''}`} onClick={() => q.value !== true && onFact(path, true)}>Ja</button>
                <button className={`btn small${q.value === false ? ' primary' : ''}`} onClick={() => q.value !== false && onFact(path, false)}>Nej</button>
              </div>
            </div>
          ))}
        </details>
      )}

      {personal.length > 0 && (
        <div className="card">
          <h2>Det här ser du ut att kunna ha rätt till</h2>
          <p className="guidance">En bedömning utifrån dina svar — slutligt beslut fattas alltid av myndigheten. Markera ”Vill ansöka” på de stöd du vill gå vidare med, och tryck sedan Nästa längre ner.</p>
          {personal.map((r) => <MatchRow key={r.opp.slug} opp={r.opp} m={r.m} facts={facts} showScore={false} selected={chosen.has(r.opp.slug)} onToggle={() => onToggle(r.opp.slug)} />)}
        </div>
      )}

      {isSelfEmployed && (business.length > 0 || excludedBusiness.length > 0) && (
        <div className="card">
          <h2>Stöd som rör ditt företagande ({business.length + excludedBusiness.length})</h2>
          {/* F-FÖRETAG (användarfynd): intaget och rapporten ska säga samma sak.
              För aktiebolag: genomlysningen för bolaget görs separat — men
              stöden VISAS här, med skäl, i stället för att gömmas längre ner. */}
          <p className="guidance">
            {businessForm === 'sole_trader'
              ? 'Med enskild firma söker du företagsstöden som person — de ingår i din genomlysning här.'
              : businessForm === 'limited_company'
                ? 'Ett aktiebolags stöd söks av bolaget, inte av dig som person — genomlysningen för bolaget görs därför separat. Här ser du ändå vilka stöd som finns för verksamheten och vad de kräver, så att du vet vad en genomlysning för bolaget skulle omfatta.'
                : 'Vilka företagsstöd som är aktuella beror på driftsformen — enskild firma söker som person, aktiebolagets stöd söks av bolaget och genomlyses separat.'}
          </p>
          {business.map((r) => <MatchRow key={r.opp.slug} opp={r.opp} m={r.m} facts={facts} showScore={false} selected={chosen.has(r.opp.slug)} onToggle={() => onToggle(r.opp.slug)} />)}
          {excludedBusiness.map((r) => (
            <div key={r.opp.slug} className="match dim">
              <div className="grow">
                <ExcludedRow opp={r.opp} m={r.m} />
              </div>
            </div>
          ))}
        </div>
      )}

      {funding.length > 0 && (
        <div className="card">
          <h2>{personal.length > 0 ? 'Bidrag och finansiering' : 'Stöd som kan passa'} ({funding.length})</h2>
          {personal.length > 0 && summarised > 0 && (
            <p className="guidance">Ytterligare {summarised} möjligheter visas inte eftersom uppgifter saknas.</p>
          )}
          {funding.map((r) => <MatchRow key={r.opp.slug} opp={r.opp} m={r.m} facts={facts} showScore={true} selected={chosen.has(r.opp.slug)} onToggle={() => onToggle(r.opp.slug)} />)}
        </div>
      )}
      {personal.length > 0 && funding.length === 0 && summarised > 0 && (
        <p className="meta" style={{ margin: '0 0 1rem 0.3rem' }}>
          Vi har även gått igenom {summarised} bidrag för projekt och verksamheter — inget av dem ser aktuellt ut för din situation just nu.
        </p>
      )}

      <div className="card accent">
        <h2>Gå vidare med ansökan</h2>
        <p className="guidance">
          Markera ”Vill ansöka” på de stöd du vill gå vidare med och tryck Nästa — du får en plan som visar hur varje ansökan görs.
        </p>
        <button className="btn primary" style={{ fontSize: '1.05rem' }} disabled={chosen.size === 0} onClick={onNext}>
          {chosen.size === 0 ? 'Nästa — markera först minst ett stöd' : `Nästa — gå vidare med ${chosen.size} ${chosen.size === 1 ? 'valt stöd' : 'valda stöd'} →`}
        </button>
      </div>

      <div className="card">
        <h2>Uppfyller inte kraven ({excludedShown.length})</h2>
        <p className="guidance">Vi visar varför — kraven kommer från respektive källa. Klicka för detaljer.</p>
        {excludedShown.map((r) => (
          <div key={r.opp.slug} className="match dim">
            <div className="grow">
              <ExcludedRow opp={r.opp} m={r.m} />
            </div>
          </div>
        ))}
      </div>

      <p className="meta" style={{ margin: '0.8rem 0.3rem' }}>
        Detta är en vägledning och inte ett myndighetsbeslut. Slutligt beslut fattas alltid av respektive myndighet.
      </p>

      <div className="row" style={{ margin: '1.2rem 0' }}>
        <button className="btn" onClick={onRestart}>↺ Börja om med ett annat scenario</button>
      </div>
    </div>
  );
}

/**
 * F-FÖRBERED (användarfynd 2026-08-28: "Systemet ska guida mig i att förbereda
 * allt inför ansökan!?"). Planvyn slutade i en länk till myndigheten — det är
 * upptäckt, inte förberedelse, och därmed halva produkten. Här körs cores
 * riktiga dokumentmotor i webbläsaren: samma mallar, samma förifyllnad, samma
 * validering och samma rendering som produkten använder.
 *
 * Ärligheten: demon simulerar arbetslagret utan betalning och utan att skicka
 * något någonstans. Det sägs rakt ut, tillsammans med att det alltid är gratis
 * att ansöka själv hos myndigheten. Dokumentet visas som text med kopieraknapp
 * — sandlådan tillåter inga nedladdningar (samma skäl som UtLank).
 */
/**
 * F-SPECIFIK (användarfynd 2026-08-28: "Allt ska vara specifikt!!").
 * Förberedelsen körde fyra generiska mallar. Kunskapsbasen har 72 kurerade
 * ansökningsscheman — myndighetens EGNA fält, rubriker, gränser och
 * vägledning ("siffran står i hyresavtalet", "en för låg uppskattning kan ge
 * återkrav") — plus kurerade underlagslistor per stöd. Nu används de.
 *
 * Ingenting hittas på: saknar ett stöd kurerat schema faller vi tillbaka på
 * de generiska mallarna och SÄGER att de är generiska. Saknas underlagslista
 * påstår vi inte att inga underlag behövs — vi säger att listan inte är
 * kurerad ännu och hänvisar till källan.
 */
const CANONICAL_FRAN_FAKTA = (facts: Facts): Record<string, AnswerValue> => {
  const c: Record<string, AnswerValue> = {};
  const put = (k: string, v: unknown) => {
    if (typeof v === 'string' || typeof v === 'number' || typeof v === 'boolean') c[k] = v;
  };
  put('person.housingCostMonthly', facts['person.housingCostMonthly']);
  put('person.childrenAtHomeCount', facts['person.childrenAtHomeCount']);
  put('person.ageYears', facts['person.ageYears']);
  put('applicant.municipality', facts['person.municipality']);
  return c;
};

function SchemaFalt({ f, value, onChange }: { f: ApplicationFieldDef; value: AnswerValue | undefined; onChange: (v: AnswerValue | undefined) => void }) {
  const id = `sf-${f.key}`;
  const numeriskt = f.type === 'number' || f.type === 'currency' || f.type === 'percentage';
  const langtext = f.type === 'long_text' || f.type === 'rich_text';
  return (
    <div className="docfalt">
      <label htmlFor={id}>{f.label}{f.required ? ' *' : ''}</label>
      {langtext && (
        <textarea id={id} rows={4} maxLength={f.maxLength} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)} />
      )}
      {(f.type === 'text' || f.type === 'date' || f.type === 'date_range' || f.type === 'email' || f.type === 'phone' || f.type === 'url') && (
        <input id={id} type={f.type === 'date' ? 'date' : f.type === 'email' ? 'email' : 'text'} maxLength={f.maxLength}
          value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)} />
      )}
      {numeriskt && (
        <input id={id} type="number" min={f.min} max={f.max} value={(value as number | undefined) ?? ''}
          onChange={(e) => onChange(e.target.value === '' ? undefined : Number(e.target.value))} />
      )}
      {(f.type === 'boolean' || f.type === 'declaration') && (
        <div className="row">
          <button type="button" className={value === true ? 'btn primary' : 'btn small'} onClick={() => onChange(true)}>Ja</button>
          <button type="button" className={value === false ? 'btn primary' : 'btn small'} onClick={() => onChange(false)}>Nej</button>
        </div>
      )}
      {(f.type === 'select' || f.type === 'multi_select') && (
        <select id={id} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)}>
          <option value="" disabled>Välj…</option>
          {f.options?.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      )}
      {f.guidance && <p className="meta">{f.guidance}</p>}
      {f.maxLength && langtext && (
        <p className="meta">{String((value as string) ?? '').length} / {f.maxLength} tecken</p>
      )}
    </div>
  );
}

/** Dokumentet byggs ur schemats egna sektioner — myndighetens ordning, inte vår. */
function renderaSchemaDokument(schema: ApplicationSchemaDef, answers: Answers, opp: Opp): string {
  const rader: string[] = [
    schema.title.toUpperCase(),
    `Avser: ${opp.title}`,
    `Till: ${opp.authority}`,
    `Datum: ${new Date().toISOString().slice(0, 10)}`,
    '',
  ];
  const synliga = visibleFields(schema, answers);
  for (const sek of schema.sections) {
    const falt = synliga.filter((f) => f.section === sek.key && answers[f.key] !== undefined && answers[f.key] !== '');
    if (falt.length === 0) continue;
    rader.push(sek.title.toUpperCase());
    for (const f of falt) {
      const v = answers[f.key];
      const text = typeof v === 'boolean' ? (v ? 'Ja' : 'Nej')
        : f.type === 'select' ? (f.options?.find((o) => o.value === v)?.label ?? String(v))
        : String(v);
      rader.push(f.type === 'long_text' || f.type === 'rich_text' ? `${f.label}:\n${text}` : `${f.label}: ${text}`);
    }
    rader.push('');
  }
  return rader.join('\n').trimEnd();
}

function docLabel(q: DocQuestion, v: unknown): string {
  if (typeof v === 'boolean') return v ? 'Ja' : 'Nej';
  if (q.type === 'select') return q.options?.find((o) => o.value === v)?.label ?? String(v);
  return String(v);
}

function DocFalt({ q, value, onChange }: { q: DocQuestion; value: unknown; onChange: (v: unknown) => void }) {
  const id = `doc-${q.key}`;
  return (
    <div className="docfalt">
      <label htmlFor={id}>{q.label}{q.required ? ' *' : ''}</label>
      {q.type === 'textarea' && (
        <textarea id={id} rows={3} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)} />
      )}
      {(q.type === 'text' || q.type === 'date') && (
        <input id={id} type={q.type === 'date' ? 'date' : 'text'} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)} />
      )}
      {q.type === 'number' && (
        <input id={id} type="number" value={(value as number | undefined) ?? ''} onChange={(e) => onChange(e.target.value === '' ? undefined : Number(e.target.value))} />
      )}
      {q.type === 'boolean' && (
        <div className="row">
          <button type="button" className={value === true ? 'btn primary' : 'btn small'} onClick={() => onChange(true)}>Ja</button>
          <button type="button" className={value === false ? 'btn primary' : 'btn small'} onClick={() => onChange(false)}>Nej</button>
        </div>
      )}
      {q.type === 'select' && (
        <select id={id} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)}>
          <option value="" disabled>Välj…</option>
          {q.options?.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      )}
      {q.guidance && <p className="meta">{q.guidance}</p>}
    </div>
  );
}

function ForberedVy({ opp, facts, onBack }: { opp: Opp; facts: Facts; onBack: () => void }) {
  const schema = opp.applicationSchema ?? null;

  // ── Stödets EGET schema (F-SPECIFIK) ──────────────────────────────────────
  const canonical = useMemo(() => CANONICAL_FRAN_FAKTA(facts), [facts]);
  const forifyllt = useMemo(
    () => (schema ? prefillFromCanonical(schema, {}, canonical) : { answers: {} as Answers, prefilledKeys: [] as string[] }),
    [schema, canonical],
  );
  const [svar, setSvar] = useState<Answers>(() => forifyllt.answers);
  const [kopierad, setKopierad] = useState(false);

  // ── Reserv: generiska mallar när stödet saknar kurerat schema ─────────────
  const personligt = PERSONAL_INSTRUMENTS.has(opp.instrumentType);
  const mallar = useMemo(
    () => DOCUMENT_TEMPLATES.filter((t) => (t.key === 'projektbeskrivning' ? !personligt : personligt)),
    [personligt],
  );
  const mallPrefill = useMemo(
    () => Object.fromEntries(mallar.map((t) => [t.key, prefillAnswers(t.key, { facts })])),
    [mallar, facts],
  );
  const [mallSvarAlla, setMallSvarAlla] = useState<Record<string, DocAnswers>>(() => ({ ...mallPrefill }));
  const [oppenMall, setOppenMall] = useState<string>(mallar[0]!.key);

  const kopiera = async (text: string) => {
    try { await navigator.clipboard.writeText(text); setKopierad(true); } catch { setKopierad(false); }
  };

  const underlag = opp.evidenceRequirements ?? [];

  const huvud = (
    <>
      <button className="btn subtle" onClick={onBack} style={{ marginBottom: '0.6rem' }}>← Tillbaka till planen</button>
      <div className="card accent">
        <h1>Förbered ansökan — {opp.title}</h1>
        <p className="guidance">
          Systemet fyller i det du redan svarat, frågar bara om det som saknas och skriver dokumentet åt dig.
          Du ser hela texten innan något lämnas in — och kan ändra varje svar.
        </p>
        <p className="meta">
          I produkten kostar det här arbetslagret 19 kr per ansökan och dokumenten levereras som filer efter
          granskning. <strong>I demon är det gratis, ingenting skickas någonstans och ingen betalning sker.</strong>{' '}
          Att fylla i och ansöka själv direkt hos {opp.authority} är alltid gratis.
        </p>
      </div>

      <div className="card">
        <h2>Så ansöker du hos {opp.authority}</h2>
        <p>{opp.applicationMethod}</p>
        <h3>Underlag att ha framme</h3>
        {underlag.length > 0 ? (
          <ul className="underlag">
            {underlag.map((e) => (
              <li key={e.id}>
                {e.description}{' '}
                <span className={e.mandatory ? 'badge warning' : 'badge info'}>{e.mandatory ? 'obligatoriskt' : 'om det finns'}</span>
              </li>
            ))}
          </ul>
        ) : (
          <p className="meta">
            Ingen underlagslista är kurerad för det här stödet ännu, och vi gissar inte. Kontrollera
            vad som ska bifogas hos källan: <UtLank href={opp.sourceUrl}>{opp.sourceUrl}</UtLank>
          </p>
        )}
      </div>
    </>
  );

  if (!schema) {
    // Ärlig reserv: generiska mallar, tydligt märkta som generiska.
    const mall = mallar.find((t) => t.key === oppenMall) ?? mallar[0]!;
    const mallSvar = mallSvarAlla[mall.key] ?? {};
    const fragor = visibleQuestions(mall, mallSvar);
    const dom = validateDocumentAnswers(mall, mallSvar);
    const redan = fragor.filter((q) => (mallPrefill[mall.key] ?? {})[q.key] !== undefined);
    const dokument = dom.ok
      ? renderDocument(mall, mallSvar, {
          recipient: opp.authority,
          opportunityTitle: opp.title,
          date: new Date().toISOString().slice(0, 10),
          applicantName: (mallSvar.fullName as string) || undefined,
        }).text
      : null;
    return (
      <div>
        {huvud}
        <div className="card">
          <h2>Dokument som förbereds</h2>
          <p className="meta warn">
            Det här stödet har ännu inget kurerat ansökningsformulär i kunskapsbasen, så vi använder generella
            mallar. De täcker det de flesta handläggare frågar efter — men följ {opp.authority}s egna anvisningar.
          </p>
          <ul className="doclista">
            {mallar.map((t) => {
              const d = validateDocumentAnswers(t, mallSvarAlla[t.key] ?? {});
              return (
                <li key={t.key}>
                  <button className={t.key === mall.key ? 'btn primary' : 'btn small'} onClick={() => { setOppenMall(t.key); setKopierad(false); }}>{t.title}</button>
                  <span className={d.ok ? 'badge success' : 'badge warning'}>{d.ok ? 'klart' : `${d.missing.length} svar kvar`}</span>
                </li>
              );
            })}
          </ul>
        </div>
        <div className="card">
          <h2>{mall.title}</h2>
          <p className="guidance">{mall.description}</p>
          {redan.length > 0 && (
            <div className="inforuta">
              <strong>Redan ifyllt från din utredning:</strong>
              <ul>{redan.map((q) => <li key={q.key}>{q.label}: <strong>{docLabel(q, mallSvar[q.key])}</strong></li>)}</ul>
              Du behöver aldrig svara på samma fråga två gånger — men allt går att ändra här.
            </div>
          )}
          {fragor.map((q) => (
            <DocFalt key={q.key} q={q} value={mallSvar[q.key]}
              onChange={(v) => setMallSvarAlla((prev) => ({ ...prev, [mall.key]: { ...(prev[mall.key] ?? {}), [q.key]: v } }))} />
          ))}
        </div>
        <div className="card">
          <h2>Så här blir dokumentet</h2>
          {dokument === null ? (
            <p className="meta warn">
              Fyll i {dom.missing.map((m) => m.label).join(', ')} — då skrivs dokumentet färdigt här.
              Vi skriver aldrig något du inte svarat.
            </p>
          ) : (
            <>
              <pre className="dokument">{dokument}</pre>
              <div className="row">
                <button className="btn primary" onClick={() => kopiera(dokument)}>{kopierad ? 'Kopierad ✓' : 'Kopiera dokumentet'}</button>
                <UtLank className="btn small" href={opp.applicationUrl}>Ansök själv hos {opp.authority}</UtLank>
              </div>
            </>
          )}
        </div>
      </div>
    );
  }

  // ── Schemavägen: myndighetens egna fält, i myndighetens ordning ───────────
  const synliga = visibleFields(schema, svar);
  const problem = validateAnswers(schema, svar);
  const klart = problem.length === 0;
  const dokument = klart ? renderaSchemaDokument(schema, svar, opp) : null;

  return (
    <div>
      {huvud}
      <div className="card">
        <h2>{schema.title}</h2>
        <p className="meta">
          Fälten är {opp.authority}s egna, kurerade ur den officiella ansökan — inte en generell mall.
          {forifyllt.prefilledKeys.length > 0 && ` ${forifyllt.prefilledKeys.length} av dem är redan ifyllda ur din utredning.`}
        </p>
        {schema.sections.map((sek) => {
          const falt = synliga.filter((f) => f.section === sek.key);
          if (falt.length === 0) return null;
          return (
            <div key={sek.key} className="schemasektion">
              <h3>{sek.title}</h3>
              {sek.description && <p className="guidance">{sek.description}</p>}
              {falt.map((f) => (
                <div key={f.key}>
                  {forifyllt.prefilledKeys.includes(f.key) && (
                    <p className="meta forifyllt">Ifyllt från din utredning — ändra om det inte stämmer.</p>
                  )}
                  <SchemaFalt f={f} value={svar[f.key]}
                    onChange={(v) => { setSvar((prev) => ({ ...prev, [f.key]: v })); setKopierad(false); }} />
                </div>
              ))}
            </div>
          );
        })}
      </div>
      <div className="card">
        <h2>Så här blir ansökan</h2>
        {dokument === null ? (
          <div>
            <p className="meta warn">Det här saknas innan ansökan är komplett:</p>
            <ul className="underlag">
              {problem.slice(0, 8).map((i) => <li key={i.fieldKey}>{i.message}</li>)}
            </ul>
            <p className="meta">Vi skriver aldrig något du inte svarat.</p>
          </div>
        ) : (
          <>
            <pre className="dokument">{dokument}</pre>
            <div className="row">
              <button className="btn primary" onClick={() => kopiera(dokument)}>{kopierad ? 'Kopierad ✓' : 'Kopiera ansökan'}</button>
              <UtLank className="btn small" href={opp.applicationUrl}>Ansök själv hos {opp.authority}</UtLank>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/**
 * F-VIDARE: planen efter "Nästa" — ett konkret nästa steg per valt stöd.
 * Demon länkar till källan och visar vad som återstår att reda ut; i
 * produkten förbereds ansökan färdigifylld utifrån samma svar.
 */
function PlanView({ slugs, facts, onBack, onToggle, onForbered }: { slugs: string[]; facts: Facts; onBack: () => void; onToggle: (slug: string) => void; onForbered: (slug: string) => void }) {
  const results = useMemo(() => runEngine(facts), [facts]);
  const rows = results.filter((r) => slugs.includes(r.opp.slug));
  return (
    <div>
      <button className="btn subtle" onClick={onBack} style={{ marginBottom: '0.6rem' }}>← Tillbaka till analysen</button>
      <div className="card accent">
        <h1>Din plan — {rows.length} {rows.length === 1 ? 'ansökan' : 'ansökningar'}</h1>
        <p className="guidance">
          Så går du vidare med varje valt stöd. I Bidragskoll.se-produkten förbereder du ansökan färdigifylld utifrån
          dina svar, med granskning innan den lämnas in — 19 kr per ansökan, alla dokument ingår. Att ansöka själv
          direkt hos myndigheten är alltid gratis — här i demon visar vi vägen och länkar till källan.
        </p>
      </div>
      {rows.map((r) => (
        <div key={r.opp.slug} className="card">
          <h2>{r.opp.title}</h2>
          <p className="meta">
            {r.opp.authority} · {r.opp.closesAt ? `stänger ${fmtDate(r.opp.closesAt)}` : r.opp.deadlineModel === 'rolling' ? 'löpande ansökan — ingen deadline att missa' : 'kommande omgång'}
          </p>
          <div className="explain">
            <p style={{ margin: '0.3rem 0' }}><strong>1. Så ansöker du:</strong> {r.opp.applicationMethod}</p>
            {r.m.missingFacts.length > 0 && (
              <p style={{ margin: '0.3rem 0' }}><strong>2. Att reda ut först:</strong> {r.m.missingFacts.map((f) => f.question).join(' · ')}</p>
            )}
            <p style={{ margin: '0.3rem 0' }}>
              <strong>{r.m.missingFacts.length > 0 ? '3' : '2'}. Kontrollera aktuella villkor hos källan:</strong>{' '}
              <UtLank href={r.opp.sourceUrl}>{r.opp.sourceUrl}</UtLank> (AI-sammanställd 2026-08-13 — ej människogranskad)
            </p>
            <div className="row" style={{ marginTop: '0.5rem' }}>
              {/* Förberedelsen är produktens arbetslager och därför huvudvägen;
                  myndighetslänken står kvar intill som den alltid gratis
                  självbetjäningsvägen (PRODUCT_DOCTRINE, Open Discovery). */}
              <button className="btn primary" onClick={() => onForbered(r.opp.slug)}>Förbered ansökan →</button>
              <UtLank className="btn small" href={r.opp.applicationUrl}>Ansök själv hos {r.opp.authority}</UtLank>
              <button className="btn small" onClick={() => onToggle(r.opp.slug)}>Ta bort ur planen</button>
            </div>
          </div>
        </div>
      ))}
      {rows.length === 0 && (
        <div className="card">
          <p className="guidance">Inga stöd valda ännu — gå tillbaka till analysen och markera ”Vill ansöka” på de stöd du vill gå vidare med.</p>
        </div>
      )}
      <p className="meta" style={{ margin: '0.8rem 0.3rem' }}>
        Detta är en vägledning och inte ett myndighetsbeslut. Slutligt beslut fattas alltid av respektive myndighet.
      </p>
    </div>
  );
}

function ExcludedRow({ opp, m }: { opp: Opp; m: ReturnType<typeof runEngine>[number]['m'] }) {
  const [open, setOpen] = useState(false);
  const reason =
    m.excludedBy.length > 0
      ? m.excludedBy.map((e) => e.description).join(' · ')
      : m.explanation.filter((e) => e.outcome === 'fail').map((e) => e.description).join(' · ') || 'Uppfyller inte de publicerade kraven.';
  return (
    <>
      <button className="linkish dim" onClick={() => setOpen(!open)}>{opp.title}</button>
      <div className="meta">{reason}</div>
      {open && <div className="meta" style={{ marginTop: '0.3rem' }}>{opp.summary} · <UtLank href={opp.sourceUrl}>källa</UtLank></div>}
    </>
  );
}

/**
 * Mitt konto — speglar produktens kontoyta: kvittot är förstaklass under
 * Mina köp (Landvex AB:s riktiga säljaruppgifter, öre-exakt moms) och
 * återställningskoderna är den kanal-lösa vägen tillbaka utan e-post.
 */
const RECEIPT_TEXT = [
  'KVITTO                                   Bidragskoll.se',
  '',
  'Kvittonummer:      BS-2026-000123',
  'Köp-ID:            d3m0a1b2-c3d4-e5f6-a7b8-c9d0e1f2a3b4',
  'Datum:             2026-08-16',
  'Säljare:           Landvex AB',
  'Organisationsnr:   559141-7042',
  'Momsreg.nr:        SE559141704201',
  'Adress:            Antennvägen 2, 135 48 Tyresö',
  '──────────────────────────────────────────────────',
  'Förberedd ansökan (19 kr/ansökan)',
  'Belopp exkl. moms: 15,20 kr',
  'Moms (25,00 %):    3,80 kr',
  'Summa:             19,00 kr',
  'Betalningsmetod:   Swish (simulerad i demot)',
  'Status:            Betald',
  'Återbetalning:     ingen',
  '──────────────────────────────────────────────────',
  'Detta kvitto gäller en digitalt levererad tjänst på Bidragskoll.se.',
  'Att upptäcka och se stöd är gratis; kvitton uppstår av köpt arbetslager.',
].join('\n');

const CODE_ALPHABET = 'ABCDEFGHJKMNPQRSTVWXYZ23456789';
function demoRecoveryCode(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(15));
  let s = '';
  for (const b of bytes) s += CODE_ALPHABET[b % CODE_ALPHABET.length];
  return `${s.slice(0, 5)}-${s.slice(5, 10)}-${s.slice(10, 15)}`;
}

function AccountView({ onBack }: { onBack: () => void }) {
  const [showReceipt, setShowReceipt] = useState(false);
  const [codes, setCodes] = useState<string[] | null>(null);
  const [hasCodes, setHasCodes] = useState(false);
  return (
    <div>
      <button className="btn subtle" onClick={onBack} style={{ marginBottom: '0.6rem' }}>← Tillbaka till analysen</button>
      <div className="card">
        <h1>Mitt konto</h1>
        <p className="guidance">Så här ser kontoytan ut i fullversionen — kvitton och säkerhet bor här, ingen e-post krävs.</p>

        <h2 style={{ marginTop: '1rem' }}>Mina köp</h2>
        <div className="match" style={{ alignItems: 'center', gap: '0.5rem' }}>
          <span className="grow"><strong>Bidragsanalys</strong> — 2026-08-16 · 39,00 kr</span>
          <span className="badge success">Betald</span>
          <button className="btn" onClick={() => setShowReceipt(!showReceipt)}>{showReceipt ? 'Dölj kvitto' : 'Kvitto BS-2026-000123'}</button>
        </div>
        {showReceipt && (
          <pre style={{ background: 'var(--bg)', padding: '0.9rem', borderRadius: 8, overflowX: 'auto', fontSize: '0.82rem', lineHeight: 1.5 }}>{RECEIPT_TEXT}</pre>
        )}
        <p className="meta">Kvittot utfärdas i samma ögonblick som betalningen bekräftas och ligger alltid kvar här — med momsspecifikation och säljaruppgifter frysta vid köpet.</p>

        <h2 style={{ marginTop: '1.4rem' }}>Återställningskoder</h2>
        <p className="guidance">
          Med en återställningskod kan du välja ett nytt lösenord om du glömmer ditt — helt utan e-post. Varje kod
          fungerar en gång; koderna sparas bara som hashar hos oss.
        </p>
        {codes && (
          <div style={{ border: '1px solid var(--warning)', background: 'var(--warning-soft)', borderRadius: 8, padding: '0.9rem', margin: '0.6rem 0' }}>
            <p style={{ margin: '0 0 0.5rem', fontWeight: 600 }}>Spara koderna nu — de visas bara den här gången.</p>
            <pre style={{ background: 'var(--bg)', padding: '0.8rem', borderRadius: 8, letterSpacing: '0.05em', margin: 0 }}>{codes.join('\n')}</pre>
          </div>
        )}
        {!codes && hasCodes && <p>Du har <strong>8 av 8</strong> koder kvar.</p>}
        <button className="btn primary" onClick={() => { setCodes(Array.from({ length: 8 }, demoRecoveryCode)); setHasCodes(true); }}>
          {hasCodes ? 'Skapa nya koder (gamla slutar gälla)' : 'Skapa återställningskoder'}
        </button>
      </div>
    </div>
  );
}

/**
 * Autospar: varje sida och varje rad. Demots hela läge (steg, historik, svar,
 * upplåsning) skrivs till webbläsarens lagring vid varje förändring — en
 * omladdning fortsätter exakt där man var. "Börja om" rensar utkastet.
 */
// v2 (F-ÅLDER): nyckeln höjdes när intaget började härleda åldersfakta ur
// födelseåret. Ett sparat läge från en tidigare version kunde bära ett eget
// svar på "Är du 40 år eller yngre?" — en fråga som numera besvaras av
// födelseåret — och det svaret vann tyst över det härledda. Höjd nyckel =
// gamla, motsägelsefulla utkast läses aldrig in igen.
const DEMO_STATE_KEY = 'bidragse-demo-v2';
const DEMO_STEPS = new Set<string>([
  'entry',
  'p-household', 'p-children', 'p-separated',
  'p-child-school', 'p-child-costs', 'p-child-leisure', 'p-child-glasses', 'p-child-travel',
  'p-age', 'p-employment', 'p-biz-form', 'p-biz-sector', 'p-capacity',
  'p-income', 'p-savings', 'p-housing', 'p-housing-cost', 'p-moving-abroad', 'p-disability', 'done',
  'pr-who', 'pr-artist', 'pr-sector',
  'pr-org-democratic', 'pr-org-sports', 'pr-org-youthshare', 'pr-org-spread',
  'pr-activities', 'pr-international', 'pr-knowledge', 'pr-youth',
]);

interface DemoState { step: StepId; history: StepId[]; a: A; extraFacts: Facts; unlocked: boolean; plan?: string[] }

function loadDemoState(): DemoState | null {
  try {
    const raw = localStorage.getItem(DEMO_STATE_KEY);
    if (!raw) return null;
    const d = JSON.parse(raw) as DemoState;
    if (!DEMO_STEPS.has(d.step) || !Array.isArray(d.history) || !d.history.every((s) => DEMO_STEPS.has(s))) return null;
    if (!d.a || typeof d.a !== 'object' || !d.extraFacts || typeof d.extraFacts !== 'object') return null;
    return {
      step: d.step,
      history: d.history,
      a: d.a,
      extraFacts: d.extraFacts,
      unlocked: d.unlocked === true,
      plan: Array.isArray(d.plan) ? d.plan.filter((s): s is string => typeof s === 'string') : [],
    };
  } catch {
    return null;
  }
}

function App() {
  const [saved] = useState(loadDemoState);
  const [step, setStep] = useState<StepId>(saved?.step ?? 'entry');
  const [history, setHistory] = useState<StepId[]>(saved?.history ?? []);
  const [a, setA] = useState<A>(saved?.a ?? {});
  const [extraFacts, setExtraFacts] = useState<Facts>(saved?.extraFacts ?? {});
  const [unlocked, setUnlocked] = useState(saved?.unlocked ?? false);
  const [plan, setPlan] = useState<string[]>(saved?.plan ?? []);
  const [view, setView] = useState<'flow' | 'konto' | 'plan' | 'forbered'>('flow');
  // Vilket stöd som förbereds just nu (F-FÖRBERED).
  const [forbereder, setForbereder] = useState<string | null>(null);

  useEffect(() => {
    try {
      localStorage.setItem(DEMO_STATE_KEY, JSON.stringify({ step, history, a, extraFacts, unlocked, plan } satisfies DemoState));
    } catch { /* privat läge — demot fungerar ändå, bara utan autospar */ }
  }, [step, history, a, extraFacts, unlocked, plan]);

  // F-SCROLL (användarfynd): varje sidbyte ska börja i toppen — annars landar
  // man mitt i eller i botten av nästa skärm.
  useEffect(() => {
    window.scrollTo(0, 0);
  }, [step, view]);

  const togglePlan = (slug: string) =>
    setPlan((p) => (p.includes(slug) ? p.filter((s) => s !== slug) : [...p, slug]));

  const advance = (patch: Partial<A>) => {
    const next = { ...a, ...patch };
    setA(next);
    setHistory([...history, step]);
    setStep(nextStep(step, next));
  };
  const back = () => {
    const prev = history[history.length - 1];
    if (prev) { setHistory(history.slice(0, -1)); setStep(prev); }
  };
  const restart = () => {
    try { localStorage.removeItem(DEMO_STATE_KEY); } catch { /* ofarligt */ }
    setStep('entry'); setHistory([]); setA({}); setExtraFacts({}); setUnlocked(false); setPlan([]); setView('flow');
  };

  // F-ÅLDER (användarfynd 2026-08-28: "jag angav 1987 så jag kan inte vara 40?"):
  // intagets svar VINNER över ett sparat följdfrågesvar på samma faktum.
  // Följdfrågor ställs bara om fakta intaget INTE kan avgöra, så för de
  // nycklarna finns ingen konflikt — men ändrar man ett intagssvar (eller bär
  // med sig ett gammalt utkast) får det härledda faktumet aldrig överskuggas
  // av ett inaktuellt svar. Födelseåret 1987 ska alltid ge "40 år eller
  // yngre: Ja", oavsett vad som en gång sparades.
  const derived = useMemo(() => buildFacts(a), [a]);
  const facts = useMemo(() => ({ ...extraFacts, ...derived }), [derived, extraFacts]);

  // Håll lagringen ärlig: ett följdfrågesvar som intaget numera kan avgöra
  // städas bort, så "Dina svar" inte visar en död dubblett.
  useEffect(() => {
    const stale = Object.keys(extraFacts).filter((k) => derived[k] !== undefined);
    if (stale.length === 0) return;
    setExtraFacts((prev) => {
      const next = { ...prev };
      for (const k of stale) delete next[k];
      return next;
    });
  }, [derived, extraFacts]);

  return (
    <div className="page">
      <header className="masthead">
        <div className="brand">
          <svg className="brand-mark" viewBox="0 0 40 40" aria-hidden="true"><rect width="40" height="40" rx="11" fill="#1273d4"/> <polyline points="10,20.5 20,11.5 30,20.5" fill="none" stroke="#6fb2f0" strokeWidth="3.2" strokeLinecap="round" strokeLinejoin="round"/> <polyline points="14,25.5 18.5,30 27,21" fill="none" stroke="#fffdf9" strokeWidth="3.6" strokeLinecap="round" strokeLinejoin="round"/></svg>
          Bidragskoll
        </div>
        <div className="tag">Demo — den riktiga matchningsmotorn och {OPP_COUNT} kurerade stöd, körda helt i din webbläsare</div>
      </header>

      {view === 'flow' && step === 'done' && (
        <div style={{ display: 'flex', justifyContent: 'space-between', gap: '0.6rem', marginBottom: '0.6rem' }}>
          {/* Backa gäller även från teasern/rapporten — svaren behålls, till
              skillnad från "Börja om" som nollställer allt. */}
          <button className="btn subtle" onClick={back}>← Ändra mina svar</button>
          <button className="btn" onClick={() => setView('konto')}>Mitt konto — kvitto &amp; säkerhet</button>
        </div>
      )}

      {view === 'konto' && <AccountView onBack={() => setView('flow')} />}

      {view === 'flow' && step !== 'entry' && step !== 'done' && (
        <button className="btn subtle" onClick={back} style={{ marginBottom: '0.6rem' }}>← Tillbaka</button>
      )}

      {step === 'entry' && (
        <QFramhavd ill="glodlampa" title="Vad behöver du hjälp med?" guidance="Berätta lite om din situation så hittar vi stöd som kan vara relevanta för dig — många stöd är sådana man inte vet att de finns. En fråga i taget.">
          <Choice label="Jag har svårt att få ekonomin att gå ihop" sub="Vi tar reda på vilka stöd och ersättningar du kan ha rätt till." onClick={() => advance({ track: 'personal' })} />
          <Choice label="Jag söker pengar till ett projekt eller en verksamhet" sub="Bidrag, stipendier och finansiering — för dig, din förening eller ditt företag." onClick={() => advance({ track: 'project' })} />
        </QFramhavd>
      )}

      {step === 'p-household' && (
        <QFramhavd ill="hus" title="Bor du själv eller tillsammans med någon?">
          <Choice label="Själv" onClick={() => advance({ household: 'alone' })} />
          <Choice label="Med partner" onClick={() => advance({ household: 'partner' })} />
          <Choice label="Med andra vuxna" onClick={() => advance({ household: 'other' })} />
        </QFramhavd>
      )}
      {step === 'p-children' && (
        <QFramhavd ill="familj" title="Har du barn som bor hos dig?">
          <Choice label="Ja" onClick={() => advance({ children: 'yes' })} />
          <Choice label="Ja, växelvis" onClick={() => advance({ children: 'shared' })} />
          <Choice label="Nej" onClick={() => advance({ children: 'no' })} />
        </QFramhavd>
      )}
      {step === 'p-separated' && (
        <Q title="Bor du och barnets andra förälder på skilda håll?"><YesNo on={(v) => advance({ separated: v })} /></Q>
      )}
      {step === 'p-child-school' && (
        <Q title="Går något av barnen i skolan?">
          <Choice label="Ja, i grundskolan" onClick={() => advance({ childSchool: 'grundskola' })} />
          <Choice label="Ja, på gymnasiet" onClick={() => advance({ childSchool: 'gymnasiet' })} />
          <Choice label="Ja, både grundskola och gymnasium" onClick={() => advance({ childSchool: 'both' })} />
          <Choice label="Nej, inte ännu" onClick={() => advance({ childSchool: 'none' })} />
        </Q>
      )}
      {step === 'p-child-costs' && (
        <Q title="Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller aktivitet som skolan förväntar sig att ditt barn ska delta i?" guidance="Det finns stöd just för sådant — de flesta känner inte till dem.">
          <YesNo on={(v) => advance({ childCostsStrain: v })} />
        </Q>
      )}
      {step === 'p-child-leisure' && (
        <Q title="Har ditt barn behövt avstå från en fritidsaktivitet för att den kostar för mycket?" guidance="Även utrustning och avgifter räknas.">
          <YesNo on={(v) => advance({ childMissedLeisure: v })} />
        </Q>
      )}
      {step === 'p-child-glasses' && (
        <Q title="Behöver något av dina barn i åldern 8–19 år glasögon eller linser?" guidance="Alla regioner ger bidrag för barns glasögon — långt ifrån alla föräldrar vet om det.">
          <YesNo on={(v) => advance({ childNeedsGlasses: v })} />
        </Q>
      )}
      {step === 'p-child-travel' && (
        <Q title="Har något av barnen lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?" guidance="Skolskjuts och resestöd är rättigheter under vissa villkor.">
          <YesNo on={(v) => advance({ childTravelHard: v })} />
        </Q>
      )}
      {step === 'p-age' && (
        <Q title="Vilket år är du född?" guidance="Året avgör exakt vilka åldersgränser som gäller — vi behöver inget personnummer, bara födelseåret.">
          <YearInput onNext={(y) => advance({ birthYear: y })} />
        </Q>
      )}
      {step === 'p-employment' && (
        <Q title="Vad gör du i dag?">
          <Choice label="Arbetar" onClick={() => advance({ employment: 'working' })} />
          <Choice label="Arbetslös" onClick={() => advance({ employment: 'unemployed' })} />
          <Choice label="Sjukskriven eller nedsatt arbetsförmåga" onClick={() => advance({ employment: 'sick' })} />
          <Choice label="Studerar" onClick={() => advance({ employment: 'studying' })} />
          <Choice label="Driver eget företag" sub="Stöd till dig som person ingår alltid. Enskild firma: företagsstöden ingår också här. Aktiebolag: bolagets stöd genomlyses separat — vi visar vilka de är." onClick={() => advance({ employment: 'self_employed' })} />
          <Choice label="Pensionär" onClick={() => advance({ employment: 'retired' })} />
        </Q>
      )}
      {step === 'p-biz-form' && (
        <Q title="Hur driver du verksamheten?" guidance="Driftsformen avgör vilka företagsstöd som är aktuella och vem som söker dem — enskild firma söker du som person, ett aktiebolags stöd söks av bolaget.">
          <Choice label="Enskild firma" onClick={() => advance({ businessForm: 'sole_trader' })} />
          <Choice label="Aktiebolag" onClick={() => advance({ businessForm: 'limited_company' })} />
          <Choice label="Annat eller osäker" onClick={() => advance({ businessForm: 'other' })} />
        </Q>
      )}
      {step === 'p-biz-sector' && (
        <Q title="Vad sysslar verksamheten med?" guidance="Frågan avgör vilka branschstöd som är aktuella — jordbruksstöden gäller till exempel bara jordbruksföretag, och kultur- och energistöden har egna villkor.">
          <Choice label="Jordbruk, trädgård eller rennäring" onClick={() => advance({ bizSector: 'agriculture' })} />
          <Choice label="Kultur eller kreativ näring" sub="Musik, film, litteratur, scen, konst" onClick={() => advance({ bizSector: 'culture' })} />
          <Choice label="Energi eller miljö" sub="Energieffektivisering, laddinfrastruktur, klimatåtgärder" onClick={() => advance({ bizSector: 'environment' })} />
          <Choice label="Innovation eller teknik" onClick={() => advance({ bizSector: 'innovation' })} />
          <Choice label="Något annat" onClick={() => advance({ bizSector: 'other' })} />
        </Q>
      )}
      {step === 'p-capacity' && (
        <Q title="Bedömer du att din arbetsförmåga är nedsatt under minst ett år?" guidance="Din egen bedömning räcker här — myndigheten gör alltid den medicinska prövningen.">
          <p className="guidance" role="note" style={{ margin: '0 0 0.6rem' }}>
            Detta är en hälsouppgift — en känslig personuppgift (GDPR art. 9). Svarar du Ja eller Nej
            samtycker du uttryckligen till att svaret används för att hitta stöd. Väljer du att inte
            svara ställs frågan aldrig igen.
          </p>
          <YesNo on={(v) => advance({ capacity: v })} />
          <button className="btn subtle" style={{ marginTop: '0.5rem' }} onClick={() => advance({ capacityDeclined: true })}>
            Vill inte svara
          </button>
        </Q>
      )}
      {step === 'p-income' && (
        <Q title="Ungefär vad har hushållet i inkomst per månad, före skatt?" guidance="Räkna ihop alla inkomster i hushållet. Ungefärligt räcker.">
          <Choice label="Under 15 000 kr" onClick={() => advance({ income: 'under15' })} />
          <Choice label="15 000–25 000 kr" onClick={() => advance({ income: '15-25' })} />
          <Choice label="25 000–40 000 kr" onClick={() => advance({ income: '25-40' })} />
          <Choice label="Över 40 000 kr" onClick={() => advance({ income: 'over40' })} />
        </Q>
      )}
      {step === 'p-savings' && (
        <Q title="Saknar du sparpengar eller tillgångar som kan täcka utgifterna?"><YesNo on={(v) => advance({ savings: v })} /></Q>
      )}
      {step === 'p-housing' && (
        <Q title="Betalar du hyra eller andra boendekostnader?"><YesNo on={(v) => advance({ paysHousing: v })} /></Q>
      )}
      {step === 'p-moving-abroad' && (
        <Q title="Funderar du på att flytta utomlands?" guidance="För jobb, studier eller återvandring — svaret öppnar bara följdfrågor om det är ja.">
          <YesNo on={(v) => advance({ movingAbroad: v })} />
        </Q>
      )}
      {step === 'p-disability' && (
        <Q title="Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?" guidance="Frågan öppnar stöd som många missar — omvårdnadsbidrag, merkostnadsersättning, bilstöd och närståendepenning. Ett nej betyder att inga sådana följdfrågor ställs.">
          <p className="guidance" role="note" style={{ margin: '0 0 0.6rem' }}>
            Detta är en hälsouppgift — en känslig personuppgift (GDPR art. 9). Svarar du Ja eller Nej
            samtycker du uttryckligen till att svaret används för att hitta stöd. Väljer du att inte
            svara ställs frågan aldrig igen.
          </p>
          <YesNo on={(v) => advance({ disabilityInFamily: v })} />
          <button className="btn subtle" style={{ marginTop: '0.5rem' }} onClick={() => advance({ disabilityDeclined: true })}>
            Vill inte svara
          </button>
        </Q>
      )}
      {step === 'p-housing-cost' && (
        <Q title="Ungefär hur mycket betalar du för boendet per månad?" guidance="Ungefärligt räcker — beloppet påverkar bostadsstödens storlek.">
          <CostInput onNext={(kr) => advance(kr === undefined ? {} : { housingCost: kr })} />
        </Q>
      )}

      {step === 'pr-who' && (
        <Q title="Vem söker?">
          <Choice label="Jag som privatperson eller enskild utövare" onClick={() => advance({ who: 'individual' })} />
          <Choice label="En ideell förening" onClick={() => advance({ who: 'association' })} />
          <Choice label="Ett företag" onClick={() => advance({ who: 'company' })} />
          <Choice label="En informell grupp" sub="T.ex. en dansgrupp utan organisationsnummer." onClick={() => advance({ who: 'informal_group' })} />
          <Choice label="En kommun eller offentlig aktör" onClick={() => advance({ who: 'municipality' })} />
        </Q>
      )}
      {step === 'pr-artist' && (
        <Q title="Är du yrkesverksam inom kulturområdet?" guidance="Det avgör om kulturstöd för yrkesverksamma är aktuella.">
          <YesNo on={(v) => advance({ artist: v })} />
        </Q>
      )}
      {step === 'pr-sector' && (
        <Q title="Vilket område ligger projektet närmast?">
          <Choice label="Kultur — dans, musik, konst, scen, film" onClick={() => advance({ sector: 'culture' })} />
          <Choice label="Barn och unga" onClick={() => advance({ sector: 'youth' })} />
          <Choice label="Idrott" onClick={() => advance({ sector: 'sports' })} />
          <Choice label="Innovation och teknik" onClick={() => advance({ sector: 'innovation' })} />
          <Choice label="Energi, miljö och klimat" onClick={() => advance({ sector: 'environment' })} />
          <Choice label="Utbildning" onClick={() => advance({ sector: 'education' })} />
          <Choice label="Jordbruk och landsbygd" onClick={() => advance({ sector: 'agriculture' })} />
          <Choice label="Föreningsliv och civilsamhälle" onClick={() => advance({ sector: 'civil_society' })} />
        </Q>
      )}
      {step === 'pr-org-democratic' && (
        <Q title="Har föreningen stadgar, styrelse och årsmöte?" guidance="Demokratisk uppbyggnad är ett grundkrav i de flesta statliga föreningsstöd.">
          <YesNo on={(v) => advance({ orgDemocratic: v })} />
        </Q>
      )}
      {step === 'pr-org-sports' && (
        <Q title="Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?" guidance="Det avgör bl.a. LOK-stödet för barn- och ungdomsidrott.">
          <YesNo on={(v) => advance({ orgSportsFederation: v })} />
        </Q>
      )}
      {step === 'pr-org-youthshare' && (
        <Q title="Är minst 60 procent av medlemmarna mellan 6 och 25 år?" guidance="Ett av MUCF:s krav för ungdomsorganisationer.">
          <YesNo on={(v) => advance({ orgYouthShare: v })} />
        </Q>
      )}
      {step === 'pr-org-spread' && (
        <Q title="Har organisationen medlemsföreningar i flera län?">
          <YesNo on={(v) => advance({ orgNationalSpread: v })} />
        </Q>
      )}
      {step === 'pr-activities' && <ActivityStep onNext={(activities) => advance({ activities })} />}
      {step === 'pr-international' && (
        <Q title="Har projektet en internationell del?" guidance="T.ex. en resa, ett utbyte eller en partner i ett annat land.">
          <YesNo on={(v) => advance({ international: v })} />
        </Q>
      )}
      {step === 'pr-knowledge' && (
        <Q title="Kommer erfarenheterna att användas i er verksamhet i Sverige?"><YesNo on={(v) => advance({ knowledge: v })} /></Q>
      )}
      {step === 'pr-youth' && (
        <Q title="Riktar sig projektet till barn eller unga?"><YesNo on={(v) => advance({ youth: v })} /></Q>
      )}

      {/* Open Discovery (produktdoktrinen v2): resultaten visas direkt och gratis
          — ingen teaser, ingen betalvägg framför matchningarna. */}
      {view === 'flow' && step === 'done' && (
        <Results
          facts={facts}
          track={a.track ?? 'project'}
          onFact={(k, v) => setExtraFacts((f) => ({ ...f, [k]: v }))}
          onRestart={restart}
          chosen={new Set(plan)}
          onToggle={togglePlan}
          onNext={() => setView('plan')}
        />
      )}
      {view === 'plan' && (
        <PlanView
          slugs={plan}
          facts={facts}
          onBack={() => setView('flow')}
          onToggle={togglePlan}
          onForbered={(slug) => { setForbereder(slug); setView('forbered'); }}
        />
      )}
      {view === 'forbered' && forbereder && (() => {
        const opp = OPPS.find((o) => o.slug === forbereder);
        if (!opp) return null;
        return <ForberedVy opp={opp} facts={facts} onBack={() => setView('plan')} />;
      })()}

      <footer className="foot">
        Detta demo kör produktens verkliga matchningsmotor och kurerade kunskapsbas ({OPP_COUNT} stöd, {AUTHORITY_COUNT} finansiärer, källor
        AI-sammanställda 2026-08-13, ej människogranskade) lokalt i din webbläsare — inget skickas någonstans. I fullversionen finns
        dessutom konton, dokumentvalv, leverans av dokumenten som filer efter granskning, assisterad inlämning med
        kvitto och ärendeuppföljning. Dokumentförberedelsen du ser här kör produktens riktiga mallmotor — men i demon
        är den gratis och ingenting lämnas in. Bedömningarna är vägledande — slutligt beslut fattas alltid av respektive myndighet eller finansiär.
      </footer>
    </div>
  );
}

function CostInput({ onNext }: { onNext: (kr: number | undefined) => void }) {
  const [v, setV] = useState('');
  // F-SPECIFIK: beloppet togs emot och kastades bort. Nu bärs det vidare som
  // person.housingCostMonthly och förifyller myndighetens boendekostnadsfält.
  const kr = v === '' ? undefined : Number(v);
  const giltigt = kr === undefined || (Number.isFinite(kr) && kr >= 0 && kr < 1000000);
  return (
    <div>
      <input type="number" min={0} value={v} onChange={(e) => setV(e.target.value)} placeholder="t.ex. 8500" autoFocus />
      <div className="row" style={{ marginTop: '0.8rem' }}>
        <button className="btn primary" disabled={!giltigt} onClick={() => onNext(giltigt ? kr : undefined)}>Nästa</button>
      </div>
    </div>
  );
}

/** Födelseår — enda personuppgiften den sökande fyller i (aldrig personnummer). */
function YearInput({ onNext }: { onNext: (year: number) => void }) {
  const [v, setV] = useState('');
  const now = new Date().getFullYear();
  const year = Number(v);
  const valid = Number.isInteger(year) && year >= now - 120 && year <= now;
  return (
    <div>
      <input type="number" inputMode="numeric" min={now - 120} max={now} value={v} onChange={(e) => setV(e.target.value)} placeholder="t.ex. 1979" autoFocus />
      <div className="row" style={{ marginTop: '0.8rem' }}>
        <button className="btn primary" disabled={!valid} onClick={() => onNext(year)}>Nästa</button>
      </div>
    </div>
  );
}

function ActivityStep({ onNext }: { onNext: (selected: string[]) => void }) {
  const [sel, setSel] = useState<string[]>([]);
  const options = [
    ['exchange', 'Utbyte eller resa'], ['training', 'Utbildning eller fortbildning'],
    ['performance', 'Föreställning eller konsert'], ['production', 'Produktion eller skapande'],
    ['investment', 'Investering eller utrustning'], ['development', 'Utvecklingsprojekt'],
  ] as const;
  return (
    <Q title="Vad ska ni göra?" guidance="Välj allt som stämmer.">
      {options.map(([value, label]) => (
        <label key={value} className="check-row">
          <input
            type="checkbox"
            checked={sel.includes(value)}
            onChange={(e) => setSel(e.target.checked ? [...sel, value] : sel.filter((x) => x !== value))}
          />
          <span>{label}</span>
        </label>
      ))}
      <div className="row" style={{ marginTop: '0.9rem' }}>
        <button className="btn primary" onClick={() => onNext(sel)}>Nästa</button>
      </div>
    </Q>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
