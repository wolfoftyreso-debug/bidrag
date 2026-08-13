/**
 * CSRF defence-in-depth. Primary protections are SameSite=Lax cookies and
 * restricted CORS; this plugin adds an explicit Origin/Referer check on every
 * state-changing request so a misconfigured proxy or future cookie change
 * cannot silently reopen the hole.
 *
 * Rule: non-GET/HEAD/OPTIONS requests that carry an Origin (or Referer)
 * header must match the allowlist (configured CORS origins + own host).
 * Requests without either header (curl, server-to-server with bearer tokens)
 * pass — they carry no ambient cookie authority from a browser.
 */
import type { FastifyInstance } from 'fastify';
import fp from 'fastify-plugin';
import { config } from '../config.ts';

const SAFE_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);

function originOf(value: string): string | null {
  try {
    const u = new URL(value);
    return `${u.protocol}//${u.host}`;
  } catch {
    return null;
  }
}

export const originGuardPlugin = fp(async (app: FastifyInstance) => {
  const allowed = new Set(
    [...config.corsOrigin.split(','), config.publicBaseUrl]
      .map((o) => originOf(o.trim()))
      .filter((x): x is string => Boolean(x)),
  );

  app.addHook('onRequest', async (request, reply) => {
    if (SAFE_METHODS.has(request.method)) return;

    const headerValue = request.headers.origin ?? request.headers.referer;
    if (!headerValue) return;

    const origin = originOf(headerValue);
    // Same-host requests are always fine (SPA served by the API itself).
    const selfOrigin = `${request.protocol}://${request.headers.host ?? ''}`;
    if (origin && (allowed.has(origin) || origin === selfOrigin)) return;

    request.log.warn({ origin: headerValue, url: request.url }, 'blocked cross-origin state-changing request');
    await reply.code(403).send({ error: 'forbidden_origin', message: 'Begäran kommer från en otillåten källa.' });
  });
});
