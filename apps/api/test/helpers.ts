import type { FastifyInstance } from 'fastify';
import { buildServer } from '../src/server.ts';
import { runMigrations } from '../src/db/migrate.ts';
import { runSeed } from '../src/seed/run.ts';

let migrated = false;

export async function testServer(): Promise<FastifyInstance> {
  if (!migrated) {
    await runMigrations();
    await runSeed();
    migrated = true;
  }
  const app = await buildServer();
  await app.ready();
  return app;
}

let userCounter = 0;

export interface TestUser {
  email: string;
  cookie: string;
  userId: string;
  tenantId: string;
}

export async function registerUser(app: FastifyInstance, name = 'Testanvändare'): Promise<TestUser> {
  const email = `user${Date.now()}-${userCounter++}@test.example`;
  const res = await app.inject({
    method: 'POST',
    url: '/v1/auth/register',
    payload: { email, password: 'mycket-sakert-losenord-123', displayName: name },
  });
  if (res.statusCode !== 201) throw new Error(`register failed: ${res.statusCode} ${res.body}`);
  const body = res.json() as { user: { id: string }; tenant: { id: string } };
  const cookies = res.cookies as { name: string; value: string }[];
  const access = cookies.find((c) => c.name === 'bidrag_access')!;
  return {
    email,
    cookie: `bidrag_access=${access.value}`,
    userId: body.user.id,
    tenantId: body.tenant.id,
  };
}

export async function api(
  app: FastifyInstance,
  user: TestUser | null,
  method: 'GET' | 'POST' | 'PATCH' | 'DELETE',
  url: string,
  payload?: unknown,
) {
  return app.inject({
    method,
    url,
    payload: payload as never,
    headers: user ? { cookie: user.cookie } : {},
  });
}

/** Lås upp analysen via mock-betalningen (testar samtidigt köpflödet). */
/**
 * Open Discovery (produktdoktrinen v2): matchningar är alltid gratis — det finns
 * ingen analysupplåsning längre. Behållen som no-op så befintliga tester som
 * förr "låste upp" innan de läste matchningar fortsätter fungera oförändrat.
 */
export async function unlockProject(_app: FastifyInstance, _user: TestUser, _projectId: string): Promise<void> {
  // no-op — resultat är fria.
}

/** Köp en ansökningskredit (19 kr/ansökan) via mock-betalningen. */
export async function payForApplication(app: FastifyInstance, user: TestUser, projectId: string): Promise<void> {
  const create = await api(app, user, 'POST', `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true });
  if (create.statusCode !== 201) throw new Error(`application purchase failed: ${create.statusCode} ${create.body}`);
  const { paymentId } = create.json() as { paymentId: string };
  const confirm = await api(app, user, 'POST', `/v1/payments/${paymentId}/mock-confirm`);
  if (confirm.statusCode !== 200) throw new Error(`mock confirm failed: ${confirm.statusCode} ${confirm.body}`);
}

/** Betala för och skapa en ansökan — standardvägen i tester som förväntar sig 201. */
export async function createApplication(app: FastifyInstance, user: TestUser, projectId: string, opportunityId: string) {
  await payForApplication(app, user, projectId);
  return api(app, user, 'POST', '/v1/applications', { projectId, opportunityId });
}

/** Standard fixture: profile + Jamaica dancehall project, analysis unlocked. */
export async function createProfileAndProject(app: FastifyInstance, user: TestUser) {
  const profileRes = await api(app, user, 'POST', '/v1/profiles', {
    kind: 'person',
    displayName: 'Dansare',
    applicantType: 'individual',
    country: 'SE',
    municipality: 'Stockholm',
    facts: { 'person.professionalArtist': true },
  });
  const profile = (profileRes.json() as { profile: { id: string } }).profile;

  const projectRes = await api(app, user, 'POST', '/v1/projects', {
    profileId: profile.id,
    title: 'Dancehall-utbyte i Jamaica',
    intent: 'Jag vill ta min dansgrupp till Jamaica.',
    totalBudgetMinor: 10_000_000,
    facts: {
      'project.hasInternationalComponent': true,
      'project.sector': 'culture',
      'project.activityTypes': ['exchange', 'training'],
      'project.targetGroups': ['youth', 'professionals'],
      'project.bringsKnowledgeBack': true,
    },
  });
  const project = (projectRes.json() as { project: { id: string } }).project;
  await unlockProject(app, user, project.id);
  return { profile, project };
}

export async function uploadPdf(app: FastifyInstance, user: TestUser, kind: string, filename: string) {
  const boundary = '----testboundary1234';
  const pdf = Buffer.from('%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<< >>\n%%EOF\n');
  const body = Buffer.concat([
    Buffer.from(
      `--${boundary}\r\nContent-Disposition: form-data; name="kind"\r\n\r\n${kind}\r\n` +
        `--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${filename}"\r\nContent-Type: application/pdf\r\n\r\n`,
    ),
    pdf,
    Buffer.from(`\r\n--${boundary}--\r\n`),
  ]);
  return app.inject({
    method: 'POST',
    url: '/v1/documents',
    headers: {
      cookie: user.cookie,
      'content-type': `multipart/form-data; boundary=${boundary}`,
    },
    payload: body,
  });
}
