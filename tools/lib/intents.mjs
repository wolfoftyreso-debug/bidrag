/**
 * Bidragsgrafen (SEO-3): resolver + Indexability-motor. Delad källa så att
 * generatorn (tools/genseo.mjs) och rapporten (tools/indexability.mjs) aldrig
 * divergerar. Query Pages är VYER över seeden — en intention resolveras till de
 * verkliga aktiva stöd som matchar filtret, och Indexability-motorn avgör om
 * kombinationen förtjänar en indexerbar sida (data-driven SEO, inte spam).
 */
import { readFileSync } from 'node:fs';

export function loadIntents(root) {
  return JSON.parse(readFileSync(`${root}/seo/search-intents.json`, 'utf8')).intents;
}

/** Resolvera en intention mot seeden → de stöd som matchar filtret. */
export function resolveIntent(intent, opportunities) {
  const f = intent.filter ?? {};
  return opportunities.filter((o) =>
    (!f.applicant || (o.applicantTypes ?? []).includes(f.applicant)) &&
    (!f.sector || (o.sectors ?? []).includes(f.sector)) &&
    (!f.instrument || o.instrumentType === f.instrument) &&
    // `activity` finns inte som seedfält → ingen kombination matchar (motorn
    // ska då ärligt vägra sidan tills kunskapsbasen kurerats för aktiviteten).
    (!f.activity),
  );
}

/**
 * Indexability Score (SEO-3/§5). Grunden är VERKLIG datatäckning — vi har ingen
 * verifierad sökvolym (search_volume=null), så vi påstår aldrig efterfrågan vi
 * inte mätt. Beslutet vilar på: finns ≥1 relevant stöd, är sidan tillräckligt
 * täckt, och skiljer den sig materiellt från förälderhubben.
 *
 *   INDEX             ≥3 relevanta stöd → self-canonical + i sitemap
 *   NOINDEX_FOLLOW    1–2 stöd → användbar för människor, tävlar inte i Google
 *   DO_NOT_GENERATE   0 stöd → kombinationen saknar värde, genereras inte
 */
export function indexabilityVerdict(intent, supports) {
  const count = supports.length;
  const reasons = [];
  let verdict;
  if (count === 0) {
    verdict = 'DO_NOT_GENERATE';
    reasons.push(intent.filter?.activity
      ? `aktiviteten "${intent.filter.activity}" saknar kurerat stöd i kunskapsbasen`
      : 'inga stöd matchar filtret');
  } else if (count < 3) {
    verdict = 'NOINDEX_FOLLOW';
    reasons.push(`endast ${count} matchande stöd — för tunt för att tävla i Google`);
  } else {
    verdict = 'INDEX';
    reasons.push(`${count} matchande stöd`, 'materiellt mer specifik än målgruppshubben', 'varje stöd har officiell källa');
  }
  return { verdict, count, reasons, score: count };
}

/**
 * Den BINDANDE indexerbarhetsregeln (§29): ingen sida indexeras enbart för att
 * den tekniskt går att generera, och ingen sida publiceras/indexeras om den bara
 * byter ut ort/bransch/årtal/målgrupp/bidragsnamn i en i övrigt identisk mall.
 * Varje indexerbar sida måste ha egen verifierad sökintention, självständigt
 * användarvärde, aktuell bidragsdata, relevanta villkor, officiella källor,
 * internlänkar OCH en konkret handling. Full beslutsvokabulär:
 *
 *   INDEX               besvarar en verklig, unik fråga → self-canonical + sitemap
 *   NOINDEX_FOLLOW      användbar i produkten men saknar eget sökvärde
 *   CANONICAL_TO_PARENT överlappar en starkare huvudsida → canonical dit, ur sitemap
 *   MERGE               unikt innehåll ska flyttas till en annan sida
 *   REMOVE_410          varaktigt värdelös utan relevant ersättare → 410
 *   DO_NOT_GENERATE     saknar reellt värde → skapas aldrig
 *
 * Produkten får skapa obegränsat med personliga/filtrerade resultat; Google får
 * bara sidorna som förtjänar att vara självständiga sökresultat.
 */
export const VERDICTS = ['INDEX', 'NOINDEX_FOLLOW', 'CANONICAL_TO_PARENT', 'MERGE', 'REMOVE_410', 'DO_NOT_GENERATE'];

/**
 * CANONICAL_TO_PARENT-detektion: om en kandidat inte SMALNAR AV sin förälderhubb
 * (samma stöduppsättning som hela föräldern) tillför den inget eget sökvärde och
 * ska canonicala till föräldern i stället för att konkurrera. Returnerar
 * 'CANONICAL_TO_PARENT' eller null.
 */
export function parentOverlapVerdict(supports, parentSupports) {
  if (!parentSupports || !parentSupports.length || !supports.length) return null;
  const set = new Set(supports.map((o) => o.slug));
  const parentSet = new Set(parentSupports.map((o) => o.slug));
  // Ingen avsmalning: kandidaten täcker hela föräldern (och tvärtom) → dubblett.
  const narrows = [...parentSet].some((s) => !set.has(s));
  return narrows ? null : 'CANONICAL_TO_PARENT';
}
