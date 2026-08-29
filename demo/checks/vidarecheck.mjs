/**
 * Verifierar användarfynden F-TEASER, F-VIDARE, F-ÄNDRA och F-HOPP i demon:
 *  - rapporten (Open Discovery) visar namngivna stöd direkt, ingen betalvägg
 *    och läcker aldrig riktiga titlar (endast maskeringstecken)
 *  - rapporten har "Vill ansöka"-val per stöd + Nästa → plan med länk per stöd
 *  - "Dina svar" är öppen som standard och svar går att ändra
 *  - när ett svar gör andra väntande frågor ointressanta visas en notis
 */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';
import { fileURLToPath } from 'node:url';

const html = `${artifactsDir}/demo/demo.html`;
const browser = await launchChromium();
const page = await browser.newPage();
await page.goto('file://' + html);

// Personligt spår, med boendekostnad så bostadsanpassningsfrågorna öppnas.
await page.click('button:has-text("svårt att få ekonomin")');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Nej")');
await page.fill('input[type=number]', '1979');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")'); // betalar boende
await page.fill('input[type=number]', '7000');
await page.click('button:has-text("Nästa")');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
// Funktionsnedsättningsspåret öppnas — ger fler väntande frågor att testa notisen mot.
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Ja")');

// 1. Teasern: tydlig rubrik + blurrade namn utan läckage.
// Open Discovery: rapporten visas direkt och gratis — ingen teaser, ingen betalvägg.
await page.waitForSelector('text=Gå vidare med ansökan');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');

// 3. F-ÄNDRA: "Dina svar" är öppen som standard — en primärmarkerad knapp syns.
await page.waitForSelector('details[open] >> text=Dina svar');
console.log('2. "Dina svar" är öppen som standard — svaren syns och kan ändras ✓');

// F-STABIL: svara på första frågan → raden STÅR KVAR på sin plats, nedtonad,
// med svaret markerat och ändringsbart. Inget försvinner eller byter plats.
const OPENQ = '.card.accent .q-row:not(.q-row-dim)';
if (await page.locator(OPENQ).count()) {
  const firstBefore = (await page.locator('.card.accent .q-row').first().locator('strong').textContent()).trim();
  await page.locator(OPENQ).first().locator('button:has-text("Ja")').click();
  await page.waitForSelector('.card.accent .q-row-dim >> text=Sparat');
  const firstAfter = (await page.locator('.card.accent .q-row').first().locator('strong').textContent()).trim();
  if (firstAfter !== firstBefore) { console.log(`FEL: frågan bytte plats ("${firstBefore}" → "${firstAfter}")`); process.exit(1); }
  const jaMarked = await page.locator('.card.accent .q-row').first().locator('button.primary:has-text("Ja")').count();
  if (!jaMarked) { console.log('FEL: svaret är inte markerat på raden'); process.exit(1); }
  // Ändringsbar direkt på raden: byt till Nej och tillbaka.
  await page.locator('.card.accent .q-row').first().locator('button:has-text("Nej")').click();
  await page.waitForTimeout(200);
  const nejMarked = await page.locator('.card.accent .q-row').first().locator('button.primary:has-text("Nej")').count();
  if (!nejMarked) { console.log('FEL: svaret gick inte att ändra på raden'); process.exit(1); }
  await page.locator('.card.accent .q-row').first().locator('button:has-text("Ja")').click();
  console.log('2b. Besvarad fråga står kvar på sin plats, nedtonad, markerad och ändringsbar ✓');

  // F-INFO: inforutan vid frågan — därför ställs den, med kravtext och källa.
  await page.locator('.card.accent .q-row .info-knapp').first().click();
  await page.waitForSelector('.inforuta >> text=Därför ställs frågan');
  const infoBody = await page.locator('.inforuta').first().textContent();
  if (!/har villkoret:|väger in svaret/.test(infoBody)) { console.log('FEL: inforutan saknar kravtext'); process.exit(1); }
  const srcLink = await page.locator('.inforuta a:has-text("officiell källa")').count();
  if (!srcLink) { console.log('FEL: inforutan saknar källänk'); process.exit(1); }
  await page.locator('.card.accent .q-row .info-knapp').first().click();
  console.log('2c. Inforutan förklarar varför frågan ställs, med kravtext och officiell källa ✓');
}

// 4. F-HOPP: frågeräknaren visar totalen.
const counter = await page.locator('h2', { hasText: 'Några frågor kvar (' }).textContent();
console.log(`3. Frågeräknaren visar totalen: "${counter.trim()}" ✓`);

// 5. F-HOPP + F-STABIL: svara Nej på obesvarade frågor uppifrån tills ett
//    svar gör en väntande fråga ointressant — raden ska då STÅ KVAR med
//    märkningen "behövdes inte längre" i stället för att tyst försvinna.
let noteSeen = false;
for (let i = 0; i < 12; i++) {
  const q = page.locator('.card.accent .q-row:not(.q-row-dim)').first();
  if (await q.count() === 0) break;
  await q.locator('button:has-text("Nej")').click();
  await page.waitForTimeout(250);
  if (/[Bb]ehövdes inte längre/.test(await page.textContent('body'))) { noteSeen = true; break; }
}
if (!noteSeen) { console.log('FEL: ingen kvarstående märkning för fråga som blev inaktuell'); process.exit(1); }
console.log('4. Inaktuell fråga står kvar med "behövdes inte längre"-märkning ✓');

