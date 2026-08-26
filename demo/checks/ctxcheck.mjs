/**
 * §7 Informationsvärde: de öppna frågorna i rapporten ska bära en
 * kontextetikett som säger vilket stöd frågan avgör, och en fråga som inte
 * kan gälla användaren ska aldrig ställas (arbetssökandefrågan till någon
 * som arbetar).
 *
 * Uppdaterad efter F-HOPP-fixen: intaget har numera avslutande
 * upptäcktsfrågor (utvandring, funktionsnedsättning) före teasern, och
 * rapporten (Open Discovery) visar namngivna stöd direkt och gratis.
 */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';
import { fileURLToPath } from 'node:url';

const S = artifactsDir;
const html = `${artifactsDir}/demo/demo.html`;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 900 } });
await page.goto('file://' + html);

// Arbetande förälder med barn i grundskolan och boendekostnad.
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")');
await page.click('text=Ja, i grundskolan');
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.fill('input[type=number]', '1979');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Arbetar")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")');
await page.fill('input[type=number]', '9000');
await page.click('button:has-text("Nästa")');

// Avslutande upptäcktsfrågor — svara Nej tills teasern visas.
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');

// Open Discovery: rapporten visas direkt och gratis — ingen teaser, ingen betalvägg.
await page.waitForSelector('text=Gå vidare med ansökan');
await page.waitForSelector('.q-context');

// Endast de ÖPPNA frågorna granskas. "Dina svar"-panelen (F-ÄNDRA) återanvänder
// samma .q-row-markup för redan besvarade frågor så att de går att ändra — de
// är inte frågor som ställs, och ska därför inte räknas här.
const OPEN = '.q-row:not(details .q-row)';
const contexts = await page.locator(`${OPEN} .q-context`).allTextContents();
const openQuestions = await page.locator(OPEN).allTextContents();
console.log(`Öppna frågor: ${openQuestions.length}, kontextetiketter: ${contexts.length}`);
console.log('Etiketter:', contexts.map((c) => c.trim()));
if (openQuestions.some((q) => q.includes('arbetssökande'))) {
  throw new Error('AF-frågan ställs som öppen fråga till någon som arbetar!');
}
if (openQuestions.length === 0) throw new Error('inga öppna frågor alls — förväntat minst en');
if (contexts.length !== openQuestions.length) {
  throw new Error(`kontextetikett saknas: ${openQuestions.length} frågor men ${contexts.length} etiketter`);
}
if (!contexts.every((c) => c.trim().startsWith('Gäller'))) {
  throw new Error('kontextetikett säger inte vilket stöd frågan gäller: ' + JSON.stringify(contexts));
}
await page.screenshot({ path: `${S}/13-fragor-kontext.png` });
console.log('KONTEXT OK — etiketter finns och ingen arbetssökandefråga till en som arbetar');
await browser.close();
