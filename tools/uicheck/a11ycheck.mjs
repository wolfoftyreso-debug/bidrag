/**
 * a11ycheck — riktad tillgänglighetsgenomgång (BETA_READINESS B4) med
 * axe-core 4.10 i Chromium: inloggning, registrering, intagets tre första
 * skärmar, analysen, stödsidan, köpsamtycket, arbetsytan och Konto & data.
 * Fäller vid varje regel med impact "serious" eller "critical"; "moderate"
 * och "minor" rapporteras. Kräver körande api (PORT=3100, mock på) + dev:web.
 *
 *   node tools/uicheck/a11ycheck.mjs
 */
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { launchChromium } from '../lib/browser.mjs';

const require = createRequire(import.meta.url);
const AXE = readFileSync(require.resolve('axe-core/axe.min.js'), 'utf8');
const BASE = 'http://localhost:5173';
const stamp = Date.now();
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1200, height: 1000 } });
const fail = (m) => { console.log('FEL:', m); process.exit(1); };
const vis = async (sel) => { const l = page.locator(sel).first(); return (await l.count()) && (await l.isVisible().catch(() => false)) ? l : null; };

let hard = 0; let soft = 0; const report = [];
async function audit(name) {
  await page.addScriptTag({ content: AXE });
  const res = await page.evaluate(async () => {
    // @ts-ignore
    return window.axe.run(document, { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa', 'best-practice'] } });
  });
  for (const v of res.violations) {
    const line = `${name}: [${v.impact}] ${v.id} — ${v.help} (${v.nodes.length} noder; t.ex. ${v.nodes[0]?.target?.[0] ?? '?'})`;
    report.push(line);
    if (v.impact === 'serious' || v.impact === 'critical') hard++; else soft++;
  }
  console.log(`${name}: ${res.violations.length} regelbrott (${res.passes.length} godkända regler)`);
  for (const v of res.violations) console.log(`   - [${v.impact}] ${v.id}: ${v.help} → ${v.nodes[0]?.target?.[0] ?? '?'}`);
}

await page.goto(BASE); await page.waitForSelector('button[type=submit]'); await audit('inloggning');
await page.click('text=Ny här? Skapa konto'); await page.waitForSelector('#name'); await audit('registrering');
await page.fill('#name', 'A11y-testaren'); await page.fill('#email', `a11y-${stamp}@test.example`); await page.fill('#password', 'a11y-losenord-123');
await page.click('button[type=submit]'); await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 60000 }); await audit('start');
await page.click('text=Kom igång'); await page.waitForSelector('text=Vem gäller det?'); await audit('intag-1');
await page.click('button:has-text("Mig själv")'); await page.waitForTimeout(300); await audit('intag-2');
await page.click('text=svårt att få ekonomin'); await page.waitForTimeout(300); await audit('intag-3');
await page.click('button:has-text("Själv")'); await page.waitForTimeout(300);
for (let step = 0; step < 30; step++) {
  if (await vis('text=Det här ser du ut att kunna ha rätt till')) break;
  const h = ((await page.locator('main h1, main h2, h1, h2').first().textContent().catch(() => '')) ?? '').toLowerCase();
  if (h.includes('tar reda på')) { await page.waitForTimeout(1000); continue; }
  const num = await vis('input[type="number"]');
  if (num) { await num.fill(h.includes('född') || h.includes('år') ? '1979' : '7000'); const nx = await vis('button:has-text("Nästa")'); if (nx) { await nx.click(); await page.waitForTimeout(400); continue; } }
  let clicked = false;
  for (const s of ['button:has-text("Nej")', 'button:has-text("Hoppa över")', 'button:has-text("Arbetslös")', 'button:has-text("15 000")', 'button:has-text("Nästa")']) { const l = await vis(s); if (l) { await l.click(); clicked = true; break; } }
  if (!clicked) { const any = page.locator('main button:not([disabled])').filter({ hasNotText: 'Tillbaka' }).first(); if (await any.count()) { await any.click(); clicked = true; } }
  if (!clicked) fail(`intaget fastnade på "${h}"`);
  await page.waitForTimeout(400);
}
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 60000 });
await page.waitForSelector('a[href*="/stod/"]', { timeout: 45000 }); await page.waitForTimeout(600); await audit('analys');
const hrefs = await page.locator('a[href*="/stod/"]').evaluateAll((as) => as.map((a) => a.getAttribute('href')));
const med = hrefs.find((h) => !/tandvardsbidrag|hogkostnadsskydd/.test(h)); if (!med) fail('inget stöd med ansökan');
await page.goto(`${BASE}${med}`); await page.waitForSelector('text=Redo att börja?', { timeout: 30000 }); await audit('stodsida');
await page.click('button:has-text("Förbered ansökan i systemet")'); await page.waitForSelector('input[type=checkbox]', { timeout: 30000 }); await audit('kop-samtycke');
await page.locator('input[type=checkbox]').first().check(); await page.click('button:has-text("Förbered ansökan —")');
await page.waitForSelector('button:has-text("Bekräfta betalning")', { timeout: 30000 }); await audit('kop-mock');
await page.click('button:has-text("Bekräfta betalning")'); await page.waitForURL(/\/ansokningar\//, { timeout: 30000 }); await page.waitForTimeout(600); await audit('arbetsyta');
await page.goto(`${BASE}/konto`); await page.waitForSelector('text=Konto och data', { timeout: 30000 }); await audit('konto');

await browser.close();
console.log('\n' + (report.length ? report.join('\n') : 'Inga regelbrott.'));
console.log(`\nSUMMA: ${hard} serious/critical · ${soft} moderate/minor`);
if (hard > 0) fail(`${hard} allvarliga tillgänglighetsbrott`);
console.log('a11ycheck OK');
