#!/usr/bin/env node
/**
 * Entitetsgrafens vakt (SCHEMA-ENTITET).
 *
 * Structured data får bara påstå sådant som (a) står i kunskapsbasen och
 * (b) syns på sidan. Den här vakten kontrollerar båda leden mot den
 * genererade ytan, så att grafen inte kan glida ifrån seeden.
 *
 * Den vaktar SANNING, inte närvaro av så många @type som möjligt: en
 * egenskap som saknas i seeden SKA saknas i markupen.
 */
import { readFileSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = join(ROOT, 'artifacts', 'seo-site');
const { opportunities, authorities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const authByKey = Object.fromEntries(authorities.map((a) => [a.key, a]));

const fel = [];
const filer = execSync(`find ${SITE} -name index.html`, { encoding: 'utf8' }).trim().split('\n');

// 1. All JSON-LD på hela ytan måste vara parsbar.
const grafPer = new Map();
for (const f of filer) {
  const html = readFileSync(f, 'utf8');
  const blk = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)];
  if (!blk.length) { fel.push(`${f}: saknar JSON-LD helt`); continue; }
  const noder = [];
  for (const b of blk) {
    try { const j = JSON.parse(b[1]); noder.push(...(j['@graph'] ?? [j])); }
    catch (e) { fel.push(`${f}: JSON-LD går inte att parsa (${e.message})`); }
  }
  grafPer.set(f, noder);
}

// 2. Varje stödsida ska bära stödet som egen nod med rätt utgivare.
let kontrollerade = 0;
for (const o of opportunities) {
  const f = join(SITE, 'bidrag', o.slug, 'index.html');
  const noder = grafPer.get(f);
  if (!noder) { fel.push(`${o.slug}: entity-sidan saknas i den byggda ytan`); continue; }
  kontrollerade++;
  const stod = noder.find((n) => String(n['@id'] ?? '').endsWith('#stod'));
  if (!stod) { fel.push(`${o.slug}: ingen stödnod (#stod) i grafen`); continue; }

  const auth = authByKey[o.authorityKey];
  if (auth) {
    const prov = noder.find((n) => n['@id'] === stod.provider?.['@id']);
    if (!prov) fel.push(`${o.slug}: provider pekar på en nod som inte finns i grafen`);
    else if (prov.name !== auth.name) fel.push(`${o.slug}: provider heter "${prov.name}" men seeden säger "${auth.name}"`);
  }

  // 3. Datum får BARA finnas när seeden har dem (aldrig ett uppdiktat fönster).
  const harDatum = Boolean(o.opensAt || o.closesAt);
  if (Boolean(stod.hoursAvailable) !== harDatum) {
    fel.push(`${o.slug}: ansökningsperiod i markupen=${Boolean(stod.hoursAvailable)} men i seeden=${harDatum}`);
  }

  // 4. Namn och beskrivning måste vara seedens — inte omskrivna för schemats skull.
  if (stod.description !== o.summary) fel.push(`${o.slug}: stödnodens description är inte seedens summary`);
  if (stod.sameAs && stod.sameAs !== o.sourceUrl) fel.push(`${o.slug}: sameAs pekar inte på seedens sourceUrl`);

  // 5. Det markupen påstår om utgivaren ska också SYNAS på sidan.
  if (auth) {
    const html = readFileSync(f, 'utf8');
    if (!html.includes(auth.name)) fel.push(`${o.slug}: "${auth.name}" står i JSON-LD men syns inte i sidans text`);
  }
}

// 6. Finansiärssidorna: aktören som EGEN nod med rätt typ, och samma @id som
//    provider-noderna på stödsidorna — annars pekar provider i tomma luften.
const KIND_TYP = { state_agency: 'GovernmentOrganization', municipality: 'GovernmentOrganization', region: 'GovernmentOrganization', eu: 'GovernmentOrganization', foundation: 'Organization', association: 'Organization' };
let aktorsidor = 0;
for (const auth of authorities) {
  const f = join(SITE, 'finansiarer', auth.key, 'index.html');
  const noder = grafPer.get(f);
  if (!noder) continue; // finansiärer utan stöd får ingen sida
  aktorsidor++;
  const id = `https://bidragskoll.se/#aktor-${auth.key}`;
  const nod = noder.find((n) => n['@id'] === id);
  if (!nod) { fel.push(`finansiarer/${auth.key}: aktörsnoden saknas (@id ${id}) — provider på stödsidorna pekar då ingenstans`); continue; }
  const vantad = KIND_TYP[auth.kind] ?? 'Organization';
  if (nod['@type'] !== vantad) fel.push(`finansiarer/${auth.key}: typad ${nod['@type']} men kind="${auth.kind}" ⇒ ${vantad}`);
  if (nod.name !== auth.name) fel.push(`finansiarer/${auth.key}: heter "${nod.name}" i grafen men "${auth.name}" i seeden`);
}

// 7. Varje ItemList måste spegla en LISTA SOM FAKTISKT SYNS: alla dess
//    poster ska förekomma som länkar i sidans HTML. En lista i markupen som
//    inte finns i texten är påhittat innehåll.
for (const [f, noder] of grafPer) {
  const html = readFileSync(f, 'utf8');
  for (const n of noder) {
    const t = Array.isArray(n['@type']) ? n['@type'] : [n['@type']];
    if (!t.includes('ItemList')) continue;
    const poster = n.itemListElement ?? [];
    if (n.numberOfItems !== undefined && n.numberOfItems !== poster.length) {
      fel.push(`${f}: ItemList säger ${n.numberOfItems} poster men har ${poster.length}`);
    }
    const saknas = poster.filter((p) => p.url && !html.includes(p.url.replace('https://bidragskoll.se', '')));
    if (saknas.length) fel.push(`${f}: ${saknas.length} ItemList-poster länkas inte på sidan (t.ex. ${saknas[0].url})`);
  }
}

// 8. Ingen Article/NewsArticle: sidorna är referenssidor, inte artiklar
//    (docs/PREFERRED_SOURCES.md §6 — schema får bara beskriva det som finns).
for (const [f, noder] of grafPer) {
  for (const n of noder) {
    const t = Array.isArray(n['@type']) ? n['@type'] : [n['@type']];
    if (t.some((x) => x === 'Article' || x === 'NewsArticle' || x === 'BlogPosting')) {
      fel.push(`${f}: ${t.join('+')} — referenssidor får inte stämplas som artiklar`);
    }
  }
}

if (fel.length) {
  console.error(`SCHEMA-ENTITET: ${fel.length} fel`);
  for (const f of fel.slice(0, 25)) console.error('  ✗', f);
  if (fel.length > 25) console.error(`  … och ${fel.length - 25} till`);
  process.exit(1);
}
console.log(`Schema-entitetsvakten: ${kontrollerade} stödsidor + ${aktorsidor} aktörssidor — utgivare, geografi, målgrupp, listor och datum stämmer med seeden och med sidans synliga innehåll.`);
