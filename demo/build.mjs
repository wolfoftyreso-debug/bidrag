/**
 * Bygger demon till en enda fristående HTML-fil.
 *
 *   node demo/build.mjs            → artifacts/demo/demo.html
 *
 * Demon kör produktens VERKLIGA matchningsmotor (@bidrag/core) och den
 * exporterade kunskapsbasen helt i webbläsaren — inget skickas någonstans.
 * Kräver att core är byggt (npm run build -w packages/core) och att
 * kunskapsbasen är exporterad; båda görs automatiskt här.
 */
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { artifactsDir, repoRoot } from '../tools/lib/browser.mjs';

const out = `${artifactsDir}/demo`;
mkdirSync(out, { recursive: true });
const run = (cmd, args, cwd = repoRoot) =>
  execFileSync(cmd, args, { cwd, stdio: 'inherit', env: { ...process.env, NODE_PATH: `${repoRoot}/node_modules` } });

// 1. Domänmotorn måste vara byggd — demon importerar den kompilerade koden.
if (!existsSync(`${repoRoot}/packages/core/dist/index.js`)) {
  console.log('→ bygger @bidrag/core');
  run('npm', ['run', 'build', '-w', 'packages/core']);
}

// 2. Kunskapsbasen exporteras ur seed-datan (kräver ingen databas).
const data = `${repoRoot}/demo/demo-opportunities.json`;
console.log('→ exporterar kunskapsbasen');
run('node', ['--experimental-strip-types', 'src/seed/export-demo.ts', data], `${repoRoot}/apps/api`);

// 3. Bundla demon (React + core + data) till en IIFE.
console.log('→ bundlar demon');
const bundle = `${out}/bundle.js`;
run(`${repoRoot}/node_modules/.bin/esbuild`, [
  `${repoRoot}/demo/main.tsx`,
  '--bundle', '--minify', '--format=iife', '--jsx=automatic', '--loader:.json=json',
  `--alias:@bidrag/core=${repoRoot}/packages/core/dist/index.js`,
  '--define:process.env.NODE_ENV="production"',
  `--outfile=${bundle}`,
]);

// 4. Inline:a allt i en fil — CSS, JS och data i samma dokument.
const css = readFileSync(new URL('./demo.css', import.meta.url), 'utf8');
const js = readFileSync(bundle, 'utf8');
const html = `<title>Bidragskoll.se Demo</title>
<style>${css}</style>
<div id="root"></div>
<script>${js.replace(/<\/script>/gi, '<\\/script>')}</script>
`;
const target = `${out}/demo.html`;
mkdirSync(dirname(target), { recursive: true });
writeFileSync(target, html);
console.log(`\nKLART: ${target} (${(html.length / 1024).toFixed(0)} kB)`);
