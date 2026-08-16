/**
 * Deterministic migration runner — applies committed SQL migrations from
 * ./drizzle in order. Used by CI, the container entrypoint, tests and the
 * deploy step (npm run db:migrate).
 *
 * Med Supabase: sätt DIRECT_DATABASE_URL (port 5432). Migreringar ska aldrig
 * gå via transaktionspoolern (6543) — DDL och pgbouncer i transaction mode är
 * en känd felkälla. Utan DIRECT_DATABASE_URL används den vanliga anslutningen
 * (lokal utveckling, CI, container).
 */
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { drizzle } from 'drizzle-orm/node-postgres';
import pg from 'pg';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { db, pool } from './client.ts';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrationsFolder = path.resolve(here, '../../drizzle');

export async function runMigrations(): Promise<void> {
  const directUrl = process.env.DIRECT_DATABASE_URL;
  if (directUrl) {
    const directPool = new pg.Pool({ connectionString: directUrl, max: 1 });
    try {
      await migrate(drizzle(directPool), { migrationsFolder });
    } finally {
      await directPool.end();
    }
    return;
  }
  await migrate(db, { migrationsFolder });
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
