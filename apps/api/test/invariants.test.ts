/**
 * Architectural invariants (reviewer requirement): the application-case state
 * column may only be written by the domain service — never by routes, jobs or
 * integrations directly. Same class of guarantee as tenant isolation.
 */
import { readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { pool } from '../src/db/client.ts';
import { runMigrations } from '../src/db/migrate.ts';

beforeAll(async () => {
  await runMigrations();
});
afterAll(async () => {
  await pool.end();
});

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

  /**
   * Supabase-invariant: PostgREST exponerar public-schemat för innehavare av
   * anon-nyckeln. Varje tabell MÅSTE ha RLS aktiverat (deny-all utan
   * policies) — en ny tabell utan RLS är ett öppet API mot dess data.
   */
  it('every public table has row level security enabled', async () => {
    const { rows } = await pool.query<{ relname: string }>(
      `select c.relname
         from pg_class c
         join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity
        order by c.relname`,
    );
    expect(
      rows.map((r) => r.relname),
      'tabeller utan RLS — lägg till ENABLE ROW LEVEL SECURITY i tabellens migration',
    ).toEqual([]);
  });
});
