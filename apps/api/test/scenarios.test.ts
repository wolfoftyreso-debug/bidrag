/**
 * Scenariomatris: tolv personor genom den riktiga motorn och kunskapsbasen.
 * Varje persona har förväntningar på (a) vad som ska se aktuellt ut,
 * (b) vad som ska uteslutas, och (c) att inga meningslösa frågor ställs
 * (t.ex. "är du inskriven som arbetssökande?" till den som arbetar).
 * Fakta byggs exakt som intaget bygger dem — sviten låser därmed både
 * regler, intagshärledningar och frågekontext.
 */
import { describe, expect, it } from 'vitest';
import { computeMatch, type CriterionDef, type EvidenceRequirement, type Facts } from '@bidrag/core';
import { opportunities } from '../src/seed/data.ts';

type Answers = Partial<{
  household: 'alone' | 'partner' | 'other';
  children: 'yes' | 'shared' | 'no';
  separated: boolean;
  childSchool: 'grundskola' | 'gymnasiet' | 'both' | 'none';
  childCostsStrain: boolean;
  childMissedLeisure: boolean;
  childNeedsGlasses: boolean;
  childTravelHard: boolean;
  age: 'under20' | '20-28' | '29-65' | '66plus';
  employment: 'working' | 'unemployed' | 'sick' | 'studying' | 'retired' | 'self_employed';
  capacity: boolean;
  income: 'under15' | '15-25' | '25-40' | 'over40';
  savings: boolean;
  limitedSavings: boolean;
  paysHousing: boolean;
  movingAbroad: boolean;
  disabilityInFamily: boolean;
}>;

/** Speglar intagshärledningarna i Onboarding/demo — hålls i synk medvetet. */
function personalFacts(a: Answers): Facts {
  const f: Facts = { 'applicant.country': 'SE', 'applicant.type': 'individual' };
  if (a.household) f['person.householdType'] = a.household;
  if (a.children) f['person.hasChildrenAtHome'] = a.children !== 'no';
  if (a.separated !== undefined) f['person.separatedParent'] = a.separated;
  f['person.consideringMovingAbroad'] = a.movingAbroad ?? false;
  f['person.disabilityOrLongTermIllnessInFamily'] = a.disabilityInFamily ?? false;
  if (a.age) {
    // Speglar födelseårshärledningen i Onboarding/demo: bandet mappas till en
    // representativ ålder och därur härleds exakta tröskelfakta (M11-stängningen).
    const repAge = a.age === 'under20' ? 18 : a.age === '20-28' ? 24 : a.age === '29-65' ? 45 : 68;
    f['person.ageYears'] = repAge;
    f['person.ageBand'] = a.age;
    f['person.ageUnder29'] = repAge <= 28;
    f['person.age40OrYounger'] = repAge <= 40;
    f['person.age60Plus'] = repAge >= 60;
    f['person.age62Plus'] = repAge >= 62;
    f['person.age66Plus'] = repAge >= 66;
    f['person.age67Plus'] = repAge >= 67;
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
    if (a.childSchool === 'grundskola' || a.childSchool === 'both') {
      f['person.childSchoolDistanceQualifies'] = a.childTravelHard;
    }
    if (!a.childTravelHard) {
      f['person.childSchoolDistanceQualifies'] = false;
      f['person.childGymnasiumLongTravel'] = false;
    }
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
    f['person.lowHouseholdIncome'] = a.income === 'under15' || a.income === '15-25';
    if (a.income === 'under15') f['person.incomeInsufficientForBasicNeeds'] = true;
    if (a.income === 'over40') f['person.incomeInsufficientForBasicNeeds'] = false;
  }
  if (a.savings !== undefined) f['person.limitedSavings'] = a.savings;
  if (a.limitedSavings !== undefined) f['person.limitedSavings'] = a.limitedSavings;
  if (a.paysHousing !== undefined) f['person.paysHousingCost'] = a.paysHousing;
  return f;
}

