/**
 * RELEVANSREVISIONEN (F-RELEVANS, användarfynd 2026-08-21): "Jag har fått
 * jordbruksbidrag som förslag fast jag inte svarat att jag pysslar med
 * jordbruk."
 *
 * Regeln som revideras: ett stöd vars domän (project.sector-kriterium) varken
 * bekräftats eller kan gälla för personens deklarerade situation får ALDRIG
 * visas som förslag — inte ens som "behöver utredas". Intaget garanterar
 * detta genom att personspåret sätter project.sector = 'personal' (personen
 * har uttryckligen valt personligt stöd, inte projekt/företag — det ÄR ett
 * svar, inte en gissning), varpå motorn utesluter sektorsgrindade stöd på
 * vanligt vis.
 *
 * Verktyget kör personorna nedan — fakta byggda EXAKT som intagen bygger dem
 * (demo/main.tsx buildFacts + apps/web Onboarding; håll dem i synk!) — mot
 * alla stöd i kunskapsbasen och fallerar på:
 *   LÄCKA    — sektorsgrindat stöd är inte 'excluded' trots att personans
 *              sektor (eller avsaknad av verksamhet) inte uppfyller grinden
 *   KONTROLL — ett stöd som personan självklart SKA se är uteslutet
 *              (skyddet mot överexkludering åt andra hållet)
 *
 *   node tools/audit-relevans.mjs             # revidera (exit 1 vid fynd)
 *   node tools/audit-relevans.mjs --legacy    # återskapa felet före fixen:
 *                                             # personspåret utan sector-svar
 *
 * Ingen server och ingen databas krävs. Körs av npm run verify.
 */
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const LEGACY = process.argv.includes('--legacy');

const { computeMatch, detectTrack, relevantForTrack } = await import(join(ROOT, 'packages/core/dist/index.js'));
const { opportunities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));

// ── Personor — speglar intagens faktabygge ───────────────────────────────────
// venture: null = personspåret (ingen verksamhet); annars vald sektor.
const base = { 'applicant.country': 'SE', 'applicant.type': 'individual' };
const personal = (extra) => ({
  ...base,
  'project.sector': 'personal', // personspårets deklaration: personligt stöd, inte projekt/företag
  'person.consideringMovingAbroad': false,
  'person.disabilityOrLongTermIllnessInFamily': false,
  ...extra,
});

const PERSONAS = [
  {
    name: 'Arbetslös, låg inkomst, hyra', venture: null,
    facts: personal({
      'person.employmentStatus': 'unemployed', 'person.registeredUnemployed': true,
      'person.receivesPension': false, 'person.selfEmployed': false,
      'person.lowHouseholdIncome': true, 'person.incomeInsufficientForBasicNeeds': true,
      'person.limitedSavings': true, 'person.paysHousingCost': true,
    }),
    mustSee: ['kommun-forsorjningsstod', 'fk-bostadsbidrag-unga'],
  },
  {
    name: 'Barnfamilj, ansträngd ekonomi', venture: null,
    facts: personal({
      'person.employmentStatus': 'employed', 'person.registeredUnemployed': false,
      'person.receivesPension': false, 'person.selfEmployed': false,
      'person.lowHouseholdIncome': true, 'person.paysHousingCost': true,
      'person.childInCompulsorySchool': true, 'person.childCostsStrain': true,
      'person.childNeedsGlasses': true,
    }),
    mustSee: ['fk-bostadsbidrag-barnfamiljer', 'region-glasogonbidrag-barn', 'majblomman-bidrag-barn'],
  },
  {
    name: 'Student', venture: null,
    facts: personal({
      'person.employmentStatus': 'studying', 'person.isOrPlansStudying': true,
      'person.registeredUnemployed': false, 'person.receivesPension': false, 'person.selfEmployed': false,
    }),
    mustSee: ['csn-studiemedel'],
  },
  {
    name: 'Pensionär med låg pension', venture: null,
    facts: personal({
      'person.employmentStatus': 'retired', 'person.receivesPension': true,
      'person.registeredUnemployed': false, 'person.selfEmployed': false,
      'person.age40OrYounger': false, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true,
    }),
    mustSee: ['pm-bostadstillagg'],
  },
  {
    name: 'Funktionsnedsättning i familjen', venture: null,
    facts: personal({
      'person.employmentStatus': 'employed', 'person.registeredUnemployed': false,
      'person.receivesPension': false, 'person.selfEmployed': false,
      'person.disabilityOrLongTermIllnessInFamily': true,
      'person.reducedWorkCapacityLongTerm': true,
    }),
    mustSee: ['fk-merkostnadsersattning'],
  },
  {
    name: 'Överväger flytt utomlands', venture: null,
    facts: personal({
      'person.employmentStatus': 'employed', 'person.registeredUnemployed': false,
      'person.receivesPension': false, 'person.selfEmployed': false,
      'person.consideringMovingAbroad': true,
    }),
    mustSee: ['csn-utlandsstudier'],
  },
  {
    name: 'Yrkesverksam konstnär, internationellt projekt', venture: 'culture',
    facts: {
      ...base, 'person.professionalArtist': true, 'project.sector': 'culture',
      'project.hasInternationalComponent': true, 'project.targetGroups': ['professionals'],
    },
    mustSee: ['kulturradet-internationellt-resebidrag-musik', 'konstnarsnamnden-internationellt-kulturutbyte'],
  },
  {
    name: 'Ung person som tar över gården', venture: 'agriculture',
    facts: {
      ...base, 'project.sector': 'agriculture', 'person.age40OrYounger': true,
      'project.startingOrTakingOverFarm': true,
    },
    mustSee: ['jordbruksverket-startstod-unga'],
  },
  {
    name: 'Idrottsförening', venture: 'sports',
    facts: {
      'applicant.country': 'SE', 'applicant.type': 'association', 'project.sector': 'sports',
      'organisation.democraticStructure': true, 'organisation.memberOfSportsFederation': true,
    },
    mustSee: ['rf-lok-stod'],
  },
  {
    name: 'Innovationsbolag', venture: 'innovation',
    facts: { 'applicant.country': 'SE', 'applicant.type': 'company', 'project.sector': 'innovation' },
    mustSee: ['vinnova-innovativa-startups'],
  },
];

