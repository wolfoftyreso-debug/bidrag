/**
 * Application case service: creation with immutable opportunity snapshots,
 * validation (schema + budget + attachments), and guarded state transitions
 * with audit logging.
 */
import { and, eq, sql } from 'drizzle-orm';
import {
  assertTransition,
  findNumericConflicts,
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
  matches,
  ruleVersions,
} from '../db/schema.ts';
import { audit } from '../audit.ts';

export interface CaseValidation {
  fieldIssues: FieldValidationIssue[];
  budgetFindings: { ruleId: string; severity: string; message: string }[];
  missingAttachments: { kind: string; description: string }[];
  ready: boolean;
}

// ── Granskningsläget (Application Intelligence §30–31) ───────────────────────

export type GapSeverity = 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';

export interface ReviewGap {
  id: string;
  severity: GapSeverity;
  area: 'eligibility' | 'fields' | 'evidence' | 'budget' | 'deadline' | 'consistency' | 'coverage';
  message: string;
  /** Vad som stänger luckan. */
  action: string;
  /**
   * §5-stoppregeln: bristen kräver en faktisk förändring i omständigheterna —
   * den kan och ska inte "skrivas runt" med bättre text.
   */
  requiresFactualChange: boolean;
}

export interface CaseReview {
  overallStatus: 'READY_FOR_SUBMISSION' | 'NOT_READY';
  eligibility: {
    status: 'PASS' | 'FAIL' | 'UNKNOWN';
    excludedBy: { description: string }[];
    missingFacts: { question: string }[];
  };
  fields: { issues: FieldValidationIssue[] };
  evidence: { kind: string; description: string; status: 'ATTACHED' | 'MISSING' }[];
  budget: {
    findings: { ruleId: string; severity: string; message: string }[];
    totalMinor: number;
    financingTotalMinor: number;
    requestedMinor: number;
  };
  deadline: { deadlineAt: string | null; daysLeft: number | null; passed: boolean };
  /** Prioriterad åtgärdslista, allvarligast först. */
  gaps: ReviewGap[];
}

const SEVERITY_ORDER: GapSeverity[] = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];

/**
 * Deterministisk helhetsgranskning av en ansökan inför inlämning:
 * behörighet (matchmotorns trevärdesbedömning — UNKNOWN blir aldrig ett
 * positivt antagande), obligatoriska fält, obligatorisk bevisning, budgetens
 * matematik och regelefterlevnad samt deadline. Utfallet är READY_FOR_-
 * SUBMISSION eller NOT_READY med en prioriterad åtgärdslista. En FAIL på ett
 * hårt behörighetskrav flaggas som något som kräver ändrade omständigheter —
 * systemet försöker aldrig "skriva runt" den.
 */
