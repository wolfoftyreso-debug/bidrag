/**
 * Dokumentstudion (§produktsteg 3): Bidragskoll.se förbereder dokument — ett
 * konkret resultat, inte "hjälp att fylla i formulär i största allmänhet".
 *
 * Affärslogik:
 *  - Paket i stället för styckdebitering per knapp: 1 dokument / upp till 3 /
 *    alla för en ansökan. Krediter härleds ur BEKRÄFTADE betalningar (samma
 *    sanningskedja som analysen: betalning → kvitto → entitlement), minus
 *    antal redan skapade dokument.
 *  - Dokument genereras deterministiskt ur mall + svar av domänmotorn — en
 *    klient kan aldrig påstå sig ha krediter, och ett dokument kan aldrig
 *    skapas ur ett obetalt eller väntande köp.
 *  - Allt hamnar i Mina dokument, tenant-scopat. Ingen e-post inblandad.
 */
import type { FastifyInstance } from 'fastify';
import { and, count, eq, sql } from 'drizzle-orm';
import { DOCUMENT_TEMPLATES, answerLanguageFindings, getTemplate, prefillAnswers, renderDocument, repetitionFindings, validateDocumentAnswers, type DocAnswers } from '@bidrag/core';
import { db } from '../db/client.ts';
import { applicantProfiles, fundingAuthorities, fundingOpportunities, generatedDocuments, payments, projects, users } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { config } from '../config.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';
import { activeProvider } from '../services/paymentProviders.ts';
import { textToPdf } from '../services/pdf.ts';

const PACKS = {
  single: { credits: 1, price: () => config.documentPrices.single, label: 'Ett dokument' },
  pack3: { credits: 3, price: () => config.documentPrices.pack3, label: 'Upp till 3 dokument' },
  all: { credits: 99, price: () => config.documentPrices.all, label: 'Alla dokument för en ansökan' },
} as const;

async function creditState(tenantId: string, projectId: string) {
  const [bought] = await db
    .select({ total: sql<number>`coalesce(sum(${payments.credits}), 0)` })
    .from(payments)
    .where(
      and(
        eq(payments.tenantId, tenantId),
        eq(payments.projectId, projectId),
        eq(payments.kind, 'document_pack'),
        eq(payments.state, 'confirmed'),
      ),
    );
  const [used] = await db
    .select({ n: count() })
    .from(generatedDocuments)
    .where(and(eq(generatedDocuments.tenantId, tenantId), eq(generatedDocuments.projectId, projectId)));
  const total = Number(bought?.total ?? 0);
  const usedN = Number(used?.n ?? 0);
  return { total, used: usedN, remaining: Math.max(0, total - usedN) };
}

async function ownedProject(tenantId: string, id: string) {
  const [row] = await db
    .select({ id: projects.id, title: projects.title })
    .from(projects)
    .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
    .limit(1);
  return row ?? null;
}

