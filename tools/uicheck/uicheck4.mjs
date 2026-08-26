/**
 * Betalväggsflödet i webappen: teaser (utan läckage) → simulerad betalning →
 * full analys med disclaimer.
 */
import { launchChromium, artifactsDir } from '../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
page.on('pageerror', (e) => console.log('PAGEERROR:', e.message));

await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Betalaren');
await page.fill('#email', `betala-${stamp}@test.example`);
await page.fill('#password', 'team-test-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 10000 });
console.log('OK: registrerad');

// Skapa fixture via API:t (samma cookies) — ensamstående förälder-scenariot.
const projectId = await page.evaluate(async () => {
  const post = async (url, body) => {
    const r = await fetch(url, {
      method: 'POST',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (!r.ok && r.status !== 201) throw new Error(`${url}: ${r.status}`);
    return r.json();
  };
  const { profile } = await post('/v1/profiles', {
    kind: 'person', displayName: 'Min situation', applicantType: 'individual', country: 'SE',
    facts: {
      'person.hasChildrenAtHome': true,
      'person.lowHouseholdIncome': true,
      'person.paysHousingCost': true,
      'person.ageYears': 45,
      'person.ageBand': '29-65',
      'person.ageUnder29': false,
      'person.age40OrYounger': false,
      'person.age60Plus': false,
      'person.age62Plus': false,
      'person.age66Plus': false,
      'person.age67Plus': false,
    },
  });
  const { project } = await post('/v1/projects', {
    profileId: profile.id, title: 'Min ekonomiska situation', intent: 'Jag har svårt att få ekonomin att gå ihop.',
  });
  await post(`/v1/projects/${project.id}/matches`, {});
  return project.id;
});
console.log('OK: fixture skapad', projectId);

// 1. Teasern: värdet syns, detaljerna inte.
await page.goto(`${BASE}/projekt/${projectId}`);
await page.waitForSelector('text=Din preliminära bidragsanalys är klar', { timeout: 10000 });
await page.waitForSelector('text=hög relevans');
await page.waitForSelector('text=Lås upp din bidragsanalys — 39 kr');
const teaserBody = await page.textContent('body');
for (const forbidden of ['Bostadsbidrag', 'Försäkringskassan', 'Underhållsstöd']) {
  if (teaserBody.includes(forbidden)) throw new Error(`TEASERLÄCKA: ${forbidden}`);
}
if (!teaserBody.includes('Detta är en vägledning och inte ett myndighetsbeslut')) throw new Error('disclaimer saknas i teasern');
await page.screenshot({ path: `${SHOT}/14-paywall.png`, fullPage: true });
console.log('OK: teaser utan läckage, med disclaimer och pris');

// 3. Starta betalning → simulerade instruktioner.
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD', { timeout: 10000 });
await page.screenshot({ path: `${SHOT}/15-mock-betalning.png`, fullPage: true });
console.log('OK: simulerad betalning tydligt märkt');

// 4. Bekräfta → kvittobekräftelse (betalningen är händelsen, inte klicket).
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓', { timeout: 10000 });
const confirmBody = await page.textContent('body');
if (!confirmBody.includes('Din bidragsanalys är nu upplåst')) throw new Error('upplåsningsbeskedet saknas');
if (!/Kvitto BS-\d{4}-\d{6}/.test(confirmBody)) throw new Error('kvittonummer saknas på bekräftelsen');
await page.screenshot({ path: `${SHOT}/19-betalning-genomford.png`, fullPage: true });
console.log('OK: bekräftelseskärm med kvittonummer och kontohänvisning');

// 5. Visa analysen.
await page.click('text=Visa min analys');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 10000 });
const fullBody = await page.textContent('body');
for (const expected of ['Bostadsbidrag', 'Försäkringskassan', 'Detta är en vägledning och inte ett myndighetsbeslut']) {
  if (!fullBody.includes(expected)) throw new Error(`saknas efter upplåsning: ${expected}`);
}
await page.screenshot({ path: `${SHOT}/16-upplast.png`, fullPage: true });
console.log('OK: full analys efter bekräftad betalning');

// 6. Kvittot: verifikationsdokument med momsspecifikation + omskick.
await page.click('text=Visa kvitto');
const receiptDoc = await page.textContent('pre');
for (const expected of ['KVITTO', 'Kvittonummer', 'Köp-ID', 'Moms (25,00 %)', '31,20 kr', '7,80 kr', '39,00 kr']) {
  if (!receiptDoc.includes(expected)) throw new Error(`kvittodokumentet saknar: ${expected}`);
}
await page.screenshot({ path: `${SHOT}/20-kvitto.png`, fullPage: true });
console.log('OK: kvitto med korrekt momsspecifikation, sparat i kontot');

// 4. Omladdning: fortsatt upplåst (persistens, inte klienttillstånd).
await page.reload();
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till', { timeout: 10000 });
console.log('OK: upplåsningen består efter omladdning');

await browser.close();
console.log('ALL PAYWALL UI CHECKS PASSED');
