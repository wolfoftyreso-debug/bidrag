/**
 * Språkvakten (docs/LANGUAGE_GUIDE.md §7, perfektionsbacklog M5) — deterministisk
 * kontroll av all användarvänd text mot språkguidens hårda regler och
 * terminologiregistret (seo/terminologi.json). Ytor som kontrolleras:
 *
 *   sv     apps/web/src/i18n/locales/sv.ts (källspråket för webben)
 *   seed   apps/api/src/seed/data.ts — sammanfattningar, villkorstexter, intagsfrågor,
 *          ansökningssätt, belopp, underlag, schematitlar/etiketter/vägledning
 *   demo   demo/main.tsx — JSX-text och svenska strängar
 *   seo    artifacts/seo-site/** (om genererad) — synlig text per sida
 *   i18n   alla 10 webbspråk + 10 seedspråk + seo/publik-i18n.json
 *
 * Regler (fäller):
 *   R1  Förbjudna löftesord: "berättigad" (utom "stödberättigad kostnad"), "garanter…"
 *       utan negation, "chans att beviljas", "du har rätt till"/"du är berättigad".
 *   R2  Belopp: aldrig "SEK", ":-" eller "kronor" i svensk text; fyrsiffriga belopp
 *       framför "kr" måste vara tusentalsgrupperade ("12 345 kr").
 *   R3  Datum: aldrig "12/3"-format.
 *   R4  CTA/ankare: aldrig "Klicka här" eller ensamt "Läs mer".
 *   R5  Ton: inga utropstecken i sakinnehåll, inga dubbla mellanslag, inga emoji,
 *       ingen "AI-genererat"-ursäkt.
 *   R6  Stavningskonsekvens: "i dag" (inte "idag"), "i stället" (inte "istället"),
 *       "mejl" (inte "mail" som svenskt ord).
 *   R7  Beslutsraden: bedömning ≠ beslut — "slutlig bedömning görs" är förbjudet;
 *       analysvyn, dokumentstudion och demon bär "Slutligt beslut fattas alltid av";
 *       varje publik stödsida bär "beslut fattas alltid av" OCH "alltid gratis".
 *   R8  Terminologi: deprecated-termer ur seo/terminologi.json används inte som
 *       huvudterm (tillåtet i "kallas ibland …"/synonym-sammanhang).
 *   R9  Översättningar: engelska texter använder "kr" (aldrig "SEK"); fa/prs/ar
 *       använder latinska siffror genomgående (inget blandat siffersystem);
 *       sidrubriken acc.title = navigationsetiketten nav.account i varje språk;
 *       ingen översättning lämnar "kunskapsbasen" oöversatt.
 *
 *   node tools/langcheck.mjs            # fäller vid brott
 *   node tools/langcheck.mjs --report   # skriver ut alla träffar, fäller inte
 */
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const REPORT = process.argv.includes('--report');
const problems = [];
const fail = (rule, where, text) => problems.push({ rule, where, text: text.replace(/\s+/g, ' ').slice(0, 160) });

