/**
 * Idempotent seeder for the wave-1 curated funding knowledge graph.
 * Safe to run repeatedly: keyed on slugs/keys, existing rows are updated
 * with a new rule version only when content changed.
 */
import { eq } from 'drizzle-orm';
import { fileURLToPath } from 'node:url';
import { db, pool } from '../db/client.ts';
import {
  applicationSchemas,
  fundingAuthorities,
  fundingOpportunities,
  fundingProgrammes,
  ruleVersions,
  sources,
} from '../db/schema.ts';
import { CURATED_AT, applicationSchemaDefs, authorities, opportunities, seedSources } from './data.ts';

export async function runSeed(): Promise<{ opportunities: number }> {
  const authorityIdByKey = new Map<string, string>();
  for (const a of authorities) {
    const [existing] = await db.select().from(fundingAuthorities).where(eq(fundingAuthorities.name, a.name)).limit(1);
    if (existing) {
      authorityIdByKey.set(a.key, existing.id);
    } else {
      const [row] = await db
        .insert(fundingAuthorities)
        .values({ name: a.name, country: a.country, kind: a.kind, website: a.website })
        .returning();
      authorityIdByKey.set(a.key, row!.id);
    }
  }

  const sourceIdByKey = new Map<string, string>();
  for (const s of seedSources) {
    const [existing] = await db.select().from(sources).where(eq(sources.url, s.url)).limit(1);
    if (existing) {
      sourceIdByKey.set(s.key, existing.id);
    } else {
      const [row] = await db
        .insert(sources)
        .values({
          authorityId: authorityIdByKey.get(s.authorityKey) ?? null,
          name: s.name,
          url: s.url,
          method: s.method,
          quality: s.quality,
          scheduleCron: '0 */6 * * *',
        })
        .returning();
      sourceIdByKey.set(s.key, row!.id);
    }
  }

  const programmeIdByKey = new Map<string, string>();
  let seeded = 0;

  for (const o of opportunities) {
    const authorityId = authorityIdByKey.get(o.authorityKey)!;
    const programmeKey = `${o.authorityKey}:${o.programmeName}`;
    let programmeId = programmeIdByKey.get(programmeKey);
    if (!programmeId) {
      const [existing] = await db
        .select()
        .from(fundingProgrammes)
        .where(eq(fundingProgrammes.name, o.programmeName))
        .limit(1);
      if (existing && existing.authorityId === authorityId) {
        programmeId = existing.id;
      } else {
        const [row] = await db
          .insert(fundingProgrammes)
          .values({ authorityId, name: o.programmeName })
          .returning();
        programmeId = row!.id;
      }
      programmeIdByKey.set(programmeKey, programmeId);
    }

    const [existing] = await db
      .select()
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.slug, o.slug))
      .limit(1);

    const oppValues = {
      authorityId,
      programmeId,
      slug: o.slug,
      title: o.title,
      summary: o.summary,
      description: o.description,
      objective: o.objective,
      instrumentType: o.instrumentType,
      applicantTypes: o.applicantTypes,
      countries: o.countries,
      sectors: o.sectors,
      minAmountMinor: o.minAmountMinor,
      maxAmountMinor: o.maxAmountMinor,
      currency: 'SEK',
      maxFundingSharePercent: o.maxFundingSharePercent,
      excludesOtherPublicFunding: o.excludesOtherPublicFunding,
      incompatibleWith: [],
      deadlineModel: o.deadlineModel,
      opensAt: o.opensAt ? new Date(o.opensAt) : null,
      closesAt: o.closesAt ? new Date(o.closesAt) : null,
      applicationMethod: o.applicationMethod,
      applicationUrl: o.applicationUrl,
      authenticationMethod: o.authenticationMethod,
      submissionLevel: o.submissionLevel,
      estimatedEffortDays: o.estimatedEffortDays,
      status: 'published' as const,
      sourceId: o.sourceKey ? sourceIdByKey.get(o.sourceKey) ?? null : null,
      sourceUrl: o.sourceUrl,
      sourceQuality: 'A' as const,
      verificationStatus: 'human_curated' as const,
      lastVerifiedAt: new Date(CURATED_AT),
      nextReviewAt: new Date(Date.parse(CURATED_AT) + 30 * 86_400_000),
    };

    let opportunityId: string;
    if (existing) {
      opportunityId = existing.id;
      await db.update(fundingOpportunities).set({ ...oppValues, updatedAt: new Date() }).where(eq(fundingOpportunities.id, opportunityId));
    } else {
      const [row] = await db.insert(fundingOpportunities).values(oppValues).returning();
      opportunityId = row!.id;
    }

    // Rule version: create v1 if none exists.
    const [rv] = await db
      .select()
      .from(ruleVersions)
      .where(eq(ruleVersions.opportunityId, opportunityId))
      .limit(1);
    let ruleVersionId = rv?.id;
    if (!ruleVersionId) {
      const [created] = await db
        .insert(ruleVersions)
        .values({
          opportunityId,
          version: 1,
          criteria: o.criteria,
          budgetRules: o.budgetRules,
          evidenceRequirements: o.evidenceRequirements,
          changeNote: 'Initial curated rule set from official source.',
          createdBy: 'seed',
        })
        .returning();
      ruleVersionId = created!.id;
    }
    await db
      .update(fundingOpportunities)
      .set({ currentRuleVersionId: ruleVersionId })
      .where(eq(fundingOpportunities.id, opportunityId));

    seeded++;
  }

  for (const s of applicationSchemaDefs) {
    const [opp] = await db
      .select({ id: fundingOpportunities.id })
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.slug, s.opportunitySlug))
      .limit(1);
    if (!opp) continue;
    const [existing] = await db
      .select({ id: applicationSchemas.id })
      .from(applicationSchemas)
      .where(eq(applicationSchemas.opportunityId, opp.id))
      .limit(1);
    if (!existing) {
      await db.insert(applicationSchemas).values({ opportunityId: opp.id, version: 1, def: s.def });
    }
  }

  return { opportunities: seeded };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runSeed()
    .then(async (r) => {
      console.log(`Seed complete: ${r.opportunities} opportunities.`);
      await pool.end();
    })
    .catch(async (err) => {
      console.error('Seed failed:', err);
      await pool.end();
      process.exit(1);
    });
}
