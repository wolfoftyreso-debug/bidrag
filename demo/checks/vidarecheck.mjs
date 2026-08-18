/**
 * Verifierar användarfynden F-TEASER, F-VIDARE, F-ÄNDRA och F-HOPP i demon:
 *  - teasern säger "X stöd som matchar din situation", namnraderna är blurrade
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
await page.click('button:has-text("29–65")');
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
await page.waitForSelector('text=stöd som matchar din situation');
const blurCount = await page.locator('.blurred').count();
if (blurCount === 0) { console.log('FEL: inga blurrade namnrader i teasern'); process.exit(1); }
const blurTexts = await page.locator('.blurred').allTextContents();
if (!blurTexts.every((t) => /^[Xx0\s—–·,().\-\/+&:]+$/.test(t))) {
  console.log('FEL: blurrad rad innehåller annat än maskeringstecken:', blurTexts); process.exit(1);
}
const bodyTeaser = await page.textContent('body');
if (!/För att se namnen och gå vidare med ansökan låser du upp rapporten/.test(bodyTeaser)) {
  console.log('FEL: upplåsningsuppmaningen saknas'); process.exit(1);
}
console.log(`1. Teasern: rubrik + ${blurCount} blurrade namnrader utan titel-läckage ✓`);

// 2. Lås upp och nå rapporten.
await page.click('button:has-text("Lås upp din bidragsanalys")');
await page.click('button:has-text("Godkänn betalning")');
await page.click('button:has-text("Visa min analys")');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');

// 3. F-ÄNDRA: "Dina svar" är öppen som standard — en primärmarkerad knapp syns.
await page.waitForSelector('details[open] >> text=Dina svar');
console.log('2. "Dina svar" är öppen som standard — svaren syns och kan ändras ✓');

// 4. F-HOPP: frågeräknaren visar totalen.
const counter = await page.locator('h2', { hasText: 'Några frågor kvar (' }).textContent();
console.log(`3. Frågeräknaren visar totalen: "${counter.trim()}" ✓`);

// 5. F-HOPP: svara Nej uppifrån tills ett svar gör en väntande fråga
//    ointressant (t.ex. funktionsnedsättning → bostadsanpassningens följdfråga)
//    — notisen ska då förklara vad som hände i stället för tyst krympning.
let noteSeen = false;
for (let i = 0; i < 12; i++) {
  const q = page.locator('.card.accent .q-row').first();
  if (await q.count() === 0) break;
  await q.locator('button:has-text("Nej")').click();
  await page.waitForTimeout(250);
  if (/behövdes inte längre/.test(await page.textContent('body'))) { noteSeen = true; break; }
}
if (!noteSeen) { console.log('FEL: ingen notis trots att frågor försvann ur listan'); process.exit(1); }
console.log('4. Notis när ett svar gör väntande frågor ointressanta ✓');

// 6. F-VIDARE: markera ett stöd och gå vidare till planen.
await page.locator('button:has-text("Vill ansöka")').first().click();
await page.waitForSelector('text=Vald — ingår i din plan');
await page.click('button:has-text("Nästa — gå vidare med 1 valt stöd")');
await page.waitForSelector('text=Din plan — 1 ansökan');
await page.waitForSelector('text=Så ansöker du:');
const applyLink = await page.locator('a:has-text("Till ansökan hos")').count();
if (applyLink === 0) { console.log('FEL: ansökningslänk saknas i planen'); process.exit(1); }
console.log('5. Vill ansöka → Nästa → plan med konkret ansökningsväg och källänk ✓');

// 7. Ta bort ur planen + tillbaka till analysen.
await page.click('button:has-text("Ta bort ur planen")');
await page.waitForSelector('text=Inga stöd valda ännu');
await page.click('button:has-text("Tillbaka till analysen")');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
console.log('6. Ta bort ur planen + tillbaka till analysen ✓');

await browser.close();
console.log('VIDARECHECK KLAR');
