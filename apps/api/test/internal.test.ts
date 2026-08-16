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
