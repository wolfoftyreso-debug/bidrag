/**
 * Steg 2+3 i webbläsare: upplåst analys → "Vad vill du göra?" per stöd →
 * dokumentstudio → paketköp (49 kr, simulerat) → formulär → färdigt dokument →
 * PDF-nedladdning → kvitto för paketet under Mina köp.
 */
import { launchChromium, artifactsDir } from '../../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Dokumentmakaren');
await page.fill('#email', `dok-${stamp}@test.example`);
await page.fill('#password', 'team-test-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');

const projectId = await page.evaluate(async () => {
  const post = async (url, body) => (await fetch(url, { method: 'POST', credentials: 'include', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })).json();
  const { profile } = await post('/v1/profiles', { kind: 'person', displayName: 'D', applicantType: 'individual', country: 'SE',
    facts: { 'person.hasChildrenAtHome': true, 'person.childCostsStrain': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true } });
  const { project } = await post('/v1/projects', { profileId: profile.id, title: 'Dokumentresan', intent: 'test' });
  await post(`/v1/projects/${project.id}/matches`, {});
  return project.id;
});

// Lås upp analysen (mock).
await page.goto(`${BASE}/projekt/${projectId}`);
await page.waitForSelector('text=Lås upp din bidragsanalys — 39 kr');
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.waitForSelector('text=SIMULERAD');
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Betalning genomförd ✓');
await page.click('text=Visa min analys');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');

// 1. Vad vill du göra?-valet per stöd: gratisväg + förbered.
await page.waitForSelector('text=Vad vill du göra?');
const body1 = await page.innerText('body');
if (!body1.includes('Ansök själv — gratis')) throw new Error('gratisvägen saknas');
if (!body1.includes('Förbered min ansökan')) throw new Error('förbered-knappen saknas');
await page.screenshot({ path: `${SHOT}/26-vad-vill-du-gora.png`, fullPage: true });
console.log('OK: Ansök själv (gratis) + Förbered min ansökan per stöd');

// 2. Studio: paketerbjudande, inte styckdebitering.
await page.click('text=Förbered min ansökan');
await page.waitForSelector('text=Vill du ha hjälp med dokumenten?');
const offer = await page.innerText('body');
for (const expected of ['Ett dokument', 'Upp till 3 dokument', 'Alla dokument för en ansökan', '19 kr', '49 kr', '79 kr', 'ansöka själv — det är gratis']) {
  if (!offer.toLowerCase().includes(expected.toLowerCase())) throw new Error(`erbjudandet saknar: ${expected}`);
}
await page.screenshot({ path: `${SHOT}/27-paket.png`, fullPage: true });
console.log('OK: paketerbjudande med gratisvägen tydlig');

// 3. Köp 3-paketet (simulerat) → formulär → dokument.
await page.click('button:has-text("49 kr")');
await page.waitForSelector('text=SIMULERAD');
await page.click('text=Bekräfta betalning (simulerad)');
await page.waitForSelector('text=Välj dokument att skapa');
await page.waitForSelector('text=Du har 3 dokument kvar');
console.log('OK: 3 krediter efter bekräftat köp');

await page.locator('.match-row', { hasText: 'Beskrivning av behov' }).locator('button:has-text("Skapa")').click();
await page.waitForSelector('text=Vem gäller behovet?');
await page.fill('#q-fullName', 'Anna Ek');
await page.selectOption('#q-whoFor', 'barn');
await page.waitForSelector('#q-childName'); // villkorad fråga dök upp
await page.fill('#q-childName', 'Vera, 9 år');
await page.fill('#q-needWhat', 'Avgift och utrustning för fotboll under höstterminen.');
await page.fill('#q-needWhy', 'Utan stödet kan Vera inte fortsätta i laget med sina klasskamrater.');
await page.click('text=Skapa dokumentet');
await page.waitForSelector('text=Mina dokument');
await page.waitForSelector('text=Beskrivning av behov');
await page.waitForSelector('text=Du har 2 dokument kvar');
await page.screenshot({ path: `${SHOT}/28-dokument-skapat.png`, fullPage: true });
console.log('OK: dokument skapat, kredit förbrukad (3 → 2)');

// 4. PDF-nedladdning är en riktig PDF.
const pdfOk = await page.evaluate(async () => {
  const links = [...document.querySelectorAll('a')].filter((a) => a.href.includes('/download?format=pdf'));
  const res = await fetch(links[0].href, { credentials: 'include' });
  const buf = new Uint8Array(await res.arrayBuffer());
  return res.headers.get('content-type')?.includes('application/pdf') && buf[0] === 0x25 && buf[1] === 0x50 && buf[2] === 0x44 && buf[3] === 0x46;
});
if (!pdfOk) throw new Error('PDF-nedladdningen är inte en riktig PDF');
console.log('OK: PDF-nedladdning verifierad (%PDF-magic + content-type)');

// 5. Kvittot för dokumentpaketet under Mina köp.
await page.click('nav >> text=Konto & data');
await page.waitForSelector('text=Mina köp');
const account = await page.innerText('body');
if (!account.includes('Dokumentförberedelse')) throw new Error('dokumentköpet saknas i Mina köp');
if (!account.includes('49 kr')) throw new Error('paketbeloppet saknas');
await page.screenshot({ path: `${SHOT}/29-mina-kop-dokument.png`, fullPage: true });
console.log('OK: kvitto för dokumentpaketet i Mina köp');

await browser.close();
console.log('DOCUMENT STUDIO UI VERIFIED');
