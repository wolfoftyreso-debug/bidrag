/**
 * Application case service: creation with immutable opportunity snapshots,
 * validation (schema + budget + attachments), and guarded state transitions
 * with audit logging.
 */
import { and, eq, sql } from 'drizzle-orm';
import {
  assertTransition,
  prefillFromCanonical,
  validateAnswers,
  validateBudget,
  type Answers,
  type AnswerValue,
  type ApplicationSchemaDef,
  type ApplicationState,
  type BudgetFinancing,
  type BudgetLine,
  type BudgetRule,
  type EvidenceRequirement,
  type FieldValidationIssue,
} from '@bidrag/core';
import { db } from '../db/client.ts';
import {
  applicationCases,
  applicationSchemas,
  budgetLines,
  canonicalAnswers,
  caseDocuments,
  documents,
  fundingOpportunities,
  ruleVersions,
} from '../db/schema.ts';
import { audit } from '../audit.ts';

export interface CaseValidation {
  fieldIssues: FieldValidationIssue[];
  budgetFindings: { ruleId: string; severity: string; message: string }[];
  missingAttachments: { kind: string; description: string }[];
  ready: boolean;
}

export async function createCase(opts: {
  tenantId: string;
  userId: string;
  projectId: string;
  opportunityId: string;
}): Promise<typeof applicationCases.$inferSelect> {
  const [opp] = await db
    .select()
    .from(fundingOpportunities)
    .where(eq(fundingOpportunities.id, opts.opportunityId))
    .limit(1);
  if (!opp || opp.status !== 'published') {
    throw Object.assign(new Error('opportunity not found'), { statusCode: 404 });
  }
  if (!opp.currentRuleVersionId) {
    throw Object.assign(new Error('opportunity has no published rules'), { statusCode: 422 });
  }
  const [rv] = await db.select().from(ruleVersions).where(eq(ruleVersions.id, opp.currentRuleVersionId)).limit(1);

  const [schemaRow] = await db
    .select()
    .from(applicationSchemas)
    .where(eq(applicationSchemas.opportunityId, opp.id))
    .orderBy(sql`${applicationSchemas.version} DESC`)
    .limit(1);

  // Prefill from the tenant's canonical answers — traceable per field (§34).
  let answers: Answers = {};
  let answerProvenance: Record<string, string> = {};
  if (schemaRow) {
    const canonicalRows = await db
      .select()
      .from(canonicalAnswers)
      .where(eq(canonicalAnswers.tenantId, opts.tenantId));
    const canonical: Record<string, AnswerValue> = {};
    for (const row of canonicalRows) canonical[row.canonicalKey] = row.value as AnswerValue;
    const prefilled = prefillFromCanonical(schemaRow.def as ApplicationSchemaDef, {}, canonical);
    answers = prefilled.answers;
    answerProvenance = Object.fromEntries(prefilled.prefilledKeys.map((k) => [k, 'canonical_prefill']));
  }

  // Immutable snapshot of what we knew at selection time (§23).
  const opportunitySnapshot = {
    capturedAt: new Date().toISOString(),
    opportunity: opp,
    ruleVersion: rv ?? null,
    schemaVersion: schemaRow?.version ?? null,
  };

  const [row] = await db
    .insert(applicationCases)
    .values({
      tenantId: opts.tenantId,
      projectId: opts.projectId,
      opportunityId: opp.id,
      ruleVersionId: opp.currentRuleVersionId,
      schemaId: schemaRow?.id ?? null,
      state: 'SELECTED',
      answers,
      answerProvenance,
      opportunitySnapshot,
      deadlineAt: opp.closesAt,
    })
    .returning();

  await audit({
    tenantId: opts.tenantId,
    actorType: 'user',
    actorUserId: opts.userId,
    action: 'application.created',
    entityType: 'application_case',
    entityId: row!.id,
    after: { opportunityId: opp.id, state: 'SELECTED' },
  });

  return row!;
}

export async function getCaseSchema(caseRow: typeof applicationCases.$inferSelect): Promise<ApplicationSchemaDef | null> {
  if (!caseRow.schemaId) return null;
  const [schemaRow] = await db
    .select()
    .from(applicationSchemas)
    .where(eq(applicationSchemas.id, caseRow.schemaId))
    .limit(1);
  return (schemaRow?.def as ApplicationSchemaDef) ?? null;
}

