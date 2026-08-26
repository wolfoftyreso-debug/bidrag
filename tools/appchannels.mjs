/**
 * Ansökningskanal-revision (Task B): för varje stöd i kunskapsbasen — exakt
 * vilka INGÅNGAR (ansökningskanaler) ansökan har som alternativ, och HUR den
 * kan mottas (autentisering/inlämningsväg). Genereras deterministiskt ur
 * sanningsmodellen `apps/api/src/seed/data.ts` — inga påhittade kanaler:
 * kanaltaggarna extraheras ur den kurerade `applicationMethod`-texten +
 * `authenticationMethod`, och stöd med den generiska standardtexten flaggas
 * ärligt som "ospecificerad — kräver kurering".
 *
 *   node --experimental-strip-types tools/appchannels.mjs          # skriv docs/APPLICATION_CHANNELS.md
 *   node --experimental-strip-types tools/appchannels.mjs --check   # i synk? (icke-noll exit vid drift)
 *
 * Deterministisk: sorterad utdata; datum ur seedens CURATED_AT, aldrig klockan.
 * INTE ett npm-skript (undviker MANUAL-reaktivitetsgrinden) — körs manuellt när
 * seedens kanalfält ändras.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'docs', 'APPLICATION_CHANNELS.md');
const CHECK = process.argv.includes('--check');

const { opportunities, authorities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));

const GENERIC = 'Ansökan görs i finansiärens officiella ansökningstjänst.';
const authName = Object.fromEntries((authorities || []).map((a) => [a.key, a.name]));

/**
 * Kanaltaggar (ingångar) — extraheras ur den kurerade metodtexten. En ansökan
 * kan ha flera (t.ex. "e-tjänst eller blankett" → E_TJANST + BLANKETT).
 * Ordningen styr visningsordningen.
 */
const CHANNEL_RULES = [
  ['MINA_SIDOR', /mina sidor/i, 'Mina sidor hos myndigheten'],
  ['E_TJANST', /e-tjänst|onlinetjänst|e-tjänster|webbplats|ansökningssystem|projektrummet|intressentportalen|min ansökan|idrottonline|prisma|funding & tenders|ansökningssystem/i, 'Myndighetens e-tjänst/onlinetjänst'],
  ['BLANKETT', /blankett/i, 'Pappersblankett'],
  ['BESOK', /bokat besök|besök/i, 'Bokat besök'],
  ['MELLANHAND', /optiker|handläggare|rådgivare|kansli|medelsförvaltare|leaderområde|via (din |sin )?kommun|lokala majblommeförening|sparbanksstiftelse|omställningsorganisation/i, 'Via mellanhand (optiker/handläggare/kansli/förvaltare)'],
  ['KONTAKT', /kontakta|skriv in dig/i, 'Kontakt först (inskrivning/handläggare)'],
];

function channelTags(o) {
  if (o.applicationMethod === GENERIC) return [['OSPECIFICERAD', 'Ospecificerad (generisk standardtext) — kräver kurering']];
  const tags = [];
  for (const [key, re, label] of CHANNEL_RULES) {
    if (re.test(o.applicationMethod)) tags.push([key, label]);
  }
  // "e-tjänst eller blankett" o.dyl. — säkra att BLANKETT/BESOK som alternativ fångas
  if (!tags.length) tags.push(['OVRIG', 'Myndighetsspecifik väg (se metodtext)']);
  return tags;
}

/** Hur ansökan kan MOTTAS/autentiseras. */
function reception(o) {
  switch (o.authenticationMethod) {
    case 'eid': return 'e-legitimation (BankID e.dyl.)';
    case 'eu_login': return 'EU Login + OID/PIC';
    case 'kulturradet_konto': return 'Kulturrådskonto';
    case 'mucf_konto': return 'MUCF-konto';
    case 'vinnova_konto': return 'Vinnova-konto (Intressentportalen)';
    case 'none': return 'Ingen inloggning krävs (öppen tjänst/blankett/mellanhand)';
    default: return o.authenticationMethod || '—';
  }
}

// --- Aggregat ---
const rows = opportunities.map((o) => ({
  slug: o.slug,
  title: o.title,
  authority: authName[o.authorityKey] || o.authorityKey,
  authorityKey: o.authorityKey,
  method: o.applicationMethod,
  url: o.applicationUrl,
  reception: reception(o),
  tags: channelTags(o),
  generic: o.applicationMethod === GENERIC,
})).sort((a, b) => a.authority.localeCompare(b.authority, 'sv') || a.slug.localeCompare(b.slug, 'sv'));

const total = rows.length;
const genericRows = rows.filter((r) => r.generic);
const chanCount = {};
for (const r of rows) for (const [k] of r.tags) chanCount[k] = (chanCount[k] || 0) + 1;
const recCount = {};
for (const r of rows) recCount[r.reception] = (recCount[r.reception] || 0) + 1;

const CHAN_LABEL = {
  MINA_SIDOR: 'Mina sidor (myndighet)', E_TJANST: 'E-tjänst/onlinetjänst', BLANKETT: 'Pappersblankett',
  BESOK: 'Bokat besök', MELLANHAND: 'Via mellanhand', KONTAKT: 'Kontakt/inskrivning först',
  OVRIG: 'Myndighetsspecifik väg', OSPECIFICERAD: 'Ospecificerad (kräver kurering)',
};

