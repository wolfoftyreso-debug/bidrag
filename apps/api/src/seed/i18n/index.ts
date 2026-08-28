/**
 * I18N fas B (docs/I18N_PROGRAM.md): kunskapsbasens användarvända texter —
 * stödsammanfattningar (summary) och kriteriernas intakefrågor — på de tio
 * icke-svenska produktspråken. Nyckeln är den EXAKTA svenska källtexten ur
 * apps/api/src/seed/data.ts; värdet är översättningen.
 *
 * Regler (bindande):
 *  - Officiella stöd-, myndighets- och programnamn översätts ALDRIG
 *    (Arbetsförmedlingen, Försäkringskassan, Horisont Europa, 90-konto …) —
 *    de står kvar på svenska inne i den översatta meningen.
 *  - Innehållet är AI-översatt och ännu inte granskat av människa —
 *    etiketten i produkten ändras först efter granskningsprotokollet.
 *  - tools/i18ncheck.mjs (verify steg 8) kräver att varje språkfil täcker
 *    exakt källmängden (alla summaries + alla unika intakefrågor) — en ny
 *    eller ändrad källtext utan översättning fäller bygget.
 *  - Dari (prs) är EGEN afghansk-persisk vokabulär, aldrig en kopia av fa.
 */
import { en } from './en.ts';
import { es } from './es.ts';
import { fr } from './fr.ts';
import { ar } from './ar.ts';
import { fa } from './fa.ts';
import { prs } from './prs.ts';
import { ru } from './ru.ts';
import { uk } from './uk.ts';
import { so } from './so.ts';
import { ti } from './ti.ts';

export const KB_LOCALES = ['en', 'es', 'fr', 'ar', 'fa', 'prs', 'ru', 'uk', 'so', 'ti'] as const;
export type KbLocale = (typeof KB_LOCALES)[number];

export const KB_TRANSLATIONS: Record<KbLocale, Record<string, string>> = {
  en, es, fr, ar, fa, prs, ru, uk, so, ti,
};