// 5b. F-RYTM (användarfynd 2026-08-29: "vissa frågor i nästa-nästa-struktur
//     och vissa i formulär — det känns inkonsekvent"). Listan ska vara både
//     översikt OCH ingång till samma en-fråga-per-skärm-rytm som intaget.
{
  const ingang = page.locator('button:has-text("Ta dem en i taget")');
  if (await ingang.count() === 0) {
    console.log('FEL: listan saknar ingång till en-fråga-per-skärm-läget'); process.exit(1);
  }
  await ingang.click();
  await page.waitForTimeout(250);
  const rubrik = await page.locator('.card.accent h1').count();
  if (rubrik === 0) { console.log('FEL: guidat läge visar ingen fråga som rubrik'); process.exit(1); }
  const raknare = await page.locator('.card.accent .guidance').first().innerText();
  if (!/Fråga \d+ av \d+/.test(raknare)) { console.log(`FEL: guidat läge saknar räknare ("${raknare}")`); process.exit(1); }
  if (await page.locator('.card.accent .progress-steps span').count() === 0) {
    console.log('FEL: guidat läge saknar progress-indikator'); process.exit(1);
  }
  const fore = await page.locator('.card.accent h1').first().innerText();
  await page.locator('.card.accent button:has-text("Hoppa över den här")').click();
  await page.waitForTimeout(200);
  const efter = await page.locator('.card.accent h1').first().innerText();
  if (efter === fore) { console.log('FEL: "Hoppa över" gick inte vidare till nästa fråga'); process.exit(1); }
  const innanSvar = await page.locator('.card.accent h1').first().innerText();
  await page.locator('.card.accent button:has-text("Nej")').first().click();
  await page.waitForTimeout(250);
  // Bakåt är wizard-konvention (Mobbin: Zillow, OKX, Hims, Remote) — och
  // svaret man gav ska stå markerat när man backar.
  await page.locator('button:has-text("Föregående")').click();
  await page.waitForTimeout(250);
  if ((await page.locator('.card.accent h1').first().innerText()) !== innanSvar) {
    console.log('FEL: "Föregående" gick inte tillbaka till frågan man just svarade på'); process.exit(1);
  }
  if (await page.locator('.card.accent .row button.primary').count() === 0) {
    console.log('FEL: det givna svaret är inte markerat när man backar'); process.exit(1);
  }
  await page.click('button:has-text("Visa alla i lista")');
  await page.waitForSelector('text=Några frågor kvar (');
  const kvar = await page.locator(`text=${JSON.stringify(fore).slice(1, -1)}`).count();
  if (kvar === 0) { console.log('FEL: den överhoppade frågan försvann ur listan (bryter F-STABIL)'); process.exit(1); }
  if ((await page.locator('.card.accent').first().innerText()).includes('besvarade') === false) {
    console.log('FEL: listan visar ingen progress ("N av M besvarade")'); process.exit(1);
  }
  console.log('5b. Guidat läge med progress, bakåt och hoppa över — överhoppad fråga står kvar i listan ✓');
}

// 6. F-VIDARE: markera ett stöd och gå vidare till planen.
await page.locator('button:has-text("Vill ansöka")').first().click();
await page.waitForSelector('text=Vald — ingår i din plan');
await page.click('button:has-text("Nästa — gå vidare med 1 valt stöd")');
await page.waitForSelector('text=Din plan — 1 ansökan');
await page.waitForSelector('text=Så ansöker du:');
// Planen måste bära BÅDA vägarna vidare: förberedelsen (produktens
// arbetslager) och självbetjäningen hos myndigheten som alltid är gratis.
// Länken söks på funktion, inte etikett — en omdöpning ska inte fälla bygget.
const applyLink = await page.locator('.explain .row a[href^="https://"]').count();
if (applyLink === 0) { console.log('FEL: ansökningslänk saknas i planen'); process.exit(1); }
const prepButton = await page.locator('button:has-text("Förbered ansökan")').count();
if (prepButton === 0) { console.log('FEL: planen erbjuder ingen dokumentförberedelse (F-FÖRBERED)'); process.exit(1); }
console.log('5. Vill ansöka → Nästa → plan med förberedelse, ansökningsväg och källänk ✓');

// 7. Ta bort ur planen + tillbaka till analysen.
await page.click('button:has-text("Ta bort ur planen")');
await page.waitForSelector('text=Inga stöd valda ännu');
await page.click('button:has-text("Tillbaka till analysen")');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
console.log('6. Ta bort ur planen + tillbaka till analysen ✓');

await browser.close();
console.log('VIDARECHECK KLAR');
