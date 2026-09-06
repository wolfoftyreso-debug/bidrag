import type { FastifyInstance } from 'fastify';
import { and, desc, eq, inArray, sql } from 'drizzle-orm';
import { validateRuleSet } from '@bidrag/core';
import { db } from '../db/client.ts';
import {
  fundingOpportunities,
  matches,
  reviewItems,
  ruleVersions,
  sources,
  sourceSnapshots,
  feedback,
  users,
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
   * Granskningskön (prio 5, motförhörets A-fynd): stöden i den ordning en
   * människa bör granska dem — förfallna först, sedan efter hur ofta stödet
   * faktiskt visats för riktiga användare (aktiva matchningar senaste 30 d),
   * med senaste granskningsprotokoll och flaggan "startsida som källa" (M25).
   */
  app.get('/v1/admin/opportunities', { schema: { tags: ['admin'] } }, async () => {
    const since = new Date(Date.now() - 30 * 86_400_000);
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
        applicationUrl: fundingOpportunities.applicationUrl,
        sourceId: fundingOpportunities.sourceId,
        closesAt: fundingOpportunities.closesAt,
      })
      .from(fundingOpportunities)
      .limit(500);
    const shown = await db
      .select({ opportunityId: matches.opportunityId, n: sql<number>`count(*)::int` })
      .from(matches)
      .where(and(inArray(matches.eligibilityStatus, ['eligible', 'unknown']), sql`${matches.createdAt} > ${since}`))
      .groupBy(matches.opportunityId);
    const shownBy = new Map(shown.map((r) => [r.opportunityId, Number(r.n)]));
    const verifications = await db
      .select({ refId: reviewItems.refId, resolvedAt: reviewItems.resolvedAt, note: reviewItems.note, payload: reviewItems.payload, by: users.displayName })
      .from(reviewItems)
      .leftJoin(users, eq(users.id, reviewItems.resolvedBy))
      .where(eq(reviewItems.kind, 'verification'))
      .orderBy(desc(reviewItems.resolvedAt));
    const lastVerification = new Map<string, (typeof verifications)[number]>();
    for (const v of verifications) if (v.refId && !lastVerification.has(v.refId)) lastVerification.set(v.refId, v);
    const now = Date.now();
    // "Startsida som källa" (M25): rotadressen eller en generisk sektionssida
    // (privatperson/företag/förening …) — inte stödets egen sida.
    const GENERIC = new Set(['privatperson', 'privatpersoner', 'foretag', 'foretagare', 'forening', 'foreningar', 'organisation', 'organisationer', 'sv', 'en', 'bidrag', 'stod', 'bidrag-och-stod', 'sok-bidrag', 'soka-bidrag', 'utlysningar', 'stipendier', 'om-oss', 'start']);
    const isStartPage = (url: string) => {
      try {
        const segs = new URL(url).pathname.split('/').filter(Boolean);
        return segs.length === 0 || (segs.length === 1 && GENERIC.has(segs[0]!.toLowerCase()));
      } catch { return false; }
    };
    const enriched = rows.map((o) => {
      const v = lastVerification.get(o.id);
      return {
        ...o,
        shown30d: shownBy.get(o.id) ?? 0,
        overdue: !o.nextReviewAt || o.nextReviewAt.getTime() < now,
        sourceIsStartPage: isStartPage(o.sourceUrl),
        lastVerification: v ? { at: v.resolvedAt, by: v.by ?? null, note: v.note ?? null, checklist: (v.payload as { checklist?: unknown }).checklist ?? null } : null,
      };
    });
    enriched.sort((a, b) => Number(b.overdue) - Number(a.overdue) || b.shown30d - a.shown30d || (a.nextReviewAt?.getTime() ?? 0) - (b.nextReviewAt?.getTime() ?? 0));
    return { opportunities: enriched };
  });

  /**
   * Källkontroll i granskningsögonblicket: hämtar stödets källa NU (samma
   * SSRF-säkra hämtning som källbevakningen) och svarar ärligt med status,
   * förändring sedan senaste snapshot och sammanfattning — kuratorn ska se
   * att källan lever innan stämpeln höjs. Ingen källa registrerad ⇒ sägs.
   */
  app.post(
    '/v1/admin/opportunities/:id/source-check',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [opp] = await db
        .select({ id: fundingOpportunities.id, sourceId: fundingOpportunities.sourceId, sourceUrl: fundingOpportunities.sourceUrl })
        .from(fundingOpportunities)
        .where(eq(fundingOpportunities.id, id))
        .limit(1);
      if (!opp) return reply.code(404).send({ error: 'not_found' });
      if (!opp.sourceId) {
        return { checked: false, changeStatus: 'error', httpStatus: null, error: 'Ingen källa är registrerad för stödet — kontrollera sourceUrl manuellt.', sourceUrl: opp.sourceUrl, fetchedAt: new Date().toISOString(), diffSummary: null };
      }
      const outcome = await fetchSource(opp.sourceId);
      const [snap] = await db
        .select({ fetchedAt: sourceSnapshots.fetchedAt, diffSummary: sourceSnapshots.diffSummary })
        .from(sourceSnapshots)
        .where(eq(sourceSnapshots.id, outcome.snapshotId))
        .limit(1);
      return {
        checked: true,
        changeStatus: outcome.changeStatus,
        httpStatus: outcome.httpStatus,
        error: outcome.error ?? null,
        sourceUrl: opp.sourceUrl,
        fetchedAt: snap?.fetchedAt ?? new Date(),
        diffSummary: snap?.diffSummary ?? null,
      };
    },
  );

  /**
   * Lyft till "verifierad mot källa" — bara med fullständigt protokoll
   * (docs/reports/KURATORSMINIMUM_2026-09-03.md §Arbetsgång): källan finns
   * kvar, villkoren stämmer, beloppet stämmer, ansökningssätt + underlag
   * stämmer, källadressen är stödets egen sida. Ett ofullständigt protokoll
   * vägras (400) — enknappen som höjde stämpeln utan kontroll är borta.
   * Protokollet sparas som granskningsärende (vem, när, vad, anteckning) och
   * i revisionsspåret; källadress/ansökningsadress kan rättas i samma steg.
   */
  app.post(
    '/v1/admin/opportunities/:id/verify',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['checklist'],
          properties: {
            checklist: {
              type: 'object',
              required: ['sourceAlive', 'criteriaMatch', 'amountMatch', 'applicationMatch', 'sourceSpecific'],
              properties: {
                sourceAlive: { type: 'boolean' },
                criteriaMatch: { type: 'boolean' },
                amountMatch: { type: 'boolean' },
                applicationMatch: { type: 'boolean' },
                sourceSpecific: { type: 'boolean' },
              },
            },
            note: { type: 'string', maxLength: 2000 },
            sourceUrl: { type: 'string', format: 'uri', maxLength: 500 },
            applicationUrl: { type: 'string', format: 'uri', maxLength: 500 },
          },
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const body = request.body as {
        checklist: Record<'sourceAlive' | 'criteriaMatch' | 'amountMatch' | 'applicationMatch' | 'sourceSpecific', boolean>;
        note?: string;
        sourceUrl?: string;
        applicationUrl?: string;
      };
      const missing = (Object.entries(body.checklist) as [string, boolean][]).filter(([, v]) => v !== true).map(([k]) => k);
      if (missing.length) return reply.code(400).send({ error: 'checklist_incomplete', missing });
      const [before] = await db
        .select({ verificationStatus: fundingOpportunities.verificationStatus, sourceUrl: fundingOpportunities.sourceUrl, applicationUrl: fundingOpportunities.applicationUrl })
        .from(fundingOpportunities)
        .where(eq(fundingOpportunities.id, id))
        .limit(1);
      if (!before) return reply.code(404).send({ error: 'not_found' });
      const now = new Date();
      const [row] = await db
        .update(fundingOpportunities)
        .set({
          verificationStatus: 'human_verified',
          lastVerifiedAt: now,
          nextReviewAt: new Date(now.getTime() + 30 * 86_400_000),
          ...(body.sourceUrl ? { sourceUrl: body.sourceUrl } : {}),
          ...(body.applicationUrl ? { applicationUrl: body.applicationUrl } : {}),
          updatedAt: now,
        })
        .where(eq(fundingOpportunities.id, id))
        .returning({ id: fundingOpportunities.id, lastVerifiedAt: fundingOpportunities.lastVerifiedAt, verificationStatus: fundingOpportunities.verificationStatus, sourceUrl: fundingOpportunities.sourceUrl, applicationUrl: fundingOpportunities.applicationUrl });
      await db.insert(reviewItems).values({
        kind: 'verification',
        refType: 'funding_opportunity',
        refId: id,
        payload: { checklist: body.checklist, sourceUrlBefore: before.sourceUrl, sourceUrlAfter: row!.sourceUrl, applicationUrlBefore: before.applicationUrl, applicationUrlAfter: row!.applicationUrl },
        status: 'approved',
        note: body.note ?? null,
        resolvedBy: request.auth!.userId,
        resolvedAt: now,
      });
      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'opportunity.verified_against_source',
        entityType: 'funding_opportunity',
        entityId: id,
        before: { verificationStatus: before.verificationStatus, sourceUrl: before.sourceUrl, applicationUrl: before.applicationUrl },
        after: { verificationStatus: 'human_verified', sourceUrl: row!.sourceUrl, applicationUrl: row!.applicationUrl, checklist: body.checklist, note: body.note ?? null },
      });
      return { opportunity: row };
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

  /**
   * Tillämpa ett förslagsutkast från en granskningspost med ett klick:
   * uppdaterar stödets deadline, stämplar det som verifierat mot källan,
   * markerar matchningar för omräkning och godkänner posten. Kuratorns
   * aktiva val — aldrig automatiskt.
   */
  app.post(
    '/v1/admin/review-queue/:id/apply',
    {
      schema: {
        tags: ['admin'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['proposalIndex'],
          properties: { proposalIndex: { type: 'integer', minimum: 0, maximum: 50 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const { proposalIndex } = request.body as { proposalIndex: number };

      const [item] = await db.select().from(reviewItems).where(eq(reviewItems.id, id)).limit(1);
      if (!item || item.status !== 'pending') return reply.code(404).send({ error: 'not_found_or_resolved' });

      const proposals = (item.payload as { proposals?: { type: string; opportunitySlug: string; proposedIso: string; currentIso: string | null; evidence: string }[] }).proposals ?? [];
      const proposal = proposals[proposalIndex];
      if (!proposal || proposal.type !== 'update_deadline') {
        return reply.code(422).send({ error: 'no_such_proposal' });
      }

      const [opp] = await db
        .select()
        .from(fundingOpportunities)
        .where(eq(fundingOpportunities.slug, proposal.opportunitySlug))
        .limit(1);
      if (!opp) return reply.code(404).send({ error: 'opportunity_not_found' });

      const now = new Date();
      const closesAt = new Date(`${proposal.proposedIso}T21:59:59Z`);
      await db
        .update(fundingOpportunities)
        .set({
          closesAt,
          deadlineModel: opp.deadlineModel === 'rolling' ? 'recurring' : opp.deadlineModel,
          verificationStatus: 'human_verified',
          lastVerifiedAt: now,
          nextReviewAt: new Date(now.getTime() + 30 * 86_400_000),
          updatedAt: now,
        })
        .where(eq(fundingOpportunities.id, opp.id));
      await markMatchesStale(opp.id);

      await db
        .update(reviewItems)
        .set({ status: 'approved', note: `Förslag tillämpat: deadline ${proposal.currentIso ?? '—'} → ${proposal.proposedIso}`, resolvedBy: request.auth!.userId, resolvedAt: now })
        .where(eq(reviewItems.id, id));

      await audit({
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'review_item.proposal_applied',
        entityType: 'funding_opportunity',
        entityId: opp.id,
        before: { closesAt: proposal.currentIso },
        after: { closesAt: proposal.proposedIso, evidence: proposal.evidence },
      });

      return { applied: { slug: proposal.opportunitySlug, closesAt: closesAt.toISOString() } };
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

      // Malformed rules must never publish — they would silently break
      // matching for every tenant (§43).
      const issues = validateRuleSet({
        criteria: body.criteria,
        budgetRules: body.budgetRules,
        evidenceRequirements: body.evidenceRequirements,
      });
      if (issues.length > 0) {
        return reply.code(422).send({ error: 'invalid_rules', message: 'Regeluppsättningen har fel.', issues });
      }

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
  /** Betans feedbacklåda (BETA_READINESS B1): senaste 200, nyast först. */
  app.get('/v1/admin/feedback', { schema: { tags: ['admin'] } }, async () => {
    const rows = await db
      .select({
        id: feedback.id,
        category: feedback.category,
        page: feedback.page,
        opportunitySlug: feedback.opportunitySlug,
        message: feedback.message,
        locale: feedback.locale,
        status: feedback.status,
        createdAt: feedback.createdAt,
      })
      .from(feedback)
      .orderBy(desc(feedback.createdAt))
      .limit(200);
    return { items: rows };
  });

  app.get('/v1/admin/stale-matches', { schema: { tags: ['admin'] } }, async () => {
    const [row] = await db
      .select({ count: sql<number>`count(*)::int` })
      .from(matches)
      .where(eq(matches.stale, true));
    return { staleMatches: row?.count ?? 0 };
  });
}
