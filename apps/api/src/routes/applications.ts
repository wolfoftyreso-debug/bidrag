import type { FastifyInstance } from 'fastify';
import { and, desc, eq } from 'drizzle-orm';
import { InvalidTransitionError, type ApplicationState } from '@bidrag/core';
import { db } from '../db/client.ts';
import {
  applicationCases,
  budgetLines,
  caseDocuments,
  decisions,
  documents,
  fundingOpportunities,
  projects,
  reportingRequirements,
  submissionReceipts,
  submissions,
} from '../db/schema.ts';
import { audit } from '../audit.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';
import { createCase, getCaseSchema, reviewCase, saveAnswers, transitionCase, validateCase } from '../services/applications.ts';
import { findAdapter, hashPayload, type SubmissionPayload } from '../services/submission.ts';

const uuidParam = {
  type: 'object',
  properties: { id: { type: 'string', format: 'uuid' } },
  required: ['id'],
} as const;

async function loadCase(tenantId: string, id: string) {
  const [row] = await db
    .select()
    .from(applicationCases)
    .where(and(eq(applicationCases.id, id), eq(applicationCases.tenantId, tenantId)))
    .limit(1);
  return row;
}

export async function applicationRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get('/v1/applications', { schema: { tags: ['applications'] } }, async (request) => {
    const rows = await db
      .select({
        id: applicationCases.id,
        state: applicationCases.state,
        deadlineAt: applicationCases.deadlineAt,
        createdAt: applicationCases.createdAt,
        updatedAt: applicationCases.updatedAt,
        projectId: applicationCases.projectId,
        opportunityId: applicationCases.opportunityId,
        opportunityTitle: fundingOpportunities.title,
        opportunitySlug: fundingOpportunities.slug,
        instrumentType: fundingOpportunities.instrumentType,
        projectTitle: projects.title,
      })
      .from(applicationCases)
      .innerJoin(fundingOpportunities, eq(applicationCases.opportunityId, fundingOpportunities.id))
      .innerJoin(projects, eq(applicationCases.projectId, projects.id))
      .where(eq(applicationCases.tenantId, request.auth!.tenantId))
      .orderBy(desc(applicationCases.updatedAt));
    return { applications: rows };
  });

  app.post(
    '/v1/applications',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        body: {
          type: 'object',
          required: ['projectId', 'opportunityId'],
          properties: {
            projectId: { type: 'string', format: 'uuid' },
            opportunityId: { type: 'string', format: 'uuid' },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { projectId, opportunityId } = request.body as { projectId: string; opportunityId: string };
      const tenantId = request.auth!.tenantId;
      const [project] = await db
        .select({ id: projects.id })
        .from(projects)
        .where(and(eq(projects.id, projectId), eq(projects.tenantId, tenantId)))
        .limit(1);
      if (!project) return reply.code(404).send({ error: 'project_not_found' });

      try {
        const row = await createCase({ tenantId, userId: request.auth!.userId, projectId, opportunityId });
        return reply.code(201).send({ application: row });
      } catch (err) {
        const status = (err as { statusCode?: number }).statusCode;
        if (status) return reply.code(status).send({ error: (err as Error).message });
        throw err;
      }
    },
  );

  app.get('/v1/applications/:id', { schema: { tags: ['applications'], params: uuidParam } }, async (request, reply) => {
    const caseRow = await loadCase(request.auth!.tenantId, (request.params as { id: string }).id);
    if (!caseRow) return reply.code(404).send({ error: 'not_found' });

    const schema = await getCaseSchema(caseRow);
    const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, caseRow.id));
    const docs = await db
      .select({
        linkId: caseDocuments.id,
        role: caseDocuments.role,
        fieldKey: caseDocuments.fieldKey,
        documentId: documents.id,
        filename: documents.filename,
        kind: documents.kind,
        sizeBytes: documents.sizeBytes,
        scanStatus: documents.scanStatus,
        createdAt: documents.createdAt,
      })
      .from(caseDocuments)
      .innerJoin(documents, eq(caseDocuments.documentId, documents.id))
      .where(eq(caseDocuments.caseId, caseRow.id));
    const subs = await db.select().from(submissions).where(eq(submissions.caseId, caseRow.id)).orderBy(desc(submissions.startedAt));
    const decisionRows = await db.select().from(decisions).where(eq(decisions.caseId, caseRow.id));
    const reporting = await db.select().from(reportingRequirements).where(eq(reportingRequirements.caseId, caseRow.id));
    const validation = await validateCase(caseRow);

    return {
      application: caseRow,
      schema,
      budgetLines: lines,
      documents: docs,
      submissions: subs,
      decisions: decisionRows,
      reportingRequirements: reporting,
      validation,
    };
  });

  app.patch(
    '/v1/applications/:id',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          properties: {
            answers: { type: 'object', additionalProperties: true },
            financing: {
              type: 'object',
              properties: {
                requestedMinor: { type: 'integer', minimum: 0 },
                ownContributionMinor: { type: 'integer', minimum: 0 },
                otherFundingMinor: { type: 'integer', minimum: 0 },
                inKindMinor: { type: 'integer', minimum: 0 },
              },
              additionalProperties: false,
            },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const body = request.body as { answers?: Record<string, unknown>; financing?: Record<string, number> };
      try {
        let row = await loadCase(tenantId, id);
        if (!row) return reply.code(404).send({ error: 'not_found' });
        if (body.answers) {
          row = await saveAnswers({ tenantId, userId: request.auth!.userId, caseId: id, answers: body.answers as never });
        }
        if (body.financing) {
          const [updated] = await db
            .update(applicationCases)
            .set({ financing: { requestedMinor: 0, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0, ...body.financing }, updatedAt: new Date() })
            .where(and(eq(applicationCases.id, id), eq(applicationCases.tenantId, tenantId)))
            .returning();
          row = updated!;
        }
        return { application: row };
      } catch (err) {
        const status = (err as { statusCode?: number }).statusCode;
        if (status) return reply.code(status).send({ error: (err as Error).message });
        throw err;
      }
    },
  );

  app.post(
    '/v1/applications/:id/transition',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['to'],
          properties: { to: { type: 'string', maxLength: 30 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const { to } = request.body as { to: ApplicationState };

      // Submission states are never reachable through the generic transition
      // endpoint — only through the dedicated submission flow with evidence.
      if (to === 'SUBMITTING' || to === 'SUBMITTED') {
        return reply.code(422).send({
          error: 'use_submission_flow',
          message: 'Inlämning görs via /submit-flödet så att kvitto och bekräftelse registreras.',
        });
      }

      try {
        const row = await transitionCase({
          tenantId: request.auth!.tenantId,
          userId: request.auth!.userId,
          actorType: 'user',
          caseId: id,
          to,
        });
        return { application: row };
      } catch (err) {
        if (err instanceof InvalidTransitionError) {
          return reply.code(409).send({ error: 'invalid_transition', message: err.message });
        }
        const status = (err as { statusCode?: number }).statusCode;
        if (status === 422) {
          return reply.code(422).send({
            error: 'not_ready',
            message: 'Ansökan är inte komplett.',
            validation: (err as { validation?: unknown }).validation,
          });
        }
        if (status) return reply.code(status).send({ error: (err as Error).message });
        throw err;
      }
    },
  );

  app.get('/v1/applications/:id/validate', { schema: { tags: ['applications'], params: uuidParam } }, async (request, reply) => {
    const caseRow = await loadCase(request.auth!.tenantId, (request.params as { id: string }).id);
    if (!caseRow) return reply.code(404).send({ error: 'not_found' });
    return { validation: await validateCase(caseRow) };
  });

  /**
   * Granskningsläget (Application Intelligence §30–31): deterministisk
   * helhetsgranskning — behörighet, fält, bevisning, budget, deadline —
   * med READY_FOR_SUBMISSION/NOT_READY och prioriterad åtgärdslista.
   */
  app.get('/v1/applications/:id/review', { schema: { tags: ['applications'], params: uuidParam } }, async (request, reply) => {
    const caseRow = await loadCase(request.auth!.tenantId, (request.params as { id: string }).id);
    if (!caseRow) return reply.code(404).send({ error: 'not_found' });
    return { review: await reviewCase(caseRow) };
  });

  // ── Budget lines ────────────────────────────────────────────────────────────

  app.post(
    '/v1/applications/:id/budget-lines',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['category', 'description', 'quantity', 'unitCostMinor'],
          properties: {
            category: { type: 'string', minLength: 1, maxLength: 50 },
            description: { type: 'string', minLength: 1, maxLength: 500 },
            quantity: { type: 'integer', minimum: 1 },
            unitCostMinor: { type: 'integer', minimum: 0 },
            currency: { type: 'string', minLength: 3, maxLength: 3 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const caseRow = await loadCase(tenantId, id);
      if (!caseRow) return reply.code(404).send({ error: 'not_found' });
      const body = request.body as { category: string; description: string; quantity: number; unitCostMinor: number; currency?: string };
      const [line] = await db
        .insert(budgetLines)
        .values({ tenantId, caseId: id, ...body, currency: body.currency ?? 'SEK' })
        .returning();
      return reply.code(201).send({ budgetLine: line });
    },
  );

  app.delete(
    '/v1/applications/:id/budget-lines/:lineId',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: {
          type: 'object',
          properties: { id: { type: 'string', format: 'uuid' }, lineId: { type: 'string', format: 'uuid' } },
          required: ['id', 'lineId'],
        },
      },
    },
    async (request, reply) => {
      const { id, lineId } = request.params as { id: string; lineId: string };
      const tenantId = request.auth!.tenantId;
      const result = await db
        .delete(budgetLines)
        .where(and(eq(budgetLines.id, lineId), eq(budgetLines.caseId, id), eq(budgetLines.tenantId, tenantId)))
        .returning({ id: budgetLines.id });
      if (result.length === 0) return reply.code(404).send({ error: 'not_found' });
      return { ok: true };
    },
  );

  // ── Attach documents ────────────────────────────────────────────────────────

  app.post(
    '/v1/applications/:id/documents',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['documentId', 'role'],
          properties: {
            documentId: { type: 'string', format: 'uuid' },
            role: { type: 'string', enum: ['attachment', 'evidence', 'receipt', 'decision', 'correspondence'] },
            fieldKey: { type: 'string', maxLength: 200, nullable: true },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const caseRow = await loadCase(tenantId, id);
      if (!caseRow) return reply.code(404).send({ error: 'not_found' });
      const { documentId, role, fieldKey } = request.body as { documentId: string; role: string; fieldKey?: string };
      const [doc] = await db
        .select({ id: documents.id, scanStatus: documents.scanStatus })
        .from(documents)
        .where(and(eq(documents.id, documentId), eq(documents.tenantId, tenantId)))
        .limit(1);
      if (!doc) return reply.code(404).send({ error: 'document_not_found' });
      if (doc.scanStatus === 'blocked') {
        return reply.code(422).send({ error: 'document_blocked', message: 'Dokumentet stoppades av säkerhetskontrollen.' });
      }
      const [link] = await db
        .insert(caseDocuments)
        .values({ tenantId, caseId: id, documentId, role: role as never, fieldKey: fieldKey ?? null })
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'application.document_attached',
        entityType: 'application_case',
        entityId: id,
        after: { documentId, role },
      });
      return reply.code(201).send({ link });
    },
  );

  // ── Submission flow (§46) ───────────────────────────────────────────────────

  /**
   * Step 1: prepare submission. Validates everything, shows exactly what will
   * be sent and to which authority, and requires explicit confirmation.
   */
  app.post(
    '/v1/applications/:id/submit',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['confirm'],
          properties: { confirm: { type: 'boolean' } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const { confirm } = request.body as { confirm: boolean };
      const tenantId = request.auth!.tenantId;

      const caseRow = await loadCase(tenantId, id);
      if (!caseRow) return reply.code(404).send({ error: 'not_found' });
      if (caseRow.state !== 'READY_TO_SUBMIT') {
        return reply.code(409).send({
          error: 'wrong_state',
          message: 'Ansökan måste vara i läget "Klar att skicka in" innan den kan lämnas in.',
        });
      }
      const validation = await validateCase(caseRow);
      if (!validation.ready) {
        return reply.code(422).send({ error: 'not_ready', validation });
      }
      if (!confirm) {
        return reply.code(422).send({ error: 'confirmation_required', message: 'Du måste bekräfta inlämningen.' });
      }

      const snapshot = caseRow.opportunitySnapshot as { opportunity: { slug: string; title: string; applicationUrl: string | null; applicationMethod: string; submissionLevel: string } };
      const opp = snapshot.opportunity;

      const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, id));
      const attachments = await db
        .select({ documentId: documents.id, filename: documents.filename, sha256: documents.sha256 })
        .from(caseDocuments)
        .innerJoin(documents, eq(caseDocuments.documentId, documents.id))
        .where(eq(caseDocuments.caseId, id));

      const payload: SubmissionPayload = {
        caseId: id,
        opportunitySlug: opp.slug,
        answers: caseRow.answers as Record<string, unknown>,
        budgetLines: lines,
        financing: caseRow.financing,
        attachments,
      };
      const payloadHash = hashPayload(payload);

      const adapter = findAdapter(opp.slug);

      if (adapter) {
        // Native/structured: transition to SUBMITTING, run adapter, then
        // SUBMITTED only on verified confirmation — otherwise fall back.
        await transitionCase({ tenantId, userId: request.auth!.userId, actorType: 'user', caseId: id, to: 'SUBMITTING' });
        const [sub] = await db
          .insert(submissions)
          .values({ tenantId, caseId: id, level: adapter.level, state: 'in_progress', payloadHash, destination: opp.title })
          .returning();
        const result = await adapter.submit(payload);
        if (result.ok && result.confirmationReference) {
          await db
            .update(submissions)
            .set({ state: 'succeeded', completedAt: new Date() })
            .where(eq(submissions.id, sub!.id));
          await db.insert(submissionReceipts).values({
            tenantId,
            submissionId: sub!.id,
            kind: 'adapter_confirmation',
            reference: result.confirmationReference,
          });
          const updated = await transitionCase({
            tenantId,
            userId: request.auth!.userId,
            actorType: 'system',
            caseId: id,
            to: 'SUBMITTED',
            context: { submissionId: sub!.id, reference: result.confirmationReference },
          });
          return { mode: adapter.level, application: updated, submissionId: sub!.id, reference: result.confirmationReference };
        }
        // Fail safely and visibly — never fake success.
        await db
          .update(submissions)
          .set({ state: 'failed', completedAt: new Date(), error: result.error ?? 'unknown adapter error' })
          .where(eq(submissions.id, sub!.id));
        const reverted = await transitionCase({
          tenantId,
          userId: request.auth!.userId,
          actorType: 'system',
          caseId: id,
          to: 'READY_TO_SUBMIT',
          context: { submissionId: sub!.id, error: result.error },
        });
        return reply.code(502).send({
          error: 'submission_failed',
          message: 'Inlämningen misslyckades hos mottagaren. Ansökan är kvar i "Klar att skicka in" och inga uppgifter gick förlorade.',
          application: reverted,
        });
      }

      // Assisted submission: prepare the package; the user completes the
      // official submission and records the receipt (§16 level 3, §54).
      const [sub] = await db
        .insert(submissions)
        .values({ tenantId, caseId: id, level: 'assisted', state: 'pending', payloadHash, destination: opp.title })
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'application.assisted_submission_prepared',
        entityType: 'submission',
        entityId: sub!.id,
        after: { payloadHash },
      });
      return {
        mode: 'assisted',
        submissionId: sub!.id,
        message:
          'Förberedelsen är klar — den slutliga inlämningen görs i myndighetens officiella ansökningstjänst. Registrera ditt kvitto här efteråt.',
        officialUrl: opp.applicationUrl,
        applicationMethod: opp.applicationMethod,
        package: {
          answers: caseRow.answers,
          budgetLines: lines,
          financing: caseRow.financing,
          attachments,
          payloadHash,
        },
      };
    },
  );

  /**
   * Step 2 (assisted only): the user confirms they completed the official
   * submission and records the receipt. Only then does the case become SUBMITTED.
   */
  app.post(
    '/v1/applications/:id/submissions/:submissionId/confirm-external',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: {
          type: 'object',
          properties: { id: { type: 'string', format: 'uuid' }, submissionId: { type: 'string', format: 'uuid' } },
          required: ['id', 'submissionId'],
        },
        body: {
          type: 'object',
          required: ['reference'],
          properties: {
            reference: { type: 'string', minLength: 1, maxLength: 500 },
            note: { type: 'string', maxLength: 2000 },
            receiptDocumentId: { type: 'string', format: 'uuid', nullable: true },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id, submissionId } = request.params as { id: string; submissionId: string };
      const tenantId = request.auth!.tenantId;
      const { reference, note, receiptDocumentId } = request.body as {
        reference: string;
        note?: string;
        receiptDocumentId?: string;
      };

      const [sub] = await db
        .select()
        .from(submissions)
        .where(and(eq(submissions.id, submissionId), eq(submissions.caseId, id), eq(submissions.tenantId, tenantId)))
        .limit(1);
      if (!sub) return reply.code(404).send({ error: 'not_found' });
      if (sub.level !== 'assisted' || sub.state !== 'pending') {
        return reply.code(409).send({ error: 'wrong_submission_state' });
      }
      if (receiptDocumentId) {
        const [doc] = await db
          .select({ id: documents.id })
          .from(documents)
          .where(and(eq(documents.id, receiptDocumentId), eq(documents.tenantId, tenantId)))
          .limit(1);
        if (!doc) return reply.code(404).send({ error: 'document_not_found' });
      }

      await db
        .update(submissions)
        .set({ state: 'user_confirmed', completedAt: new Date() })
        .where(eq(submissions.id, submissionId));
      await db.insert(submissionReceipts).values({
        tenantId,
        submissionId,
        kind: 'user_receipt',
        reference,
        note: note ?? '',
        documentId: receiptDocumentId ?? null,
      });

      const updated = await transitionCase({
        tenantId,
        userId: request.auth!.userId,
        actorType: 'user',
        caseId: id,
        to: 'SUBMITTED',
        context: { submissionId, reference, mode: 'assisted_user_confirmed' },
      });
      return { application: updated };
    },
  );

  // ── Decisions (recorded from correspondence or manually) ────────────────────

  app.post(
    '/v1/applications/:id/decision',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['outcome', 'decidedAt'],
          properties: {
            outcome: { type: 'string', enum: ['awarded', 'partially_awarded', 'rejected'] },
            amountMinor: { type: 'integer', minimum: 0, nullable: true },
            reference: { type: 'string', maxLength: 200 },
            decidedAt: { type: 'string', format: 'date-time' },
            note: { type: 'string', maxLength: 2000 },
            documentId: { type: 'string', format: 'uuid', nullable: true },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const caseRow = await loadCase(tenantId, id);
      if (!caseRow) return reply.code(404).send({ error: 'not_found' });

      const body = request.body as {
        outcome: 'awarded' | 'partially_awarded' | 'rejected';
        amountMinor?: number;
        reference?: string;
        decidedAt: string;
        note?: string;
        documentId?: string;
      };

      // Record the decision first, then walk the state machine.
      const [decision] = await db
        .insert(decisions)
        .values({
          tenantId,
          caseId: id,
          outcome: body.outcome,
          amountMinor: body.amountMinor ?? null,
          reference: body.reference ?? '',
          decidedAt: new Date(body.decidedAt),
          note: body.note ?? '',
          documentId: body.documentId ?? null,
        })
        .returning();

      try {
        let row = caseRow;
        if (row.state !== 'DECISION_RECEIVED') {
          row = await transitionCase({ tenantId, userId: request.auth!.userId, actorType: 'user', caseId: id, to: 'DECISION_RECEIVED', context: { decisionId: decision!.id } });
        }
        const finalState = body.outcome === 'rejected' ? 'REJECTED' : 'AWARDED';
        row = await transitionCase({ tenantId, userId: request.auth!.userId, actorType: 'user', caseId: id, to: finalState, context: { decisionId: decision!.id } });
        return { application: row, decision };
      } catch (err) {
        if (err instanceof InvalidTransitionError) {
          return reply.code(409).send({ error: 'invalid_transition', message: err.message, decision });
        }
        throw err;
      }
    },
  );

  // ── Reporting obligations (§49) ─────────────────────────────────────────────

  app.post(
    '/v1/applications/:id/reporting-requirements',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['applications'],
        params: uuidParam,
        body: {
          type: 'object',
          required: ['title'],
          properties: {
            title: { type: 'string', minLength: 1, maxLength: 300 },
            dueAt: { type: 'string', format: 'date-time', nullable: true },
            note: { type: 'string', maxLength: 2000 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const caseRow = await loadCase(tenantId, id);
      if (!caseRow) return reply.code(404).send({ error: 'not_found' });
      const body = request.body as { title: string; dueAt?: string; note?: string };
      const [row] = await db
        .insert(reportingRequirements)
        .values({ tenantId, caseId: id, title: body.title, dueAt: body.dueAt ? new Date(body.dueAt) : null, note: body.note ?? '' })
        .returning();
      return reply.code(201).send({ reportingRequirement: row });
    },
  );
}