function projectFacts(p: {
  who: string;
  artist?: boolean;
  sector: string;
  activities?: string[];
  international?: boolean;
  knowledge?: boolean;
  youth?: boolean;
  extra?: Facts;
}): Facts {
  return {
    'applicant.country': 'SE',
    'applicant.type': p.who,
    ...(p.artist !== undefined ? { 'person.professionalArtist': p.artist } : {}),
    'project.sector': p.sector,
    'project.activityTypes': p.activities ?? [],
    'project.targetGroups': [...(p.youth ? ['youth'] : []), 'professionals'],
    ...(p.international !== undefined ? { 'project.hasInternationalComponent': p.international } : {}),
    ...(p.knowledge !== undefined ? { 'project.bringsKnowledgeBack': p.knowledge } : {}),
    ...p.extra,
  };
}

const REF = '2026-08-14T00:00:00Z';

function run(facts: Facts) {
  const bySlug = new Map<string, ReturnType<typeof computeMatch>>();
  for (const o of opportunities) {
    bySlug.set(
      o.slug,
      computeMatch({
        criteria: o.criteria as CriterionDef[],
        facts,
        evidenceRequirements: o.evidenceRequirements as EvidenceRequirement[],
        availableEvidenceKinds: [],
        referenceDate: REF,
        deadline: o.closesAt,
        estimatedEffortDays: o.estimatedEffortDays,
      }),
    );
  }
  return bySlug;
}

function allQuestions(r: Map<string, ReturnType<typeof computeMatch>>): string[] {
  return [...r.values()]
    .filter((m) => m.eligibilityStatus !== 'excluded')
    .flatMap((m) => m.missingFacts.map((f) => f.question));
}

