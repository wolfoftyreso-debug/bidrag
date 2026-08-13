/**
 * Architectural invariants (reviewer requirement): the application-case state
 * column may only be written by the domain service — never by routes, jobs or
 * integrations directly. Same class of guarantee as tenant isolation.
 */
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

const SRC = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../src');

async function allSourceFiles(dir: string): Promise<string[]> {
  const out: string[] = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...(await allSourceFiles(full)));
    else if (entry.name.endsWith('.ts')) out.push(full);
  }
  return out;
}

describe('domain invariants', () => {
  it('only services/applications.ts updates applicationCases state', async () => {
    const offenders: string[] = [];
    for (const file of await allSourceFiles(SRC)) {
      const rel = path.relative(SRC, file);
      if (rel === path.join('services', 'applications.ts')) continue;
      const content = await readFile(file, 'utf8');
      // A state write on the cases table looks like `.update(applicationCases)` followed
      // by a set(...) containing `state:` in the same statement.
      const updates = content.match(/\.update\(applicationCases\)[\s\S]{0,200}?\.set\(\{[\s\S]*?\}\)/g) ?? [];
      if (updates.some((u) => /\bstate\s*:/.test(u))) offenders.push(rel);
    }
    expect(offenders).toEqual([]);
  });

  it('no source file references redis — pg-boss on Postgres is the only queue', async () => {
    for (const file of await allSourceFiles(SRC)) {
      const content = await readFile(file, 'utf8');
      expect(content.toLowerCase().includes('redis'), path.relative(SRC, file)).toBe(false);
    }
  });
});
