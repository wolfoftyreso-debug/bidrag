/**
 * SEO data-QA (SEO-120 deadline-accuracy + SEO-121 source-accuracy m.fl.) —
 * deterministiska invarianter över kunskapsbasen som kodar Definition-of-Done-
 * blockerarna: inget stöd får sakna officiell källa, inget engångsstöd får visas
 * som öppet efter passerad deadline, inga dubbletter. Ingen extern data, ingen
 * databas — läser seeden direkt.
 *
 *   node --experimental-strip-types tools/seo-dataqa.mjs   # icke-noll exit vid brott
 *
 * Wire:ad i scripts/verify.sh. Referensdatum = seedens CURATED_AT (aldrig klockan).
 */
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { computeFundingIndex } from './lib/foretagsindex.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const { opportunities, authorities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const NOW = CURATED_AT.slice(0, 10);
const authKeys = new Set(authorities.map((a) => a.key));

let errors = 0;
const err = (m) => { console.error('DATA-QA FEL: ' + m); errors++; };

// SEO-121 — källproveniens: varje stöd måste ha officiell källa + ansökningslänk.
for (const o of opportunities) {
  if (!o.sourceUrl || !/^https?:\/\//.test(o.sourceUrl)) err(`${o.slug}: saknar giltig sourceUrl (bidragssida utan källa får ej publiceras)`);
  if (!o.applicationUrl || !/^https?:\/\//.test(o.applicationUrl)) err(`${o.slug}: saknar giltig applicationUrl (officiell ansökningsväg)`);
}

// SEO-120 — deadline-accuracy: ett ENGÅNGSstöd med passerad closesAt får aldrig
// renderas som öppet. (Återkommande/rolling ramas in som "nästa omgång" i genseo.)
for (const o of opportunities) {
  if (o.deadlineModel === 'one_time' && o.closesAt && o.closesAt.slice(0, 10) < NOW) {
    err(`${o.slug}: engångsstöd med passerad deadline (${o.closesAt.slice(0, 10)} < ${NOW}) — skulle visas som stale-open`);
  }
}

// Integritet: unika slugs, giltig finansiär, titel finns.
const seen = new Set();
for (const o of opportunities) {
  if (seen.has(o.slug)) err(`dubblett-slug: ${o.slug}`);
  seen.add(o.slug);
  if (!o.title) err(`${o.slug}: saknar titel`);
  if (!authKeys.has(o.authorityKey)) err(`${o.slug}: authorityKey "${o.authorityKey}" finns inte i authorities`);
}

// Företagsbidragsindex §80: all publik statistik ska vara REPRODUCERBAR. Räkna om
// ur seeden och kontrollera att den publicerade sidan visar samma siffra.
const fbi = computeFundingIndex(opportunities, authorities, CURATED_AT);
const fbiHtml = join(ROOT, 'artifacts', 'seo-site', 'foretagsbidragsindex', 'index.html');
if (existsSync(fbiHtml)) {
  const html = readFileSync(fbiHtml, 'utf8');
  const open = fbi.metrics.openCompanyGrants.value;
  if (!html.includes(`Öppna företagsstöd</th><td>${open}<`)) {
    err(`Företagsbidragsindex: publicerad "öppna företagsstöd" matchar inte omräkningen (${open}) — statistiken är inte reproducerbar`);
  }
  const cov = fbi.metrics.verifiedAvailableFunding.coveragePct;
  if (!html.includes(`${cov} % täckning`)) {
    err(`Företagsbidragsindex: publicerad finansieringstäckning matchar inte omräkningen (${cov} %)`);
  }
}

if (errors) {
  console.error(`\nSEO data-QA: ${errors} brott mot DoD-invarianterna. Blockerar release.`);
  process.exit(1);
}
console.log(`SEO data-QA GODKÄND — ${opportunities.length} stöd: alla har källa + ansökningslänk, inga stale-open deadlines, inga dubbletter (ref ${NOW}).`);