describe('scenariomatris — personliga situationer', () => {
  it('1. Ensamstående arbetslös förälder, 29–65, 15–25 tkr, hyra', () => {
    const r = run(personalFacts({ household: 'alone', children: 'yes', separated: true, age: '29-65', employment: 'unemployed', income: '15-25', paysHousing: true }));
    expect(r.get('fk-bostadsbidrag-barnfamiljer')!.eligibilityStatus).toBe('eligible');
    expect(r.get('fk-bostadsbidrag-unga')!.eligibilityStatus).toBe('excluded');
    expect(r.get('pm-aldreforsorjningsstod')!.eligibilityStatus).toBe('excluded');
    expect(r.get('af-stod-start-naringsverksamhet')!.eligibilityStatus).toBe('unknown'); // arbetslös → relevant fråga
    // Underhållsstöd väntar bara på underhållsfrågan.
    expect(r.get('fk-underhallsstod')!.missingFacts.map((f) => f.question)).toEqual([
      'Betalar den andra föräldern inget eller mindre än fullt underhåll?',
    ]);
  });

  it('2. Student 20–28 utan barn, under 15 tkr, hyra', () => {
    const r = run(personalFacts({ household: 'other', children: 'no', age: '20-28', employment: 'studying', income: 'under15', savings: true, paysHousing: true }));
    expect(r.get('fk-bostadsbidrag-unga')!.eligibilityStatus).toBe('eligible');
    expect(r.get('csn-studiemedel')!.eligibilityStatus).toBe('eligible');
    expect(r.get('kommun-forsorjningsstod')!.eligibilityStatus).toBe('eligible');
    expect(r.get('fk-bostadsbidrag-barnfamiljer')!.eligibilityStatus).toBe('excluded'); // inga barn
    // Ingen fråga om arbetssökande till en student.
    expect(allQuestions(r).join(' ')).not.toContain('arbetssökande');
  });

  it('3. Pensionär 66+, mycket låg pension, hyra', () => {
    const r = run(personalFacts({ household: 'alone', children: 'no', age: '66plus', employment: 'retired', income: 'under15', savings: true, paysHousing: true }));
    expect(r.get('pm-bostadstillagg')!.eligibilityStatus).toBe('eligible');
    expect(r.get('pm-aldreforsorjningsstod')!.missingFacts.map((f) => f.question)).toEqual([
      'Har du svårt att klara dig på din pension och dina övriga inkomster?',
    ]);
    expect(r.get('fk-aktivitetsersattning')!.eligibilityStatus).toBe('excluded'); // ålder
    expect(r.get('jordbruksverket-startstod-unga')!.eligibilityStatus).toBe('excluded'); // 40+-gränsen härledd ur 66+
  });

  it('4. Sjukskriven 20–28 med långvarigt nedsatt arbetsförmåga', () => {
    const r = run(personalFacts({ household: 'partner', children: 'no', age: '20-28', employment: 'sick', capacity: true, income: '15-25', paysHousing: true }));
    expect(r.get('fk-aktivitetsersattning')!.eligibilityStatus).toBe('eligible');
    expect(r.get('fk-bostadsbidrag-unga')!.eligibilityStatus).toBe('eligible');
  });

  it('5. Arbetande hushåll med god inkomst: inga falska positiva, inga onödiga frågor', () => {
    const r = run(personalFacts({ household: 'partner', children: 'yes', separated: false, age: '29-65', employment: 'working', income: 'over40', paysHousing: true }));
    expect(r.get('fk-bostadsbidrag-barnfamiljer')!.eligibilityStatus).toBe('excluded'); // inkomst
    expect(r.get('kommun-forsorjningsstod')!.eligibilityStatus).toBe('excluded');      // härledd över40
    expect(r.get('fk-underhallsstod')!.eligibilityStatus).toBe('excluded');            // ej separerad
    const qs = allQuestions(r).join(' ');
    expect(qs).not.toContain('arbetssökande');
    expect(qs).not.toContain('mest nödvändiga');
    // Omställningsstudiestödet är däremot en helt rimlig fråga för en arbetande.
    expect(r.get('csn-omstallningsstudiestod')!.eligibilityStatus).toBe('unknown');
  });

  it('6. Ung under 20 som varken studerar eller arbetar', () => {
    const r = run(personalFacts({ household: 'other', children: 'no', age: 'under20', employment: 'unemployed', income: 'under15', savings: true, paysHousing: false }));
    expect(r.get('fk-bostadsbidrag-unga')!.eligibilityStatus).toBe('excluded'); // betalar inget boende
    expect(r.get('kommun-forsorjningsstod')!.eligibilityStatus).toBe('eligible');
    expect(r.get('af-stod-start-naringsverksamhet')!.eligibilityStatus).toBe('unknown');
  });

  it('6b. Barnspåret: förälder som tackat nej till skolutflykt öppnar stöd hen inte visste fanns', () => {
    // Arbetande förälder med ok-inkomst — skulle ALDRIG själv söka på "bidrag".
    // Upptäcktsfrågan (skolutflykten) + glasögonfrågan öppnar tre stödspår.
    const r = run(personalFacts({
      household: 'partner', children: 'yes', separated: false,
      childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: true, childTravelHard: true,
      age: '29-65', employment: 'working', income: '25-40', paysHousing: true,
    }));
    expect(r.get('majblomman-bidrag-barn')!.eligibilityStatus).toBe('eligible');
    expect(r.get('region-glasogonbidrag-barn')!.eligibilityStatus).toBe('eligible');
    expect(r.get('kommun-skolskjuts')!.eligibilityStatus).toBe('eligible');
    // Gymnasiestöden är korrekt uteslutna — barnet går i grundskolan.
    expect(r.get('kommun-elevresor-gymnasiet')!.eligibilityStatus).toBe('excluded');
    // Och inkomstprövade stöd blandas inte in i onödan: bostadsbidraget
    // utesluts på inkomsten, inte visas som falskt hopp.
    expect(r.get('fk-bostadsbidrag-barnfamiljer')!.eligibilityStatus).toBe('excluded');
  });

  it('6c. Barnspåret: fritidsaktivitets-frågan räcker ensam för Majblomman', () => {
    const r = run(personalFacts({
      household: 'alone', children: 'shared', separated: true,
      childSchool: 'gymnasiet', childCostsStrain: false, childMissedLeisure: true, childNeedsGlasses: false, childTravelHard: true,
      age: '29-65', employment: 'working', income: '15-25', paysHousing: true,
    }));
    expect(r.get('majblomman-bidrag-barn')!.eligibilityStatus).toBe('eligible');
    expect(r.get('region-glasogonbidrag-barn')!.eligibilityStatus).toBe('excluded'); // behöver inga glasögon
    expect(r.get('kommun-skolskjuts')!.eligibilityStatus).toBe('excluded'); // inget barn i grundskolan
    // Gymnasiet + besvärlig resväg: sexkilometersvillkoret är medvetet en
    // följdfråga (kommunens exakta villkor) — inte en gissning.
    const elevresor = r.get('kommun-elevresor-gymnasiet')!;
    expect(elevresor.eligibilityStatus).toBe('unknown');
    expect(elevresor.missingFacts.some((f) => f.question.includes('sex kilometer'))).toBe(true);
  });

  it('6d. Egenföretagare med barn: "driver eget" är en datapunkt, inte en kategori', () => {
    const r = run(personalFacts({
      household: 'partner', children: 'yes', separated: false,
      childSchool: 'grundskola', childCostsStrain: true, childNeedsGlasses: false, childTravelHard: false,
      age: '29-65', employment: 'self_employed', income: '15-25', paysHousing: true,
    }));
    // Familjespåren öppnas oavsett företagandet…
    expect(r.get('majblomman-bidrag-barn')!.eligibilityStatus).toBe('eligible');
    expect(r.get('fk-bostadsbidrag-barnfamiljer')!.eligibilityStatus).toBe('eligible');
    // …och egenföretagaren får inte AF-frågan om att vara inskriven arbetssökande.
    const questions = allQuestions(r);
    expect(questions.some((q) => q.includes('arbetssökande'))).toBe(false);
  });

  it('13. Utvandringsspåret: gated bakom upptäcktsfrågan — tyst för alla andra', () => {
    // Utan uttalad flyttfundering: alla tre utlandsstöden är uteslutna och tysta.
    const base = run(personalFacts({ household: 'alone', children: 'no', age: '20-28', employment: 'working', income: '25-40', paysHousing: true }));
    expect(base.get('csn-utlandsstudier')!.eligibilityStatus).toBe('excluded');
    expect(base.get('af-eures-targeted-mobility')!.eligibilityStatus).toBe('excluded');
    expect(base.get('migrationsverket-atervandringsbidrag')!.eligibilityStatus).toBe('excluded');
    expect(allQuestions(base).some((q) => q.includes('utomlands') || q.includes('ursprungsland'))).toBe(false);

    // Med flyttfundering: spåret öppnas med riktiga följdfrågor.
    const moving = run(personalFacts({ household: 'alone', children: 'no', age: '20-28', employment: 'studying', income: 'under15', limitedSavings: true, paysHousing: true, movingAbroad: true }));
    expect(moving.get('csn-utlandsstudier')!.eligibilityStatus).toBe('unknown');
    const qs = allQuestions(moving);
    expect(qs.some((q) => q.includes('studera utomlands'))).toBe(true);
    expect(qs.some((q) => q.includes('EU- eller EES-land'))).toBe(true);
  });

  it('14. Funktionsnedsättningsspåret: gated bakom upptäcktsfrågan — tyst för alla andra', () => {
    // Utan funktionsnedsättning/sjukdom i familjen: de tre funktionsnedsättnings-
    // grindade stöden uteslutna och tysta.
    const base = run(personalFacts({ household: 'partner', children: 'yes', separated: false, age: '29-65', employment: 'working', income: '25-40', paysHousing: true }));
    for (const slug of ['fk-omvardnadsbidrag', 'fk-merkostnadsersattning', 'fk-bilstod']) {
      expect(base.get(slug)!.eligibilityStatus, slug).toBe('excluded');
    }
    // Red team RT03-F1: närståendepenning gäller vård av en svårt sjuk anhörig,
    // inte funktionsnedsättning i familjen — den får INTE döljas av ett nej på
    // funktionsnedsättningsfrågan, utan förblir synlig med sin egen följdfråga.
    expect(base.get('fk-narstaendepenning')!.eligibilityStatus).toBe('unknown');
    expect(allQuestions(base).some((q) => q.includes('hot mot livet'))).toBe(true);
    expect(allQuestions(base).some((q) => q.includes('funktionsnedsättning') || q.includes('omvårdnad'))).toBe(false);

    // Med ja på upptäcktsfrågan: spåret öppnas med riktiga följdfrågor.
    const open = run(personalFacts({ household: 'partner', children: 'yes', separated: false, age: '29-65', employment: 'working', income: '25-40', paysHousing: true, disabilityInFamily: true }));
    expect(open.get('fk-omvardnadsbidrag')!.eligibilityStatus).toBe('unknown');
    expect(open.get('fk-narstaendepenning')!.eligibilityStatus).toBe('unknown');
    const qs = allQuestions(open);
    expect(qs.some((q) => q.includes('mer omvårdnad eller tillsyn'))).toBe(true);
    expect(qs.some((q) => q.includes('hot mot livet'))).toBe(true);
    expect(qs.some((q) => q.includes('buss och tåg'))).toBe(true);
  });

  it('15. Nyanländspåret: en gemensam upptäcktsfråga avgör etableringsersättning och hemutrustningslån', () => {
    const r = run(personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'unemployed', income: 'under15', savings: true, paysHousing: true }));
    // Båda stöden väntar på samma gate-fråga — en fråga, två stöd avgjorda.
    expect(r.get('af-etableringsersattning')!.eligibilityStatus).toBe('unknown');
    expect(r.get('csn-hemutrustningslan')!.eligibilityStatus).toBe('unknown');
    const gateQ = 'Har du under de senaste åren fått uppehållstillstånd i Sverige, t.ex. som skyddsbehövande eller som anhörig?';
    expect(r.get('af-etableringsersattning')!.missingFacts.some((f) => f.question === gateQ)).toBe(true);
    expect(r.get('csn-hemutrustningslan')!.missingFacts.some((f) => f.question === gateQ)).toBe(true);

    // Studiestartsstödet är också en arbetslöshetsfråga — öppet med följdfrågor.
    expect(r.get('csn-studiestartsstod')!.eligibilityStatus).toBe('unknown');

    // Den som arbetar ser inget av detta.
    const working = run(personalFacts({ household: 'alone', children: 'no', age: '29-65', employment: 'working', income: '25-40', paysHousing: true }));
    expect(working.get('af-etableringsersattning')!.eligibilityStatus).toBe('excluded');
    expect(working.get('csn-studiestartsstod')!.eligibilityStatus).toBe('excluded');
  });
});

