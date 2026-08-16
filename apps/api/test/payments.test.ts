/**
 * Analysupplåsning (§68): teasern visar värdet men aldrig detaljerna;
 * betalning → bekräftelse → full analys. Mockprovidern är tenant-skyddad
 * och kan aldrig aktiveras i produktion (config-villkor).
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;
let paymentId: string;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Betalaren');
  // Fixture UTAN auto-upplåsning — vi bygger den för hand.
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person', displayName: 'Min situation', applicantType: 'individual', country: 'SE',
    facts: { 'person.hasChildrenAtHome': true, 'person.lowHouseholdIncome': true, 'person.paysHousingCost': true },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;
  const projectRes = await api(app, user, 'POST', '/v1/projects', {
    profileId: profile.id, title: 'Min ekonomiska situation', intent: 'test',
  });
  projectId = (projectRes.json() as { project: { id: string } }).project.id;
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
});

afterAll(async () => {
  await app.close();
});

describe('teaser före betalning', () => {
  it('shows counts and categories but never names, sources or questions', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    expect(res.statusCode).toBe(200);
    const body = res.json() as {
      locked: boolean; priceMinor: number; total: number;
      counts: { high: number; possible: number; needsInfo: number };
      rows: { likelihood: string; category: string }[];
    };
    expect(body.locked).toBe(true);
    expect(body.priceMinor).toBe(3900);
    expect(body.total).toBeGreaterThanOrEqual(3);
    expect(body.counts.high).toBeGreaterThanOrEqual(1); // bostadsbidrag: alla kända krav uppfyllda
    expect(body.rows.every((r) => ['high', 'possible', 'needs_info'].includes(r.likelihood))).toBe(true);

    // Inget läckage: inga stödnamn, myndigheter, slugs, källor eller frågor.
    const raw = res.body;
    for (const forbidden of ['Bostadsbidrag', 'Försäkringskassan', 'fk-bostadsbidrag', 'sourceUrl', 'missingFacts', 'kulturradet']) {
      expect(raw, `teasern läcker "${forbidden}"`).not.toContain(forbidden);
    }
  });

  it('locks the funding-stack behind the same purchase (402)', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/funding-stack`, { ownContributionMinor: 0 });
    expect(res.statusCode).toBe(402);
  });

  it('unlock-status reports locked with the price', async () => {
    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/unlock-status`);
    expect(res.json()).toMatchObject({ unlocked: false, priceMinor: 3900, currency: 'SEK' });
  });
});

describe('betalning → bekräftelse → upplåsning', () => {
  it('creates a pending payment with mock instructions', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`);
    expect(res.statusCode).toBe(201);
    const body = res.json() as { paymentId: string; amountMinor: number; instructions: { method: string; mockConfirmable: boolean; message: string } };
    paymentId = body.paymentId;
    expect(body.amountMinor).toBe(3900);
    expect(body.instructions.method).toBe('mock');
    expect(body.instructions.message).toContain('SIMULERAD');
  });

  it('another tenant cannot confirm someone else’s payment', async () => {
    const other = await registerUser(app, 'Annan');
    const res = await api(app, other, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(res.statusCode).toBe(404);
  });

  it('confirmation unlocks the full analysis', async () => {
    const confirm = await api(app, user, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(confirm.statusCode).toBe(200);

    const res = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const body = res.json() as { matches?: { slug: string; sourceUrl: string }[]; locked?: boolean };
    expect(body.locked).toBeUndefined();
    expect(body.matches!.some((m) => m.slug === 'fk-bostadsbidrag-barnfamiljer')).toBe(true);
    expect(body.matches![0]!.sourceUrl).toContain('https://');

    const status = await api(app, user, 'GET', `/v1/projects/${projectId}/unlock-status`);
    expect((status.json() as { unlocked: boolean }).unlocked).toBe(true);
  });

  it('a second unlock attempt is idempotent — never charge twice', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/analysis-unlock`);
    expect(res.statusCode).toBe(200);
    expect((res.json() as { alreadyUnlocked: boolean }).alreadyUnlocked).toBe(true);
  });

  it('a new project (new analysis) is locked again — one purchase per analysis', async () => {
    const profiles = await api(app, user, 'GET', '/v1/profiles');
    const profileId = (profiles.json() as { profiles: { id: string }[] }).profiles[0]!.id;
    const projectRes = await api(app, user, 'POST', '/v1/projects', { profileId, title: 'Nytt projekt', intent: 'annat' });
    const newId = (projectRes.json() as { project: { id: string } }).project.id;
    await api(app, user, 'POST', `/v1/projects/${newId}/matches`, {});
    const res = await api(app, user, 'GET', `/v1/projects/${newId}/matches`);
    expect((res.json() as { locked?: boolean }).locked).toBe(true);
  });

  it('payment webhooks refuse honestly until a real provider is configured', async () => {
    const res = await app.inject({ method: 'POST', url: '/v1/webhooks/payments/swish', payload: {} });
    expect(res.statusCode).toBe(503);
  });
});
