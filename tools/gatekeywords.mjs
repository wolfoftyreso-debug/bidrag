/**
 * GATE 0 — block A: 300-keyword verification.
 * Bygger seo/gate0-keywords.json: varje rot i seo/keywords.json får
 *   keyword → intent → query-familj → SERP-ägare → vår URL → content gap → status
 * Status (användarens definitioner, docs/ZERO_COMPROMISE_GATE.md):
 *   GREEN  — vi har en exceptionell destination (kräver även mänsklig
 *            granskning + SERP-jämförelse — koden kan bara föreslå, aldrig
 *            sätta GREEN på egen hand: maskinellt max = YELLOW)
 *   YELLOW — bra men inte tillräckligt (sida finns, gold standard ej nådd)
 *   RED    — vi saknar rätt innehåll/verktyg
 *   GREY   — queryn bör egentligen ägas av myndigheten (navigational
 *            myndighetsterm; vår roll är komplementär)
 * SERP-ägare kommer ur seo/serp-gate0.json (familjeobservationer 2026-08-22)
 * med seo/serp-sprint01.json som andra källa; rot utan observation märks
 * verifikation NONE — ägaren lämnas tom i stället för att gissas.
 *
 *   node --experimental-strip-types tools/gatekeywords.mjs          # skriv
 *   node --experimental-strip-types tools/gatekeywords.mjs --check  # i synk?
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const CHECK = process.argv.includes('--check');
const OUT = join(ROOT, 'seo', 'gate0-keywords.json');

const kw = JSON.parse(readFileSync(join(ROOT, 'seo', 'keywords.json'), 'utf8')).keywords;
const { opportunities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const slugs = opportunities.map((o) => o.slug);
const slugify = (s) => s.toLowerCase().replace(/[åä]/g, 'a').replace(/ö/g, 'o').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
// Manuell rot som redan bärs av en entity-sida (t.ex. "bilstöd" → fk-bilstod):
const entityFor = (root) => {
  const norm = slugify(root);
  if (norm.length < 5) return null;
  return slugs.find((s) => s.includes(norm) || norm.split('-').every((w) => w.length > 3 && s.includes(w))) ?? null;
};
const gateSerp = JSON.parse(readFileSync(join(ROOT, 'seo', 'serp-gate0.json'), 'utf8'));
const famById = new Map(gateSerp.familjer.map((f) => [f.familj, f]));

// Kategori/målgrupp → observerad query-familj. Kategorier utan färsk
// observation mappas till null → verifikation NONE (ägare lämnas tom).
const FAM = {
  'boende': 'k16-hjalp-med-hyran', 'ekonomisk-utsatthet': 'k3-forsorjningsstod',
  'familj': 'k18-bidrag-barnfamilj', 'anställa': 'k12-anstalla-med-stod',
  'arbete': 'k19-arbetslos-tidslinjen', 'pension': 'k20-lag-pension',
  'funktionsnedsättning': 's30-barn-funktionsnedsattning', 'förening': 'k22-foreningsbidrag',
  'jordbruk': 'k25-startstod-jordbruk', 'energi': 'k24-laddstation',
  'eu': 'k23-eu-bidrag-foretag', 'starta-företag': 'k13-starta-eget',
  'stipendier': 'k21-fonder-stipendier', 'process': 'p38-avslag',
  'upptäckt': 'k17-vilka-bidrag', 'generisk': 'k17-vilka-bidrag',
  'verktyg': 'verktyg-kalkylator', 'etablering': 's29-ny-i-sverige',
  'unga': 's32-flytta-hemifran', 'sjukdom': 's27-sjukskriven',
  'studier': 'k4-studiemedel', 'brand': 'brand-bidragskoll',
  'idrott': 'ent-lok-stod', 'klimat': 'ent-klimatklivet',
  'kultur': 'ent-skapande-skola', 'civilsamhälle': 'k22-foreningsbidrag',
};
const OVERRIDE = { // rot-nivå där kategorin inte räcker
  'bidrag ensamstående': 'aud-ensamstaende', 'bidrag ensamstående mamma': 'aud-ensamstaende',
  'stipendier studenter': 'aud-stipendier-student', 'stipendier': 'aud-stipendier-student',
  'bidrag solceller': 'energi-solceller', 'csn fribelopp': 'ent-csn-fribelopp',
  'barnbidrag': 'ent-barnbidrag', 'omvårdnadsbidrag': 'ent-omvardnadsbidrag',
  'lok stöd': 'ent-lok-stod', 'a kassa eller försörjningsstöd': 'j40-akassa-forsorjningsstod',
  'försörjningsstöd eller a kassa': 'j40-akassa-forsorjningsstod',
  'bostadsbidrag eller bostadstillägg': 'k2-avgoraren',
  'underhållsstöd eller underhållsbidrag': 'k8-underhall',
  'studiemedel eller omställningsstudiestöd': 'k6-studiestodsvaljaren',
  'nystartsjobb eller lönebidrag': 'k12-anstalla-med-stod',
  'lönebidrag': 'k10-lonebidrag', 'nystartsjobb': 'k11-nystartsjobb',
  'bidragskalender deadlines': 'p39-deadlines', 'ansökningsdatum bidrag': 'p39-deadlines',
  'bidrag 2026': 'p100-andringar-2026', 'nya bidrag 2026': 'p100-andringar-2026',
  'medfinansiering': 'p41-medfinansiering', 'glasögonbidrag': 'k14-glasogonbidrag',
  'bidrag glasögon barn': 'k14-glasogonbidrag', 'bidrag anpassa bostad': 'k15-bostadsanpassning',
};
// Rötter som bärs av en befintlig entity-sida men inte fångas av namnlikhet:
const AUTH_ENTITY = {
  'esf projektstöd': 'esf-kompetensutveckling', 'leader projektstöd': 'leader-lokalt-ledd-utveckling',
  'startstöd unga jordbrukare': 'jordbruksverket-startstod-unga', 'eures mobilitetsstöd': 'af-eures-targeted-mobility',
  'studera utomlands csn': 'csn-utlandsstudier', 'skolskjuts regler': 'kommun-skolskjuts',
  'underhållsbidrag': 'fk-underhallsstod', 'socialbidrag': 'kommun-forsorjningsstod',
  'ekonomiskt bistånd': 'kommun-forsorjningsstod', 'riksnorm': 'kommun-forsorjningsstod',
  'studiebidrag': 'csn-studiemedel', 'studielån': 'csn-studiemedel',
  'vetenskapsrådet bidrag': 'vr-projektbidrag', 'konstnärsstipendium': 'konstnarsnamnden-arbetsstipendium',
  'arbetsstipendium konstnär': 'konstnarsnamnden-arbetsstipendium', 'bidrag samlingslokal': 'boverket-allmanna-samlingslokaler',
  'busskort gymnasiet bidrag': 'kommun-elevresor-gymnasiet', 'bidrag glasögon barn': 'region-glasogonbidrag-barn',
  'bidrag anpassa bostad': 'kommun-bostadsanpassningsbidrag', 'låg pension hjälp': 'pm-aldreforsorjningsstod',
  'återvandringsbidrag': 'migrationsverket-atervandringsbidrag', 'starta eget bidrag': 'af-stod-start-naringsverksamhet',
};
// Angränsande termer (automatiska/försäkringsbaserade/skatteavdrag) — utanför
// kärnan per keywords.json-noterna; myndigheten/etablerade aktörer ska äga.
const ANGRANSANDE = new Set(['barnbidrag', 'flerbarnstillägg', 'föräldrapenning', 'vab ersättning',
  'sjukpenning', 'sjukersättning', 'garantipension', 'tandvårdsbidrag', 'högkostnadsskydd',
  'elstöd', 'rot avdrag', 'grön teknik avdrag', 'a kassa', 'aktivitetsstöd', 'gårdsstöd',
  'existensminimum', 'körkortslån', 'ersättning arbetslös', 'ersättning vid sjukdom', 'skatt på bidrag']);
// Kluster 10–12-stöden finns inte i kunskapsbasen — RED med kureringsgap.
const KB_GAP = new Set(['lönebidrag', 'nystartsjobb', 'introduktionsjobb', 'anställningsstöd',
  'bidrag för att anställa', 'hjälp med lönekostnad', 'stöd anställa arbetslös', 'nystartsjobb eller lönebidrag']);
// Rötter vars sidor redan finns som hubbar.
const HUB = { 'bidrag företag': '/bidrag/foretag/', 'företagsstöd': '/bidrag/foretag/',
  'bidrag förening': '/bidrag/foreningar/', 'föreningsbidrag': '/bidrag/foreningar/',
  'bidrag privatperson': '/bidrag/privatpersoner/', 'statsbidrag': '/bidrag/offentlig-sektor/',
  'bidrag': '/bidrag/', 'bidrag och stöd': '/bidrag/', 'vilka bidrag finns': '/bidrag/' };

const rows = kw.map((k) => {
  const fam = OVERRIDE[k.root_keyword] ?? (k.entity ? null : FAM[k.category] ?? null);
  const famObs = fam ? famById.get(fam) : null;
  const matchedEntity = k.entity ?? AUTH_ENTITY[k.root_keyword]
    ?? (k.source === 'manual:authority-term' && !KB_GAP.has(k.root_keyword) ? entityFor(k.root_keyword) : null);
  const ourUrl = k.our_target_url ?? (matchedEntity && !k.entity ? `/bidrag/${matchedEntity}/` : null) ?? HUB[k.root_keyword] ?? null;
  const angransande = /angränsande/.test(k.notes ?? '') || ANGRANSANDE.has(k.root_keyword);
  let status, gap, verifikation;
  if (KB_GAP.has(k.root_keyword)) {
    status = 'RED';
    gap = 'stödet saknas i kunskapsbasen (kluster 10–12) — kurera före sidbygge';
  } else if (angransande && !matchedEntity) {
    status = 'GREY';
    gap = 'angränsande myndighetsterm utanför kärnan (automatiskt/försäkringsbaserat stöd) — orienteringsinnehåll, aldrig huvudmål';
  } else if (matchedEntity) {
    // Entity-rot: sida finns. Navigational myndighetsterm → GREY (komplementär);
    // informational → YELLOW (11/18 moduler ≠ gold standard).
    status = k.intent === 'navigational' ? 'GREY' : 'YELLOW';
    gap = status === 'GREY'
      ? 'myndigheten ska äga sin egen ansökningsterm; vår sida är komplementär (pre-check + helhet)'
      : 'entity-sidan finns men saknar gold standard-moduler (FAQ, exempel, ändringshistorik, interaktiv behörighetskontroll)';
  } else if (ourUrl) {
    status = 'YELLOW';
    gap = 'hubb finns men är lista, inte svar — samlingsvyn B1 krävs för frågeformen';
  } else {
    status = 'RED';
    gap = famObs?.feasibility?.startsWith('ETTA')
      ? 'sidan/verktyget är inte byggt (blueprint-kön B1–B10 / 25-klusterfasen)'
      : 'sidan är inte byggd; angrip-runt-läge — behovsvinkeln, inte termen';
  }
  if (k.category === 'brand') { status = 'RED'; gap = 'brand-SERP ägs av namngrannen; kräver deploy + entity footprint (C4)'; }
  if (famObs) verifikation = fam.startsWith('ent-') || k.entity ? 'FRESH-FAMILJ 2026-08-22' : 'FRESH 2026-08-22';
  else if (k.entity) verifikation = 'MÖNSTER (6 entity-stickprov 2026-08-22 + Sprint 01)';
  else verifikation = 'NONE — ägare ej observerad, lämnas tom';
  return {
    keyword: k.keyword, root: k.root_keyword, intent: k.intent,
    query_familj: fam ?? (k.entity ? `entity:${k.entity}` : null),
    serp_agare: famObs?.agare ?? null,
    var_url: ourUrl, content_gap: gap, status, verifikation,
  };
});

const antal = { GREEN: 0, YELLOW: 0, RED: 0, GREY: 0 };
for (const r of rows) antal[r.status]++;
const out = {
  _kontrakt: 'GATE 0 block A (docs/ZERO_COMPROMISE_GATE.md): statusregister för alla keyword-rötter. GREEN kan aldrig sättas maskinellt — kräver mänsklig SERP-jämförelse sida-mot-sida (gatens manuella del). SERP-ägare endast där observation finns (seo/serp-gate0.json / serp-sprint01.json); rader med verifikation NONE har medvetet tom ägare. Genereras av tools/gatekeywords.mjs — redigeras aldrig för hand.',
  datum_serp: gateSerp.datum,
  antal_rotter: rows.length,
  status: antal,
  rotter: rows,
};
const json = JSON.stringify(out, null, 1) + '\n';
if (CHECK) {
  const cur = readFileSync(OUT, 'utf8');
  if (cur !== json) { console.error('gate0-keywords.json är inte i synk — kör npm run gate:keywords'); process.exit(1); }
  console.log(`gate0-keywords --check: OK (${rows.length} rötter: ${antal.GREEN} GREEN / ${antal.YELLOW} YELLOW / ${antal.RED} RED / ${antal.GREY} GREY)`);
} else {
  writeFileSync(OUT, json);
  console.log(`skrev seo/gate0-keywords.json: ${rows.length} rötter — GREEN ${antal.GREEN} · YELLOW ${antal.YELLOW} · RED ${antal.RED} · GREY ${antal.GREY}`);
}