describe('scenariomatris — projekt och verksamheter', () => {
  it('7. Dansaren med Jamaicaprojektet', () => {
    const r = run(projectFacts({ who: 'individual', artist: true, sector: 'culture', activities: ['exchange', 'training'], international: true, knowledge: true }));
    expect(r.get('kulturradet-internationellt-resebidrag-musik')!.eligibilityStatus).toBe('eligible');
    expect(r.get('konstnarsnamnden-internationellt-kulturutbyte')!.eligibilityStatus).toBe('eligible');
    expect(r.get('erasmus-plus-ungdomsutbyten')!.eligibilityStatus).toBe('excluded'); // privatperson
    expect(r.get('vinnova-innovativa-startups')!.eligibilityStatus).toBe('excluded');
  });

  it('8. Idrottsförening med barnverksamhet', () => {
    const r = run(projectFacts({ who: 'association', sector: 'sports', activities: ['development'], international: false, youth: true, extra: { 'organisation.memberOfSportsFederation': true } }));
    expect(r.get('rf-lok-stod')!.eligibilityStatus).toBe('eligible');
    expect(r.get('arvsfonden-projektstod')!.eligibilityStatus).toBe('unknown'); // nyskapande + delaktighet återstår
    expect(r.get('rf-lok-stod')!.score).toBeGreaterThan(80);
  });

  it('9. Företag som vill göra en klimatinvestering', () => {
    const r = run(projectFacts({ who: 'company', sector: 'environment', activities: ['investment'], international: false, extra: { 'project.measurableEnvironmentalImpact': true } }));
    expect(r.get('naturvardsverket-klimatklivet')!.eligibilityStatus).toBe('eligible');
    expect(r.get('naturvardsverket-ladda-bilen-organisationer')!.eligibilityStatus).toBe('eligible');
    expect(r.get('rf-lok-stod')!.eligibilityStatus).toBe('excluded');
    expect(r.get('kommun-forsorjningsstod')!.eligibilityStatus).toBe('excluded'); // fel sökandetyp
  });

  it('10. Kommun som vill stärka skolbibliotek och kultur i skolan', () => {
    const r = run(projectFacts({ who: 'municipality', sector: 'culture', activities: ['development'], international: false, youth: true, extra: { 'organisation.isSchoolAuthority': true, 'project.usesProfessionalCulture': true, 'project.concernsLibraries': true } }));
    expect(r.get('kulturradet-skapande-skola')!.eligibilityStatus).toBe('eligible');
    expect(r.get('kulturradet-inkopsstod-bibliotek')!.eligibilityStatus).toBe('eligible');
  });

  it('11. Ung jordbrukare som tar över gården', () => {
    const r = run(projectFacts({ who: 'individual', artist: false, sector: 'agriculture', activities: ['investment', 'development'], international: false, extra: { 'person.age40OrYounger': true, 'project.startingOrTakingOverFarm': true } }));
    expect(r.get('jordbruksverket-startstod-unga')!.eligibilityStatus).toBe('eligible');
    expect(r.get('jordbruksverket-investeringsstod')!.eligibilityStatus).toBe('eligible');
    expect(r.get('kulturradet-internationellt-resebidrag-musik')!.eligibilityStatus).toBe('excluded'); // ej kulturutövare
  });

  it('12. Förening som planerar ungdomsutbyte i Europa', () => {
    const r = run(projectFacts({ who: 'association', sector: 'youth', activities: ['exchange'], international: true, youth: true, extra: { 'organisation.hasOid': true, 'project.hasPartnerGroupAbroad': true, 'project.participantsAge13to30': true, 'project.durationDays5to21': true } }));
    expect(r.get('erasmus-plus-ungdomsutbyten')!.eligibilityStatus).toBe('eligible');
    expect(r.get('erasmus-ka2-smaskaliga-partnerskap')!.eligibilityStatus).toBe('eligible');
    expect(r.get('mucf-solidaritetskaren-volontarprojekt')!.eligibilityStatus).toBe('unknown'); // Quality Label + 18–30 återstår
  });
});

