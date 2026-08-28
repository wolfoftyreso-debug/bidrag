/**
 * F-ÅLDER (användarfynd 2026-08-28): "Jag angav 1987 så jag kan inte vara 40?"
 *
 * Åldersfakta härleds ur födelseåret i intaget. Ett följdfrågesvar på samma
 * faktum — sparat i webbläsaren från en tidigare körning eller en tidigare
 * version av demot — vann tyst över det härledda och stängde ute stöd
 * personen faktiskt uppfyllde (Startstöd till unga jordbrukare).
 *
 * Kontrollerna:
 *   1. Ett sparat läge under den GAMLA nyckeln läses aldrig in.
 *   2. Intagets härledda faktum vinner även om en motsägelse ligger i det
 *      sparade läget — och motsägelsen städas bort ur lagringen.
 *   3. Födelseåret räknas rätt mot gränserna (1987 → 40 år eller yngre).
 */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 1200 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${artifactsDir}/demo/demo.html`);

// Ett läge där födelseåret säger "39 år" men ett gammalt svar säger motsatsen.
const motsagelse = {
  step: 'done',
  history: ['entry'],
  a: {
    track: 'personal', household: 'alone', children: 'no', birthYear: 1987,
    employment: 'self_employed', businessForm: 'sole_trader', bizSector: 'agriculture',
    income: '15-25', paysHousing: false, movingAbroad: false, disability: false,
  },
  extraFacts: { 'person.age40OrYounger': false },
  unlocked: true,
};

const set = async (key) => {
  await page.evaluate(([k, st]) => { localStorage.clear(); localStorage.setItem(k, JSON.stringify(st)); },
    [key, motsagelse]);
  await page.reload();
};

// 1. Gamla nyckeln ignoreras helt — utkastet från före födelseårs-intaget
//    får inte återuppstå.
await set('bidragse-demo-v1');
await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 15000 });
console.log('1. Sparat läge under den gamla nyckeln läses inte in ✓');

// 2 + 3. Med motsägelsen i det nya läget ska födelseåret ändå vinna.
await set('bidragse-demo-v2');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 20000 });
const body = await page.innerText('body');
if (body.includes('Sökande ska vara 40 år eller yngre')) {
  throw new Error('åldersvillkoret redovisas som ej uppfyllt trots födelseår 1987 (39 år)');
}
if (!body.includes('Startstöd till unga jordbrukare')) {
  throw new Error('Startstöd till unga jordbrukare saknas — åldersgrinden stänger fortfarande ute stödet');
}
console.log('2. Födelseåret vinner över ett inaktuellt sparat svar ✓');

const kvar = await page.evaluate(() => {
  const raw = localStorage.getItem('bidragse-demo-v2');
  return raw ? Object.keys(JSON.parse(raw).extraFacts ?? {}) : [];
});
if (kvar.includes('person.age40OrYounger')) {
  throw new Error(`motsägelsen ligger kvar i lagringen: ${kvar.join(', ')}`);
}
console.log('3. Det inaktuella svaret städas bort ur lagringen ✓');

await browser.close();
console.log('ÅLDERSCHECK KLAR');
