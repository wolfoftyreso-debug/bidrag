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

export const VERDICTS = ['INDEX', 'NOINDEX_FOLLOW', 'DO_NOT_GENERATE'];