// --- Rendera ---
const L = [];
L.push('# Ansökningskanal-revision — ingångar per stöd & hur ansökan mottas');
L.push('');
L.push('> **Byggprodukt — redigera aldrig för hand.** Genereras ur sanningsmodellen');
L.push('> (`apps/api/src/seed/data.ts`) av `tools/appchannels.mjs`. Kanaltaggarna');
L.push('> extraheras ur den kurerade `applicationMethod`-texten + `authenticationMethod`;');
L.push('> inga kanaler hittas på. Regenerera efter kanaländringar i seeden:');
L.push('> `node --experimental-strip-types tools/appchannels.mjs`.');
L.push('');
L.push(`Kurerat läge: **${CURATED_AT}**. Stöd i kunskapsbasen: **${total}**.`);
L.push('');
L.push('## Varför den här revisionen finns');
L.push('');
L.push('Produktägaren: *"Vi kontrollerar exakt vilka ingångar alla ansökningar har');
L.push('som alternativ, hur de kan mottas."* Idag lämnas ingen ansökan direkt från');
L.push('systemet — Bidragskoll **förbereder** ansökan och lämnar över till den');
L.push('officiella ingången (Open Discovery: "ansök själv"-länken är alltid gratis).');
L.push('Därför måste varje stöd ha en känd, korrekt ingång och en ärlig beskrivning');
L.push('av hur ansökan tas emot. Denna fil är facit och gap-listan för det.');
L.push('');
L.push('## Sammanfattning');
L.push('');
L.push('**Datatäckning (alla stöd):**');
L.push('');
L.push('| Fält | Täckning |');
L.push('|---|---|');
L.push(`| Officiell ansöknings-URL (\`applicationUrl\`) | ${total - rows.filter((r) => !r.url).length}/${total} |`);
L.push(`| Preciserad kanaltext (ej generisk standard) | ${total - genericRows.length}/${total} |`);
L.push(`| Angiven mottagning/autentisering (\`authenticationMethod\`) | ${total}/${total} |`);
L.push('');
L.push('**Ingångar (kanaltaggar) — antal stöd per kanal (ett stöd kan ha flera):**');
L.push('');
L.push('| Ingång | Antal stöd |');
L.push('|---|---|');
for (const [k, n] of Object.entries(chanCount).sort((a, b) => b[1] - a[1])) {
  L.push(`| ${CHAN_LABEL[k] || k} | ${n} |`);
}
L.push('');
L.push('**Mottagning (hur ansökan tas emot / autentisering) — antal stöd:**');
L.push('');
L.push('| Mottagning | Antal stöd |');
L.push('|---|---|');
for (const [k, n] of Object.entries(recCount).sort((a, b) => b[1] - a[1])) {
  L.push(`| ${k} | ${n} |`);
}
L.push('');
L.push('## Gap — stöd med ospecificerad kanal (generisk standardtext)');
L.push('');
if (!genericRows.length) {
  L.push('Inga. Alla stöd har en preciserad ansökningskanal.');
} else {
  L.push(`**${genericRows.length} stöd** bär fortfarande den generiska texten`);
  L.push(`"${GENERIC}" — den officiella URL:en finns, men den exakta ingången och`);
  L.push('mottagningsvägen är ännu inte kurerad i klartext. Prioriterad kureringskö:');
  L.push('');
  L.push('| Stöd | Myndighet | Mottagning | URL |');
  L.push('|---|---|---|---|');
  for (const r of genericRows) {
    L.push(`| ${r.title} (\`${r.slug}\`) | ${r.authority} | ${r.reception} | ${r.url} |`);
  }
}
L.push('');
L.push('## Fullständig kanalmatris (per myndighet, per stöd)');
L.push('');
let curAuth = null;
for (const r of rows) {
  if (r.authority !== curAuth) {
    curAuth = r.authority;
    const n = rows.filter((x) => x.authority === curAuth).length;
    L.push('');
    L.push(`### ${curAuth} (${n})`);
    L.push('');
    L.push('| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |');
    L.push('|---|---|---|---|---|');
  }
  const tagStr = r.tags.map(([, label]) => label).join(' · ');
  const method = r.method.replace(/\|/g, '\\|');
  L.push(`| ${r.title} (\`${r.slug}\`) | ${tagStr} | ${r.reception} | ${method} | ${r.url} |`);
}
L.push('');
L.push('---');
L.push('');
L.push('*Regenererad av `tools/appchannels.mjs` ur seeden. Antalet stöd, kanaler och');
L.push('mottagningsvägar följer kunskapsbasen automatiskt — filen kan aldrig divergera.*');
L.push('');

const body = L.join('\n');

if (CHECK) {
  let cur = '';
  try { cur = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (cur !== body) {
    console.error(`docs/APPLICATION_CHANNELS.md är inte i synk — kör: node --experimental-strip-types tools/appchannels.mjs`);
    process.exit(1);
  }
  console.log(`APPLICATION_CHANNELS.md i synk (${total} stöd, ${genericRows.length} ospecificerade).`);
} else {
  writeFileSync(OUT, body);
  console.log(`Skrev ${OUT}: ${total} stöd, ${genericRows.length} ospecificerade kanaler, ${Object.keys(chanCount).length} kanaltyper.`);
}
