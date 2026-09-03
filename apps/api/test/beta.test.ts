/**
 * Betans byggstenar (docs/reports/BETA_READINESS_2026-09-03.md):
 *  B7 sluten beta — registreringen kräver inbjudningskod när BETA_INVITE_CODES är satt,
 *  B1 feedback — inloggad användare kan skicka, kuratorn läser i admin,
 *  B2 instrumentering — allow-listade klienthändelser + serverside trattsteg,
 *  A9 vakthund — jobbet kör och säger ok på en frisk databas.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { db } from '../src/db/client.ts';
import { feedback, memberships, productEvents } from '../src/db/schema.ts';
import { runWatchdog } from '../src/jobs/tasks.ts';
import { api, createProfileAndProject, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Betatestaren');
});
afterAll(async () => {
  delete process.env.BETA_INVITE_CODES;
  delete process.env.BETA_MODE;
  await app.close();
});

describe('sluten beta (B7)', () => {
  it('policyn är öppen utan koder och stängd med', async () => {
    delete process.env.BETA_INVITE_CODES;
    let res = await app.inject({ method: 'GET', url: '/v1/auth/register-policy' });
    expect(res.json()).toEqual({ inviteRequired: false, beta: false });
    process.env.BETA_INVITE_CODES = 'kod-ett, kod-tva';
    process.env.BETA_MODE = 'true';
    res = await app.inject({ method: 'GET', url: '/v1/auth/register-policy' });
    expect(res.json()).toEqual({ inviteRequired: true, beta: true });
  });

  it('registrering utan eller med fel kod ger 403, med rätt kod 201', async () => {
    process.env.BETA_INVITE_CODES = 'kod-ett, kod-tva';
    const base = { password: 'beta-losenord-123', displayName: 'Inbjuden' };
    const utan = await app.inject({ method: 'POST', url: '/v1/auth/register', payload: { ...base, email: `utan-${Date.now()}@test.example` } });
    expect(utan.statusCode).toBe(403);
    expect((utan.json() as { error: string }).error).toBe('invite_required');
    const fel = await app.inject({ method: 'POST', url: '/v1/auth/register', payload: { ...base, email: `fel-${Date.now()}@test.example`, inviteCode: 'kod-tre' } });
    expect(fel.statusCode).toBe(403);
    const ratt = await app.inject({ method: 'POST', url: '/v1/auth/register', payload: { ...base, email: `ratt-${Date.now()}@test.example`, inviteCode: 'kod-tva' } });
    expect(ratt.statusCode).toBe(201);
    delete process.env.BETA_INVITE_CODES;
  });
});

describe('feedback och händelser (B1–B2)', () => {
  it('feedback kräver inloggning, lagras och syns för kuratorn', async () => {
    const anon = await app.inject({ method: 'POST', url: '/v1/feedback', payload: { category: 'facts', page: 'analys', message: 'Beloppet ser fel ut.' } });
    expect(anon.statusCode).toBe(401);
    const res = await api(app, user, 'POST', '/v1/feedback', { category: 'facts', page: 'stod', opportunitySlug: 'fk-barnbidrag', message: 'Beloppet stämmer inte med Försäkringskassans sida.' });
    expect(res.statusCode).toBe(201);
    // Vanlig användare får inte läsa lådan; kuratorn får.
    const forbidden = await api(app, user, 'GET', '/v1/admin/feedback');
    expect(forbidden.statusCode).toBe(403);
    await db.update(memberships).set({ role: 'data_curator' }).where(eq(memberships.userId, user.userId));
    const list = await api(app, user, 'GET', '/v1/admin/feedback');
    expect(list.statusCode).toBe(200);
    const items = (list.json() as { items: { opportunitySlug: string | null; category: string }[] }).items;
    expect(items.some((i) => i.opportunitySlug === 'fk-barnbidrag' && i.category === 'facts')).toBe(true);
    await db.update(memberships).set({ role: 'owner' }).where(eq(memberships.userId, user.userId));
  });

  it('klienthändelser är allow-listade; matchningen loggar genomgang_slutford', async () => {
    const bad = await api(app, user, 'POST', '/v1/events', { name: 'betalning_bekraftad' });
    expect(bad.statusCode).toBe(400);
    const ok = await api(app, user, 'POST', '/v1/events', { name: 'genomgang_startad', props: { spar: 'personal' } });
    expect(ok.statusCode).toBe(202);
    const { project } = await createProfileAndProject(app, user);
    const m = await api(app, user, 'POST', `/v1/projects/${project.id}/matches`, {});
    expect(m.statusCode).toBe(200);
    const rows = await db.select({ name: productEvents.name }).from(productEvents).where(eq(productEvents.tenantId, user.tenantId));
    const names = rows.map((r) => r.name);
    expect(names).toContain('genomgang_startad');
    expect(names).toContain('genomgang_slutford');
    expect(names).toContain('konto_skapat');
  });
});

describe('vakthund (A9)', () => {
  it('bryter aldrig invarianterna på en frisk databas, larmar på ett obehandlat faktafel, mejlar inget utan ALERT_EMAIL', async () => {
    // Testdatabasen lever mellan körningar och samlar väntande testbetalningar och gamla
    // granskningsärenden — de trösklarna är driftlarm, inte testinvarianter. Det som
    // ALDRIG får larma här är databasen och kvittoinvarianten.
    const before = await runWatchdog();
    expect(before.notified).toBe('none');
    expect(before.alarms.some((a) => a.startsWith('databas') || a.includes('saknar kvitto'))).toBe(false);

    const [row] = await db
      .insert(feedback)
      .values({ tenantId: user.tenantId, userId: user.userId, category: 'facts', page: 'stod', message: 'Gammalt obehandlat faktafel', createdAt: new Date(Date.now() - 3 * 86_400_000) })
      .returning({ id: feedback.id });
    try {
      const r = await runWatchdog();
      expect(r.ok).toBe(false);
      expect(r.alarms.some((a) => a.includes('faktafelsrapport'))).toBe(true);
      expect(r.notified).toBe('none');
    } finally {
      await db.delete(feedback).where(eq(feedback.id, row!.id));
    }
  });
});
