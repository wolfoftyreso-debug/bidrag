/**
 * Bidrag.se relational schema.
 *
 * Invariants:
 *  - Tenant-owned tables carry tenant_id; every query filters on it.
 *  - Public funding knowledge (authorities, programmes, opportunities, rules,
 *    sources) is shared across tenants and carries provenance instead.
 *  - Rule data is versioned and effective-dated (temporal model, §23).
 *  - audit_events is append-only.
 *  - Amounts are integers in minor units (öre).
 */

import {
  boolean,
  index,
  integer,
  jsonb,
  pgSequence,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';

const id = () => uuid('id').primaryKey().defaultRandom();
const createdAt = () => timestamp('created_at', { withTimezone: true }).notNull().defaultNow();
const updatedAt = () => timestamp('updated_at', { withTimezone: true }).notNull().defaultNow();

// ── Identity & tenancy ────────────────────────────────────────────────────────

export const tenants = pgTable('tenants', {
  id: id(),
  name: text('name').notNull(),
  kind: text('kind', { enum: ['personal', 'organisation'] }).notNull(),
  createdAt: createdAt(),
});

export const users = pgTable('users', {
  id: id(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  displayName: text('display_name').notNull(),
  locale: text('locale').notNull().default('sv-SE'),
  createdAt: createdAt(),
});

export const memberships = pgTable(
  'memberships',
  {
    id: id(),
    userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    role: text('role', {
      enum: ['owner', 'applicant', 'contributor', 'reviewer', 'finance', 'administrator', 'data_curator', 'integration_operator'],
    }).notNull(),
    createdAt: createdAt(),
  },
  (t) => [uniqueIndex('memberships_user_tenant_idx').on(t.userId, t.tenantId)],
);

/** Invitations to join a tenant with a role (§26). Token stored hashed. */
export const invites = pgTable(
  'invites',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    email: text('email').notNull(),
    role: text('role', {
      enum: ['applicant', 'contributor', 'reviewer', 'finance', 'administrator', 'data_curator'],
    }).notNull(),
    tokenHash: text('token_hash').notNull().unique(),
    invitedBy: uuid('invited_by').notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    acceptedAt: timestamp('accepted_at', { withTimezone: true }),
    revokedAt: timestamp('revoked_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [index('invites_tenant_idx').on(t.tenantId)],
);

export const refreshTokens = pgTable(
  'refresh_tokens',
  {
    id: id(),
    userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
    tokenHash: text('token_hash').notNull().unique(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    revokedAt: timestamp('revoked_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [index('refresh_tokens_user_idx').on(t.userId)],
);

/**
 * Lösenordsåterställning ("innan riktiga kronor"-kravet): engångstoken,
 * lagrad hashad (SHA-256), 60 min TTL. Vid använd återställning återkallas
 * alla refresh-tokens — en kapad session överlever inte ett lösenordsbyte.
 */
export const passwordResetTokens = pgTable(
  'password_reset_tokens',
  {
    id: id(),
    userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
    tokenHash: text('token_hash').notNull().unique(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    usedAt: timestamp('used_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [index('password_reset_tokens_user_idx').on(t.userId)],
);

// ── Applicant world (tenant-owned) ───────────────────────────────────────────

export const applicantProfiles = pgTable(
  'applicant_profiles',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    kind: text('kind', { enum: ['person', 'organisation'] }).notNull(),
    displayName: text('display_name').notNull(),
    applicantType: text('applicant_type').notNull(), // ApplicantType
    country: text('country').notNull().default('SE'),
    region: text('region'),
    municipality: text('municipality'),
    /** Dot-path facts consumed by the match engine, e.g. {"person.ageBand": "25-64"}. */
    facts: jsonb('facts').notNull().default({}),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [index('profiles_tenant_idx').on(t.tenantId)],
);

/** External identifiers (OID, org.nr …) stored separately, encrypted at rest (AES-256-GCM). */
export const externalIdentifiers = pgTable(
  'external_identifiers',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    profileId: uuid('profile_id').notNull().references(() => applicantProfiles.id, { onDelete: 'cascade' }),
    kind: text('kind').notNull(), // 'oid' | 'orgnr' | ...
    valueEncrypted: text('value_encrypted').notNull(),
    createdAt: createdAt(),
  },
  (t) => [index('extid_tenant_idx').on(t.tenantId)],
);

export const projects = pgTable(
  'projects',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    profileId: uuid('profile_id').notNull().references(() => applicantProfiles.id, { onDelete: 'cascade' }),
    title: text('title').notNull(),
    /** Free-text intent as the user expressed it ("Jag vill åka till Jamaica…"). */
    intent: text('intent').notNull().default(''),
    facts: jsonb('facts').notNull().default({}),
    totalBudgetMinor: integer('total_budget_minor'),
    currency: text('currency').notNull().default('SEK'),
    startsOn: timestamp('starts_on', { withTimezone: true }),
    endsOn: timestamp('ends_on', { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [index('projects_tenant_idx').on(t.tenantId)],
);

// ── Funding knowledge graph (public, shared, provenance-tracked) ─────────────

export const fundingAuthorities = pgTable('funding_authorities', {
  id: id(),
  name: text('name').notNull(),
  country: text('country').notNull(),
  kind: text('kind').notNull(), // 'state_agency' | 'eu' | 'municipality' | 'region' | 'foundation' | ...
  website: text('website'),
  createdAt: createdAt(),
});

export const fundingProgrammes = pgTable('funding_programmes', {
  id: id(),
  authorityId: uuid('authority_id').notNull().references(() => fundingAuthorities.id),
  name: text('name').notNull(),
  description: text('description').notNull().default(''),
  createdAt: createdAt(),
});

export const fundingOpportunities = pgTable(
  'funding_opportunities',
  {
    id: id(),
    authorityId: uuid('authority_id').notNull().references(() => fundingAuthorities.id),
    programmeId: uuid('programme_id').references(() => fundingProgrammes.id),
    slug: text('slug').notNull().unique(),
    title: text('title').notNull(),
    summary: text('summary').notNull().default(''),
    description: text('description').notNull().default(''),
    objective: text('objective').notNull().default(''),
    instrumentType: text('instrument_type').notNull(), // InstrumentType — never mixed in UI
    applicantTypes: jsonb('applicant_types').notNull().default([]), // ApplicantType[]
    countries: jsonb('countries').notNull().default([]),
    sectors: jsonb('sectors').notNull().default([]),
    minAmountMinor: integer('min_amount_minor'),
    maxAmountMinor: integer('max_amount_minor'),
    currency: text('currency').notNull().default('SEK'),
    maxFundingSharePercent: integer('max_funding_share_percent'),
    excludesOtherPublicFunding: boolean('excludes_other_public_funding').notNull().default(false),
    incompatibleWith: jsonb('incompatible_with').notNull().default([]), // opportunity slugs
    deadlineModel: text('deadline_model', { enum: ['one_time', 'recurring', 'rolling', 'upcoming_round'] }).notNull(),
    opensAt: timestamp('opens_at', { withTimezone: true }),
    closesAt: timestamp('closes_at', { withTimezone: true }),
    decisionExpectedAt: timestamp('decision_expected_at', { withTimezone: true }),
    applicationMethod: text('application_method').notNull().default(''), // human description
    applicationUrl: text('application_url'),
    authenticationMethod: text('authentication_method'), // e.g. 'eid', 'eu_login', 'none'
    submissionLevel: text('submission_level', { enum: ['native', 'structured', 'assisted'] }).notNull().default('assisted'),
    estimatedEffortDays: integer('estimated_effort_days').notNull().default(5),
    reportingObligations: text('reporting_obligations').notNull().default(''),
    status: text('status', { enum: ['draft', 'published', 'closed', 'archived'] }).notNull().default('draft'),
    currentRuleVersionId: uuid('current_rule_version_id'),
    // Provenance & freshness (§21, §41, §42)
    sourceId: uuid('source_id'),
    sourceUrl: text('source_url').notNull(),
    sourceQuality: text('source_quality', { enum: ['A', 'B', 'C', 'D'] }).notNull(),
    verificationStatus: text('verification_status', {
      enum: ['unverified', 'machine_extracted', 'human_curated', 'human_verified'],
    }).notNull(),
    lastVerifiedAt: timestamp('last_verified_at', { withTimezone: true }),
    nextReviewAt: timestamp('next_review_at', { withTimezone: true }),
    version: integer('version').notNull().default(1),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [index('opps_status_idx').on(t.status), index('opps_closes_idx').on(t.closesAt)],
);

/**
 * Versioned, effective-dated rule sets (§22–23). `criteria`, `budgetRules`
 * and `evidenceRequirements` hold the core-engine JSON structures.
 */
export const ruleVersions = pgTable(
  'rule_versions',
  {
    id: id(),
    opportunityId: uuid('opportunity_id').notNull().references(() => fundingOpportunities.id, { onDelete: 'cascade' }),
    version: integer('version').notNull(),
    criteria: jsonb('criteria').notNull().default([]),
    budgetRules: jsonb('budget_rules').notNull().default([]),
    evidenceRequirements: jsonb('evidence_requirements').notNull().default([]),
    effectiveFrom: timestamp('effective_from', { withTimezone: true }).notNull().defaultNow(),
    effectiveTo: timestamp('effective_to', { withTimezone: true }),
    changeNote: text('change_note').notNull().default(''),
    createdBy: text('created_by').notNull().default('system'),
    createdAt: createdAt(),
  },
  (t) => [uniqueIndex('rule_versions_opp_version_idx').on(t.opportunityId, t.version)],
);

// ── Source ingestion (§20–22) ────────────────────────────────────────────────

export const sources = pgTable('sources', {
  id: id(),
  authorityId: uuid('authority_id').references(() => fundingAuthorities.id),
  name: text('name').notNull(),
  url: text('url').notNull(),
  method: text('method', { enum: ['html', 'pdf', 'api', 'rss', 'manual'] }).notNull(),
  quality: text('quality', { enum: ['A', 'B', 'C', 'D'] }).notNull(),
  scheduleCron: text('schedule_cron'),
  active: boolean('active').notNull().default(true),
  parserVersion: text('parser_version').notNull().default('none'),
  lastFetchAt: timestamp('last_fetch_at', { withTimezone: true }),
  lastSuccessAt: timestamp('last_success_at', { withTimezone: true }),
  lastError: text('last_error'),
  createdAt: createdAt(),
});

export const sourceSnapshots = pgTable(
  'source_snapshots',
  {
    id: id(),
    sourceId: uuid('source_id').notNull().references(() => sources.id, { onDelete: 'cascade' }),
    fetchedAt: timestamp('fetched_at', { withTimezone: true }).notNull().defaultNow(),
    httpStatus: integer('http_status'),
    contentType: text('content_type'),
    contentHash: text('content_hash').notNull(),
    /** Raw evidence is never lost — stored inline for text, in object storage for binaries. */
    content: text('content'),
    storagePath: text('storage_path'),
    changeStatus: text('change_status', { enum: ['new', 'unchanged', 'changed', 'error'] }).notNull(),
    diffSummary: text('diff_summary'),
  },
  (t) => [index('snapshots_source_idx').on(t.sourceId, t.fetchedAt)],
);

/** Human review queue for extracted/changed funding facts (§43, §65). */
export const reviewItems = pgTable(
  'review_items',
  {
    id: id(),
    kind: text('kind').notNull(), // 'source_change' | 'extracted_rule' | 'correspondence_match' | ...
    refType: text('ref_type').notNull(),
    refId: uuid('ref_id'),
    payload: jsonb('payload').notNull().default({}),
    status: text('status', { enum: ['pending', 'approved', 'rejected'] }).notNull().default('pending'),
    note: text('note'),
    resolvedBy: uuid('resolved_by'),
    resolvedAt: timestamp('resolved_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [index('review_items_status_idx').on(t.status, t.createdAt)],
);

// ── Matching (tenant-owned results over shared knowledge) ────────────────────

export const matches = pgTable(
  'matches',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    projectId: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
    opportunityId: uuid('opportunity_id').notNull().references(() => fundingOpportunities.id, { onDelete: 'cascade' }),
    ruleVersionId: uuid('rule_version_id').notNull().references(() => ruleVersions.id),
    referenceDate: timestamp('reference_date', { withTimezone: true }).notNull(),
    eligibilityStatus: text('eligibility_status', { enum: ['excluded', 'unknown', 'eligible'] }).notNull(),
    score: integer('score').notNull(),
    /** Full MatchResultComputed for explainability (§67). */
    result: jsonb('result').notNull(),
    stale: boolean('stale').notNull().default(false),
    createdAt: createdAt(),
  },
  (t) => [
    uniqueIndex('matches_project_opp_idx').on(t.projectId, t.opportunityId),
    index('matches_tenant_idx').on(t.tenantId),
  ],
);

export const fundingStacks = pgTable('funding_stacks', {
  id: id(),
  tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  projectId: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  plan: jsonb('plan').notNull(),
  createdAt: createdAt(),
});

// ── Application cases (§14, §32) ─────────────────────────────────────────────

export const applicationSchemas = pgTable(
  'application_schemas',
  {
    id: id(),
    opportunityId: uuid('opportunity_id').notNull().references(() => fundingOpportunities.id, { onDelete: 'cascade' }),
    version: integer('version').notNull(),
    /** ApplicationSchemaDef JSON, including canonical field mappings. */
    def: jsonb('def').notNull(),
    createdAt: createdAt(),
  },
  (t) => [uniqueIndex('app_schemas_opp_version_idx').on(t.opportunityId, t.version)],
);

export const applicationCases = pgTable(
  'application_cases',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    projectId: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
    opportunityId: uuid('opportunity_id').notNull().references(() => fundingOpportunities.id),
    ruleVersionId: uuid('rule_version_id').notNull().references(() => ruleVersions.id),
    schemaId: uuid('schema_id').references(() => applicationSchemas.id),
    state: text('state').notNull().default('SELECTED'),
    answers: jsonb('answers').notNull().default({}),
    /** Which answers were prefilled from canonical data (field provenance, §34). */
    answerProvenance: jsonb('answer_provenance').notNull().default({}),
    financing: jsonb('financing'),
    /** Immutable snapshot of the opportunity + rules at selection/submission (§23). */
    opportunitySnapshot: jsonb('opportunity_snapshot').notNull(),
    submittedSnapshot: jsonb('submitted_snapshot'),
    deadlineAt: timestamp('deadline_at', { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [index('cases_tenant_idx').on(t.tenantId), index('cases_state_idx').on(t.state)],
);

export const budgetLines = pgTable(
  'budget_lines',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
    category: text('category').notNull(),
    description: text('description').notNull(),
    quantity: integer('quantity').notNull().default(1),
    unitCostMinor: integer('unit_cost_minor').notNull(),
    currency: text('currency').notNull().default('SEK'),
    createdAt: createdAt(),
  },
  (t) => [index('budget_lines_case_idx').on(t.caseId)],
);

/** Reusable validated canonical answers per tenant (§34). */
export const canonicalAnswers = pgTable(
  'canonical_answers',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    canonicalKey: text('canonical_key').notNull(),
    value: jsonb('value').notNull(),
    sourceCaseId: uuid('source_case_id'),
    updatedAt: updatedAt(),
  },
  (t) => [uniqueIndex('canonical_answers_key_idx').on(t.tenantId, t.canonicalKey)],
);

// ── Documents & evidence (§24, §28) ──────────────────────────────────────────

export const documents = pgTable(
  'documents',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    filename: text('filename').notNull(),
    contentType: text('content_type').notNull(),
    sizeBytes: integer('size_bytes').notNull(),
    sha256: text('sha256').notNull(),
    storagePath: text('storage_path').notNull(),
    /** Evidence kind: 'cv' | 'budget' | 'partner_letter' | 'annual_report' | ... */
    kind: text('kind').notNull().default('other'),
    scanStatus: text('scan_status', { enum: ['pending', 'clean', 'blocked', 'scan_unavailable'] }).notNull().default('pending'),
    uploadedBy: uuid('uploaded_by').notNull(),
    createdAt: createdAt(),
  },
  (t) => [index('documents_tenant_idx').on(t.tenantId)],
);

export const caseDocuments = pgTable(
  'case_documents',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
    documentId: uuid('document_id').notNull().references(() => documents.id, { onDelete: 'cascade' }),
    fieldKey: text('field_key'),
    role: text('role', { enum: ['attachment', 'evidence', 'receipt', 'decision', 'correspondence'] }).notNull(),
    createdAt: createdAt(),
  },
  (t) => [index('case_documents_case_idx').on(t.caseId)],
);

// ── Submission (§16, §46) ────────────────────────────────────────────────────

export const submissions = pgTable(
  'submissions',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
    attempt: integer('attempt').notNull().default(1),
    level: text('level', { enum: ['native', 'structured', 'assisted'] }).notNull(),
    state: text('state', { enum: ['pending', 'in_progress', 'succeeded', 'failed', 'user_confirmed'] }).notNull(),
    startedAt: timestamp('started_at', { withTimezone: true }).notNull().defaultNow(),
    completedAt: timestamp('completed_at', { withTimezone: true }),
    /** Hash of the exact payload sent/prepared — submission evidence (§45). */
    payloadHash: text('payload_hash').notNull(),
    destination: text('destination').notNull(),
    error: text('error'),
  },
  (t) => [index('submissions_case_idx').on(t.caseId)],
);

export const submissionReceipts = pgTable(
  'submission_receipts',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    submissionId: uuid('submission_id').notNull().references(() => submissions.id, { onDelete: 'cascade' }),
    kind: text('kind', { enum: ['adapter_confirmation', 'user_receipt', 'authority_email'] }).notNull(),
    reference: text('reference').notNull().default(''),
    documentId: uuid('document_id'),
    note: text('note').notNull().default(''),
    receivedAt: timestamp('received_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [index('submission_receipts_tenant_idx').on(t.tenantId)],
);

// ── Correspondence inbox (§17–18, §48) ───────────────────────────────────────

export const correspondenceEvents = pgTable(
  'correspondence_events',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    caseId: uuid('case_id').references(() => applicationCases.id, { onDelete: 'set null' }),
    source: text('source', { enum: ['email', 'upload', 'manual', 'api', 'digital_post'] }).notNull(),
    direction: text('direction', { enum: ['inbound', 'outbound'] }).notNull(),
    sender: text('sender').notNull().default(''),
    recipient: text('recipient').notNull().default(''),
    subject: text('subject').notNull().default(''),
    body: text('body').notNull().default(''),
    messageType: text('message_type', {
      enum: ['decision', 'clarification_request', 'missing_document', 'deadline_extension', 'award', 'rejection', 'payment_notice', 'reporting_request', 'acknowledgement', 'other'],
    }).notNull().default('other'),
    confidence: text('confidence', { enum: ['low', 'medium', 'high'] }).notNull().default('low'),
    matchedBy: text('matched_by', { enum: ['auto', 'human', 'unmatched'] }).notNull().default('unmatched'),
    documentId: uuid('document_id'),
    receivedAt: timestamp('received_at', { withTimezone: true }).notNull().defaultNow(),
    createdAt: createdAt(),
  },
  (t) => [index('correspondence_tenant_idx').on(t.tenantId), index('correspondence_case_idx').on(t.caseId)],
);

// ── Post-award (§49) ─────────────────────────────────────────────────────────

export const decisions = pgTable('decisions', {
  id: id(),
  tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
  outcome: text('outcome', { enum: ['awarded', 'partially_awarded', 'rejected'] }).notNull(),
  amountMinor: integer('amount_minor'),
  reference: text('reference').notNull().default(''),
  decidedAt: timestamp('decided_at', { withTimezone: true }).notNull(),
  documentId: uuid('document_id'),
  note: text('note').notNull().default(''),
  createdAt: createdAt(),
});

export const reportingRequirements = pgTable('reporting_requirements', {
  id: id(),
  tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  dueAt: timestamp('due_at', { withTimezone: true }),
  status: text('status', { enum: ['pending', 'submitted', 'accepted'] }).notNull().default('pending'),
  note: text('note').notNull().default(''),
  createdAt: createdAt(),
});

export const paymentMilestones = pgTable('payment_milestones', {
  id: id(),
  tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
  caseId: uuid('case_id').notNull().references(() => applicationCases.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  amountMinor: integer('amount_minor'),
  dueAt: timestamp('due_at', { withTimezone: true }),
  status: text('status', { enum: ['planned', 'requested', 'paid'] }).notNull().default('planned'),
  createdAt: createdAt(),
});

// ── Payments: engångsupplåsning av bidragsanalysen (§68) ─────────────────────
// Generiskt lager: Payment → Payment confirmed → Unlock. Providern (Swish,
// kort, …) är en adapter och rör aldrig motorn. Ett köp = en analys (projekt).

export const payments = pgTable(
  'payments',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    projectId: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
    kind: text('kind', { enum: ['analysis_unlock'] }).notNull().default('analysis_unlock'),
    amountMinor: integer('amount_minor').notNull(),
    currency: text('currency').notNull().default('SEK'),
    provider: text('provider').notNull(), // 'swish' | 'mock' | ...
    state: text('state', { enum: ['pending', 'confirmed', 'failed', 'cancelled'] }).notNull().default('pending'),
    providerReference: text('provider_reference'),
    /** Providerns hemliga token (Swish: QR-/app-token). Exponeras aldrig i listor. */
    providerToken: text('provider_token'),
    /** Dit kvittot skickas — samlas in före betalningen, kan kompletteras efteråt. */
    receiptEmail: text('receipt_email'),
    createdAt: createdAt(),
    confirmedAt: timestamp('confirmed_at', { withTimezone: true }),
  },
  (t) => [index('payments_project_idx').on(t.projectId, t.state), index('payments_tenant_idx').on(t.tenantId)],
);

/** Löpande kvittonummer — verifikationsserie, aldrig återanvänd. */
export const receiptNumberSeq = pgSequence('receipt_number_seq', { startWith: 1, increment: 1 });

/**
 * Kvitton (verifikationsunderlag). Ett kvitto per bekräftad betalning,
 * genererat i samma transaktion som bekräftelsen — betalningen är den
 * auktoritativa händelsen, kvittot dess bokföringsspår. Beloppen fryses
 * här (öre) tillsammans med momssats och säljaruppgifter vid utfärdandet.
 *
 * Bokföringslagen kräver att verifikationer bevaras (7 år) — därför har
 * tenantId ingen FK (kvittot överlever kontoradering) och paymentId släpps
 * till null om betalningsraden försvinner; köp-ID:t är fryst i paymentRef.
 * Vid GDPR-radering skrubbas e-postadressen men verifikationen består.
 */
export const receipts = pgTable(
  'receipts',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull(),
    paymentId: uuid('payment_id').references(() => payments.id, { onDelete: 'set null' }),
    /** Köp-ID, fryst vid utfärdandet — trycks på kvittot och överlever betalningsraden. */
    paymentRef: text('payment_ref').notNull(),
    receiptNumber: text('receipt_number').notNull(),
    productDescription: text('product_description').notNull(),
    amountGrossMinor: integer('amount_gross_minor').notNull(),
    amountNetMinor: integer('amount_net_minor').notNull(),
    vatAmountMinor: integer('vat_amount_minor').notNull(),
    vatRateBps: integer('vat_rate_bps').notNull(),
    currency: text('currency').notNull().default('SEK'),
    paymentMethod: text('payment_method').notNull(),
    paymentStatus: text('payment_status').notNull().default('confirmed'),
    refundStatus: text('refund_status', { enum: ['none', 'requested', 'refunded'] }).notNull().default('none'),
    sellerName: text('seller_name').notNull(),
    sellerOrgNumber: text('seller_org_number'),
    sellerVatNumber: text('seller_vat_number'),
    email: text('email'),
    emailStatus: text('email_status', { enum: ['pending', 'sent', 'skipped', 'failed'] }).notNull().default('pending'),
    emailSentAt: timestamp('email_sent_at', { withTimezone: true }),
    issuedAt: timestamp('issued_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [
    uniqueIndex('receipts_payment_uq').on(t.paymentId),
    uniqueIndex('receipts_number_uq').on(t.receiptNumber),
    index('receipts_tenant_idx').on(t.tenantId),
  ],
);

// ── Notifications & reminders (§53, §36) ─────────────────────────────────────

export const notifications = pgTable(
  'notifications',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),
    kind: text('kind').notNull(),
    title: text('title').notNull(),
    body: text('body').notNull().default(''),
    refType: text('ref_type'),
    refId: uuid('ref_id'),
    readAt: timestamp('read_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [index('notifications_tenant_idx').on(t.tenantId, t.createdAt)],
);

export const reminders = pgTable(
  'reminders',
  {
    id: id(),
    tenantId: uuid('tenant_id').notNull().references(() => tenants.id, { onDelete: 'cascade' }),
    caseId: uuid('case_id').references(() => applicationCases.id, { onDelete: 'cascade' }),
    kind: text('kind').notNull(), // 'deadline_14d' | 'deadline_7d' | 'deadline_3d' | ...
    dueAt: timestamp('due_at', { withTimezone: true }).notNull(),
    sentAt: timestamp('sent_at', { withTimezone: true }),
    createdAt: createdAt(),
  },
  (t) => [uniqueIndex('reminders_case_kind_idx').on(t.caseId, t.kind)],
);

// ── Audit (§45) — append-only ────────────────────────────────────────────────

export const auditEvents = pgTable(
  'audit_events',
  {
    id: id(),
    tenantId: uuid('tenant_id'),
    actorType: text('actor_type', { enum: ['user', 'system', 'job'] }).notNull(),
    actorUserId: uuid('actor_user_id'),
    action: text('action').notNull(),
    entityType: text('entity_type').notNull(),
    entityId: uuid('entity_id'),
    before: jsonb('before'),
    after: jsonb('after'),
    correlationId: text('correlation_id'),
    createdAt: createdAt(),
  },
  (t) => [index('audit_tenant_idx').on(t.tenantId, t.createdAt), index('audit_entity_idx').on(t.entityType, t.entityId)],
);
