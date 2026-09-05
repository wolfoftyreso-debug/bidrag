/**
 * Belastningstest utan beroenden — två lägen:
 *
 *   KAPACITET (som tidigare): N samtidiga arbetare på full fart.
 *     node scripts/loadtest.mjs [baseUrl] [seconds] [concurrency]
 *
 *   MODELLENS TOPPTIMME (LAUNCH_DEMAND_INTELLIGENCE §8): trafik i en fast
 *   takt (RPS) med en mix som speglar tratten — genomgång (matchning),
 *   stödsida, händelser, listor — och scenarierna hämtas ur modellens
 *   senaste körning (artifacts/demand-model.json, `npm run demand:model`).
 *     node scripts/loadtest.mjs --model [baseUrl]            # alla scenarier + spik ×5
 *     node scripts/loadtest.mjs --rps 12.8 [baseUrl] [seconds]
 *   Resultat skrivs till artifacts/loadtest.json (för rapporten).
 *
 * OBS (revision 2026-09-01): all trafik kommer från EN IP, så API:ts per-IP-
 * rate-limit (RATE_LIMIT_MAX, default 300/min) slår till efter några sekunder
 * och nästan allt får 429 — då mäter du vakten, inte kapaciteten. Starta API:t
 * med t.ex. RATE_LIMIT_MAX=1000000. 429 räknas som fel med flit: mot en riktig
 * deploy är 429 ett verkligt fel för användaren.
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';

const args = process.argv.slice(2);
const flag = (name) => { const i = args.indexOf(name); return i > -1 ? args[i + 1] : undefined; };
const MODEL = args.includes('--model');
const RPS = flag('--rps') ? Number(flag('--rps')) : null;
const positional = args.filter((a, i) => !a.startsWith('--') && args[i - 1] !== '--rps');
const BASE = positional[0] ?? 'http://localhost:3100';
const SECONDS = Number(positional[1] ?? (MODEL || RPS ? 30 : 20));
const CONCURRENCY = Number(positional[2] ?? 25);

// ── Förberedelse: ett konto, en profil, ett projekt, ett stöd att läsa ──────
const email = `load-${Date.now()}@test.example`;
const reg = await fetch(`${BASE}/v1/auth/register`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password: 'load-test-losenord-123', displayName: 'Lasttest' }),
});
if (reg.status !== 201) throw new Error(`register failed: ${reg.status}`);
const cookie = reg.headers.getSetCookie().map((c) => c.split(';')[0]).join('; ');
const json = (method, path, body) => fetch(`${BASE}${path}`, { method, headers: { 'Content-Type': 'application/json', cookie }, body: body ? JSON.stringify(body) : undefined });

const { profile } = await (await json('POST', '/v1/profiles', { kind: 'person', displayName: 'Last', applicantType: 'individual', country: 'SE', facts: { 'person.professionalArtist': true } })).json();
const { project } = await (await json('POST', '/v1/projects', { profileId: profile.id, title: 'Lasttestprojekt', intent: 'test', facts: { 'project.sector': 'culture', 'project.hasInternationalComponent': true } })).json();
const list = await (await json('GET', '/v1/funding-opportunities?openOnly=true')).json();
const slugs = (list.items ?? list.opportunities ?? list ?? []).map((o) => o.slug).filter(Boolean);
const slug = slugs[0] ?? 'fk-barnbidrag';

// Trafikmixen. Vikterna speglar tratten i LAUNCH_DEMAND_INTELLIGENCE §2: per
// genomgång läses flera stödsidor och listor, och varje steg loggar en händelse.
const paths = [
  { name: 'POST /v1/projects/:id/matches  (genomgång)', weight: 2, run: () => json('POST', `/v1/projects/${project.id}/matches`, {}) },
  { name: 'GET  /v1/funding-opportunities/:slug (stödsida)', weight: 3, run: () => json('GET', `/v1/funding-opportunities/${slugs[Math.floor(Math.random() * slugs.length)] ?? slug}`) },
  { name: 'GET  /v1/funding-opportunities (lista)', weight: 2, run: () => json('GET', '/v1/funding-opportunities?openOnly=true') },
  { name: 'POST /v1/events (instrumentering)', weight: 2, run: () => json('POST', '/v1/events', { name: 'nasta_steg_visad', props: { antal: 3 } }) },
  { name: 'GET  /v1/applications', weight: 1, run: () => json('GET', '/v1/applications') },
];
const weighted = paths.flatMap((p) => Array(p.weight).fill(p));
const pct = (arr, p) => { const s = [...arr].sort((a, b) => a - b); return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))] ?? 0; };

async function hit(stats, statusCounts) {
  const p = weighted[Math.floor(Math.random() * weighted.length)];
  const s = stats.get(p.name);
  const t0 = performance.now();
  try {
    const res = await p.run();
    await res.arrayBuffer();
    s.count++;
    statusCounts.set(res.status, (statusCounts.get(res.status) ?? 0) + 1);
    if (res.status < 200 || res.status >= 300) s.errors++;
    s.latencies.push(performance.now() - t0);
  } catch {
    s.errors++;
  }
}

function summarize(label, stats, statusCounts, elapsed, targetRps) {
  let total = 0; let errors = 0; const all = [];
  const rows = [];
  for (const [name, s] of stats) {
    total += s.count; errors += s.errors; all.push(...s.latencies);
    rows.push({ name, n: s.count, p50: Math.round(pct(s.latencies, 50)), p95: Math.round(pct(s.latencies, 95)), p99: Math.round(pct(s.latencies, 99)), errors: s.errors });
    console.log(`  ${name.padEnd(48)} n=${String(s.count).padStart(5)}  p50=${Math.round(pct(s.latencies, 50))}ms  p95=${Math.round(pct(s.latencies, 95))}ms  p99=${Math.round(pct(s.latencies, 99))}ms  fel=${s.errors}`);
  }
  const rps = total / elapsed;
  const errRate = total ? errors / total : 1;
  console.log(`  status: ${JSON.stringify(Object.fromEntries([...statusCounts.entries()].sort()))}`);
  console.log(`  TOTALT ${total} anrop på ${elapsed.toFixed(1)} s = ${rps.toFixed(1)} req/s${targetRps ? ` (mål ${targetRps})` : ''} · p95 ${Math.round(pct(all, 95))} ms · fel ${(errRate * 100).toFixed(2)} %`);
  return { label, targetRps, achievedRps: Number(rps.toFixed(2)), total, errors, errorRate: Number(errRate.toFixed(4)), p50: Math.round(pct(all, 50)), p95: Math.round(pct(all, 95)), p99: Math.round(pct(all, 99)), rows, status: Object.fromEntries([...statusCounts.entries()].sort()) };
}

/** Fast takt: en timer skjuter anrop i jämn takt (öppen loop — köer syns som latens, inte som färre anrop). */
async function runAtRps(label, targetRps, seconds) {
  console.log(`\n■ ${label}: ${targetRps} req/s i ${seconds} s mot ${BASE}`);
  const stats = new Map(paths.map((p) => [p.name, { count: 0, errors: 0, latencies: [] }]));
  const statusCounts = new Map();
  const inflight = new Set();
  const t0 = Date.now();
  const intervalMs = 1000 / targetRps;
  let next = t0;
  while (Date.now() - t0 < seconds * 1000) {
    const now = Date.now();
    if (now >= next) {
      const p = hit(stats, statusCounts).finally(() => inflight.delete(p));
      inflight.add(p);
      next += intervalMs;
    } else {
      await new Promise((r) => setTimeout(r, Math.min(next - now, 50)));
    }
  }
  await Promise.all(inflight);
  return summarize(label, stats, statusCounts, (Date.now() - t0) / 1000, targetRps);
}

