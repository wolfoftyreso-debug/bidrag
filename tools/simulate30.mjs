/**
 * 30 simulerade användare genom HELA flödet mot riktiga API:t:
 * konto → situationsprofil (exakt intagets härledningar) → matchning → teaser
 * → analys (gratis, Open Discovery) → ev. följdfrågor → ev. ansökningsköp
 * → dokument → PDF → kvitton. Loggar allt till JSON för utvärdering, inklusive
 * automatiska rimlighetskontroller (fel frågor till fel personer, tomma
 * resultat, betalvägg före värde, kvittosummor).
 */
import { artifactsDir } from './lib/browser.mjs';
import { deriveAgeFacts } from '../packages/core/dist/index.js';
import { writeFile } from 'node:fs/promises';

const BASE = 'http://localhost:3100';
const OUT = `${artifactsDir}/sim30-results.json`;

// ── Intagets härledningar (speglar Onboarding/demo exakt) ────────────────────
function personalFacts(a) {
  const f = { 'applicant.country': 'SE' };
  if (a.household) f['person.householdType'] = a.household;
  if (a.children) f['person.hasChildrenAtHome'] = a.children !== 'no';
  if (a.separated !== undefined) f['person.separatedParent'] = a.separated;
  if (a.otherParentNotPaying !== undefined) f['person.otherParentNotPaying'] = a.otherParentNotPaying;
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
  if (a.age) {
    // Speglar födelseårshärledningen i Onboarding/demo: bandet → representativ
    // ålder → exakta tröskelfakta (M11-stängningen).
    const repAge = a.age === 'under20' ? 18 : a.age === '20-28' ? 24 : a.age === '29-65' ? 45 : 68;
    f['person.ageYears'] = repAge;
    f['person.ageBand'] = a.age;
    Object.assign(f, deriveAgeFacts(repAge)); // EN källa (core/facts.ts, M15)
  }
  if (a.employment) {
    f['person.employmentStatus'] = a.employment;
    if (a.employment === 'studying') f['person.isOrPlansStudying'] = true;
    f['person.receivesPension'] = a.employment === 'retired';
    f['person.registeredUnemployed'] = a.employment === 'unemployed';
    f['person.selfEmployed'] = a.employment === 'self_employed';
  }
  if (a.capacity !== undefined) f['person.reducedWorkCapacityLongTerm'] = a.capacity;
  if (a.income) {
    f['person.monthlyIncomeBand'] = a.income;
    f['person.lowHouseholdIncome'] = a.income === 'under15' || a.income === '15-25';
    if (a.income === 'under15') f['person.incomeInsufficientForBasicNeeds'] = true;
    if (a.income === 'over40') f['person.incomeInsufficientForBasicNeeds'] = false;
  }
  if (a.savings !== undefined) f['person.limitedSavings'] = a.savings;
  if (a.paysHousing !== undefined) f['person.paysHousingCost'] = a.paysHousing;
  if (a.housingCost) f['person.housingCostMonthly'] = a.housingCost;
  // Upptäcktsfrågorna ställs alltid explicit i intaget — speglas här.
  f['person.consideringMovingAbroad'] = a.movingAbroad === true;
  f['person.disabilityOrLongTermIllnessInFamily'] = a.disabilityInFamily === true;
  return { type: 'individual', facts: f };
}

function projectFacts(p) {
  return {
    type: p.who,
    facts: {
      'applicant.country': 'SE',
      ...(p.artist !== undefined ? { 'person.professionalArtist': p.artist } : {}),
      'project.sector': p.sector,
      'project.activityTypes': p.activities ?? [],
      'project.targetGroups': [...(p.youth ? ['youth'] : []), 'professionals'],
      ...(p.international !== undefined ? { 'project.hasInternationalComponent': p.international } : {}),
      ...(p.knowledge !== undefined ? { 'project.bringsKnowledgeBack': p.knowledge } : {}),
      ...(p.extra ?? {}),
    },
    budget: p.budget,
  };
}

