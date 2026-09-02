/**
 * Hand-rolled load test (no dependencies): logs in once, then drives
 * concurrent traffic against the hot read paths and one write path.
 * Usage: node scripts/loadtest.mjs [baseUrl] [seconds] [concurrency]
 *
 * OBS (revision 2026-09-01): all trafik kommer från EN IP, så API:ts per-IP-
 * rate-limit (RATE_LIMIT_MAX, default 300/min) slår till efter några sekunder
 * och nästan allt får 429 — då mäter du vakten, inte kapaciteten. Starta API:t
 * med t.ex. RATE_LIMIT_MAX=1000000 för ett kapacitetstal. 429 räknas som fel
 * med flit: mot en riktig deploy är 429 ett verkligt fel för användaren.
 */
const BASE = process.argv[2] ?? 'http://localhost:3100';
const SECONDS = Number(process.argv[3] ?? 20);
const CONCURRENCY = Number(process.argv[4] ?? 25);

const email = `load-${Date.now()}@test.example`;
const reg = await fetch(`${BASE}/v1/auth/register`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ email, password: 'load-test-losenord-123', displayName: 'Lasttest' }),
});
if (reg.status !== 201) throw new Error(`register failed: ${reg.status}`);
const cookie = reg.headers.getSetCookie().map((c) => c.split(';')[0]).join('; ');

const profileRes = await fetch(`${BASE}/v1/profiles`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', cookie },
  body: JSON.stringify({ kind: 'person', displayName: 'Last', applicantType: 'individual', country: 'SE', facts: { 'person.professionalArtist': true } }),
});
const { profile } = await profileRes.json();
const projectRes = await fetch(`${BASE}/v1/projects`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', cookie },
  body: JSON.stringify({ profileId: profile.id, title: 'Lasttestprojekt', intent: 'test', facts: { 'project.sector': 'culture', 'project.hasInternationalComponent': true } }),
});
const { project } = await projectRes.json();

const paths = [
  { name: 'GET  /v1/funding-opportunities', weight: 4, run: () => fetch(`${BASE}/v1/funding-opportunities?openOnly=true`, { headers: { cookie } }) },
  { name: 'GET  /v1/applications', weight: 2, run: () => fetch(`${BASE}/v1/applications`, { headers: { cookie } }) },
  { name: 'GET  /v1/notifications', weight: 2, run: () => fetch(`${BASE}/v1/notifications`, { headers: { cookie } }) },
  { name: 'POST /v1/projects/:id/matches', weight: 1, run: () => fetch(`${BASE}/v1/projects/${project.id}/matches`, { method: 'POST', headers: { 'Content-Type': 'application/json', cookie }, body: '{}' }) },
];
const weighted = paths.flatMap((p) => Array(p.weight).fill(p));

const stats = new Map(paths.map((p) => [p.name, { count: 0, errors: 0, latencies: [] }]));
const statusCounts = new Map();
const deadline = Date.now() + SECONDS * 1000;
let inFlightErrors = 0;

async function worker() {
  while (Date.now() < deadline) {
    const p = weighted[Math.floor(Math.random() * weighted.length)];
    const s = stats.get(p.name);
    const t0 = performance.now();
    try {
      const res = await p.run();
      await res.arrayBuffer();
      s.count++;
      statusCounts.set(res.status, (statusCounts.get(res.status) ?? 0) + 1);
      // Anything but 2xx is a failure for the load test — 429s must be
      // visible, never silently counted as throughput.
      if (res.status < 200 || res.status >= 300) s.errors++;
      s.latencies.push(performance.now() - t0);
    } catch {
      s.errors++;
      inFlightErrors++;
    }
  }
}

console.log(`Load test: ${CONCURRENCY} concurrent workers for ${SECONDS}s against ${BASE}`);
const t0 = Date.now();
await Promise.all(Array.from({ length: CONCURRENCY }, worker));
const elapsed = (Date.now() - t0) / 1000;

function pct(arr, p) {
  const sorted = [...arr].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.floor((p / 100) * sorted.length))] ?? 0;
}

let total = 0;
let totalErrors = 0;
for (const [name, s] of stats) {
  total += s.count;
  totalErrors += s.errors;
  console.log(
    `${name}  n=${s.count}  p50=${pct(s.latencies, 50).toFixed(0)}ms  p95=${pct(s.latencies, 95).toFixed(0)}ms  p99=${pct(s.latencies, 99).toFixed(0)}ms  5xx/err=${s.errors}`,
  );
}
console.log('Status distribution:', Object.fromEntries([...statusCounts.entries()].sort()));
console.log(`TOTAL: ${total} requests in ${elapsed.toFixed(1)}s = ${(total / elapsed).toFixed(0)} req/s, non-2xx/errors: ${totalErrors + inFlightErrors}`);
if (totalErrors + inFlightErrors > total * 0.01) {
  console.error('FAIL: error rate above 1%');
  process.exit(1);
}
console.log('LOAD TEST PASSED (error rate < 1%)');
