/**
 * uicheck13 — prismodellen i riktiga webbappen (39 kr analys + 19 kr/ansökan):
 *  1. stödsidans knapp heter "Förbered ansökan i systemet"
 *  2. utan betald kredit visas köpflödet med priset — inte ett felmeddelande
 *  3. simulerad betalning → ansökan skapas → vi hamnar på ansökningssidan
 *  4. Mina köp visar både "Bidragsanalys" och "Förberedd ansökan"
 */
import { launchChromium } from '../lib/browser.mjs';

const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1200, height: 1000 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
const fail = (m) => { console.log('FEL:', m); process.exit(1); };

await page.goto('http://localhost:5173');
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Prismodelltestaren');
await page.fill('#email', `pris-${stamp}@test.example`);
await page.fill('#password', 'prismodell-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 60000 });
console.log('0. Konto skapat ✓');

// Intag: ensamstående arbetslös utan barn, med boendekostnad.
await page.click('text=Kom igång');
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // inga barn
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // betalar boende
await page.waitForSelector('text=hur mycket betalar du');
await page.fill('input[type=number]', '7000');
await page.click('button:has-text("Nästa")');
await page.waitForSelector('text=flytta utomlands');
await page.getByRole('button', { name: 'Nej', exact: true }).click();
await page.waitForSelector('text=allvarlig sjukdom');
await page.getByRole('button', { name: 'Nej', exact: true }).click();
await page.waitForSelector('text=något mer som påverkar');
await page.click('button:has-text("Hoppa över")');
await page.waitForSelector('text=stöd som matchar din situation', { timeout: 60000 });
console.log('1. Intaget genomfört, teasern visas ✓');

// Lås upp analysen (39 kr, simulerad).
await page.check('#angerratt-samtycke-analys');
await page.click('button:has-text("Lås upp")');
await page.waitForSelector('button:has-text("Bekräfta betalning")', { timeout: 30000 });
await page.click('button:has-text("Bekräfta betalning")');
await page.waitForSelector('text=Betalning genomförd', { timeout: 30000 });
const receipt = ((await page.textContent('body')) ?? '').match(/BS-\d{4}-\d{6}/)?.[0];
if (!receipt) fail('inget kvittonummer visas efter betalningen');
await page.click('button:has-text("Visa min analys")');
await page.waitForSelector('a[href*="/stod/"]', { timeout: 45000 });
console.log(`2. Analysen upplåst (39 kr, simulerad), kvitto ${receipt} — namngivna stöd syns ✓`);

// Öppna ett stöd.
const opp = page.locator('a[href*="/stod/"]').first();
if (!(await opp.count())) fail('hittade inget stöd att öppna i rapporten');
await opp.click();
await page.waitForSelector('text=Redo att börja?', { timeout: 30000 });
const prepare = page.locator('button:has-text("Förbered ansökan i systemet")');
if (!(await prepare.count())) fail('knappen "Förbered ansökan i systemet" saknas på stödsidan');
console.log('3. Stödsidans knapp heter "Förbered ansökan i systemet" ✓');

// 402 → köpflöde, inte fel.
await prepare.click();
await page.waitForTimeout(2000);
const body = (await page.textContent('body')) ?? '';
if (/Kunde inte skapa ansökan/.test(body)) fail('402 visas som felmeddelande i stället för köpflöde');
if (!/19,00 kr|19 kr/.test(body)) fail('priset 19 kr syns inte i köpflödet');
if (!/per ansökan/.test(body)) fail('förklaringen "per ansökan" saknas');
if (!/ansöka själv/.test(body)) fail('den ärliga "gratis att ansöka själv"-raden saknas');
console.log('4. Utan kredit → köpflöde med 19 kr + ärlig gratisväg, inget fel ✓');

// Köp + bekräfta → ansökan skapas.
await page.check('#angerratt-samtycke-ansokan');
await page.click('button:has-text("Förbered ansökan —")');
await page.waitForSelector('button:has-text("Bekräfta betalning")', { timeout: 30000 });
await page.click('button:has-text("Bekräfta betalning")');
await page.waitForURL(/\/ansokningar\//, { timeout: 30000 }).catch(() => {});
if (!/\/ansokningar\//.test(page.url())) fail('hamnade inte på ansökningssidan; url=' + page.url());
console.log('5. Betalning bekräftad → ansökan skapad, vi står på ansökningssidan ✓');

// Kvitton i Mina köp.
await page.goto('http://localhost:5173/konto');
await page.waitForSelector('text=Mina köp', { timeout: 30000 });
await page.waitForTimeout(1200);
const account = (await page.textContent('body')) ?? '';
if (!/Förberedd ansökan/.test(account)) fail('kvittoraden "Förberedd ansökan" saknas i Mina köp');
if (!/Bidragsanalys/.test(account)) fail('analysköpet saknas i Mina köp');
console.log('6. Mina köp visar både "Bidragsanalys" och "Förberedd ansökan" ✓');

console.log('UICHECK13 KLAR — prismodellen fungerar hela vägen i webbgränssnittet');
await browser.close();
