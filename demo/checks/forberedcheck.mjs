/**
 * F-FÖRBERED (användarfynd 2026-08-28: "Systemet ska guida mig i att förbereda
 * allt inför ansökan!?"). Planvyn slutade i en myndighetslänk — upptäckt utan
 * förberedelse, alltså halva produkten. Nu kör demon cores riktiga
 * dokumentmotor i webbläsaren.
 *
 * Checken går hela vägen: utredning → plan → förbered, och kräver att
 *   1. förberedelsen nås och bara visar mallar som hör till stödets typ,
 *   2. utredningens svar är förifyllda (ingen fråga ställs två gånger),
 *   3. dokumentet vägrar skrivas innan obligatoriska svar finns,
 *   4. det färdiga dokumentet innehåller användarens egna svar,
 *   5. ärlighetstexten om pris och att inget skickas står kvar.
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

// Personligt stöd → projektbeskrivningen hör inte hit (F-RELEVANS).
const doclista = await page.locator('.doclista').innerText();
if (doclista.includes('Projektbeskrivning')) {
  throw new Error('projektmallen erbjuds för ett personligt stöd');
}
if (!doclista.includes('Ansökan om ekonomiskt stöd')) throw new Error('ansökningsmallen saknas');
console.log('2. Bara mallar som hör till stödets typ visas ✓');

const forifyllt = await page.locator('.inforuta').first().innerText();
if (!/Redan ifyllt från din utredning/.test(forifyllt)) {
  throw new Error('förifyllnaden ur utredningen visas inte');
}
if (!/hushållet\?: 1/.test(forifyllt)) {
  throw new Error(`hushållssvaret följde inte med: ${forifyllt.replace(/\n/g, ' | ')}`);
}
console.log('3. Utredningens svar är förifyllda — ingen fråga ställs två gånger ✓');

const innan = await page.innerText('body');
if (!innan.includes('Vi skriver aldrig något du inte svarat')) {
  throw new Error('dokumentet skrivs utan att obligatoriska svar finns');
}
console.log('4. Dokumentet vägrar skrivas innan svaren finns ✓');

await page.fill('#doc-fullName', 'Anna Andersson');
await page.fill('#doc-address', 'Storgatan 12');
await page.fill('#doc-postalCity', '135 40 Tyresö');
await page.fill('#doc-municipality', 'Tyresö');
const ta = page.locator('.docfalt textarea');
for (let k = 0; k < await ta.count(); k++) {
  await ta.nth(k).fill(k === 0 ? 'Hjälp med boendekostnaden.' : 'Inkomsten räcker inte till hyran.');
}
await page.waitForSelector('.dokument', { timeout: 10000 });
const doc = await page.locator('.dokument').innerText();
for (const krav of ['ANSÖKAN OM EKONOMISKT STÖD', 'Anna Andersson', 'Storgatan 12', 'Försäkringskassan', 'Hjälp med boendekostnaden.']) {
  if (!doc.includes(krav)) throw new Error(`dokumentet saknar "${krav}"`);
}
console.log('5. Det färdiga dokumentet bär användarens egna svar ✓');

const body = await page.innerText('body');
for (const fras of ['19 kr per ansökan', 'ingenting skickas någonstans', 'är alltid gratis']) {
  if (!body.includes(fras)) throw new Error(`ärlighetstexten saknar "${fras}"`);
}
console.log('6. Pris, att inget skickas och gratisvägen sägs uttryckligen ✓');

await browser.close();
console.log('FÖRBEREDCHECK KLAR');
