/**
 * Adaptiv intake — produktens centrala designprincip: EN fråga per skärm.
 * Ingen blankett, ingen "fyll i din profil". Användaren behöver inte veta
 * vilket stöd som finns eller vilken kategori det tillhör — dialogen avgör
 * vilka frågor som behöver ställas, och systemet gör första utgrävningen.
 */
import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiError, post } from '../api';
import { useSession } from '../App';

type Track = 'personal' | 'project';

interface Answers {
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
  ageBand?: 'under20' | '20-28' | '29-65' | '66plus';
  employment?: 'working' | 'unemployed' | 'sick' | 'studying' | 'retired' | 'self_employed';
  reducedCapacity?: boolean;
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
  | 'entry'
  | 'p-household' | 'p-children' | 'p-separated'
  | 'p-child-school' | 'p-child-costs' | 'p-child-leisure' | 'p-child-glasses' | 'p-child-travel'
  | 'p-age' | 'p-employment' | 'p-capacity'
  | 'p-income' | 'p-savings' | 'p-housing' | 'p-housing-cost' | 'p-extra'
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
  'entry',
  'p-household', 'p-children', 'p-separated',
  'p-child-school', 'p-child-costs', 'p-child-leisure', 'p-child-glasses', 'p-child-travel',
  'p-age', 'p-employment', 'p-capacity',
  'p-income', 'p-savings', 'p-housing', 'p-housing-cost', 'p-extra',
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
    case 'p-age': return 'p-employment';
    case 'p-employment': return a.employment === 'sick' ? 'p-capacity' : 'p-income';
    case 'p-capacity': return 'p-income';
    case 'p-income': return a.incomeBand === 'under15' ? 'p-savings' : 'p-housing';
    case 'p-savings': return 'p-housing';
    case 'p-housing': return a.paysHousing ? 'p-housing-cost' : 'p-extra';
    case 'p-housing-cost': return 'p-extra';
    case 'p-extra': return 'done';
    case 'pr-intent': return 'pr-who';
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
  if (a.ageBand) {
    facts['person.ageBand'] = a.ageBand;
    facts['person.ageUnder29'] = a.ageBand === 'under20' || a.ageBand === '20-28';
    facts['person.age66Plus'] = a.ageBand === '66plus';
    if (a.ageBand === 'under20' || a.ageBand === '20-28') facts['person.age40OrYounger'] = true;
    if (a.ageBand === '66plus') facts['person.age40OrYounger'] = false;
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
  if (a.reducedCapacity !== undefined) facts['person.reducedWorkCapacityLongTerm'] = a.reducedCapacity;
  if (a.incomeBand) {
    facts['person.monthlyIncomeBand'] = a.incomeBand;
    facts['person.lowHouseholdIncome'] = a.incomeBand === 'under15' || a.incomeBand === '15-25';
    if (a.incomeBand === 'under15') facts['person.incomeInsufficientForBasicNeeds'] = true;
    if (a.incomeBand === 'over40') facts['person.incomeInsufficientForBasicNeeds'] = false;
  }
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
  const [step, setStep] = useState<StepId>(draft?.step ?? 'entry');
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
        ? {}
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

  const totalEstimate = a.track === 'personal' ? 10 : a.track === 'project' ? 10 : 8;
  const progress = useMemo(() => Math.min(1, stepNumber / totalEstimate), [stepNumber, totalEstimate]);

  return (
    <div style={{ maxWidth: 560 }}>
      <div className="progress-steps" aria-hidden>
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
              setStep('entry'); setHistory([]); setA(initial); setResumed(false);
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
  return (
    <div className="card">
      <h1 style={{ fontSize: '1.35rem' }}>{title}</h1>
      {guidance && <p className="guidance">{guidance}</p>}
      <div style={{ marginTop: '1rem' }}>{children}</div>
    </div>
  );
}

function Choice({ label, onClick, sub }: { label: string; sub?: string; onClick: () => void }) {
  return (
    <button
      className="secondary"
      onClick={onClick}
      style={{ display: 'block', width: '100%', textAlign: 'left', marginBottom: '0.55rem', padding: '0.8rem 1rem' }}
    >
      <span style={{ fontWeight: 600 }}>{label}</span>
      {sub && <span style={{ display: 'block', fontWeight: 400, color: 'var(--text-muted)', fontSize: '0.85rem' }}>{sub}</span>}
    </button>
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
    case 'entry':
      return (
        <Q
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
        </Q>
      );

    // ── Personligt spår ──────────────────────────────────────────────────────
    case 'p-household':
      return (
        <Q title="Bor du själv eller tillsammans med någon?">
          <Choice label="Själv" onClick={() => onAnswer({ householdType: 'alone' })} />
          <Choice label="Med partner" onClick={() => onAnswer({ householdType: 'partner' })} />
          <Choice label="Med andra vuxna" onClick={() => onAnswer({ householdType: 'other' })} />
        </Q>
      );
    case 'p-children':
      return (
        <Q title="Har du barn som bor hos dig?">
          <Choice label="Ja" onClick={() => onAnswer({ children: 'yes' })} />
          <Choice label="Ja, växelvis" onClick={() => onAnswer({ children: 'shared' })} />
          <Choice label="Nej" onClick={() => onAnswer({ children: 'no' })} />
        </Q>
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

    case 'p-age':
      return (
        <Q title="Hur gammal är du?" guidance="Åldern avgör vilka stöd som är aktuella — vi behöver inget personnummer.">
          <Choice label="Under 20" onClick={() => onAnswer({ ageBand: 'under20' })} />
          <Choice label="20–28" onClick={() => onAnswer({ ageBand: '20-28' })} />
          <Choice label="29–65" onClick={() => onAnswer({ ageBand: '29-65' })} />
          <Choice label="66 eller äldre" onClick={() => onAnswer({ ageBand: '66plus' })} />
        </Q>
      );
    case 'p-employment':
      return (
        <Q title="Vad gör du i dag?">
          <Choice label="Arbetar" onClick={() => onAnswer({ employment: 'working' })} />
          <Choice label="Arbetslös" onClick={() => onAnswer({ employment: 'unemployed' })} />
          <Choice label="Sjukskriven eller nedsatt arbetsförmåga" onClick={() => onAnswer({ employment: 'sick' })} />
          <Choice label="Studerar" onClick={() => onAnswer({ employment: 'studying' })} />
          <Choice label="Driver eget företag" sub="Vi tittar på både stöd till dig som person och stöd som rör företagandet." onClick={() => onAnswer({ employment: 'self_employed' })} />
          <Choice label="Pensionär" onClick={() => onAnswer({ employment: 'retired' })} />
        </Q>
      );
    case 'p-capacity':
      return (
        <Q
          title="Bedömer du att din arbetsförmåga är nedsatt under minst ett år?"
          guidance="Det avgör om ersättningar vid längre sjukdom kan vara aktuella. Din egen bedömning räcker här — myndigheten gör alltid den medicinska prövningen."
        >
          <YesNo onAnswer={(v) => onAnswer({ reducedCapacity: v })} />
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
    case 'p-extra':
      return (
        <Q title="Är det något mer som påverkar din ekonomi?" guidance="Frivilligt — t.ex. skulder, sjukdom i familjen eller något annat du vill nämna.">
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
