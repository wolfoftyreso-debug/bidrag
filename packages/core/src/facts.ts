/**
 * Härledda personfakta — EN källa för hela systemet.
 *
 * Bakgrund (revision 2026-09-01, PERFECTION_BACKLOG M15): härledningen av
 * åldersfakta ur födelseår låg kopierad på fyra ställen (webb, demo,
 * simulate30, gendocs) med kommentaren "håll dem i synk!", och faktavägen
 * `person.ageUnder29` var överlastad — bostadsbidrag unga prövar 18–28 och
 * aktivitetsersättning prövar 19–29, men båda läste samma boolean
 * (`age <= 28`). En 29-åring uteslöts därför felaktigt från
 * aktivitetsersättning, och en 18-åring passerade den felaktigt.
 *
 * Regeln: ett kriterium som prövar ett åldersspann ska peka på ett faktum
 * som betyder EXAKT det spannet. Nya kriterier ska aldrig använda
 * `person.ageUnder29`; det finns kvar enbart för redan lagrade profiler.
 */
export interface AgeFacts {
  'person.ageYears': number;
  /** 18–28 år inklusive — bostadsbidrag för unga (Försäkringskassan). */
  'person.age18to28': boolean;
  /** 19–29 år inklusive — aktivitetsersättning (Försäkringskassan). */
  'person.age19to29': boolean;
  /** @deprecated Överlastad (18–28 OCH 19–29 läste den). Behålls för gamla profiler. */
  'person.ageUnder29': boolean;
  'person.age24Plus': boolean;
  'person.age40OrYounger': boolean;
  'person.age60Plus': boolean;
  'person.age62Plus': boolean;
  'person.age66Plus': boolean;
  'person.age67Plus': boolean;
  'person.ageBand': 'under20' | '20-28' | '29-65' | '66plus';
}

/** Det år personen fyller X räknas som X — samma regel som intagen alltid haft. */
export function ageFromBirthYear(birthYear: number, now: Date = new Date()): number {
  return now.getFullYear() - birthYear;
}

export function deriveAgeFacts(age: number): AgeFacts {
  return {
    'person.ageYears': age,
    'person.age18to28': age >= 18 && age <= 28,
    'person.age19to29': age >= 19 && age <= 29,
    'person.ageUnder29': age <= 28,
    'person.age24Plus': age >= 24,
    'person.age40OrYounger': age <= 40,
    'person.age60Plus': age >= 60,
    'person.age62Plus': age >= 62,
    'person.age66Plus': age >= 66,
    'person.age67Plus': age >= 67,
    'person.ageBand': age < 20 ? 'under20' : age <= 28 ? '20-28' : age <= 65 ? '29-65' : '66plus',
  };
}
