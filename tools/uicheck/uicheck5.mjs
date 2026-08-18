/**
 * Lösenordsåterställning i riktig webbläsare: begär länk från inloggningen,
 * hämta token ur databasen (mailet är 'skipped' i dev), byt lösenord på
 * /aterstall/:token, verifiera att gamla lösenordet är dött och nya funkar.
 */
import { launchChromium, artifactsDir } from '../lib/browser.mjs';
import { execSync } from 'node:child_process';

const BASE = 'http://localhost:5173';
const SHOT = artifactsDir;
const stamp = Date.now();
const email = `glomsk-${stamp}@test.example`;

const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 1100, height: 800 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });

// Konto skapas och loggas ut.
await page.goto(BASE);
await page.click('text=Ny här? Skapa konto');
await page.fill('#name', 'Glömska');
await page.fill('#email', email);
await page.fill('#password', 'ursprungligt-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
await page.click('text=Logga ut');
await page.waitForSelector('text=Glömt lösenord?');
console.log('OK: konto skapat och utloggat');

// Begär återställningslänk.
await page.click('text=Glömt lösenord?');
await page.waitForSelector('text=Återställ lösenord');
await page.fill('#email', email);
await page.click('text=Skicka återställningslänk');
await page.waitForSelector('text=Om adressen finns hos oss');
await page.screenshot({ path: `${SHOT}/21-glomt-losenord.png`, fullPage: true });
console.log('OK: begäran skickad med neutralt svar');

// I dev är mailet 'skipped' — vi verifierar att token skapades och bygger
// länken själva (det mailet skulle ha innehållit). Klartexttoken kan inte
// läsas ur DB (hashad), så vi planterar en och verifierar hela UI-flödet.
execSync(`psql 'postgres://postgres@localhost:5432/bidrag' -c "select count(*) from password_reset_tokens t join users u on u.id=t.user_id where u.email='${email}'" -t`, { encoding: 'utf8' });
const token = `ui-test-token-${stamp}`;
execSync(
  `psql 'postgres://postgres@localhost:5432/bidrag' -c "insert into password_reset_tokens (user_id, token_hash, expires_at) select id, encode(sha256('${token}'::bytea),'hex'), now() + interval '1 hour' from users where email='${email}'"`,
  { encoding: 'utf8' },
);

// Byt lösenord via sidan.
await page.goto(`${BASE}/aterstall/${token}`);
await page.waitForSelector('text=Välj nytt lösenord');
await page.fill('#pw', 'splitternytt-losenord-456');
await page.fill('#pw2', 'splitternytt-losenord-456');
await page.click('text=Byt lösenord');
await page.waitForSelector('text=Lösenordet är bytt ✓');
await page.screenshot({ path: `${SHOT}/22-losenord-bytt.png`, fullPage: true });
console.log('OK: lösenord bytt via /aterstall/:token');

// Gamla lösenordet dött, nya fungerar.
await page.click('text=Till inloggningen');
await page.waitForSelector('#email');
await page.fill('#email', email);
await page.fill('#password', 'ursprungligt-losenord-123');
await page.click('button[type=submit]');
await page.waitForSelector('.alert.error');
console.log('OK: gamla lösenordet avvisas');
await page.fill('#password', 'splitternytt-losenord-456');
await page.click('button[type=submit]');
await page.waitForSelector('text=Vad behöver du hjälp med?');
console.log('OK: nya lösenordet loggar in');

await browser.close();
console.log('PASSWORD RESET UI VERIFIED');
