/** Autospar i demot: svara på frågor → ladda om sidan → fortsätt exakt där man var. */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

const S = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 900 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${S}/demo/demo.html`);

// Svara på fyra frågor och ladda om mitt i.
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")');
await page.waitForSelector('text=Går något av barnen i skolan?');
await page.reload();
await page.waitForSelector('text=Går något av barnen i skolan?');
console.log('1. Omladdning mitt i intaget → samma fråga, svaren kvar ✓');

// Backa efter omladdning: historiken överlevde också.
await page.click('button:has-text("← Tillbaka")');
await page.waitForSelector('text=skilda håll');
await page.click('button:has-text("Ja")');
console.log('2. Historiken överlevde omladdningen — backa fungerar ✓');

// Kör klart till rapporten, ladda om → rapporten visas direkt (Open Discovery).
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
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
await page.reload();
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
console.log('3. Omladdning → rapporten visas direkt (Open Discovery, ingen betalvägg) ✓');

// Börja om rensar utkastet.
await page.click('text=Börja om');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.reload();
await page.waitForSelector('text=Vad behöver du hjälp med?');
console.log('4. Börja om rensar det sparade läget ✓');

await browser.close();
console.log('SAVECHECK KLAR');
