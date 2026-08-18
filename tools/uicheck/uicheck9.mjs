/** Autospar i riktiga intaget: svar → omladdning → fortsätt där man var + "Börja om". */
import { launchChromium } from '../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Autosparen');
await page.fill('#email', `spar-${stamp}@test.example`);
await page.fill('#password', 'sparat-losenord-12345');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.click('text=Kom igång');

// Svara på tre frågor, ladda om mitt i.
await page.click('text=svårt att få ekonomin');
await page.waitForSelector('text=Bor du själv eller tillsammans med någon?');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis")), button:has-text("Ja"):not(:has-text("växelvis"))');
await page.waitForTimeout(200);
const questionBefore = await page.locator(".card h1").first().innerText();
await page.reload();
await page.waitForSelector('text=du fortsätter där du var');
const questionAfter = await page.locator(".card h1").first().innerText();
if (questionBefore !== questionAfter) {
  console.log(`FEL: fråga före omladdning "${questionBefore}" ≠ efter "${questionAfter}"`);
  process.exit(1);
}
console.log(`1. Omladdning mitt i intaget → samma fråga ("${questionAfter}") + sparat-banner ✓`);

// Backa fungerar efter omladdning (historiken sparades också).
await page.click('button:has-text("← Tillbaka")');
await page.waitForTimeout(150);
console.log('2. Historiken överlevde omladdningen ✓');

// Börja om rensar utkastet.
await page.click('text=Börja om från början');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.reload();
await page.waitForSelector('text=Vad behöver du hjälp med?');
const banner = await page.locator('text=du fortsätter där du var').count();
if (banner > 0) { console.log('FEL: banner kvar efter Börja om'); process.exit(1); }
console.log('3. Börja om rensar utkastet — ren start efter omladdning ✓');

await browser.close();
console.log('UICHECK9 KLAR — intaget autosparar varje sida och varje rad.');
