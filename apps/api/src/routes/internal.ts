/**
 * Interna cron-endpoints för drift utan långlivad process (Vercel Cron).
 * Skyddas av CRON_SECRET som Bearer-token — Vercel Cron skickar headern
 * automatiskt när miljövariabeln finns. Utan konfigurerad hemlighet är hela
 * ytan avstängd (404), aldrig öppen av misstag. Jobben är idempotenta, så en
 * missad eller dubblerad körning är alltid säker.
 */
import type { FastifyInstance } from 'fastify';
import { timingSafeEqual } from 'node:crypto';
import Anthropic from '@anthropic-ai/sdk';
import { sql } from 'drizzle-orm';
import { config } from '../config.ts';
import { db } from '../db/client.ts';
import { CRON_TASKS } from '../jobs/tasks.ts';
import { eventSummary } from '../services/events.ts';
import { emailConfigured } from '../services/email.ts';
import { swishConfigured } from '../services/integrations/swish.ts';
import { stripeConfigured } from '../services/integrations/stripe.ts';

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

  /** Kontrollrummets trattsammanställning (BETA_READINESS B2). CRON_SECRET-skyddad. */
  app.get(
    '/v1/internal/metrics/product',
    {
      config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
      schema: {
        tags: ['internal'],
        querystring: { type: 'object', properties: { days: { type: 'integer', minimum: 1, maximum: 90 } }, additionalProperties: false },
      },
    },
    async (request, reply) => {
      if (!config.cronSecret) return reply.code(404).send({ error: 'not_found' });
      if (!authorized(request.headers.authorization)) return reply.code(401).send({ error: 'unauthorized' });
      const days = (request.query as { days?: number }).days ?? 7;
      return eventSummary(days);
    },
  );

  /**
   * Aktiveringsberedskap: en endpoint som gör varje driftsättning verifierbar.
   * Utan ?probe=true görs inga externa anrop — bara konfigurationsstatus.
   * Med ?probe=true görs ofarliga läsanrop mot Resend (GET /domains) och
   * Anthropic (GET /v1/models/claude-opus-5) för att bevisa att nycklarna
   * faktiskt fungerar. Skyddas av CRON_SECRET precis som cron-ytan.
   */
  app.get(
    '/v1/internal/readiness',
    {
      config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
      schema: {
        tags: ['internal'],
        querystring: { type: 'object', properties: { probe: { type: 'string', enum: ['true', 'false'] } }, additionalProperties: false },
      },
    },
    async (request, reply) => {
      if (!config.cronSecret) return reply.code(404).send({ error: 'not_found' });
      if (!authorized(request.headers.authorization)) return reply.code(401).send({ error: 'unauthorized' });
      const probe = (request.query as { probe?: string }).probe === 'true';

      const checks: Record<string, { status: 'ready' | 'not_configured' | 'mock' | 'error'; detail: string }> = {};

      try {
        await db.execute(sql`select 1`);
        checks.database = { status: 'ready', detail: 'Databasen svarar.' };
      } catch (err) {
        checks.database = { status: 'error', detail: `Databasen svarar inte: ${(err as Error).message}` };
      }

      // Betalväg: valfri riktig provider räcker. Stripe är lanseringsrälsen
      // (Swish dröjer); mock endast utanför produktion; annars ingen betalväg.
      checks.payments = stripeConfigured()
        ? { status: 'ready', detail: 'Stripe är konfigurerat (Checkout). STRIPE_WEBHOOK_SECRET krävs för bekräftelse.' }
        : swishConfigured()
          ? { status: 'ready', detail: 'Swish-certifikat och handelsalias är konfigurerade.' }
          : config.paymentsMockEnabled
            ? { status: 'mock', detail: 'Mockbetalningar aktiva (endast utanför produktion). Aktivering: STRIPE_SECRET_KEY + STRIPE_WEBHOOK_SECRET, eller SWISH_MERCHANT_ALIAS + SWISH_CERT_BASE64 + SWISH_KEY_BASE64.' }
            : { status: 'not_configured', detail: 'Ingen betalväg. Aktivering kräver Stripe (STRIPE_SECRET_KEY + STRIPE_WEBHOOK_SECRET) eller Swish Handel-avtal + certifikat (se docs/ACTIVATION.md).' };

      // Objektlagring: 'postgres' (in-house Neon) och 'supabase' är beständiga;
      // 'disk' är flyktig på serverless och duger bara utanför produktion.
      checks.storage = config.storageDriver === 'postgres'
        ? { status: 'ready', detail: 'Objektlagring i Postgres/Neon — privat, i databasen, överlever serverless.' }
        : config.storageDriver === 'supabase'
          ? (config.supabaseUrl && config.supabaseServiceRoleKey
              ? { status: 'ready', detail: 'Supabase Storage konfigurerat (privat bucket).' }
              : { status: 'not_configured', detail: 'STORAGE_DRIVER=supabase kräver SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY.' })
          : (process.env.NODE_ENV === 'production' && process.env.VERCEL_ENV !== 'preview'
              ? { status: 'not_configured', detail: 'STORAGE_DRIVER=disk är flyktig på serverless och överlever inte nästa anrop. Sätt STORAGE_DRIVER=postgres (Neon) för beständig privat lagring.' }
              : { status: 'ready', detail: 'Disklagring (lokal utveckling/test/container med volym).' });

      if (!emailConfigured()) {
        checks.email_resend = { status: 'not_configured', detail: 'Ingen e-postkanal. Aktivering kräver RESEND_API_KEY + EMAIL_FROM med verifierad domän. Kvitton i kontot och återställningskoder fungerar ändå; länk-återställning är avstängd (fail-closed).' };
      } else if (probe && config.resendApiKey) {
        try {
          const res = await fetch('https://api.resend.com/domains', {
            headers: { Authorization: `Bearer ${config.resendApiKey}` },
          });
          checks.email_resend = res.ok
            ? { status: 'ready', detail: `Resend-nyckeln fungerar (GET /domains → ${res.status}). Kontrollera att ${config.emailFrom} ligger på en verifierad domän.` }
            : { status: 'error', detail: `Resend-nyckeln avvisades (GET /domains → ${res.status}).` };
        } catch (err) {
          checks.email_resend = { status: 'error', detail: `Resend nåddes inte: ${(err as Error).message}` };
        }
      } else {
        checks.email_resend = { status: 'ready', detail: `E-postkanal konfigurerad (${config.resendApiKey ? 'Resend' : 'SMTP'}). Kör ?probe=true för att verifiera nyckeln mot Resend.` };
      }

      if (!config.anthropicApiKey) {
        checks.generation_anthropic = config.generationMockEnabled
          ? { status: 'mock', detail: 'Deterministisk generation-mock aktiv (endast utanför produktion). Aktivering kräver ANTHROPIC_API_KEY.' }
          : { status: 'not_configured', detail: 'Språkförslag avstängda (503). Aktivering kräver ANTHROPIC_API_KEY; modell claude-opus-5.' };
      } else if (probe) {
        try {
          const anthropic = new Anthropic({ apiKey: config.anthropicApiKey });
          const model = await anthropic.models.retrieve('claude-opus-5');
          checks.generation_anthropic = { status: 'ready', detail: `Anthropic-nyckeln fungerar; ${model.id} är tillgänglig.` };
        } catch (err) {
          checks.generation_anthropic =
            err instanceof Anthropic.APIError
              ? { status: 'error', detail: `Anthropic-nyckeln avvisades (${err.status}).` }
              : { status: 'error', detail: `Anthropic nåddes inte: ${(err as Error).message}` };
        }
      } else {
        checks.generation_anthropic = { status: 'ready', detail: 'ANTHROPIC_API_KEY satt (modell claude-opus-5). Kör ?probe=true för att verifiera nyckeln.' };
      }

      const blockers = Object.entries(checks)
        .filter(([, c]) => c.status === 'not_configured' || c.status === 'mock' || c.status === 'error')
        .map(([k]) => k);
      return {
        ok: blockers.length === 0,
        probed: probe,
        environment: process.env.NODE_ENV ?? 'development',
        checks,
        blockers,
      };
    },
  );
}
