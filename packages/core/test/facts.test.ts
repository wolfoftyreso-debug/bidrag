import { describe, expect, it } from 'vitest';
import { ageFromBirthYear, deriveAgeFacts } from '../src/facts.js';

describe('deriveAgeFacts — gränserna som M15 handlade om', () => {
  it('18–28 och 19–29 är två olika fakta, inte en boolean', () => {
    expect(deriveAgeFacts(17)['person.age18to28']).toBe(false);
    expect(deriveAgeFacts(18)['person.age18to28']).toBe(true);
    expect(deriveAgeFacts(28)['person.age18to28']).toBe(true);
    expect(deriveAgeFacts(29)['person.age18to28']).toBe(false);

    expect(deriveAgeFacts(18)['person.age19to29']).toBe(false); // en 18-åring passerade felaktigt förut
    expect(deriveAgeFacts(19)['person.age19to29']).toBe(true);
    expect(deriveAgeFacts(29)['person.age19to29']).toBe(true); // en 29-åring uteslöts felaktigt förut
    expect(deriveAgeFacts(30)['person.age19to29']).toBe(false);
  });

  it('övriga gränser är oförändrade mot intagens tidigare härledning', () => {
    const f = deriveAgeFacts(66);
    expect(f['person.age60Plus']).toBe(true);
    expect(f['person.age62Plus']).toBe(true);
    expect(f['person.age66Plus']).toBe(true);
    expect(f['person.age67Plus']).toBe(false);
    expect(f['person.ageBand']).toBe('66plus');
    expect(deriveAgeFacts(19)['person.ageBand']).toBe('under20');
    expect(deriveAgeFacts(20)['person.ageBand']).toBe('20-28');
    expect(deriveAgeFacts(40)['person.age40OrYounger']).toBe(true);
    expect(deriveAgeFacts(41)['person.age40OrYounger']).toBe(false);
  });

  it('åldern räknas som det år personen fyller', () => {
    expect(ageFromBirthYear(2000, new Date('2026-01-01'))).toBe(26);
    expect(ageFromBirthYear(2000, new Date('2026-12-31'))).toBe(26);
  });
});