export async function validateCase(caseRow: typeof applicationCases.$inferSelect): Promise<CaseValidation> {
  const schema = await getCaseSchema(caseRow);
  const fieldIssues = schema ? validateAnswers(schema, caseRow.answers as Answers) : [];

  const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, caseRow.id));
  const coreLines: BudgetLine[] = lines.map((l) => ({
    id: l.id,
    category: l.category,
    description: l.description,
    quantity: l.quantity,
    unitCostMinor: l.unitCostMinor,
    currency: l.currency,
  }));

  const snapshot = caseRow.opportunitySnapshot as { ruleVersion?: { budgetRules?: BudgetRule[]; evidenceRequirements?: EvidenceRequirement[] } | null };
  const budgetRules = snapshot.ruleVersion?.budgetRules ?? [];
  const evidenceRequirements = snapshot.ruleVersion?.evidenceRequirements ?? [];

  const financing = (caseRow.financing as BudgetFinancing | null) ?? {
    requestedMinor: 0,
    ownContributionMinor: 0,
    otherFundingMinor: 0,
    inKindMinor: 0,
  };
  const budgetFindings =
    coreLines.length > 0 ? validateBudget(coreLines, financing, budgetRules) : [];

  const attachedRows = await db
    .select({ kind: documents.kind })
    .from(caseDocuments)
    .innerJoin(documents, eq(caseDocuments.documentId, documents.id))
    .where(eq(caseDocuments.caseId, caseRow.id));
  const attachedKinds = new Set(attachedRows.map((r) => r.kind));
  const missingAttachments = evidenceRequirements
    .filter((e) => e.mandatory && !attachedKinds.has(e.kind))
    .map((e) => ({ kind: e.kind, description: e.description }));

  const ready =
    fieldIssues.length === 0 &&
    budgetFindings.filter((f) => f.severity === 'error').length === 0 &&
    missingAttachments.length === 0;

  return { fieldIssues, budgetFindings, missingAttachments, ready };
}

/**
 * Guarded state transition. Enforces the state machine and the transition
 * guards (receipts for SUBMITTED, validation for READY_TO_SUBMIT).
 */
export async function transitionCase(opts: {
  tenantId: string;
  userId: string | null;
  actorType: 'user' | 'system' | 'job';
  caseId: string;
  to: ApplicationState;
  /** Extra context recorded in the audit trail. */
  context?: Record<string, unknown>;
}): Promise<typeof applicationCases.$inferSelect> {
  const [caseRow] = await db
    .select()
    .from(applicationCases)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .limit(1);
  if (!caseRow) throw Object.assign(new Error('case not found'), { statusCode: 404 });

  const from = caseRow.state as ApplicationState;
  assertTransition(from, opts.to);

  if (opts.to === 'READY_TO_SUBMIT') {
    const validation = await validateCase(caseRow);
    if (!validation.ready) {
      throw Object.assign(new Error('application is not complete'), {
        statusCode: 422,
        validation,
      });
    }
  }

  const patch: Record<string, unknown> = { state: opts.to, updatedAt: new Date() };
  if (opts.to === 'SUBMITTED') {
    // Freeze the exact submitted content (§80: preserve historical state).
    patch.submittedSnapshot = {
      submittedAt: new Date().toISOString(),
      answers: caseRow.answers,
      financing: caseRow.financing,
      opportunitySnapshot: caseRow.opportunitySnapshot,
    };
  }

  const [updated] = await db
    .update(applicationCases)
    .set(patch)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .returning();

  await audit({
    tenantId: opts.tenantId,
    actorType: opts.actorType,
    actorUserId: opts.userId,
    action: 'application.state_changed',
    entityType: 'application_case',
    entityId: opts.caseId,
    before: { state: from },
    after: { state: opts.to, ...opts.context },
  });

  return updated!;
}

/** Persist answers (only in editable states) and update canonical reuse store. */
export async function saveAnswers(opts: {
  tenantId: string;
  userId: string;
  caseId: string;
  answers: Answers;
}): Promise<typeof applicationCases.$inferSelect> {
  const [caseRow] = await db
    .select()
    .from(applicationCases)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .limit(1);
  if (!caseRow) throw Object.assign(new Error('case not found'), { statusCode: 404 });

  const editable: ApplicationState[] = ['SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'ACTION_REQUIRED'];
  if (!editable.includes(caseRow.state as ApplicationState)) {
    throw Object.assign(new Error(`answers cannot be edited in state ${caseRow.state}`), { statusCode: 409 });
  }

  const merged: Answers = { ...(caseRow.answers as Answers), ...opts.answers };
  const provenance = { ...(caseRow.answerProvenance as Record<string, string>) };
  for (const key of Object.keys(opts.answers)) provenance[key] = `user:${opts.userId}`;

  const [updated] = await db
    .update(applicationCases)
    .set({ answers: merged, answerProvenance: provenance, updatedAt: new Date() })
    .where(eq(applicationCases.id, opts.caseId))
    .returning();

  // Update canonical answers for reuse across applications (§34) — the value
  // remains traceable to the case it came from and is never silently rewritten.
  const schema = await getCaseSchema(caseRow);
  if (schema) {
    for (const field of schema.fields) {
      if (!field.canonicalKey) continue;
      const value = opts.answers[field.key];
      if (value === undefined || value === null || value === '') continue;
      await db
        .insert(canonicalAnswers)
        .values({ tenantId: opts.tenantId, canonicalKey: field.canonicalKey, value, sourceCaseId: opts.caseId, updatedAt: new Date() })
        .onConflictDoUpdate({
          target: [canonicalAnswers.tenantId, canonicalAnswers.canonicalKey],
          set: { value, sourceCaseId: opts.caseId, updatedAt: new Date() },
        });
    }
  }

  await audit({
    tenantId: opts.tenantId,
    actorType: 'user',
    actorUserId: opts.userId,
    action: 'application.answers_updated',
    entityType: 'application_case',
    entityId: opts.caseId,
    after: { keys: Object.keys(opts.answers) },
  });

  return updated!;
}
