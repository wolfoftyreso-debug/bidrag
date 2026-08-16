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
        // Beloppet matchar finansieringsplanen nedan — korskontrollen K2b vaktar.
        f.type === 'currency' ? 15000
        : f.type === 'number' ? 12000
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

  // ── Revisionsfynden K1–K5 (slutrevisionen) ──────────────────────────────────

  it('K4: conflicting participant figures across fields are flagged', async () => {
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      answers: {
        projekt_sammanfattning: 'Utbytet når 500 deltagare genom öppna klasser.',
        aterforing: 'Metodiken sprids till 450 deltagare i Sverige.',
      },
    });
    const review = await getReview();
    const conflict = review.gaps.find((g) => g.area === 'consistency' && g.message.includes('deltagare'));
    expect(conflict, 'konsistenskonflikten saknas').toBeDefined();
    // Återställ.
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      answers: {
        projekt_sammanfattning: 'Residens hos Kingston Dance Collective med gemensamma föreställningar.',
        aterforing: 'Metodiken dokumenteras och delas i workshops efter hemkomst.',
      },
    });
  });

  it('K2: financing exceeding the budget blocks submission — both directions are contradictions', async () => {
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      financing: { requestedMinor: 2600000, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 },
    });
    const review = await getReview();
    expect(review.overallStatus).toBe('NOT_READY');
    expect(review.gaps.some((g) => g.area === 'budget' && g.severity === 'HIGH')).toBe(true);
    // Sökt > totalbudget är dessutom en implicit stödandel över 100 %.
    expect(review.gaps.some((g) => g.id === 'budget-requested-exceeds-total')).toBe(true);
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      financing: { requestedMinor: 1500000, ownContributionMinor: 200000, otherFundingMinor: 0, inKindMinor: 0 },
    });
  });

  it('K2b: the form amount and the financing plan must agree', async () => {
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, { answers: { sokt_belopp: 20000 } });
    const review = await getReview();
    expect(review.gaps.some((g) => g.id === 'consistency-requested-amount' && g.severity === 'HIGH')).toBe(true);
    await api(app, user, 'PATCH', `/v1/applications/${caseId}`, { answers: { sokt_belopp: 15000 } });
    const after = await getReview();
    expect(after.gaps.some((g) => g.id === 'consistency-requested-amount')).toBe(false);
  });

  it('K1+K3: unknown eligibility and missing schema both block the gate', async () => {
    const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string; eligibilityStatus: string }[] };
    const unknown = matches.find((m) => m.eligibilityStatus === 'unknown')!;
    const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: unknown.opportunityId });
    const idU = (created.json() as { application: { id: string } }).application.id;
    const res = await api(app, user, 'GET', `/v1/applications/${idU}/review`);
    const review = (res.json() as { review: Review }).review;
    expect(review.eligibility.status).toBe('UNKNOWN');
    expect(review.overallStatus).toBe('NOT_READY');
    expect(review.gaps.some((g) => g.area === 'eligibility' && g.severity === 'HIGH')).toBe(true);
    // Stödet saknar digitaliserat formulär — granskningen säger det öppet (§18).
    expect(review.gaps.some((g) => g.area === 'coverage' && g.severity === 'HIGH')).toBe(true);
  });

  it('K5: the state machine refuses READY_TO_SUBMIT on unresolved eligibility, with the review attached', async () => {
    const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string; eligibilityStatus: string }[] };
    const unknown = matches.filter((m) => m.eligibilityStatus === 'unknown')[1] ?? matches.find((m) => m.eligibilityStatus === 'unknown')!;
    const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: unknown.opportunityId });
    const idU = (created.json() as { application: { id: string } }).application.id;
    await api(app, user, 'POST', `/v1/applications/${idU}/transition`, { to: 'PREPARING' });
    await api(app, user, 'POST', `/v1/applications/${idU}/transition`, { to: 'READY_FOR_REVIEW' });
    const res = await api(app, user, 'POST', `/v1/applications/${idU}/transition`, { to: 'READY_TO_SUBMIT' });
    expect(res.statusCode).toBe(422);
    const body = res.json() as { review?: { gaps: { area: string }[] } };
    expect(body.review?.gaps.some((g) => g.area === 'eligibility')).toBe(true);
  });

  it('the complete application still passes the hardened gate', async () => {
    const review = await getReview();
    expect(review.gaps, JSON.stringify(review.gaps, null, 1)).toEqual([]);
    expect(review.overallStatus).toBe('READY_FOR_SUBMISSION');
  });
});