PERSONAS.push(
  {
    name: 'Egenföretagare (frisör, enskild firma)', venture: 'other', selfEmployed: true,
    facts: {
      ...base,
      'person.employmentStatus': 'self_employed', 'person.selfEmployed': true,
      'person.registeredUnemployed': false, 'person.receivesPension': false,
      'person.businessForm': 'sole_trader', 'project.sector': 'other',
      'person.consideringMovingAbroad': false, 'person.disabilityOrLongTermIllnessInFamily': false,
    },
    mustSee: [],
    // F-EGEN: företagsstöden ska REDOVISAS (även som ärligt uteslutna) …
    mustShow: ['af-stod-start-naringsverksamhet'],
    // … men jordbruksstöden ska vara uteslutna för en icke-jordbruksverksamhet.
    mustExclude: ['jordbruksverket-startstod-unga', 'jordbruksverket-investeringsstod', 'kulturradet-projektbidrag-musik'],
  },
  {
    // F-BRANSCH: deklarerad kultursektor ska öppna kulturbranschstöden i
    // personspåret — och jordbruksstöden ska förbli uteslutna.
    name: 'Egenföretagare (musiker, enskild firma)', venture: 'culture', selfEmployed: true,
    facts: {
      ...base,
      'person.employmentStatus': 'self_employed', 'person.selfEmployed': true,
      'person.registeredUnemployed': false, 'person.receivesPension': false,
      'person.businessForm': 'sole_trader', 'project.sector': 'culture',
      'person.consideringMovingAbroad': false, 'person.disabilityOrLongTermIllnessInFamily': false,
    },
    mustSee: [],
    mustShow: ['af-stod-start-naringsverksamhet', 'kulturradet-projektbidrag-musik', 'musikverket-projektbidrag'],
    mustExclude: ['jordbruksverket-startstod-unga', 'jordbruksverket-investeringsstod'],
  },
  {
    name: 'Egenföretagare (tar över gården, enskild firma)', venture: 'agriculture', selfEmployed: true,
    facts: {
      ...base,
      'person.employmentStatus': 'self_employed', 'person.selfEmployed': true,
      'person.registeredUnemployed': false, 'person.receivesPension': false,
      'person.businessForm': 'sole_trader', 'project.sector': 'agriculture',
      'person.age40OrYounger': true, 'project.startingOrTakingOverFarm': true,
      'person.consideringMovingAbroad': false, 'person.disabilityOrLongTermIllnessInFamily': false,
    },
    mustSee: ['jordbruksverket-startstod-unga'],
    mustShow: ['af-stod-start-naringsverksamhet'],
  },
);