/** Kapacitet: N arbetare på full fart. */
async function runCapacity(seconds, concurrency) {
  console.log(`\n■ Kapacitet: ${concurrency} samtidiga arbetare i ${seconds} s mot ${BASE}`);
  const stats = new Map(paths.map((p) => [p.name, { count: 0, errors: 0, latencies: [] }]));
  const statusCounts = new Map();
  const deadline = Date.now() + seconds * 1000;
  const t0 = Date.now();
  await Promise.all(Array.from({ length: concurrency }, async () => { while (Date.now() < deadline) await hit(stats, statusCounts); }));
  return summarize('kapacitet', stats, statusCounts, (Date.now() - t0) / 1000, null);
}

// Uppvärmning: JIT, pool och cache — annars mäter första scenariot kallstarten,
// som på Vercel är en egen fråga (per instans), inte modellens topptimme.
for (const p of paths) for (let i = 0; i < 3; i++) await p.run().then((r) => r.arrayBuffer()).catch(() => {});

const results = [];
if (MODEL) {
  const modelPath = new URL('../artifacts/demand-model.json', import.meta.url);
  if (!existsSync(modelPath)) throw new Error('artifacts/demand-model.json saknas — kör npm run demand:model först');
  const model = JSON.parse(readFileSync(modelPath, 'utf8'));
  for (const sc of model.scenarier) {
    const rps = sc.teknisk_last.topptimme_api_rps;
    results.push(await runAtRps(`${sc.sessioner_per_manad.toLocaleString('sv-SE')} sessioner/mån — topptimme`, Math.max(rps, 0.5), SECONDS));
  }
  const top = model.scenarier.at(-1).teknisk_last.topptimme_api_rps;
  results.push(await runAtRps(`spik ×5 på största scenariot`, Number((top * 5).toFixed(1)), SECONDS));
  results.push(await runCapacity(20, CONCURRENCY));
} else if (RPS) {
  results.push(await runAtRps(`${RPS} req/s`, RPS, SECONDS));
} else {
  results.push(await runCapacity(SECONDS, CONCURRENCY));
}

mkdirSync(new URL('../artifacts/', import.meta.url), { recursive: true });
writeFileSync(new URL('../artifacts/loadtest.json', import.meta.url), JSON.stringify({ base: BASE, ranAt: new Date().toISOString(), results }, null, 2));
for (const r of results) if (r.p95 > 2000) console.log(`VARNING: ${r.label}: p95 ${r.p95} ms över 2 s — en enskild process är mättad; i serverless-driften är svaret scale-out (Vercel-tak DATA_UNAVAILABLE i modellen).`);
const worst = Math.max(...results.map((r) => r.errorRate));
if (worst > 0.01) { console.error(`\nFAIL: felandel ${(worst * 100).toFixed(2)} % > 1 %`); process.exit(1); }
console.log('\nLOAD TEST PASSED (felandel < 1 % i alla körningar) → artifacts/loadtest.json');
