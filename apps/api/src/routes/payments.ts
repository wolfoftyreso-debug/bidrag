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
import { receiptDocument, sendReceiptEmail } from '../services/receipts.ts';
import { textToPdf } from '../services/pdf.ts';
import { confirmPendingPayment, verifySwishPayment } from '../services/payments.ts';
import { fetchQrPng, swishConfigured } from '../services/integrations/swish.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';

export async function isProjectUnlocked(tenantId: string, projectId: string): Promise<boolean> {
  const [row] = await db
    .select({ id: payments.id })
    .from(payments)
    .where(
      and(
        eq(payments.tenantId, tenantId),
        eq(payments.projectId, projectId),
        eq(payments.state, 'confirmed'),
        // Ett dokumentköp är inte en analysupplåsning — kind avgör entitlement.
        eq(payments.kind, 'analysis_unlock'),
      ),
    )
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
          message: 'Bidragskoll.se — bidragsanalys',
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

      // Samma bekräftelsekedja som riktiga providrar (services/payments.ts):
      // confirmed + kvitto atomiskt; pending-villkoret gör dubbletter till no-ops.
      const outcome = await confirmPendingPayment(id, { provider: 'mock', tenantId });
      if (!outcome) return reply.code(404).send({ error: 'not_found' });

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'payment.confirmed',
        entityType: 'payment',
        entityId: id,
        after: { provider: 'mock', receiptNumber: outcome.receipt.receiptNumber },
      });
      // Mailet är efterhandsarbete — får aldrig blockera eller häva upplåsningen.
      const emailOutcome = await sendReceiptEmail(outcome.receipt.id);
      return {
        unlocked: true,
        receipt: { receiptNumber: outcome.receipt.receiptNumber, email: outcome.receipt.email, emailOutcome },
      };
    },
  );

  /**
   * Statuspolling under pågående betalning. För Swish är detta också
   * fallbacken när en callback tappas: en pending-betalning verifieras live
   * mot Swish (mTLS) vid varje anrop — pollingen är en väckning, aldrig en
   * sanning i sig.
   */
  app.get(
    '/v1/payments/:id/status',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [payment] = await db
        .select()
        .from(payments)
        .where(and(eq(payments.id, id), eq(payments.tenantId, tenantId)))
        .limit(1);
      if (!payment) return reply.code(404).send({ error: 'not_found' });

      let state: string = payment.state;
      if (payment.state === 'pending' && payment.provider === 'swish' && swishConfigured()) {
        try {
          state = await verifySwishPayment(payment);
        } catch (err) {
          request.log.warn({ err, paymentId: id }, 'swish verification failed during polling');
          state = 'pending'; // vendorfel får aldrig se ut som betalningsfel
        }
      }

      if (state !== 'confirmed') return { state };
      const [receipt] = await db.select().from(receipts).where(eq(receipts.paymentId, id)).limit(1);
      return {
        state,
        receipt: receipt ? { receiptNumber: receipt.receiptNumber, email: receipt.email } : null,
      };
    },
  );

  /** Swish-QR för desktop — proxad server-side så att token aldrig behöver nå klienten. */
  app.get(
    '/v1/payments/:id/qr',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [payment] = await db
        .select({ provider: payments.provider, state: payments.state, providerToken: payments.providerToken })
        .from(payments)
        .where(and(eq(payments.id, id), eq(payments.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!payment || payment.provider !== 'swish' || payment.state !== 'pending' || !payment.providerToken) {
        return reply.code(404).send({ error: 'not_found' });
      }
      const png = await fetchQrPng(payment.providerToken);
      return reply.header('Content-Type', 'image/png').header('Cache-Control', 'private, max-age=60').send(png);
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

  /**
   * Mina köp (§release-gate 2 & 4): kvittot är en förstaklassfunktion i det
   * autentiserade kontot — ingen e-post krävs för att komma åt sitt kvitto.
   * Tenant-scopat i varje query; främmande köp existerar inte (404/tom lista).
   */
  app.get('/v1/purchases', { schema: { tags: ['payments'] } }, async (request) => {
    const tenantId = request.auth!.tenantId;
    const rows = await db
      .select({
        paymentId: payments.id,
        kind: payments.kind,
        state: payments.state,
        amountMinor: payments.amountMinor,
        currency: payments.currency,
        provider: payments.provider,
        projectId: payments.projectId,
        projectTitle: projects.title,
        createdAt: payments.createdAt,
        confirmedAt: payments.confirmedAt,
        receiptNumber: receipts.receiptNumber,
        refundStatus: receipts.refundStatus,
      })
      .from(payments)
      .leftJoin(receipts, eq(receipts.paymentId, payments.id))
      .leftJoin(projects, eq(projects.id, payments.projectId))
      .where(eq(payments.tenantId, tenantId))
      .orderBy(desc(payments.createdAt));
    return { purchases: rows };
  });

  /** Kvitto per köp — ownership kontrolleras server-side (tenant + betalning). */
  app.get(
    '/v1/payments/:id/receipt',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [row] = await db
        .select()
        .from(receipts)
        .where(and(eq(receipts.paymentId, id), eq(receipts.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      return { receipt: row, document: receiptDocument(row) };
    },
  );

  /** Kvittot som nedladdningsbar PDF — "spara kvittot" i Mina köp. */
  app.get(
    '/v1/payments/:id/receipt.pdf',
    { schema: { tags: ['payments'], params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } } },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [row] = await db
        .select()
        .from(receipts)
        .where(and(eq(receipts.paymentId, id), eq(receipts.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      const pdf = textToPdf(`Kvitto ${row.receiptNumber}`, receiptDocument(row));
      return reply
        .header('Content-Type', 'application/pdf')
        .header('Content-Disposition', `attachment; filename="kvitto-${row.receiptNumber}.pdf"`)
        .send(pdf);
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
 * Callback-yta för providrar (registreras UTAN sessionkrav — Swish anropar
 * server-till-server). Swish-callbacken är osignerad och behandlas därför
 * som en väckning, aldrig som sanning: vi slår upp betalningen på vår egen
 * referens och verifierar status server-till-server över mTLS innan något
 * bekräftas. En förfalskad callback kan i värsta fall trigga en extra
 * verifiering — aldrig en upplåsning.
 */
export async function paymentWebhookRoutes(app: FastifyInstance) {
  app.post('/v1/webhooks/payments/:provider', { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } }, async (request, reply) => {
    const { provider } = request.params as { provider: string };
    if (provider !== 'swish' || !swishConfigured()) {
      return reply.code(503).send({ error: 'provider_not_configured' });
    }

    const body = (request.body ?? {}) as { id?: string };
    if (!body.id || typeof body.id !== 'string' || !/^[0-9A-F]{32}$/.test(body.id)) {
      return reply.code(400).send({ error: 'invalid_payload' });
    }

    const [payment] = await db
      .select()
      .from(payments)
      .where(and(eq(payments.providerReference, body.id), eq(payments.provider, 'swish')))
      .limit(1);
    // Okänd referens: 200 utan innehåll — vi läcker inte vilka betalningar som finns.
    if (!payment) return { received: true };

    try {
      const state = await verifySwishPayment(payment);
      request.log.info({ paymentId: payment.id, state }, 'swish callback processed');
    } catch (err) {
      // Verifieringen misslyckades — statuspolling/cron tar det senare; 200
      // så att Swish inte retry-stormar mot en känd betalning.
      request.log.error({ err, paymentId: payment.id }, 'swish callback verification failed');
    }
    return { received: true };
  });
}
