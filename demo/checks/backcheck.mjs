/** Backa-navigering: varje fråga har Tillbaka, teasern och rapporten har "Ändra mina svar". */
import { launchChromium, artifactsDir } from '../../tools/lib/browser.mjs';

const S = artifactsDir;
const browser = await launchChromium();
const page = await browser.newPage({ viewport: { width: 900, height: 900 } });
page.on('pageerror', (e) => { console.log('PAGEERROR:', e.message); process.exitCode = 1; });
await page.goto(`file://${S}/demo/demo.html`);

// 1. Varje frågesteg på vägen har en Tillbaka-knapp.
await page.click('text=svårt att få ekonomin');
const steps = [
  ['button:has-text("Själv")', 'hushåll'],
  ['.choice:has-text("Ja"):not(:has-text("växelvis"))', 'barn'],
  ['button:has-text("Ja")', 'skilda håll'],
  ['text=Ja, i grundskolan', 'skolform'],
];
for (const [sel, name] of steps) {
  if (!(await page.locator('button:has-text("← Tillbaka")').count())) {
    console.log(`FEL: ingen Tillbaka-knapp på frågan (${name})`); process.exit(1);
  }
  await page.click(sel);
  await page.waitForTimeout(80);
}
console.log('1. Tillbaka-knapp på varje frågesteg ✓');

// 2. Backa ändrar faktiskt steg: gå tillbaka från "skilda håll"-läget ett steg och fram igen.
await page.click('button:has-text("← Tillbaka")');
await page.waitForSelector('text=Går något av barnen i skolan?');
await page.click('text=Ja, i grundskolan');
console.log('2. Backa återvänder till föregående fråga med svaren kvar ✓');

// 3. Fram till teasern: "Ändra mina svar" finns och fungerar.
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.click('.row >> button:has-text("Ja")');
await page.click('button:has-text("29–65")');
await page.click('button:has-text("Arbetslös")');
await page.click('button:has-text("15 000–25 000 kr")');
await page.click('.row >> button:has-text("Ja")');
await page.fill('input[type=number]', '8500');
await page.click('text=Nästa');
await page.waitForSelector('text=flytta utomlands');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=stöd som matchar din situation');
await page.click('text=← Ändra mina svar');
await page.waitForSelector('text=allvarlig sjukdom'); // sista frågan är numera funktionsnedsättningsfrågan
console.log('3. Teasern → Ändra mina svar → tillbaka på sista frågan ✓');

// 4. Fram igen, betala, och rapporten har också Ändra mina svar (utan att låsa om).
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');
await page.click('text=Lås upp din bidragsanalys — 39 kr');
await page.click('text=Godkänn betalning (simulerad)');
await page.click('text=Visa min analys');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
await page.click('text=← Ändra mina svar');
await page.waitForSelector('text=allvarlig sjukdom');
await page.click('.row >> button:has-text("Nej")');
await page.waitForSelector('text=Det här ser du ut att kunna ha rätt till');
console.log('4. Rapporten → Ändra mina svar → tillbaka utan ny betalvägg ✓');

await page.screenshot({ path: `${S}/shot-demo-backa.png` });
await browser.close();
console.log('BACKCHECK KLAR');
