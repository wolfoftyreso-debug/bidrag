/**
 * Ödmjukhetsprotokollet (§12) + zero-bullshit (§13): flaggar, skriver aldrig
 * om, och tiger när texten redan är saklig.
 */
import { describe, expect, it } from 'vitest';
import { answerLanguageFindings, humilityFindings } from '../src/index.js';

describe('humilityFindings — §12 superlativ', () => {
  it('flags each term on the avoid-list with a concrete suggestion', () => {
    const text =
      'Vår revolutionerande metod är unik i Sverige. Vi garanterar full effekt. Ingen annan gör detta idag.';
    const kinds = humilityFindings(text);
    const terms = kinds.map((f) => f.term.toLowerCase());
    expect(terms).toContain('revolutionerande');
    expect(terms).toContain('unik');
    expect(terms).toContain('garanterar');
    expect(terms).toContain('ingen annan gör');
    for (const f of kinds) {
      expect(f.kind).toBe('SUPERLATIVE');
      expect(f.suggestion.length).toBeGreaterThan(20);
      expect(f.excerpt.length).toBeLessThanOrEqual(140);
    }
  });

  it('stays silent on sober, hedged language', () => {
    const text =
      'Projektet bedöms kunna nå 60 deltagare per termin. Erfarenheten hittills visar att öppna klasser sänker tröskeln. Målet är att verksamheten bärs av medlemsavgifter från år 2.';
    expect(humilityFindings(text)).toEqual([]);
  });

  it('does not flag "kommunikation" or other words containing substrings', () => {
    expect(humilityFindings('Vi arbetar med kommunikation och garderober.')).toEqual([]);
  });
});

describe('humilityFindings — §13 absoluta utfallslöften', () => {
  it('flags a quantified future promise and suggests goal-framing', () => {
    const f = humilityFindings('Projektet kommer att skapa 500 arbetstillfällen.');
    expect(f).toHaveLength(1);
    expect(f[0]!.kind).toBe('ABSOLUTE_CLAIM');
    expect(f[0]!.suggestion).toContain('mål');
  });

  it('leaves unquantified future tense alone — normal Swedish is not a claim', () => {
    expect(humilityFindings('Klasserna kommer att genomföras under våren.')).toEqual([]);
    // Siffra men inget utfallsverb: också ok.
    expect(humilityFindings('Projektet kommer att pågå i 12 månader.')).toEqual([]);
  });

  it('is deterministic', () => {
    const text = 'Vi kommer att öka antalet aktiva till 60.';
    expect(humilityFindings(text)).toEqual(humilityFindings(text));
  });
});

describe('answerLanguageFindings — skannar bara fritext', () => {
  it('maps findings to field keys and skips non-strings', () => {
    const found = answerLanguageFindings({
      problem: 'Vår unika metod löser detta.',
      budgetTotal: 500000,
      hasIndicator: true,
      goal: 'Fler unga deltar regelbundet.',
    });
    expect(found).toHaveLength(1);
    expect(found[0]!.fieldKey).toBe('problem');
  });
});
