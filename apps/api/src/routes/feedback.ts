/**
 * Betans två lärkanaler (docs/reports/BETA_READINESS_2026-09-03.md B1–B2):
 *  - POST /v1/feedback  — "Verkar något fel? Var detta begripligt?" från
 *    analysen, stödsidan och arbetsytan; kategoriserad så att faktafel kan gå
 *    rakt till kuratorn (admin läser via GET /v1/admin/feedback).
 *  - POST /v1/events    — allow-listade klienthändelser för trattmåtten.
 * Båda kräver inloggning (betan är sluten) och är hårt rate-limitade.
 */
import type { FastifyInstance } from 'fastify';
import { config } from '../config.ts';
import { db } from '../db/client.ts';
import { feedback } from '../db/schema.ts';
import { CLIENT_EVENTS, trackEvent } from '../services/events.ts';

const CATEGORIES = ['facts', 'language', 'navigation', 'missing', 'technical', 'other'] as const;

export async function feedbackRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.post(
    '/v1/feedback',
    {
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
      schema: {
        tags: ['feedback'],
        body: {
          type: 'object',
          required: ['category', 'page', 'message'],
          properties: {
            category: { type: 'string', enum: [...CATEGORIES] },
            page: { type: 'string', minLength: 1, maxLength: 200 },
            opportunitySlug: { type: 'string', maxLength: 120 },
            message: { type: 'string', minLength: 3, maxLength: 4000 },
            locale: { type: 'string', maxLength: 8 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const body = request.body as { category: (typeof CATEGORIES)[number]; page: string; opportunitySlug?: string; message: string; locale?: string };
      const [row] = await db
        .insert(feedback)
        .values({
          tenantId: request.auth!.tenantId,
          userId: request.auth!.userId,
          category: body.category,
          page: body.page,
          opportunitySlug: body.opportunitySlug ?? null,
          message: body.message.trim(),
          locale: body.locale ?? null,
          userAgent: (request.headers['user-agent'] ?? '').slice(0, 300) || null,
        })
        .returning({ id: feedback.id });
      await trackEvent('feedback_skickad', { tenantId: request.auth!.tenantId, userId: request.auth!.userId, props: { category: body.category, page: body.page } });
      return reply.code(201).send({ id: row!.id });
    },
  );

  app.post(
    '/v1/events',
    {
      // 60/min per IP i produktion (default RATE_LIMIT_MAX=300). Skalar med
      // RATE_LIMIT_MAX så att belastningstestet (scripts/loadtest.mjs, all
      // trafik från EN IP) mäter kapaciteten och inte vakten.
      config: { rateLimit: { max: Math.max(60, Math.floor(config.rateLimitMax / 5)), timeWindow: '1 minute' } },
      schema: {
        tags: ['feedback'],
        body: {
          type: 'object',
          required: ['name'],
          properties: {
            name: { type: 'string', maxLength: 40 },
            props: { type: 'object', additionalProperties: { anyOf: [{ type: 'string', maxLength: 200 }, { type: 'number' }, { type: 'boolean' }] }, maxProperties: 8 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { name, props } = request.body as { name: string; props?: Record<string, string | number | boolean> };
      if (!CLIENT_EVENTS.has(name)) return reply.code(400).send({ error: 'unknown_event' });
      await trackEvent(name, { tenantId: request.auth!.tenantId, userId: request.auth!.userId, props: props ?? {} });
      return reply.code(202).send({ ok: true });
    },
  );
}
