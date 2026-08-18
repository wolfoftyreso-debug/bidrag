/**
 * Release-gate-UI: kvittot som förstaklass i kontot (ingen e-post),
 * betalvägg utan mailfält/mail-löften, Mina köp med kvittodokument,
 * och ärligt fail-closed när lösenordsåterställning saknar kanal.
 */
import { launchChromium, artifactsDir } from '../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Kvittoägaren');
await page.fill('#email', `kvitto-${stamp}@test.example`);
await page.fill('#password', 'team-test-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');

const projectId = await page.evaluate(async () => {
  const post = async (url, body) => (await fetch(url, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })).json();
  const { profile } = await post('/v1/profiles', { kind: 'person', displayName: 'K', applicantType: 'individual', country: 'SE', facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true } });
  const { project } = await post('/v1/projects', { profileId: profile.id, title: 'Kvittotest', intent: 'test' });
  await post(`/v1/projects/${project.id}/matches`, {});
  return project.id;
});

// 1. Betalväggen: inget mailfält, inga mail-löften.
await page.goto(`${BASE}/projekt/${projectId}`);
await page.waitForSelector('text=Din preliminära bidragsanalys är klar');
const teaserBody = await page.innerText('body');
for (const forbidden of ['Vart vill du ha ditt kvitto', 'skickar ett kvitto', 'e-postadress']) {
  if (teaserBody.toLowerCase().includes(forbidden.toLowerCase())) throw new Error(`mail-löfte kvar i betalväggen: "${forbidden}"`);
}
if (!teaserBody.includes('Kvittot sparas på ditt konto under Mina köp')) throw new Error('kontohänvisningen saknas');
console.log('OK: betalvägg utan e-postberoende');

// 2. Betala (mock i dev) → bekräftelsen pekar på Mina köp.
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD');
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
const confirmBody = await page.innerText('body');
if (!/Kvitto BS-\d{4}-\d{6} är sparat på ditt konto/.test(confirmBody)) throw new Error('kvittobeskedet pekar inte på kontot');
if (confirmBody.includes('skickas till')) throw new Error('bekräftelsen lovar fortfarande mail');
await page.screenshot({ path: `${SHOT}/23-bekraftelse-konto.png`, fullPage: true });
console.log('OK: bekräftelse hänvisar till Mina köp, inga mail-löften');

// 3. Rapporten: kvittorad utan omskicksknapp.
await page.click('text=Visa min analys');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
await page.waitForSelector('text=sparat under', { timeout: 10000 });
const reportBody = await page.innerText('body');
if (reportBody.includes('Skicka om kvittot')) throw new Error('omskicksknappen är kvar');
console.log('OK: rapportens kvittorad pekar på kontot');

// 4. Mitt konto → Mina köp → kvitto med momsspecifikation.
await page.click('nav >> text=Konto & data');
await page.waitForSelector('text=Mina köp');
await page.waitForSelector('text=Bidragsanalys — Kvittotest');
await page.click('button:has-text("BS-")');
await page.waitForSelector('pre');
const receiptDoc = await page.textContent('pre');
for (const expected of ['KVITTO', 'Kvittonummer', 'Köp-ID', 'Moms (25,00 %)', '31,20 kr', '7,80 kr', '39,00 kr', 'Betalningsstatus', 'Återbetalning']) {
  if (!receiptDoc.includes(expected)) throw new Error(`kvittot i kontot saknar: ${expected}`);
}
await page.screenshot({ path: `${SHOT}/24-mina-kop.png`, fullPage: true });
console.log('OK: Mina köp visar betalning + fullständigt kvitto');

// 5. Fail-closed lösenordsåterställning (ingen mailkanal i dev-miljön).
await page.click('text=Logga ut');
await page.waitForSelector('text=Glömt lösenord?');
await page.click('text=Glömt lösenord?');
await page.fill('#email', `kvitto-${stamp}@test.example`);
await page.click('text=Skicka återställningslänk');
await page.waitForSelector('text=Lösenordsåterställning är inte tillgänglig');
await page.screenshot({ path: `${SHOT}/25-recovery-fail-closed.png`, fullPage: true });
console.log('OK: återställning fail-closed med ärligt besked (ingen kanal i denna miljö)');

await browser.close();
console.log('RELEASE GATE UI CHECKS PASSED');
