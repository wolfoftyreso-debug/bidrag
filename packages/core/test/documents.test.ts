/**
 * Dokumentmotorn: villkorade frågor, validering, deterministisk rendering,
 * och regeln att tomma fält utelämnas i stället för att gissas.
 */
import { describe, expect, it } from 'vitest';
import { DOCUMENT_TEMPLATES, getTemplate, prefillAnswers, renderDocument, validateDocumentAnswers, visibleQuestions } from '../src/index.js';

const ctx = { recipient: 'Socialtjänsten i Norrköping', opportunityTitle: 'Försörjningsstöd', date: '2026-08-16' };

describe('document template engine', () => {
  it('ships the four generic templates with valid structure', () => {
    expect(DOCUMENT_TEMPLATES.map((t) => t.key)).toEqual([
      'ansokan-ekonomiskt-stod',
      'bilaga-ekonomisk-situation',
      'behovsbeskrivning',
      'sarskilda-omstandigheter',
    ]);
    for (const t of DOCUMENT_TEMPLATES) {
      expect(t.questions.length).toBeGreaterThan(2);
      expect(t.sections.length).toBeGreaterThan(1);
    }
  });

  it('conditional questions appear only when their condition is met', () => {
    const t = getTemplate('ansokan-ekonomiskt-stod')!;
    const withoutChildren = visibleQuestions(t, { hasChildren: false }).map((q) => q.key);
    expect(withoutChildren).not.toContain('childrenCount');
    const withChildren = visibleQuestions(t, { hasChildren: true }).map((q) => q.key);
    expect(withChildren).toContain('childrenCount');
  });

  it('validation lists missing required answers by label', () => {
    const t = getTemplate('behovsbeskrivning')!;
    const v = validateDocumentAnswers(t, { fullName: 'Anna Ek' });
    expect(v.ok).toBe(false);
    expect(v.missing.map((m) => m.key)).toContain('needWhat');
  });

  it('renders deterministically, omits unanswered lines, and never claims decisions', () => {
    const t = getTemplate('behovsbeskrivning')!;
    const answers = {
      fullName: 'Anna Ek', whoFor: 'barn', childName: 'Vera, 9 år',
      needWhat: 'Avgift och utrustning för fotboll under höstterminen.',
      needWhy: 'Utan stödet kan Vera inte fortsätta i laget tillsammans med sina klasskamrater.',
    };
    const doc = renderDocument(t, answers, ctx);
    expect(doc.text).toContain('BESKRIVNING AV BEHOV');
    expect(doc.text).toContain('Vera, 9 år');
    expect(doc.text).not.toContain('Ungefärlig kostnad'); // obesvarat ⇒ utelämnat, aldrig gissat
    expect(doc.text).toContain('Slutlig bedömning görs alltid av mottagande myndighet');
    expect(renderDocument(t, answers, ctx).text).toBe(doc.text); // deterministisk
  });

  it('refuses to render with missing required answers', () => {
    const t = getTemplate('ansokan-ekonomiskt-stod')!;
    expect(() => renderDocument(t, { fullName: 'X' }, ctx)).toThrow(/Obligatoriska svar saknas/);
  });

  it('boolean answers render as Ja/Nej', () => {
    const t = getTemplate('bilaga-ekonomisk-situation')!;
    const doc = renderDocument(t, { fullName: 'Anna Ek', costHousing: 8500, savings: false }, ctx);
    expect(doc.text).toContain('Sparade medel/tillgångar: Nej');
  });

  it('numbers render with Swedish thousands grouping and decimal comma', () => {
    const t = getTemplate('bilaga-ekonomisk-situation')!;
    const doc = renderDocument(
      t,
      { fullName: 'Anna Ek', costHousing: 9250, incomeBenefits: 14200, incomeOther: 950, costDebts: 1800.5, savings: false },
      ctx,
    );
    // Hårt mellanslag som tusentalsavgränsare — beloppet radbryts aldrig mitt i.
    expect(doc.text).toContain('Boende: 9 250 kr');
    expect(doc.text).toContain('Ersättningar och bidrag: 14 200 kr');
    expect(doc.text).toContain('Övrigt: 950 kr'); // under 1000 grupperas inte
    expect(doc.text).toContain('Skulder/avbetalningar: 1 800,5 kr');
    // Användarens egen text skrivs aldrig om.
    const t2 = getTemplate('sarskilda-omstandigheter')!;
    const doc2 = renderDocument(t2, { fullName: 'A', circumstance: 'hyra 11250 kr', impact: 'x' }, ctx);
    expect(doc2.text).toContain('hyra 11250 kr');
  });
});

describe('förifyllnad — färdigifyllda dokument ur intaget', () => {
  const facts = {
    'person.householdType': 'alone',
    'person.hasChildrenAtHome': true,
    'person.housingCostMonthly': 9250,
    'person.limitedSavings': true,
  };

  it('maps only what the system actually knows', () => {
    const pf = prefillAnswers('ansokan-ekonomiskt-stod', { displayName: 'Åsa Öström', municipality: 'Härnösand', facts });
    expect(pf).toEqual({ fullName: 'Åsa Öström', municipality: 'Härnösand', householdAdults: 1, hasChildren: true });
    // Adress och fritext gissas aldrig.
    expect(pf).not.toHaveProperty('address');
    expect(pf).not.toHaveProperty('whatFor');
  });

  it('mirrors limited savings into the assets question and copies housing cost', () => {
    const pf = prefillAnswers('bilaga-ekonomisk-situation', { displayName: 'Åsa', municipality: null, facts });
    expect(pf.costHousing).toBe(9250);
    expect(pf.savings).toBe(false);
  });

  it('leaves household size empty when the intake answer does not imply a count', () => {
    const pf = prefillAnswers('ansokan-ekonomiskt-stod', {
      displayName: 'X',
      municipality: null,
      facts: { 'person.householdType': 'other' },
    });
    expect(pf).not.toHaveProperty('householdAdults');
    const partner = prefillAnswers('ansokan-ekonomiskt-stod', {
      displayName: 'X',
      municipality: null,
      facts: { 'person.householdType': 'partner' },
    });
    expect(partner.householdAdults).toBe(2);
  });

  it('every template gets name and municipality, nothing fabricated beyond that', () => {
    for (const key of ['behovsbeskrivning', 'sarskilda-omstandigheter']) {
      const pf = prefillAnswers(key, { displayName: 'N', municipality: 'Umeå', facts });
      expect(pf).toEqual({ fullName: 'N', municipality: 'Umeå' });
    }
  });
});
