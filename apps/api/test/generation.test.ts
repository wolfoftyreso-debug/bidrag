/**
 * Generation mode-skalet (AI-spec §32): förslag-och-godkänn bakom
 * deterministiska vakter. Mockprovidern är aktiv i test — det som bevisas här
 * är ARKITEKTUREN: tomt underlag vägras, uppfunna siffror avvisas maskinellt,
 * ingenting sparas utan sökandens egen PATCH, allt spårloggas.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createApplication, createProfileAndProject, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let caseId: string;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Generationstestaren');
  const fixture = await createProfileAndProject(app, user);
  await api(app, user, 'POST', `/v1/projects/${fixture.project.id}/matches`, {});
  const matchesRes = await api(app, user, 'GET', `/v1/projects/${fixture.project.id}/matches`);
  const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string }[] };
  const travel = matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
  const created = await createApplication(app, user, fixture.project.id, travel.opportunityId);
  caseId = (created.json() as { application: { id: string } }).application.id;
});

afterAll(async () => {
  await app.close();
});

describe('generation mode — förslag-och-godkänn bakom vakter', () => {
  it('exposes availability and refuses to generate from an empty field (§5)', async () => {
    const detail = await api(app, user, 'GET', `/v1/applications/${caseId}`);
    expect((detail.json() as { generationAvailable: boolean }).generationAvailable).toBe(true);

    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/suggest-field`, { fieldKey: 'projekt_sammanfattning' });
    expect(res.statusCode).toBe(422);
    expect((res.json() as { error: string }).error).toBe('nothing_to_improve');
  });

  it('suggests an improvement, saves NOTHING, and leaves acceptance to the applicant', async () => {
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      answers: { projekt_sammanfattning: 'Residenset i Kingston är  jättebra för min konstnärliga utveckling.' },
    });
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/suggest-field`, { fieldKey: 'projekt_sammanfattning' });
    expect(res.statusCode).toBe(200);
    const body = res.json() as { before: string; suggestion: string; reason: string };
    expect(body.suggestion).toContain('väl fungerande'); // mockens kända ordbyte
    expect(body.suggestion).not.toContain('jättebra');
    expect(body.reason.length).toBeGreaterThan(10); // §32: REASON är obligatoriskt

    // Ingenting sparat: svaret är orört tills sökanden själv PATCH:ar.
    const detail = await api(app, user, 'GET', `/v1/applications/${caseId}`);
    const answers = (detail.json() as { application: { answers: Record<string, string> } }).application.answers;
    expect(answers.projekt_sammanfattning).toContain('jättebra');
  });

  it('the guards reject a suggestion that invents a number — it is never shown (§25)', async () => {
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      answers: { projekt_sammanfattning: 'Residenset stärker min konstnärliga utveckling. [[MOCK-INVENT]]' },
    });
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/suggest-field`, { fieldKey: 'projekt_sammanfattning' });
    expect(res.statusCode).toBe(422);
    const body = res.json() as { error: string; findings: { kind: string; detail: string }[]; suggestion?: string };
    expect(body.error).toBe('suggestion_rejected_by_guards');
    expect(body.findings.some((f) => f.kind === 'INVENTED_NUMBER' && f.detail === '9999')).toBe(true);
    expect(body.suggestion).toBeUndefined(); // det avvisade förslaget läcker aldrig
  });

  it('refuses non-text fields and enforces tenant isolation', async () => {
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/suggest-field`, { fieldKey: 'sokt_belopp' });
    expect(res.statusCode).toBe(422);
    const stranger = await registerUser(app, 'Främling');
    const foreign = await api(app, stranger, 'POST', `/v1/applications/${caseId}/suggest-field`, { fieldKey: 'projekt_sammanfattning' });
    expect(foreign.statusCode).toBe(404);
  });
});
