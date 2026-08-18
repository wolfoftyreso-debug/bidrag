/**
 * Återställningskoder i webbläsare: skapa konto → Konto & data → generera
 * koder (visas en gång) → logga ut → "Glömt lösenord?" → "Har du en
 * återställningskod?" → byt lösenord med kod → logga in med nya lösenordet.
 * Verifierar också att en förbrukad kod avvisas i UI:t.
 */
import { launchChromium, artifactsDir } from '../lib/browser.mjs';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();
const email = `kod-${stamp}@test.example`;

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1280, height: 950 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

// 1. Konto
await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Kodhållaren');
await page.fill('#email', email);
await page.fill('#password', 'ursprungligt-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');

// 2. Konto & data → generera koder
await page.goto(`${BASE}/konto`);
await page.waitForSelector('text=Återställningskoder');
await page.click('text=Skapa återställningskoder');
await page.waitForSelector('text=Spara koderna nu');
const codesText = await page.locator('.alert.warning pre').innerText();
const codes = codesText.trim().split('\n');
if (codes.length !== 8 || !/^[A-Z2-9]{5}-[A-Z2-9]{5}-[A-Z2-9]{5}$/.test(codes[0])) {
  console.log('FEL: oväntat kodformat', codes);
  process.exit(1);
}
await page.screenshot({ path: `${SHOT}/shot-koder-1-genererade.png` });
console.log('1. 8 koder genererade och visade en gång ✓');

// 3. Logga ut → glömt lösenord → kodvägen
await page.evaluate(async () => { await fetch('/v1/auth/logout', { method: 'POST', credentials: 'include' }); });
await page.goto(BASE);
await page.waitForSelector('text=Glömt lösenord?');
await page.click('text=Glömt lösenord?');
await page.waitForSelector('text=Har du en återställningskod?');
await page.click('text=Har du en återställningskod?');
await page.waitForSelector('#recovery-code');
await page.fill('#email', email);
// Normaliseringen ska tåla gemener + mellanslag i stället för bindestreck.
await page.fill('#recovery-code', codes[0].toLowerCase().replaceAll('-', ' '));
await page.fill('#password', 'nytt-kodvalt-losenord-456');
await page.screenshot({ path: `${SHOT}/shot-koder-2-formular.png` });
await page.click('button[type=submit]');
await page.waitForSelector('text=Lösenordet är bytt');
console.log('2. Lösenord bytt med återställningskod (normaliserad inmatning) ✓');

// 4. Förbrukad kod avvisas
await page.click('text=Glömt lösenord?');
await page.click('text=Har du en återställningskod?');
await page.fill('#email', email);
await page.fill('#recovery-code', codes[0]);
await page.fill('#password', 'tredje-losenordet-789000');
await page.click('button[type=submit]');
await page.waitForSelector('text=ogiltig/förbrukad');
console.log('3. Förbrukad kod avvisas med ärligt felmeddelande ✓');

// 5. Nya lösenordet fungerar; gamla gör det inte
await page.click('text=Skicka länk via e-post i stället');
await page.click('text=Har du redan konto? Logga in');
await page.fill('#email', email);
await page.fill('#password', 'ursprungligt-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Fel e-post eller lösenord');
await page.fill('#password', 'nytt-kodvalt-losenord-456');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
console.log('4. Gamla lösenordet dött, nya fungerar ✓');

// 6. Kontosidan visar förbrukningen
await page.goto(`${BASE}/konto`);
await page.waitForSelector('text=7 av 8');
await page.screenshot({ path: `${SHOT}/shot-koder-3-status.png` });
console.log('5. Konto & data visar 7 av 8 koder kvar ✓');

await browser.close();
console.log('UICHECK8 KLAR — hela kodvägen fungerar i webbläsaren.');
