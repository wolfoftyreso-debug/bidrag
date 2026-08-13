/**
 * Rule-change propagation (§22): publishing a new rule version marks existing
 * matches stale; recomputation reflects the new rules; submitted application
 * snapshots keep the historical rule version.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { api, createProfileAndProject, registerUser, testServer, type TestUser } from './helpers.ts';
import { db } from '../src/db/client.ts';
import { fundingOpportunities, matches, memberships } from '../src/db/schema.ts';

let app: FastifyInstance;
let curator: TestUser;
let applicant: TestUser;
let projectId: string;
let opportunityId: string;

beforeAll(async () => {
  app = await testServer();
  applicant = await registerUser(app, 'Sökande');
  curator = await registerUser(app, 'Kurator');
  // Elevate curator via DB (role management UI is a later slice).
  await db.update(memberships).set({ role: 'data_curator' }).where(eq(memberships.tenantId, curator.tenantId));

  const fixture = await createProfileAndProject(app, applicant);
  projectId = fixture.project.id;
  await api(app, applicant, 'POST', `/v1/projects/${projectId}/matches`, {});
  const [opp] = await db
    .select({ id: fundingOpportunities.id })
    .from(fundingOpportunities)
    .where(eq(fundingOpportunities.slug, 'kulturradet-internationellt-resebidrag-musik'))
    .limit(1);
  opportunityId = opp!.id;
});

afterAll(async () => {
  await app.close();
});

describe('rule versioning and staleness', () => {
  it('curator can publish a new rule version; matches become stale', async () => {
    const res = await api(app, curator, 'POST', `/v1/admin/opportunities/${opportunityId}/rule-versions`, {
      criteria: [
        {
          id: 'kr-rb-h1',
          kind: 'hard',
          factPath: 'applicant.country',
          op: 'eq',
          expected: 'SE',
          description: 'Sökande ska vara verksam i Sverige',
        },
        {
          id: 'kr-rb-m-new',
          kind: 'mandatory',
          factPath: 'project.cofinancingConfirmed',
          op: 'is_true',
          description: 'Nytt krav: bekräftad medfinansiering',
          intakeQuestion: 'Har du bekräftad medfinansiering?',
        },
      ],
      budgetRules: [],
      evidenceRequirements: [],
      changeNote: 'Programmet införde medfinansieringskrav 2026-09-01.',
    });
    expect(res.statusCode).toBe(201);

    const [match] = await db
      .select({ stale: matches.stale })
      .from(matches)
      .where(eq(matches.opportunityId, opportunityId))
      .limit(1);
    expect(match?.stale).toBe(true);
  });

  it('recomputation applies the new rules — status drops to unknown with the new question', async () => {
    await api(app, applicant, 'POST', `/v1/projects/${projectId}/matches`, {});
    const { matches: rows } = (await api(app, applicant, 'GET', `/v1/projects/${projectId}/matches`)).json() as {
      matches: { slug: string; eligibilityStatus: string; result: { missingFacts: { question: string }[] } }[];
    };
    const kr = rows.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
    expect(kr.eligibilityStatus).toBe('unknown');
    expect(kr.result.missingFacts.some((f) => f.question.includes('medfinansiering'))).toBe(true);
  });

  it('regular users cannot publish rule versions', async () => {
    const res = await api(app, applicant, 'POST', `/v1/admin/opportunities/${opportunityId}/rule-versions`, {
      criteria: [],
      changeNote: 'hack',
    });
    expect(res.statusCode).toBe(403);
  });
});
