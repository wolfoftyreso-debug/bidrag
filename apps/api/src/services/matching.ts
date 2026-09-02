/**
 * Matching service: composes the deterministic core engine with stored
 * profiles, projects, opportunities and rule versions. Results are persisted
 * with the rule version they were computed against, so they are reproducible
 * and can be marked stale when rules change (§22).
 */
import { and, eq, inArray, sql } from 'drizzle-orm';
import {
  computeMatch,
  type CriterionDef,
  type EvidenceRequirement,
  type Facts,
  type MatchResultComputed,
} from '@bidrag/core';
import { db } from '../db/client.ts';
import {
  applicantProfiles,
  documents,
  fundingAuthorities,
  fundingOpportunities,
  matches,
  projects,
  ruleVersions,
} from '../db/schema.ts';

export interface MatchRow {
  matchId: string;
  opportunityId: string;
  slug: string;
  title: string;
  authorityName: string;
  instrumentType: string;
  score: number;
  eligibilityStatus: string;
  result: MatchResultComputed;
  closesAt: string | null;
  deadlineModel: string;
  sourceUrl: string;
  applicationUrl: string | null;
  sourceQuality: string;
  verificationStatus: string;
  lastVerifiedAt: string | null;
  maxAmountMinor: number | null;
  currency: string;
  submissionLevel: string;
}

export function buildFacts(profileFacts: unknown, projectFacts: unknown, profileRow: { applicantType: string; country: string; region: string | null; municipality: string | null }): Facts {
  return {
    'applicant.type': profileRow.applicantType,
    'applicant.country': profileRow.country,
    'applicant.region': profileRow.region ?? undefined,
    'applicant.municipality': profileRow.municipality ?? undefined,
    ...(profileFacts as Facts),
    ...(projectFacts as Facts),
  };
}

/**
 * Recompute matches for a project against all published opportunities.
 * Deterministic given referenceDate.
 */
export async function recomputeMatchesForProject(
  tenantId: string,
  projectId: string,
  referenceDate = new Date(),
): Promise<number> {
  const [project] = await db
    .select()
    .from(projects)
    .where(and(eq(projects.id, projectId), eq(projects.tenantId, tenantId)))
    .limit(1);
  if (!project) throw Object.assign(new Error('project not found'), { statusCode: 404 });

  const [profile] = await db
    .select()
    .from(applicantProfiles)
    .where(and(eq(applicantProfiles.id, project.profileId), eq(applicantProfiles.tenantId, tenantId)))
    .limit(1);
  if (!profile) throw Object.assign(new Error('profile not found'), { statusCode: 404 });

  const facts = buildFacts(profile.facts, project.facts, profile);

  const docRows = await db
    .select({ kind: documents.kind })
    .from(documents)
    .where(eq(documents.tenantId, tenantId));
  const availableEvidenceKinds = [...new Set(docRows.map((d) => d.kind))];

  const opps = await db
    .select()
    .from(fundingOpportunities)
    .where(eq(fundingOpportunities.status, 'published'));

  const ruleVersionIds = opps.map((o) => o.currentRuleVersionId).filter((x): x is string => x !== null);
  const versions = ruleVersionIds.length
    ? await db.select().from(ruleVersions).where(inArray(ruleVersions.id, ruleVersionIds))
    : [];
  const versionById = new Map(versions.map((v) => [v.id, v]));

  // Compute in memory, persist as ONE batched upsert — the recompute path is
  // hot (every intake answer triggers it) and per-row round trips dominate.
  const rows: (typeof matches.$inferInsert)[] = [];
  for (const opp of opps) {
    const rv = opp.currentRuleVersionId ? versionById.get(opp.currentRuleVersionId) : undefined;
    if (!rv) continue;

    const result = computeMatch({
      criteria: rv.criteria as CriterionDef[],
      facts,
      evidenceRequirements: rv.evidenceRequirements as EvidenceRequirement[],
      availableEvidenceKinds,
      referenceDate: referenceDate.toISOString(),
      deadline: opp.closesAt?.toISOString() ?? null,
      deadlineModel: opp.deadlineModel as 'one_time' | 'recurring' | 'rolling' | 'upcoming_round',
      estimatedEffortDays: opp.estimatedEffortDays,
      lastVerifiedAt: opp.lastVerifiedAt?.toISOString() ?? null,
    });

    rows.push({
      tenantId,
      projectId,
      opportunityId: opp.id,
      ruleVersionId: rv.id,
      referenceDate,
      eligibilityStatus: result.eligibilityStatus,
      score: result.score,
      result,
      stale: false,
    });
  }

  if (rows.length > 0) {
    await db
      .insert(matches)
      .values(rows)
      .onConflictDoUpdate({
        target: [matches.projectId, matches.opportunityId],
        set: {
          ruleVersionId: sql`excluded.rule_version_id`,
          referenceDate: sql`excluded.reference_date`,
          eligibilityStatus: sql`excluded.eligibility_status`,
          score: sql`excluded.score`,
          result: sql`excluded.result`,
          stale: sql`excluded.stale`,
        },
      });
  }
  return rows.length;
}

export async function listMatchesForProject(tenantId: string, projectId: string): Promise<MatchRow[]> {
  const rows = await db
    .select({
      matchId: matches.id,
      opportunityId: fundingOpportunities.id,
      slug: fundingOpportunities.slug,
      title: fundingOpportunities.title,
      authorityName: fundingAuthorities.name,
      instrumentType: fundingOpportunities.instrumentType,
      score: matches.score,
      eligibilityStatus: matches.eligibilityStatus,
      result: matches.result,
      closesAt: fundingOpportunities.closesAt,
      deadlineModel: fundingOpportunities.deadlineModel,
      sourceUrl: fundingOpportunities.sourceUrl,
      applicationUrl: fundingOpportunities.applicationUrl,
      sourceQuality: fundingOpportunities.sourceQuality,
      verificationStatus: fundingOpportunities.verificationStatus,
      lastVerifiedAt: fundingOpportunities.lastVerifiedAt,
      maxAmountMinor: fundingOpportunities.maxAmountMinor,
      currency: fundingOpportunities.currency,
      submissionLevel: fundingOpportunities.submissionLevel,
    })
    .from(matches)
    .innerJoin(fundingOpportunities, eq(matches.opportunityId, fundingOpportunities.id))
    .innerJoin(fundingAuthorities, eq(fundingOpportunities.authorityId, fundingAuthorities.id))
    .where(and(eq(matches.tenantId, tenantId), eq(matches.projectId, projectId)));

  return rows
    .map((r) => ({
      ...r,
      result: r.result as MatchResultComputed,
      closesAt: r.closesAt?.toISOString() ?? null,
      lastVerifiedAt: r.lastVerifiedAt?.toISOString() ?? null,
    }))
    .sort((a, b) => b.score - a.score);
}

/** Mark all matches computed against older rule versions of an opportunity as stale. */
export async function markMatchesStale(opportunityId: string): Promise<void> {
  await db.update(matches).set({ stale: true }).where(eq(matches.opportunityId, opportunityId));
}
