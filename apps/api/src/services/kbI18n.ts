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

/** Översätt kriteriers intakeQuestion i en regelversions kriterielista. */
export function translateCriteria<T>(criteria: T, tr: KbTranslate): T {
  if (!Array.isArray(criteria)) return criteria;
  return criteria.map((c) =>
    c && typeof c === 'object' && typeof (c as { intakeQuestion?: unknown }).intakeQuestion === 'string'
      ? { ...c, intakeQuestion: tr((c as { intakeQuestion: string }).intakeQuestion) }
      : c,
  ) as T;
}
