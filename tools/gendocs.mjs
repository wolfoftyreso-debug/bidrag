/**
 * Testar ALLA fyra dokumentmallarna hela vägen: intag med rika fakta →
 * upplåsning → "alla dokument"-paket → förifyllnad verifieras → generering
 * med realistiskt, krävande innehåll (åäö, långa stycken, radbrytningar,
 * överlånga ord, citattecken, tankstreck) → text + PDF laddas ner.
 */
import { artifactsDir } from './lib/browser.mjs';
import { deriveAgeFacts } from '../packages/core/dist/index.js';
const API = 'http://localhost:3100';
const S = artifactsDir;
import { writeFileSync } from 'node:fs';

let cookie = '';
async function call(method, path, body) {
  const res = await fetch(API + path, {
    method,
    headers: { ...(body ? { 'Content-Type': 'application/json' } : {}), cookie },
    body: body ? JSON.stringify(body) : undefined,
  });
  const setC = res.headers.getSetCookie?.() ?? [];
  if (setC.length) cookie = setC.map((c) => c.split(';')[0]).join('; ');
  const text = await res.text();
  let json = null;
  try { json = JSON.parse(text); } catch {}
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status}: ${text.slice(0, 300)}`);
  return json;
}

// 1. Konto + situationsprofil med allt förifyllnaden ska hämta.
const stamp = Date.now();
await call('POST', '/v1/auth/register', {
  email: `dok-${stamp}@test.example`,
  password: 'dokument-test-losenord-1',
  displayName: 'Åsa Öström-Ekelöf',
});
const { profile } = await call('POST', '/v1/profiles', {
  kind: 'person',
  displayName: 'Min situation',
  applicantType: 'individual',
  country: 'SE',
  municipality: 'Härnösand',
  facts: {
    'person.householdType': 'alone',
    'person.hasChildrenAtHome': true,
    ...deriveAgeFacts(45), // EN källa (core/facts.ts, M15) — ålder 45 → band 29-65
    'person.employmentStatus': 'unemployed',
    'person.monthlyIncomeBand': '15-25',
    'person.lowHouseholdIncome': true,
    'person.limitedSavings': true,
    'person.paysHousingCost': true,
    'person.housingCostMonthly': 9250,
    'person.childCostsStrain': true,
  },
});
const { project } = await call('POST', '/v1/projects', {
  profileId: profile.id,
  title: 'Min ekonomiska situation',
  intent: 'Jag har svårt att få ekonomin att gå ihop.',
});
const pid = project.id;
await call('POST', `/v1/projects/${pid}/matches`, {});

// 2. Lås upp analys + köp "alla dokument".
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`, { immediateDeliveryConsent: true });
await call('POST', `/v1/payments/${unlock.paymentId}/mock-confirm`);
const pack = await call('POST', `/v1/projects/${pid}/document-pack`, { pack: 'application', immediateDeliveryConsent: true });
await call('POST', `/v1/payments/${pack.paymentId}/mock-confirm`);

// 3. Förifyllnaden.
const credits = await call('GET', `/v1/projects/${pid}/document-credits`);
console.log('FÖRIFYLLNAD:');
for (const [k, v] of Object.entries(credits.prefill)) console.log(` ${k}:`, JSON.stringify(v));
const pf = credits.prefill;
const assert = (cond, msg) => { if (!cond) { console.log('FEL:', msg); process.exitCode = 1; } };
assert(pf['ansokan-ekonomiskt-stod'].fullName === 'Åsa Öström-Ekelöf', 'fullName saknas');
assert(pf['ansokan-ekonomiskt-stod'].municipality === 'Härnösand', 'municipality saknas');
assert(pf['ansokan-ekonomiskt-stod'].householdAdults === 1, 'householdAdults');
assert(pf['ansokan-ekonomiskt-stod'].hasChildren === true, 'hasChildren');
assert(pf['bilaga-ekonomisk-situation'].costHousing === 9250, 'costHousing');
assert(pf['bilaga-ekonomisk-situation'].savings === false, 'savings-spegling');

