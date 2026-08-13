/**
 * Production-hardening guarantees: CSRF origin guard, rate limiting,
 * and idempotent deadline reminders.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { and, eq } from 'drizzle-orm';
import { api, createProfileAndProject, registerUser, testServer, type TestUser } from './helpers.ts';
import { db } from '../src/db/client.ts';
import { applicationCases, fundingOpportunities, notifications, projects } from '../src/db/schema.ts';
import { runDeadlineScan } from '../src/services/reminders.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Härdad');
});

afterAll(async () => {
  await app.close();
});

describe('origin guard (CSRF defence-in-depth)', () => {
  it('blocks state-changing requests from a foreign origin', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/profiles',
      headers: { cookie: user.cookie, origin: 'https://evil.example' },
      payload: { kind: 'person', displayName: 'x', applicantType: 'individual' },
    });
    expect(res.statusCode).toBe(403);
    expect((res.json() as { error: string }).error).toBe('forbidden_origin');
  });

  it('allows the configured frontend origin and GET from anywhere', async () => {
    const post = await app.inject({
      method: 'POST',
      url: '/v1/profiles',
      headers: { cookie: user.cookie, origin: 'http://localhost:5173', 'content-type': 'application/json' },
      payload: { kind: 'person', displayName: 'Ok', applicantType: 'individual' },
    });
    expect(post.statusCode).toBe(201);

    const get = await app.inject({
      method: 'GET',
      url: '/v1/profiles',
      headers: { cookie: user.cookie, origin: 'https://evil.example' },
    });
    expect(get.statusCode).toBe(200); // reads carry no CSRF risk; CORS handles exposure
  });

  it('allows requests without Origin/Referer (no ambient browser authority)', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/profiles',
      headers: { cookie: user.cookie },
      payload: { kind: 'person', displayName: 'Server', applicantType: 'individual' },
    });
    expect(res.statusCode).toBe(201);
  });
});

describe('rate limiting', () => {
  it('throttles rapid login attempts (11th within a minute is rejected)', async () => {
    let lastStatus = 0;
    for (let i = 0; i < 11; i++) {
      const res = await app.inject({
        method: 'POST',
        url: '/v1/auth/login',
        remoteAddress: '10.99.99.99',
        payload: { email: 'ratelimit@test.example', password: 'fel-losenord-000000' },
      });
      lastStatus = res.statusCode;
    }
    expect(lastStatus).toBe(429);
  });
});

describe('error responses never leak internals', () => {
  it('500-class errors return a generic message with request id — no stack, no addresses', async () => {
    // Regression guard: the error handler must be inherited by ENCAPSULATED
    // route contexts (it is captured at register time). A route in a child
    // plugin that throws a pg-style error must still produce the safe shape.
    const { buildServer } = await import('../src/server.ts');
    const scoped = await buildServer();
    await scoped.register(async (child) => {
      child.post('/v1/_test_boom', async () => {
        const err = new Error('connect ECONNREFUSED 127.0.0.1:5432') as Error & { code: string };
        err.code = 'ECONNREFUSED';
        throw err;
      });
    });
    await scoped.ready();
    const res = await scoped.inject({ method: 'POST', url: '/v1/_test_boom' });
    expect(res.statusCode).toBe(500);
    const body = res.json() as { error: string; message: string; requestId?: string };
    expect(body.error).toBe('internal_error');
    expect(body.message).not.toContain('ECONNREFUSED');
    expect(body.message).not.toContain('127.0.0.1');
    expect(body.requestId).toBeTruthy();
    await scoped.close();
  });
});

describe('deadline reminders are idempotent', () => {
  it('notifies once per threshold bucket, not once per scan', async () => {
    const { project } = await createProfileAndProject(app, user);
    const [opp] = await db
      .select({ id: fundingOpportunities.id })
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.slug, 'kulturradet-internationellt-resebidrag-musik'))
      .limit(1);
    const caseRes = await api(app, user, 'POST', '/v1/applications', {
      projectId: project.id,
      opportunityId: opp!.id,
    });
    const caseId = (caseRes.json() as { application: { id: string } }).application.id;
    // Sätt en deadline 5 dagar bort (7-dagarsintervallet).
    await db
      .update(applicationCases)
      .set({ deadlineAt: new Date(Date.now() + 5 * 86_400_000) })
      .where(eq(applicationCases.id, caseId));

    const first = await runDeadlineScan();
    expect(first.notified).toBeGreaterThanOrEqual(1);
    const second = await runDeadlineScan();
    expect(second.notified).toBe(0); // samma intervall → ingen ny notis

    const rows = await db
      .select({ id: notifications.id })
      .from(notifications)
      .where(and(eq(notifications.tenantId, user.tenantId), eq(notifications.refId, caseId)));
    expect(rows).toHaveLength(1);

    // Deadline närmar sig → nästa intervall ger EN ny notis.
    await db
      .update(applicationCases)
      .set({ deadlineAt: new Date(Date.now() + 2 * 86_400_000) })
      .where(eq(applicationCases.id, caseId));
    const third = await runDeadlineScan();
    expect(third.notified).toBe(1);
    const fourth = await runDeadlineScan();
    expect(fourth.notified).toBe(0);
  });
});
