/**
 * Vercel-entry: hela Fastify-API:t som EN serverless-funktion. Ingen
 * omskrivning av rutter/auth/tenancy — samma buildServer som i container-
 * driften, med två medvetna skillnader för serverless:
 *
 *  - Migreringar körs INTE vid kallstart (deploysteg: npm run db:migrate mot
 *    direktanslutningen). En funktion som muterar schema vid första anropet
 *    är en kapplöpning.
 *  - pg-boss-workern startas INTE — schemaläggning sker via Vercel Cron mot
 *    /v1/internal/cron/:job (se vercel.json).
 *
 * Instansen delas mellan anrop i samma funktionscontainer (varm start),
 * vilket ger normal Fastify-prestanda efter första anropet.
 */
import type { IncomingMessage, ServerResponse } from 'node:http';
// VIKTIGT: importera den KOMPILERADE servern (apps/api byggs i vercel.json:s
// buildCommand före funktionspaketeringen). En .ts-import överlever ordagrant
// in i Vercels funktionsbundle och kan inte lösas i runtime —
// FUNCTION_INVOCATION_FAILED på varje anrop (verifierat i runtime-loggarna
// 2026-08-28). Lokalt fungerar .ts bara tack vare --experimental-strip-types,
// vilket är precis varför simuleringen inte fångade felet.
import { buildServer } from '../apps/api/dist/server.js';

let appPromise: ReturnType<typeof buildServer> | null = null;

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  appPromise ??= (async () => {
    const app = await buildServer();
    await app.ready();
    return app;
  })();
  const app = await appPromise;
  app.server.emit('request', req, res);
}
