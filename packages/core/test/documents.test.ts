/**
 * Dokumentmotorn: villkorade frågor, validering, deterministisk rendering,
 * och regeln att tomma fält utelämnas i stället för att gissas.
 */
import { describe, expect, it } from 'vitest';
import { DOCUMENT_TEMPLATES, getTemplate, renderDocument, validateDocumentAnswers, visibleQuestions } from '../src/index.js';

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
});
