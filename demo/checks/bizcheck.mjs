/** Företagarspåret i demon: löftet vid "Driver eget" ska infrias i rapporten. */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${artifactsDir}/demo/demo.html`);

await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Nej")'); // inga barn
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Driver eget företag")');
await page.waitForSelector('text=Hur driver du verksamheten?');
console.log('1. Driftsformsfrågan ställs efter "Driver eget" ✓');
await page.click('button:has-text("Enskild firma")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")'); // betalar boende
await page.fill('input[type=number]', '9000');
await page.click('text=Nästa');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=stöd som matchar din situation');
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD BETALNING');
await page.check('#angerratt');
await page.click('text=Godkänn betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
await page.waitForSelector('text=Stöd som rör ditt företagande');
console.log('2. Sektionen "Stöd som rör ditt företagande" finns i rapporten ✓');
const body = await page.locator('body').innerText();
if (!/Med enskild firma söker du företagsstöden som person/.test(body)) { console.log('FEL: driftsformstexten saknas'); process.exit(1); }
console.log('3. Vägledningen speglar driftsformen (enskild firma) ✓');
if (!/Startstöd|Jordbruksverket|start av näringsverksamhet/i.test(body)) { console.log('FEL: inga företagsstöd i rapporten'); process.exit(1); }
console.log('4. Företagsstöd genomlyses ✓');
if (!/aktiebolag/i.test(body)) { console.log('FEL: AB-stöden nämns inte alls'); process.exit(1); }
console.log('5. Stöd som kräver aktiebolag redovisas ärligt ✓');
await browser.close();
console.log('BIZCHECK KLAR');
