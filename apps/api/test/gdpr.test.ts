/**
 * GDPR self-service (§29): tenant export and erasure, plus the /metrics
 * exposition endpoint from the same hardening pass.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createProfileAndProject, registerUser, testServer, uploadPdf, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Raderaren');
  await createProfileAndProject(app, user);
  await uploadPdf(app, user, 'cv', 'cv.pdf');
});

afterAll(async () => {
  await app.close();
});

describe('GDPR self-service', () => {
  it('exports all tenant data as one JSON bundle', async () => {
    const res = await api(app, user, 'GET', '/v1/tenant/export');
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-disposition']).toContain('bidrag-export-');
    const bundle = res.json() as { tenantId: string; profiles: unknown[]; projects: unknown[]; documents: { sha256: string }[] };
    expect(bundle.tenantId).toBe(user.tenantId);
    expect(bundle.profiles).toHaveLength(1);
    expect(bundle.projects).toHaveLength(1);
    expect(bundle.documents).toHaveLength(1);
    expect(bundle.documents[0]!.sha256).toMatch(/^[0-9a-f]{64}$/);
  });

  it('refuses erasure without the typed confirmation', async () => {
    const res = await api(app, user, 'DELETE', '/v1/tenant', { confirm: 'ja' });
    expect(res.statusCode).toBe(422);
  });

  it('erases the tenant and cascades all owned data', async () => {
    const res = await api(app, user, 'DELETE', '/v1/tenant', { confirm: 'RADERA' });
    expect(res.statusCode).toBe(200);

    // The session's tenant membership is gone — requests are unauthenticated.
    const after = await api(app, user, 'GET', '/v1/projects');
    expect(after.statusCode).toBe(401);
  });

  it('another tenant cannot invoke erasure on someone else via headers', async () => {
    const other = await registerUser(app, 'Annan');
    const res = await app.inject({
      method: 'DELETE',
      url: '/v1/tenant',
      headers: { cookie: other.cookie, 'x-tenant-id': user.tenantId },
      payload: { confirm: 'RADERA' },
    });
    expect(res.statusCode).toBe(401);
  });
});

describe('metrics endpoint', () => {
  it('serves Prometheus text format with domain gauges', async () => {
    const res = await app.inject({ method: 'GET', url: '/metrics' });
    expect(res.statusCode).toBe(200);
    expect(res.headers['content-type']).toContain('text/plain');
    expect(res.body).toContain('bidrag_http_requests_total');
    expect(res.body).toContain('bidrag_opportunities_published');
    expect(res.body).toContain('bidrag_matches_stale');
    expect(res.body).toContain('bidrag_pg_pool_total');
  });
});
