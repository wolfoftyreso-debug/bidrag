import { launchChromium, artifactsDir } from '../lib/browser.mjs';
import { execSync } from 'node:child_process';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const email = `curator-${Date.now()}@test.example`;

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
page.on('pageerror', (e) => console.log('PAGEERROR:', e.message));

// Registrera + höj till kurator via DB
await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Kuratorn');
await page.fill('#email', email);
await page.fill('#password', 'kurator-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?', { timeout: 10000 });
execSync(`psql -U postgres -h /tmp -d bidrag -c "UPDATE memberships SET role='data_curator' WHERE user_id=(SELECT id FROM users WHERE email='${email}')"`);
await page.reload();

// Adminkonsol → regeleditor
await page.click('nav >> text=Administration');
await page.waitForSelector('text=Källhälsa');
await page.waitForSelector('text=Stöd efter granskningsbehov');
const editLinks = page.locator('text=Redigera regler');
await editLinks.first().click();
await page.waitForSelector('text=Så läser systemet reglerna', { timeout: 10000 });
await page.screenshot({ path: `${SHOT}/7-regeleditor.png`, fullPage: true });
console.log('OK: regeleditor renderar med klartextförhandsvisning');

// Publicera med trasig JSON → klientfel; laga → publicera
const criteriaBox = page.locator('textarea').first();
await criteriaBox.fill('[{"id":"x","kind":"magic","factPath":"bad path","op":"nope","description":""}]');
await page.fill('input[placeholder*="medfinansieringskrav"]', 'Teständring från regeleditorn');
await page.click('text=Publicera ny regelversion');
await page.waitForSelector('text=Servern vägrade publicera', { timeout: 10000 });
console.log('OK: servern avvisar trasiga regler med fältfel');

await criteriaBox.fill(JSON.stringify([
  { id: 'h1', kind: 'hard', factPath: 'applicant.country', op: 'eq', expected: 'SE', description: 'Sökande ska vara verksam i Sverige' },
  { id: 'm1', kind: 'mandatory', factPath: 'person.professionalArtist', op: 'is_true', description: 'Yrkesverksam', intakeQuestion: 'Är du yrkesverksam?' },
], null, 2));
await page.click('text=Publicera ny regelversion');
await page.waitForSelector('text=Ny regelversion publicerad', { timeout: 10000 });
console.log('OK: giltig regelversion publicerad → ommatchning triggad');

// Kontosidan
await page.click('nav >> text=Konto & data');
await page.waitForSelector('text=Hämta ut din data');
await page.waitForSelector('text=Radera kontot permanent');
await page.screenshot({ path: `${SHOT}/8-konto.png`, fullPage: true });
console.log('OK: kontosida med export och radering');

await browser.close();
console.log('ALL UI2 CHECKS PASSED');
