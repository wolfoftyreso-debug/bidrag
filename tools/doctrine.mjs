/**
 * PRODUKTDOKTRINEN SOM KOD (docs/PRODUCT_DOCTRINE.md §2, den bärande
 * invarianten): "Användaren ska aldrig behöva känna till stödet — dess namn,
 * kategori, myndighet eller stödform — för att få värde ur systemet."
 *
 * Doktrinen får inte vara en checklista man glömmer. Den här kontrollen körs i
 * npm run verify och fäller bygget om intagsytorna börjar kräva förkunskap
 * eller om värde-före-betalning-ordningen bryts. Precis som audit-relevans.mjs:
 * ingen server, ingen databas — ren källkodsläsning.
 *
 *   node tools/doctrine.mjs             # revidera (exit 1 vid brott)
 *   node tools/doctrine.mjs --legacy    # visa att kontrollen fångar ett brott
 *                                       # (injicerar en förbjuden entry-gate-fras
 *                                       #  i minnet och förväntar sig fällning)
 *
 * Vad som kontrolleras:
 *
 *  A. SITUATIONS-FÖRST (positiv). Både webbappens och demons intag ska öppna
 *     med situationsförgreningen — användaren väljer sin situation, aldrig ett
 *     bidrag. Load-bearing copy måste finnas ordagrant.
 *
 *  B. INGA ENTRY-GATE-FRASER (negativ). Intagsfilerna får inte innehålla
 *     fraser som tvingar användaren att namnge/välja ett bidrag, en stödform,
 *     en finansiär eller ett myndighetsbegrepp som inträdesbiljett. Vi förbjuder
 *     PRECISA fraser — inte ordet "bidrag" (som förekommer legitimt i vägledning
 *     och i utdata). Att NAMNGE ett stöd i resultat/SEO är tillåtet; att KRÄVA
 *     att användaren kan det som indata är det inte — därför gäller B bara
 *     intagsytor, inte resultatkort eller SEO-sidor.
 *
 *  C. VÄRDE FÖRE BETALNING (positiv). Matches-vyn ska visa en teaser (att
 *     relevanta stöd finns, hur många, på vilken nivå) FÖRE upplåsning, och
 *     teasern får aldrig avslöja namn/källa. Paywall efter, inte före, värde.
 */
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const LEGACY = process.argv.includes('--legacy');
const read = (rel) => readFileSync(join(ROOT, rel), 'utf8');

// ── Intagsytorna (där invarianten är hårdast) ────────────────────────────────
const INTAKE = ['apps/web/src/pages/Onboarding.tsx', 'demo/main.tsx'];

// ── A. Situationsförgreningen — måste finnas ordagrant i båda intagen ─────────
const SITUATION_ANCHORS = [
  'Jag har svårt att få ekonomin att gå ihop',
  'Jag söker pengar till ett projekt eller en verksamhet',
];

// ── B. Förbjudna entry-gate-fraser (regex, skiftlägesokänsligt) ──────────────
// Var och en representerar "användaren måste redan kunna stödet/stödformen".
// Formulerade snävt så att vardaglig vägledning ("vi hittar stöd som passar
// din situation") aldrig träffas.
const BANNED = [
  { re: /vilket bidrag (söker|vill|ska)\s+du/i, why: 'ber användaren namnge bidraget som inträde' },
  { re: /välj (ett |vilket )?bidrag\b/i, why: 'bidragsväljare som inträdesbiljett' },
  { re: /ange (stödform|bidragsform|stödtyp)/i, why: 'kräver myndighetsbegrepp som indata' },
  { re: /välj (stödform|bidragsform|finansiär|myndighet)\b/i, why: 'kräver myndighetsbegrepp som indata' },
  { re: /vilken (stödform|bidragsform)\b/i, why: 'kräver att användaren kan stödformen' },
  { re: /stödberättigande insats/i, why: 'myndighetsspråk i en fråga till användaren' },
  { re: /vilket (stöd|projektstöd) (söker|vill)\s+du\s+söka/i, why: 'förutsätter att användaren vet stödets namn' },
  { re: /sök på (bidragets|stödets) namn/i, why: 'gör namnkunskap till förutsättning' },
];

// ── C. Open Discovery: matchningar gratis, ingen betalvägg framför resultatet ─
// (produktdoktrinen v2 §3.1/§4). Fäller bygget om paywall-före-resultat
// återinförs — i api (matches-gate) eller i webben (paywall-UI).
const OPEN_DISCOVERY_FORBIDDEN = [
  { file: 'apps/api/src/routes/projects.ts', needle: 'buildTeaser', why: 'teaser-gate framför matchningarna återinförd i API:t' },
  { file: 'apps/api/src/routes/projects.ts', needle: 'isProjectUnlocked', why: 'matchningsvisning gatead bakom betalning igen' },
  { file: 'apps/web/src/pages/Matches.tsx', needle: 'AnalysisPaywall', why: 'betalvägg-UI framför resultaten återinförd' },
];

const findings = [];
const note = (surface, rule, msg) => findings.push({ surface, rule, msg });

// A ---------------------------------------------------------------------------
for (const f of INTAKE) {
  const src = read(f);
  for (const anchor of SITUATION_ANCHORS) {
    if (!src.includes(anchor)) {
      note(f, 'A · situations-först', `saknar förankringen "${anchor}" — intaget öppnar inte längre med situationsförgreningen`);
    }
  }
}

// B ---------------------------------------------------------------------------
for (const f of INTAKE) {
  let src = read(f);
  if (LEGACY && f === 'demo/main.tsx') {
    // Simulera regressionen: någon inför en bidragsväljare som första fråga.
    src += '\n<Q title="Vilket bidrag söker du?" />\n';
  }
  const lines = src.split('\n');
  lines.forEach((line, i) => {
    for (const b of BANNED) {
      if (b.re.test(line)) {
        note(f, 'B · ingen entry-gate', `rad ${i + 1}: ${b.why} — «${line.trim().slice(0, 80)}»`);
      }
    }
  });
}

// C ---------------------------------------------------------------------------
for (const c of OPEN_DISCOVERY_FORBIDDEN) {
  if (read(c.file).includes(c.needle)) note(c.file, 'C · Open Discovery', c.why);
}

// ── Dom ──────────────────────────────────────────────────────────────────────
const RULES = ['A · situations-först', 'B · ingen entry-gate', 'C · Open Discovery'];
console.log('PRODUKTDOKTRINEN — konformanskontroll (docs/PRODUCT_DOCTRINE.md §2)\n');
for (const r of RULES) {
  const hits = findings.filter((x) => x.rule === r);
  if (hits.length === 0) {
    console.log(`  PASS  ${r}`);
  } else {
    console.log(`  FAIL  ${r}`);
    for (const h of hits) console.log(`        ${h.surface}: ${h.msg}`);
  }
}

if (LEGACY) {
  const caught = findings.some((x) => x.rule.startsWith('B'));
  console.log(`\n[--legacy] Förväntar fällning på injicerad entry-gate: ${caught ? 'FÅNGAD ✓' : 'MISSAD ✗'}`);
  process.exit(caught ? 0 : 1);
}

console.log(`\n${findings.length === 0 ? 'Doktrinen hålls på alla kontrollerade ytor.' : `${findings.length} brott mot doktrinen.`}`);
process.exit(findings.length === 0 ? 0 : 1);
