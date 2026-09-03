/**
 * Adaptiv intake — produktens centrala designprincip: EN fråga per skärm.
 * Ingen blankett, ingen "fyll i din profil". Användaren behöver inte veta
 * vilket stöd som finns eller vilken kategori det tillhör — dialogen avgör
 * vilka frågor som behöver ställas, och systemet gör första utgrävningen.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { ageFromBirthYear, deriveAgeFacts } from '@bidrag/core';
import { useNavigate } from 'react-router-dom';
import { ApiError, post } from '../api';
import { useSession } from '../App';
import { useT } from '../i18n';

/** Översättarfunktionens typ — skickas ned till stegen från sidkomponenten. */
type T = ReturnType<typeof useT>;

type Track = 'personal' | 'project';
/** FAS 1: lätt sökandekontext före situationsdialogen — ger struktur utan att
 * kräva förkunskap (produktdoktrinen §2 hålls; doctrine.mjs vaktar). */
type Audience = 'self' | 'company' | 'sole_trader' | 'association';

interface Answers {
  audience?: Audience;
  track?: Track;
  freeIntent: string;
  // personligt spår
  householdType?: 'alone' | 'partner' | 'other';
  children?: 'yes' | 'shared' | 'no';
  separatedParent?: boolean;
  // barnspåret: situationsfrågor som öppnar stöd folk inte vet finns
  childSchool?: 'grundskola' | 'gymnasiet' | 'both' | 'none';
  childCostsStrain?: boolean;
  childMissedLeisure?: boolean;
  childNeedsGlasses?: boolean;
  childTravelHard?: boolean;
  /** Födelseår — enda personuppgiften den sökande fyller i (aldrig personnummer).
   * Ger exakt ålder mot varje åldersgräns (stänger M11:s grova bandproxy). */
  birthYear?: number;
  employment?: 'working' | 'unemployed' | 'sick' | 'studying' | 'retired' | 'self_employed';
  businessForm?: 'sole_trader' | 'limited_company' | 'other';
  bizSector?: 'agriculture' | 'culture' | 'environment' | 'innovation' | 'other';
  reducedCapacity?: boolean;
  /** Art. 9: användaren avböjde arbetsförmågefrågan — den ställs aldrig igen. */
  capacityDeclined?: boolean;
  movingAbroad?: boolean;
  disabilityInFamily?: boolean;
  /** Art. 9: användaren avböjde hälsofrågan — den ställs aldrig igen. */
  disabilityDeclined?: boolean;
  incomeBand?: 'under15' | '15-25' | '25-40' | 'over40';
  limitedSavings?: boolean;
  paysHousing?: boolean;
  housingCost?: string;
  extraContext: string;
  // projektspår
  applicantType?: string;
  municipality?: string;
  professionalArtist?: boolean;
  sector?: string;
  activityTypes: string[];
  international?: boolean;
  bringsKnowledgeBack?: boolean;
  targetsYouth?: boolean;
  budget?: string;
  // föreningsgrenen (kuratorsbeslut b, 30-simuleringen)
  orgDemocratic?: boolean;
  orgSportsFederation?: boolean;
  orgYouthShare?: boolean;
  orgNationalSpread?: boolean;
}

const initial: Answers = { freeIntent: '', extraContext: '', activityTypes: [] };

type StepId =
  | 'who'
  | 'entry'
  | 'p-household' | 'p-children' | 'p-separated'
  | 'p-child-school' | 'p-child-costs' | 'p-child-leisure' | 'p-child-glasses' | 'p-child-travel'
  | 'p-age' | 'p-employment' | 'p-biz-form' | 'p-biz-sector' | 'p-capacity'
  | 'p-income' | 'p-savings' | 'p-housing' | 'p-housing-cost' | 'p-moving-abroad' | 'p-disability' | 'p-extra'
  | 'pr-intent' | 'pr-who' | 'pr-municipality' | 'pr-artist' | 'pr-sector'
  | 'pr-org-democratic' | 'pr-org-sports' | 'pr-org-youthshare' | 'pr-org-spread'
  | 'pr-activities'
  | 'pr-international' | 'pr-knowledge' | 'pr-youth' | 'pr-budget';

/**
 * Autospar: varje sida och varje rad. Varje svar och varje stegbyte skrivs
 * omedelbart till webbläsarens lagring (per konto), så en omladdning, krasch
 * eller stängd flik aldrig tappar ett svar — användaren fortsätter där den
 * var. Utkastet rensas när intaget slutförts; från den punkten äger servern
 * all data (profil, projekt, fakta).
 */
const STEP_IDS = new Set<string>([
  'who',
  'entry',
  'p-household', 'p-children', 'p-separated',
  'p-child-school', 'p-child-costs', 'p-child-leisure', 'p-child-glasses', 'p-child-travel',
  'p-age', 'p-employment', 'p-biz-form', 'p-biz-sector', 'p-capacity',
  'p-income', 'p-savings', 'p-housing', 'p-housing-cost', 'p-moving-abroad', 'p-disability', 'p-extra',
  'pr-intent', 'pr-who', 'pr-municipality', 'pr-artist', 'pr-sector',
  'pr-org-democratic', 'pr-org-sports', 'pr-org-youthshare', 'pr-org-spread',
  'pr-activities', 'pr-international', 'pr-knowledge', 'pr-youth', 'pr-budget',
]);

