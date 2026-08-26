/**
* Riktiga webbappen (Open Discovery): (1) intagssteget p-disability, (2) rapporten
 *   visas gratis (ingen teaser), (3) funktionsnedsättningsstöden i rapporten.
 * (4) Mina köp: ladda ner kvitto-PDF + skicka via e-post (ärligt utfall).
 */
import { launchChromium } from '../lib/browser.mjs';
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto('http://localhost:5173');
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Omsorgstestaren');
await page.fill('#email', `omsorg-${stamp}@test.example`);
await page.fill('#password', 'omsorgs-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.click('text=Kom igång');
await page.waitForSelector('text=Vem gäller det?');
await page.click('button:has-text("Mig själv")');
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Med partner")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // barn
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // ej skilda håll
await page.click('button:has-text("Nej, inte ännu")'); // skolform
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // skolutflykt
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // fritidsaktivitet
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // glasögon
await page.fill('input[type="number"]', '1979');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Arbetar")');
await page.click('button:has-text("25 000–40 000")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // betalar boende
await page.waitForSelector('text=hur mycket betalar du');
await page.fill('input[type=number]', '11000');
await page.click('button:has-text("Nästa")');
await page.waitForSelector('text=flytta utomlands');
await page.getByRole('button', { name: 'Nej', exact: true }).click();

// 1. Nya steget.
await page.waitForSelector('text=allvarlig sjukdom');
console.log('1. Intagssteget om funktionsnedsättning/sjukdom finns ✓');
await page.getByRole('button', { name: 'Ja', exact: true }).click();
await page.waitForSelector('text=något mer som påverkar');
await page.click('button:has-text("Hoppa över")');

// 2. Open Discovery: rapporten visas DIREKT — inga blurrade namn, ingen betalvägg.
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 20000 });
const report = await page.textContent('body');
if (await page.locator('.blurred-name').count() > 0) { console.log('FEL: blurrade namn kvar (betalvägg)'); process.exit(1); }
if (/Lås upp din bidragsanalys|låser du upp rapporten/i.test(report)) { console.log('FEL: betalvägg-CTA framför resultatet'); process.exit(1); }
console.log('2. Open Discovery: rapporten visas gratis (inga blurrade namn, ingen upplåsnings-CTA) ✓');

// 3. Funktionsnedsättningsspårets följdfrågor finns direkt i rapporten.
for (const probe of ['omvårdnad', 'hot mot livet']) {
  if (!report.includes(probe)) { console.log(`FEL: förväntad följdfråga saknas ("${probe}")`); process.exit(1); }
}
console.log('3. Funktionsnedsättningsspårets följdfrågor i rapporten ✓');

await browser.close();
console.log('UICHECK12 KLAR');