export async function documentStudioRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  /** Läge + priser + mallkatalog (frågorna behövs för formulärrendering). */
  app.get(
    '/v1/projects/:id/document-credits',
    { schema: { tags: ['documents'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      if (!(await ownedProject(request.auth!.tenantId, id))) return reply.code(404).send({ error: 'not_found' });
      const credits = await creditState(request.auth!.tenantId, id);

      // Färdigifyllda dokument: allt systemet redan vet från intaget mappas
      // in i mallens frågor — användaren kontrollerar och kompletterar i
      // stället för att svara på samma fråga igen. Inget gissas.
      const [ctx] = await db
        .select({
          projectFacts: projects.facts,
          profileFacts: applicantProfiles.facts,
          municipality: applicantProfiles.municipality,
        })
        .from(projects)
        .leftJoin(applicantProfiles, eq(projects.profileId, applicantProfiles.id))
        .where(and(eq(projects.id, id), eq(projects.tenantId, request.auth!.tenantId)))
        .limit(1);
      const [me] = await db
        .select({ displayName: users.displayName })
        .from(users)
        .where(eq(users.id, request.auth!.userId))
        .limit(1);
      const facts = {
        ...((ctx?.profileFacts as Record<string, unknown>) ?? {}),
        ...((ctx?.projectFacts as Record<string, unknown>) ?? {}),
      };

      return {
        ...credits,
        prices: {
          single: config.documentPrices.single,
          pack3: config.documentPrices.pack3,
          all: config.documentPrices.all,
        },
        templates: DOCUMENT_TEMPLATES.map((t) => ({
          key: t.key,
          title: t.title,
          description: t.description,
          questions: t.questions,
        })),
        prefill: Object.fromEntries(
          DOCUMENT_TEMPLATES.map((t) => [
            t.key,
            prefillAnswers(t.key, { displayName: me?.displayName, municipality: ctx?.municipality, facts }),
          ]),
        ),
      };
    },
  );

  /** Köp dokumentpaket — exakt samma betalningskedja som analysupplåsningen. */
  app.post(
    '/v1/projects/:id/document-pack',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['documents'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['pack'],
          properties: { pack: { type: 'string', enum: ['single', 'pack3', 'all'] } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const { pack } = request.body as { pack: keyof typeof PACKS };
      if (!(await ownedProject(tenantId, id))) return reply.code(404).send({ error: 'not_found' });

      const provider = activeProvider();
      if (!provider) {
        return reply.code(503).send({
          error: 'no_payment_provider',
          message: 'Betalning är inte tillgänglig just nu. Swish kräver att tjänstens handelsavtal och certifikat är konfigurerade.',
        });
      }

      const spec = PACKS[pack];
      const [payment] = await db
        .insert(payments)
        .values({
          tenantId,
          projectId: id,
          kind: 'document_pack',
          credits: spec.credits,
          amountMinor: spec.price(),
          provider: provider.id,
          state: 'pending',
        })
        .returning();

      try {
        const created = await provider.create({
          id: payment!.id,
          amountMinor: spec.price(),
          currency: 'SEK',
          message: `Bidragskoll.se — dokument (${spec.label.toLowerCase()})`,
        });
        if (created.providerReference || created.providerToken) {
          await db
            .update(payments)
            .set({ providerReference: created.providerReference, providerToken: created.providerToken ?? null })
            .where(eq(payments.id, payment!.id));
        }
        await audit({
          tenantId,
          actorType: 'user',
          actorUserId: request.auth!.userId,
          action: 'payment.created',
          entityType: 'payment',
          entityId: payment!.id,
          after: { projectId: id, kind: 'document_pack', pack, amountMinor: spec.price(), provider: provider.id },
        });
        return reply.code(201).send({ paymentId: payment!.id, amountMinor: spec.price(), credits: spec.credits, instructions: created.instructions });
      } catch (err) {
        await db.update(payments).set({ state: 'failed' }).where(eq(payments.id, payment!.id));
        const status = (err as { statusCode?: number }).statusCode ?? 502;
        return reply.code(status).send({ error: 'payment_create_failed', message: (err as Error).message });
      }
    },
  );

  /** Generera ett dokument ur mall + svar. Kostar en kredit; utan krediter → 402. */
  app.post(
    '/v1/projects/:id/generated-documents',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['documents'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['templateKey', 'answers'],
          properties: {
            templateKey: { type: 'string', maxLength: 60 },
            answers: { type: 'object', additionalProperties: true },
            opportunitySlug: { type: 'string', maxLength: 200 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const body = request.body as { templateKey: string; answers: DocAnswers; opportunitySlug?: string };
      if (!(await ownedProject(tenantId, id))) return reply.code(404).send({ error: 'not_found' });

      const template = getTemplate(body.templateKey);
      if (!template) return reply.code(404).send({ error: 'unknown_template' });

      const credits = await creditState(tenantId, id);
      if (credits.remaining <= 0) {
        return reply.code(402).send({
          error: 'no_document_credits',
          message: 'Köp dokumentförberedelse för att skapa dokument.',
          prices: config.documentPrices,
        });
      }

      const validation = validateDocumentAnswers(template, body.answers);
      if (!validation.ok) {
        return reply.code(422).send({ error: 'missing_answers', missing: validation.missing });
      }

      // Mottagare/rubrik från stödet när det är valt — annars generiskt.
      let opportunityTitle = 'Ansökan om stöd';
      let recipient = template.recipientLabel;
      if (body.opportunitySlug) {
        const [opp] = await db
          .select({ title: fundingOpportunities.title, authorityName: fundingAuthorities.name })
          .from(fundingOpportunities)
          .innerJoin(fundingAuthorities, eq(fundingOpportunities.authorityId, fundingAuthorities.id))
          .where(eq(fundingOpportunities.slug, body.opportunitySlug))
          .limit(1);
        if (opp) {
          opportunityTitle = opp.title;
          recipient = opp.authorityName;
        }
      }

      const rendered = renderDocument(template, body.answers, {
        recipient,
        opportunityTitle,
        date: new Date().toISOString().slice(0, 10),
      });

      const [row] = await db
        .insert(generatedDocuments)
        .values({
          tenantId,
          projectId: id,
          opportunitySlug: body.opportunitySlug ?? null,
          opportunityTitle,
          templateKey: template.key,
          title: rendered.title,
          content: rendered.text,
          answers: body.answers,
          createdBy: request.auth!.userId,
        })
        .returning();

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'document.generated',
        entityType: 'generated_document',
        entityId: row!.id,
        after: { templateKey: template.key, opportunitySlug: body.opportunitySlug ?? null },
      });
      const after = await creditState(tenantId, id);
      // Ödmjukhetsprotokollet (§12–13) + korrekturvarvet: sökandens
      // formuleringar och upprepningar i det färdiga dokumentet flaggas
      // rådgivande — dokumentet skapas ändå, texten skrivs aldrig om.
      return reply.code(201).send({
        document: row,
        creditsRemaining: after.remaining,
        languageFindings: [
          ...answerLanguageFindings(body.answers),
          ...repetitionFindings(rendered.text).map((f) => ({ ...f, fieldKey: '_dokumentet' })),
        ],
      });
    },
  );

  app.get(
    '/v1/projects/:id/generated-documents',
    { schema: { tags: ['documents'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      if (!(await ownedProject(request.auth!.tenantId, id))) return reply.code(404).send({ error: 'not_found' });
      const rows = await db
        .select({
          id: generatedDocuments.id,
          title: generatedDocuments.title,
          templateKey: generatedDocuments.templateKey,
          opportunityTitle: generatedDocuments.opportunityTitle,
          opportunitySlug: generatedDocuments.opportunitySlug,
          createdAt: generatedDocuments.createdAt,
        })
        .from(generatedDocuments)
        .where(and(eq(generatedDocuments.tenantId, request.auth!.tenantId), eq(generatedDocuments.projectId, id)))
        .orderBy(generatedDocuments.createdAt);
      return { documents: rows };
    },
  );

  /** Nedladdning: PDF (färdigt dokument) eller text (för egen redigering). */
  app.get(
    '/v1/generated-documents/:id/download',
    {
      schema: {
        tags: ['documents'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        querystring: { type: 'object', properties: { format: { type: 'string', enum: ['pdf', 'text'] } }, additionalProperties: false },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const { format = 'pdf' } = request.query as { format?: 'pdf' | 'text' };
      const [row] = await db
        .select()
        .from(generatedDocuments)
        .where(and(eq(generatedDocuments.id, id), eq(generatedDocuments.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });

      const safeName = row.title.toLowerCase().replace(/[^a-z0-9åäö]+/gi, '-').replace(/^-|-$/g, '');
      if (format === 'text') {
        return reply
          .header('Content-Type', 'text/plain; charset=utf-8')
          .header('Content-Disposition', `attachment; filename="${encodeURIComponent(safeName)}.txt"`)
          .send(row.content);
      }
      return reply
        .header('Content-Type', 'application/pdf')
        .header('Content-Disposition', `attachment; filename="${encodeURIComponent(safeName)}.pdf"`)
        .header('X-Content-Type-Options', 'nosniff')
        .send(textToPdf(row.title, row.content));
    },
  );
}
