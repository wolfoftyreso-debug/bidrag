/**
 * GATE 0 — extern länkhälsa (myndighetslänkarna).
 * Kan INTE köras i agent-sandlådan (utgående HTTP blockeras) — körs från en
 * nätansluten maskin, t.ex. direkt efter deploy tillsammans med
 * tools/deploy-smoke.mjs:
 *
 *   npm run seo:build && node tools/linkhealth.mjs
 *
 * Läser alla externa länkar ur artifacts/seo-site, gör HEAD (GET vid 405)
 * med paus mellan anrop (artighet mot myndighetsservrar), och failar på
 * 404/410/DNS-fel. 3xx rapporteras som varning (uppdatera källänken).
 */
import { readdirSync, readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = join(ROOT, 'artifacts', 'seo-site');
const links = new Map();
(function walk(dir) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name.endsWith('.html')) {
      const rel = p.slice(SITE.length);
      for (const m of readFileSync(p, 'utf8').matchAll(/href="(https?:\/\/[^"]+)"/g)) {
        if (m[1].startsWith('https://bidragskoll.se')) continue;
        if (m[1].startsWith('https://fonts.g')) continue;
        if (!links.has(m[1])) links.set(m[1], []);
        links.get(m[1]).push(rel);
      }
    }
  }
})(SITE);

console.log(`Kontrollerar ${links.size} unika externa länkar…`);
let broken = 0, redirects = 0;
for (const [url, pages] of [...links.entries()].sort()) {
  let status = null, err = null;
  try {
    let res = await fetch(url, { method: 'HEAD', redirect: 'manual', signal: AbortSignal.timeout(15000) });
    if (res.status === 405 || res.status === 403) res = await fetch(url, { method: 'GET', redirect: 'manual', signal: AbortSignal.timeout(15000) });
    status = res.status;
  } catch (e) { err = e.cause?.code ?? e.name; }
  if (err || status === 404 || status === 410 || status >= 500) {
    broken++;
    console.log(`  BRUTEN ${url} (${err ?? status}) — på ${pages.length} sidor, t.ex. ${pages[0]}`);
  } else if (status >= 300 && status < 400) {
    redirects++;
    console.log(`  redirect ${status}: ${url} — uppdatera käll-URL:en i seeden`);
  }
  await new Promise((r) => setTimeout(r, 300));
}
console.log(`\nKLART: ${links.size} länkar — ${broken} brutna, ${redirects} redirectar, ${links.size - broken - redirects} OK`);
process.exit(broken ? 1 : 0);
