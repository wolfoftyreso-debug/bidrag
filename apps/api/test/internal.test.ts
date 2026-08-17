/**
 * Interna cron-endpoints (Vercel Cron-vägen): Bearer-skydd med CRON_SECRET,
 * 404 utan konfigurerad hemlighet är omöjligt att testa här (env sätts i
 * vitest.config), men fel/avsaknad av token och okänt jobb verifieras, plus
 * att ett riktigt jobb faktiskt kör.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { testServer } from './helpers.ts';

let app: FastifyInstance;

beforeAll(async () => {
  app = await testServer();
});
afterAll(async () => {
  await app.close();
});

describe('cron endpoints', () => {
  it('rejects missing and wrong bearer tokens', async () => {
    const noAuth = await app.inject({ method: 'POST', url: '/v1/internal/cron/deadline-scan' });
    expect(noAuth.statusCode).toBe(401);
    const wrong = await app.inject({
      method: 'POST',
      url: '/v1/internal/cron/deadline-scan',
      headers: { authorization: 'Bearer fel-hemlighet' },
    });
    expect(wrong.statusCode).toBe(401);
  });

  it('runs a real job with the correct secret', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/internal/cron/deadline-scan',
      headers: { authorization: 'Bearer test-cron-secret' },
    });
    expect(res.statusCode).toBe(200);
    expect((res.json() as { ok: boolean; job: string }).job).toBe('deadline-scan');
  });

  it('unknown jobs are 404, never arbitrary execution', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/internal/cron/rm-rf',
      headers: { authorization: 'Bearer test-cron-secret' },
    });
    expect(res.statusCode).toBe(404);
  });
});

describe('readiness endpoint (aktiveringsberedskap)', () => {
  it('rejects without the cron secret', async () => {
    const res = await app.inject({ method: 'GET', url: '/v1/internal/readiness' });
    expect(res.statusCode).toBe(401);
  });

  it('reports honest per-integration status without external calls', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/v1/internal/readiness',
      headers: { authorization: 'Bearer test-cron-secret' },
    });
    expect(res.statusCode).toBe(200);
    const body = res.json() as {
      ok: boolean;
      probed: boolean;
      checks: Record<string, { status: string; detail: string }>;
      blockers: string[];
    };
    expect(body.probed).toBe(false);
    expect(body.checks.database!.status).toBe('ready');
    // Testmiljön kör mockbetalningar och generation-mock — det ska redovisas
    // som blockerare för produktion, aldrig döljas som "ready".
    expect(body.checks.payments_swish!.status).toBe('mock');
    expect(body.checks.generation_anthropic!.status).toBe('mock');
    // Testmiljön har en SMTP-kanal konfigurerad (vitest.config) — redovisas som klar.
    expect(body.checks.email_resend!.status).toBe('ready');
    expect(body.ok).toBe(false);
    expect(body.blockers).toContain('payments_swish');
    expect(body.blockers).toContain('generation_anthropic');
    expect(body.blockers).not.toContain('email_resend');
    // Varje icke-klar kontroll pekar på vad aktiveringen kräver.
    for (const key of body.blockers) {
      expect(body.checks[key]!.detail.length).toBeGreaterThan(20);
    }
  });
});
