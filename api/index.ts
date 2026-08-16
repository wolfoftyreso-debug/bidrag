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
import { buildServer } from '../apps/api/src/server.ts';

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
