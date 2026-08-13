/**
 * Full production journey (§74): individual → profile → project → matches →
 * application → validation gate → documents → ready-to-submit → assisted
 * submission → receipt → SUBMITTED → correspondence auto-match → decision.
 *
 * Also proves the no-fake-submission invariants (§54, §78).
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { api, createProfileAndProject, registerUser, testServer, uploadPdf, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let user: TestUser;
let projectId: string;
let caseId: string;
let submissionId: string;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Dansläraren');
  const fixture = await createProfileAndProject(app, user);
  projectId = fixture.project.id;
});

afterAll(async () => {
  await app.close();
});

describe('full journey — dancehall exchange to Jamaica', () => {
  it('computes explainable matches with the travel grant on top', async () => {
    const res = await api(app, user, 'POST', `/v1/projects/${projectId}/matches`, {});
    expect(res.statusCode).toBe(200);
    const { matches } = res.json() as {
      matches: { slug: string; score: number; eligibilityStatus: string; result: { explanation: unknown[]; missingFacts: unknown[] } }[];
    };
    expect(matches.length).toBeGreaterThanOrEqual(5);

    const kr = matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
    expect(kr.eligibilityStatus).toBe('eligible');
    expect(kr.score).toBeGreaterThan(70);
    expect(kr.result.explanation.length).toBeGreaterThan(0);
    // The travel grant is at (or tied for) the top of the ranking.
    expect(matches[0]!.score).toBe(kr.score);

    // Erasmus requires an organisation — an individual must be excluded, with the reason visible.
    const erasmus = matches.find((m) => m.slug === 'erasmus-plus-ungdomsutbyten')!;
    expect(erasmus.eligibilityStatus).toBe('excluded');
    expect(erasmus.score).toBe(0);
  });

  it('creates an application case with an immutable opportunity snapshot', async () => {
    const matches = (await api(app, user, 'GET', `/v1/projects/${projectId}/matches`)).json() as {
      matches: { opportunityId: string; slug: string }[];
    };
    const opp = matches.matches.find((m) => m.slug === 'kulturradet-internationellt-resebidrag-musik')!;
    const res = await api(app, user, 'POST', '/v1/applications', { projectId, opportunityId: opp.opportunityId });
    expect(res.statusCode).toBe(201);
    const { application } = res.json() as { application: { id: string; state: string; opportunitySnapshot: { opportunity: { slug: string } } } };
    caseId = application.id;
    expect(application.state).toBe('SELECTED');
    expect(application.opportunitySnapshot.opportunity.slug).toBe(opp.slug);
  });

  it('never allows jumping straight to SUBMITTED (state machine + submission flow)', async () => {
    const direct = await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'SUBMITTED' });
    expect(direct.statusCode).toBe(422); // must use the submission flow
    const invalid = await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'UNDER_REVIEW' });
    expect(invalid.statusCode).toBe(409); // invalid transition
  });

  it('blocks READY_TO_SUBMIT until the application is complete', async () => {
    await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'PREPARING' });
    await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'READY_FOR_REVIEW' });
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'READY_TO_SUBMIT' });
    expect(res.statusCode).toBe(422);
    const body = res.json() as { validation: { fieldIssues: { fieldKey: string }[]; missingAttachments: unknown[] } };
    expect(body.validation.fieldIssues.length).toBeGreaterThan(0);
  });

  it('accepts answers, enforces conditional fields, prefers user input', async () => {
    const res = await api(app, user, 'PATCH', `/v1/applications/${caseId}`, {
      answers: {
        sokande_namn: 'Dansläraren',
        sokande_verksamhet: 'Dans / dancehall',
        projekt_sammanfattning: 'Tre veckors träning och kulturutbyte i Kingston.',
        projekt_land: 'Jamaica',
        projekt_datum: ['2026-11-02', '2026-11-23'],
        har_inbjudan: true,
        inbjudan_beskrivning: 'Bekräftad inbjudan från dansstudio i Kingston.',
        aterforing: 'Workshops i Sverige våren 2027.',
        sokt_belopp: 40000,
        intygande: true,
      },
      financing: { requestedMinor: 4_000_000, ownContributionMinor: 6_000_000 },
    });
    expect(res.statusCode).toBe(200);

    const validation = (await api(app, user, 'GET', `/v1/applications/${caseId}/validate`)).json() as {
      validation: { fieldIssues: unknown[]; missingAttachments: { kind: string }[] };
    };
    expect(validation.validation.fieldIssues).toHaveLength(0);
    expect(validation.validation.missingAttachments.map((a) => a.kind).sort()).toEqual(['cv', 'invitation']);
  });

  it('uploads evidence and reaches READY_TO_SUBMIT', async () => {
    for (const kind of ['cv', 'invitation']) {
      const doc = await uploadPdf(app, user, kind, `${kind}.pdf`);
      expect(doc.statusCode).toBe(201);
      const documentId = (doc.json() as { document: { id: string } }).document.id;
      const attach = await api(app, user, 'POST', `/v1/applications/${caseId}/documents`, {
        documentId,
        role: 'evidence',
      });
      expect(attach.statusCode).toBe(201);
    }
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/transition`, { to: 'READY_TO_SUBMIT' });
    expect(res.statusCode).toBe(200);
  });

  it('assisted submission prepares a package but does NOT mark the case submitted', async () => {
    const noConfirm = await api(app, user, 'POST', `/v1/applications/${caseId}/submit`, { confirm: false });
    expect(noConfirm.statusCode).toBe(422);

    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/submit`, { confirm: true });
    expect(res.statusCode).toBe(200);
    const body = res.json() as { mode: string; submissionId: string; officialUrl: string; package: { payloadHash: string } };
    expect(body.mode).toBe('assisted');
    expect(body.officialUrl).toContain('kulturradet.se');
    expect(body.package.payloadHash).toMatch(/^[0-9a-f]{64}$/);
    submissionId = body.submissionId;

    const after = (await api(app, user, 'GET', `/v1/applications/${caseId}`)).json() as { application: { state: string } };
    expect(after.application.state).toBe('READY_TO_SUBMIT'); // NOT submitted — no fake success
  });

  it('records the receipt and only then transitions to SUBMITTED with a frozen snapshot', async () => {
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/submissions/${submissionId}/confirm-external`, {
      reference: 'KUR-2026-98765',
      note: 'Inlämnad i Kulturrådets onlinetjänst.',
    });
    expect(res.statusCode).toBe(200);
    const { application } = res.json() as { application: { state: string; submittedSnapshot: { answers: Record<string, unknown> } } };
    expect(application.state).toBe('SUBMITTED');
    expect(application.submittedSnapshot.answers['projekt_land']).toBe('Jamaica');

    // Answers are frozen after submission.
    const edit = await api(app, user, 'PATCH', `/v1/applications/${caseId}`, { answers: { projekt_land: 'Kuba' } });
    expect(edit.statusCode).toBe(409);
  });

  it('auto-matches authority correspondence via the submission reference', async () => {
    const res = await api(app, user, 'POST', '/v1/correspondence', {
      source: 'manual',
      sender: 'Kulturrådet',
      subject: 'Beslut om resebidrag',
      body: 'Kulturrådet har beviljat din ansökan. Diarienummer KUR-2026-98765.',
    });
    expect(res.statusCode).toBe(201);
    const { correspondence } = res.json() as { correspondence: { messageType: string; matchedBy: string; caseId: string } };
    expect(correspondence.messageType).toBe('award');
    expect(correspondence.matchedBy).toBe('auto');
    expect(correspondence.caseId).toBe(caseId);
  });

  it('records the decision and closes the loop AWARDED', async () => {
    const res = await api(app, user, 'POST', `/v1/applications/${caseId}/decision`, {
      outcome: 'awarded',
      amountMinor: 3_500_000,
      reference: 'KUR-2026-98765',
      decidedAt: new Date().toISOString(),
    });
    expect(res.statusCode).toBe(200);
    const { application } = res.json() as { application: { state: string } };
    expect(application.state).toBe('AWARDED');
  });

  it('canonical answers are reused in the next application (prefill with provenance)', async () => {
    const matches = (await api(app, user, 'GET', `/v1/projects/${projectId}/matches`)).json() as {
      matches: { opportunityId: string; slug: string }[];
    };
    const erasmusLike = matches.matches.find((m) => m.slug === 'erasmus-plus-ungdomsutbyten')!;
    // Even though excluded for an individual, a case can technically be drafted;
    // here we just verify the prefill machinery.
    const res = await api(app, user, 'POST', '/v1/applications', {
      projectId,
      opportunityId: erasmusLike.opportunityId,
    });
    expect(res.statusCode).toBe(201);
    const { application } = res.json() as {
      application: { answers: Record<string, unknown>; answerProvenance: Record<string, string> };
    };
    // project.summary canonical value flows into the Erasmus schema field.
    expect(application.answers['projekt_sammanfattning']).toBe('Tre veckors träning och kulturutbyte i Kingston.');
    expect(application.answerProvenance['projekt_sammanfattning']).toBe('canonical_prefill');
  });
});
