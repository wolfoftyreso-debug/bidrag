/**
 * Consistency engine v1 (§11–12): sifferpåståenden korsjämförs över fält —
 * samma storhet med olika värden flaggas, monetära belopp undantas, och
 * samma värde på flera ställen är konsekvent (ingen flagga).
 */
import { describe, expect, it } from 'vitest';
import { extractNumericClaims, findNumericConflicts, isValidSwedishOrgNumber } from '../src/index.js';

describe('konsistensmotorn', () => {
  it('detects the 500/450/600 participant conflict across fields', () => {
    const conflicts = findNumericConflicts({
      sammanfattning: 'Projektet når 500 deltagare genom öppna klasser.',
      plan: 'Planen omfattar 450 deltagare under residenset.',
      budgetmotiv: 'Budgeten är dimensionerad för 600 deltagare.',
    });
    expect(conflicts).toHaveLength(1);
    expect(conflicts[0]!.unit).toBe('deltagare');
    expect(conflicts[0]!.values.map((v) => v.value).sort((a, b) => a - b)).toEqual([450, 500, 600]);
    expect(conflicts[0]!.message).toContain('deltagare');
  });

  it('is consistent when the same figure appears everywhere', () => {
    expect(
      findNumericConflicts({
        a: 'Vi når 500 deltagare.',
        b: 'Alla 500 deltagare erbjuds uppföljning.',
      }),
    ).toEqual([]);
  });

  it('exempts monetary amounts — different cost lines are legitimate', () => {
    expect(
      findNumericConflicts({
        a: 'Resan kostar 12 000 kr.',
        b: 'Boendet kostar 8 500 kr och traktamentet 1 850 kr.',
      }),
    ).toEqual([]);
  });

  it('parses thousand-separated numbers and percentages', () => {
    const claims = extractNumericClaims({ a: 'Vi når 1 850 ungdomar, en ökning med 60 procent.' });
    expect(claims).toContainEqual(expect.objectContaining({ value: 1850, unit: 'ungdomar' }));
    expect(claims).toContainEqual(expect.objectContaining({ value: 60, unit: 'procent' }));

    const conflicts = findNumericConflicts({
      a: 'Målet är 60 procent deltagande.',
      b: 'Vi räknar med 45 procent deltagande.',
    });
    expect(conflicts.some((c) => c.unit === 'procent')).toBe(true);
  });

  it('ignores non-string answers and generic units', () => {
    expect(findNumericConflicts({ n: 42, b: true, t: 'Vi ses 3 gånger per år, sedan 4 gånger.' })).toEqual([]);
  });

  it('validates Swedish organisation numbers with the Luhn check digit', () => {
    expect(isValidSwedishOrgNumber('556016-0680')).toBe(true); // giltig kontrollsiffra
    expect(isValidSwedishOrgNumber('5560160680')).toBe(true); // format utan bindestreck
    expect(isValidSwedishOrgNumber('556016-0681')).toBe(false); // fel kontrollsiffra
    expect(isValidSwedishOrgNumber('55601-0680')).toBe(false); // för kort
    expect(isValidSwedishOrgNumber('inte ett nummer')).toBe(false);
  });
});
