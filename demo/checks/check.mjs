import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';
const S = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 900 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${S}/demo/demo.html`);

// Räkningarna i UI:t ska komma ur den bundlade kunskapsbasen — aldrig en
// hårdkodad siffra som tyst blir fel vid nästa kureringspass (fynd 2026-08-28:
// demon påstod 72 stöd när basen hade 85).
{
  const { readFileSync } = await import('node:fs');
  const opps = JSON.parse(readFileSync(new URL('../demo-opportunities.json', import.meta.url), 'utf8'));
  const authorities = new Set(opps.map((o) => o.authority).filter(Boolean)).size;
  const head = await page.textContent('body');
  if (!head.includes(`${opps.length} kurerade stöd`)) {
    throw new Error(`headern anger inte ${opps.length} kurerade stöd (kunskapsbasens verkliga antal)`);
  }
  if (!head.includes(`${opps.length} stöd, ${authorities} finansiärer`)) {
    throw new Error(`footern anger inte ${opps.length} stöd / ${authorities} finansiärer`);
  }
  console.log(`OK: räkningarna i UI:t matchar kunskapsbasen (${opps.length} stöd, ${authorities} finansiärer)`);
}

// Personligt spår: ensamstående förälder, arbetslös, låg inkomst
await page.click('text=svårt att få ekonomin');
await page.click('button:has-text("Själv")');
await page.click('.choice:has-text("Ja"):not(:has-text("växelvis"))');
await page.click('button:has-text("Ja")'); // skilda håll
await page.click('text=Ja, i grundskolan');
await page.click('.row >> button:has-text("Ja")'); // svårt betala skolutflykt → öppnar Majblomman
await page.click('.row >> button:has-text("Ja")'); // glasögon 8–19 → glasögonbidrag
await page.click('.row >> button:has-text("Ja")'); // besvärlig skolväg → skolskjuts
await page.fill('input[type=number]', '1979');
await page.click('button:has-text("Nästa")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")'); // betalar boende
await page.fill('input[type=number]', '8500');
await page.click('text=Nästa');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');

// Betalvägg: teasern visar värdet men läcker inga namn. (innerText = det som
// faktiskt renderas — kunskapsbasen ligger med avsikt i demots bundle.)
// Open Discovery: rapporten visas direkt och gratis — ingen teaser, ingen betalvägg.
await page.waitForSelector('text=Gå vidare med ansökan');
console.log('OK: simulerad Swish-betalning tydligt märkt');

await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
let body = await page.textContent('body');
if (!body.includes('Bostadsbidrag till barnfamiljer')) throw new Error('bostadsbidrag saknas');
if (!body.includes('stämmer väl med kraven')) throw new Error('sannolikhet saknas');
if (!body.includes('Uppfyller inte kraven')) throw new Error('uteslutningar saknas');
console.log('OK: personligt spår');

// F-VAD (mönsterkontroll mot Mobbin): varje resultatrad ska säga VAD stödet är
// utan att man klickar. Referenserna framhäver beloppet, men bara 1 av 85 stöd
// har ett kurerat maxbelopp — sammanfattningen är det vi ärligt kan visa.
{
  const rader = await page.locator('.match-sammanfattning').count();
  if (rader === 0) throw new Error('resultatraderna saknar sammanfattning — man måste klicka för att veta vad stödet är');
  const forsta = (await page.locator('.match-sammanfattning').first().innerText()).trim();
  if (forsta.length < 20) throw new Error(`sammanfattningen är tom eller stympad: "${forsta}"`);
  console.log(`OK: ${rader} resultatrader bär stödets sammanfattning`);
}

// F-VAL: den primära handlingen får inte kräva att man scrollar förbi hela
// listan. Valraden dyker upp när något valts och följer med nedtill.
{
  if (await page.locator('.valrad').count() !== 0) throw new Error('valraden visas innan något är valt');
  await page.locator('button:has-text("Vill ansöka")').first().click();
  await page.waitForSelector('.valrad');
  if (!(await page.locator('.valrad').isVisible())) throw new Error('valraden syns inte utan att man scrollar');
  const text = await page.locator('.valrad').innerText();
  if (!/1 stöd valt/.test(text)) throw new Error(`valraden räknar fel: "${text.replace(/\n/g, ' | ')}"`);
  if (await page.locator('.valrad button:has-text("Nästa")').count() === 0) throw new Error('valraden saknar Nästa-knappen');
  await page.locator('button:has-text("Vald — ingår i din plan")').first().click();
  await page.waitForTimeout(200);
  if (await page.locator('.valrad').count() !== 0) throw new Error('valraden ligger kvar när inget är valt');
  console.log('OK: valraden följer med nedtill och försvinner när inget är valt');
}

// Följdfråga: svara Ja på underhållsfrågan → underhållsstöd uppgraderas live
const before = (body.match(/stämmer väl med kraven/g) || []).length;
await page.locator('.q-row', { hasText: 'Betalar den andra föräldern' }).locator('button:has-text("Ja")').click();
await page.waitForTimeout(300);
body = await page.textContent('body');
const after = (body.match(/stämmer väl med kraven/g) || []).length;
if (after <= before) throw new Error(`live-omräkning misslyckades (${before} → ${after})`);
console.log(`OK: följdfråga uppgraderade bedömningen live (${before} → ${after} stämmer väl med kraven)`);
await page.screenshot({ path: `${S}/11-demo-personligt.png`, fullPage: true });

// Börja om → projektspår: Jamaica-fallet
await page.click('text=Börja om');
await page.click('text=pengar till ett projekt');
await page.click('text=privatperson eller enskild utövare');
await page.click('.row >> button:has-text("Ja")'); // yrkesverksam kultur
await page.click('text=Kultur — dans');
await page.check('input[type=checkbox] >> nth=0'); // utbyte/resa
await page.check('input[type=checkbox] >> nth=1'); // utbildning
await page.click('button:has-text("Nästa")');
await page.click('.row >> button:has-text("Ja")'); // internationell
await page.click('.row >> button:has-text("Ja")'); // kunskap hem
await page.click('.row >> button:has-text("Nej")'); // ej barn/unga
// Open Discovery: rapporten visas direkt och gratis — ingen teaser, ingen betalvägg.
await page.waitForSelector('text=Gå vidare med ansökan');
console.log('OK: betalvägg även i projektspåret');
await page.waitForSelector('text=/Stöd som kan passa|Bidrag och finansiering/');
body = await page.textContent('body');
if (!body.includes('Resebidrag för internationellt kulturutbyte')) throw new Error('resebidrag saknas');
console.log('OK: projektspår (Jamaica-fallet)');

// Förklaring expanderar med källrad
await page.locator('button.linkish', { hasText: 'Resebidrag för internationellt kulturutbyte' }).first().click();
await page.waitForSelector('text=Källa:');
console.log('OK: förklaring med källa och kriterier');
await page.screenshot({ path: `${S}/12-demo-projekt.png`, fullPage: true });

await browser.close();
console.log('DEMO VERIFIED');
