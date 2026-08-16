/**
 * Interna cron-endpoints för drift utan långlivad process (Vercel Cron).
 * Skyddas av CRON_SECRET som Bearer-token — Vercel Cron skickar headern
 * automatiskt när miljövariabeln finns. Utan konfigurerad hemlighet är hela
 * ytan avstängd (404), aldrig öppen av misstag. Jobben är idempotenta, så en
 * missad eller dubblerad körning är alltid säker.
 */
import type { FastifyInstance } from 'fastify';
import { timingSafeEqual } from 'node:crypto';
import { config } from '../config.ts';
import { CRON_TASKS } from '../jobs/tasks.ts';

function authorized(header: string | undefined): boolean {
  if (!config.cronSecret || !header?.startsWith('Bearer ')) return false;
  const given = Buffer.from(header.slice(7));
  const expected = Buffer.from(config.cronSecret);
  return given.length === expected.length && timingSafeEqual(given, expected);
}

export async function internalRoutes(app: FastifyInstance) {
  app.route({
    method: ['GET', 'POST'],
    url: '/v1/internal/cron/:job',
    config: { rateLimit: { max: 60, timeWindow: '1 minute' } },
    schema: {
      tags: ['internal'],
      params: { type: 'object', properties: { job: { type: 'string', maxLength: 40 } }, required: ['job'] },
    },
    handler: async (request, reply) => {
      if (!config.cronSecret) return reply.code(404).send({ error: 'not_found' });
      if (!authorized(request.headers.authorization)) return reply.code(401).send({ error: 'unauthorized' });

      const { job } = request.params as { job: string };
      const task = CRON_TASKS[job];
      if (!task) return reply.code(404).send({ error: 'unknown_job' });

      const startedAt = Date.now();
      try {
        const result = await task();
        request.log.info({ job, ms: Date.now() - startedAt, result }, 'cron job completed');
        return { ok: true, job, ms: Date.now() - startedAt, result: result ?? null };
      } catch (err) {
        request.log.error({ job, err }, 'cron job failed');
        return reply.code(500).send({ ok: false, job, error: 'job_failed' });
      }
    },
  });
}
