/** Demo (Open Discovery): Mitt konto är direkt nåbart — kvitto (exempel, 19 kr) + återställningskoder. */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

const SHOT = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${SHOT}/demo/demo.html`);

// Kör intaget (ensamstående förälder, arbetslös) → rapporten visas direkt (Open Discovery).
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")');
await page.click('text=Ja, i grundskolan');
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")');
await page.fill('input[type=number]', '8500');
await page.click('text=Nästa');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=Gå vidare med ansökan');

// Mitt konto (direkt nåbart från rapporten)
await page.waitForSelector('text=Mitt konto — kvitto & säkerhet');
await page.click('text=Mitt konto — kvitto & säkerhet');
await page.waitForSelector('text=Mina köp');
await page.click('text=Kvitto BS-2026-000123');
await page.waitForSelector('text=Landvex AB');
await page.waitForSelector('text=SE559141704201');
await page.waitForSelector('text=Antennvägen 2, 135 48 Tyresö');
console.log('1. Kvitto med Landvex-uppgifter och momsspecifikation ✓');

await page.click('text=Skapa återställningskoder');
await page.waitForSelector('text=Spara koderna nu');
const codes = (await page.locator('pre').last().innerText()).trim().split('\n');
if (codes.length !== 8 || !/^[A-Z2-9]{5}-[A-Z2-9]{5}-[A-Z2-9]{5}$/.test(codes[0])) {
  console.log('FEL kodformat:', codes); process.exit(1);
}
console.log('2. 8 återställningskoder genererade ✓');
await page.screenshot({ path: `${SHOT}/shot-demo-konto.png`, fullPage: true });

// Tillbaka till analysen fungerar
await page.click('text=← Tillbaka till analysen');
await page.waitForSelector('text=Mitt konto — kvitto & säkerhet');
console.log('3. Tillbaka till analysen ✓');

await browser.close();
console.log('KONTOCHECK KLAR');