// Miljöprojekt (venture environment): investeringsstödet för JORDBRUK får
// aldrig läcka hit via en för bred sektorsgrind (kureringsfyndet).
PERSONAS.push({
  name: 'Miljöprojekt (förening)', venture: 'environment',
  facts: {
    'applicant.country': 'SE', 'applicant.type': 'association', 'project.sector': 'environment',
    'organisation.democraticStructure': true,
  },
  mustExclude: ['jordbruksverket-investeringsstod'],
  mustSee: [],
});

if (LEGACY) {
  // Före fixen satte personspåret aldrig project.sector — återskapa det läget.
  for (const p of PERSONAS) if (p.venture === null) delete p.facts['project.sector'];
}

// ── Revisionen ───────────────────────────────────────────────────────────────
const REF = '2026-08-21T00:00:00Z';

function sectorGate(opp) {
  // Sektorsgrinden = hard/mandatory-kriterier på project.sector.
  const gates = opp.criteria.filter(
    (c) => c.factPath === 'project.sector' && (c.kind === 'hard' || c.kind === 'mandatory'),
  );
  if (gates.length === 0) return null;
  const accepted = new Set();
  for (const g of gates) {
    if (g.op === 'eq') accepted.add(g.expected);
    else if (g.op === 'in') for (const v of g.expected) accepted.add(v);
  }
  return accepted;
}

let leaks = 0;
let controlFailures = 0;

for (const persona of PERSONAS) {
  const rows = opportunities.map((o) => ({
    o,
    m: computeMatch({
      criteria: o.criteria,
      facts: persona.facts,
      evidenceRequirements: o.evidenceRequirements ?? [],
      availableEvidenceKinds: [],
      referenceDate: REF,
      deadline: o.closesAt ?? null,
      estimatedEffortDays: o.estimatedEffortDays,
    }),
  }));

  // PIPELINEN — exakt det användaren ser: motorns bedömning + spårfiltret
  // (delade regler i @bidrag/core). Företagsstöden får visas för egen-
  // företagare även som uteslutna (ärlig "uppfyller inte kraven"-rad).
  const track = detectTrack(persona.facts);
  const shown = relevantForTrack(
    rows.map((r) => ({ slug: r.o.slug, instrumentType: r.o.instrumentType, eligibilityStatus: r.m.eligibilityStatus, r })),
    track,
    { selfEmployed: persona.selfEmployed === true, sector: persona.facts['project.sector'] },
  );
  const visible = shown.filter((x) => x.eligibilityStatus !== 'excluded').map((x) => x.r);
  const personaLeaks = visible.filter((r) => {
    const gate = sectorGate(r.o);
    if (!gate) return false;
    return persona.venture === null || !gate.has(persona.venture);
  });
  const missing = persona.mustSee.filter((slug) => {
    const row = rows.find((r) => r.o.slug === slug);
    return !row || row.m.eligibilityStatus === 'excluded';
  });
  const wronglyIncluded = (persona.mustExclude ?? []).filter((slug) => {
    const row = rows.find((r) => r.o.slug === slug);
    return row && row.m.eligibilityStatus !== 'excluded';
  });
  const notShown = (persona.mustShow ?? []).filter((slug) => !shown.some((x) => x.slug === slug));

  console.log(`\n${persona.name} [spår: ${track}] — ${visible.length} synliga stöd av ${rows.length}`);
  for (const slug of wronglyIncluded) {
    console.log(`  KONTROLL FALLERAR: ${slug} ska vara uteslutet för den här personan`);
  }
  for (const slug of notShown) {
    console.log(`  KONTROLL FALLERAR: ${slug} ska redovisas (även som ärligt uteslutet) för den här personan`);
  }
  for (const r of personaLeaks) {
    console.log(`  LÄCKA: ${r.o.slug} (${r.m.eligibilityStatus}) — sektorsgrindat stöd utanför personens situation`);
  }
  for (const slug of missing) {
    console.log(`  KONTROLL FALLERAR: ${slug} är uteslutet men ska vara synligt`);
  }
  leaks += personaLeaks.length;
  controlFailures += missing.length + wronglyIncluded.length + notShown.length;
}

console.log(`\n──────────────────────────────`);
console.log(`Läckor: ${leaks} · Fallerade positiva kontroller: ${controlFailures}`);
if (LEGACY) {
  console.log('(--legacy: personspåret utan sector-svar — så här såg felet ut före fixen)');
  process.exit(0);
}
if (leaks || controlFailures) {
  console.log('RELEVANSREVISION FALLERAD');
  process.exit(1);
}
console.log('RELEVANSREVISION GODKÄND');
