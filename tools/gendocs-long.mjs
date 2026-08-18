/** Flersidigt stresstest: långa stycken → sidbrytning, rubrikkontroll, sidfot "Sida X av Y". */
import { artifactsDir } from './lib/browser.mjs';
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
  const t = await res.text();
  if (!res.ok) throw new Error(`${method} ${path} → ${res.status}: ${t.slice(0, 200)}`);
  return JSON.parse(t);
}

const stamp = Date.now();
await call('POST', '/v1/auth/register', { email: `lang-${stamp}@test.example`, password: 'dokument-test-losenord-2', displayName: 'Per-Ulrik Wennerström-Ljunggren' });
const { profile } = await call('POST', '/v1/profiles', { kind: 'person', displayName: 'S', applicantType: 'individual', country: 'SE', municipality: 'Övertorneå', facts: { 'person.hasChildrenAtHome': true, 'person.householdType': 'alone' } });
const { project } = await call('POST', '/v1/projects', { profileId: profile.id, title: 'Lång', intent: 'test' });
const pid = project.id;
const unlock = await call('POST', `/v1/projects/${pid}/analysis-unlock`);
await call('POST', `/v1/payments/${unlock.paymentId}/mock-confirm`);
const pack = await call('POST', `/v1/projects/${pid}/document-pack`, { pack: 'all' });
await call('POST', `/v1/payments/${pack.paymentId}/mock-confirm`);

const LONG_IMPACT = [
  'Under hösten har situationen förändrats i grunden. Hyresvärden aviserade en höjning på 6,5 procent från januari, samtidigt som elpriset i vårt område legat väsentligt över föregående år. Marginalen som tidigare fanns för oförutsedda utgifter är borta.',
  'Jag har gått igenom varje utgiftspost i hushållet — försäkringar, abonnemang, matkostnader, kläder — och skurit bort allt som går att skära bort utan att det drabbar barnen. Streamingtjänster är uppsagda, semesterplaner är inställda och jag handlar numera uteslutande efter veckans extrapriser.',
  'Min arbetsinkomst varierar kraftigt mellan månaderna eftersom jag arbetar på timmar via bemanning. En bra månad täcker det mesta; en dålig månad tvingar mig att välja mellan att betala elräkningen i tid eller att fylla frysen.',
  'Barnens behov går inte att skjuta på samma sätt. Ett par vinterskor som växts ur, en klassresa som skolan förutsätter att alla följer med på, en tandläkarräkning — sådant kommer alltid, och det kommer utan förvarning.',
  'Jag ligger i dag efter med en månads el och har en avbetalningsplan med tandvården. Inga andra skulder finns, men buffert saknas helt: kontot är i praktiken tomt de sista dagarna varje månad.',
  'Situationen påverkar även barnen socialt. Min äldsta har slutat fråga om att följa med på aktiviteter som kostar pengar, och det är precis den utvecklingen jag försöker bryta genom att söka det här stödet.',
  'Jag vill understryka att behovet är tillfälligt. Bemanningsföretaget har utlovat fler pass från februari, och jag har en anställningsintervju inbokad för en tillsvidaretjänst. Det som behövs är en bro över vintern.',
  'Med ett tillfälligt stöd klarar hushållet de fasta kostnaderna utan att dra på sig nya skulder, och barnen kan behålla den vardag de behöver. Utan stödet riskerar vi att hamna i en skuldspiral som blir betydligt dyrare att ta sig ur — för både oss och samhället.',
].join('\n\n');

const r = await call('POST', `/v1/projects/${pid}/generated-documents`, {
  templateKey: 'sarskilda-omstandigheter',
  answers: {
    fullName: 'Per-Ulrik Wennerström-Ljunggren',
    circumstance: 'Kraftigt ökade boendekostnader i kombination med varierande arbetsinkomst under hösten 2026. Beloppen nedan: hyra 11250 kr, el 1875 kr, totalt 13125 kr per månad.',
    since: 'September 2026',
    impact: LONG_IMPACT,
    steps: 'Kontaktat hyresvärd, bytt elavtal, anmält mig till extrapass via bemanningsföretag samt sökt bostadsbidrag.',
  },
});
const id = r.document.id;
const pdf = await fetch(`${API}/v1/generated-documents/${id}/download?format=pdf`, { headers: { cookie } });
writeFileSync(`${S}/doc-lang.pdf`, Buffer.from(await pdf.arrayBuffer()));
console.log('KLART doc-lang.pdf');
