import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer } from './helpers.ts';

let app: FastifyInstance;

beforeAll(async () => {
  app = await testServer();
});
afterAll(async () => {
  await app.close();
});

describe('auth', () => {
  it('registers a user with a personal tenant and owner role', async () => {
    const user = await registerUser(app);
    const me = await api(app, user, 'GET', '/v1/auth/me');
    expect(me.statusCode).toBe(200);
    const body = me.json() as { activeTenant: { role: string }; tenants: unknown[] };
    expect(body.activeTenant.role).toBe('owner');
    expect(body.tenants).toHaveLength(1);
  });

  it('rejects duplicate registration', async () => {
    const user = await registerUser(app);
    const res = await app.inject({
      method: 'POST',
      url: '/v1/auth/register',
      payload: { email: user.email, password: 'annat-langt-losenord-456', displayName: 'X' },
    });
    expect(res.statusCode).toBe(409);
  });

  it('rejects short passwords', async () => {
    const res = await app.inject({
      method: 'POST',
      url: '/v1/auth/register',
      payload: { email: 'short@test.example', password: 'kort', displayName: 'X' },
    });
    expect(res.statusCode).toBe(400);
  });

  it('rejects wrong credentials with identical error shape', async () => {
    const user = await registerUser(app);
    const wrongPassword = await app.inject({
      method: 'POST',
      url: '/v1/auth/login',
      payload: { email: user.email, password: 'fel-losenord-000000' },
    });
    const noUser = await app.inject({
      method: 'POST',
      url: '/v1/auth/login',
      payload: { email: 'finns-inte@test.example', password: 'fel-losenord-000000' },
    });
    expect(wrongPassword.statusCode).toBe(401);
    expect(noUser.statusCode).toBe(401);
    expect(wrongPassword.json()).toEqual(noUser.json());
  });

  it('requires authentication for protected routes', async () => {
    for (const url of ['/v1/profiles', '/v1/projects', '/v1/applications', '/v1/funding-opportunities', '/v1/documents']) {
      const res = await api(app, null, 'GET', url);
      expect(res.statusCode, url).toBe(401);
    }
  });

  it('denies admin routes to regular users (RBAC)', async () => {
    const user = await registerUser(app);
    const res = await api(app, user, 'GET', '/v1/admin/sources');
    expect(res.statusCode).toBe(403);
  });
});
