/**
 * SVG-vakt — varje SVG i repot måste vara välformad XML, och de härledda
 * varumärkesfilerna måste komma ur logo-mark.svg.
 *
 * Bakgrund: designsystemet "Signal" gick ut med ett `--primary-light` inuti en
 * XML-kommentar i logo-mark.svg. Två bindestreck i rad är otillåtna i en
 * XML-kommentar, så BÅDE märket och den genererade favicon.svg slutade parsa
 * och renderades som trasig bild i webbläsaren — utan att något bygge klagade.
 * Zero broken windows (DESIGN_CONSTITUTION §2): felet får inte kunna återkomma.
 *
 * Kontrollerna:
 *   1. Välformadhet: kommentarer utan `--`, balanserade taggar, citerade
 *      attribut, inga nakna `&`.
 *   2. Härledningen: favicon.svg bär märkets bock och ingen geometri som inte
 *      står i logo-mark.svg (dvs. `node tools/genbrand.mjs` har körts efter en
 *      ändring av märket). Taklinjen får saknas — den lilla varianten släpper
 *      medvetet taket, se generatorns huvud.
 *
 * Körs i npm run verify. Exit 1 vid fel.
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const DIRS = ['apps/web/public', 'apps/web/public/illustrationer', 'design/illustrationer'];
const errors = [];

function svgFiles() {
  const out = [];
  for (const d of DIRS) {
    const abs = join(ROOT, d);
    if (!existsSync(abs)) continue;
    for (const f of readdirSync(abs)) {
      const p = join(abs, f);
      if (f.endsWith('.svg') && statSync(p).isFile()) out.push(p);
    }
  }
  return out;
}

/** Minimal XML-välformadhetskontroll — räcker för handskriven SVG. */
function checkWellFormed(path, src) {
  const rel = relative(ROOT, path);
  const err = (msg) => errors.push(`${rel}: ${msg}`);
  const stack = [];
  let i = 0;

  while (i < src.length) {
    const lt = src.indexOf('<', i);
    if (lt === -1) break;
    const text = src.slice(i, lt);
    if (/&(?!(#\d+|#x[0-9a-fA-F]+|[a-zA-Z][a-zA-Z0-9]*);)/.test(text)) err('naket & i textinnehåll');

    if (src.startsWith('<!--', lt)) {
      const end = src.indexOf('-->', lt + 4);
      if (end === -1) { err('oavslutad XML-kommentar'); break; }
      const body = src.slice(lt + 4, end);
      // XML förbjuder `--` inuti en kommentar (XML 1.0 §2.5).
      if (body.includes('--')) err('XML-kommentar innehåller "--" (otillåtet — bryter parsningen)');
      i = end + 3;
      continue;
    }
    if (src.startsWith('<?', lt) || src.startsWith('<!', lt)) {
      const end = src.indexOf('>', lt);
      if (end === -1) { err('oavslutad deklaration'); break; }
      i = end + 1;
      continue;
    }

    const gt = src.indexOf('>', lt);
    if (gt === -1) { err('oavslutad tagg'); break; }
    const raw = src.slice(lt + 1, gt);
    if (raw.startsWith('/')) {
      const name = raw.slice(1).trim();
      const open = stack.pop();
      if (open !== name) err(`</${name}> stänger inte <${open ?? 'ingenting'}>`);
    } else {
      const selfClosing = raw.endsWith('/');
      const body = selfClosing ? raw.slice(0, -1) : raw;
      const name = body.trim().split(/[\s/>]/)[0];
      if (!name) err('tom taggnamn');
      const attrs = body.slice(body.indexOf(name) + name.length);
      // Varje attribut måste ha citerat värde.
      const bad = attrs.replace(/\s+[\w:.-]+\s*=\s*("[^"]*"|'[^']*')/g, '').trim();
      if (bad) err(`ociterat eller trasigt attribut i <${name}>: ${bad.slice(0, 40)}`);
      if (!selfClosing) stack.push(name);
    }
    i = gt + 1;
  }
  if (stack.length) errors.push(`${rel}: ostängda taggar: ${stack.join(', ')}`);
}

const files = svgFiles();
for (const f of files) checkWellFormed(f, readFileSync(f, 'utf8'));

// Härledningen: favicon.svg ska bära märkets geometri.
const markPath = join(ROOT, 'apps/web/public/logo-mark.svg');
const favPath = join(ROOT, 'apps/web/public/favicon.svg');
if (existsSync(markPath) && existsSync(favPath)) {
  const mark = readFileSync(markPath, 'utf8');
  const fav = readFileSync(favPath, 'utf8');
  const points = [...mark.matchAll(/points="([^"]+)"/g)].map((m) => m[1]);
  const favPoints = [...fav.matchAll(/points="([^"]+)"/g)].map((m) => m[1]);
  if (points.length === 0) errors.push('logo-mark.svg: hittar inga polylinjer — är märket ritat?');
  // Bocken är märkets sista linje och måste finnas i varje storlek.
  const tick = points.at(-1);
  if (tick && !favPoints.includes(tick)) {
    errors.push(`favicon.svg saknar märkets bock "${tick}" — kör: node tools/genbrand.mjs`);
  }
  for (const p of favPoints) {
    if (!points.includes(p)) {
      errors.push(`favicon.svg ritar en linje "${p}" som inte står i logo-mark.svg — den ska härledas, inte handritas`);
    }
  }
  if (!fav.includes('#1273d4')) errors.push('favicon.svg saknar den blå rutan (--primary #1273d4)');
} else {
  errors.push('logo-mark.svg eller favicon.svg saknas i apps/web/public/');
}

if (errors.length) {
  console.error('SVG-VAKTEN FÄLLER:');
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`SVG-vakten OK: ${files.length} filer välformade, favicon.svg härledd ur logo-mark.svg`);
