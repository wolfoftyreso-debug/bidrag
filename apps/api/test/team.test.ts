/**
 * Organisationssamarbete (§26–27): organisationstenants, inbjudningar med
 * hashade tokens och e-postmatchning, tenantväxling, och att medlemskap
 * ger åtkomst utan att bryta isoleringen mot utomstående.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let owner: TestUser;
let colleague: TestUser;
let outsider: TestUser;
let orgId: string;
let inviteToken: string;

function tenantApi(user: TestUser, tenantId: string, method: 'GET' | 'POST' | 'PATCH' | 'DELETE', url: string, payload?: unknown) {
  return app.inject({ method, url, payload: payload as never, headers: { cookie: user.cookie, 'x-tenant-id': tenantId } });
}

beforeAll(async () => {
  app = await testServer();
  owner = await registerUser(app, 'Ordföranden');
  colleague = await registerUser(app, 'Kassören');
  outsider = await registerUser(app, 'Utomstående');
});

afterAll(async () => {
  await app.close();
});

describe('organisationer och inbjudningar', () => {
  it('creates an organisation tenant with the creator as owner', async () => {
    const res = await api(app, owner, 'POST', '/v1/tenants', { name: 'Kulturföreningen Rytm' });
    expect(res.statusCode).toBe(201);
    orgId = (res.json() as { tenant: { id: string } }).tenant.id;

    const me = await tenantApi(owner, orgId, 'GET', '/v1/auth/me');
    const body = me.json() as { activeTenant: { id: string; role: string } };
    expect(body.activeTenant.id).toBe(orgId);
    expect(body.activeTenant.role).toBe('owner');
  });

  it('owner invites a colleague; the invite link carries a token', async () => {
    const res = await tenantApi(owner, orgId, 'POST', '/v1/tenant/invites', {
      email: colleague.email,
      role: 'contributor',
    });
    expect(res.statusCode).toBe(201);
    const { inviteUrl } = res.json() as { inviteUrl: string };
    inviteToken = inviteUrl.split('/inbjudan/')[1]!;
    expect(inviteToken.length).toBeGreaterThan(20);

    const info = await app.inject({ method: 'GET', url: `/v1/invites/${inviteToken}` });
    expect(info.statusCode).toBe(200);
    expect((info.json() as { invite: { tenantName: string } }).invite.tenantName).toBe('Kulturföreningen Rytm');
  });

  it('the owner role can never be granted via invite', async () => {
    const res = await tenantApi(owner, orgId, 'POST', '/v1/tenant/invites', { email: 'x@test.example', role: 'owner' });
    expect(res.statusCode).toBe(400); // schema enum rejects it
  });

  it('a user with the wrong email cannot accept the invite', async () => {
    const res = await api(app, outsider, 'POST', `/v1/invites/${inviteToken}/accept`);
    expect(res.statusCode).toBe(403);
    expect((res.json() as { error: string }).error).toBe('email_mismatch');
  });

  it('the invited colleague accepts and gains scoped access', async () => {
    const res = await api(app, colleague, 'POST', `/v1/invites/${inviteToken}/accept`);
    expect(res.statusCode).toBe(200);

    // Kollegan ser organisationens (tomma) projektlista via tenant-headern...
    const projects = await tenantApi(colleague, orgId, 'GET', '/v1/projects');
    expect(projects.statusCode).toBe(200);

    // ...kan skriva som contributor...
    const profile = await tenantApi(colleague, orgId, 'POST', '/v1/profiles', {
      kind: 'organisation',
      displayName: 'Föreningen',
      applicantType: 'association',
    });
    expect(profile.statusCode).toBe(201);

    // ...och medlemslistan visar båda med rätt roller.
    const members = await tenantApi(owner, orgId, 'GET', '/v1/tenant/members');
    const list = (members.json() as { members: { email: string; role: string }[] }).members;
    expect(list).toHaveLength(2);
    expect(list.find((m) => m.email === colleague.email)?.role).toBe('contributor');
  });

  it('the token is single-use and outsiders still have no access', async () => {
    expect((await api(app, colleague, 'POST', `/v1/invites/${inviteToken}/accept`)).statusCode).toBe(410);
    expect((await tenantApi(outsider, orgId, 'GET', '/v1/projects')).statusCode).toBe(401);
  });

  it('non-admin members cannot invite; revoked invites stop working', async () => {
    const denied = await tenantApi(colleague, orgId, 'POST', '/v1/tenant/invites', {
      email: 'ny@test.example',
      role: 'reviewer',
    });
    expect(denied.statusCode).toBe(403);

    const created = await tenantApi(owner, orgId, 'POST', '/v1/tenant/invites', {
      email: 'ny@test.example',
      role: 'reviewer',
    });
    const url = (created.json() as { inviteUrl: string }).inviteUrl;
    const token = url.split('/inbjudan/')[1]!;
    const listed = await tenantApi(owner, orgId, 'GET', '/v1/tenant/invites');
    const inviteId = (listed.json() as { invites: { id: string; email: string }[] }).invites.find((i) => i.email === 'ny@test.example')!.id;
    await tenantApi(owner, orgId, 'DELETE', `/v1/tenant/invites/${inviteId}`);
    expect((await app.inject({ method: 'GET', url: `/v1/invites/${token}` })).statusCode).toBe(404);
  });
});
