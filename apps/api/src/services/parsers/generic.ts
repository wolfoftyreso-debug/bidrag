/**
 * Deterministisk extraktion ur källinnehåll (§24). Ingen ML, inga nätanrop:
 * regex-baserad igenkänning av svenska datum, belopp, deadlinefraser och
 * länkar. Osäkerhet är synlig — varje extraktion bär sitt textbevis, och
 * ingenting publiceras utan mänsklig granskning.
 */

export interface ExtractedDate {
  /** ISO-datum (YYYY-MM-DD). */
  iso: string;
  /** Exakt textbevis ur källan. */
  evidence: string;
  /** Står datumet i ett deadlinesammanhang? */
  nearDeadlinePhrase: boolean;
}

export interface ExtractedAmount {
  /** Belopp i ören. */
  amountMinor: number;
  evidence: string;
}

export interface ExtractedLink {
  href: string;
  text: string;
}

export interface ParsedSource {
  text: string;
  dates: ExtractedDate[];
  amounts: ExtractedAmount[];
  links: ExtractedLink[];
  deadlinePhrases: string[];
}

const MONTHS: Record<string, number> = {
  januari: 1, februari: 2, mars: 3, april: 4, maj: 5, juni: 6,
  juli: 7, augusti: 8, september: 9, oktober: 10, november: 11, december: 12,
};

const DEADLINE_WORDS = /sista ansökningsdag|ansök senast|senast den|stänger|sista dag|ansökningsperioden|deadline|öppnar/i;

export function htmlToText(html: string): string {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&auml;|&#228;/g, 'ä')
    .replace(/&aring;|&#229;/g, 'å')
    .replace(/&ouml;|&#246;/g, 'ö')
    .replace(/\s+/g, ' ')
    .trim();
}

function pad(n: number): string {
  return String(n).padStart(2, '0');
}

/** Kontext runt en träff — används som bevis och för deadlinenärhet. */
function contextAround(text: string, index: number, length: number, radius = 60): string {
  const start = Math.max(0, index - radius);
  const end = Math.min(text.length, index + length + radius);
  return text.slice(start, end).trim();
}

export function extractDates(text: string): ExtractedDate[] {
  const out = new Map<string, ExtractedDate>();

  // "24 september 2026" / "den 24 september 2026"
  const written = /\b(\d{1,2})\s+(januari|februari|mars|april|maj|juni|juli|augusti|september|oktober|november|december)\s+(\d{4})\b/gi;
  for (const m of text.matchAll(written)) {
    const day = Number(m[1]);
    const month = MONTHS[m[2]!.toLowerCase()]!;
    const year = Number(m[3]);
    if (day < 1 || day > 31) continue;
    const iso = `${year}-${pad(month)}-${pad(day)}`;
    const evidence = contextAround(text, m.index!, m[0].length);
    out.set(iso, { iso, evidence, nearDeadlinePhrase: DEADLINE_WORDS.test(evidence) });
  }

  // "2026-09-24"
  const isoRe = /\b(\d{4})-(\d{2})-(\d{2})\b/g;
  for (const m of text.matchAll(isoRe)) {
    const year = Number(m[1]);
    const month = Number(m[2]);
    const day = Number(m[3]);
    if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1 || day > 31) continue;
    const iso = `${m[1]}-${m[2]}-${m[3]}`;
    if (out.has(iso)) continue;
    const evidence = contextAround(text, m.index!, m[0].length);
    out.set(iso, { iso, evidence, nearDeadlinePhrase: DEADLINE_WORDS.test(evidence) });
  }

  return [...out.values()].sort((a, b) => a.iso.localeCompare(b.iso));
}

export function extractAmounts(text: string): ExtractedAmount[] {
  const out = new Map<number, ExtractedAmount>();

  // "50 000 kr", "50 000 kronor", "1,5 miljoner kronor", "2 mnkr"
  const plain = /\b(\d{1,3}(?:[  ]\d{3})+|\d+)\s*(kr|kronor)\b/gi;
  for (const m of text.matchAll(plain)) {
    const amount = Number(m[1]!.replace(/[  ]/g, ''));
    if (!Number.isFinite(amount) || amount < 100) continue; // brus: "5 kr"-nivåer ointressant
    const minor = amount * 100;
    if (!out.has(minor)) out.set(minor, { amountMinor: minor, evidence: contextAround(text, m.index!, m[0].length, 40) });
  }

  const millions = /\b(\d+(?:[.,]\d+)?)\s*(miljoner?|mnkr|mkr)\s*(kronor|kr)?\b/gi;
  for (const m of text.matchAll(millions)) {
    const amount = Number(m[1]!.replace(',', '.')) * 1_000_000;
    const minor = Math.round(amount * 100);
    if (!out.has(minor)) out.set(minor, { amountMinor: minor, evidence: contextAround(text, m.index!, m[0].length, 40) });
  }

  return [...out.values()].sort((a, b) => a.amountMinor - b.amountMinor);
}

export function extractLinks(html: string): ExtractedLink[] {
  const out: ExtractedLink[] = [];
  const seen = new Set<string>();
  const re = /<a\b[^>]*href=["']([^"'#]+)["'][^>]*>([\s\S]*?)<\/a>/gi;
  for (const m of html.matchAll(re)) {
    const href = m[1]!.trim();
    const text = htmlToText(m[2]!);
    if (!text || text.length < 3) continue;
    if (/^(javascript|mailto|tel):/i.test(href)) continue;
    const key = `${href}|${text}`;
    if (seen.has(key)) continue;
    seen.add(key);
    out.push({ href, text });
  }
  return out;
}

export function extractDeadlinePhrases(text: string): string[] {
  const phrases: string[] = [];
  const re = new RegExp(DEADLINE_WORDS.source, 'gi');
  for (const m of text.matchAll(re)) {
    phrases.push(contextAround(text, m.index!, m[0].length, 70));
  }
  return [...new Set(phrases)].slice(0, 20);
}

export const PARSER_VERSION = 'generic-sv@1';

export function parseSource(content: string, contentType: string | null): ParsedSource {
  const isHtml = (contentType ?? '').includes('html') || /<[a-z][\s\S]*>/i.test(content.slice(0, 2000));
  const text = isHtml ? htmlToText(content) : content;
  return {
    text,
    dates: extractDates(text),
    amounts: extractAmounts(text),
    links: isHtml ? extractLinks(content) : [],
    deadlinePhrases: extractDeadlinePhrases(text),
  };
}
