/**
 * Granskningsläget (Application Intelligence §30–31): deterministisk
 * helhetsgranskning med READY_FOR_SUBMISSION/NOT_READY och prioriterad
 * åtgärdslista. Ett obesvarat krav räknas aldrig som uppfyllt, en FAIL på
 * behörighet flaggas som något som kräver ändrade omständigheter, och en
 * komplett ansökan blir READY.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createProfileAndProject, registerUser, testServer, uploadPdf, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;
let caseId: string;

interface Review {
  overallStatus: string;
  eligibility: { status: string; missingFacts: { question: string }[] };
  evidence: { kind: string; status: string }[];
  deadline: { passed: boolean };
  gaps: { severity: string; area: string; message: string; requiresFactualChange: boolean }[];
}

async function getReview(): Promise<Review> {
  const res = await api(app, user, 'GET', `/v1/applications/${caseId}/review`);
  expect(res.statusCode).toBe(200);
  return (res.json() as { review: Review }).review;
}

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Granskaren');
  const fixture = await createProfileAndProject(app, user);
  projectId = fixture.project.id;
  await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});

  const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
  const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string }[] };
  const travel = matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
  const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: travel.opportunityId });
  caseId = (created.json() as { application: { id: string } }).application.id;
});

afterAll(async () => {
  await app.close();
});

describe('granskning inför inlämning', () => {
  it('an incomplete application is NOT_READY with prioritized gaps, worst first', async () => {
    const review = await getReview();
    expect(review.overallStatus).toBe('NOT_READY');
    expect(review.gaps.length).toBeGreaterThan(0);
    // Sorterad: ingen allvarligare lucka efter en mildare.
    const order = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];
    const indices = review.gaps.map((g) => order.indexOf(g.severity));
    expect([...indices].sort((a, b) => a - b)).toEqual(indices);
    // Obligatorisk bilaga saknas ⇒ CRITICAL (§24).
    expect(review.gaps.some((g) => g.severity === 'CRITICAL' && g.area === 'evidence')).toBe(true);
  });

  it('eligibility PASS is reported from the deterministic match, never assumed', async () => {
    const review = await getReview();
    expect(review.eligibility.status).toBe('PASS');
    expect(review.deadline.passed).toBe(false);
  });

  it('a completed application becomes READY_FOR_SUBMISSION', async () => {
    // Fyll fälten enligt schemat, bifoga obligatoriska underlag, balansera budgeten.
    const caseRes = await api(app, user, 'GET', `/v1/applications/${caseId}`);
    const { schema } = caseRes.json() as {
      schema: { fields: { key: string; type: string; required?: boolean; options?: { value: string }[] }[] } | null;
    };
    const answers: Record<string, unknown> = {};
    for (const f of schema?.fields ?? []) {
      if (!f.required) continue;
      answers[f.key] =
        f.type === 'number' || f.type === 'currency' ? 12000
        : f.type === 'percentage' ? 50
        : f.type === 'boolean' || f.type === 'declaration' ? true
        : f.type === 'date' ? '2026-10-01'
        : f.type === 'date_range' ? ['2026-10-01', '2026-10-14']
        : f.type === 'select' ? f.options?.[0]?.value ?? 'a'
        : f.type === 'multiselect' ? [f.options?.[0]?.value ?? 'a']
        : 'Ett konkret och verifierbart svar för granskningstestet.';
    }
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, { answers });

    await api(app, user, 'POST', `/v1/applications/${caseId}/budget-lines`, {
      category: 'travel', description: 'Flyg Stockholm–Kingston t/r', quantity: 2, unitCostMinor: 850000,
    });
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 },
    });

    const review1 = await getReview();
    for (const e of review1.evidence.filter((e) => e.status === 'MISSING')) {
      const up = await uploadPdf(app, user, e.kind, `bevis-${e.kind}.pdf`);
      expect(up.statusCode).toBe(201);
      const doc = (up.json() as { document: { id: string } }).document;
      const attach = await api(app, user, 'POST', `/v1/applications/${caseId}/documents`, { documentId: doc.id, role: 'evidence' });
      expect(attach.statusCode).toBe(201);
    }

    const review = await getReview();
    expect(review.gaps.filter((g) => g.severity === 'CRITICAL')).toEqual([]);
    expect(review.gaps, JSON.stringify(review.gaps, null, 1)).toEqual([]);
    expect(review.overallStatus).toBe('READY_FOR_SUBMISSION');
    expect(review.evidence.every((e) => e.status === 'ATTACHED')).toBe(true);
  });

  it('tenant isolation: another account cannot review the case', async () => {
    const stranger = await registerUser(app, 'Främling');
    const res = await api(app, stranger, 'GET', `/v1/applications/${caseId}/review`);
    expect(res.statusCode).toBe(404);
  });
});