// ── 30 personor ──────────────────────────────────────────────────────────────
const PERSONAS = [
  { id: 'P01', name: 'Sara, ensamstående tvåbarnsmamma, arbetslös', story: 'Separerad, underhåll uteblir, barn i grundskolan, svårt med skolutflykter, barn behöver glasögon, besvärlig skolväg.',
    ...personalFacts({ household: 'alone', children: 'yes', separated: true, otherParentNotPaying: true, childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: true, childTravelHard: true, age: '29-65', employment: 'unemployed', income: '15-25', paysHousing: true, housingCost: 8900 }),
    followUps: { 'person.incomeInsufficientForBasicNeeds': true, 'person.limitedSavings': true }, buyDocs: 'application',
    docAnswers: { templateKey: 'behovsbeskrivning', opportunitySlug: 'majblomman-bidrag-barn', answers: { fullName: 'Sara Lindqvist', whoFor: 'barn', childName: 'Elias, 10 år', needWhat: 'Kostnad för klassresa till Stockholm i maj samt matsäck och utrustning.', needWhy: 'Utan stöd kan Elias inte följa med sin klass på resan som skolan planerat.', needCost: 1200, needWhen: 'Senast i april' } } },
  { id: 'P02', name: 'Johan, arbetande pappa med ok inkomst', story: 'Partner, två barn i grundskolan, 25–40 tkr — men har tackat nej till skolutflykt av kostnadsskäl. Skulle aldrig googla "bidrag".',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: false, childTravelHard: false, age: '29-65', employment: 'working', income: '25-40', paysHousing: true }), buyDocs: 'application',
    docAnswers: { templateKey: 'behovsbeskrivning', opportunitySlug: 'majblomman-bidrag-barn', answers: { fullName: 'Johan Berg', whoFor: 'barn', childName: 'Liv, 8 år', needWhat: 'Avgift och cykel för att kunna delta i cykelläger på sportlovet.', needWhy: 'Liv är den enda i klassen som inte kan delta, vilket påverkar henne socialt.', needCost: 1800 } } },
  { id: 'P03', name: 'Amir, egenföretagare med barn i båda skolformerna', story: 'Driver eget, 15–25 tkr varierande, barn har avstått fritidsaktivitet, gymnasiebarn med lång resväg.',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'both', childCostsStrain: false, childMissedLeisure: true, childNeedsGlasses: false, childTravelHard: true, age: '29-65', employment: 'self_employed', income: '15-25', paysHousing: true }),
    followUps: { 'person.childGymnasiumLongTravel': true } },
  { id: 'P04', name: 'Moa, student utan barn', story: '22 år, studerar, under 15 tkr, hyr rum, inga besparingar.',
    ...personalFacts({ household: 'other', children: 'no', age: '20-28', employment: 'studying', income: 'under15', savings: true, paysHousing: true }) },
  { id: 'P05', name: 'Gunnar, pensionär med mycket låg pension', story: '74 år, ensam, hyresrätt, under 15 tkr.',
    ...personalFacts({ household: 'alone', children: 'no', age: '66plus', employment: 'retired', income: 'under15', savings: true, paysHousing: true }) },
  { id: 'P06', name: 'Elin, långtidssjukskriven', story: '38 år, nedsatt arbetsförmåga över ett år, 15–25 tkr, hyresrätt.',
    ...personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'sick', capacity: true, income: '15-25', paysHousing: true }), buyDocs: 'application',
    docAnswers: { templateKey: 'sarskilda-omstandigheter', answers: { fullName: 'Elin Åström', circumstance: 'Långtidssjukskriven sedan ett år på grund av utmattningssyndrom.', since: 'Augusti 2025', impact: 'Inkomsten har minskat kraftigt och besparingarna är slut; hyran tar större delen av sjukpenningen.', steps: 'Har kontakt med Försäkringskassan och arbetsgivaren om arbetsträning.' } } },
  { id: 'P07', name: 'Liam, 19 år utan sysselsättning', story: 'Bor hemma, varken studier eller arbete, ingen egen boendekostnad.',
    ...personalFacts({ household: 'other', children: 'no', age: 'under20', employment: 'unemployed', income: 'under15', savings: true, paysHousing: false }) },
  { id: 'P08', name: 'Petra, växelvis boende med gymnasiebarn', story: 'Arbetar, 25–40 tkr, sonen har 7 km till gymnasiet.',
    ...personalFacts({ household: 'alone', children: 'shared', separated: true, otherParentNotPaying: false, childSchool: 'gymnasiet', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, childTravelHard: true, age: '29-65', employment: 'working', income: '25-40', paysHousing: true }),
    followUps: { 'person.childGymnasiumLongTravel': true } },
  { id: 'P09', name: 'Krister, arbetslös utan barn', story: '45 år, inskriven på AF, 15–25 tkr, hyresrätt.',
    ...personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'unemployed', income: '15-25', paysHousing: true }) },
  { id: 'P10', name: 'Cecilia & Marcus, hög inkomst utan barn', story: 'Partner, över 40 tkr, villa. Förväntar sig ärligt tunt resultat.',
    ...personalFacts({ household: 'partner', children: 'no', age: '29-65', employment: 'working', income: 'over40', paysHousing: true }) },
  { id: 'P11', name: 'Helena, hög inkomst MEN skolkostnadsstress', story: 'Över 40 tkr men svarar ja på skolutflyktsfrågan — testar Majblommans gräns.',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: false, childTravelHard: false, age: '29-65', employment: 'working', income: 'over40', paysHousing: true }) },
  { id: 'P12', name: 'Yusuf, ensamstående trebarnspappa', story: 'Under 15 tkr, inga besparingar, alla barnfrågor ja, grundskola.',
    ...personalFacts({ household: 'alone', children: 'yes', separated: true, otherParentNotPaying: true, childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: true, childTravelHard: true, age: '29-65', employment: 'unemployed', income: 'under15', savings: true, paysHousing: true, housingCost: 10200 }),
    buyDocs: 'application', docAnswers: { templateKey: 'ansokan-ekonomiskt-stod', opportunitySlug: 'kommun-forsorjningsstod', answers: { fullName: 'Yusuf Ali', address: 'Rågvägen 12', postalCity: '603 62 Norrköping', municipality: 'Norrköping', householdAdults: 1, hasChildren: true, childrenCount: 3, childrenAges: '7, 9 och 12 år', whatFor: 'Hjälp med hyra och vinterkläder till barnen inför vintern.', whyNeeded: 'Underhållet från barnens andra förälder uteblir och a-kassan täcker inte hela hyran.' } },
    docAnswers2: { templateKey: 'bilaga-ekonomisk-situation', opportunitySlug: 'kommun-forsorjningsstod', answers: { fullName: 'Yusuf Ali', incomeBenefits: 11400, costHousing: 10200, costChildren: 2400, savings: false } } },
  { id: 'P13', name: 'Frida, studerande småbarnsförälder', story: '24 år, barn i förskoleåldern, 15–25 tkr, hyresrätt.',
    ...personalFacts({ household: 'alone', children: 'yes', separated: true, otherParentNotPaying: false, childSchool: 'none', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, age: '20-28', employment: 'studying', income: '15-25', paysHousing: true }) },
  { id: 'P14', name: 'Birgitta, pensionär med hyggligt pension', story: '70 år, 25–40 tkr — ska INTE se äldreförsörjningsstöd som aktuellt.',
    ...personalFacts({ household: 'partner', children: 'no', age: '66plus', employment: 'retired', income: '25-40', paysHousing: true }) },
  { id: 'P15', name: 'Tomas, sjukskriven med gymnasiebarn', story: 'Nedsatt förmåga, 15–25 tkr, barnet har avstått fritidsaktiviteter.',
    ...personalFacts({ household: 'alone', children: 'yes', separated: true, otherParentNotPaying: false, childSchool: 'gymnasiet', childCostsStrain: false, childMissedLeisure: true, childNeedsGlasses: true, childTravelHard: false, age: '29-65', employment: 'sick', capacity: true, income: '15-25', paysHousing: true }) },
  { id: 'P16', name: 'Anna, arbetande ensamboende', story: '31 år, 15–25 tkr, hyresrätt, inga barn.',
    ...personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'working', income: '15-25', paysHousing: true }) },
  { id: 'P17', name: 'Basel, egenföretagare utan barn', story: 'Enmansbolag med tunna marginaler, 15–25 tkr, hyresrätt.',
    ...personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'self_employed', income: '15-25', paysHousing: true }) },
  { id: 'P18', name: 'Nellie, ung arbetslös i egen lägenhet', story: '23 år, under 15 tkr, hyresrätt, inga besparingar.',
    ...personalFacts({ household: 'alone', children: 'no', age: '20-28', employment: 'unemployed', income: 'under15', savings: true, paysHousing: true }),
    followUps: { 'person.incomeInsufficientForBasicNeeds': true, 'person.limitedSavings': true } },
  { id: 'P19', name: 'Oskar & Lina, småbarnsföräldrar', story: 'Barn 3 och 5 år (ej skola), 25–40 tkr, bostadsrätt.',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'none', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, age: '29-65', employment: 'working', income: '25-40', paysHousing: true }) },
  { id: 'P20', name: 'Maria, förälder med bara skolvägsproblem', story: 'Arbetar, ok ekonomi, men barnets skolväg är trafikfarlig.',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'grundskola', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, childTravelHard: true, age: '29-65', employment: 'working', income: '25-40', paysHousing: true }) },
  { id: 'P21', name: 'Rut, 79 år med enbart garantipension', story: 'Ensam, hyresrätt, under 15 tkr.',
    ...personalFacts({ household: 'alone', children: 'no', age: '66plus', employment: 'retired', income: 'under15', savings: true, paysHousing: true }),
    followUps: { 'person.limitedSavings': true } },
  { id: 'P22', name: 'Vera, 18-årig gymnasiestuderande', story: 'Bor hemma, studerar, ingen boendekostnad.',
    ...personalFacts({ household: 'other', children: 'no', age: 'under20', employment: 'studying', income: 'under15', paysHousing: false }) },
  { id: 'P23', name: 'Danijela, arbetslös med tonåring', story: '48 år, gymnasiebarn, 15–25 tkr, funderar på omskolning.',
    ...personalFacts({ household: 'alone', children: 'yes', separated: true, otherParentNotPaying: false, childSchool: 'gymnasiet', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, childTravelHard: false, age: '29-65', employment: 'unemployed', income: '15-25', paysHousing: true }) },
  { id: 'P24', name: 'Familjen Ek, trygg ekonomi med skolbarn', story: 'Över 40 tkr, inga kostnadsproblem — nej på alla upptäcktsfrågor. Ska INTE få barnstödsspåren.',
    ...personalFacts({ household: 'partner', children: 'yes', separated: false, childSchool: 'grundskola', childCostsStrain: false, childMissedLeisure: false, childNeedsGlasses: false, childTravelHard: false, age: '29-65', employment: 'working', income: 'over40', paysHousing: true }) },
  // Projektspåret
  { id: 'P25', name: 'Aisha, danskonstnär (Jamaicaprojektet)', story: 'Yrkesverksam, internationellt utbyte med kunskapshemtagning.', ...projectFacts({ who: 'individual', artist: true, sector: 'culture', activities: ['exchange', 'training'], international: true, knowledge: true, budget: 10_000_000 }) },
  { id: 'P26', name: 'IF Kämpen, idrottsförening med barnverksamhet', story: 'Ideell förening, lokal barn- och ungdomsidrott, ansluten till RF.', ...projectFacts({ who: 'association', sector: 'sports', activities: ['development'], youth: true, extra: { 'organisation.democraticStructure': true, 'organisation.memberOfSportsFederation': true }, budget: 25_000_000 }) },
  { id: 'P27', name: 'Grön Energi AB, klimatinvestering', story: 'Företag som vill investera i utsläppsminskande teknik.', ...projectFacts({ who: 'company', sector: 'environment', activities: ['investment'], extra: { 'project.reducesEmissions': true, 'project.investmentNotStarted': true }, budget: 500_000_000 }) },
  { id: 'P28', name: 'Ung Röst, förening för ungas organisering', story: 'Nationell ungdomsförening: demokratisk, 60 % unga medlemmar, flera län.', ...projectFacts({ who: 'association', sector: 'civil_society', activities: ['development'], youth: true, extra: { 'organisation.democraticStructure': true, 'organisation.youthMembersShareOver60': true, 'organisation.hasNationalSpread': true }, budget: 40_000_000 }) },
  { id: 'P29', name: 'Kollektivet Norr, informell kulturgrupp', story: 'Dansgrupp utan organisationsnummer, ej yrkesverksamma.', ...projectFacts({ who: 'informal_group', artist: false, sector: 'culture', activities: ['performance'], budget: 5_000_000 }) },
  { id: 'P30', name: 'Sundby kommun, energiprojekt', story: 'Kommun som vill söka stöd för lokal klimatinvestering.', ...projectFacts({ who: 'municipality', sector: 'environment', activities: ['investment'], extra: { 'project.reducesEmissions': true }, budget: 1_000_000_000 }) },
];

