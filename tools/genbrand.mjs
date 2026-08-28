/**
 * Bidragskoll brand-asset generator — HÄRLEDER ALLT ur en enda käll-SVG
 * (apps/web/public/logo-mark.svg, Signal-märket: taklinje + bock på blå ruta).
 * Ändras märket regenereras favicon, app-ikoner och OG-bild i ett svep.
 * "Ändra loggan → kör detta → allt följer med." Kräver Chromium (samma som
 * övriga browserkontroller).
 *
 *   node tools/genbrand.mjs
 *
 * Två varianter, båda ur samma källa (designsystemet Signal, avsnitt Märket):
 *   full   — ruta + taklinje + bock. Används från 40px och uppåt.
 *   liten  — ruta + bock med tyngre streck; taket faller bort under ~24px
 *            eftersom två linjer nära varandra grumlar ihop i en webbläsarflik.
 *
 * Producerar i apps/web/public/:
 *   favicon.svg        liten variant (renderas i flikar ~16–32px)
 *   icon-32.png        liten variant · icon-180/192/512.png full variant
 *   favicon.ico        32px-PNG inbäddad i ICO
 *   og/bidragskoll-og.png  1200×630 delningsbild (lockup på ljus canvas)
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const PUB = join(ROOT, 'apps/web/public');
const BLUE = '#1273d4';        // --primary — rutan
const ROOF = '#6fb2f0';        // --primary-light — taklinjen

// Läs käll-märket och plocka isär det, så geometrin bara finns ETT ställe.
const src = readFileSync(join(PUB, 'logo-mark.svg'), 'utf8');
const inner = src
  .replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '')
  .replace(/<!--[\s\S]*?-->/g, '').trim();
const parts = inner.match(/<(rect|polyline)\b[^>]*\/>/g) ?? [];
const roof = parts.find((el) => el.toLowerCase().includes(ROOF));
if (!roof) throw new Error('logo-mark.svg: hittar ingen taklinje i ' + ROOF + ' — har märket ritats om?');

const svg = (body, attrs = '') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40"${attrs}>${body}</svg>`;
// Full variant: märket som det är ritat. Liten variant: taket bort, tyngre bock.
const full = svg(parts.join(''));
const small = svg(parts.filter((el) => el !== roof)
  .join('').replace('stroke-width="3.6"', 'stroke-width="4.4"'));

writeFileSync(join(PUB, 'favicon.svg'), small + '\n');

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

// App-ikoner: full variant från 180px, liten variant i 32px-fliken.
const iconHtml = (px) => {
  const body = px <= 32 ? small : full;
  return `<!doctype html><meta charset=utf8><style>*{margin:0}body{width:${px}px;height:${px}px}svg{display:block}</style>`
    + body.replace('<svg ', `<svg width="${px}" height="${px}" `);
};
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
 body{width:1200px;height:630px;background:#f7f5f0;font-family:ui-sans-serif,system-ui,Arial,sans-serif;
   display:flex;flex-direction:column;justify-content:center;padding:0 96px}
 .lock{display:flex;align-items:center;gap:34px}
 .lock svg{width:132px;height:132px}
 .word{font-family:Georgia,'Source Serif 4',serif;font-weight:700;font-size:104px;color:#0a3f78;letter-spacing:-2px}
 .tag{margin-top:34px;font-weight:600;font-size:38px;color:#57534a;max-width:940px;line-height:1.35}
 .bar{position:absolute;left:0;bottom:0;width:100%;height:16px;background:${BLUE}}
</style>
<div class="lock">${full}<span class="word">Bidragskoll</span></div>
<div class="tag">Berätta din situation — se vilka stöd du ser ut att kunna ha rätt till.</div>
<div class="bar"></div>`;
mkdirSync(join(PUB, 'og'), { recursive: true });
await shot(ogHtml, 1200, 630, join(PUB, 'og/bidragskoll-og.png'));

await browser.close();
console.log('Bidragskoll-brandassets genererade ur logo-mark.svg: favicon.svg, icon-32/180/192/512.png, favicon.ico, og/bidragskoll-og.png');