interface IntakeDraft { v: 1; step: StepId; history: StepId[]; a: Answers }

function loadIntakeDraft(key: string): IntakeDraft | null {
  try {
    const raw = localStorage.getItem(key);
    if (!raw) return null;
    const d = JSON.parse(raw) as IntakeDraft;
    if (d.v !== 1 || !STEP_IDS.has(d.step) || !Array.isArray(d.history) || !d.history.every((s) => STEP_IDS.has(s))) return null;
    if (!d.a || typeof d.a !== 'object') return null;
    return { ...d, a: { ...initial, ...d.a, activityTypes: Array.isArray(d.a.activityTypes) ? d.a.activityTypes : [] } };
  } catch {
    return null;
  }
}

/** Nästa steg beror på svaren — frågor som inte ändrar resultatet hoppas över. */
function nextStep(current: StepId, a: Answers): StepId | 'done' {
  switch (current) {
    case 'who':
      // Sökandekontext → rätt situationsdialog. Enskild firma får dubbelkontext:
      // personspåret (person-stöd) med förifyllt self_employed/sole_trader så att
      // företagsstöden också genomlyses. Företag/förening går direkt till
      // situationsfrågan "Vad vill du åstadkomma?" (ingen förkunskap krävs).
      if (a.audience === 'company' || a.audience === 'association') return 'pr-intent';
      if (a.audience === 'sole_trader') return 'p-household';
      return 'entry';
    case 'entry': return a.track === 'personal' ? 'p-household' : 'pr-intent';
    case 'p-household': return 'p-children';
    case 'p-children': return a.children !== 'no' ? 'p-separated' : 'p-age';
    case 'p-separated': return 'p-child-school';
    // Barnspåret ställs bara när det finns barn — och varje fråga kan öppna
    // stöd användaren inte visste fanns.
    case 'p-child-school': return 'p-child-costs';
    case 'p-child-costs': return a.childCostsStrain ? 'p-child-glasses' : 'p-child-leisure';
    case 'p-child-leisure': return 'p-child-glasses';
    case 'p-child-glasses': return a.childSchool !== 'none' ? 'p-child-travel' : 'p-age';
    case 'p-child-travel': return 'p-age';
    // Enskild firma: sysselsättning och driftsform är redan kända (förifyllda i
    // 'who'), så hoppa direkt till verksamhetens sektor. Övriga: fråga vidare.
    case 'p-age': return a.employment === 'self_employed' ? 'p-biz-sector' : 'p-employment';
    case 'p-employment':
      return a.employment === 'sick' ? 'p-capacity' : a.employment === 'self_employed' ? 'p-biz-form' : 'p-income';
    case 'p-biz-form': return 'p-biz-sector';
    case 'p-biz-sector': return 'p-income';
    case 'p-capacity': return 'p-income';
    case 'p-income': return a.incomeBand === 'under15' ? 'p-savings' : 'p-housing';
    case 'p-savings': return 'p-housing';
    case 'p-housing': return a.paysHousing ? 'p-housing-cost' : 'p-moving-abroad';
    case 'p-housing-cost': return 'p-moving-abroad';
    case 'p-moving-abroad': return 'p-disability';
    case 'p-disability': return 'p-extra';
    case 'p-extra': return 'done';
    // Om sökandekontexten redan är känd (företag/förening via 'who') hoppas
    // "Vem söker?" över — annars ställs den (privatperson som valt projektspåret).
    case 'pr-intent': return a.applicantType ? 'pr-municipality' : 'pr-who';
    case 'pr-who': return 'pr-municipality';
    case 'pr-municipality':
      return a.applicantType === 'individual' || a.applicantType === 'informal_group' ? 'pr-artist' : 'pr-sector';
    case 'pr-artist': return 'pr-sector';
    case 'pr-sector':
      // Föreningsgrenen: org-fakta som RF-/MUCF-stöden faktiskt kräver — utan
      // dem hamnar varje förening i "behöver utredas" (30-simuleringens fynd).
      return a.applicantType === 'association' ? 'pr-org-democratic' : 'pr-activities';
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
    case 'pr-youth': return 'pr-budget';
    case 'pr-budget': return 'done';
  }
}

