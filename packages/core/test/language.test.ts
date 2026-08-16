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

describe('findPeriodConflicts — claim propagation för projektperioden (§9)', async () => {
  const { findPeriodConflicts } = await import('../src/index.js');
  const period = { start: '2026-10-01', end: '2026-11-14' };

  it('flags months mentioned outside the period, with field and snippet', () => {
    const c = findPeriodConflicts(
      { plan: 'Residenset genomförs i januari med två föreställningar.', ovrigt: 'Redovisning sker i november.' },
      period,
    );
    expect(c).toHaveLength(1);
    expect(c[0]).toMatchObject({ month: 'januari', fieldKey: 'plan' });
  });

  it('stays silent when all months fall inside the period, and for year-long periods', () => {
    expect(findPeriodConflicts({ plan: 'Start i oktober, avslut i november.' }, period)).toEqual([]);
    expect(findPeriodConflicts({ plan: 'Aktiviteter i mars och juli.' }, { start: '2026-01-01', end: '2026-12-31' })).toEqual([]);
  });

  it('handles periods spanning a year boundary', () => {
    const winter = { start: '2026-12-01', end: '2027-02-28' };
    expect(findPeriodConflicts({ plan: 'Uppstart i december, avslut i februari.' }, winter)).toEqual([]);
    expect(findPeriodConflicts({ plan: 'Turné i juni.' }, winter)).toHaveLength(1);
  });

  it('an impossible period yields no month flags (the order error is reported separately)', () => {
    expect(findPeriodConflicts({ plan: 'I januari.' }, { start: '2026-11-01', end: '2026-10-01' })).toEqual([]);
  });

  it('checks exact ISO dates at day precision', () => {
    // Perioden är 2026-10-01–2026-11-14: 2026-11-20 är i rätt "månadszon" men
    // efter slutdatumet — bara dagprecision fångar det.
    expect(findPeriodConflicts({ plan: 'Föreställningen ges 2026-11-20.' }, period)).toHaveLength(1);
    expect(findPeriodConflicts({ plan: 'Slutredovisning lämnas 2027-03-01.' }, period)).toHaveLength(1);
    expect(findPeriodConflicts({ plan: 'Avresa 2026-10-02.' }, period)).toEqual([]);
  });

  it('checks "14 oktober"-style dates, year-boundary aware, without double-flagging the month', () => {
    // Dag + månad utan år: godtas om något av periodens år placerar datumet i perioden.
    expect(findPeriodConflicts({ plan: 'Premiär 14 oktober.' }, period)).toEqual([]);
    const c = findPeriodConflicts({ plan: 'Premiär 14 januari.' }, period);
    expect(c).toHaveLength(1); // EN flagga — inte en för datumet och en för månadsnamnet
    expect(c[0]!.month).toBe('14 januari');
    // Årsskiftesperiod: "5 februari" hör till periodens andra år.
    const winter = { start: '2026-12-01', end: '2027-02-28' };
    expect(findPeriodConflicts({ plan: 'Avslutning 5 februari.' }, winter)).toEqual([]);
    // Med explicit år jämförs exakt: rätt dag men fel år är en konflikt.
    expect(findPeriodConflicts({ plan: 'Avslutning 5 februari 2028.' }, winter)).toHaveLength(1);
  });

  it('a full-year period silences month names but still checks explicit dates', () => {
    const year = { start: '2026-01-01', end: '2026-12-31' };
    expect(findPeriodConflicts({ plan: 'Aktiviteter i mars och november.' }, year)).toEqual([]);
    expect(findPeriodConflicts({ plan: 'Konferens 2027-05-01.' }, year)).toHaveLength(1);
  });
});
