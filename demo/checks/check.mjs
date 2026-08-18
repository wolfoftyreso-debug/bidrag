import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';
const S = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 900 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${S}/demo/demo.html`);

// Personligt spår: ensamstående förälder, arbetslös, låg inkomst
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")'); // skilda håll
await page.click('text=Ja, i grundskolan');
await page.click('.row >> button:has-text("Ja")'); // svårt betala skolutflykt → öppnar Majblomman
await page.click('.row >> button:has-text("Ja")'); // glasögon 8–19 → glasögonbidrag
await page.click('.row >> button:has-text("Ja")'); // besvärlig skolväg → skolskjuts
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")'); // betalar boende
await page.fill('input[type=number]', '8500');
await page.click('text=Nästa');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');

// Betalvägg: teasern visar värdet men läcker inga namn. (innerText = det som
// faktiskt renderas — kunskapsbasen ligger med avsikt i demots bundle.)
await page.waitForSelector('text=stöd som matchar din situation');
let teaserBody = await page.innerText('body');
for (const forbidden of ['Bostadsbidrag till barnfamiljer', 'Försäkringskassan', 'Underhållsstöd']) {
  if (teaserBody.includes(forbidden)) throw new Error(`TEASERLÄCKA: ${forbidden}`);
}
if (!teaserBody.includes('hög relevans')) throw new Error('teaser saknar nivåräkning');
if (!teaserBody.includes('Detta är en vägledning och inte ett myndighetsbeslut')) throw new Error('teaser saknar disclaimer');
await page.screenshot({ path: `${S}/17-demo-teaser.png`, fullPage: true });
console.log('OK: teaser utan läckage');
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD BETALNING');
await page.screenshot({ path: `${S}/18-demo-swish.png`, fullPage: true });
await page.click('text=Godkänn betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
console.log('OK: simulerad Swish-betalning tydligt märkt');

await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
let body = await page.textContent('body');
if (!body.includes('Bostadsbidrag till barnfamiljer')) throw new Error('bostadsbidrag saknas');
if (!body.includes('hög sannolikhet')) throw new Error('sannolikhet saknas');
if (!body.includes('Uppfyller inte kraven')) throw new Error('uteslutningar saknas');
console.log('OK: personligt spår');

// Följdfråga: svara Ja på underhållsfrågan → underhållsstöd uppgraderas live
const before = (body.match(/hög sannolikhet/g) || []).length;
await page.locator('.q-row', { hasText: 'Betalar den andra föräldern' }).locator('button:has-text("Ja")').click();
await page.waitForTimeout(300);
body = await page.textContent('body');
const after = (body.match(/hög sannolikhet/g) || []).length;
if (after <= before) throw new Error(`live-omräkning misslyckades (${before} → ${after})`);
console.log(`OK: följdfråga uppgraderade bedömningen live (${before} → ${after} hög sannolikhet)`);
await page.screenshot({ path: `${S}/11-demo-personligt.png`, fullPage: true });

// Börja om → projektspår: Jamaica-fallet
await page.click('text=Börja om');
await page.click('text=pengar till ett projekt');
await page.click('text=privatperson eller enskild utövare');
await page.click('.row >> button:has-text("Ja")'); // yrkesverksam kultur
await page.click('text=Kultur — dans');
await page.check('input[type=checkbox] >> nth=0'); // utbyte/resa
await page.check('input[type=checkbox] >> nth=1'); // utbildning
await page.click('button:has-text("Nästa")');
await page.click('.row >> button:has-text("Ja")'); // internationell
await page.click('.row >> button:has-text("Ja")'); // kunskap hem
await page.click('.row >> button:has-text("Nej")'); // ej barn/unga
await page.waitForSelector('text=stöd som matchar din situation');
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.click('text=Godkänn betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
console.log('OK: betalvägg även i projektspåret');
await page.waitForSelector('text=Stöd som kan passa');
body = await page.textContent('body');
if (!body.includes('Resebidrag för internationellt kulturutbyte')) throw new Error('resebidrag saknas');
console.log('OK: projektspår (Jamaica-fallet)');

// Förklaring expanderar med källrad
await page.locator('button.linkish', { hasText: 'Resebidrag för internationellt kulturutbyte' }).first().click();
await page.waitForSelector('text=Källa:');
console.log('OK: förklaring med källa och kriterier');
await page.screenshot({ path: `${S}/12-demo-projekt.png`, fullPage: true });

await browser.close();
console.log('DEMO VERIFIED');