export async function reviewCase(caseRow: typeof applicationCases.$inferSelect): Promise<CaseReview> {
  const validation = await validateCase(caseRow);
  const gaps: ReviewGap[] = [];

  // Behörighet ur senaste matchningen för projekt + stöd.
  const [matchRow] = await db
    .select({ result: matches.result })
    .from(matches)
    .where(and(eq(matches.projectId, caseRow.projectId), eq(matches.opportunityId, caseRow.opportunityId)))
    .limit(1);
  const matchResult = matchRow?.result as
    | { eligibilityStatus?: string; excludedBy?: { description: string }[]; missingFacts?: { question: string }[] }
    | undefined;
  const eligibilityStatus: 'PASS' | 'FAIL' | 'UNKNOWN' =
    matchResult?.eligibilityStatus === 'eligible' ? 'PASS' : matchResult?.eligibilityStatus === 'excluded' ? 'FAIL' : 'UNKNOWN';
  const excludedBy = matchResult?.excludedBy ?? [];
  const missingFacts = matchResult?.missingFacts ?? [];

  if (eligibilityStatus === 'FAIL') {
    for (const e of excludedBy.length > 0 ? excludedBy : [{ description: 'Ett obligatoriskt villkor är inte uppfyllt.' }]) {
      gaps.push({
        id: 'eligibility-fail',
        severity: 'CRITICAL',
        area: 'eligibility',
        message: `Behörighetskrav ej uppfyllt: ${e.description}`,
        action:
          'Kravet kan inte lösas med bättre text — det kräver att omständigheterna faktiskt ändras. Kontrollera villkoret hos finansiären innan du går vidare.',
        requiresFactualChange: true,
      });
    }
  } else if (eligibilityStatus === 'UNKNOWN') {
    // Revisionsfynd K1: ett obesvarat behörighetskrav får aldrig passera
    // submission-gaten — UNKNOWN är blockerande tills frågan är besvarad.
    for (const f of missingFacts.slice(0, 5)) {
      gaps.push({
        id: 'eligibility-unknown',
        severity: 'HIGH',
        area: 'eligibility',
        message: `Obesvarad behörighetsfråga: ${f.question}`,
        action: 'Besvara frågan i analysen — ett obesvarat krav räknas aldrig som uppfyllt vid inlämning.',
        requiresFactualChange: false,
      });
    }
  }

  // Deadline: en passerad ansökningsperiod går inte att åtgärda med text.
  const deadlineAt = caseRow.deadlineAt ? new Date(caseRow.deadlineAt).toISOString() : null;
  const daysLeft = caseRow.deadlineAt
    ? Math.floor((new Date(caseRow.deadlineAt).getTime() - Date.now()) / 86_400_000)
    : null;
  const deadlinePassed = daysLeft !== null && daysLeft < 0;
  if (deadlinePassed) {
    gaps.push({
      id: 'deadline-passed',
      severity: 'CRITICAL',
      area: 'deadline',
      message: 'Ansökningsperioden har passerat.',
      action: 'Kontrollera om en ny ansökningsomgång öppnar, eller välj ett annat stöd.',
      requiresFactualChange: true,
    });
  }

  for (const a of validation.missingAttachments) {
    gaps.push({
      id: `evidence-${a.kind}`,
      severity: 'CRITICAL',
      area: 'evidence',
      message: `Obligatorisk bilaga saknas: ${a.description}`,
      action: 'Ladda upp dokumentet i dokumentvalvet och koppla det till ansökan.',
      requiresFactualChange: false,
    });
  }
  for (const i of validation.fieldIssues) {
    gaps.push({
      id: `field-${i.fieldKey}`,
      severity: 'HIGH',
      area: 'fields',
      message: i.message,
      action: 'Fyll i fältet i ansökningsformuläret.',
      requiresFactualChange: false,
    });
  }
  for (const f of validation.budgetFindings) {
    // Revisionsfynd K2: finansiering ≠ budget är en matematisk motsägelse åt
    // BÅDA hållen — även överfinansiering blockerar inlämning.
    const blocking = f.severity === 'error' || f.ruleId === '_financing_balance';
    gaps.push({
      id: `budget-${f.ruleId}`,
      severity: blocking ? 'HIGH' : 'MEDIUM',
      area: 'budget',
      message: f.message,
      action: blocking
        ? 'Justera budgetposterna eller finansieringen så att beloppen stämmer matematiskt.'
        : 'Kontrollera posten — en varning hindrar inte inlämning men kan leda till kompletteringskrav.',
      requiresFactualChange: false,
    });
  }

  const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, caseRow.id));
  const totalMinor = lines.reduce((s, l) => s + Math.round(l.quantity * l.unitCostMinor), 0);
  const financing = (caseRow.financing as BudgetFinancing | null) ?? {
    requestedMinor: 0,
    ownContributionMinor: 0,
    otherFundingMinor: 0,
    inKindMinor: 0,
  };
  const financingTotalMinor =
    financing.requestedMinor + financing.ownContributionMinor + financing.otherFundingMinor + financing.inKindMinor;

  // Revisionsfynd K2: sökt stöd som ensamt överstiger hela budgeten är en
  // stödandel över 100 % — en motsägelse oavsett om stödet saknar explicit
  // andelsregel.
  if (totalMinor > 0 && financing.requestedMinor > totalMinor) {
    gaps.push({
      id: 'budget-requested-exceeds-total',
      severity: 'HIGH',
      area: 'budget',
      message: `Sökt belopp (${(financing.requestedMinor / 100).toLocaleString('sv-SE')} kr) överstiger hela projektbudgeten (${(totalMinor / 100).toLocaleString('sv-SE')} kr).`,
      action: 'Sänk sökt belopp eller komplettera budgetposterna — stödandelen kan inte överstiga 100 %.',
      requiresFactualChange: false,
    });
  }

  const schema = await getCaseSchema(caseRow);

  // Revisionsfynd K3 (fail-safe §18): när stödet saknar digitaliserat
  // ansökningsformulär kan granskningen inte verifiera fälten — det sägs
  // öppet och blockerar, i stället för att tyst godkänna en tom ansökan.
  if (!schema) {
    gaps.push({
      id: 'coverage-no-schema',
      severity: 'HIGH',
      area: 'coverage',
      message: 'Ansökningsformuläret för det här stödet är inte digitaliserat i systemet — granskningen kan inte verifiera att alla obligatoriska fält är besvarade.',
      action: 'Fyll i ansökan hos finansiären enligt deras formulär. Använd granskningens övriga punkter (behörighet, bilagor, budget) som checklista.',
      requiresFactualChange: false,
    });
  }

  // Konsistensmotor v1 (§11–12): sifferpåståenden korsjämförs över fälten,
  // och sökt belopp i formuläret jämförs mot finansieringsplanen.
  const answers = caseRow.answers as Record<string, unknown>;
  for (const c of findNumericConflicts(answers)) {
    gaps.push({
      id: `consistency-${c.unit}`,
      severity: 'MEDIUM',
      area: 'consistency',
      message: c.message,
      action: `Rätta uppgifterna så att samma antal ${c.unit} anges överallt (${c.values.map((v) => `"${v.snippet}"`).join(' · ')}).`,
      requiresFactualChange: false,
    });
  }
  const requestedField = (schema?.fields ?? []).find((f) => f.canonicalKey === 'project.requestedAmount');
  const requestedAnswer = requestedField ? answers[requestedField.key] : undefined;
  if (typeof requestedAnswer === 'number' && financing.requestedMinor > 0 && Math.round(requestedAnswer * 100) !== financing.requestedMinor) {
    gaps.push({
      id: 'consistency-requested-amount',
      severity: 'HIGH',
      area: 'consistency',
      message: `Sökt belopp i formuläret (${requestedAnswer.toLocaleString('sv-SE')} kr) stämmer inte med finansieringsplanen (${(financing.requestedMinor / 100).toLocaleString('sv-SE')} kr).`,
      action: 'Ange samma sökta belopp i formuläret och finansieringsplanen.',
      requiresFactualChange: false,
    });
  }

  const snapshot = caseRow.opportunitySnapshot as {
    ruleVersion?: { evidenceRequirements?: EvidenceRequirement[] } | null;
  };
  const required = (snapshot.ruleVersion?.evidenceRequirements ?? []).filter((e) => e.mandatory);
  const missingKinds = new Set(validation.missingAttachments.map((a) => a.kind));
  const evidence = required.map((e) => ({
    kind: e.kind,
    description: e.description,
    status: (missingKinds.has(e.kind) ? 'MISSING' : 'ATTACHED') as 'ATTACHED' | 'MISSING',
  }));

  gaps.sort((a, b) => SEVERITY_ORDER.indexOf(a.severity) - SEVERITY_ORDER.indexOf(b.severity));
  const blocking = gaps.some((g) => g.severity === 'CRITICAL' || g.severity === 'HIGH');

  return {
    overallStatus: blocking ? 'NOT_READY' : 'READY_FOR_SUBMISSION',
    eligibility: { status: eligibilityStatus, excludedBy, missingFacts },
    fields: { issues: validation.fieldIssues },
    evidence,
    budget: { findings: validation.budgetFindings, totalMinor, financingTotalMinor, requestedMinor: financing.requestedMinor },
    deadline: { deadlineAt, daysLeft, passed: deadlinePassed },
    gaps,
  };
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
    // Revisionsfynd K5: övergången vaktar på HELA granskningen — behörighet,
    // deadline, konsistens och täckning — inte bara fält/budget/bilagor. En
    // ansökan med olöst eller underkänd behörighet kan aldrig bli klar att
    // skicka in, oavsett hur komplett den ser ut i övrigt.
    const review = await reviewCase(caseRow);
    if (review.overallStatus !== 'READY_FOR_SUBMISSION') {
      throw Object.assign(new Error('application is not complete'), {
        statusCode: 422,
        validation: await validateCase(caseRow),
        review,
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
