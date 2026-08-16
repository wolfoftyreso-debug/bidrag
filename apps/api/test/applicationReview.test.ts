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
  criteria: { criterionId: string; kind: string; outcome: string; nonCompensatory: boolean; evidenceLevel: string }[];
  internalEstimate: { label: string; fitScore: number | null };
  doubleFunding: { status: string; notes: string[] };
  stateAid: { status: string; note: string };
  likelyComplementRequests: string[];
  gaps: { id: string; severity: string; area: string; message: string; requiresFactualChange: boolean }[];
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
    expect(review.gaps.filter((g) => g.severity === 'CRITICAL' || g.severity === 'HIGH'), JSON.stringify(review.gaps, null, 1)).toEqual([]);
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

  it('K1: unknown eligibility blocks the gate', async () => {
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
  });

  it('K3: a support without a digitised form is flagged openly as unverifiable coverage (§18)', async () => {
    const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string; eligibilityStatus: string }[] };
    // Arbetsstipendiet: behörig för personan men saknar digitaliserat schema.
    const noSchema = matches.find((m) => m.slug === 'konstnarsnamnden-arbetsstipendium')!;
    const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: noSchema.opportunityId });
    const idN = (created.json() as { application: { id: string } }).application.id;
    const caseRes = await api(app, user, 'GET', `/v1/applications/${idN}`);
    expect((caseRes.json() as { schema: unknown }).schema).toBeNull();
    const res = await api(app, user, 'GET', `/v1/applications/${idN}/review`);
    const review = (res.json() as { review: Review }).review;
    expect(review.gaps.some((g) => g.area === 'coverage' && g.severity === 'HIGH' && g.id === 'coverage-no-schema')).toBe(true);
    expect(review.overallStatus).toBe('NOT_READY');
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
    expect(review.gaps.filter((g) => g.severity === 'CRITICAL' || g.severity === 'HIGH'), JSON.stringify(review.gaps, null, 1)).toEqual([]);
    expect(review.overallStatus).toBe('READY_FOR_SUBMISSION');
  });

  // ── Block 2: evaluation matrix, evidensnivåer, dubbelfinansiering, diligence ──

  it('§7: every frozen criterion is assessed with outcome, non-compensatory flag and evidence level', async () => {
    const review = await getReview();
    expect(review.criteria.length).toBeGreaterThan(0);
    for (const c of review.criteria) {
      expect(['pass', 'fail', 'unknown']).toContain(c.outcome);
      expect(['E0', 'E1', 'E2']).toContain(c.evidenceLevel);
      // E0 exakt när utfallet är okänt — ett obesvarat krav är obevisat.
      expect(c.evidenceLevel === 'E0').toBe(c.outcome === 'unknown');
      expect(c.nonCompensatory).toBe(c.kind !== 'weighted');
    }
    expect(review.criteria.some((c) => c.nonCompensatory)).toBe(true);
  });

  it('§8: the internal quality score is always labeled INTERNAL_ESTIMATE, never a decision forecast', async () => {
    const review = await getReview();
    expect(review.internalEstimate.label).toBe('INTERNAL_ESTIMATE');
    expect(review.internalEstimate.fitScore).not.toBeNull();
  });

  it('§23: likely complement requests point at E1-based mandatory criteria — never hidden', async () => {
    const review = await getReview();
    // Behöriga kriterier vilar på eget svar (E1) ⇒ minst en trolig komplettering.
    expect(review.likelyComplementRequests.length).toBeGreaterThan(0);
    expect(review.likelyComplementRequests.some((r) => r.includes('E1'))).toBe(true);
  });

  it('§18: other public funding against an exclusive scheme is HIGH_RISK — and schemes that allow it stay clear', async () => {
    // Erasmus+ utesluter annan offentlig finansiering; resebidraget gör det inte.
    const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string }[] };
    const erasmus = matches.find((m) => m.slug === 'erasmus-plus-ungdomsutbyten')!;
    const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: erasmus.opportunityId });
    const idE = (created.json() as { application: { id: string } }).application.id;
    await api(app, user, 'PATCH', `/v1/applications/${idE}`, {
      financing: { requestedMinor: 1000000, ownContributionMinor: 0, otherFundingMinor: 300000, inKindMinor: 0 },
    });
    const res = await api(app, user, 'GET', `/v1/applications/${idE}/review`);
    const review = (res.json() as { review: Review }).review;
    expect(review.doubleFunding.status).toBe('HIGH_RISK');
    expect(review.gaps.some((g) => g.id === 'double-funding-excluded' && g.severity === 'HIGH' && g.requiresFactualChange)).toBe(true);
    expect(review.overallStatus).toBe('NOT_READY');

    // Resebidragets ansökan (tillåter samfinansiering) förblir READY — det är
    // stödordningens regel som styr, inte ett generiskt antagande.
    const travel = await getReview();
    expect(travel.doubleFunding.status).not.toBe('HIGH_RISK');
    expect(travel.doubleFunding.notes.join(' ')).toContain('pågående ansökan');
    expect(travel.overallStatus).toBe('READY_FOR_SUBMISSION');
  });

  // ── Block 3: E2-koppling, statsstöd, källfärskhet, schematäckning ──────────

  it('§10: criteria backed by an attached linked document reach E2 — never by guesswork', async () => {
    const review = await getReview();
    // CV och inbjudan är bifogade; de kurerade kopplingarna lyfter kriterierna till E2.
    const m1 = review.criteria.find((c) => c.criterionId === 'kr-rb-m1')!;
    const m2 = review.criteria.find((c) => c.criterionId === 'kr-rb-m2')!;
    expect(m1.evidenceLevel).toBe('E2');
    expect(m2.evidenceLevel).toBe('E2');
    // Kriterier utan kurerad koppling stannar på E1 trots bifogade dokument.
    const h1 = review.criteria.find((c) => c.criterionId === 'kr-rb-h1')!;
    expect(h1.evidenceLevel).toBe('E1');
    // Diligence pekar inte längre på E2-styrkta kriterier.
    expect(review.likelyComplementRequests.join(' ')).not.toContain('yrkesverksam inom kulturområdet');
  });

  it('§19: state aid is NOT_APPLICABLE only for personal benefits to individuals — otherwise flagged UNKNOWN', async () => {
    const review = await getReview();
    expect(review.stateAid.status).toBe('STATE_AID_UNKNOWN');
    expect(review.gaps.some((g) => g.id === 'state-aid-unknown' && g.severity === 'MEDIUM')).toBe(true);
    // MEDIUM-flaggan informerar men blockerar inte en i övrigt komplett ansökan.
    expect(review.overallStatus).toBe('READY_FOR_SUBMISSION');
  });

  it('§18: a rule source past its re-verification date is flagged', async () => {
    const { db } = await import('../src/db/client.ts');
    const { applicationCases } = await import('../src/db/schema.ts');
    const { eq } = await import('drizzle-orm');
    const [row] = await db.select().from(applicationCases).where(eq(applicationCases.id, caseId)).limit(1);
    const snapshot = row!.opportunitySnapshot as { opportunity: Record<string, unknown> };
    snapshot.opportunity.nextReviewAt = '2020-01-01T00:00:00.000Z';
    await db.update(applicationCases).set({ opportunitySnapshot: snapshot }).where(eq(applicationCases.id, caseId));

    const review = await getReview();
    expect(review.gaps.some((g) => g.id === 'source-stale')).toBe(true);

    snapshot.opportunity.nextReviewAt = new Date(Date.now() + 30 * 86_400_000).toISOString();
    await db.update(applicationCases).set({ opportunitySnapshot: snapshot }).where(eq(applicationCases.id, caseId));
  });

  it('K3 residual: the newly curated schemas exist for Nordisk kulturfond and MUCF', async () => {
    const matchesRes = await api(app, user, 'GET', `/v1/projects/${projectId}/matches`);
    const { matches } = matchesRes.json() as { matches: { slug: string; opportunityId: string }[] };
    const nordisk = matches.find((m) => m.slug === 'nordisk-kulturfond-projektstod')!;
    const created = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: nordisk.opportunityId });
    const idN = (created.json() as { application: { id: string } }).application.id;
    const caseRes = await api(app, user, 'GET', `/v1/applications/${idN}`);
    const schema = (caseRes.json() as { schema: { fields: { key: string }[] } | null }).schema;
    expect(schema).not.toBeNull();
    expect(schema!.fields.some((f) => f.key === 'nordiska_lander')).toBe(true);
    // Med schema på plats försvinner täckningsluckan för det här stödet.
    const res = await api(app, user, 'GET', `/v1/applications/${idN}/review`);
    const review = (res.json() as { review: Review }).review;
    expect(review.gaps.some((g) => g.id === 'coverage-no-schema')).toBe(false);
  });
});
