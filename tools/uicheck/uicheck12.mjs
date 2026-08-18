/**
 * Riktiga webbappen: (1) nya intagssteget p-disability, (2) nya teasern med
 * blurrade namnrader, (3) funktionsnedsättningsstöden i rapporten,
 * (4) Mina köp: ladda ner kvitto-PDF + skicka via e-post (ärligt utfall).
 */
import { launchChromium } from '../lib/browser.mjs';
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto('http://localhost:5173');
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Omsorgstestaren');
await page.fill('#email', `omsorg-${stamp}@test.example`);
await page.fill('#password', 'omsorgs-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.click('text=Kom igång');
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Med partner")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // barn
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // ej skilda håll
await page.click('button:has-text("Nej, inte ännu")'); // skolform
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // skolutflykt
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // fritidsaktivitet
await page.getByRole('button', { name: 'Nej', exact: true }).click(); // glasögon
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Arbetar")');
await page.click('button:has-text("25 000–40 000")');
await page.getByRole('button', { name: 'Ja', exact: true }).click(); // betalar boende
await page.waitForSelector('text=hur mycket betalar du');
await page.fill('input[type=number]', '11000');
await page.click('button:has-text("Nästa")');
await page.waitForSelector('text=flytta utomlands');
await page.getByRole('button', { name: 'Nej', exact: true }).click();

// 1. Nya steget.
await page.waitForSelector('text=allvarlig sjukdom');
console.log('1. Intagssteget om funktionsnedsättning/sjukdom finns ✓');
await page.getByRole('button', { name: 'Ja', exact: true }).click();
await page.waitForSelector('text=något mer som påverkar');
await page.click('button:has-text("Hoppa över")');

// 2. Nya teasern.
await page.waitForSelector('text=stöd som matchar din situation', { timeout: 20000 });
const blurCount = await page.locator('.blurred-name').count();
if (blurCount === 0) { console.log('FEL: inga blurrade namnrader i webbteasern'); process.exit(1); }
const body = await page.textContent('body');
if (!/För att se namnen och gå vidare med ansökan låser du upp rapporten/.test(body)) { console.log('FEL: CTA-raden saknas'); process.exit(1); }
console.log(`2. Webbteasern: rubrik + ${blurCount} blurrade namnrader + upplåsnings-CTA ✓`);

// 3. Lås upp → funktionsnedsättningsspårets frågor i rapporten.
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD');
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 20000 });
const report = await page.textContent('body');
for (const probe of ['omvårdnad', 'hot mot livet']) {
  if (!report.includes(probe)) { console.log(`FEL: förväntad följdfråga saknas ("${probe}")`); process.exit(1); }
}
console.log('3. Funktionsnedsättningsspårets följdfrågor i rapporten ✓');

// 4. Mina köp: kvittoknapparna.
await page.goto('http://localhost:5173/konto');
await page.waitForSelector('text=Mina köp');
await page.click('table.data button.secondary'); // öppna kvittot (kvittonumret)
await page.waitForSelector('text=Ladda ner kvittot (PDF)');
await page.waitForSelector('text=Skicka kvittot via e-post');
console.log('4. Kvittoknapparna finns i Mina köp ✓');

// PDF-nedladdning: verifiera via API:t i sidans kontext (cookies följer med).
const pdfHead = await page.evaluate(async () => {
  const rows = await (await fetch('/v1/purchases', { credentials: 'include' })).json();
  const pid = rows.purchases[0].paymentId;
  const res = await fetch(`/v1/payments/${pid}/receipt.pdf`, { credentials: 'include' });
  const buf = new Uint8Array(await res.arrayBuffer());
  return { status: res.status, type: res.headers.get('content-type'), magic: String.fromCharCode(...buf.slice(0, 5)) };
});
if (pdfHead.status !== 200 || pdfHead.type !== 'application/pdf' || pdfHead.magic !== '%PDF-') {
  console.log('FEL: kvitto-PDF svarar fel', pdfHead); process.exit(1);
}
console.log('5. Kvitto-PDF laddas ner (200, application/pdf, %PDF-magik) ✓');

// Skicka via e-post: ärligt utfall utan konfigurerad kanal.
await page.click('text=Skicka kvittot via e-post');
await page.waitForSelector('text=Ingen e-postkanal är konfigurerad', { timeout: 10000 }).catch(async () => {
  const b = await page.textContent('body');
  if (/skickat|vart ska det skickas/i.test(b)) { console.log('6. Utskicksflödet svarar (adressfråga/skickat) ✓'); }
  else { console.log('FEL: inget ärligt utfall efter utskicksklick'); process.exit(1); }
});
const after = await page.textContent('body');
if (/Ingen e-postkanal är konfigurerad/.test(after)) console.log('6. Ärligt utfall utan e-postkanal — kvittot kvar i kontot ✓');

await browser.close();
console.log('UICHECK12 KLAR');
