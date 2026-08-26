import type { FastifyInstance } from 'fastify';
import { and, eq } from 'drizzle-orm';
import { detectTrack, proposeStack, relevantForTrack, type StackableOpportunity } from '@bidrag/core';
import { db } from '../db/client.ts';
import { applicantProfiles, fundingOpportunities, fundingStacks, matches, projects } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';
import { listMatchesForProject, recomputeMatchesForProject, type MatchRow } from '../services/matching.ts';

/**
 * Open Discovery (produktdoktrinen v2, 2026-08-26): matchningar visas ALLTID
 * gratis — namn, varför, status, deadline och källa. Ingen betalvägg framför
 * resultatet. Betalning utlöses först av arbetsverktygen (19 kr/ansökan m.m.),
 * aldrig av att se om det finns något att söka. Den tidigare teasern och
 * 39 kr-analysupplåsningen är borttagna.
 */

/**
 * Spårmedveten relevans (F1, 30-simuleringen; F-RELEVANS): policyn ligger i
 * @bidrag/core (relevance.ts) så att API, demo och relevansrevisionen delar
 * exakt samma regler — inklusive undantaget att personspårets sektor-
 * deklaration (project.sector = 'personal') aldrig flippar spåret.
 * Re-exporteras här för testernas och övriga modulers skull.
 */
export { detectTrack, relevantForTrack };

/** Matchningar för projektet, filtrerade till spårets relevans (F1). */
async function trackRelevantMatches(
  tenantId: string,
  projectId: string,
): Promise<{ rows: MatchRow[]; facts: Record<string, unknown> }> {
  const [row] = await db
    .select({ projectFacts: projects.facts, profileFacts: applicantProfiles.facts })
    .from(projects)
    .innerJoin(applicantProfiles, eq(projects.profileId, applicantProfiles.id))
    .where(and(eq(projects.id, projectId), eq(projects.tenantId, tenantId)))
    .limit(1);
  const merged = { ...((row?.profileFacts as Record<string, unknown>) ?? {}), ...((row?.projectFacts as Record<string, unknown>) ?? {}) };
  const rows = await listMatchesForProject(tenantId, projectId);
  return {
    rows: relevantForTrack(rows, detectTrack(merged), { selfEmployed: merged['person.selfEmployed'] === true, sector: merged['project.sector'] }),
    facts: merged,
  };
}

const projectBody = {
  type: 'object',
  required: ['profileId', 'title'],
  properties: {
    profileId: { type: 'string', format: 'uuid' },
    title: { type: 'string', minLength: 1, maxLength: 300 },
    intent: { type: 'string', maxLength: 5000 },
    facts: { type: 'object', additionalProperties: true },
    totalBudgetMinor: { type: 'integer', minimum: 0, nullable: true },
    currency: { type: 'string', minLength: 3, maxLength: 3 },
    startsOn: { type: 'string', format: 'date-time', nullable: true },
    endsOn: { type: 'string', format: 'date-time', nullable: true },
  },
  additionalProperties: false,
} as const;

