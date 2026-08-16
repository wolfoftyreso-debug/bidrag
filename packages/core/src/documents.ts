/**
 * Document Template Engine (§produktsteg 3): generisk motor som förvandlar
 * frågesvar till färdiga, strukturerade dokument — ansökningar, bilagor,
 * behovsbeskrivningar, intyg. En mall beskriver frågor (med villkor) och
 * sektioner; motorn validerar svaren och renderar deterministisk text.
 *
 * Ren domänlogik: ingen I/O, ingen PDF — rendering till PDF/nedladdning är
 * API-lagrets ansvar. Samma motor bär alla dokumenttyper; nya stöd får nya
 * mallar, aldrig ny kod.
 */

export type DocFieldType = 'text' | 'textarea' | 'number' | 'boolean' | 'select' | 'date';

export interface DocQuestion {
  key: string;
  label: string;
  type: DocFieldType;
  required?: boolean;
  options?: { value: string; label: string }[];
  /** Hjälptext under frågan. */
  guidance?: string;
  /** Ställs bara när ett tidigare svar matchar. */
  showIf?: { key: string; equals: unknown };
}

export interface DocSection {
  title: string;
  /**
   * Radmallar. {{key}} ersätts med svaret; rader där ALLA platshållare är
   * obesvarade utelämnas — dokumentet ljuger aldrig med tomma fält.
   */
  lines: string[];
  /** Sektionen tas bara med när villkoret är uppfyllt. */
  showIf?: { key: string; equals: unknown };
}

export interface DocumentTemplate {
  key: string;
  title: string;
  /** Vem dokumentet är ställt till — myndighet/organisation fylls i vid rendering. */
  recipientLabel: string;
  description: string;
  questions: DocQuestion[];
  sections: DocSection[];
}

export type DocAnswers = Record<string, unknown>;

export function visibleQuestions(t: DocumentTemplate, answers: DocAnswers): DocQuestion[] {
  return t.questions.filter((q) => !q.showIf || answers[q.showIf.key] === q.showIf.equals);
}

export interface DocValidation {
  ok: boolean;
  missing: { key: string; label: string }[];
}

export function validateDocumentAnswers(t: DocumentTemplate, answers: DocAnswers): DocValidation {
  const missing = visibleQuestions(t, answers)
    .filter((q) => q.required)
    .filter((q) => {
      const v = answers[q.key];
      return v === undefined || v === null || v === '' || (q.type === 'boolean' && typeof v !== 'boolean');
    })
    .map((q) => ({ key: q.key, label: q.label }));
  return { ok: missing.length === 0, missing };
}

const PLACEHOLDER = /\{\{([a-zA-Z0-9_.]+)\}\}/g;

/**
 * Belopp och antal sätts med svensk tusentalsgruppering (hårt mellanslag så
 * att "14 200" aldrig radbryts mitt i) och decimalkomma: 14200 → "14 200",
 * 2.5 → "2,5". Text lämnas orörd — motorn skriver aldrig om användarens ord.
 */
function formatNumberSv(n: number): string {
  const neg = n < 0;
  const [int, dec] = String(Math.abs(n)).split('.');
  const grouped = int!.replace(/\B(?=(\d{3})+(?!\d))/g, '\u00A0');
  return `${neg ? '-' : ''}${grouped}${dec ? `,${dec}` : ''}`;
}

function formatValue(v: unknown): string {
  if (typeof v === 'boolean') return v ? 'Ja' : 'Nej';
  if (typeof v === 'number' && Number.isFinite(v)) return formatNumberSv(v);
  if (v === undefined || v === null) return '';
  return String(v);
}

/** En rad tas med om den saknar platshållare eller om minst en är besvarad. */
function renderLine(line: string, answers: DocAnswers): string | null {
  let sawPlaceholder = false;
  let sawValue = false;
  const out = line.replace(PLACEHOLDER, (_m, key: string) => {
    sawPlaceholder = true;
    const v = answers[key];
    if (v !== undefined && v !== null && v !== '') sawValue = true;
    return formatValue(v);
  });
  if (sawPlaceholder && !sawValue) return null;
  return out;
}

export interface RenderedDocument {
  title: string;
  recipient: string;
  paragraphs: { heading: string | null; text: string }[];
  /** Ren text — deterministisk, för lagring/PDF/nedladdning. */
  text: string;
}

export function renderDocument(
  t: DocumentTemplate,
  answers: DocAnswers,
  ctx: { recipient: string; opportunityTitle: string; date: string; applicantName?: string },
): RenderedDocument {
  const validation = validateDocumentAnswers(t, answers);
  if (!validation.ok) {
    throw new Error(`Obligatoriska svar saknas: ${validation.missing.map((m) => m.label).join(', ')}`);
  }
  const enriched: DocAnswers = {
    ...answers,
    _recipient: ctx.recipient,
    _opportunity: ctx.opportunityTitle,
    _date: ctx.date,
    _applicant: ctx.applicantName ?? '',
  };

  const paragraphs: { heading: string | null; text: string }[] = [];
  for (const s of t.sections) {
    if (s.showIf && enriched[s.showIf.key] !== s.showIf.equals) continue;
    const lines = s.lines.map((l) => renderLine(l, enriched)).filter((l): l is string => l !== null && l.trim() !== '');
    if (lines.length === 0) continue;
    paragraphs.push({ heading: s.title || null, text: lines.join('\n') });
  }

  // Dokumentet är SÖKANDENS handling till myndigheten — ingen verktygsreklam
  // och inga friskrivningar här. Produktens ansvarstexter hör hemma i
  // gränssnittet där dokumentet skapas, aldrig i det som lämnas in.
  const text = [
    t.title.toUpperCase(),
    `Avser: ${ctx.opportunityTitle}`,
    `Till: ${ctx.recipient}`,
    `Datum: ${ctx.date}`,
    '',
    ...paragraphs.flatMap((p) => [...(p.heading ? [p.heading.toUpperCase()] : []), p.text, '']),
  ].join('\n').trimEnd();

  return { title: t.title, recipient: ctx.recipient, paragraphs, text };
}
