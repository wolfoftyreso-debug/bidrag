import type { FastifyInstance } from 'fastify';
import { requiresApplication } from '../services/applicationNeed.ts';
import { and, eq, ilike, or, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { applicationSchemas, fundingAuthorities, fundingOpportunities, ruleVersions } from '../db/schema.ts';
import { kbTranslator, resolveKbLocale, translateCriteria, translateEvidence } from '../services/kbI18n.ts';

/**
 * Public funding knowledge — readable by any authenticated user; shared across
 * tenants (§30). Search complements but never replaces the match engine (§52).
 */
export async function opportunityRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get(
    '/v1/funding-opportunities',
    {
      schema: {
        tags: ['opportunities'],
        querystring: {
          type: 'object',
          properties: {
            q: { type: 'string', maxLength: 200 },
            instrumentType: { type: 'string', maxLength: 50 },
            applicantType: { type: 'string', maxLength: 50 },
            country: { type: 'string', maxLength: 2 },
            openOnly: { type: 'boolean' },
            limit: { type: 'integer', minimum: 1, maximum: 100, default: 50 },
            offset: { type: 'integer', minimum: 0, default: 0 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request) => {
      const q = request.query as {
        q?: string;
        instrumentType?: string;
        applicantType?: string;
        country?: string;
        openOnly?: boolean;
        limit: number;
        offset: number;
      };

      const conditions = [eq(fundingOpportunities.status, 'published')];
      if (q.instrumentType) conditions.push(eq(fundingOpportunities.instrumentType, q.instrumentType));
      if (q.q) {
        conditions.push(
          or(
            ilike(fundingOpportunities.title, `%${q.q}%`),
            ilike(fundingOpportunities.summary, `%${q.q}%`),
            ilike(fundingOpportunities.description, `%${q.q}%`),
          )!,
        );
      }
      if (q.applicantType) {
        conditions.push(sql`${fundingOpportunities.applicantTypes} @> ${JSON.stringify([q.applicantType])}::jsonb`);
      }
      if (q.country) {
        conditions.push(sql`${fundingOpportunities.countries} @> ${JSON.stringify([q.country])}::jsonb`);
      }
      if (q.openOnly) {
        conditions.push(
          or(
            sql`${fundingOpportunities.closesAt} IS NULL`,
            sql`${fundingOpportunities.closesAt} > now()`,
          )!,
        );
      }

      const rows = await db
        .select({
          id: fundingOpportunities.id,
          slug: fundingOpportunities.slug,
          title: fundingOpportunities.title,
          summary: fundingOpportunities.summary,
          instrumentType: fundingOpportunities.instrumentType,
          applicantTypes: fundingOpportunities.applicantTypes,
          countries: fundingOpportunities.countries,
          minAmountMinor: fundingOpportunities.minAmountMinor,
          maxAmountMinor: fundingOpportunities.maxAmountMinor,
          amountNote: fundingOpportunities.amountNote,
          amountSourceUrl: fundingOpportunities.amountSourceUrl,
          currency: fundingOpportunities.currency,
          deadlineModel: fundingOpportunities.deadlineModel,
          opensAt: fundingOpportunities.opensAt,
          closesAt: fundingOpportunities.closesAt,
          submissionLevel: fundingOpportunities.submissionLevel,
          sourceUrl: fundingOpportunities.sourceUrl,
          sourceQuality: fundingOpportunities.sourceQuality,
          verificationStatus: fundingOpportunities.verificationStatus,
          lastVerifiedAt: fundingOpportunities.lastVerifiedAt,
          authorityName: fundingAuthorities.name,
        })
        .from(fundingOpportunities)
        .innerJoin(fundingAuthorities, eq(fundingOpportunities.authorityId, fundingAuthorities.id))
        .where(and(...conditions))
        .limit(q.limit)
        .offset(q.offset);

      // I18N fas B: sammanfattningen på användarens språk; titeln (officiellt
      // namn) översätts aldrig. Okänd/ändrad källtext ⇒ ärlig svensk fallback.
      const tr = await kbTranslator(resolveKbLocale(request.headers['accept-language']));
      return { opportunities: rows.map((r) => ({ ...r, summary: tr(r.summary) })) };
    },
  );

  app.get(
    '/v1/funding-opportunities/:id',
    {
      schema: {
        tags: ['opportunities'],
        params: { type: 'object', properties: { id: { type: 'string' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
      const [opp] = await db
        .select()
        .from(fundingOpportunities)
        .where(isUuid ? eq(fundingOpportunities.id, id) : eq(fundingOpportunities.slug, id))
        .limit(1);
      if (!opp || opp.status === 'draft') return reply.code(404).send({ error: 'not_found' });

      const [authority] = await db
        .select()
        .from(fundingAuthorities)
        .where(eq(fundingAuthorities.id, opp.authorityId))
        .limit(1);

      const rv = opp.currentRuleVersionId
        ? (await db.select().from(ruleVersions).where(eq(ruleVersions.id, opp.currentRuleVersionId)).limit(1))[0]
        : undefined;

      const [schemaRow] = await db
        .select({ id: applicationSchemas.id, version: applicationSchemas.version })
        .from(applicationSchemas)
        .where(eq(applicationSchemas.opportunityId, opp.id))
        .orderBy(sql`${applicationSchemas.version} DESC`)
        .limit(1);

      // I18N fas B+D: sammanfattning, intakefrågor, villkorstexter,
      // ansökningssätt, beloppsmeningen och underlagslistan på användarens
      // språk. Officiella namn (title, authority) och beloppets siffror
      // översätts aldrig; källänken pekar fortsatt på myndighetens svenska
      // sida (docs/I18N_PROGRAM.md; ärlig notis i webben).
      const tr = await kbTranslator(resolveKbLocale(request.headers['accept-language']));
      return {
        opportunity: {
          ...opp,
          summary: tr(opp.summary),
          applicationMethod: tr(opp.applicationMethod),
          requiresApplication: requiresApplication(opp.applicationMethod),
          amountNote: opp.amountNote ? tr(opp.amountNote) : opp.amountNote,
        },
        authority,
        ruleVersion: rv
          ? {
              id: rv.id,
              version: rv.version,
              criteria: translateCriteria(rv.criteria, tr),
              budgetRules: rv.budgetRules,
              evidenceRequirements: translateEvidence(rv.evidenceRequirements, tr),
              effectiveFrom: rv.effectiveFrom,
              changeNote: rv.changeNote,
            }
          : null,
        hasApplicationSchema: Boolean(schemaRow),
      };
    },
  );
}
