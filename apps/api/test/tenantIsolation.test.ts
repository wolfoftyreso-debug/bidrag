import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createProfileAndProject, registerUser, testServer, uploadPdf, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let alice: TestUser;
let mallory: TestUser;
let aliceProjectId: string;
let aliceProfileId: string;
let aliceCaseId: string;
let aliceDocumentId: string;

beforeAll(async () => {
  app = await testServer();
  alice = await registerUser(app, 'Alice');
  mallory = await registerUser(app, 'Mallory');

  const { profile, project } = await createProfileAndProject(app, alice);
  aliceProfileId = profile.id;
  aliceProjectId = project.id;

  await api(app, alice, 'POST', `/v1/projects/${aliceProjectId}/matches`, {});
  const matches = (await api(app, alice, 'GET', `/v1/projects/${aliceProjectId}/matches`)).json() as {
    matches: { opportunityId: string; slug: string }[];
  };
  const opp = matches.matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
  const caseRes = await api(app, alice, 'POST', '/v1/applications', {
    projectId: aliceProjectId,
    opportunityId: opp.opportunityId,
  });
  aliceCaseId = (caseRes.json() as { application: { id: string } }).application.id;

  const docRes = await uploadPdf(app, alice, 'cv', 'cv.pdf');
  aliceDocumentId = (docRes.json() as { document: { id: string } }).document.id;
});

afterAll(async () => {
  await app.close();
});

describe('tenant isolation (§27) — no cross-tenant access', () => {
  it('foreign project is invisible (404, not 403 — existence is not leaked)', async () => {
    const res = await api(app, mallory, 'GET', `/v1/projects/${aliceProjectId}`);
    expect(res.statusCode).toBe(404);
  });

  it('foreign project cannot be modified', async () => {
    const res = await api(app, mallory, 'PATCH', `/v1/projects/${aliceProjectId}`, { title: 'Kapad' });
    expect(res.statusCode).toBe(404);
  });

  it('foreign profile cannot be modified or referenced', async () => {
    const patch = await api(app, mallory, 'PATCH', `/v1/profiles/${aliceProfileId}`, { displayName: 'Kapad' });
    expect(patch.statusCode).toBe(404);
    // Mallory cannot create a project attached to Alice's profile.
    const create = await api(app, mallory, 'POST', '/v1/projects', {
      profileId: aliceProfileId,
      title: 'IDOR-försök',
    });
    expect(create.statusCode).toBe(404);
  });

  it('foreign application case is invisible and immutable', async () => {
    expect((await api(app, mallory, 'GET', `/v1/applications/${aliceCaseId}`)).statusCode).toBe(404);
    expect(
      (await api(app, mallory, 'PATCH', `/v1/applications/${aliceCaseId}`, { answers: { x: 'y' } })).statusCode,
    ).toBe(404);
    expect(
      (await api(app, mallory, 'POST', `/v1/applications/${aliceCaseId}/transition`, { to: 'PREPARING' })).statusCode,
    ).toBe(404);
  });

  it('foreign document cannot be downloaded, attached or deleted', async () => {
    expect((await api(app, mallory, 'GET', `/v1/documents/${aliceDocumentId}/download`)).statusCode).toBe(404);
    expect((await api(app, mallory, 'DELETE', `/v1/documents/${aliceDocumentId}`)).statusCode).toBe(404);
    // Mallory cannot attach Alice's document to anything, nor Alice's case.
    const attach = await api(app, mallory, 'POST', `/v1/applications/${aliceCaseId}/documents`, {
      documentId: aliceDocumentId,
      role: 'evidence',
    });
    expect(attach.statusCode).toBe(404);
  });

  it('foreign matches are invisible', async () => {
    const res = await api(app, mallory, 'GET', `/v1/projects/${aliceProjectId}/matches`);
    expect(res.statusCode).toBe(404);
  });

  it('list endpoints only return own-tenant data', async () => {
    const projects = (await api(app, mallory, 'GET', '/v1/projects')).json() as { projects: unknown[] };
    const applications = (await api(app, mallory, 'GET', '/v1/applications')).json() as { applications: unknown[] };
    const docs = (await api(app, mallory, 'GET', '/v1/documents')).json() as { documents: unknown[] };
    expect(projects.projects).toHaveLength(0);
    expect(applications.applications).toHaveLength(0);
    expect(docs.documents).toHaveLength(0);
  });

  it('X-Tenant-Id header cannot switch to a foreign tenant', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/v1/projects',
      headers: { cookie: mallory.cookie, 'x-tenant-id': alice.tenantId },
    });
    // Membership check fails → unauthenticated context, not Alice's data.
    expect(res.statusCode).toBe(401);
  });
});