export async function projectRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get('/v1/projects', { schema: { tags: ['projects'] } }, async (request) => {
    const rows = await db.select().from(projects).where(eq(projects.tenantId, request.auth!.tenantId));
    return { projects: rows };
  });

  app.get(
    '/v1/projects/:id',
    { schema: { tags: ['projects'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [row] = await db
        .select()
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      return { project: row };
    },
  );

  app.post(
    '/v1/projects',
    { preHandler: app.requireRole(...WRITER_ROLES), schema: { tags: ['projects'], body: projectBody } },
    async (request, reply) => {
      const body = request.body as Record<string, unknown>;
      const tenantId = request.auth!.tenantId;
      const [profile] = await db
        .select({ id: applicantProfiles.id })
        .from(applicantProfiles)
        .where(and(eq(applicantProfiles.id, body.profileId as string), eq(applicantProfiles.tenantId, tenantId)))
        .limit(1);
      if (!profile) return reply.code(404).send({ error: 'profile_not_found' });

      const [row] = await db
        .insert(projects)
        .values({
          tenantId,
          profileId: body.profileId as string,
          title: body.title as string,
          intent: (body.intent as string) ?? '',
          facts: body.facts ?? {},
          totalBudgetMinor: (body.totalBudgetMinor as number) ?? null,
          currency: (body.currency as string) ?? 'SEK',
          startsOn: body.startsOn ? new Date(body.startsOn as string) : null,
          endsOn: body.endsOn ? new Date(body.endsOn as string) : null,
        })
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'project.created',
        entityType: 'project',
        entityId: row!.id,
        after: row,
      });
      return reply.code(201).send({ project: row });
    },
  );

  app.patch(
    '/v1/projects/:id',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['projects'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: { ...projectBody, required: [] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [before] = await db
        .select()
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
        .limit(1);
      if (!before) return reply.code(404).send({ error: 'not_found' });

      const body = request.body as Record<string, unknown>;
      const patch: Record<string, unknown> = { updatedAt: new Date() };
      for (const key of ['title', 'intent', 'totalBudgetMinor', 'currency'] as const) {
        if (body[key] !== undefined) patch[key] = body[key];
      }
      if (body.startsOn !== undefined) patch.startsOn = body.startsOn ? new Date(body.startsOn as string) : null;
      if (body.endsOn !== undefined) patch.endsOn = body.endsOn ? new Date(body.endsOn as string) : null;
      if (body.facts !== undefined) patch.facts = { ...(before.facts as object), ...(body.facts as object) };

      const [after] = await db
        .update(projects)
        .set(patch)
        .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'project.updated',
        entityType: 'project',
        entityId: id,
        before,
        after,
      });
      return { project: after };
    },
  );

  /** Compute (or refresh) matches for a project. */
  app.post(
    '/v1/projects/:id/matches',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: { tags: ['matches'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      try {
        const count = await recomputeMatchesForProject(request.auth!.tenantId, id);
        await audit({
          tenantId: request.auth!.tenantId,
          actorType: 'user',
          actorUserId: request.auth!.userId,
          action: 'matches.recomputed',
          entityType: 'project',
          entityId: id,
          after: { count },
        });
        const { rows, facts } = await trackRelevantMatches(request.auth!.tenantId, id);
        return { computed: count, matches: rows, facts };
      } catch (err) {
        const status = (err as { statusCode?: number }).statusCode ?? 500;
        if (status === 404) return reply.code(404).send({ error: 'not_found' });
        throw err;
      }
    },
  );

  app.get(
    '/v1/projects/:id/matches',
    { schema: { tags: ['matches'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [project] = await db
        .select({ id: projects.id })
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!project) return reply.code(404).send({ error: 'not_found' });
      const { rows, facts } = await trackRelevantMatches(request.auth!.tenantId, id);
      // Open Discovery: fulla matchningar gratis. facts följer med så att "Dina
      // svar" kan visa och ändra besvarade frågor — en fråga försvinner aldrig
      // för att den fått svar.
      return { matches: rows, facts };
    },
  );

  /** Funding stack proposal (§13). */
  app.post(
    '/v1/projects/:id/funding-stack',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['matches'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          properties: { ownContributionMinor: { type: 'integer', minimum: 0 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [project] = await db
        .select()
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
        .limit(1);
      if (!project) return reply.code(404).send({ error: 'not_found' });
      // Open Discovery: finansieringsplanen är en del av det gratis
      // matchningsresultatet — ingen betalvägg.
      if (!project.totalBudgetMinor) {
        return reply.code(422).send({
          error: 'missing_budget',
          message: 'Projektet behöver en totalbudget innan en finansieringsplan kan tas fram.',
        });
      }

      const matchRows = await db
        .select({
          opportunityId: matches.opportunityId,
          score: matches.score,
          eligibilityStatus: matches.eligibilityStatus,
          title: fundingOpportunities.title,
          instrumentType: fundingOpportunities.instrumentType,
          maxAmountMinor: fundingOpportunities.maxAmountMinor,
          maxFundingSharePercent: fundingOpportunities.maxFundingSharePercent,
          excludesOtherPublicFunding: fundingOpportunities.excludesOtherPublicFunding,
          incompatibleWith: fundingOpportunities.incompatibleWith,
          slug: fundingOpportunities.slug,
        })
        .from(matches)
        .innerJoin(fundingOpportunities, eq(matches.opportunityId, fundingOpportunities.id))
        .where(and(eq(matches.tenantId, tenantId), eq(matches.projectId, id)));

      const slugToId = new Map(matchRows.map((m) => [m.slug, m.opportunityId]));
      const candidates: StackableOpportunity[] = matchRows
        .filter((m) => m.eligibilityStatus !== 'excluded')
        .map((m) => ({
          opportunityId: m.opportunityId,
          title: m.title,
          instrumentType: m.instrumentType,
          maxContributionMinor: m.maxAmountMinor,
          maxFundingSharePercent: m.maxFundingSharePercent,
          incompatibleWith: ((m.incompatibleWith as string[]) ?? [])
            .map((slug) => slugToId.get(slug))
            .filter((x): x is string => Boolean(x)),
          excludesOtherPublicFunding: m.excludesOtherPublicFunding,
          matchScore: m.score,
        }));

      const { ownContributionMinor = 0 } = (request.body ?? {}) as { ownContributionMinor?: number };
      const plan = proposeStack(project.totalBudgetMinor, ownContributionMinor, candidates);
      const [saved] = await db.insert(fundingStacks).values({ tenantId, projectId: id, plan }).returning();
      return { stack: saved };
    },
  );
}
