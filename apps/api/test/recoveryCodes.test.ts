/**
 * Återställningskoder — den kanal-lösa återställningsvägen (produktbeslutet
 * i docs/LIMITATIONS.md §4): fungerar helt utan e-postkanal, koderna visas
 * en gång och lagras hashade, engångsanvändning är atomisk, nygenerering
 * ersätter hela uppsättningen, och ytan läcker aldrig om ett konto finns.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let codes: string[];

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Kodhållaren');
});
afterAll(async () => {
  await app.close();
});

describe('återställningskoder', () => {
  it('an authenticated user generates 8 codes, shown exactly once', async () => {
    const res = await api(app, user, 'POST', '/v1/auth/recovery-codes');
    expect(res.statusCode).toBe(200);
    codes = (res.json() as { codes: string[] }).codes;
    expect(codes).toHaveLength(8);
    for (const c of codes) expect(c).toMatch(/^[A-Z2-9]{5}-[A-Z2-9]{5}-[A-Z2-9]{5}$/);

    const status = await api(app, user, 'GET', '/v1/auth/recovery-codes');
    expect(status.json()).toEqual({ total: 8, remaining: 8 });
  });

  it('generation requires authentication', async () => {
    const res = await api(app, null, 'POST', '/v1/auth/recovery-codes');
    expect(res.statusCode).toBe(401);
  });

  it('recovers the account with a code — no email channel involved — and kills every session', async () => {
    const saved = process.env.SMTP_URL;
    delete process.env.SMTP_URL; // kanal-lös miljö: länk-vägen är 503, kod-vägen ska fungera
    try {
      const res = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
        email: user.email,
        // Normalisering: gemener och mellanslag i stället för bindestreck ska matcha.
        code: codes[0]!.toLowerCase().replaceAll('-', ' '),
        password: 'nytt-kodbaserat-losenord-77',
      });
      expect(res.statusCode).toBe(200);
    } finally {
      process.env.SMTP_URL = saved;
    }

    // Gamla sessionen är död, gamla lösenordet också; nya fungerar.
    const refresh = await app.inject({ method: 'POST', url: '/v1/auth/refresh', headers: { cookie: user.cookie } });
    expect(refresh.statusCode).toBe(401);
    const oldLogin = await api(app, null, 'POST', '/v1/auth/login', { email: user.email, password: 'mycket-sakert-losenord-123' });
    expect(oldLogin.statusCode).toBe(401);
    const newLogin = await api(app, null, 'POST', '/v1/auth/login', { email: user.email, password: 'nytt-kodbaserat-losenord-77' });
    expect(newLogin.statusCode).toBe(200);
  });

  it('a code is single-use and consumption is visible in the status', async () => {
    const again = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
      email: user.email,
      code: codes[0]!,
      password: 'fjarde-langa-losenordet-88',
    });
    expect(again.statusCode).toBe(422);

    const status = await api(app, user, 'GET', '/v1/auth/recovery-codes');
    expect(status.json()).toEqual({ total: 8, remaining: 7 });
  });

  it('answers identically for wrong code, someone else’s code and unknown account — no enumeration', async () => {
    const other = await registerUser(app, 'Främling');
    const wrongCode = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
      email: user.email,
      code: 'AAAAA-BBBBB-CCCCC',
      password: 'giltigt-langt-losenord-55',
    });
    const othersCode = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
      email: other.email, // koden tillhör `user`, inte `other`
      code: codes[1]!,
      password: 'giltigt-langt-losenord-55',
    });
    const unknownAccount = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
      email: 'finnsinte@test.example',
      code: codes[1]!,
      password: 'giltigt-langt-losenord-55',
    });
    expect(wrongCode.statusCode).toBe(422);
    expect(othersCode.statusCode).toBe(422);
    expect(unknownAccount.statusCode).toBe(422);
    expect(wrongCode.body).toBe(unknownAccount.body);
    expect(othersCode.body).toBe(unknownAccount.body);
  });

  it('regenerating replaces the whole set — old codes stop working immediately', async () => {
    // Ny session efter lösenordsbytet (gamla cookien är återkallad).
    const login = await app.inject({
      method: 'POST',
      url: '/v1/auth/login',
      payload: { email: user.email, password: 'nytt-kodbaserat-losenord-77' },
    });
    const access = (login.cookies as { name: string; value: string }[]).find((c) => c.name === 'bidrag_access')!;
    const cookie = `bidrag_access=${access.value}`;
    const fresh = await app.inject({ method: 'POST', url: '/v1/auth/recovery-codes', headers: { cookie } });
    expect(fresh.statusCode).toBe(200);

    const oldCode = await api(app, null, 'POST', '/v1/auth/recover-with-code', {
      email: user.email,
      code: codes[2]!, // oanvänd, men ur den ersatta uppsättningen
      password: 'giltigt-langt-losenord-66',
    });
    expect(oldCode.statusCode).toBe(422);

    const status = await app.inject({ method: 'GET', url: '/v1/auth/recovery-codes', headers: { cookie } });
    expect(status.json()).toEqual({ total: 8, remaining: 8 });
  });
});
