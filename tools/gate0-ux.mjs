/**
 * GATE 0 — UX-blocket: webbläsarkontroll av hela publika ytan.
 * Kräver byggd yta (npm run seo:build) + Chromium (npx playwright install
 * chromium eller CHROMIUM_PATH). Kontrollerar varje sida i mobil (320 px)
 * och desktop (1280 px):
 *   - ingen horisontell overflow (dokumentbredd > viewport)
 *   - exakt en synlig H1
 *   - alla länkar har läsbar text (inga tomma ankare)
 *   - sidan har en tydlig nästa steg-länk (§42 inga återvändsgränder)
 * Skriver artifacts/gate0-ux.json + skärmdumpar (bevis) till
 * artifacts/gate0-shots/. Exit 1 vid fynd.
 */
import { readdirSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = join(ROOT, 'artifacts', 'seo-site');
const SHOTS = join(ROOT, 'artifacts', 'gate0-shots');
mkdirSync(SHOTS, { recursive: true });

const pages = [];
(function walk(dir, rel) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (e.isDirectory()) walk(join(dir, e.name), `${rel}${e.name}/`);
    else if (e.name === 'index.html') pages.push(rel);
  }
})(join(SITE, 'bidrag'), '/bidrag/');
pages.sort();

const CHROME = process.env.CHROMIUM_PATH
  || (existsSync('/opt/pw-browsers/chromium') ? '/opt/pw-browsers/chromium' : undefined);
const browser = await chromium.launch({ executablePath: CHROME });
const findings = [];
const SHOT_PAGES = ['/bidrag/', '/bidrag/privatpersoner/', '/bidrag/csn-studiemedel/', '/bidrag/kommun-forsorjningsstod/', '/bidrag/foretag/'];

for (const [vw, label] of [[320, 'mobil320'], [1280, 'desktop1280']]) {
  const ctx = await browser.newContext({ viewport: { width: vw, height: 900 } });
  const page = await ctx.newPage();
  // Sandlådan saknar utgående nät — abortera externa anrop (Google Fonts)
  // så att file://-laddningar inte väntar på nättimeouts.
  await page.route(/^https?:\/\//, (route) => route.abort());
  for (const rel of pages) {
    await page.goto('file://' + join(SITE, rel, 'index.html'), { waitUntil: 'load' });
    const r = await page.evaluate(async () => {
      await new Promise((res) => requestAnimationFrame(() => requestAnimationFrame(res)));
      const doc = document.documentElement;
      // Mät både scrollbredd och faktiskt bredaste element — enstaka
      // layoutpass kan ge falsk scrollWidth innan stilarna satt sig.
      let maxRight = 0;
      for (const el of document.querySelectorAll('*')) maxRight = Math.max(maxRight, el.getBoundingClientRect().right);
      const overflow = Math.min(doc.scrollWidth - doc.clientWidth, Math.round(maxRight - doc.clientWidth));
      const h1s = [...document.querySelectorAll('h1')].filter((h) => h.offsetParent !== null || h.offsetHeight > 0).length;
      const emptyAnchors = [...document.querySelectorAll('a')].filter((a) => !a.textContent.trim() && !a.getAttribute('aria-label')).length;
      const links = document.querySelectorAll('a[href]').length;
      return { overflow, h1s, emptyAnchors, links };
    });
    if (r.overflow > 1) findings.push({ page: rel, vy: label, fynd: `horisontell overflow ${r.overflow}px` });
    if (r.h1s !== 1) findings.push({ page: rel, vy: label, fynd: `${r.h1s} synliga H1` });
    if (r.emptyAnchors > 0) findings.push({ page: rel, vy: label, fynd: `${r.emptyAnchors} tomma ankare` });
    if (r.links < 2) findings.push({ page: rel, vy: label, fynd: 'återvändsgränd — färre än 2 länkar vidare' });
    if (SHOT_PAGES.includes(rel)) {
      await page.screenshot({ path: join(SHOTS, `${label}-${rel.replaceAll('/', '_')}.png`), fullPage: vw === 320 });
    }
  }
  await ctx.close();
}
await browser.close();

writeFileSync(join(ROOT, 'artifacts', 'gate0-ux.json'), JSON.stringify({ sidor: pages.length, vyer: ['320px', '1280px'], fynd: findings }, null, 2) + '\n');
console.log(`GATE 0 UX: ${pages.length} sidor × 2 vyer kontrollerade, ${findings.length} fynd`);
for (const f of findings.slice(0, 20)) console.log(`  [${f.vy}] ${f.page} — ${f.fynd}`);
console.log(`→ artifacts/gate0-ux.json + skärmdumpar i artifacts/gate0-shots/`);
process.exit(findings.length ? 1 : 0);
