/**
 * FAS 1 (Master Control Prompt) — bevis för hybrid-ingången "Vem gäller det?"
 * + enskild firma-dubbelkontexten. Kräver körande api (3100, mock) + web (5173).
 */
import { launchChromium, artifactsDir } from '../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 420, height: 900 } }); // mobil
page.on('pageerror', (e) => console.log('PAGEERROR:', e.message));

await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Enskild Firma-testet');
await page.fill('#email', `ef-${Date.now()}@test.example`);
await page.fill('#password', 'faas1-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?'); // dashboard-tomtillstånd
await page.click('text=Kom igång');

// 1. Nya steg 0: sökandekontext, situations-först, inget bidragsnamn.
await page.waitForSelector('text=Vem gäller det?');
await page.screenshot({ path: `${SHOT}/faas1-01-vem-galler-det.png` });
console.log('1. "Vem gäller det?" visas som steg 0 ✓');

// 2. Enskild firma → dubbelkontext: personspåret öppnas (person-stöd),
//    med self_employed/sole_trader förifyllt.
await page.click('button:has-text("Min enskilda firma")');
await page.waitForSelector('text=Bor du själv eller tillsammans med någon?');
console.log('2. Enskild firma → personspåret (dubbelkontext) ✓');
await page.click('button:has-text("Själv")');
await page.waitForSelector('text=Har du barn som bor hos dig?');
await page.getByRole('button', { name: 'Nej', exact: true }).click();
await page.waitForSelector('text=Hur gammal är du?');
await page.click('button:has-text("29–65")');

// 3. Driftsform/sysselsättning är redan känd → hoppar direkt till sektorn
//    (bevisar att förifyllningen skippar p-employment + p-biz-form).
await page.waitForSelector('text=Vad sysslar verksamheten med?');
await page.screenshot({ path: `${SHOT}/faas1-02-verksamhetens-sektor.png` });
console.log('3. Hoppar direkt till verksamhetens sektor (självverksam förifylld) ✓');
await page.click('button:has-text("Innovation eller teknik")');

// 4. Fortsätter person-frågorna (inkomst) → dubbelkontexten bekräftad.
await page.waitForSelector('text=inkomst per månad');
console.log('4. Personspårets ekonomifrågor fortsätter → person + verksamhet i samma flöde ✓');

console.log('FAAS1-WHO KLAR — hybrid-ingång + enskild firma-dubbelkontext verifierade');
await browser.close();