// ── Textkällor ───────────────────────────────────────────────────────────────
async function tsStrings(path, code) {
  // Samma inläsning som tools/i18ncheck.mjs: importera modulen, läs exporten —
  // ingen regex kan missa radbrutna eller citattecken-blandade värden.
  const mod = await import(path);
  return Object.entries(mod[code]).filter(([, v]) => typeof v === 'string');
}
function kbStrings(path) {
  const src = readFileSync(path, 'utf8');
  const out = [];
  for (const m of src.matchAll(/^\s*"((?:\\.|[^"])*)":\s*"((?:\\.|[^"])*)",?\s*$/gm)) out.push([m[1], m[2]]);
  return out;
}
async function seedStrings() {
  const { opportunities, applicationSchemaDefs } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
  const out = [];
  const add = (where, t) => { if (typeof t === 'string' && t.trim()) out.push([where, t]); };
  for (const o of opportunities) {
    add(`${o.slug}.summary`, o.summary); add(`${o.slug}.applicationMethod`, o.applicationMethod); add(`${o.slug}.amountNote`, o.amountNote);
    for (const c of o.criteria ?? []) { add(`${o.slug}.${c.id}.q`, c.intakeQuestion); add(`${o.slug}.${c.id}.d`, c.description); }
    for (const e of o.evidenceRequirements ?? []) add(`${o.slug}.evidence`, e.description);
  }
  for (const { def } of applicationSchemaDefs ?? []) {
    add(`${def.id}.title`, def.title);
    for (const s of def.sections ?? []) { add(`${def.id}.${s.key}`, s.title); add(`${def.id}.${s.key}.desc`, s.description); }
    for (const f of def.fields ?? []) { add(`${def.id}.${f.key}.label`, f.label); add(`${def.id}.${f.key}.guidance`, f.guidance); }
  }
  return out;
}
function demoStrings() {
  const src = readFileSync(join(ROOT, 'demo/main.tsx'), 'utf8');
  const out = [];
  src.split('\n').forEach((l, i) => {
    for (const m of l.matchAll(/>([^<>{}]{12,})</g)) out.push([`demo:${i + 1}`, m[1]]);
    for (const m of l.matchAll(/(['"`])((?:\\.|(?!\1).){20,}?)\1/g)) {
      const t = m[2];
      if (/[åäö]|\b(och|att|för|inte|med|din|ditt|du)\b/.test(t) && !/https?:\/\/|\$\{|^[a-z/._-]+$/.test(t)) out.push([`demo:${i + 1}`, t]);
    }
  });
  return out;
}
function walk(dir) {
  const out = [];
  for (const f of readdirSync(dir)) {
    const p = join(dir, f);
    if (statSync(p).isDirectory()) out.push(...walk(p)); else if (p.endsWith('.html')) out.push(p);
  }
  return out;
}
const decode = (s) => s.replace(/&amp;/g, '&').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&nbsp;/g, ' ');
function seoPages() {
  const dir = join(ROOT, 'artifacts/seo-site');
  if (!existsSync(dir)) return null;
  return walk(dir).map((p) => {
    let h = readFileSync(p, 'utf8').replace(/<script[^>]*>[\s\S]*?<\/script>/g, '').replace(/<style[^>]*>[\s\S]*?<\/style>/g, '');
    const anchors = [...h.matchAll(/<a\b[^>]*>([\s\S]*?)<\/a>/g)].map((m) => decode(m[1].replace(/<[^>]+>/g, '')).trim());
    const text = decode(h.replace(/<[^>]+>/g, ' ')).replace(/[ \t]+/g, ' ');
    return { path: relative(dir, p), text, anchors };
  });
}

// ── Regler för svensk text ───────────────────────────────────────────────────
const TERMS = JSON.parse(readFileSync(join(ROOT, 'seo/terminologi.json'), 'utf8')).termer;
const DEPRECATED = TERMS.flatMap((t) => t.deprecated ?? []).map((d) => d.replace(/\s*\(.*\)\s*$/, '').trim().toLowerCase()).filter((d) => d && !/^csn$/i.test(d));

const SV_RULES = [
  ['R1 löftesord', /(?<!stöd)berättigad/i],
  // "du har rätt till" är ett löfte — men villkorsformen ("om du har rätt till",
  // "vad du har rätt till") är just den osäkerhet guiden kräver och tillåts.
  ['R1 löftesord', /(?<!\b(?:om|ifall|när|vad|vilka|vilket|det|huruvida) )\b(du har rätt till|du är berättigad|du får rätt till)\b/i],
  ['R1 löftesord', /\b(chans(en)? att (bli )?beviljas?|kommer att beviljas)\b/i],
  ['R2 belopp', /\bSEK\b|\bkronor\b|\d:-/],
  ['R2 belopp', /(?<![\d ])\d{4,}\s?kr\b/],
  ['R3 datum', /\b\d{1,2}\/\d{1,2}(\/\d{2,4})?\b/],
  ['R4 CTA', /[Kk]licka här/],
  ['R5 ton', /[a-zåäö0-9]!(?![=\w])/],
  ['R5 ton', /\S {2,}\S/],
  ['R5 ton', /[\u{1F300}-\u{1FAFF}]/u],
  ['R5 ton', /AI-genererat|AI-genererad/],
  ['R6 stavning', /\bidag\b|\bistället\b/i],
  ['R6 stavning', /\bmail(et|en|a|ar|ade)?\b/i],
  ['R7 beslut ≠ bedömning', /slutlig bedömning görs/i],
];
function garanterUtanNegation(t) {
  for (const m of t.matchAll(/garanter\w*/gi)) {
    const before = t.slice(Math.max(0, m.index - 60), m.index).toLowerCase();
    if (!/\b(inte|aldrig|ingen|inget|kan inte|utan)\b/.test(before)) return true;
  }
  return false;
}
function deprecatedSomHuvudterm(t) {
  const lt = t.toLowerCase();
  for (const d of DEPRECATED) {
    const re = new RegExp(`\\b${d.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'i');
    if (!re.test(lt)) continue;
    // Tillåtet i synonym-/förklaringssammanhang (sökbarhet, LANGUAGE_GUIDE §2).
    if (/kallas (ibland|också|ofta|även|i vardagligt tal)|tidigare kallade|vardagligt|synonym|ibland kallat|även kallat|\(.*\bäven\b.*\)/.test(lt)) continue;
    return d;
  }
  return null;
}
function checkSv(where, t) {
  for (const [rule, re] of SV_RULES) if (re.test(t)) fail(rule, where, t);
  if (garanterUtanNegation(t)) fail('R1 löftesord', where, t);
  const d = deprecatedSomHuvudterm(t);
  if (d) fail(`R8 terminologi (${d} som huvudterm)`, where, t);
}

// ── 1. Webbens svenska källsträngar ──────────────────────────────────────────
const sv = await tsStrings(join(ROOT, 'apps/web/src/i18n/locales/sv.ts'), 'sv');
for (const [k, v] of sv) checkSv(`sv.ts ${k}`, v);
const svMap = Object.fromEntries(sv);
for (const k of ['m.personalGuidance', 'm.disclaimer', 'ds.footer', 'm.whyFooter']) {
  if (!/slutligt beslut fattas alltid av/i.test(svMap[k] ?? '')) fail('R7 beslutsraden saknas', `sv.ts ${k}`, svMap[k] ?? '(saknas)');
}
if (!/gratis/.test(svMap['o.payGuidance'] ?? '')) fail('R7 gratisvägen saknas vid köpknappen', 'sv.ts o.payGuidance', svMap['o.payGuidance'] ?? '');

// ── 2. Kunskapsbasen ─────────────────────────────────────────────────────────
for (const [where, t] of await seedStrings()) checkSv(`seed ${where}`, t);

// ── 3. Demon ─────────────────────────────────────────────────────────────────
const demo = demoStrings();
for (const [where, t] of demo) {
  // Kvittots monospace-kolumner ("Säljare:   Landvex AB") är layout, inte prosa.
  if (/^(Köp-ID|Säljare|Adress|Org\.nr|Datum|Kvitto|Belopp|Moms|Summa|Tjänst|Betalsätt|Kund):/.test(t)) continue;
  checkSv(where, t);
}
const demoSrc = readFileSync(join(ROOT, 'demo/main.tsx'), 'utf8');
if (!/[Ss]lutligt beslut fattas alltid av/.test(demoSrc)) fail('R7 beslutsraden saknas', 'demo/main.tsx', '');
if (!/alltid gratis/.test(demoSrc)) fail('R7 gratisvägen saknas', 'demo/main.tsx', '');

// ── 4. Publika ytan (om genererad) ───────────────────────────────────────────
const pages = seoPages();
if (pages) {
  for (const { path, text, anchors } of pages) {
    for (const [rule, re] of SV_RULES) {
      if (rule === 'R5 ton' && re.source.includes('{2,}')) continue; // whitespace i HTML är layout
      if (re.test(text)) fail(rule, `seo ${path}`, text.match(re)?.input?.slice(Math.max(0, text.search(re) - 60), text.search(re) + 60) ?? '');
    }
    if (garanterUtanNegation(text)) fail('R1 löftesord', `seo ${path}`, text.slice(Math.max(0, text.search(/garanter/i) - 60), text.search(/garanter/i) + 60));
    for (const a of anchors) if (/^(läs mer|klicka här|här)$/i.test(a)) fail('R4 CTA', `seo ${path}`, `ankartext "${a}"`);
    if (/^bidrag\/[^/]+\/index\.html$/.test(path) && !/(bidrag|finansiarer)\/index\.html$/.test(path)) {
      if (!/beslut fattas alltid av/i.test(text)) fail('R7 beslutsraden saknas', `seo ${path}`, '');
      if (!/alltid gratis/i.test(text)) fail('R7 gratisvägen saknas', `seo ${path}`, '');
    }
  }
} else {
  console.log('langcheck: artifacts/seo-site saknas — publika ytan hoppas över (kör npm run seo:build först för full kontroll)');
}

// ── 5. Översättningarna ──────────────────────────────────────────────────────
const LOCALES = ['en', 'es', 'fr', 'ar', 'fa', 'prs', 'ru', 'uk', 'so', 'ti'];
const NON_LATIN_DIGITS = /[٠-٩۰-۹]/;
for (const l of LOCALES) {
  const web = await tsStrings(join(ROOT, `apps/web/src/i18n/locales/${l}.ts`), l);
  const kb = kbStrings(join(ROOT, `apps/api/src/seed/i18n/${l}.ts`));
  const webMap = Object.fromEntries(web);
  if (webMap['acc.title'] !== webMap['nav.account']) fail('R9 rubrik ≠ navigation', `${l}.ts acc.title`, `${webMap['acc.title']} ≠ ${webMap['nav.account']}`);
  for (const [k, v] of web) {
    if (/kunskapsbas/i.test(v)) fail('R9 oöversatt jargong', `${l}.ts ${k}`, v);
    if (l === 'en' && /\bSEK\b/.test(v)) fail('R9 SEK i engelska (använd kr)', `${l}.ts ${k}`, v);
    if (['fa', 'prs', 'ar'].includes(l) && NON_LATIN_DIGITS.test(v)) fail('R9 blandat siffersystem', `${l}.ts ${k}`, v);
  }
  for (const [k, v] of kb) {
    if (l === 'en' && /\bSEK\b/.test(v)) fail('R9 SEK i engelska (använd kr)', `seed/${l} ${k.slice(0, 50)}`, v);
    if (['fa', 'prs', 'ar'].includes(l) && NON_LATIN_DIGITS.test(v)) fail('R9 blandat siffersystem', `seed/${l} ${k.slice(0, 50)}`, v);
  }
}
const publik = JSON.parse(readFileSync(join(ROOT, 'seo/publik-i18n.json'), 'utf8')).sprak ?? {};
for (const [k, v] of Object.entries(publik.sv ?? {})) if (typeof v === 'string') checkSv(`publik-i18n sv ${k}`, v);
for (const l of LOCALES) for (const [k, v] of Object.entries(publik[l] ?? {})) {
  if (typeof v !== 'string') continue;
  if (l === 'en' && /\bSEK\b/.test(v)) fail('R9 SEK i engelska (använd kr)', `publik-i18n ${l} ${k}`, v);
  if (['fa', 'prs', 'ar'].includes(l) && NON_LATIN_DIGITS.test(v)) fail('R9 blandat siffersystem', `publik-i18n ${l} ${k}`, v);
}

// ── Utfall ───────────────────────────────────────────────────────────────────
const counts = {};
for (const p of problems) counts[p.rule] = (counts[p.rule] ?? 0) + 1;
if (problems.length) {
  for (const p of problems) console.log(`  ${REPORT ? 'TRÄFF' : 'FEL'}  [${p.rule}] ${p.where}: ${p.text}`);
  console.log(`\nlangcheck: ${problems.length} träffar — ${Object.entries(counts).map(([r, n]) => `${r} ${n}`).join(' · ')}`);
  if (!REPORT) process.exit(1);
} else {
  console.log(`langcheck OK: ${sv.length} webbsträngar, ${demo.length} demosträngar, kunskapsbasen, ${pages ? pages.length + ' publika sidor' : 'ingen publik yta'}, 10+10 språkfiler — inga brott mot LANGUAGE_GUIDE §3–§4 eller terminologin.`);
}