function personalFacts(a: Answers): Record<string, unknown> {
  const facts: Record<string, unknown> = {};
  if (a.householdType) facts['person.householdType'] = a.householdType;
  if (a.children) facts['person.hasChildrenAtHome'] = a.children !== 'no';
  if (a.separatedParent !== undefined) facts['person.separatedParent'] = a.separatedParent;
  if (a.birthYear) {
    // Exakt ålder (det år personen fyller X) mot varje gräns — EN källa för
    // härledningen (packages/core/src/facts.ts, M15): 18–28 och 19–29 är två
    // olika fakta, och kopian som låg här (och i demon, sim30, gendocs) är borta.
    Object.assign(facts, deriveAgeFacts(ageFromBirthYear(a.birthYear)));
  }
  // Barnspåret: upptäcktsfrågorna sätter fakta som öppnar stöd användaren
  // sällan känner till (Majblomman, glasögonbidrag, skolskjuts, elevresor).
  if (a.childSchool) {
    facts['person.childInCompulsorySchool'] = a.childSchool === 'grundskola' || a.childSchool === 'both';
    facts['person.childInUpperSecondary'] = a.childSchool === 'gymnasiet' || a.childSchool === 'both';
  }
  if (a.childCostsStrain !== undefined || a.childMissedLeisure !== undefined) {
    // Endera upptäcktsfrågan räcker: skolutflykten ELLER fritidsaktiviteten.
    facts['person.childCostsStrain'] = Boolean(a.childCostsStrain || a.childMissedLeisure);
  }
  if (a.childNeedsGlasses !== undefined) facts['person.childNeedsGlasses'] = a.childNeedsGlasses;
  if (a.childTravelHard !== undefined) {
    // Grundskolans skolskjuts bedöms brett (avstånd/trafik/funktionsnedsättning);
    // gymnasiets elevresor har ett exakt sexkilometersvillkor som får bli
    // följdfråga i resultatet i stället för att gissas här.
    if (a.childSchool === 'grundskola' || a.childSchool === 'both') {
      facts['person.childSchoolDistanceQualifies'] = a.childTravelHard;
    }
    if (!a.childTravelHard) {
      facts['person.childSchoolDistanceQualifies'] = false;
      facts['person.childGymnasiumLongTravel'] = false;
    }
  }
  if (a.employment) {
    facts['person.employmentStatus'] = a.employment;
    if (a.employment === 'studying') facts['person.isOrPlansStudying'] = true;
    facts['person.receivesPension'] = a.employment === 'retired';
    // Redan besvarat implicit: den som arbetar/studerar/är pensionär ska inte
    // få följdfrågan "är du inskriven som arbetssökande?".
    facts['person.registeredUnemployed'] = a.employment === 'unemployed';
    // "Driver eget" är en datapunkt i situationen — inte en huvudkategori.
    facts['person.selfEmployed'] = a.employment === 'self_employed';
  }
  // Företagarspåret: driftsformen avgör vem som kan söka företagsstöden —
  // enskild firma söker som person, aktiebolagets stöd söks av bolaget.
  if (a.businessForm) facts['person.businessForm'] = a.businessForm;
  // Egenföretagarens verksamhetssektor (F-RELEVANS): jordbruksstöden ska
  // antingen gälla på riktigt eller uteslutas ärligt — aldrig ligga kvar som
  // "behöver utredas"-brus. OBS: sätts som project.sector i projectFacts.

  if (a.reducedCapacity !== undefined) {
    facts['person.reducedWorkCapacityLongTerm'] = a.reducedCapacity;
    // Art. 9: nedsatt arbetsförmåga p.g.a. långvarig sjukdom är en hälsouppgift —
    // samma samtyckesram som funktionsnedsättningsfrågan (red team RT03-S3).
    facts['person.sensitiveDataConsentAt'] = new Date().toISOString();
  }
  if (a.capacityDeclined) facts['person.sensitiveQuestionDeclined'] = true;
  if (a.incomeBand) {
    facts['person.monthlyIncomeBand'] = a.incomeBand;
    facts['person.lowHouseholdIncome'] = a.incomeBand === 'under15' || a.incomeBand === '15-25';
    if (a.incomeBand === 'under15') facts['person.incomeInsufficientForBasicNeeds'] = true;
    if (a.incomeBand === 'over40') facts['person.incomeInsufficientForBasicNeeds'] = false;
  }
  // Utvandringsspåret: alltid explicit ja/nej så att frågorna aldrig spammar
  // den som inte funderar på flytt.
  if (a.movingAbroad !== undefined) facts['person.consideringMovingAbroad'] = a.movingAbroad;
  // Funktionsnedsättnings- och omsorgsspåret: samma gate-mönster — ett nej
  // håller omvårdnads-, merkostnads-, bilstöds- och närståendefrågorna borta.
  if (a.disabilityInFamily !== undefined) {
    facts['person.disabilityOrLongTermIllnessInFamily'] = a.disabilityInFamily;
    // Art. 9: svaret är en känslig personuppgift (hälsa) — samtyckestidpunkten
    // sparas som spårbart faktum tillsammans med svaret.
    facts['person.sensitiveDataConsentAt'] = new Date().toISOString();
  }
  // Avböjt = frågan får aldrig återkomma, inte i intaget och inte i rapporten.
  if (a.disabilityDeclined) facts['person.sensitiveQuestionDeclined'] = true;
  if (a.limitedSavings !== undefined) facts['person.limitedSavings'] = a.limitedSavings;
  if (a.paysHousing !== undefined) facts['person.paysHousingCost'] = a.paysHousing;
  if (a.housingCost) facts['person.housingCostMonthly'] = Number(a.housingCost);
  return facts;
}

