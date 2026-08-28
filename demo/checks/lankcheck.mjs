/**
 * F-LÄNK (användarfynd 2026-08-28: "kommer inte vidare när jag klickar").
 *
 * Demon visas i en sandlådad iframe (artefaktvyn). Utan 'allow-popups' vägrar
 * webbläsaren tyst öppna externa länkar — knappen "Till ansökan hos …" gjorde
 * ingenting alls, och det är produktens viktigaste steg: överlämningen till
 * myndigheten (§42, inga återvändsgränder).
 *
 * Checken kör demon under EXAKT den begränsningen och kräver att vägen vidare
 * finns kvar: en förklaring av varför klicket inte gick fram, hela adressen
 * synlig och markerbar, och en kopieringsknapp som kvitterar.
 */
import { writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

// Värdsida med samma sandlåda som artefaktvyn: skript ja, popup nej.
const host = join(artifactsDir, 'demo', 'sandbox-check.html');
writeFileSync(host, `<!doctype html><meta charset=utf-8>
<iframe sandbox="allow-scripts allow-forms" src="./demo.html" style="width:100%;height:1000px;border:0"></iframe>`);

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 1000 } });
let sandboxBlockad = false;
page.on('console', (m) => { if (/sandboxed frame/i.test(m.text())) sandboxBlockad = true; });
await page.goto(`file://${host}`);
await page.waitForTimeout(800);

const f = page.frames().find((fr) => fr.url().includes('demo.html'));
if (!f) throw new Error('demon laddades inte i den sandlådade ramen');

await f.click('text=svårt att få ekonomin');
await f.click('button:has-text("Själv")');
await f.click('.choice:has-text("Nej")');
await f.fill('input[type=number]', '1987');
await f.click('button:has-text("Nästa")');
await f.click('button:has-text("Arbetslös")');
await f.click('button:has-text("15 000–25 000 kr")');
for (let i = 0; i < 8; i++) {
  if (await f.locator('text=Det här ser du ut att kunna ha rätt till').count()) break;
  const nej = f.locator('.row >> button:has-text("Nej")').first();
  if (!(await nej.count())) break;
  await nej.click();
  await page.waitForTimeout(200);
}
await f.locator('button:has-text("Vill ansöka")').first().click();
await f.locator('button:has-text("Nästa")').last().click();
await f.waitForSelector('text=Din plan —', { timeout: 15000 });
console.log('1. Planen nås i den sandlådade vyn ✓');

// Sök på funktion, inte på etikett: knappraden i planvyns kort innehåller
// exakt en utgående länk — den till myndigheten. (Fyndet som motiverar detta:
// F-FÖRBERED döpte om knappen och checken slutade hitta den.)
const knapp = f.locator('.explain .row a[href^="https://"]').first();
const href = await knapp.getAttribute('href');
if (!href) throw new Error('planvyns kort har ingen utgående länk till myndigheten');
const etikett = (await knapp.innerText()).trim();
if (!/ansök/i.test(etikett)) {
  throw new Error(`den utgående länken beskriver inte att man ansöker: "${etikett}"`);
}
await knapp.click();
await page.waitForTimeout(400);

if (!sandboxBlockad) {
  throw new Error('sandlådan blockerade inte klicket — checken mäter inte längre det den ska');
}
const ruta = f.locator('.utlank-block').first();
if (!(await ruta.count())) {
  throw new Error('klicket blockerades men ingen väg vidare visades — den döda knappen är tillbaka');
}
const adress = await ruta.locator('input').inputValue();
if (adress !== href) throw new Error(`adressen i rutan (${adress}) är inte knappens (${href})`);
console.log('2. Blockerat klick ger förklaring + hela adressen synlig ✓');

await ruta.locator('button').click();
await page.waitForTimeout(300);
const kvitto = await ruta.locator('button').innerText();
if (!kvitto.includes('Kopierad')) throw new Error(`kopieringsknappen kvitterar inte: "${kvitto}"`);
console.log('3. Kopieringsknappen kvitterar ✓');

// 320px: adressfältet får inte spränga kortet.
await page.setViewportSize({ width: 320, height: 900 });
await page.waitForTimeout(300);
const spill = await f.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
if (spill > 1) throw new Error(`sidan scrollar i sidled på 320px (${spill}px)`);
console.log('4. Ingen sidledes scroll på 320px ✓');

await browser.close();
console.log('LÄNKCHECK KLAR');
