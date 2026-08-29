/**
 * Beloppsvakten (F-BELOPP). Beloppet är det användaren mest vill veta, och
 * mönsterkontrollen mot Mobbin visade att det är resultatradens tyngsta
 * element i alla jämförbara produkter. Men ett belopp som inte stämmer är
 * värre än inget belopp alls: red team F1 slog fast att kunskapsbasen hellre
 * säger "varierar, se källan" än gissar.
 *
 * Därför: `amountNote` får bara finnas tillsammans med `amountSourceUrl`, och
 * noten måste innehålla en verklig sifferuppgift. Ingen får smyga in ett
 * ungefär eller ett belopp utan spårbar källa.
 *
 * Körs i npm run verify. Exit 1 vid fel.
 */
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const { opportunities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));

const fel = [];
// Vaga formuleringar hör inte hemma i ett beloppspåstående — då ska fältet
// vara tomt i stället, så att ytan säger "kontrollera hos källan".
const VAGT = /\b(cirka|ca\.?|ungefär|runt|omkring|upp emot|kanske|troligen)\b/i;

let medNot = 0;
for (const o of opportunities) {
  const note = o.amountNote;
  const src = o.amountSourceUrl;
  if (!note && !src) continue;
  if (!note && src) { fel.push(`${o.slug}: amountSourceUrl utan amountNote`); continue; }
  medNot += 1;
  if (!src) fel.push(`${o.slug}: amountNote saknar källa (amountSourceUrl)`);
  else if (!/^https:\/\//.test(src)) fel.push(`${o.slug}: amountSourceUrl är inte en https-adress: ${src}`);
  if (!/\d/.test(note)) fel.push(`${o.slug}: amountNote innehåller ingen sifferuppgift: "${note}"`);
  if (VAGT.test(note)) fel.push(`${o.slug}: amountNote är vagt formulerat — ange källans exakta uppgift eller lämna fältet tomt: "${note}"`);
  if (note.length > 400) fel.push(`${o.slug}: amountNote är ${note.length} tecken — håll det till radens korta sanning`);
}

if (fel.length) {
  console.error('BELOPPSVAKTEN FÄLLER:');
  for (const f of fel) console.error(`  - ${f}`);
  process.exit(1);
}
console.log(`Beloppsvakten OK: ${medNot} av ${opportunities.length} stöd har kurerat belopp, alla med källa`);
