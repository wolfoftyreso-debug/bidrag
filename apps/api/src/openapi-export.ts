/** Writes the generated OpenAPI contract to docs/openapi.json (§58). */
import { writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildServer } from './server.ts';
import { pool } from './db/client.ts';

const here = path.dirname(fileURLToPath(import.meta.url));
const app = await buildServer();
await app.ready();
const spec = app.swagger();
const out = path.resolve(here, '../../../docs/openapi.json');
await writeFile(out, JSON.stringify(spec, null, 2));
console.log(`OpenAPI written to ${out} (${Object.keys((spec as { paths: object }).paths).length} paths)`);
await app.close();
await pool.end();
