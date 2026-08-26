/**
 * SEMANTIC GUARD (FAS SEO-2) — deterministisk kontrollgrind som fäller bygget om
 * den semantiska markpositionen (Open Discovery) motsägs på någon LIVE-yta som
 * Google, AI-sökmotorer och användare faktiskt läser, och som vaktar att den
 * KANONISKA entitetsbeskrivningen (seo/entity.json) inte divergerar.
 *
 * Två kontroller:
 *   A. Motsägelseskanning — flaggar kvarvarande betalvägg-före-resultat-språk
 *      (den borttagna 39 kr-analysupplåsningen, "lås upp dina matchningar" m.m.)
 *      på appens ytor + generatorerna + systemhandboken.
 *   B. Entitetskonsistens — samma kanoniska beskrivning ska finnas ordagrant på
 *      startsidan; genseo läser entity.json (single source).
 *
 * Scope = det Google/AI/användare ser. Historiska revisionsrapporter
 * (docs/reports/), migrationsnapshots och gammalt testställning är AVSIKTLIGT
 * utanför (de är daterade ögonblicksbilder, inte påståenden om nuläget).
 *
 *   node tools/semanticguard.mjs        # kör; icke-noll exit vid motsägelse
 *
 * Wire:ad i scripts/verify.sh. Deterministisk, ingen databas, inget nät.
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
let errors = 0;
const err = (m) => { console.error('MOTSÄGELSE: ' + m); errors++; };

// ── LIVE-ytor som skannas (det maskiner/användare läser) ─────────────────────
function collect(dir, exts, acc = []) {
  if (!existsSync(dir)) return acc;
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) collect(p, exts, acc);
    else if (exts.some((e) => name.endsWith(e))) acc.push(p);
  }
  return acc;
}
const FILES = [
  join(ROOT, 'apps/web/index.html'),
  ...collect(join(ROOT, 'apps/web/src'), ['.ts', '.tsx']),
  join(ROOT, 'demo/main.tsx'),
  join(ROOT, 'tools/genseo.mjs'),
  join(ROOT, 'tools/genmanual.mjs'),
  join(ROOT, 'docs/MANUAL.md'),
].filter(existsSync);

// Förbjudna formuleringar — betalvägg FÖRE resultat / den borttagna 39 kr-modellen.
const FORBIDDEN = [
  { re: /\b39\s?kr\b/i, why: 'den borttagna 39 kr-analysupplåsningen' },
  { re: /analysuppl[åa]sning/i, why: '"analysupplåsning" (pensionerad i Open Discovery)' },
  { re: /l[åa]s upp (din|dina|analysen|matchning|bidragsanalys|resultat)/i, why: '"lås upp …" — resultaten är inte låsta' },
  { re: /betala för att se/i, why: '"betala för att se …" — upptäckten är gratis' },
  { re: /bakom betalv[äa]ggen/i, why: '"bakom betalväggen" — resultaten är inte betalväggade' },
  { re: /betalv[äa]gg framf[öo]r/i, why: '"betalvägg framför resultat"' },
  { re: /fyll (f[öo]rst )?i projektet f[öo]r att (hitta|se)/i, why: '"fyll först i projektet för att hitta bidrag"' },
];
// Rader som FÖRKLARAR borttagningen/negationen släpps förbi (inte påståenden om nuläget).
const ALLOW = /borttag|pensioner|open discovery|ej l[äa]ngre|inte l[äa]ngre|togs bort|finns kvar|finns inte|ingen analysuppl|ingen betalv|ingen teaser|inte l[åa]st|utan att betala|inte l[åa]sta/i;

for (const f of FILES) {
  const rel = f.slice(ROOT.length + 1);
  const lines = readFileSync(f, 'utf8').split('\n');
  lines.forEach((line, i) => {
    if (ALLOW.test(line)) return;
    for (const { re, why } of FORBIDDEN) {
      if (re.test(line)) err(`${rel}:${i + 1} — ${why}\n           › ${line.trim().slice(0, 120)}`);
    }
  });
}

// ── B. Entitetskonsistens ────────────────────────────────────────────────────
const entity = JSON.parse(readFileSync(join(ROOT, 'seo/entity.json'), 'utf8'));
if (!Array.isArray(entity.claims) || entity.claims.length !== 10) {
  err('seo/entity.json ska ha exakt 10 maskinläsbara påståenden (claims).');
}
const indexHtml = readFileSync(join(ROOT, 'apps/web/index.html'), 'utf8');
if (!indexHtml.includes(entity.description.sv)) {
  err('startsidan (apps/web/index.html) saknar den kanoniska entitetsbeskrivningen (entity.description.sv) ordagrant i sin JSON-LD.');
}
if (!readFileSync(join(ROOT, 'tools/genseo.mjs'), 'utf8').includes("readFileSync(join(ROOT, 'seo', 'entity.json')")) {
  err('tools/genseo.mjs läser inte längre seo/entity.json som single source.');
}

if (errors) {
  console.error(`\nSemantic guard: ${errors} motsägelse(r) mot Open Discovery/entiteten. Rätta ytan innan push.`);
  process.exit(1);
}
console.log(`Semantic guard GODKÄND — ${FILES.length} live-ytor skannade, entiteten konsekvent (10 påståenden, startsidan i synk).`);
