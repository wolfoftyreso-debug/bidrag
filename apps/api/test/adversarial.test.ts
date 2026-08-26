/**
 * ADVERSARIAL SUITE — bedrägeri- och attacksimuleringar som körs vid VARJE
 * commit (npm test → verify → CI). Direktiv: "alla typer av försök till
 * bedrägeri, alla typer av hackerattack ... måste testas hela tiden."
 *
 * Detta är inte en engångsrevision utan en stående vakt: varje test kodifierar
 * ett konkret angrepp och kräver att systemet vägrar. En regression som öppnar
 * en av dessa vägar fäller bygget.
 *
 * Klasser: money-path-bedrägeri (pris/belopp, consent, gratisväg, replay,
 * kredit), cross-tenant/IDOR på pengar, mass-assignment, rolleskalering,
 * injection/mass-assignment, mock-gate. Kompletterar tenantIsolation.test.ts
 * och hardening.test.ts (som täcker CSRF, rate limit, felläckage).
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { pool } from '../src/db/client.ts';
import { config } from '../src/config.ts';
import {
  testServer,
  registerUser,
  api,
  unlockProject,
  payForApplication,
  type TestUser,
} from './helpers.ts';

let app: FastifyInstance;
let attacker: TestUser;
let victim: TestUser;

/** Skapa en profil + projekt UTAN att låsa upp analysen (för gratisväg-tester). */
async function rawProject(user: TestUser): Promise<{ projectId: string; profileId: string }> {
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person', displayName: 'P', applicantType: 'individual', country: 'SE',
    municipality: 'Stockholm', facts: { 'person.professionalArtist': true },
  });
  const profileId = (profileRes.json() as { profile: { id: string } }).profile.id;
  const projectRes = await api(app, user, 'POST', '/v1/projects', {
    profileId, title: 'Angreppsprojekt', intent: 'Test.',
    facts: { 'project.hasInternationalComponent': true, 'project.sector': 'culture', 'project.activityTypes': ['exchange'] },
  });
  const projectId = (projectRes.json() as { project: { id: string } }).project.id;
  return { projectId, profileId };
}

async function firstOpportunityId(user: TestUser, projectId: string): Promise<string> {
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
  const m = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
  const matches = (m.json() as { matches: { opportunityId: string }[] }).matches;
  return matches[0]!.opportunityId;
}

beforeAll(async () => {
  app = await testServer();
  attacker = await registerUser(app, 'Angripare');
  victim = await registerUser(app, 'Offer');
});
afterAll(async () => {
  await app.close();
  await pool.end();
});

// ── Money-path: pris & beloppsintegritet ─────────────────────────────────────
describe('bedrägeri: pris- och beloppsmanipulation', () => {
  it('klienten kan inte injicera eget belopp/pris — servern debiterar alltid konfigurerat pris', async () => {
    const { projectId } = await rawProject(attacker);
    const res = await api(app, attacker, 'POST', `/v1/projects/${projectId}/application-purchase`, {
      immediateDeliveryConsent: true, amountMinor: 1, priceMinor: 1, credits: 999, pack: 'gratis',
    });
    // Okända fält avvisas (400) ELLER strippas tyst av Fastify — i båda fallen
    // gäller invarianten: beloppet kommer ur config, aldrig ur request-body.
    if (res.statusCode === 201) {
      expect((res.json() as { amountMinor: number }).amountMinor).toBe(config.applicationPriceMinor);
    } else {
      expect(res.statusCode).toBe(400);
    }
  });
});

// ── Money-path: ångerrätts-consent tvingas server-side ───────────────────────
describe('bedrägeri: samtyckesgrinden kan inte kringgås från klienten', () => {
  it('utan consent → 400 consent_required, ingen betalning skapas', async () => {
    const { projectId } = await rawProject(attacker);
    const noField = await api(app, attacker, 'POST', `/v1/projects/${projectId}/application-purchase`, {});
    expect(noField.statusCode).toBe(400);
    expect((noField.json() as { error: string }).error).toBe('consent_required');
    const falseField = await api(app, attacker, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: false });
    expect(falseField.statusCode).toBe(400);
  });
});

