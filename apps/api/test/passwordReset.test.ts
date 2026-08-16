/**
 * Lösenordsåterställning ("innan riktiga kronor"): ingen kontouppräkning,
 * engångstoken med TTL, alla sessioner dödas vid byte.
 */
import { createHash } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { db } from '../src/db/client.ts';
import { passwordResetTokens, users } from '../src/db/schema.ts';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Glömska');
});
afterAll(async () => {
  await app.close();
});

/** Testet läser tokenhashen ur databasen och återskapar klartexten går inte —
 *  därför injicerar vi en känd token direkt (samma väg som routen skapar den). */
async function plantToken(email: string, opts: { expired?: boolean } = {}): Promise<string> {
  const [u] = await db.select({ id: users.id }).from(users).where(eq(users.email, email)).limit(1);
  const token = `testtoken-${Math.random().toString(36).slice(2)}-${Date.now()}`;
  await db.insert(passwordResetTokens).values({
    userId: u!.id,
    tokenHash: createHash('sha256').update(token).digest('hex'),
    expiresAt: new Date(Date.now() + (opts.expired ? -60_000 : 3_600_000)),
  });
  return token;
}

describe('lösenordsåterställning', () => {
  it('answers identically for existing and unknown addresses — no enumeration', async () => {
    const known = await api(app, null, 'POST', '/v1/auth/request-password-reset', { email: user.email });
    const unknown = await api(app, null, 'POST', '/v1/auth/request-password-reset', { email: 'finnsinte@test.example' });
    expect(known.statusCode).toBe(200);
    expect(unknown.statusCode).toBe(200);
    expect(known.body).toBe(unknown.body);
  });

  it('resets the password with a valid token and kills every session', async () => {
    const token = await plantToken(user.email);
    const res = await api(app, null, 'POST', '/v1/auth/reset-password', { token, password: 'nytt-superlangt-losenord-99' });
    expect(res.statusCode).toBe(200);

    // Gamla sessionen är död: refresh-tokens återkallade.
    const refresh = await app.inject({ method: 'POST', url: '/v1/auth/refresh', headers: { cookie: user.cookie } });
    expect(refresh.statusCode).toBe(401);

    // Gamla lösenordet fungerar inte; nya gör det.
    const oldLogin = await api(app, null, 'POST', '/v1/auth/login', { email: user.email, password: 'mycket-sakert-losenord-123' });
    expect(oldLogin.statusCode).toBe(401);
    const newLogin = await api(app, null, 'POST', '/v1/auth/login', { email: user.email, password: 'nytt-superlangt-losenord-99' });
    expect(newLogin.statusCode).toBe(200);
  });

  it('a token is single-use', async () => {
    const token = await plantToken(user.email);
    const first = await api(app, null, 'POST', '/v1/auth/reset-password', { token, password: 'annu-ett-langt-losenord-11' });
    expect(first.statusCode).toBe(200);
    const second = await api(app, null, 'POST', '/v1/auth/reset-password', { token, password: 'tredje-langa-losenordet-22' });
    expect(second.statusCode).toBe(422);
  });

  it('expired and bogus tokens are rejected', async () => {
    const expired = await plantToken(user.email, { expired: true });
    const res = await api(app, null, 'POST', '/v1/auth/reset-password', { token: expired, password: 'giltigt-langt-losenord-33' });
    expect(res.statusCode).toBe(422);
    const bogus = await api(app, null, 'POST', '/v1/auth/reset-password', { token: 'helt-pahittad-token-123456', password: 'giltigt-langt-losenord-44' });
    expect(bogus.statusCode).toBe(422);
  });
});
