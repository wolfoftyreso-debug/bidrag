/**
 * F-INGEN-ANSÖKAN (UX-genomgången 2026-09-02): ett stöd som inte kräver
 * någon ansökan (dras/registreras automatiskt) får aldrig säljas som en
 * "förberedd ansökan". API:t markerar sådana stöd (requiresApplication=false)
 * och vägrar skapa ansökan med 409 — utan att förbruka någon kredit.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createProfileAndProject, payForApplication, registerUser, testServer, type TestUser } from './helpers.ts';
import { requiresApplication } from '../src/services/applicationNeed.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Ingen ansökan');
  projectId = (await createProfileAndProject(app, user)).project.id;
});
afterAll(async () => { await app.close(); });

describe('stöd utan ansökan', () => {
  it('regeln härleds ur det kurerade ansökningssättet', () => {
    expect(requiresApplication('Ingen ansökan — säg till hos tandvården.')).toBe(false);
    expect(requiresApplication('ingen ansökan behövs')).toBe(false);
    expect(requiresApplication('Ansökan görs i Mina sidor.')).toBe(true);
    expect(requiresApplication('Ingen ansökningsavgift tas ut; ansökan görs digitalt.')).toBe(true);
    expect(requiresApplication(null)).toBe(true);
  });

  it('stödsidan markerar tandvårdsbidraget som utan ansökan, och ett vanligt stöd som med', async () => {
    const atb = await api(app, user, 'GET', '/v1/funding-opportunities/fk-tandvardsbidrag');
    expect(atb.statusCode).toBe(200);
    expect((atb.json() as { opportunity: { requiresApplication: boolean } }).opportunity.requiresApplication).toBe(false);
    const vanligt = await api(app, user, 'GET', '/v1/funding-opportunities/fk-barnbidrag');
    expect(vanligt.statusCode).toBe(200);
    expect((vanligt.json() as { opportunity: { requiresApplication: boolean } }).opportunity.requiresApplication).toBe(true);
  });

  it('vägrar skapa ansökan (409) även med betald kredit — och krediten förbrukas inte', async () => {
    const atb = (await api(app, user, 'GET', '/v1/funding-opportunities/fk-tandvardsbidrag')).json() as { opportunity: { id: string } };
    await payForApplication(app, user, projectId);
    const res = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: atb.opportunity.id });
    expect(res.statusCode).toBe(409);
    expect((res.json() as { error: string }).error).toBe('no_application_needed');
    // Krediten är kvar: samma projekt kan förbereda ett vanligt stöd utan nytt köp.
    const bb = (await api(app, user, 'GET', '/v1/funding-opportunities/fk-barnbidrag')).json() as { opportunity: { id: string } };
    const ok = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: bb.opportunity.id });
    expect(ok.statusCode).toBe(201);
  });
});