// ── Money-path: gratisväg-bypass (få det som kostar utan att betala) ──────────
describe('bedrägeri: kan inte få upplåst innehåll utan betalning', () => {
  it('Open Discovery: finansieringsplanen är INTE en betalvägg (aldrig 402 analysis_locked)', async () => {
    const { projectId } = await rawProject(attacker);
    const res = await api(app, attacker, 'POST', `/v1/projects/${projectId}/funding-stack`, {});
    expect(res.statusCode).not.toBe(402);
    expect((res.json() as { error?: string }).error).not.toBe('analysis_locked');
  });

  it('ansökan utan köpt kredit ger 402 payment_required', async () => {
    const { projectId } = await rawProject(attacker);
    await unlockProject(app, attacker, projectId);
    const opp = await firstOpportunityId(attacker, projectId);
    const res = await api(app, attacker, 'POST', '/v1/applications', { projectId, opportunityId: opp });
    expect(res.statusCode).toBe(402);
    expect((res.json() as { error: string }).error).toBe('payment_required');
  });

  it('mock-confirm på en betalning som inte finns ger 404 (ingen kredit skapas)', async () => {
    const res = await api(app, attacker, 'POST', `/v1/payments/00000000-0000-0000-0000-000000000000/mock-confirm`);
    expect(res.statusCode).toBe(404);
  });
});

// ── Money-path: replay / dubbelbekräftelse ───────────────────────────────────
describe('bedrägeri: en betalning kan inte återanvändas för dubbla krediter', () => {
  it('dubbel mock-confirm ger EN kredit och EN ansökan — andra confirmen är no-op', async () => {
    const { projectId } = await rawProject(attacker);
    await unlockProject(app, attacker, projectId);
    const opp = await firstOpportunityId(attacker, projectId);

    const create = await api(app, attacker, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true });
    const paymentId = (create.json() as { paymentId: string }).paymentId;
    const first = await api(app, attacker, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(first.statusCode).toBe(200);
    const second = await api(app, attacker, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(second.statusCode).toBe(404); // pending-villkoret gör replayen till no-op

    const app1 = await api(app, attacker, 'POST', '/v1/applications', { projectId, opportunityId: opp });
    expect(app1.statusCode).toBe(201);
    // Krediten är förbrukad: en andra ansökan kräver ett nytt köp.
    const app2 = await api(app, attacker, 'POST', '/v1/applications', { projectId, opportunityId: opp });
    expect(app2.statusCode).toBe(402);
  });

  it('SAMTIDIGHET: en kredit ger EXAKT en ansökan även vid parallella anrop (TOCTOU-race)', async () => {
    // Bedrägerivägen: köp EN ansökningskredit och skjut iväg många parallella
    // POST /v1/applications samtidigt. Utan atomisk kontroll-och-förbrukning
    // läser alla remaining=1 och multiplicerar 19-kr-köpet. Systemet MÅSTE
    // släppa igenom exakt en; resten ska mötas av 402.
    const { projectId } = await rawProject(attacker);
    await unlockProject(app, attacker, projectId);
    const opp = await firstOpportunityId(attacker, projectId);
    await payForApplication(app, attacker, projectId); // exakt 1 kredit

    const parallel = await Promise.all(
      Array.from({ length: 12 }, () =>
        api(app, attacker, 'POST', '/v1/applications', { projectId, opportunityId: opp }),
      ),
    );
    const created = parallel_count(parallel, 201);
    const denied = parallel_count(parallel, 402);
    expect(created).toBe(1);
    expect(denied).toBe(11);
  });
});

function parallel_count(results: { statusCode: number }[], code: number): number {
  return results.filter((r) => r.statusCode === code).length;
}

// ── Cross-tenant: en användare kan inte röra en annans betalning ─────────────
describe('attack: cross-tenant på pengaflödet', () => {
  it('angriparen kan inte bekräfta offrets betalning (404) och offret förblir obetalt', async () => {
    const { projectId } = await rawProject(victim);
    const create = await api(app, victim, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true });
    const paymentId = (create.json() as { paymentId: string }).paymentId;

    const steal = await api(app, attacker, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
    expect(steal.statusCode).toBe(404); // scope.tenantId matchar inte → osynlig

    // Offrets betalning är fortfarande pending (angriparen kunde inte låsa upp åt någon).
    const status = await api(app, victim, 'GET', `/v1/payments/${paymentId}/status`);
    expect((status.json() as { state: string }).state).toBe('pending');
  });

  it('angriparen kan inte se offrets betalstatus eller kvitto (404)', async () => {
    const { projectId } = await rawProject(victim);
    const create = await api(app, victim, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true });
    const paymentId = (create.json() as { paymentId: string }).paymentId;
    const status = await api(app, attacker, 'GET', `/v1/payments/${paymentId}/status`);
    expect(status.statusCode).toBe(404);
  });
});

