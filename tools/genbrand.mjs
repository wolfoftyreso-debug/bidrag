/**
 * Bidragskoll brand-asset generator — HÄRLEDER ALLT ur en enda käll-SVG
 * (apps/web/public/logo-mark.svg, X-person-märket i #0056A3). Ändras märket
 * regenereras favicon, app-ikoner och OG-bild i ett svep. "Ändra loggan → kör
 * detta → allt följer med." Kräver Chromium (samma som övriga browserkontroller).
 *
 *   node tools/genbrand.mjs
 *
 * Producerar i apps/web/public/:
 *   favicon.svg        vit figur på Bidragskoll-blå rundad ruta
 *   icon-32/180/192/512.png, favicon.ico (32px PNG-inbäddad)
 *   og/bidragskoll-og.png  1200×630 delningsbild (lockup på ljus canvas)
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const PUB = join(ROOT, 'apps/web/public');
const BLUE = '#0056A3';

// Läs käll-märket och extrahera det inre (grupp + cirkel) så geometrin bara
// finns ETT ställe. Färgen byts per användning (blå/vit).
const src = readFileSync(join(PUB, 'logo-mark.svg'), 'utf8');
const inner = src.replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '').trim();
const mark = (color) => `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">${inner.replace(/#0056A3/gi, color)}</svg>`;

// favicon.svg: vit figur, centrerad med luft, på blå rundad ruta.
const faviconSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="${BLUE}"/>
  <g transform="translate(12 12) scale(0.4)">${inner.replace(/#0056A3/gi, '#ffffff')}</g>
</svg>
`;
writeFileSync(join(PUB, 'favicon.svg'), faviconSvg);

const EXTERNAL = /^https?:\/\//;
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM_PATH
  || '/opt/pw-browsers/chromium' });

async function shot(html, w, h, out) {
  const ctx = await browser.newContext({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  const page = await ctx.newPage();
  await page.route(EXTERNAL, (r) => r.abort()); // ingen extern nätverksväntan
  await page.setContent(html, { waitUntil: 'load' });
  await page.waitForTimeout(150);
  await page.screenshot({ path: out, omitBackground: out.endsWith('.png') && !html.includes('data-bg') });
  await ctx.close();
}

// App-ikoner: favicon.svg skalad till varje storlek (blå ruta, vit figur).
const iconHtml = (px) => `<!doctype html><meta charset=utf8><style>*{margin:0}body{width:${px}px;height:${px}px}svg{display:block}</style>${faviconSvg.replace('viewBox="0 0 64 64"', `width="${px}" height="${px}" viewBox="0 0 64 64"`)}`;
for (const px of [32, 180, 192, 512]) {
  await shot(iconHtml(px), px, px, join(PUB, `icon-${px}.png`));
}
// favicon.ico = 32px-ikonen inbäddad (PNG-i-ICO, samma teknik som tidigare).
const png32 = readFileSync(join(PUB, 'icon-32.png'));
const ico = Buffer.alloc(6 + 16 + png32.length);
ico.writeUInt16LE(0, 0); ico.writeUInt16LE(1, 2); ico.writeUInt16LE(1, 4);
ico.writeUInt8(32, 6); ico.writeUInt8(32, 7); ico.writeUInt8(0, 8); ico.writeUInt8(0, 9);
ico.writeUInt16LE(1, 10); ico.writeUInt16LE(32, 12);
ico.writeUInt32LE(png32.length, 14); ico.writeUInt32LE(6 + 16, 18);
png32.copy(ico, 6 + 16);
writeFileSync(join(PUB, 'favicon.ico'), ico);

// OG-delningsbild 1200×630: lockup (blå märke + ordbild) på ljus Bläck-canvas,
// med tagline. Open Sans laddas via Google Fonts (renderas här, bakas in i PNG).
const ogHtml = `<!doctype html><meta charset=utf8>
<link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@600;800&display=swap" rel=stylesheet>
<style>
 *{margin:0;box-sizing:border-box}
 body{width:1200px;height:630px;background:#f6f4ee;font-family:'Open Sans',sans-serif;
   display:flex;flex-direction:column;justify-content:center;padding:0 96px}
 .lock{display:flex;align-items:center;gap:34px}
 .lock svg{width:132px;height:132px}
 .word{font-weight:800;font-size:104px;color:${BLUE};letter-spacing:-2px}
 .tag{margin-top:34px;font-weight:600;font-size:38px;color:#3a362e;max-width:940px;line-height:1.35}
 .bar{position:absolute;left:0;bottom:0;width:100%;height:16px;background:${BLUE}}
</style>
<div class="lock">${mark(BLUE)}<span class="word">Bidragskoll</span></div>
<div class="tag">Berätta din situation — se vilka stöd du ser ut att kunna ha rätt till.</div>
<div class="bar"></div>`;
mkdirSync(join(PUB, 'og'), { recursive: true });
await shot(ogHtml, 1200, 630, join(PUB, 'og/bidragskoll-og.png'));

await browser.close();
console.log('Bidragskoll-brandassets genererade ur logo-mark.svg: favicon.svg, icon-32/180/192/512.png, favicon.ico, og/bidragskoll-og.png');
