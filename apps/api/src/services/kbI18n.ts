/**
 * I18N fas B: leverans av kunskapsbasens texter på användarens språk.
 *
 * Översättningsminnet bor i tabellen kb_translations, nycklat på den svenska
 * KÄLLTEXTEN. Det gör fallbacken självreglerande och ärlig: om källtexten
 * ändras (t.ex. via kuratorsflödet) missar uppslaget och svenskan visas tills
 * översättningen är uppdaterad — hellre rätt på svenska än fel på målspråket.
 *
 * Språket väljs av klienten via Accept-Language (webben skickar exakt den
 * språkkod användaren valt i språkväljaren). Okänd/svensk kod ⇒ ingen
 * översättning. Cachen laddas per språk och process — innehållet ändras bara
 * vid seed/deploy, så ingen TTL behövs i serverless-livscykeln.
 */
import { eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { kbTranslations } from '../db/schema.ts';
import { KB_LOCALES, type KbLocale } from '../seed/i18n/index.ts';

const cache = new Map<KbLocale, Map<string, string>>();

/** Accept-Language → produktspråkkod, eller null för svenska/okänt. */
export function resolveKbLocale(header: string | undefined): KbLocale | null {
  if (!header) return null;
  // Webben skickar en exakt kod ('so', 'ar', 'prs' …); ta första taggens
  // primärspråk så att även en vanlig webbläsarlista ('uk-UA,uk;q=0.9') träffar.
  const primary = header.split(',')[0]?.trim().split(';')[0]?.split('-')[0]?.toLowerCase() ?? '';
  return (KB_LOCALES as readonly string[]).includes(primary) ? (primary as KbLocale) : null;
}

async function tableFor(locale: KbLocale): Promise<Map<string, string>> {
  const hit = cache.get(locale);
  if (hit) return hit;
  const rows = await db
    .select({ sourceText: kbTranslations.sourceText, translatedText: kbTranslations.translatedText })
    .from(kbTranslations)
    .where(eq(kbTranslations.locale, locale));
  const map = new Map(rows.map((r) => [r.sourceText, r.translatedText]));
  cache.set(locale, map);
  return map;
}

export type KbTranslate = (text: string) => string;

/** Översättare för ett språk: exakt träff eller ärlig svensk fallback. */
export async function kbTranslator(locale: KbLocale | null): Promise<KbTranslate> {
  if (!locale) return (text) => text;
  const table = await tableFor(locale);
  return (text) => table.get(text) ?? text;
}

/** Testbarhet: töm processcachen (t.ex. efter omseedning i testsvit). */
export function clearKbI18nCache(): void {
  cache.clear();
}

type QuestionFact = { question: string };
type MatchResultish = { missingFacts?: QuestionFact[]; answeredFacts?: QuestionFact[] };

/** Översätt intakefrågorna i matchrader utan att röra övrig struktur. */
export function translateMatchRows<T extends { result: MatchResultish }>(rows: T[], tr: KbTranslate): T[] {
  return rows.map(
    (row) =>
      ({
        ...row,
        result: {
          ...row.result,
          missingFacts: row.result.missingFacts?.map((f) => ({ ...f, question: tr(f.question) })),
          answeredFacts: row.result.answeredFacts?.map((f) => ({ ...f, question: tr(f.question) })),
        },
      }) as T,
  );
}

/** Översätt kriteriers intakeQuestion OCH villkorstext (fas D). */
export function translateCriteria<T>(criteria: T, tr: KbTranslate): T {
  if (!Array.isArray(criteria)) return criteria;
  return criteria.map((c) => {
    if (!c || typeof c !== 'object') return c;
    const row = c as { intakeQuestion?: unknown; description?: unknown };
    const out: Record<string, unknown> = { ...(c as object) };
    if (typeof row.intakeQuestion === 'string') out.intakeQuestion = tr(row.intakeQuestion);
    if (typeof row.description === 'string') out.description = tr(row.description);
    return out;
  }) as T;
}

/** Översätt underlagslistans beskrivningar (fas D). Bilagetypen (kind) rörs inte. */
export function translateEvidence<T>(evidence: T, tr: KbTranslate): T {
  if (!Array.isArray(evidence)) return evidence;
  return evidence.map((e) =>
    e && typeof e === 'object' && typeof (e as { description?: unknown }).description === 'string'
      ? { ...e, description: tr((e as { description: string }).description) }
      : e,
  ) as T;
}

/**
 * Översätt ett ansökningsschemas VISADE text (fas D): formulärets titel,
 * sektionsrubriker, fältetiketter och vägledning.
 *
 * Rör aldrig key, canonicalKey, type, validering eller villkorslogik — och
 * används ENDAST på presentationsvägen. Motorn (validering, förifyllnad,
 * dokumentrendering) och textförslagen kör alltid mot det svenska schemat:
 * ansökan som lämnas till myndigheten förblir svensk (I18N_PROGRAM §3).
 */
export function translateSchemaDef<T>(def: T, tr: KbTranslate): T {
  if (!def || typeof def !== 'object') return def;
  const d = def as { title?: unknown; sections?: unknown; fields?: unknown };
  const out: Record<string, unknown> = { ...(def as object) };
  if (typeof d.title === 'string') out.title = tr(d.title);
  if (Array.isArray(d.sections)) {
    out.sections = d.sections.map((s) =>
      s && typeof s === 'object' && typeof (s as { title?: unknown }).title === 'string'
        ? { ...s, title: tr((s as { title: string }).title) }
        : s,
    );
  }
  if (Array.isArray(d.fields)) {
    out.fields = d.fields.map((f) => {
      if (!f || typeof f !== 'object') return f;
      const row = f as { label?: unknown; guidance?: unknown };
      const field: Record<string, unknown> = { ...(f as object) };
      if (typeof row.label === 'string') field.label = tr(row.label);
      if (typeof row.guidance === 'string') field.guidance = tr(row.guidance);
      return field;
    });
  }
  return out as T;
}