// ── Mass-assignment: klienten kan inte sätta serverägda fält ─────────────────
describe('attack: mass-assignment på skapande', () => {
  it('profil skapas alltid i den egna tenanten — injicerat tenantId/id ignoreras', async () => {
    const res = await api(app, attacker, 'POST', '/v1/profiles', {
      kind: 'person', displayName: 'X', applicantType: 'individual', country: 'SE',
      id: '11111111-1111-1111-1111-111111111111', tenantId: victim.tenantId, ownerUserId: victim.userId,
    });
    // Okända fält avvisas (additionalProperties:false) ELLER ignoreras och raden
    // hamnar i angriparens egen tenant — aldrig i offrets.
    if (res.statusCode === 201) {
      const profile = (res.json() as { profile: { id: string; tenantId: string } }).profile;
      expect(profile.tenantId).toBe(attacker.tenantId);
      expect(profile.id).not.toBe('11111111-1111-1111-1111-111111111111');
    } else {
      expect(res.statusCode).toBe(400);
    }
  });
});

// ── Rolleskalering (red team RT03-S1): kuratorsrollen är inte självtilldelbar ─
describe('attack: rolleskalering till global kurator', () => {
  it('data_curator kan inte bjudas in (schema-enum avvisar) och /v1/admin är stängt för icke-kurator', async () => {
    const orgRes = await api(app, attacker, 'POST', '/v1/tenants', { name: 'Angriparens org' });
    expect(orgRes.statusCode).toBe(201);
    const orgId = (orgRes.json() as { tenant: { id: string } }).tenant.id;

    const invite = await app.inject({
      method: 'POST', url: '/v1/tenant/invites',
      headers: { cookie: attacker.cookie, 'x-tenant-id': orgId },
      payload: { email: 'medbrottsling@test.example', role: 'data_curator' },
    });
    expect(invite.statusCode).toBe(400); // data_curator ej i INVITABLE_ROLES

    // Även administrator (som är inbjudningsbar för team) når INTE kurationskonsolen.
    const adminReach = await app.inject({
      method: 'GET', url: '/v1/admin/sources',
      headers: { cookie: attacker.cookie, 'x-tenant-id': orgId },
    });
    expect(adminReach.statusCode).toBe(403); // ägare är inte i CURATOR_ROLES
  });
});

// ── Mock-gate: mock får aldrig vara på i skarp produktion ────────────────────
describe('invariant: betalmocken är omöjlig i skarp produktion', () => {
  it('paymentsMockEnabled är sant här (test) men gatead på NODE_ENV/VERCEL_ENV i config', () => {
    // I testmiljön är mocken på (annars kunde köpflödet inte testas)…
    expect(config.paymentsMockEnabled).toBe(true);
    // …men gaten i config.ts tillåter den bara när NODE_ENV !== 'production'
    // ELLER VERCEL_ENV === 'preview'. previewMockGate.test.ts bevisar den
    // deterministiskt; här dokumenteras invarianten som stående kontroll.
    expect(config.nodeEnv).not.toBe('production');
  });
});
