import type { FastifyInstance } from 'fastify';
import { and, desc, eq, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { applicationCases, correspondenceEvents, fundingOpportunities, submissionReceipts, submissions } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';

/**
 * Unified funding inbox (§17, §48). Sources: uploads, manual entries, and —
 * where authorised integrations exist — email/digital post connectors.
 * Never stores external portal credentials.
 */

/** Simple deterministic classifier over Swedish decision vocabulary; low-confidence results go to human review. */
export function classifyMessage(subject: string, body: string): { messageType: string; confidence: 'low' | 'medium' | 'high' } {
  const text = `${subject}\n${body}`.toLowerCase();
  const rules: [RegExp, string][] = [
    [/beviljat|beviljas|beviljar|bifall|tilldelas|tilldelning/, 'award'],
    [/avslag|avslås|avslagit|beviljas inte/, 'rejection'],
    [/komplettering|komplettera|saknas följande|inkom med/, 'clarification_request'],
    [/utbetalning|utbetalas|rekvisition/, 'payment_notice'],
    [/redovisning|slutrapport|delrapport|återrapport/, 'reporting_request'],
    [/förlängd|förlängning av|ny ansökningstid/, 'deadline_extension'],
    [/mottagit din ansökan|bekräftelse|diarienummer|ärendenummer/, 'acknowledgement'],
    [/beslut/, 'decision'],
  ];
  for (const [re, type] of rules) {
    if (re.test(text)) return { messageType: type, confidence: 'medium' };
  }
  return { messageType: 'other', confidence: 'low' };
}

/**
 * Try to auto-match a message to a case. Strongest signal first: a known
 * submission reference (diarienummer) appearing in the text; then the
 * opportunity title. Unmatched messages stay visible for human assignment.
 */
async function autoMatchCase(tenantId: string, subject: string, body: string): Promise<string | null> {
  const text = `${subject}\n${body}`.toLowerCase();

  const receipts = await db
    .select({ reference: submissionReceipts.reference, caseId: submissions.caseId })
    .from(submissionReceipts)
    .innerJoin(submissions, eq(submissionReceipts.submissionId, submissions.id))
    .where(eq(submissionReceipts.tenantId, tenantId));
  const refHit = receipts.find((r) => r.reference.length >= 5 && text.includes(r.reference.toLowerCase()));
  if (refHit) return refHit.caseId;

  const cases = await db
    .select({
      id: applicationCases.id,
      state: applicationCases.state,
      title: fundingOpportunities.title,
    })
    .from(applicationCases)
    .innerJoin(fundingOpportunities, eq(applicationCases.opportunityId, fundingOpportunities.id))
    .where(
      and(
        eq(applicationCases.tenantId, tenantId),
        sql`${applicationCases.state} IN ('SUBMITTED','ACKNOWLEDGED','UNDER_REVIEW','ACTION_REQUIRED','DECISION_RECEIVED','AWARDED')`,
      ),
    );
  const hit = cases.find((c) => c.title && text.includes(c.title.toLowerCase()));
  return hit?.id ?? null;
}

export async function correspondenceRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get(
    '/v1/correspondence',
    {
      schema: {
        tags: ['correspondence'],
        querystring: {
          type: 'object',
          properties: { caseId: { type: 'string', format: 'uuid' } },
          additionalProperties: false,
        },
      },
    },
    async (request) => {
      const { caseId } = request.query as { caseId?: string };
      const conditions = [eq(correspondenceEvents.tenantId, request.auth!.tenantId)];
      if (caseId) conditions.push(eq(correspondenceEvents.caseId, caseId));
      const rows = await db
        .select()
        .from(correspondenceEvents)
        .where(and(...conditions))
        .orderBy(desc(correspondenceEvents.receivedAt))
        .limit(200);
      return { correspondence: rows };
    },
  );

  /** Register an incoming message (manual entry or forwarded/uploaded letter). */
  app.post(
    '/v1/correspondence',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['correspondence'],
        body: {
          type: 'object',
          required: ['source', 'subject'],
          properties: {
            source: { type: 'string', enum: ['email', 'upload', 'manual', 'digital_post'] },
            sender: { type: 'string', maxLength: 320 },
            subject: { type: 'string', minLength: 1, maxLength: 500 },
            body: { type: 'string', maxLength: 50000 },
            caseId: { type: 'string', format: 'uuid', nullable: true },
            documentId: { type: 'string', format: 'uuid', nullable: true },
            receivedAt: { type: 'string', format: 'date-time', nullable: true },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const tenantId = request.auth!.tenantId;
      const b = request.body as {
        source: 'email' | 'upload' | 'manual' | 'digital_post';
        sender?: string;
        subject: string;
        body?: string;
        caseId?: string;
        documentId?: string;
        receivedAt?: string;
      };

      if (b.caseId) {
        const [c] = await db
          .select({ id: applicationCases.id })
          .from(applicationCases)
          .where(and(eq(applicationCases.id, b.caseId), eq(applicationCases.tenantId, tenantId)))
          .limit(1);
        if (!c) return reply.code(404).send({ error: 'case_not_found' });
      }

      const classification = classifyMessage(b.subject, b.body ?? '');
      const matchedCaseId = b.caseId ?? (await autoMatchCase(tenantId, b.subject, b.body ?? ''));

      const [row] = await db
        .insert(correspondenceEvents)
        .values({
          tenantId,
          caseId: matchedCaseId,
          source: b.source,
          direction: 'inbound',
          sender: b.sender ?? '',
          subject: b.subject,
          body: b.body ?? '',
          messageType: classification.messageType as never,
          confidence: classification.confidence,
          matchedBy: b.caseId ? 'human' : matchedCaseId ? 'auto' : 'unmatched',
          documentId: b.documentId ?? null,
          receivedAt: b.receivedAt ? new Date(b.receivedAt) : new Date(),
        })
        .returning();

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'correspondence.registered',
        entityType: 'correspondence_event',
        entityId: row!.id,
        after: { messageType: row!.messageType, matchedBy: row!.matchedBy },
      });

      return reply.code(201).send({ correspondence: row });
    },
  );

  /** Human override of an automatic match or classification. */
  app.patch(
    '/v1/correspondence/:id',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['correspondence'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          properties: {
            caseId: { type: 'string', format: 'uuid', nullable: true },
            messageType: { type: 'string', maxLength: 50 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [before] = await db
        .select()
        .from(correspondenceEvents)
        .where(and(eq(correspondenceEvents.id, id), eq(correspondenceEvents.tenantId, tenantId)))
        .limit(1);
      if (!before) return reply.code(404).send({ error: 'not_found' });

      const b = request.body as { caseId?: string | null; messageType?: string };
      const patch: Record<string, unknown> = {};
      if (b.caseId !== undefined) {
        if (b.caseId) {
          const [c] = await db
            .select({ id: applicationCases.id })
            .from(applicationCases)
            .where(and(eq(applicationCases.id, b.caseId), eq(applicationCases.tenantId, tenantId)))
            .limit(1);
          if (!c) return reply.code(404).send({ error: 'case_not_found' });
        }
        patch.caseId = b.caseId;
        patch.matchedBy = 'human';
      }
      if (b.messageType !== undefined) {
        patch.messageType = b.messageType;
        patch.confidence = 'high';
      }

      const [after] = await db
        .update(correspondenceEvents)
        .set(patch)
        .where(and(eq(correspondenceEvents.id, id), eq(correspondenceEvents.tenantId, tenantId)))
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'correspondence.reclassified',
        entityType: 'correspondence_event',
        entityId: id,
        before: { caseId: before.caseId, messageType: before.messageType },
        after: { caseId: after!.caseId, messageType: after!.messageType },
      });
      return { correspondence: after };
    },
  );
}
