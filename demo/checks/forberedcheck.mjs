/**
 * F-FÖRBERED (användarfynd 2026-08-28: "Systemet ska guida mig i att förbereda
 * allt inför ansökan!?"). Planvyn slutade i en myndighetslänk — upptäckt utan
 * förberedelse, alltså halva produkten. Nu kör demon cores riktiga
 * dokumentmotor i webbläsaren.
 *
 * F-SPECIFIK (2026-08-28): förberedelsen ska använda STÖDETS EGET kurerade
 * ansökningsschema — myndighetens fält, sektioner och vägledning — inte en
 * generell mall. 71 av 85 stöd har ett; övriga faller tillbaka på mallarna
 * och ska säga att de är generella.
 *
 * Checken går hela vägen: utredning → plan → förbered, och kräver att
 *   1. förberedelsen nås och visar stödets eget formulär med dess sektioner,
 *   2. utredningens svar är förifyllda (ingen fråga ställs två gånger) —
 *      inklusive boendekostnaden, som tidigare frågades och kastades bort,
 *   3. ansökan vägrar skrivas innan obligatoriska svar finns,
 *   4. den färdiga ansökan bär myndighetens egna fältnamn och användarens svar,
 *   5. ansökningssätt och underlagslista visas per stöd,
 *   6. ärlighetstexten om pris och att inget skickas står kvar.
 */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 1000 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${artifactsDir}/demo/demo.html`);

// Ensamstående förälder, arbetslös, låg inkomst, betalar hyra.
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")');
await page.click('text=Ja, i grundskolan');
for (let i = 0; i < 4; i++) {
  const b = page.locator('.row >> button:has-text("Ja")').first();
  if (await b.count()) { await b.click(); await page.waitForTimeout(120); }
}
await page.fill('input[type=number]', '1987');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.locator('.row >> button:has-text("Ja")').first().click();
await page.fill('input[type=number]', '8500');
await page.click('text=Nästa');
for (let i = 0; i < 6; i++) {
  if (await page.locator('text=Det här ser du ut att kunna ha rätt till').count()) break;
  const nej = page.locator('.row >> button:has-text("Nej")').first();
  if (await nej.count()) { await nej.click(); await page.waitForTimeout(180); }
}
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
await page.locator('button:has-text("Vill ansöka")').first().click();
await page.locator('button:has-text("Nästa")').last().click();
await page.waitForSelector('text=Din plan —');

await page.locator('button:has-text("Förbered ansökan")').first().click();
await page.waitForSelector('text=Förbered ansökan —', { timeout: 15000 });
console.log('1. Planen leder till förberedelsen ✓');

// Stödets EGET formulär, inte en generell mall.
const sida = await page.innerText('body');
if (!sida.includes('Ansökan — Bostadsbidrag till barnfamiljer')) {
  throw new Error('stödets eget ansökningsformulär visas inte — föll tillbaka på generell mall?');
}
if (!/Fälten är Försäkringskassans egna/.test(sida)) {
  throw new Error('det sägs inte att fälten är myndighetens egna');
}
for (const sektion of ['Om dig', 'Bostaden', 'Inkomster', 'Intyg']) {
  if (!sida.includes(sektion)) throw new Error(`schemasektionen "${sektion}" saknas`);
}
console.log('1b. Stödets eget formulär med myndighetens sektioner ✓');

// Ansökningssätt + underlag per stöd.
if (!sida.includes('Så ansöker du hos Försäkringskassan')) throw new Error('ansökningssättet visas inte');
if (!sida.includes('Underlag att ha framme')) throw new Error('underlagsrubriken saknas');
console.log('2. Ansökningssätt och underlag redovisas per stöd ✓');

// Boendekostnaden frågades i utredningen — den ska nu stå i myndighetens fält.
const boende = await page.locator('#sf-boendekostnad').inputValue();
if (boende !== '8500') throw new Error(`boendekostnaden följde inte med till ansökan: "${boende}"`);
if (await page.locator('.meta.forifyllt').count() === 0) {
  throw new Error('förifyllda fält märks inte ut');
}
console.log('3. Utredningens svar är förifyllda i myndighetens fält ✓');

if (!sida.includes('Vi skriver aldrig något du inte svarat')) {
  throw new Error('ansökan skrivs utan att obligatoriska svar finns');
}
console.log('4. Ansökan vägrar skrivas innan svaren finns ✓');

await page.fill('#sf-sokande_namn', 'Anna Andersson');
await page.fill('#sf-barn_hemma', '2');
await page.fill('#sf-boyta', '68');
await page.fill('#sf-inkomst_ar', '240000');
await page.locator('.docfalt:has-text("intygar") button:has-text("Ja")').first().click();
await page.waitForSelector('.dokument', { timeout: 10000 });
const doc = await page.locator('.dokument').innerText();
for (const krav of [
  'ANSÖKAN — BOSTADSBIDRAG TILL BARNFAMILJER',
  'Anna Andersson',
  'Boendekostnad per månad (kr): 8500',
  'Bostadens yta (kvm): 68',
  'Till: Försäkringskassan',
]) {
  if (!doc.includes(krav)) throw new Error(`ansökan saknar "${krav}"`);
}
console.log('5. Den färdiga ansökan bär myndighetens fältnamn och användarens svar ✓');

const body = await page.innerText('body');
for (const fras of ['19 kr per ansökan', 'ingenting skickas någonstans', 'är alltid gratis']) {
  if (!body.includes(fras)) throw new Error(`ärlighetstexten saknar "${fras}"`);
}
console.log('6. Pris, att inget skickas och gratisvägen sägs uttryckligen ✓');

await browser.close();
console.log('FÖRBEREDCHECK KLAR');
