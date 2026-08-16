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
  age: 'under20' | '20-28' | '29-65' | '66plus';
  employment: 'working' | 'unemployed' | 'sick' | 'studying' | 'retired';
  capacity: boolean;
  income: 'under15' | '15-25' | '25-40' | 'over40';
  savings: boolean;
  paysHousing: boolean;
}>;

/** Speglar intagshärledningarna i Onboarding/demo — hålls i synk medvetet. */
function personalFacts(a: Answers): Facts {
  const f: Facts = { 'applicant.country': 'SE', 'applicant.type': 'individual' };
  if (a.household) f['person.householdType'] = a.household;
  if (a.children) f['person.hasChildrenAtHome'] = a.children !== 'no';
  if (a.separated !== undefined) f['person.separatedParent'] = a.separated;
  if (a.age) {
    f['person.ageBand'] = a.age;
    f['person.ageUnder29'] = a.age === 'under20' || a.age === '20-28';
    f['person.age66Plus'] = a.age === '66plus';
    if (a.age === 'under20' || a.age === '20-28') f['person.age40OrYounger'] = true;
    if (a.age === '66plus') f['person.age40OrYounger'] = false;
  }
  if (a.employment) {
    f['person.employmentStatus'] = a.employment;
    if (a.employment === 'studying') f['person.isOrPlansStudying'] = true;
    f['person.receivesPension'] = a.employment === 'retired';
    f['person.registeredUnemployed'] = a.employment === 'unemployed';
  }
  if (a.capacity !== undefined) f['person.reducedWorkCapacityLongTerm'] = a.capacity;
  if (a.income) {
    f['person.lowHouseholdIncome'] = a.income === 'under15' || a.income === '15-25';
    if (a.income === 'under15') f['person.incomeInsufficientForBasicNeeds'] = true;
    if (a.income === 'over40') f['person.incomeInsufficientForBasicNeeds'] = false;
  }
  if (a.savings !== undefined) f['person.limitedSavings'] = a.savings;
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
