/** Företagarspåret i RIKTIGA webbappen: intag → driftsform → rapportsektion. */
import { launchChromium } from '../../lib/browser.mjs';
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto('http://localhost:5173');
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Företagaren');
await page.fill('#email', `biz-${stamp}@test.example`);
await page.fill('#password', 'foretags-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.click('text=Kom igång');
await page.waitForSelector('text=Vem gäller det?');
await page.click('button:has-text("Mig själv")');
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // inga barn
await page.fill('input[type="number"]', '1979');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Driver eget företag")');
await page.waitForSelector('text=Hur driver du verksamheten?');
console.log('1. Driftsformsfrågan i riktiga intaget ✓');
await page.click('button:has-text("Enskild firma")');
await page.click('button:has-text("15 000–25 000")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // betalar boende
await page.waitForSelector('text=hur mycket betalar du');
await page.fill('input[type=number]', '9000');
await page.click('button:has-text("Nästa")');
await page.waitForSelector('text=flytta utomlands');
await page.getByRole('button', { name: 'Nej', exact: true }).click();
await page.waitForSelector('text=något mer som påverkar');
await page.click('button:has-text("Hoppa över")');
await page.waitForSelector('text=stöd som matchar din situation', { timeout: 15000 });
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD');
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
await page.waitForSelector('text=Stöd som rör ditt företagande', { timeout: 15000 });
console.log('2. "Stöd som rör ditt företagande" i riktiga rapporten ✓');
const body = await page.locator('body').innerText();
if (!/Med enskild firma söker du företagsstöden som person/.test(body)) { console.log('FEL: driftsformstext saknas'); process.exit(1); }
console.log('3. Vägledningen speglar enskild firma ✓');
if (!/Jordbruksverket|start av näringsverksamhet|Startstöd/i.test(body)) { console.log('FEL: företagsstöden saknas'); process.exit(1); }
console.log('4. Företagsstöd genomlyses med frågor ✓');
await browser.close();
console.log('UICHECK11 KLAR — företagarspåret fungerar i riktiga webbappen.');