// 4. Krävande innehåll per mall — förifyllnad + kompletteringar.
const LONG = 'Efter separationen i våras har hela ansvaret för barnens ekonomi legat på mig. ' +
  'Min a-kassa täcker hyra och mat, men när skolan i september meddelade att klassresan till Åre kostar 1 850 kr per barn ' +
  'fanns det ingenting kvar att ta av. Jag har redan skjutit upp tandläkarbesök och sagt upp vårt streamingabonnemang — ' +
  'det som återstår är sådant som inte går att välja bort: hyran, elen, busskortet och barnens mat.\n\n' +
  'Det här är andra stycket, med hårda radbrytningar, "citattecken", ett tankstreck – och ett långt sammansatt ord: ' +
  'handläggningsdokumentationsreferensnummer-2026-HRN-0042/B. Även é och ü ska återges korrekt.';
const OVERLONG = 'Ansökningsreferens: ' + 'X'.repeat(140) + ' (avsiktligt överlångt utan mellanslag för att testa hårdbrytning).';

const docs = [
  ['ansokan-ekonomiskt-stod', {
    ...pf['ansokan-ekonomiskt-stod'],
    address: 'Kvarnbacksvägen 14 B lgh 1203', postalCity: '871 45 Härnösand', phone: '070-123 45 67',
    childrenCount: 2, childrenAges: '8 och 11 år',
    whatFor: 'Kostnad för klassresa till Åre i maj (1 850 kr per barn, totalt 3 700 kr) samt vinterkläder inför säsongen.',
    whyNeeded: LONG,
  }],
  ['bilaga-ekonomisk-situation', {
    ...pf['bilaga-ekonomisk-situation'],
    incomeBenefits: 14200, incomeOther: 1250,
    costChildren: 2100, costDebts: 1800, costOther: 950,
    situationNote: 'Inkomsten varierar med a-kassans utbetalningsdagar. ' + OVERLONG,
  }],
  ['behovsbeskrivning', {
    ...pf['behovsbeskrivning'],
    whoFor: 'barn', childName: 'Vilgot, 11 år',
    needWhat: 'Glasögon efter synundersökning hos optiker (styrka −2,5), båge och glas enligt kostnadsförslag: 2 450 kr.',
    needWhy: 'Utan glasögon kan Vilgot inte följa undervisningen på tavlan. Skolan har påtalat att han "tappar fokus och hamnar efter" — det är synen, inte viljan.',
    needCost: 2450, needWhen: 'Före terminsstart i januari',
  }],
  ['sarskilda-omstandigheter', {
    ...pf['sarskilda-omstandigheter'],
    circumstance: 'Separation i april 2026 följd av arbetslöshet i juni. Den andra föräldern betalar inte underhåll; ärende hos Försäkringskassan pågår.',
    since: 'April 2026',
    impact: LONG,
    steps: 'Anmäld hos Arbetsförmedlingen sedan juni, söker aktivt arbete, har ansökt om underhållsstöd och bostadsbidrag samt kontaktat hyresvärden om anstånd.',
  }],
];

for (const [key, answers] of docs) {
  const r = await call('POST', `/v1/projects/${pid}/generated-documents`, { templateKey: key, answers });
  const id = r.document.id;
  const pdfRes = await fetch(`${API}/v1/generated-documents/${id}/download?format=pdf`, { headers: { cookie } });
  const txtRes = await fetch(`${API}/v1/generated-documents/${id}/download?format=text`, { headers: { cookie } });
  writeFileSync(`${S}/doc-${key}.pdf`, Buffer.from(await pdfRes.arrayBuffer()));
  writeFileSync(`${S}/doc-${key}.txt`, await txtRes.text());
  console.log(`✓ ${key}: PDF ${(await import('node:fs')).statSync(`${S}/doc-${key}.pdf`).size} B`);
}
console.log('KLART');
