/**
 * Deterministic migration runner — applies committed SQL migrations from
 * ./drizzle in order. Used by CI, the container entrypoint and tests.
 */
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { db, pool } from './client.ts';

const here = path.dirname(fileURLToPath(import.meta.url));

export async function runMigrations(): Promise<void> {
  await migrate(db, { migrationsFolder: path.resolve(here, '../../drizzle') });
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runMigrations()
    .then(async () => {
      console.log('Migrations applied.');
      await pool.end();
    })
    .catch(async (err) => {
      console.error('Migration failed:', err);
      await pool.end();
      process.exit(1);
    });
}
