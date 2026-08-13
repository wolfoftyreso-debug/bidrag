import pg from 'pg';
import { drizzle } from 'drizzle-orm/node-postgres';
import { config } from '../config.ts';
import * as schema from './schema.ts';

export const pool = new pg.Pool({
  connectionString: config.databaseUrl,
  max: Number(process.env.PG_POOL_MAX ?? 10),
});

// A database blip must degrade the service (5xx per request, 503 on /readyz),
// never kill the process: idle clients emit 'error' when the server drops the
// connection, and an unhandled 'error' event crashes Node. Found by failure
// injection — do not remove.
pool.on('error', (err) => {
  console.error('pg pool idle-client error (service degraded, not crashed):', err.message);
});

export const db = drizzle(pool, { schema });
export type Db = typeof db;
export { schema };
