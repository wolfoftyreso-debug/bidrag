/**
 * uicheck14 — UX-genomgången 2026-09-02 (Mobbin-mönstren) i riktiga webbappen:
 *  1. F-SPRÅK: webbläsare med en-US + gränssnitt på svenska ⇒ kunskapsbasen
 *     (frågor, villkor, sammanfattningar) visas på svenska — aldrig engelska.
 *  2. Intaget visar räknaren "Fråga N av ungefär M" och säger att svaren sparas.
 *  3. F-INGEN-ANSÖKAN: ett stöd utan ansökan (tandvårdsbidraget) visar
 *     "Ingen ansökan behövs" och INGEN köpknapp.
 *  4. F-KVITTO: efter simulerad betalning visar arbetsytan bekräftelsen med
 *     kvittonummer och länk till kvittot.
 * Kräver körande api (PORT=3100, PAYMENTS_MOCK_ENABLED=true) + dev:web.
 */
import { launchChromium } from '../lib/browser.mjs';

const stamp = Date.now();
const browser = await launchChromium();
// en-US: så ser en svensk med engelskt operativsystem ut för servern.
const page = await browser.newPage({ viewport: { width: 1200, height: 1000 }, locale: 'en-US' });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
const fail = (m) => { console.log('FEL:', m); process.exit(1); };
const vis = async (sel) => { const l = page.locator(sel).first(); return (await l.count()) && (await l.isVisible().catch(() => false)) ? l : null; };

await page.goto('http://localhost:5173');
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'UX-testaren');
await page.fill('#email', `ux14-${stamp}@test.example`);
await page.fill('#password', 'ux-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 60000 });
await page.click('text=Kom igång');
await page.waitForSelector('text=Vem gäller det?');

// 2. Räknare + autospar synligt från första frågan.
const räknare = (await page.locator('.progress-text').textContent().catch(() => '')) ?? '';
if (!/Fråga 1 av ungefär \d+/.test(räknare)) fail(`räknaren saknas eller fel: "${räknare}"`);
if (!/sparas automatiskt/.test(räknare)) fail('autospar-raden saknas vid stapeln');
console.log(`1. Intaget visar "${räknare.trim()}" ✓`);

await page.click('button:has-text("Mig själv")'); await page.waitForTimeout(300);
await page.click('text=svårt att få ekonomin'); await page.waitForTimeout(300);
await page.click('button:has-text("Själv")'); await page.waitForTimeout(300);
for (let step = 0; step < 30; step++) {
  if (await vis('text=Det här ser du ut att kunna ha rätt till')) break;
  const h = ((await page.locator('main h1, main h2, h1, h2').first().textContent().catch(() => '')) ?? '').toLowerCase();
  const num = await vis('input[type="number"]');
  if (num) { await num.fill(h.includes('född') || h.includes('år') ? '1979' : '7000'); const nx = await vis('button:has-text("Nästa")'); if (nx) { await nx.click(); await page.waitForTimeout(500); continue; } }
  let clicked = false;
  for (const s of ['button:has-text("Nej")', 'button:has-text("Hoppa över")', 'button:has-text("Arbetslös")', 'button:has-text("15 000")', 'button:has-text("Nästa")']) {
    const l = await vis(s); if (l) { await l.click(); clicked = true; break; }
  }
  if (!clicked) { const any = page.locator('main button:not([disabled])').filter({ hasNotText: 'Tillbaka' }).first(); if (await any.count()) { await any.click(); clicked = true; } }
  if (!clicked) fail(`intaget fastnade på "${h}"`);
  await page.waitForTimeout(500);
}
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 60000 });
await page.waitForSelector('a[href*="/stod/"]', { timeout: 45000 });
await page.waitForTimeout(800);

// 1. Språkkonsekvens.
const analys = await page.locator('main').innerText();
const engelska = analys.match(/\b(Have you|Are you|Do you|Does the|The benefit|Is your)\b/g) ?? [];
if (engelska.length) fail(`analysen läcker engelska trots svenskt gränssnitt: ${engelska.slice(0, 5).join(', ')}`);
if (!/Har du|Är du|Bor du/.test(analys)) fail('analysen saknar svenska frågor — kontrollen kan inte lita på sig själv');
console.log('2. en-US-webbläsare + svenskt gränssnitt ⇒ kunskapsbasen på svenska (0 engelska fraser) ✓');

// 3. Stöd utan ansökan.
const hrefs = await page.locator('a[href*="/stod/"]').evaluateAll((as) => as.map((a) => a.getAttribute('href')));
const projekt = new URL(hrefs[0], 'http://localhost:5173').searchParams.get('projekt');
if (!projekt) fail('stödlänken saknar ?projekt= — kan inte nå stödsidan i projektkontext');
await page.goto(`http://localhost:5173/stod/fk-tandvardsbidrag?projekt=${projekt}`);
await page.waitForSelector('text=Ingen ansökan behövs', { timeout: 30000 });
if (await vis('button:has-text("Förbered ansökan i systemet")')) fail('köpknappen visas för ett stöd som inte kräver ansökan');
if (await vis('text=Redo att börja?')) fail('"Redo att börja?" visas för ett stöd utan ansökan');
console.log('3. Tandvårdsbidraget: "Ingen ansökan behövs", ingen köpknapp ✓');

// 4. Köp av ett stöd MED ansökan → bekräftelse med kvitto på arbetsytan.
const medAnsokan = hrefs.find((h) => !/tandvardsbidrag|hogkostnadsskydd/.test(h));
if (!medAnsokan) fail('hittade inget stöd med ansökan i analysen');
await page.goto(`http://localhost:5173${medAnsokan}`);
await page.waitForSelector('text=Redo att börja?', { timeout: 30000 });
await page.click('button:has-text("Förbered ansökan i systemet")');
await page.waitForSelector('input[type=checkbox]', { timeout: 30000 });
await page.locator('input[type=checkbox]').first().check();
await page.click('button:has-text("Förbered ansökan —")');
await page.waitForSelector('button:has-text("Bekräfta betalning")', { timeout: 30000 });
await page.click('button:has-text("Bekräfta betalning")');
await page.waitForURL(/\/ansokningar\//, { timeout: 30000 });
await page.waitForSelector('text=Betalningen är genomförd', { timeout: 30000 });
const banner = (await page.locator('.alert.success').first().textContent()) ?? '';
const kvitto = banner.match(/BS-\d{4}-\d{6}/)?.[0];
if (!kvitto) fail(`bekräftelsen saknar kvittonummer: "${banner}"`);
if (!(await vis('a:has-text("Visa kvittot")'))) fail('länken till kvittot saknas i bekräftelsen');
console.log(`4. Efter betalning: bekräftelse med kvitto ${kvitto} + länk ✓`);

await browser.close();
console.log('uicheck14 OK');
