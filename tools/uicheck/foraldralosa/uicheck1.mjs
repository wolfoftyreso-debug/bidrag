import { launchChromium, artifactsDir } from '../../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT_DIR = artifactsDir;

const browser = await launchChromium();

// ── Spår 1: personlig rättighetsutredning ────────────────────────────────────
{
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  page.on('pageerror', (e) => console.log('PAGEERROR:', e.message));
  await page.goto(BASE);
  await page.click('text=Ny här? Skapa konto');
  await page.fill('#name', 'Ensamstående');
  await page.fill('#email', `pers-${Date.now()}@test.example`);
  await page.fill('#password', 'ui-test-losenord-123');
  await page.click('button[type=submit]');
  await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 10000 });
  await page.click('text=Kom igång');

  await page.waitForSelector('text=Vem gäller det?');
  await page.click('button:has-text("Mig själv")');
  await page.waitForSelector('text=Vad behöver du hjälp med?');
  await page.click('text=Jag har svårt att få ekonomin att gå ihop');
  await page.waitForSelector('text=Bor du själv');
  await page.click('button:has-text("Själv")');
  await page.waitForSelector('text=Har du barn');
  await page.click('button:has-text("Ja"):not(:has-text("växelvis"))');
  await page.waitForSelector('text=skilda håll');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=Går något av barnen i skolan?');
  await page.click('text=Ja, i grundskolan');
  await page.waitForSelector('text=skolutflykt');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=glasögon');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=väg till skolan');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=Hur gammal är du?');
  await page.fill('input[type="number"]', '1979');
  await page.click('button:has-text("Nästa")');
  await page.waitForSelector('text=Vad gör du i dag?');
  await page.click('button:has-text("Arbetslös")');
  await page.waitForSelector('text=inkomst per månad');
  await page.click('button:has-text("15 000–25 000 kr")');
  await page.waitForSelector('text=boendekostnader');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=hur mycket betalar du');
  await page.fill('input[type=number]', '8500');
  await page.click('button:has-text("Nästa")');
  await page.waitForSelector('text=något mer som påverkar');
  await page.click('button:has-text("Hoppa över")');

  // Betalvägg (mock i dev): lås upp analysen innan rapporten.
  await page.waitForSelector('text=Din preliminära bidragsanalys är klar', { timeout: 15000 });
  await page.click('text=Lås upp din bidragsanalys — 39 kr');
  await page.waitForSelector('text=SIMULERAD');
  await page.click('text=Bekräfta betalning (simulerad)');
  await page.waitForSelector('text=Betalning genomförd ✓');
  await page.click('text=Visa min analys');

  await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 15000 });
  const bodyText = await page.textContent('body');
  if (!bodyText.includes('Bostadsbidrag till barnfamiljer')) throw new Error('bostadsbidrag saknas i resultatet');
  if (!bodyText.includes('stämmer väl med kraven')) throw new Error('sannolikhetsspråk saknas');
  if (!bodyText.includes('slutligt beslut fattas alltid av myndigheten')) throw new Error('disclaimer saknas');
  await page.screenshot({ path: `${SHOT_DIR}/6-rattigheter.png`, fullPage: true });
  console.log('OK: personligt spår → rättighetslista med sannolikhetsspråk');
  await page.close();
}

// ── Spår 2: projektfinansiering (Jamaica-fallet) ─────────────────────────────
{
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  page.on('pageerror', (e) => console.log('PAGEERROR:', e.message));
  await page.goto(BASE);
  await page.click('text=Ny här? Skapa konto');
  await page.fill('#name', 'Dansläraren');
  await page.fill('#email', `proj-${Date.now()}@test.example`);
  await page.fill('#password', 'ui-test-losenord-123');
  await page.click('button[type=submit]');
  await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 10000 });
  await page.click('text=Kom igång');

  await page.waitForSelector('text=Vem gäller det?');
  await page.click('button:has-text("Mig själv")');
  await page.click('text=Jag söker pengar till ett projekt');
  await page.waitForSelector('text=Vad vill du åstadkomma?');
  await page.fill('textarea', 'Jag vill ta min dansgrupp till Jamaica för att träna dancehall och ta hem kunskapen till Sverige.');
  await page.click('button:has-text("Nästa")');
  await page.waitForSelector('text=Vem söker?');
  await page.click('text=privatperson eller enskild utövare');
  await page.waitForSelector('text=Vilken kommun');
  await page.click('button:has-text("Hoppa över")');
  await page.waitForSelector('text=yrkesverksam inom kulturområdet');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=Vilket område');
  await page.click('text=Kultur — dans');
  await page.waitForSelector('text=Vad ska ni göra?');
  await page.check('#act-exchange');
  await page.check('#act-training');
  await page.click('button:has-text("Nästa")');
  await page.waitForSelector('text=internationell del');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=erfarenheterna');
  await page.click('button:has-text("Ja")');
  await page.waitForSelector('text=barn eller unga');
  await page.click('button:has-text("Nej")');
  await page.waitForSelector('text=kostar projektet');
  await page.fill('input[type=number]', '100000');
  await page.click('button:has-text("Visa vad jag kan söka")');

  // Betalvägg (mock i dev): lås upp analysen innan rapporten.
  await page.waitForSelector('text=Din preliminära bidragsanalys är klar', { timeout: 15000 });
  await page.click('text=Lås upp din bidragsanalys — 39 kr');
  await page.waitForSelector('text=SIMULERAD');
  await page.click('text=Bekräfta betalning (simulerad)');
  await page.waitForSelector('text=Betalning genomförd ✓');
  await page.click('text=Visa min analys');

  await page.waitForSelector('text=Resebidrag', { timeout: 15000 });
  await page.screenshot({ path: `${SHOT_DIR}/2-matches.png`, fullPage: true });
  console.log('OK: projektspår → matchningar');

  await page.click('text=Resebidrag för internationellt kulturutbyte');
  await page.waitForSelector('text=Krav och bedömning');
  await page.click('text=Starta ansökan');
  await page.waitForSelector('text=Status', { timeout: 10000 });
  console.log('OK: ansökningsarbetsyta');
  await page.close();
}

await browser.close();
console.log('ALL UI CHECKS PASSED');
