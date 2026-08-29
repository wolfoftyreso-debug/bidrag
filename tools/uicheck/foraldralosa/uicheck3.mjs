import { launchChromium, artifactsDir } from '../../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();

const browser = await launchChromium();

async function register(page, name, email) {
  await page.goto(BASE);
  await page.click('text=Ny här? Skapa konto');
  await page.fill('#name', name);
  await page.fill('#email', email);
  await page.fill('#password', 'team-test-losenord-123');
  await page.click('button[type=submit]');
  await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 10000 });
}

// Ägaren skapar organisation och bjuder in
const ownerPage = await browser.newPage({ viewport: { width: 1280, height: 900 } });
ownerPage.on('pageerror', (e) => console.log('PAGEERROR:', e.message));
await register(ownerPage, 'Ordföranden', `ordf-${stamp}@test.example`);
await ownerPage.click('nav >> text=Konto & data');
await ownerPage.waitForSelector('text=Skapa organisation');
await ownerPage.fill('input[placeholder*="Kulturföreningen"]', 'Dansföreningen Riddim');
await ownerPage.click('button:has-text("Skapa")');
await ownerPage.waitForSelector('select[aria-label="Aktiv organisation"]', { timeout: 10000 });
console.log('OK: organisation skapad, tenantväxlare synlig');

await ownerPage.click('nav >> text=Konto & data');
await ownerPage.waitForSelector('text=Bjud in medlem');
await ownerPage.fill('input[name=email]', `kassor-${stamp}@test.example`);
await ownerPage.click('button:has-text("Bjud in")');
await ownerPage.waitForSelector('text=Inbjudan skapad');
const inviteUrl = await ownerPage.locator('.alert.success code').textContent();
console.log('OK: inbjudan skapad med delbar länk');
await ownerPage.screenshot({ path: `${SHOT}/9-organisation.png`, fullPage: true });

// Kollegan registrerar sig och accepterar
const colleaguePage = await browser.newPage({ viewport: { width: 1280, height: 900 } });
colleaguePage.on('pageerror', (e) => console.log('PAGEERROR:', e.message));
await register(colleaguePage, 'Kassören', `kassor-${stamp}@test.example`);
await colleaguePage.goto(inviteUrl.trim());
await colleaguePage.waitForSelector('text=Dansföreningen Riddim');
await colleaguePage.click('text=Acceptera inbjudan');
await colleaguePage.waitForSelector('select[aria-label="Aktiv organisation"]', { timeout: 10000 });
console.log('OK: inbjudan accepterad, kollegan är inne i organisationen');

// Kalendern
await colleaguePage.click('nav >> text=Kalender');
await colleaguePage.waitForSelector('text=Deadlines för dina ansökningar');
await colleaguePage.screenshot({ path: `${SHOT}/10-kalender.png`, fullPage: true });
console.log('OK: kalendersida');

await browser.close();
console.log('ALL UI3 CHECKS PASSED');
