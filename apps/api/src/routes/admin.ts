import type { FastifyInstance } from 'fastify';
import { and, desc, eq, inArray, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import {
  fundingOpportunities,
  matches,
  reviewItems,
  ruleVersions,
  sources,
  sourceSnapshots,
} from '../db/schema.ts';
import { audit } from '../audit.ts';
import { CURATOR_ROLES } from '../plugins/auth.ts';
import { fetchSource } from '../services/ingestion.ts';
import { markMatchesStale } from '../services/matching.ts';

/**
 * Curation console API (§43): source registry, snapshots, review queue and
 * rule versioning. Restricted to administrator/data_curator roles.
 */
export async function adminRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);
  app.addHook('preHandler', app.requireRole(...CURATOR_ROLES));

  // ── Source registry & health (§64) ─────────────────────────────────────────

  app.get('/v1/admin/sources', { schema: { tags: ['admin'] } }, async () => {
    const rows = await db.select().from(sources).orderBy(sources.name);
    const health = await Promise.all(
      rows.map(async (s) => {
        const [counts] = await db
          .select({
            active: sql<number>`(SELECT count(*)::int FROM funding_opportunities fo WHERE fo.source_id = ${s.id} AND fo.status = 'published')`,
            pendingReview: sql<number>`(SELECT count(*)::int FROM review_items ri WHERE ri.status = 'pending' AND (ri.payload->>'sourceId') = ${s.id}::text)`,
          })
          .from(sql`(SELECT 1) AS one`);
        return { ...s, activeOpportunities: counts?.active ?? 0, pendingReview: counts?.pendingReview ?? 0 };
      }),
    );
    return { sources: health };
  });

  app.post(
    '/v1/admin/sources',
    {
      schema: {
        tags: ['admin'],
        body: {
          type: 'object',
          required: ['name', 'url', 'method', 'quality'],
          properties: {
            name: { type: 'string', minLength: 1, maxLength: 300 },
            url: { type: 'string', format: 'uri', maxLength: 1000 },
            method: { type: 'string', enum: ['html', 'pdf', 'api', 'rss', 'manual'] },
            quality: { type: 'string', enum: ['A', 'B', 'C', 'D'] },
            authorityId: { type: 'string', format: 'uuid', nullable: true },
            scheduleCron: { type: 'string', maxLength: 100, nullable: true },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const body = request.body as Record<string, unknown>;
      const [row] = await db
        .insert(sources)
        .values({
          name: body.name as string,
          url: body.url as string,
          method: body.method as never,
          quality: body.quality as never,
          authorityId: (body.authorityId as string) ?? null,
          scheduleCron: (body.scheduleCron as string) ?? null,
        })
        .returning();
      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'source.registered',
        entityType: 'source',
        entityId: row!.id,
        after: row,
      });
      return reply.code(201).send({ source: row });
    },
  );

  /** Trigger an immediate fetch of a source (also run on schedule by the worker). */
  app.post(
    '/v1/admin/sources/:id/fetch',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      try {
        const outcome = await fetchSource(id);
        return { outcome };
      } catch (err) {
        return reply.code(422).send({ error: 'fetch_failed', message: (err as Error).message });
      }
    },
  );

  app.get(
    '/v1/admin/sources/:id/snapshots',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request) => {
      const { id } = request.params as { id: string };
      const rows = await db
        .select({
          id: sourceSnapshots.id,
          fetchedAt: sourceSnapshots.fetchedAt,
          httpStatus: sourceSnapshots.httpStatus,
          contentType: sourceSnapshots.contentType,
          contentHash: sourceSnapshots.contentHash,
          changeStatus: sourceSnapshots.changeStatus,
          diffSummary: sourceSnapshots.diffSummary,
        })
        .from(sourceSnapshots)
        .where(eq(sourceSnapshots.sourceId, id))
        .orderBy(desc(sourceSnapshots.fetchedAt))
        .limit(50);
      return { snapshots: rows };
    },
  );

  // ── Review queue (§65) ─────────────────────────────────────────────────────

  /**
   * Review queue enriched with the opportunities each change affects, so the
   * curator sees "källa ändrad → påverkade stöd" in one view (§65).
   */
  app.get('/v1/admin/review-queue', { schema: { tags: ['admin'] } }, async () => {
    const rows = await db
      .select()
      .from(reviewItems)
      .where(eq(reviewItems.status, 'pending'))
      .orderBy(reviewItems.createdAt)
      .limit(100);

    const sourceIds = [
      ...new Set(
        rows
          .map((r) => (r.payload as { sourceId?: string }).sourceId)
          .filter((x): x is string => Boolean(x)),
      ),
    ];
    const affected = sourceIds.length
      ? await db
          .select({
            id: fundingOpportunities.id,
            slug: fundingOpportunities.slug,
            title: fundingOpportunities.title,
            sourceId: fundingOpportunities.sourceId,
            lastVerifiedAt: fundingOpportunities.lastVerifiedAt,
          })
          .from(fundingOpportunities)
          .where(inArray(fundingOpportunities.sourceId, sourceIds))
      : [];
    const bySource = new Map<string, typeof affected>();
    for (const opp of affected) {
      if (!opp.sourceId) continue;
      const list = bySource.get(opp.sourceId) ?? [];
      list.push(opp);
      bySource.set(opp.sourceId, list);
    }

    return {
      items: rows.map((r) => ({
        ...r,
        affectedOpportunities: bySource.get((r.payload as { sourceId?: string }).sourceId ?? '') ?? [],
      })),
    };
  });

  /**
   * Curator list of published opportunities ordered by review urgency, with a
   * one-click verification action below.
   */
  app.get('/v1/admin/opportunities', { schema: { tags: ['admin'] } }, async () => {
    const rows = await db
      .select({
        id: fundingOpportunities.id,
        slug: fundingOpportunities.slug,
        title: fundingOpportunities.title,
        status: fundingOpportunities.status,
        verificationStatus: fundingOpportunities.verificationStatus,
        lastVerifiedAt: fundingOpportunities.lastVerifiedAt,
        nextReviewAt: fundingOpportunities.nextReviewAt,
        sourceUrl: fundingOpportunities.sourceUrl,
        closesAt: fundingOpportunities.closesAt,
      })
      .from(fundingOpportunities)
      .orderBy(sql`${fundingOpportunities.nextReviewAt} ASC NULLS FIRST`)
      .limit(500);
    return { opportunities: rows };
  });

  /**
   * One-click "verified against source today": curator confirms the published
   * rules still match the source; bumps freshness without a new rule version.
   */
  app.post(
    '/v1/admin/opportunities/:id/verify',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const now = new Date();
      const rows = await db
        .update(fundingOpportunities)
        .set({
          verificationStatus: 'human_verified',
          lastVerifiedAt: now,
          nextReviewAt: new Date(now.getTime() + 30 * 86_400_000),
          updatedAt: now,
        })
        .where(eq(fundingOpportunities.id, id))
        .returning({ id: fundingOpportunities.id, lastVerifiedAt: fundingOpportunities.lastVerifiedAt });
      if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'opportunity.verified_against_source',
        entityType: 'funding_opportunity',
        entityId: id,
      });
      return { opportunity: rows[0] };
    },
  );

  app.post(
    '/v1/admin/review-queue/:id/resolve',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['resolution'],
          properties: {
            resolution: { type: 'string', enum: ['approved', 'rejected'] },
            note: { type: 'string', maxLength: 2000 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const { resolution, note } = request.body as { resolution: 'approved' | 'rejected'; note?: string };
      const rows = await db
        .update(reviewItems)
        .set({ status: resolution, note: note ?? null, resolvedBy: request.auth!.userId, resolvedAt: new Date() })
        .where(and(eq(reviewItems.id, id), eq(reviewItems.status, 'pending')))
        .returning();
      if (rows.length === 0) return reply.code(404).send({ error: 'not_found_or_resolved' });
      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: `review_item.${resolution}`,
        entityType: 'review_item',
        entityId: id,
        after: { note },
      });
      return { item: rows[0] };
    },
  );

  // ── Rule versioning (§22) ──────────────────────────────────────────────────

  /**
   * Publish a new rule version for an opportunity. Existing matches computed
   * against older versions are marked stale and recomputed by the worker;
   * submitted application snapshots are never altered.
   */
  app.post(
    '/v1/admin/opportunities/:id/rule-versions',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['criteria', 'changeNote'],
          properties: {
            criteria: { type: 'array' },
            budgetRules: { type: 'array' },
            evidenceRequirements: { type: 'array' },
            changeNote: { type: 'string', minLength: 1, maxLength: 2000 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const body = request.body as {
        criteria: unknown[];
        budgetRules?: unknown[];
        evidenceRequirements?: unknown[];
        changeNote: string;
      };
      const [opp] = await db.select().from(fundingOpportunities).where(eq(fundingOpportunities.id, id)).limit(1);
      if (!opp) return reply.code(404).send({ error: 'not_found' });

      const [latest] = await db
        .select({ version: ruleVersions.version })
        .from(ruleVersions)
        .where(eq(ruleVersions.opportunityId, id))
        .orderBy(desc(ruleVersions.version))
        .limit(1);
      const nextVersion = (latest?.version ?? 0) + 1;

      // Effective-date the previous version.
      if (opp.currentRuleVersionId) {
        await db
          .update(ruleVersions)
          .set({ effectiveTo: new Date() })
          .where(eq(ruleVersions.id, opp.currentRuleVersionId));
      }

      const [rv] = await db
        .insert(ruleVersions)
        .values({
          opportunityId: id,
          version: nextVersion,
          criteria: body.criteria,
          budgetRules: body.budgetRules ?? [],
          evidenceRequirements: body.evidenceRequirements ?? [],
          changeNote: body.changeNote,
          createdBy: request.auth!.userId,
        })
        .returning();

      await db
        .update(fundingOpportunities)
        .set({
          currentRuleVersionId: rv!.id,
          version: opp.version + 1,
          lastVerifiedAt: new Date(),
          updatedAt: new Date(),
        })
        .where(eq(fundingOpportunities.id, id));

      await markMatchesStale(id);

      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'rule_version.published',
        entityType: 'funding_opportunity',
        entityId: id,
        after: { ruleVersionId: rv!.id, version: nextVersion, changeNote: body.changeNote },
      });

      return reply.code(201).send({ ruleVersion: rv });
    },
  );

  /** Stale-match overview for operations. */
  app.get('/v1/admin/stale-matches', { schema: { tags: ['admin'] } }, async () => {
    const [row] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(matches)
      .where(eq(matches.stale, true));
    return { staleMatches: row?.count ?? 0 };
  });
}