export default function OnboardingPage() {
  const t = useT();
  const navigate = useNavigate();
  const { session } = useSession();
  const draftKey = `bidrag.intag.v1.${session?.user.id ?? 'anon'}`;
  const [draft] = useState(() => loadIntakeDraft(draftKey));
  const [step, setStep] = useState<StepId>(draft?.step ?? 'who');
  const [history, setHistory] = useState<StepId[]>(draft?.history ?? []);
  const [a, setA] = useState<Answers>(draft?.a ?? initial);
  const [resumed, setResumed] = useState(Boolean(draft && draft.history.length > 0));
  // Trattmått (QSDR-nämnare): en ny genomgång påbörjad — inte vid återupptagning.
  useEffect(() => {
    if (!resumed) void post('/v1/events', { name: 'genomgang_startad', props: {} }).catch(() => {});
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  // Varje svar och varje stegbyte sparas i samma ögonblick det sker.
  useEffect(() => {
    try {
      localStorage.setItem(draftKey, JSON.stringify({ v: 1, step, history, a } satisfies IntakeDraft));
    } catch {
      // Privat läge/full lagring: dialogen fungerar ändå, bara utan utkast.
    }
  }, [draftKey, step, history, a]);

  const stepNumber = history.length + 1;

  const finish = async (answers: Answers) => {
    setBusy(true);
    setError(null);
    try {
      const isPersonal = answers.track === 'personal';
      const { profile } = await post<{ profile: { id: string } }>('/v1/profiles', {
        kind: isPersonal || answers.applicantType === 'individual' ? 'person' : 'organisation',
        displayName: isPersonal ? t('ob.data.mySituation') : answers.applicantType === 'individual' ? t('ob.data.myProfile') : t('ob.data.ourOrg'),
        applicantType: isPersonal ? 'individual' : (answers.applicantType ?? 'individual'),
        country: 'SE',
        municipality: answers.municipality || null,
        facts: isPersonal
          ? personalFacts(answers)
          : answers.professionalArtist !== undefined
            ? { 'person.professionalArtist': answers.professionalArtist }
            : {},
      });

      const intent = isPersonal
        ? [answers.freeIntent, answers.extraContext].filter(Boolean).join(' ') || t('ob.data.defaultIntent')
        : answers.freeIntent;
      const words = intent.trim().split(/\s+/);
      let title = '';
      for (const w of words) {
        if ((title + ' ' + w).trim().length > 60) { title = title.trim() + '…'; break; }
        title = `${title} ${w}`;
      }

      const projectFacts: Record<string, unknown> = isPersonal
        ? {
            // F-RELEVANS: personspåret ÄR ett svar på sektorsfrågan — personen
            // har valt personligt stöd, inte projekt/företag. Utan detta faktum
            // hamnade sektorsgrindade stöd (jordbruk, kulturprojekt m.fl.) i
            // "behöver utredas" för alla. Egenföretagare deklarerar i stället
            // sin verksamhetssektor (p-biz-sector) så att branschstöden gäller
            // på riktigt eller utesluts ärligt. Vaktas av tools/audit-relevans.mjs.
            ...(answers.employment !== 'self_employed'
              ? { 'project.sector': 'personal' }
              : answers.bizSector
                ? { 'project.sector': answers.bizSector }
                : {}),
          }
        : {
            'project.sector': answers.sector,
            'project.activityTypes': answers.activityTypes,
            'project.targetGroups': [...(answers.targetsYouth ? ['youth'] : []), 'professionals'],
            ...(answers.international !== undefined ? { 'project.hasInternationalComponent': answers.international } : {}),
            ...(answers.bringsKnowledgeBack !== undefined ? { 'project.bringsKnowledgeBack': answers.bringsKnowledgeBack } : {}),
            ...(answers.orgDemocratic !== undefined ? { 'organisation.democraticStructure': answers.orgDemocratic } : {}),
            ...(answers.orgSportsFederation !== undefined ? { 'organisation.memberOfSportsFederation': answers.orgSportsFederation } : {}),
            ...(answers.orgYouthShare !== undefined ? { 'organisation.youthMembersShareOver60': answers.orgYouthShare } : {}),
            ...(answers.orgNationalSpread !== undefined ? { 'organisation.hasNationalSpread': answers.orgNationalSpread } : {}),
          };

      const { project } = await post<{ project: { id: string } }>('/v1/projects', {
        profileId: profile.id,
        title: isPersonal ? t('ob.data.myEconomy') : title.trim() || t('ob.data.myProject'),
        intent,
        totalBudgetMinor: !isPersonal && answers.budget ? Math.round(Number(answers.budget) * 100) : null,
        facts: projectFacts,
      });

      await post(`/v1/projects/${project.id}/matches`, {});
      // Slutfört: svaren är nu profil-/projektfakta på servern — utkastet är klart.
      try { localStorage.removeItem(draftKey); } catch { /* ofarligt */ }
      navigate(`/projekt/${project.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('ob.error.generic'));
      setBusy(false);
    }
  };

  const advance = (patch: Partial<Answers>) => {
    const updated = { ...a, ...patch };
    setA(updated);
    const next = nextStep(step, updated);
    if (next === 'done') {
      void finish(updated);
    } else {
      setHistory([...history, step]);
      setStep(next);
    }
  };

  const back = () => {
    const prev = history[history.length - 1];
    if (prev) {
      setHistory(history.slice(0, -1));
      setStep(prev);
    }
  };

  const totalEstimate = a.track === 'personal' ? 11 : a.track === 'project' ? 11 : 9;
  const progress = useMemo(() => Math.min(1, stepNumber / totalEstimate), [stepNumber, totalEstimate]);

  return (
    <div style={{ maxWidth: 560 }}>
      <div className="progress-steps" role="progressbar" aria-label={t('ob.progressLabel')} aria-valuemin={0} aria-valuemax={STEP_IDS.size} aria-valuenow={[...STEP_IDS].indexOf(step) + 1}>
        <span className="done" style={{ flex: progress }} />
        <span style={{ flex: 1 - progress }} />
      </div>
      {/* UX-genomgången 2026-09-02 (Mobbin: Laravel Cloud "Question 1 of 3",
          Monarch "Save & Exit"): en synlig räknare bredvid stapeln, och
          autosparandet sägs rakt ut i stället för att bara ske i tysthet.
          "ungefär" är ärligt — antalet frågor beror på svaren. */}
      <p className="progress-text" aria-live="polite">
        <span>{t('ob.stepOf', { n: Math.min(stepNumber, totalEstimate), m: totalEstimate })}</span>
        {!resumed && <span className="progress-autosave">{t('ob.autosave')}</span>}
      </p>
      {resumed && (
        <div className="alert success" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '0.6rem', flexWrap: 'wrap' }}>
          <span>{t('ob.resumed')}</span>
          <button
            className="subtle"
            onClick={() => {
              try { localStorage.removeItem(draftKey); } catch { /* ofarligt */ }
              setStep('who'); setHistory([]); setA(initial); setResumed(false);
            }}
          >
            {t('ob.restart')}
          </button>
        </div>
      )}
      {history.length > 0 && (
        <button className="subtle" onClick={back} style={{ marginBottom: '0.5rem' }}>{t('ob.back')}</button>
      )}
      {error && <div className="alert error">{error}</div>}
      {busy ? (
        <div className="card"><h2>{t('ob.workingTitle')}</h2><p className="guidance">{t('ob.workingBody')}</p></div>
      ) : (
        <Step key={step} step={step} a={a} onAnswer={advance} t={t} />
      )}
    </div>
  );
}

/** En fråga. Ett svar. Nästa. */
function Q({ title, guidance, children }: { title: string; guidance?: string; children: React.ReactNode }) {
  // Tillgänglighet (motförhöret B1): en fråga per skärm fungerar bara med
  // skärmläsare om fokus följer med till den nya frågan. Rubriken görs
  // fokuserbar (utan att hamna i tabbordningen) och fokuseras vid varje byte.
  const headingRef = useRef<HTMLHeadingElement | null>(null);
  useEffect(() => { headingRef.current?.focus(); }, [title]);
  return (
    <div className="card">
      <h1 ref={headingRef} tabIndex={-1} style={{ fontSize: '1.35rem', outline: 'none' }}>{title}</h1>
      {guidance && <p className="guidance">{guidance}</p>}
      <div style={{ marginTop: '1rem' }}>{children}</div>
    </div>
  );
}

function Choice({ label, onClick, sub }: { label: string; sub?: string; onClick: () => void }) {
  return (
    <button className="choice" onClick={onClick}>
      <span className="choice-label">{label}</span>
      {sub && <span className="choice-sub">{sub}</span>}
    </button>
  );
}

/**
 * Framhävd nyckelfråga (designsystemet Signal, design/README.md): för de frågor
 * som väger tyngst — mjuk blå panel, illustration i vit rundel (figuren
 * speglar frågans ämne, alt="" eftersom rubriken bär betydelsen), max en per
 * flödessteg. Samma fokushantering som Q (motförhöret B1).
 */
function QFramhavd({ title, guidance, ill, children }: { title: string; guidance?: string; ill: string; children: React.ReactNode }) {
  const headingRef = useRef<HTMLHeadingElement | null>(null);
  useEffect(() => { headingRef.current?.focus(); }, [title]);
  return (
    <div className="fraga-framhavd">
      <span className="scen"><img src={`/illustrationer/${ill}.svg`} alt="" width={96} height={96} /></span>
      <h1 ref={headingRef} tabIndex={-1} style={{ outline: 'none' }}>{title}</h1>
      {guidance && <p className="guidance">{guidance}</p>}
      <div className="val">{children}</div>
    </div>
  );
}

function YesNo({ onAnswer, t }: { onAnswer: (v: boolean) => void; t: T }) {
  return (
    <div style={{ display: 'flex', gap: '0.6rem' }}>
      <button onClick={() => onAnswer(true)} style={{ flex: 1, padding: '0.8rem' }}>{t('ob.yes')}</button>
      <button className="secondary" onClick={() => onAnswer(false)} style={{ flex: 1, padding: '0.8rem' }}>{t('ob.no')}</button>
    </div>
  );
}

function ActivityStep({ initial, onNext, t }: { initial: string[]; onNext: (selected: string[]) => void; t: T }) {
  const [selected, setSelected] = useState<string[]>(initial);
  const options = [
    { value: 'exchange', label: t('ob.activities.exchange') },
    { value: 'training', label: t('ob.activities.training') },
    { value: 'performance', label: t('ob.activities.performance') },
    { value: 'production', label: t('ob.activities.production') },
    { value: 'investment', label: t('ob.activities.investment') },
    { value: 'development', label: t('ob.activities.development') },
  ];
  return (
    <Q title={t('ob.activities.title')} guidance={t('ob.activities.guidance')}>
      {options.map((o) => (
        <div className="checkbox-row" key={o.value}>
          <input
            type="checkbox"
            id={`act-${o.value}`}
            checked={selected.includes(o.value)}
            onChange={(e) =>
              setSelected(e.target.checked ? [...selected, o.value] : selected.filter((x) => x !== o.value))
            }
          />
          <label htmlFor={`act-${o.value}`}>{o.label}</label>
        </div>
      ))}
      <button style={{ marginTop: '0.8rem' }} onClick={() => onNext(selected)}>{t('ob.next')}</button>
    </Q>
  );
}

function Step({ step, a, onAnswer, t }: { step: StepId; a: Answers; onAnswer: (patch: Partial<Answers>) => void; t: T }) {
  const [text, setText] = useState('');

  switch (step) {
    // FAS 1 — lätt sökandekontext före situationsdialogen. Icke-tvingande, inget
    // bidragsnamn krävs; nästa steg är alltid en situationsfråga (doktrinen §2).
    case 'who':
      return (
        <QFramhavd ill="glodlampa" title={t('ob.who.title')} guidance={t('ob.who.guidance')}>
          <Choice
            label={t('ob.who.self')}
            sub={t('ob.who.selfSub')}
            onClick={() => onAnswer({ audience: 'self' })}
          />
          <Choice
            label={t('ob.who.company')}
            sub={t('ob.who.companySub')}
            onClick={() => onAnswer({ audience: 'company', track: 'project', applicantType: 'company' })}
          />
          <Choice
            label={t('ob.who.sole')}
            sub={t('ob.who.soleSub')}
            onClick={() =>
              onAnswer({ audience: 'sole_trader', track: 'personal', employment: 'self_employed', businessForm: 'sole_trader' })
            }
          />
          <Choice
            label={t('ob.who.assoc')}
            sub={t('ob.who.assocSub')}
            onClick={() => onAnswer({ audience: 'association', track: 'project', applicantType: 'association' })}
          />
        </QFramhavd>
      );

    case 'entry':
      return (
        <QFramhavd ill="glodlampa" title={t('ob.entry.title')} guidance={t('ob.entry.guidance')}>
          <Choice
            label={t('ob.entry.eco')}
            sub={t('ob.entry.ecoSub')}
            onClick={() => onAnswer({ track: 'personal', freeIntent: t('ob.entry.ecoIntent') })}
          />
          <Choice
            label={t('ob.entry.project')}
            sub={t('ob.entry.projectSub')}
            onClick={() => onAnswer({ track: 'project' })}
          />
        </QFramhavd>
      );

    // ── Personligt spår ──────────────────────────────────────────────────────
    case 'p-household':
      return (
        <QFramhavd ill="hus" title={t('ob.household.title')}>
          <Choice label={t('ob.household.alone')} onClick={() => onAnswer({ householdType: 'alone' })} />
          <Choice label={t('ob.household.partner')} onClick={() => onAnswer({ householdType: 'partner' })} />
          <Choice label={t('ob.household.others')} onClick={() => onAnswer({ householdType: 'other' })} />
        </QFramhavd>
      );
    case 'p-children':
      return (
        <QFramhavd ill="familj" title={t('ob.children.title')}>
          <Choice label={t('ob.children.yes')} onClick={() => onAnswer({ children: 'yes' })} />
          <Choice label={t('ob.children.shared')} onClick={() => onAnswer({ children: 'shared' })} />
          <Choice label={t('ob.children.no')} onClick={() => onAnswer({ children: 'no' })} />
        </QFramhavd>
      );
    case 'p-separated':
      return (
        <Q title={t('ob.separated.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ separatedParent: v })} />
        </Q>
      );

    // ── Barnspåret: frågor som upptäcker stöd man inte söker efter ──────────
    case 'p-child-school':
      return (
        <Q title={t('ob.childSchool.title')}>
          <Choice label={t('ob.childSchool.compulsory')} onClick={() => onAnswer({ childSchool: 'grundskola' })} />
          <Choice label={t('ob.childSchool.upper')} onClick={() => onAnswer({ childSchool: 'gymnasiet' })} />
          <Choice label={t('ob.childSchool.both')} onClick={() => onAnswer({ childSchool: 'both' })} />
          <Choice label={t('ob.childSchool.none')} onClick={() => onAnswer({ childSchool: 'none' })} />
        </Q>
      );
    case 'p-child-costs':
      return (
        <Q title={t('ob.childCosts.title')} guidance={t('ob.childCosts.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ childCostsStrain: v })} />
        </Q>
      );
    case 'p-child-leisure':
      return (
        <Q title={t('ob.childLeisure.title')} guidance={t('ob.childLeisure.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ childMissedLeisure: v })} />
        </Q>
      );
    case 'p-child-glasses':
      return (
        <Q title={t('ob.childGlasses.title')} guidance={t('ob.childGlasses.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ childNeedsGlasses: v })} />
        </Q>
      );
    case 'p-child-travel':
      return (
        <Q title={t('ob.childTravel.title')} guidance={t('ob.childTravel.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ childTravelHard: v })} />
        </Q>
      );

    case 'p-age': {
      const nowYear = new Date().getFullYear();
      const year = Number(text);
      const valid = Number.isInteger(year) && year >= nowYear - 120 && year <= nowYear;
      return (
        <Q title={t('ob.age.title')} guidance={t('ob.age.guidance')}>
          <input
            type="number"
            inputMode="numeric"
            min={nowYear - 120}
            max={nowYear}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder={t('ob.age.placeholder')}
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} disabled={!valid} onClick={() => onAnswer({ birthYear: year })}>{t('ob.next')}</button>
        </Q>
      );
    }
    case 'p-employment':
      return (
        <Q title={t('ob.employment.title')}>
          <Choice label={t('ob.employment.working')} onClick={() => onAnswer({ employment: 'working' })} />
          <Choice label={t('ob.employment.unemployed')} onClick={() => onAnswer({ employment: 'unemployed' })} />
          <Choice label={t('ob.employment.sick')} onClick={() => onAnswer({ employment: 'sick' })} />
          <Choice label={t('ob.employment.studying')} onClick={() => onAnswer({ employment: 'studying' })} />
          <Choice label={t('ob.employment.self')} sub={t('ob.employment.selfSub')} onClick={() => onAnswer({ employment: 'self_employed' })} />
          <Choice label={t('ob.employment.retired')} onClick={() => onAnswer({ employment: 'retired' })} />
        </Q>
      );
    case 'p-biz-form':
      return (
        <Q title={t('ob.bizForm.title')} guidance={t('ob.bizForm.guidance')}>
          <Choice label={t('ob.bizForm.sole')} onClick={() => onAnswer({ businessForm: 'sole_trader' })} />
          <Choice label={t('ob.bizForm.ab')} onClick={() => onAnswer({ businessForm: 'limited_company' })} />
          <Choice label={t('ob.bizForm.other')} onClick={() => onAnswer({ businessForm: 'other' })} />
        </Q>
      );
    case 'p-biz-sector':
      return (
        <Q title={t('ob.bizSector.title')} guidance={t('ob.bizSector.guidance')}>
          <Choice label={t('ob.bizSector.agri')} onClick={() => onAnswer({ bizSector: 'agriculture' })} />
          <Choice label={t('ob.bizSector.culture')} sub={t('ob.bizSector.cultureSub')} onClick={() => onAnswer({ bizSector: 'culture' })} />
          <Choice label={t('ob.bizSector.energy')} sub={t('ob.bizSector.energySub')} onClick={() => onAnswer({ bizSector: 'environment' })} />
          <Choice label={t('ob.bizSector.innovation')} onClick={() => onAnswer({ bizSector: 'innovation' })} />
          <Choice label={t('ob.bizSector.other')} onClick={() => onAnswer({ bizSector: 'other' })} />
        </Q>
      );
    case 'p-capacity':
      return (
        <Q title={t('ob.capacity.title')} guidance={t('ob.capacity.guidance')}>
          <p className="guidance" role="note" style={{ marginBottom: '0.6rem' }}>{t('ob.art9Note')}</p>
          <YesNo t={t} onAnswer={(v) => onAnswer({ reducedCapacity: v })} />
          <button className="subtle" style={{ marginTop: '0.6rem' }} onClick={() => onAnswer({ capacityDeclined: true })}>
            {t('ob.declineAnswer')}
          </button>
        </Q>
      );
    case 'p-income':
      return (
        <Q title={t('ob.income.title')} guidance={t('ob.income.guidance')}>
          <Choice label={t('ob.income.under15')} onClick={() => onAnswer({ incomeBand: 'under15' })} />
          <Choice label={t('ob.income.b1525')} onClick={() => onAnswer({ incomeBand: '15-25' })} />
          <Choice label={t('ob.income.b2540')} onClick={() => onAnswer({ incomeBand: '25-40' })} />
          <Choice label={t('ob.income.over40')} onClick={() => onAnswer({ incomeBand: 'over40' })} />
        </Q>
      );
    case 'p-savings':
      return (
        <Q title={t('ob.savings.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ limitedSavings: v })} />
        </Q>
      );
    case 'p-housing':
      return (
        <Q title={t('ob.housing.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ paysHousing: v })} />
        </Q>
      );
    case 'p-housing-cost':
      return (
        <Q title={t('ob.housingCost.title')}>
          <input
            type="number"
            min={0}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder={t('ob.housingCost.placeholder')}
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} onClick={() => onAnswer({ housingCost: text })}>{t('ob.next')}</button>
        </Q>
      );
    case 'p-moving-abroad':
      return (
        <Q title={t('ob.movingAbroad.title')} guidance={t('ob.movingAbroad.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ movingAbroad: v })} />
        </Q>
      );
    case 'p-disability':
      return (
        <Q title={t('ob.disability.title')} guidance={t('ob.disability.guidance')}>
          <p className="guidance" role="note" style={{ marginBottom: '0.6rem' }}>{t('ob.art9Note')}</p>
          <YesNo t={t} onAnswer={(v) => onAnswer({ disabilityInFamily: v })} />
          <button className="subtle" style={{ marginTop: '0.6rem' }} onClick={() => onAnswer({ disabilityDeclined: true })}>
            {t('ob.declineAnswer')}
          </button>
        </Q>
      );
    case 'p-extra':
      return (
        <Q title={t('ob.extra.title')} guidance={t('ob.extra.guidance')}>
          <textarea value={text} onChange={(e) => setText(e.target.value)} placeholder={t('ob.extra.placeholder')} />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ extraContext: text })}>{t('ob.extra.show')}</button>
            <button className="subtle" onClick={() => onAnswer({ extraContext: '' })}>{t('ob.skip')}</button>
          </div>
        </Q>
      );

    // ── Projektspår ──────────────────────────────────────────────────────────
    case 'pr-intent':
      return (
        <Q title={t('ob.prIntent.title')} guidance={t('ob.prIntent.guidance')}>
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder={t('ob.prIntent.placeholder')}
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} disabled={text.trim().length < 10} onClick={() => onAnswer({ freeIntent: text })}>
            {t('ob.next')}
          </button>
        </Q>
      );
    case 'pr-who':
      return (
        <Q title={t('ob.prWho.title')}>
          <Choice label={t('ob.prWho.individual')} onClick={() => onAnswer({ applicantType: 'individual' })} />
          <Choice label={t('ob.prWho.assoc')} onClick={() => onAnswer({ applicantType: 'association' })} />
          <Choice label={t('ob.prWho.company')} onClick={() => onAnswer({ applicantType: 'company' })} />
          <Choice label={t('ob.prWho.informal')} sub={t('ob.prWho.informalSub')} onClick={() => onAnswer({ applicantType: 'informal_group' })} />
          <Choice label={t('ob.prWho.public')} onClick={() => onAnswer({ applicantType: 'public_body' })} />
        </Q>
      );
    case 'pr-municipality':
      return (
        <Q title={t('ob.prMunicipality.title')} guidance={t('ob.prMunicipality.guidance')}>
          <input value={text} onChange={(e) => setText(e.target.value)} placeholder={t('ob.prMunicipality.placeholder')} autoFocus />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ municipality: text })}>{t('ob.next')}</button>
            <button className="subtle" onClick={() => onAnswer({ municipality: '' })}>{t('ob.skip')}</button>
          </div>
        </Q>
      );
    case 'pr-artist':
      return (
        <Q title={t('ob.prArtist.title')} guidance={t('ob.prArtist.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ professionalArtist: v })} />
        </Q>
      );
    case 'pr-sector':
      return (
        <Q title={t('ob.prSector.title')}>
          <Choice label={t('ob.prSector.culture')} onClick={() => onAnswer({ sector: 'culture' })} />
          <Choice label={t('ob.prSector.youth')} onClick={() => onAnswer({ sector: 'youth' })} />
          <Choice label={t('ob.prSector.sports')} onClick={() => onAnswer({ sector: 'sports' })} />
          <Choice label={t('ob.prSector.innovation')} onClick={() => onAnswer({ sector: 'innovation' })} />
          <Choice label={t('ob.prSector.environment')} onClick={() => onAnswer({ sector: 'environment' })} />
          <Choice label={t('ob.prSector.education')} onClick={() => onAnswer({ sector: 'education' })} />
          <Choice label={t('ob.prSector.agriculture')} onClick={() => onAnswer({ sector: 'agriculture' })} />
          <Choice label={t('ob.prSector.civil')} onClick={() => onAnswer({ sector: 'civil_society' })} />
        </Q>
      );
    case 'pr-org-democratic':
      return (
        <Q title={t('ob.orgDemocratic.title')} guidance={t('ob.orgDemocratic.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ orgDemocratic: v })} />
        </Q>
      );
    case 'pr-org-sports':
      return (
        <Q title={t('ob.orgSports.title')} guidance={t('ob.orgSports.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ orgSportsFederation: v })} />
        </Q>
      );
    case 'pr-org-youthshare':
      return (
        <Q title={t('ob.orgYouth.title')} guidance={t('ob.orgYouth.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ orgYouthShare: v })} />
        </Q>
      );
    case 'pr-org-spread':
      return (
        <Q title={t('ob.orgSpread.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ orgNationalSpread: v })} />
        </Q>
      );
    case 'pr-activities':
      return <ActivityStep t={t} initial={a.activityTypes} onNext={(activityTypes) => onAnswer({ activityTypes })} />;
    case 'pr-international':
      return (
        <Q title={t('ob.prInternational.title')} guidance={t('ob.prInternational.guidance')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ international: v })} />
        </Q>
      );
    case 'pr-knowledge':
      return (
        <Q title={t('ob.prKnowledge.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ bringsKnowledgeBack: v })} />
        </Q>
      );
    case 'pr-youth':
      return (
        <Q title={t('ob.prYouth.title')}>
          <YesNo t={t} onAnswer={(v) => onAnswer({ targetsYouth: v })} />
        </Q>
      );
    case 'pr-budget':
      return (
        <Q title={t('ob.prBudget.title')} guidance={t('ob.prBudget.guidance')}>
          <input type="number" min={0} value={text} onChange={(e) => setText(e.target.value)} placeholder={t('ob.prBudget.placeholder')} autoFocus />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ budget: text })}>{t('ob.prBudget.show')}</button>
            <button className="subtle" onClick={() => onAnswer({ budget: '' })}>{t('ob.skip')}</button>
          </div>
        </Q>
      );
  }
}
