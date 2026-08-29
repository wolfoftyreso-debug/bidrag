#!/usr/bin/env node --experimental-strip-types
/**
 * I18N-täckningsmätare (docs/I18N_PROGRAM.md §Täckningen i siffror).
 *
 * tools/i18ncheck.mjs vaktar att översättningsminnet är KOMPLETT mot sin egen
 * definierade källmängd (fas B: sammanfattningar + intakefrågor). Den säger
 * däremot ingenting om hur stor del av kunskapsbasens användarvända text som
 * ÖVER HUVUD TAGET ingår i den mängden — och den andelen sjunker varje gång
 * ny svensk text kureras in (ansökningsscheman, underlagslistor, belopp).
 *
 * Det här skriptet mäter just det, per innehållstyp, så att gapet är en
 * uppmätt siffra och inte en känsla. Det fäller inget bygge: en otolkad
 * villkorstext är ett kureringsläge, inte ett fel. Kör manuellt:
 *
 *   node tools/i18ncov.mjs           # tabell
 *   node tools/i18ncov.mjs --missing # + de otolkade källtexterna per typ
 */
import { opportunities, applicationSchemaDefs } from '../apps/api/src/seed/data.ts';
import { KB_TRANSLATIONS, KB_LOCALES } from '../apps/api/src/seed/i18n/index.ts';

const visaSaknade = process.argv.includes('--missing');

// Alla tio språken täcker exakt samma källmängd (i18ncheck fäller annars),
// så en av dem räcker för att avgöra vilka källtexter som är översatta.
const minne = KB_TRANSLATIONS[KB_LOCALES[0]];
const finns = (s) => Object.prototype.hasOwnProperty.call(minne, s);

const typer = new Map();
const rakna = (typ, text) => {
  if (typeof text !== 'string' || !text.trim()) return;
  if (!typer.has(typ)) typer.set(typ, { antal: 0, oversatta: 0, saknade: new Set() });
  const t = typer.get(typ);
  t.antal++;
  if (finns(text)) t.oversatta++;
  else t.saknade.add(text);
};

for (const o of opportunities) {
  rakna('summary — stödets sammanfattning', o.summary);
  rakna('applicationMethod — så ansöker du', o.applicationMethod);
  rakna('amountNote — belopp', o.amountNote);
  for (const c of o.criteria ?? []) {
    rakna('criteria.intakeQuestion — intagsfråga', c.intakeQuestion);
    rakna('criteria.description — villkorstext', c.description);
  }
  for (const e of o.evidenceRequirements ?? []) rakna('evidence.description — underlag', e.description);
}

for (const { def } of applicationSchemaDefs ?? []) {
  rakna('schema.title — formulärets titel', def.title);
  for (const s of def.sections ?? []) rakna('schema.sectionTitle — formulärsektion', s.title);
  for (const f of def.fields ?? []) {
    rakna('schema.fieldLabel — fältetikett', f.label);
    rakna('schema.fieldGuidance — fältvägledning', f.guidance);
  }
}

const rader = [...typer.entries()].sort((a, b) => a[1].oversatta / a[1].antal - b[1].oversatta / b[1].antal);
const bredd = Math.max(...rader.map(([namn]) => namn.length));
let antal = 0;
let oversatta = 0;

console.log('I18N-täckning i kunskapsbasen — andel användarvänd text som har en');
console.log('post i översättningsminnet (och därmed levereras på alla tio språken).\n');
for (const [namn, t] of rader) {
  antal += t.antal;
  oversatta += t.oversatta;
  const pct = Math.round((100 * t.oversatta) / t.antal);
  console.log(
    `${String(pct).padStart(4)}%  ${String(t.oversatta).padStart(4)}/${String(t.antal).padEnd(5)} ` +
      `${namn.padEnd(bredd)}  otolkade unika: ${t.saknade.size}`,
  );
}
console.log(
  `\nTOTALT ${oversatta}/${antal} förekomster (${Math.round((100 * oversatta) / antal)} %) · ` +
    `${Object.keys(minne).length} källtexter × ${KB_LOCALES.length} språk i minnet.`,
);

if (visaSaknade) {
  for (const [namn, t] of rader) {
    if (t.saknade.size === 0) continue;
    console.log(`\n── ${namn} (${t.saknade.size} otolkade) ──`);
    for (const s of [...t.saknade].sort()) console.log('  ' + s);
  }
}
