/**
 * Skärmdumpsvandraren från UX-genomgången 2026-09-02 (docs/reports/UX_MOBBIN_2026-09-02.md).
 * Registrerar ett konto, går igenom intaget som arbetslös privatperson, öppnar
 * analysen, tandvårdsbidragets stödsida och köper en förberedd ansökan med
 * simulerad betalning — och sparar fullsides-skärmdumpar i artifacts/flows/.
 * Webbläsaren kör med locale en-US så att språkläckan (F-SPRÅK) skulle synas
 * om den kom tillbaka. Kräver körande api (PORT=3100, PAYMENTS_MOCK_ENABLED=true)
 * + dev:web + Chromium. Inte del av verify — ett arbetsredskap för UX-pass.
 */
const BASE = 'http://localhost:5173'; const OUT = new URL('../../artifacts/flows/', import.meta.url).pathname;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, locale: 'en-US' });
let n = 0;
const shot = async (name) => { n++; await page.screenshot({ path: `${OUT}/${String(n).padStart(2, '0')}-${name}.png`, fullPage: true }); console.log(`${String(n).padStart(2, '0')} ${name}`); };
const vis = async (sel) => { const l = page.locator(sel).first(); return (await l.count()) && (await l.isVisible().catch(() => false)) ? l : null; };
await page.goto(BASE); await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Efter-testaren'); await page.fill('#email', `flow5-${Date.now()}@test.example`); await page.fill('#password', 'flodes-losenord-123');
await page.click('button[type=submit]'); await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 60000 });
await page.click('text=Kom igång'); await page.waitForSelector('text=Vem gäller det?'); await shot('efter-intag-raknare');
await page.click('button:has-text("Mig själv")'); await page.waitForTimeout(300);
await page.click('text=svårt att få ekonomin'); await page.waitForTimeout(300);
await page.click('button:has-text("Själv")'); await page.waitForTimeout(300); await shot('efter-intag-steg4');
for (let step = 0; step < 30; step++) {
  if (await vis('text=Det här ser du ut att kunna ha rätt till')) break;
  const h = ((await page.locator('main h1, main h2, h1, h2').first().textContent().catch(() => '')) ?? '').toLowerCase();
  const num = await vis('input[type="number"]');
  if (num) { await num.fill(h.includes('född') || h.includes('år') ? '1979' : '7000'); const nx = await vis('button:has-text("Nästa")'); if (nx) { await nx.click(); await page.waitForTimeout(500); continue; } }
  let clicked = false;
  for (const s of ['button:has-text("Nej")', 'button:has-text("Hoppa över")', 'button:has-text("Arbetslös")', 'button:has-text("15 000")', 'button:has-text("Nästa")']) { const l = await vis(s); if (l) { await l.click(); clicked = true; break; } }
  if (!clicked) { const any = page.locator('main button:not([disabled])').filter({ hasNotText: 'Tillbaka' }).first(); if (await any.count()) { await any.click(); clicked = true; } }
  if (!clicked) break; await page.waitForTimeout(500);
}
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 60000 }); await page.waitForSelector('a[href*="/stod/"]', { timeout: 45000 }); await page.waitForTimeout(800);
await shot('efter-analys-svenska');
const hrefs = await page.locator('a[href*="/stod/"]').evaluateAll((as) => as.map((a) => a.getAttribute('href')));
const projekt = new URL(hrefs[0], BASE).searchParams.get('projekt');
await page.goto(`${BASE}/stod/fk-tandvardsbidrag?projekt=${projekt}`); await page.waitForSelector('text=Ingen ansökan behövs'); await page.waitForTimeout(400); await shot('efter-stod-utan-ansokan');
const med = hrefs.find((h) => !/tandvardsbidrag|hogkostnadsskydd/.test(h));
await page.goto(`${BASE}${med}`); await page.waitForSelector('text=Redo att börja?');
await page.click('button:has-text("Förbered ansökan i systemet")'); await page.waitForSelector('input[type=checkbox]'); await page.locator('input[type=checkbox]').first().check();
await page.click('button:has-text("Förbered ansökan —")'); await page.waitForSelector('button:has-text("Bekräfta betalning")'); await page.click('button:has-text("Bekräfta betalning")');
await page.waitForSelector('text=Betalningen är genomförd', { timeout: 30000 }); await page.waitForTimeout(500); await shot('efter-kop-bekraftelse');
await browser.close(); console.log('KLART');
