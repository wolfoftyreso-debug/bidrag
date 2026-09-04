/**
 * Behörighetskontrollen i riktig webbläsare: serverar artifacts/seo-site
 * lokalt, öppnar /bidrag/bostadsbidrag/ och klickar igenom verktyget.
 * Kräver att SEO-ytan är genererad (npm run seo:build) + Chromium.
 *
 *   node tools/uicheck/precheckcheck-browser.mjs
 */
import { createServer } from 'node:http';
import { readFileSync, existsSync, statSync } from 'node:fs';
import { join, extname } from 'node:path';
import { launchChromium, artifactsDir } from '../lib/browser.mjs';

const SITE = join(artifactsDir, 'seo-site');
const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json' };
const server = createServer((req, res) => {
  let p = join(SITE, decodeURIComponent(req.url.split('?')[0]));
  if (existsSync(p) && statSync(p).isDirectory()) p = join(p, 'index.html');
  if (!existsSync(p)) { res.writeHead(404); res.end('not found'); return; }
  res.writeHead(200, { 'content-type': MIME[extname(p)] ?? 'application/octet-stream' });
  res.end(readFileSync(p));
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${server.address().port}`;
const fail = (m) => { console.log('FEL:', m); process.exit(1); };

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 420, height: 900 } });
page.on('pageerror', (e) => fail(`pageerror: ${e.message}`));

await page.goto(`${base}/bidrag/bostadsbidrag/`);
await page.waitForSelector('#precheck.precheck-live', { timeout: 15000 });
const first = await page.textContent('#precheck .precheck-q');
console.log(`1. Verktyget lever, första frågan: "${first.trim()}"`);
if (!/Fråga 1 av \d+/.test(await page.textContent('#precheck'))) fail('räknaren "Fråga 1 av N" saknas');

// Svara som en 25-åring utan barn, låg inkomst, betalar hyra ⇒ unga: ja, barnfamiljer: nej.
for (let i = 0; i < 8; i++) {
  if (await page.locator('#precheck .precheck-res').count()) break;
  const q = (await page.textContent('#precheck .precheck-q')).trim();
  if (q === 'Vilket år är du född?') { await page.fill('#precheck-year', '2001'); await page.click('#precheck button[type=submit]'); }
  else if (/barn som bor hos dig/.test(q)) await page.click('#precheck [data-act="no"]');
  else await page.click('#precheck [data-act="yes"]');
  await page.waitForTimeout(80);
}
await page.waitForSelector('#precheck .precheck-res', { timeout: 5000 });
const body = await page.textContent('#precheck');
if (!/Bostadsbidrag för unga[\s\S]*ser ut att kunna gälla dig/.test(body)) fail('unga-varianten fick inte "ser ut att kunna gälla dig"');
if (!/barnfamiljer[\s\S]*uppfyller inte de publicerade kraven/.test(body)) fail('barnfamiljer fick inte "uppfyller inte"');
if (!body.includes('Slutligt beslut fattas alltid av myndigheten')) fail('beslutsraden saknas i resultatet');
if (!body.includes('alltid gratis')) fail('gratisvägen saknas i resultatet');
if (!(await page.locator('#precheck a:has-text("Ansök själv hos Försäkringskassan — gratis")').count())) fail('ansök-själv-länken saknas');
console.log('2. Resultat: unga = ser ut att kunna, barnfamiljer = uppfyller inte, beslutsrad + gratisväg + ansök-själv ✓');

// Ändra ett svar ⇒ omräkning (F-STABIL: svaren står kvar och går att ändra).
await page.click('#precheck summary');
await page.click('#precheck li:has-text("barn som bor hos dig") button');
await page.click('#precheck [data-act="yes"]');
for (let i = 0; i < 6; i++) {
  if (await page.locator('#precheck .precheck-res').count()) break;
  await page.click('#precheck [data-act="yes"]').catch(() => {});
  await page.waitForTimeout(60);
}
const body2 = await page.textContent('#precheck');
if (!/barnfamiljer[\s\S]*ser ut att kunna gälla dig/.test(body2)) fail('ändrat svar räknades inte om');
console.log('3. Ändrat svar ⇒ barnfamiljer räknas om till "ser ut att kunna" ✓');

// Stödets egen sida: en fråga i taget, underlagslistan FÖRE ansök-länken, ingen "Se stödet"-länk till sig själv.
await page.goto(`${base}/bidrag/fk-bostadsbidrag-unga/`);
await page.waitForSelector('#precheck.precheck-live', { timeout: 15000 });
for (let i = 0; i < 6; i++) {
  if (await page.locator('#precheck .precheck-res').count()) break;
  const q = (await page.textContent('#precheck .precheck-q')).trim();
  if (q === 'Vilket år är du född?') { await page.fill('#precheck-year', '2001'); await page.click('#precheck button[type=submit]'); }
  else await page.click('#precheck [data-act="yes"]');
  await page.waitForTimeout(80);
}
await page.waitForSelector('#precheck .precheck-res', { timeout: 5000 });
const ent = await page.textContent('#precheck');
if (!ent.includes('ser ut att kunna gälla dig')) fail('stödsidan: 25-åring med låg inkomst och hyra fick inte "ser ut att kunna"');
const iU = ent.indexOf('Underlag att ha framme innan du ansöker'); const iA = ent.indexOf('Ansök själv hos Försäkringskassan — gratis');
if (iU < 0 || iA < 0 || iU > iA) fail('stödsidan: underlagslistan står inte före ansök-länken');
if (await page.locator('#precheck a:has-text("Se stödet")').count()) fail('stödsidan länkar till sig själv');
console.log('5. Stödsidan: underlagslistan före utklicket, ingen självlänk ✓');

// 320 px: inget horisontellt overflow.
await page.setViewportSize({ width: 320, height: 800 });
const overflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth + 1);
if (overflow) fail('horisontellt overflow på 320 px');
console.log('4. 320 px utan overflow ✓');

await browser.close();
server.close();
console.log('precheckcheck-browser OK');
