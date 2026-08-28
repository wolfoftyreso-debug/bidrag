/**
 * I18N-vakt (I18N_PROGRAM §vakt) — deterministisk kontroll av språkfilerna:
 *
 *  1. Varje språk har EXAKT samma nyckelmängd som källspråket (sv) —
 *     inget språk kan tyst halka efter när nya strängar tillkommer.
 *  2. Ingen översättning är tom eller bara whitespace.
 *  3. {platshållare} i källsträngen finns också i översättningen (och inga
 *     nya har hittats på) — annars renderas trasig text i det språket.
 *  4. RTL-språken (ar, prs, fa) innehåller faktiskt RTL-skrift i minst 90 %
 *     av strängarna (fångar en råkopierad LTR-fil).
 *
 *   node --experimental-strip-types tools/i18ncheck.mjs
 *
 * Körs i verify. Ingen nätverksåtkomst, ingen extern data.
 */
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const DIR = join(ROOT, 'apps/web/src/i18n/locales');

const LOCALES = ['sv', 'en', 'so', 'ar', 'prs', 'es', 'fr', 'fa', 'ru', 'ti', 'uk'];
const RTL = new Set(['ar', 'prs', 'fa']);

const dicts = {};
for (const code of LOCALES) {
  const mod = await import(join(DIR, `${code}.ts`));
  dicts[code] = mod[code];
  if (!dicts[code] || typeof dicts[code] !== 'object') {
    console.error(`i18ncheck: ${code}.ts exporterar inte \`${code}\``);
    process.exit(1);
  }
}

const svKeys = Object.keys(dicts.sv);
const placeholders = (s) => [...s.matchAll(/\{([a-zA-Z]+)\}/g)].map((m) => m[1]).sort().join(',');
const hasRtlScript = (s) => /[؀-ۿݐ-ݿ]/.test(s);

let errors = 0;
const fail = (msg) => { console.error(`  FEL  ${msg}`); errors += 1; };

for (const code of LOCALES) {
  if (code === 'sv') continue;
  const dict = dicts[code];
  const keys = Object.keys(dict);
  for (const k of svKeys) if (!(k in dict)) fail(`${code}: saknar nyckeln '${k}'`);
  for (const k of keys) if (!svKeys.includes(k)) fail(`${code}: okänd nyckel '${k}' (finns inte i sv)`);
  for (const [k, v] of Object.entries(dict)) {
    if (typeof v !== 'string' || !v.trim()) fail(`${code}: tom översättning för '${k}'`);
    else if (k in dicts.sv && placeholders(dicts.sv[k]) !== placeholders(v)) {
      fail(`${code}: platshållarna i '${k}' matchar inte källan (sv: {${placeholders(dicts.sv[k])}} ↔ ${code}: {${placeholders(v)}})`);
    }
  }
  if (RTL.has(code)) {
    const vals = Object.values(dict);
    const withScript = vals.filter((v) => hasRtlScript(String(v))).length;
    if (withScript / vals.length < 0.9) {
      fail(`${code}: bara ${withScript}/${vals.length} strängar innehåller RTL-skrift — fel fil?`);
    }
  }
}

// ── Fas B: kunskapsbasens översättningsminne (apps/api/src/seed/i18n/) ──────
// Källmängden = alla summaries + alla unika intakefrågor i seeden. Varje
// KB-språkfil måste täcka EXAKT den mängden: en ny/ändrad källtext utan
// översättning fäller bygget (annars visas tyst svenska på det språket),
// och en föräldralös nyckel avslöjar en källtext som ändrats i seeden.
const { opportunities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const { KB_LOCALES, KB_TRANSLATIONS } = await import(join(ROOT, 'apps/api/src/seed/i18n/index.ts'));
const kbSources = new Set();
for (const o of opportunities) kbSources.add(o.summary);
for (const o of opportunities) for (const c of o.criteria ?? []) if (c.intakeQuestion) kbSources.add(c.intakeQuestion);

for (const code of KB_LOCALES) {
  const dict = KB_TRANSLATIONS[code];
  for (const src of kbSources) {
    const v = dict[src];
    if (typeof v !== 'string' || !v.trim()) fail(`kb/${code}: saknar översättning för källtexten '${src.slice(0, 60)}…'`);
  }
  for (const k of Object.keys(dict)) {
    if (!kbSources.has(k)) fail(`kb/${code}: föräldralös nyckel (källtexten finns inte längre i seeden): '${k.slice(0, 60)}…'`);
  }
  if (RTL.has(code)) {
    const vals = Object.values(dict);
    const withScript = vals.filter((v) => hasRtlScript(String(v))).length;
    if (withScript / vals.length < 0.9) fail(`kb/${code}: bara ${withScript}/${vals.length} strängar innehåller RTL-skrift — fel fil?`);
  }
}

// ── Fas C: publika ytans kurerade strängar (seo/publik-i18n.json) ──────────
// De flerspråkiga landningssidorna byggs av dessa; en lucka i ett språk skulle
// annars rendera en halvsvensk sida (och ett halvt löfte) på det språket.
const PUBLIK = JSON.parse(readFileSync(join(ROOT, 'seo', 'publik-i18n.json'), 'utf8')).sprak;
const publikSvKeys = Object.keys(PUBLIK.sv ?? {});
if (!publikSvKeys.length) fail('publik-i18n.json: sv-blocket saknas (källspråket)');
for (const code of LOCALES) {
  const dict = PUBLIK[code];
  if (!dict) { fail(`publik/${code}: språket saknas i publik-i18n.json`); continue; }
  for (const k of publikSvKeys) {
    const v = dict[k];
    if (typeof v !== 'string' || !v.trim()) fail(`publik/${code}: tom eller saknad sträng '${k}'`);
    else if (placeholders(PUBLIK.sv[k]) !== placeholders(v)) {
      fail(`publik/${code}: platshållarna i '${k}' matchar inte källan`);
    }
  }
  for (const k of Object.keys(dict)) if (!publikSvKeys.includes(k)) fail(`publik/${code}: okänd nyckel '${k}'`);
  if (RTL.has(code)) {
    const vals = Object.values(dict);
    const withScript = vals.filter((v) => hasRtlScript(String(v))).length;
    if (withScript / vals.length < 0.9) fail(`publik/${code}: bara ${withScript}/${vals.length} strängar bär RTL-skrift — fel fil?`);
  }
}

if (errors) {
  console.error(`i18ncheck: ${errors} fel i språkfilerna.`);
  process.exit(1);
}
console.log(`I18N-koll: ${LOCALES.length} språk, ${svKeys.length} nycklar per språk + kunskapsbas ${kbSources.size} källtexter × ${KB_LOCALES.length} språk + publik yta ${publikSvKeys.length} strängar × ${LOCALES.length} språk — komplett och konsistent.`);
