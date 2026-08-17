/**
 * PDF-typografin: breddbaserad radbrytning mot Helveticas verkliga
 * teckenbredder, hårdbrytning av överlånga ord, strukturmedveten sättning
 * (fet titel/rubriker, nedtonad meta och disclaimer, sidfot) och giltig,
 * deterministisk PDF-struktur.
 */
import { describe, expect, it } from 'vitest';
import { textToPdf, textWidth, wrapToWidth } from '../src/services/pdf.ts';

const CONTENT_W = 595.28 - 2 * 56;

describe('breddbaserad radbrytning', () => {
  it('no wrapped line ever exceeds the content width', () => {
    const texts = [
      'MMMMW WWWM MMW '.repeat(40), // breda versaler bryts tidigare …
      'illil jilt itil '.repeat(120), // … än smala gemener
      'Efter separationen i våras har hela ansvaret för barnens ekonomi legat på mig — åäöÅÄÖé. '.repeat(10),
    ];
    for (const text of texts) {
      for (const line of wrapToWidth(text, 10.5, false, CONTENT_W)) {
        expect(textWidth(line, 10.5, false)).toBeLessThanOrEqual(CONTENT_W + 0.01);
      }
    }
  });

  it('narrow glyphs pack more characters per line than wide ones', () => {
    const wide = wrapToWidth('M'.repeat(400), 10.5, false, CONTENT_W);
    const narrow = wrapToWidth('i'.repeat(400), 10.5, false, CONTENT_W);
    expect(narrow.length).toBeLessThan(wide.length);
  });

  it('an overlong word without spaces is hard-broken at the width limit', () => {
    const word = 'X'.repeat(300);
    const lines = wrapToWidth(`Referens: ${word} slut`, 10.5, false, CONTENT_W);
    expect(lines.length).toBeGreaterThan(2);
    for (const line of lines) expect(textWidth(line, 10.5, false)).toBeLessThanOrEqual(CONTENT_W + 0.01);
    expect(lines.join('')).toContain('slut');
  });

  it('hard newlines in answers are preserved as line breaks', () => {
    expect(wrapToWidth('rad ett\nrad två', 10.5, false, CONTENT_W)).toEqual(['rad ett', 'rad två']);
  });
});

describe('textToPdf', () => {
  const body = [
    'ANSÖKAN OM EKONOMISKT STÖD',
    'Avser: Teststöd',
    'Till: Kommunen',
    'Datum: 2026-08-16',
    '',
    'SÖKANDE',
    'Åsa Öström-Ekelöf',
    '',
    'MOTIVERING',
    'Ett stycke med åäö, "citat", tankstreck – och minus −2,5.',
    '—',
    'Dokumentet är förberett med stöd av Bidragskoll.se.',
  ].join('\n');

  it('is deterministic and structurally valid', () => {
    const a = textToPdf('Ansökan om ekonomiskt stöd', body);
    const b = textToPdf('Ansökan om ekonomiskt stöd', body);
    expect(a.equals(b)).toBe(true);
    const s = a.toString('latin1');
    expect(s.startsWith('%PDF-1.4')).toBe(true);
    expect(s).toContain('%%EOF');
    // xref-offseten pekar på rätt ställe.
    const startxref = Number(/startxref\n(\d+)/.exec(s)![1]);
    expect(s.slice(startxref, startxref + 4)).toBe('xref');
  });

  it('uses bold Helvetica for title/headings and prints page numbers', () => {
    const s = textToPdf('Ansökan om ekonomiskt stöd', body).toString('latin1');
    expect(s).toContain('/Helvetica-Bold');
    expect(s).toContain('/F2 16 Tf'); // titeln i fetstil
    expect(s).toContain('/F2 11 Tf'); // sektionsrubrik i fetstil
    expect(s).toContain('(Sida 1 av 1)');
  });

  it('replaces the mathematical minus and never emits "?" for it', () => {
    const s = textToPdf('T', 'styrka −2,5').toString('latin1');
    expect(s).toContain('styrka -2,5');
  });

  it('paginates long documents and numbers every page', () => {
    const long = Array.from({ length: 40 }, (_, i) => `RUBRIK ${i + 1}\n${'Stycketext som fyller raden med vanligt innehåll och lite till. '.repeat(4)}\n`).join('\n');
    const s = textToPdf('Långt dokument', long).toString('latin1');
    const pageCount = Number(/\/Count (\d+)/.exec(s)![1]);
    expect(pageCount).toBeGreaterThan(1);
    for (let p = 1; p <= pageCount; p++) expect(s).toContain(`(Sida ${p} av ${pageCount})`);
  });
});
