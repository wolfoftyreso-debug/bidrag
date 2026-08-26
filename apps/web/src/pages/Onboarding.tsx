/**
 * Adaptiv intake — produktens centrala designprincip: EN fråga per skärm.
 * Ingen blankett, ingen "fyll i din profil". Användaren behöver inte veta
 * vilket stöd som finns eller vilken kategori det tillhör — dialogen avgör
 * vilka frågor som behöver ställas, och systemet gör första utgrävningen.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, post } from '../api';
import { useSession } from '../App';

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
    // Exakt ålder (det år personen fyller X) mot varje gräns — ingen grov proxy.
    const age = new Date().getFullYear() - a.birthYear;
    facts['person.ageYears'] = age;
    facts['person.ageUnder29'] = age <= 28;
    facts['person.age40OrYounger'] = age <= 40;
    facts['person.age60Plus'] = age >= 60;
    facts['person.age62Plus'] = age >= 62;
    facts['person.age66Plus'] = age >= 66;
    facts['person.age67Plus'] = age >= 67;
    facts['person.ageBand'] = age < 20 ? 'under20' : age <= 28 ? '20-28' : age <= 65 ? '29-65' : '66plus';
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
  const navigate = useNavigate();
  const { session } = useSession();
  const draftKey = `bidrag.intag.v1.${session?.user.id ?? 'anon'}`;
  const [draft] = useState(() => loadIntakeDraft(draftKey));
  const [step, setStep] = useState<StepId>(draft?.step ?? 'who');
  const [history, setHistory] = useState<StepId[]>(draft?.history ?? []);
  const [a, setA] = useState<Answers>(draft?.a ?? initial);
  const [resumed, setResumed] = useState(Boolean(draft && draft.history.length > 0));
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
        displayName: isPersonal ? 'Min situation' : answers.applicantType === 'individual' ? 'Min profil' : 'Vår organisation',
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
        ? [answers.freeIntent, answers.extraContext].filter(Boolean).join(' ') || 'Jag behöver hjälp med min ekonomi.'
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
        title: isPersonal ? 'Min ekonomiska situation' : title.trim() || 'Mitt projekt',
        intent,
        totalBudgetMinor: !isPersonal && answers.budget ? Math.round(Number(answers.budget) * 100) : null,
        facts: projectFacts,
      });

      await post(`/v1/projects/${project.id}/matches`, {});
      // Slutfört: svaren är nu profil-/projektfakta på servern — utkastet är klart.
      try { localStorage.removeItem(draftKey); } catch { /* ofarligt */ }
      navigate(`/projekt/${project.id}`);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Något gick fel.');
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
      <div className="progress-steps" role="progressbar" aria-label="Så långt har du kommit i frågorna" aria-valuemin={0} aria-valuemax={STEP_IDS.size} aria-valuenow={[...STEP_IDS].indexOf(step) + 1}>
        <span className="done" style={{ flex: progress }} />
        <span style={{ flex: 1 - progress }} />
      </div>
      {resumed && (
        <div className="alert success" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '0.6rem', flexWrap: 'wrap' }}>
          <span>Dina svar sparas löpande — du fortsätter där du var.</span>
          <button
            className="subtle"
            onClick={() => {
              try { localStorage.removeItem(draftKey); } catch { /* ofarligt */ }
              setStep('who'); setHistory([]); setA(initial); setResumed(false);
            }}
          >
            Börja om från början
          </button>
        </div>
      )}
      {history.length > 0 && (
        <button className="subtle" onClick={back} style={{ marginBottom: '0.5rem' }}>← Tillbaka</button>
      )}
      {error && <div className="alert error">{error}</div>}
      {busy ? (
        <div className="card"><h2>Tar reda på vad du kan ha rätt till…</h2><p className="guidance">Vi går igenom kända stöd och ersättningar utifrån dina svar.</p></div>
      ) : (
        <Step key={step} step={step} a={a} onAnswer={advance} />
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
 * Framhävd nyckelfråga (designsystemet Bläck, design/README.md): för de frågor
 * som väger tyngst — indigo-mjuk panel, illustration i vit rundel (figuren
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

function YesNo({ onAnswer }: { onAnswer: (v: boolean) => void }) {
  return (
    <div style={{ display: 'flex', gap: '0.6rem' }}>
      <button onClick={() => onAnswer(true)} style={{ flex: 1, padding: '0.8rem' }}>Ja</button>
      <button className="secondary" onClick={() => onAnswer(false)} style={{ flex: 1, padding: '0.8rem' }}>Nej</button>
    </div>
  );
}

function ActivityStep({ initial, onNext }: { initial: string[]; onNext: (selected: string[]) => void }) {
  const [selected, setSelected] = useState<string[]>(initial);
  const options = [
    { value: 'exchange', label: 'Utbyte eller resa' },
    { value: 'training', label: 'Utbildning eller fortbildning' },
    { value: 'performance', label: 'Föreställning eller konsert' },
    { value: 'production', label: 'Produktion eller skapande' },
    { value: 'investment', label: 'Investering eller utrustning' },
    { value: 'development', label: 'Utvecklingsprojekt' },
  ];
  return (
    <Q title="Vad ska ni göra?" guidance="Välj allt som stämmer.">
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
      <button style={{ marginTop: '0.8rem' }} onClick={() => onNext(selected)}>Nästa</button>
    </Q>
  );
}

function Step({ step, a, onAnswer }: { step: StepId; a: Answers; onAnswer: (patch: Partial<Answers>) => void }) {
  const [text, setText] = useState('');

  switch (step) {
    // FAS 1 — lätt sökandekontext före situationsdialogen. Icke-tvingande, inget
    // bidragsnamn krävs; nästa steg är alltid en situationsfråga (doktrinen §2).
    case 'who':
      return (
        <QFramhavd
          ill="glodlampa"
          title="Vem gäller det?"
          guidance="Ett snabbt val så vi ställer rätt frågor — sedan berättar du om situationen med egna ord. Du behöver inte veta vad något stöd heter."
        >
          <Choice
            label="Mig själv"
            sub="Stöd och ersättningar för dig och ditt hushåll."
            onClick={() => onAnswer({ audience: 'self' })}
          />
          <Choice
            label="Mitt företag"
            sub="Bidrag och stöd till aktiebolag eller annan företagsform."
            onClick={() => onAnswer({ audience: 'company', track: 'project', applicantType: 'company' })}
          />
          <Choice
            label="Min enskilda firma"
            sub="Både stöd till dig som person och till verksamheten — vi tar båda."
            onClick={() =>
              onAnswer({ audience: 'sole_trader', track: 'personal', employment: 'self_employed', businessForm: 'sole_trader' })
            }
          />
          <Choice
            label="En förening eller organisation"
            sub="Verksamhets- och projektstöd för föreningar och civilsamhälle."
            onClick={() => onAnswer({ audience: 'association', track: 'project', applicantType: 'association' })}
          />
        </QFramhavd>
      );

    case 'entry':
      return (
        <QFramhavd
          ill="glodlampa"
          title="Vad behöver du hjälp med?"
          guidance="Berätta lite om din situation så hittar vi stöd som kan vara relevanta för dig — många stöd är sådana man inte vet att de finns. Du behöver inte veta vad något heter."
        >
          <Choice
            label="Jag har svårt att få ekonomin att gå ihop"
            sub="Vi tar reda på vilka stöd och ersättningar du kan ha rätt till."
            onClick={() => onAnswer({ track: 'personal', freeIntent: 'Jag har svårt att få ekonomin att gå ihop.' })}
          />
          <Choice
            label="Jag söker pengar till ett projekt eller en verksamhet"
            sub="Bidrag, stipendier och finansiering — för dig, din förening eller ditt företag."
            onClick={() => onAnswer({ track: 'project' })}
          />
        </QFramhavd>
      );

    // ── Personligt spår ──────────────────────────────────────────────────────
    case 'p-household':
      return (
        <QFramhavd ill="hus" title="Bor du själv eller tillsammans med någon?">
          <Choice label="Själv" onClick={() => onAnswer({ householdType: 'alone' })} />
          <Choice label="Med partner" onClick={() => onAnswer({ householdType: 'partner' })} />
          <Choice label="Med andra vuxna" onClick={() => onAnswer({ householdType: 'other' })} />
        </QFramhavd>
      );
    case 'p-children':
      return (
        <QFramhavd ill="familj" title="Har du barn som bor hos dig?">
          <Choice label="Ja" onClick={() => onAnswer({ children: 'yes' })} />
          <Choice label="Ja, växelvis" onClick={() => onAnswer({ children: 'shared' })} />
          <Choice label="Nej" onClick={() => onAnswer({ children: 'no' })} />
        </QFramhavd>
      );
    case 'p-separated':
      return (
        <Q title="Bor du och barnets andra förälder på skilda håll?">
          <YesNo onAnswer={(v) => onAnswer({ separatedParent: v })} />
        </Q>
      );

    // ── Barnspåret: frågor som upptäcker stöd man inte söker efter ──────────
    case 'p-child-school':
      return (
        <Q title="Går något av barnen i skolan?">
          <Choice label="Ja, i grundskolan" onClick={() => onAnswer({ childSchool: 'grundskola' })} />
          <Choice label="Ja, på gymnasiet" onClick={() => onAnswer({ childSchool: 'gymnasiet' })} />
          <Choice label="Ja, både grundskola och gymnasium" onClick={() => onAnswer({ childSchool: 'both' })} />
          <Choice label="Nej, inte ännu" onClick={() => onAnswer({ childSchool: 'none' })} />
        </Q>
      );
    case 'p-child-costs':
      return (
        <Q
          title="Har du någon gång haft svårt att betala för en skolutflykt, klassresa eller aktivitet som skolan förväntar sig att ditt barn ska delta i?"
          guidance="Det finns stöd just för sådant — de flesta känner inte till dem."
        >
          <YesNo onAnswer={(v) => onAnswer({ childCostsStrain: v })} />
        </Q>
      );
    case 'p-child-leisure':
      return (
        <Q
          title="Har ditt barn behövt avstå från en fritidsaktivitet för att den kostar för mycket?"
          guidance="Även utrustning och avgifter räknas."
        >
          <YesNo onAnswer={(v) => onAnswer({ childMissedLeisure: v })} />
        </Q>
      );
    case 'p-child-glasses':
      return (
        <Q
          title="Behöver något av dina barn i åldern 8–19 år glasögon eller linser?"
          guidance="Alla regioner ger bidrag för barns glasögon — långt ifrån alla föräldrar vet om det."
        >
          <YesNo onAnswer={(v) => onAnswer({ childNeedsGlasses: v })} />
        </Q>
      );
    case 'p-child-travel':
      return (
        <Q
          title="Har något av barnen lång, trafikfarlig eller på annat sätt besvärlig väg till skolan?"
          guidance="Skolskjuts och resestöd är rättigheter under vissa villkor — kommunen gör bedömningen."
        >
          <YesNo onAnswer={(v) => onAnswer({ childTravelHard: v })} />
        </Q>
      );

    case 'p-age': {
      const nowYear = new Date().getFullYear();
      const year = Number(text);
      const valid = Number.isInteger(year) && year >= nowYear - 120 && year <= nowYear;
      return (
        <Q title="Vilket år är du född?" guidance="Året avgör exakt vilka åldersgränser som gäller — vi behöver inget personnummer, bara födelseåret.">
          <input
            type="number"
            inputMode="numeric"
            min={nowYear - 120}
            max={nowYear}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="t.ex. 1979"
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} disabled={!valid} onClick={() => onAnswer({ birthYear: year })}>Nästa</button>
        </Q>
      );
    }
    case 'p-employment':
      return (
        <Q title="Vad gör du i dag?">
          <Choice label="Arbetar" onClick={() => onAnswer({ employment: 'working' })} />
          <Choice label="Arbetslös" onClick={() => onAnswer({ employment: 'unemployed' })} />
          <Choice label="Sjukskriven eller nedsatt arbetsförmåga" onClick={() => onAnswer({ employment: 'sick' })} />
          <Choice label="Studerar" onClick={() => onAnswer({ employment: 'studying' })} />
          <Choice label="Driver eget företag" sub="Stöd till dig som person ingår alltid. Enskild firma: företagsstöden ingår också här. Aktiebolag: bolagets stöd genomlyses separat — vi visar vilka de är." onClick={() => onAnswer({ employment: 'self_employed' })} />
          <Choice label="Pensionär" onClick={() => onAnswer({ employment: 'retired' })} />
        </Q>
      );
    case 'p-biz-form':
      return (
        <Q
          title="Hur driver du verksamheten?"
          guidance="Driftsformen avgör vilka företagsstöd som är aktuella och vem som söker dem — enskild firma söker du som person, ett aktiebolags stöd söks av bolaget."
        >
          <Choice label="Enskild firma" onClick={() => onAnswer({ businessForm: 'sole_trader' })} />
          <Choice label="Aktiebolag" onClick={() => onAnswer({ businessForm: 'limited_company' })} />
          <Choice label="Annat eller osäker" onClick={() => onAnswer({ businessForm: 'other' })} />
        </Q>
      );
    case 'p-biz-sector':
      return (
        <Q
          title="Vad sysslar verksamheten med?"
          guidance="Frågan avgör vilka branschstöd som är aktuella — jordbruksstöden gäller till exempel bara jordbruksföretag, och kultur- och energistöden har egna villkor."
        >
          <Choice label="Jordbruk, trädgård eller rennäring" onClick={() => onAnswer({ bizSector: 'agriculture' })} />
          <Choice label="Kultur eller kreativ näring" sub="Musik, film, litteratur, scen, konst" onClick={() => onAnswer({ bizSector: 'culture' })} />
          <Choice label="Energi eller miljö" sub="Energieffektivisering, laddinfrastruktur, klimatåtgärder" onClick={() => onAnswer({ bizSector: 'environment' })} />
          <Choice label="Innovation eller teknik" onClick={() => onAnswer({ bizSector: 'innovation' })} />
          <Choice label="Något annat" onClick={() => onAnswer({ bizSector: 'other' })} />
        </Q>
      );
    case 'p-capacity':
      return (
        <Q
          title="Bedömer du att din arbetsförmåga är nedsatt under minst ett år?"
          guidance="Det avgör om ersättningar vid längre sjukdom kan vara aktuella. Din egen bedömning räcker här — myndigheten gör alltid den medicinska prövningen."
        >
          <p className="guidance" role="note" style={{ marginBottom: '0.6rem' }}>
            Detta är en hälsouppgift — en känslig personuppgift enligt GDPR (artikel 9).
            Svarar du Ja eller Nej samtycker du uttryckligen till att svaret behandlas för att
            hitta stöd åt dig. Du kan när som helst radera alla dina uppgifter under
            Konto &amp; data. Väljer du att inte svara ställs frågan aldrig igen.
          </p>
          <YesNo onAnswer={(v) => onAnswer({ reducedCapacity: v })} />
          <button className="subtle" style={{ marginTop: '0.6rem' }} onClick={() => onAnswer({ capacityDeclined: true })}>
            Vill inte svara
          </button>
        </Q>
      );
    case 'p-income':
      return (
        <Q title="Ungefär vad har hushållet i inkomst per månad, före skatt?" guidance="Räkna ihop alla inkomster i hushållet. Ungefärligt räcker.">
          <Choice label="Under 15 000 kr" onClick={() => onAnswer({ incomeBand: 'under15' })} />
          <Choice label="15 000–25 000 kr" onClick={() => onAnswer({ incomeBand: '15-25' })} />
          <Choice label="25 000–40 000 kr" onClick={() => onAnswer({ incomeBand: '25-40' })} />
          <Choice label="Över 40 000 kr" onClick={() => onAnswer({ incomeBand: 'over40' })} />
        </Q>
      );
    case 'p-savings':
      return (
        <Q title="Saknar du sparpengar eller tillgångar som kan täcka utgifterna?">
          <YesNo onAnswer={(v) => onAnswer({ limitedSavings: v })} />
        </Q>
      );
    case 'p-housing':
      return (
        <Q title="Betalar du hyra eller andra boendekostnader?">
          <YesNo onAnswer={(v) => onAnswer({ paysHousing: v })} />
        </Q>
      );
    case 'p-housing-cost':
      return (
        <Q title="Ungefär hur mycket betalar du för boendet per månad?">
          <input
            type="number"
            min={0}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="t.ex. 8500"
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} onClick={() => onAnswer({ housingCost: text })}>Nästa</button>
        </Q>
      );
    case 'p-moving-abroad':
      return (
        <Q
          title="Funderar du på att flytta utomlands?"
          guidance="För jobb, studier eller återvandring — det finns stöd även för den vägen. Svaret öppnar bara följdfrågor om det är ja."
        >
          <YesNo onAnswer={(v) => onAnswer({ movingAbroad: v })} />
        </Q>
      );
    case 'p-disability':
      return (
        <Q
          title="Har du eller någon nära anhörig en funktionsnedsättning eller en långvarig eller allvarlig sjukdom?"
          guidance="Frågan öppnar stöd som många missar — omvårdnadsbidrag, merkostnadsersättning, bilstöd och närståendepenning. Ett nej betyder att inga sådana följdfrågor ställs."
        >
          <p className="guidance" role="note" style={{ marginBottom: '0.6rem' }}>
            Detta är en hälsouppgift — en känslig personuppgift enligt GDPR (artikel 9).
            Svarar du Ja eller Nej samtycker du uttryckligen till att svaret behandlas för att
            hitta stöd åt dig. Du kan när som helst radera alla dina uppgifter under
            Konto &amp; data. Väljer du att inte svara ställs frågan aldrig igen.
          </p>
          <YesNo onAnswer={(v) => onAnswer({ disabilityInFamily: v })} />
          <button className="subtle" style={{ marginTop: '0.6rem' }} onClick={() => onAnswer({ disabilityDeclined: true })}>
            Vill inte svara
          </button>
        </Q>
      );
    case 'p-extra':
      return (
        <Q title="Är det något mer som påverkar din ekonomi?" guidance="Frivilligt — t.ex. skulder, höga boendekostnader eller något annat du vill nämna. Skriv inte in känsliga hälsouppgifter här; sådant frågar vi om separat med samtycke.">
          <textarea value={text} onChange={(e) => setText(e.target.value)} placeholder="Skriv fritt, eller hoppa över." />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ extraContext: text })}>Visa vad jag kan ha rätt till</button>
            <button className="subtle" onClick={() => onAnswer({ extraContext: '' })}>Hoppa över</button>
          </div>
        </Q>
      );

    // ── Projektspår ──────────────────────────────────────────────────────────
    case 'pr-intent':
      return (
        <Q title="Vad vill du åstadkomma?" guidance="Beskriv med egna ord — du behöver inte kunna namnet på något bidrag.">
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="T.ex: Jag vill ta min dansgrupp till Jamaica för att träna dancehall och ta hem kunskapen till Sverige."
            autoFocus
          />
          <button style={{ marginTop: '0.8rem' }} disabled={text.trim().length < 10} onClick={() => onAnswer({ freeIntent: text })}>
            Nästa
          </button>
        </Q>
      );
    case 'pr-who':
      return (
        <Q title="Vem söker?">
          <Choice label="Jag som privatperson eller enskild utövare" onClick={() => onAnswer({ applicantType: 'individual' })} />
          <Choice label="En ideell förening" onClick={() => onAnswer({ applicantType: 'association' })} />
          <Choice label="Ett företag" onClick={() => onAnswer({ applicantType: 'company' })} />
          <Choice label="En informell grupp" sub="T.ex. en dansgrupp eller ett kompisgäng utan organisationsnummer." onClick={() => onAnswer({ applicantType: 'informal_group' })} />
          <Choice label="En offentlig aktör" onClick={() => onAnswer({ applicantType: 'public_body' })} />
        </Q>
      );
    case 'pr-municipality':
      return (
        <Q title="Vilken kommun utgår ni från?" guidance="Frivilligt — vissa stöd är lokala.">
          <input value={text} onChange={(e) => setText(e.target.value)} placeholder="t.ex. Stockholm" autoFocus />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ municipality: text })}>Nästa</button>
            <button className="subtle" onClick={() => onAnswer({ municipality: '' })}>Hoppa över</button>
          </div>
        </Q>
      );
    case 'pr-artist':
      return (
        <Q title="Är du yrkesverksam inom kulturområdet?" guidance="Det avgör om kulturstöd för yrkesverksamma är aktuella.">
          <YesNo onAnswer={(v) => onAnswer({ professionalArtist: v })} />
        </Q>
      );
    case 'pr-sector':
      return (
        <Q title="Vilket område ligger projektet närmast?">
          <Choice label="Kultur — dans, musik, konst, scen, film" onClick={() => onAnswer({ sector: 'culture' })} />
          <Choice label="Barn och unga" onClick={() => onAnswer({ sector: 'youth' })} />
          <Choice label="Idrott" onClick={() => onAnswer({ sector: 'sports' })} />
          <Choice label="Innovation och teknik" onClick={() => onAnswer({ sector: 'innovation' })} />
          <Choice label="Energi, miljö och klimat" onClick={() => onAnswer({ sector: 'environment' })} />
          <Choice label="Utbildning" onClick={() => onAnswer({ sector: 'education' })} />
          <Choice label="Jordbruk och landsbygd" onClick={() => onAnswer({ sector: 'agriculture' })} />
          <Choice label="Föreningsliv och civilsamhälle" onClick={() => onAnswer({ sector: 'civil_society' })} />
        </Q>
      );
    case 'pr-org-democratic':
      return (
        <Q title="Har föreningen stadgar, styrelse och årsmöte?" guidance="Demokratisk uppbyggnad är ett grundkrav i de flesta statliga föreningsstöd.">
          <YesNo onAnswer={(v) => onAnswer({ orgDemocratic: v })} />
        </Q>
      );
    case 'pr-org-sports':
      return (
        <Q title="Är föreningen ansluten till ett specialidrottsförbund inom Riksidrottsförbundet?" guidance="Det avgör bl.a. LOK-stödet för barn- och ungdomsidrott.">
          <YesNo onAnswer={(v) => onAnswer({ orgSportsFederation: v })} />
        </Q>
      );
    case 'pr-org-youthshare':
      return (
        <Q title="Är minst 60 procent av medlemmarna mellan 6 och 25 år?" guidance="Ett av MUCF:s krav för ungdomsorganisationer.">
          <YesNo onAnswer={(v) => onAnswer({ orgYouthShare: v })} />
        </Q>
      );
    case 'pr-org-spread':
      return (
        <Q title="Har organisationen medlemsföreningar i flera län?">
          <YesNo onAnswer={(v) => onAnswer({ orgNationalSpread: v })} />
        </Q>
      );
    case 'pr-activities':
      return <ActivityStep initial={a.activityTypes} onNext={(activityTypes) => onAnswer({ activityTypes })} />;
    case 'pr-international':
      return (
        <Q title="Har projektet en internationell del?" guidance="T.ex. en resa, ett utbyte eller en partner i ett annat land.">
          <YesNo onAnswer={(v) => onAnswer({ international: v })} />
        </Q>
      );
    case 'pr-knowledge':
      return (
        <Q title="Kommer erfarenheterna att användas i er verksamhet i Sverige?">
          <YesNo onAnswer={(v) => onAnswer({ bringsKnowledgeBack: v })} />
        </Q>
      );
    case 'pr-youth':
      return (
        <Q title="Riktar sig projektet till barn eller unga?">
          <YesNo onAnswer={(v) => onAnswer({ targetsYouth: v })} />
        </Q>
      );
    case 'pr-budget':
      return (
        <Q title="Ungefär vad kostar projektet totalt?" guidance="Frivilligt — hjälper oss föreslå en finansieringsplan.">
          <input type="number" min={0} value={text} onChange={(e) => setText(e.target.value)} placeholder="t.ex. 100000" autoFocus />
          <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.8rem' }}>
            <button onClick={() => onAnswer({ budget: text })}>Visa vad jag kan söka</button>
            <button className="subtle" onClick={() => onAnswer({ budget: '' })}>Hoppa över</button>
          </div>
        </Q>
      );
  }
}