// ── API-hjälpare ─────────────────────────────────────────────────────────────
async function call(cookie, method, path, body) {
  const res = await fetch(BASE + path, {
    method,
    headers: { ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}), ...(cookie ? { cookie } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const setCookies = res.headers.getSetCookie?.() ?? [];
  const json = await res.json().catch(() => ({}));
  return { status: res.status, json, setCookies };
}

const results = [];
const anomalies = [];
const stamp = Date.now();

for (const p of PERSONAS) {
  const r = { id: p.id, name: p.name, story: p.story, track: p.budget ? 'projekt' : 'personligt' };
  try {
    // 1. Konto (auth-endpointen är rate-limitad till 10/min — riktiga
    // användare kommer inte i 30-pack från samma IP; simuleringen backar av).
    let reg;
    for (let attempt = 0; attempt < 4; attempt++) {
      reg = await call(null, 'POST', '/v1/auth/register', {
        email: `sim-${p.id.toLowerCase()}-${stamp}-${attempt}@test.example`, password: 'simulerat-losenord-123', displayName: p.name.split(',')[0],
      });
      if (reg.status === 201) break;
      if (reg.status === 429) { console.log(`  (rate limit — väntar 65 s före ${p.id})`); await new Promise((res) => setTimeout(res, 65_000)); }
      else throw new Error(`register ${reg.status}`);
    }
    if (reg.status !== 201) throw new Error('register: rate limit kvarstod');
    const cookie = reg.setCookies.filter((c) => c.startsWith('bidrag_access=')).map((c) => c.split(';')[0]).join('; ');

    // 2. Profil + projekt (fakta exakt som intaget bygger dem)
    const prof = await call(cookie, 'POST', '/v1/profiles', {
      kind: p.type === 'individual' ? 'person' : 'organisation', displayName: p.name.split(',')[0],
      applicantType: p.type, country: 'SE', facts: p.facts,
    });
    const proj = await call(cookie, 'POST', '/v1/projects', {
      profileId: prof.json.profile.id,
      title: p.track === 'projekt' ? p.story.slice(0, 60) : 'Min situation',
      intent: p.story,
      ...(p.budget ? { totalBudgetMinor: p.budget } : {}),
      facts: p.facts,
    });
    const projectId = proj.json.project.id;
    await call(cookie, 'POST', `/v1/projects/${projectId}/matches`, {});

    // 3. Open Discovery — den fria upptäckten.
    //
    // Kontrollen var tidigare INVERTERAD: den flaggade myndighetsnamn,
    // stödnamn och sourceUrl som "TEASERLÄCKA", ett arv från den borttagna
    // 39 kr-betalväggen. Under Open Discovery är det tvärtom KRAVET att de
    // syns gratis (docs/PRODUCT_DOCTRINE.md; tools/doctrine.mjs vaktar det).
    // Nu kontrolleras rätt sak: att den fria vyn faktiskt bär värdet.
    const oppen = await call(cookie, 'GET', `/v1/projects/${projectId}/matches`);
    r.teaser = { total: oppen.json.total, counts: oppen.json.counts, excluded: oppen.json.excludedCount };
    const oppenRaw = JSON.stringify(oppen.json);
    const rader = oppen.json.matches ?? [];
    if (rader.length > 0) {
      if (!rader.some((m) => typeof m.title === 'string' && m.title.length > 0)) {
        anomalies.push(`${p.id}: OPEN DISCOVERY — matchning utan stödnamn`);
      }
      if (!rader.some((m) => typeof m.sourceUrl === 'string' && m.sourceUrl.startsWith('https://'))) {
        anomalies.push(`${p.id}: OPEN DISCOVERY — ingen officiell källänk i den fria vyn`);
      }
    }
    for (const betalvagg of ['Lås upp din bidragsanalys', 'analysis-unlock', '39 kr']) {
      if (oppenRaw.includes(betalvagg)) anomalies.push(`${p.id}: BETALVÄGG FÖRE VÄRDE "${betalvagg}"`);
    }

    // 4. Analysen — SAMMA vy som den fria upptäckten.
    //
    // Här låg tidigare ett anrop till POST /v1/projects/:id/analysis-unlock
    // följt av en mock-betalning. Den endpointen finns inte längre (404):
    // 39 kr-upplåsningen togs bort med Open Discovery. Anropet misslyckades
    // tyst och simuleringen påstod ändå att den mätte en "upplåst" analys.
    // Under Open Discovery ÄR den fria vyn analysen — inget steg emellan.
    const matches = rader;
    // Speglar serverns kalibrerade likelihoodOf: viktat kriterium som fallerar ⇒ "möjlig".
    const lik = (m) => {
      if (m.eligibilityStatus !== 'eligible') return m.eligibilityStatus === 'unknown' ? 'utreds' : 'utesluten';
      if (m.result.confidence !== 'high') return 'möjlig';
      return (m.result.explanation ?? []).some((e) => e.kind === 'weighted' && e.outcome === 'fail') ? 'möjlig' : 'hög';
    };
    r.eligibleHigh = matches.filter((m) => lik(m) === 'hög').map((m) => m.title.split(' — ').pop());
    r.eligiblePossible = matches.filter((m) => lik(m) === 'möjlig').map((m) => m.title.split(' — ').pop());
    r.needsInfo = matches.filter((m) => lik(m) === 'utreds').length;
    r.excluded = matches.filter((m) => lik(m) === 'utesluten').length;
    r.questions = [...new Set(matches.filter((m) => m.eligibilityStatus !== 'excluded').flatMap((m) => m.result.missingFacts.map((f) => f.question)))];

    // Rimlighetskontroller på frågor
    const qs = r.questions.join(' | ');
    const emp = p.facts['person.employmentStatus'];
    if ((emp === 'working' || emp === 'retired' || emp === 'self_employed') && qs.includes('arbetssökande')) {
      anomalies.push(`${p.id}: AF-frågan ställd till ${emp}`);
    }
    if (p.facts['person.age66Plus'] && qs.toLowerCase().includes('studier som stärker')) anomalies.push(`${p.id}: studiefråga till pensionär`);
    if (r.track === 'personligt' && (r.eligibleHigh.length + r.eligiblePossible.length + r.needsInfo) === 0) anomalies.push(`${p.id}: NOLL relevanta resultat`);

    // 6. Följdfrågor (de personor som definierat svar)
    if (p.followUps) {
      const before = r.eligibleHigh.length + r.eligiblePossible.length;
      await call(cookie, 'PATCH', `/v1/projects/${projectId}`, { facts: p.followUps });
      await call(cookie, 'POST', `/v1/projects/${projectId}/matches`, {});
      const after = await call(cookie, 'GET', `/v1/projects/${projectId}/matches`);
      const am = after.json.matches ?? [];
      const eligibleAfter = am.filter((m) => m.eligibilityStatus === 'eligible').map((m) => m.title.split(' — ').pop());
      r.followUp = { answered: Object.keys(p.followUps), eligibleBefore: before, eligibleAfter: eligibleAfter.length, newlyEligible: eligibleAfter.filter((t) => !r.eligibleHigh.includes(t) && !r.eligiblePossible.includes(t)) };
    }

    // 7. Dokumentköp + generering (utvalda personor)
    if (p.buyDocs) {
      const pack = await call(cookie, 'POST', `/v1/projects/${projectId}/document-pack`, { pack: p.buyDocs, immediateDeliveryConsent: true });
      await call(cookie, 'POST', `/v1/payments/${pack.json.paymentId}/mock-confirm`);
      const docs = [];
      for (const spec of [p.docAnswers, p.docAnswers2].filter(Boolean)) {
        const gen = await call(cookie, 'POST', `/v1/projects/${projectId}/generated-documents`, spec);
        if (gen.status !== 201) { anomalies.push(`${p.id}: dokumentgenerering ${gen.status}`); continue; }
        const dl = await fetch(`${BASE}/v1/generated-documents/${gen.json.document.id}/download?format=pdf`, { headers: { cookie } });
        const buf = new Uint8Array(await dl.arrayBuffer());
        const pdfOk = dl.headers.get('content-type')?.includes('pdf') && buf[0] === 0x25 && buf[1] === 0x50;
        if (!pdfOk) anomalies.push(`${p.id}: PDF ogiltig`);
        docs.push({ title: gen.json.document.title, pdfOk, chars: gen.json.document.content.length });
      }
      r.documents = { pack: p.buyDocs, created: docs };
    }

    // 8. Kvitton
    const purchases = await call(cookie, 'GET', '/v1/purchases');
    r.purchases = purchases.json.purchases.filter((x) => x.state === 'confirmed').map((x) => ({ kind: x.kind, amount: x.amountMinor / 100, receipt: x.receiptNumber }));
    r.spentKr = r.purchases.reduce((s, x) => s + x.amount, 0);
    r.ok = true;
  } catch (err) {
    r.ok = false;
    r.error = String(err);
    anomalies.push(`${p.id}: KRASCH ${err}`);
  }
  results.push(r);
  console.log(`${p.id} ${r.ok ? '✓' : '✗'} ${p.name} — 🟢${r.eligibleHigh?.length ?? '?'} 🟡${r.eligiblePossible?.length ?? '?'} ⚪${r.needsInfo ?? '?'} · ${r.spentKr ?? 0} kr`);
}

// Aggregat
const personal = results.filter((r) => r.track === 'personligt' && r.ok);
const agg = {
  totalUsers: results.length,
  succeeded: results.filter((r) => r.ok).length,
  totalRevenueKr: results.reduce((s, r) => s + (r.spentKr ?? 0), 0),
  avgHighPersonal: (personal.reduce((s, r) => s + r.eligibleHigh.length, 0) / personal.length).toFixed(1),
  avgPossiblePersonal: (personal.reduce((s, r) => s + r.eligiblePossible.length, 0) / personal.length).toFixed(1),
  zeroResultUsers: results.filter((r) => r.ok && (r.eligibleHigh.length + r.eligiblePossible.length + r.needsInfo) === 0).map((r) => r.id),
  documentsCreated: results.reduce((s, r) => s + (r.documents?.created.length ?? 0), 0),
  anomalies,
};
await writeFile(OUT, JSON.stringify({ results, agg }, null, 2));
console.log('\n══ AGGREGAT ══');
console.log(JSON.stringify(agg, null, 2));