describe('frågetydlighet — strukturella regler', () => {
  it('inga negerade huvudsatser i ja/nej-frågor (förtydliganden i parentes/tankstreck är ok)', () => {
    for (const o of opportunities) {
      for (const c of o.criteria as CriterionDef[]) {
        if (!c.intakeQuestion) continue;
        // "Är verksamheten professionell (inte amatörverksamhet)?" är tydlig —
        // negation i själva huvudfrågan ("Är X inte påbörjad?") är det inte:
        // då blir Ja/Nej tvetydigt. Lintern prövar bara huvudsatsen.
        const mainClause = c.intakeQuestion
          .replace(/\([^)]*\)/g, '')
          .replace(/\s[—–-]\s.*$/, '')
          .replace(/,.*$/, '');
        expect(mainClause, `${o.slug}:${c.id}: negerad huvudsats — Ja/Nej blir tvetydigt: "${c.intakeQuestion}"`).not.toMatch(/\b(inte|aldrig|uteblir)\b/i);
        expect(c.intakeQuestion.endsWith('?'), `${o.slug}:${c.id} ska sluta med frågetecken`).toBe(true);
      }
    }
  });

  it('alla obligatoriska kriterier har en ställbar fråga', () => {
    for (const o of opportunities) {
      for (const c of o.criteria as CriterionDef[]) {
        if (c.kind === 'mandatory') {
          expect(c.intakeQuestion, `${o.slug}:${c.id}`).toBeTruthy();
          expect(c.intakeQuestion!.length, `${o.slug}:${c.id}`).toBeGreaterThan(10);
        }
      }
    }
  });
});
