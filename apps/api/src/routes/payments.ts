/**
 * Upplåsning av bidragsanalysen (§68): engångsköp per analys (projekt).
 * Betalningen är den auktoritativa händelsen — kedjan är alltid
 * betalning bekräftad → transaktion bokförd → kvitto utfärdat → upplåsning,
 * aldrig "användaren klickade Betala → upplåsning". Kvittot utfärdas i samma
 * databastransaktion som bekräftelsen; mailet är efterhandsarbete som kan
 * skickas om. Providern är utbytbar; motorn påverkas aldrig av betalvägen.
 */
import type { FastifyInstance } from 'fastify';
import { and, desc, eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { payments, projects, receipts } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { config } from '../config.ts';
import { activeProvider } from '../services/paymentProviders.ts';
import { issueReceipt, receiptDocument, sendReceiptEmail } from '../services/receipts.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';

export async function isProjectUnlocked(tenantId: string, projectId: string): Promise<boolean> {
  const [row] = await db
    .select({ id: payments.id })
    .from(payments)
    .where(and(eq(payments.tenantId, tenantId), eq(payments.projectId, projectId), eq(payments.state, 'confirmed')))
    .limit(1);
  return Boolean(row);
}

export async function paymentRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get(
    '/v1/projects/:id/unlock-status',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [project] = await db
        .select({ id: projects.id })
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
        .limit(1);
      if (!project) return reply.code(404).send({ error: 'not_found' });
      return { unlocked: await isProjectUnlocked(tenantId, id), priceMinor: config.analysisPriceMinor, currency: 'SEK' };
    },
  );

  /**
   * Skapa betalning för att låsa upp analysen. Idempotent om redan upplåst.
   * E-postadressen för kvittot samlas in här — precis före betalningen, med
   * tydligt syfte — men kan kompletteras i efterhand via receipt-email.
   */
  app.post(
    '/v1/projects/:id/analysis-unlock',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['payments'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          properties: { email: { type: 'string', format: 'email', maxLength: 320 } },
          additionalProperties: false,
          nullable: true,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const { email } = (request.body ?? {}) as { email?: string };
      const [project] = await db
        .select({ id: projects.id, title: projects.title })
        .from(projects)
        .where(and(eq(projects.id, id), eq(projects.tenantId, tenantId)))
        .limit(1);
      if (!project) return reply.code(404).send({ error: 'not_found' });

      if (await isProjectUnlocked(tenantId, id)) {
        return { alreadyUnlocked: true };
      }

      const provider = activeProvider();
      if (!provider) {
        return reply.code(503).send({
          error: 'no_payment_provider',
          message: 'Betalning är inte tillgänglig just nu. Swish kräver att tjänstens handelsavtal och certifikat är konfigurerade.',
        });
      }

      const [payment] = await db
        .insert(payments)
        .values({
          tenantId,
          projectId: id,
          amountMinor: config.analysisPriceMinor,
          provider: provider.id,
          state: 'pending',
          receiptEmail: email?.trim().toLowerCase() ?? null,
        })
        .returning();

      try {
        const created = await provider.create({
          id: payment!.id,
          amountMinor: config.analysisPriceMinor,
          currency: 'SEK',
          message: 'Bidrag.se — bidragsanalys',
        });
        if (created.providerReference) {
          await db.update(payments).set({ providerReference: created.providerReference }).where(eq(payments.id, payment!.id));
        }
        await audit({
          tenantId,
          actorType: 'user',
          actorUserId: request.auth!.userId,
          action: 'payment.created',
          entityType: 'payment',
          entityId: payment!.id,
          after: { projectId: id, amountMinor: config.analysisPriceMinor, provider: provider.id },
        });
        return reply.code(201).send({ paymentId: payment!.id, amountMinor: config.analysisPriceMinor, instructions: created.instructions });
      } catch (err) {
        await db.update(payments).set({ state: 'failed' }).where(eq(payments.id, payment!.id));
        const status = (err as { statusCode?: number }).statusCode ?? 502;
        return reply.code(status).send({ error: 'payment_create_failed', message: (err as Error).message });
      }
    },
  );

  /**
   * Mockbekräftelse — endast utveckling/test (providern 'mock', aldrig i
   * produktion). Riktiga providrar bekräftar via signerad callback nedan.
   */
  app.post(
    '/v1/payments/:id/mock-confirm',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      if (!config.paymentsMockEnabled) return reply.code(404).send({ error: 'not_found' });
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;

      // Bekräftelse + bokföring + kvitto atomiskt: antingen finns allt, eller
      // inget. state='pending'-villkoret gör dubbla bekräftelser till no-ops.
      const receipt = await db.transaction(async (tx) => {
        const rows = await tx
          .update(payments)
          .set({ state: 'confirmed', confirmedAt: new Date() })
          .where(and(eq(payments.id, id), eq(payments.tenantId, tenantId), eq(payments.provider, 'mock'), eq(payments.state, 'pending')))
          .returning();
        if (rows.length === 0) return null;
        return issueReceipt(tx, rows[0]!);
      });
      if (!receipt) return reply.code(404).send({ error: 'not_found' });

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'payment.confirmed',
        entityType: 'payment',
        entityId: id,
        after: { provider: 'mock', receiptNumber: receipt.receiptNumber },
      });
      // Mailet är efterhandsarbete — får aldrig blockera eller häva upplåsningen.
      const emailOutcome = await sendReceiptEmail(receipt.id);
      return {
        unlocked: true,
        receipt: { receiptNumber: receipt.receiptNumber, email: receipt.email, emailOutcome },
      };
    },
  );

  /**
   * Komplettera e-postadress efter köpet ("jag missade fältet") och skicka
   * kvittot. Fungerar både före bekräftelsen (sparas på betalningen) och
   * efter (uppdaterar kvittot och skickar direkt).
   */
  app.post(
    '/v1/payments/:id/receipt-email',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['payments'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['email'],
          properties: { email: { type: 'string', format: 'email', maxLength: 320 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const email = (request.body as { email: string }).email.trim().toLowerCase();

      const rows = await db
        .update(payments)
        .set({ receiptEmail: email })
        .where(and(eq(payments.id, id), eq(payments.tenantId, tenantId)))
        .returning();
      if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });

      const [receipt] = await db.select().from(receipts).where(eq(receipts.paymentId, id)).limit(1);
      if (!receipt) return { saved: true, sent: false };
      await db.update(receipts).set({ email }).where(eq(receipts.id, receipt.id));
      const outcome = await sendReceiptEmail(receipt.id);
      return { saved: true, sent: outcome === 'sent', emailOutcome: outcome };
    },
  );

  /** Skicka om kvittot — självservice i stället för support. */
  app.post(
    '/v1/payments/:id/resend-receipt',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [receipt] = await db
        .select()
        .from(receipts)
        .where(and(eq(receipts.paymentId, id), eq(receipts.tenantId, tenantId)))
        .limit(1);
      if (!receipt) return reply.code(404).send({ error: 'not_found' });
      if (!receipt.email) {
        return reply.code(422).send({ error: 'no_email', message: 'Ange en e-postadress för kvittot först.' });
      }
      const outcome = await sendReceiptEmail(receipt.id);
      return { sent: outcome === 'sent', emailOutcome: outcome };
    },
  );

  /** Kvittot för projektets upplåsning — visning och verifikationstext. */
  app.get(
    '/v1/projects/:id/receipt',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const tenantId = request.auth!.tenantId;
      const { id } = request.params as { id: string };
      const [row] = await db
        .select({ receipt: receipts })
        .from(receipts)
        .innerJoin(payments, eq(receipts.paymentId, payments.id))
        .where(and(eq(receipts.tenantId, tenantId), eq(payments.projectId, id), eq(payments.state, 'confirmed')))
        .orderBy(desc(receipts.issuedAt))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      return { receipt: row.receipt, document: receiptDocument(row.receipt) };
    },
  );
}

/**
 * Callback-yta för riktiga providrar (registreras UTAN sessionkrav — Swish
 * anropar server-till-server). Verifiering av signatur/mTLS sker i
 * provideradaptern när Swish konfigureras — tills dess avvisas allt ärligt.
 */
export async function paymentWebhookRoutes(app: FastifyInstance) {
  app.post('/v1/webhooks/payments/:provider', { config: { rateLimit: { max: 60, timeWindow: '1 minute' } } }, async (_request, reply) => {
    return reply.code(503).send({ error: 'provider_not_configured' });
  });
}
