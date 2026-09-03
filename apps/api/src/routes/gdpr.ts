/**
 * GDPR self-service (§29): tenant-level data export (Art. 15/20) and erasure
 * (Art. 17). Owner role only; erasure requires an explicit typed confirmation
 * and removes stored upload files before the database cascade.
 */
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import {
  applicantProfiles,
  applicationCases,
  budgetLines,
  canonicalAnswers,
  caseDocuments,
  correspondenceEvents,
  decisions,
  documents,
  fundingStacks,
  matches,
  memberships,
  notifications,
  paymentMilestones,
  projects,
  receipts,
  reportingRequirements,
  submissionReceipts,
  submissions,
  tenants,
  users,
  productEvents,
  feedback,
} from '../db/schema.ts';
import { audit } from '../audit.ts';
import { getStorage } from '../services/storage.ts';

export async function gdprRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  /**
   * Full tenant data export as a single JSON document. External identifiers
   * are intentionally excluded in decrypted form; their existence is listed
   * via the audit trail instead.
   */
  app.get(
    '/v1/tenant/export',
    { preHandler: app.requireRole('owner', 'administrator'), schema: { tags: ['gdpr'] } },
    async (request, reply) => {
      const tenantId = request.auth!.tenantId;
      const bundle = {
        exportedAt: new Date().toISOString(),
        tenantId,
        profiles: await db.select().from(applicantProfiles).where(eq(applicantProfiles.tenantId, tenantId)),
        projects: await db.select().from(projects).where(eq(projects.tenantId, tenantId)),
        matches: await db.select().from(matches).where(eq(matches.tenantId, tenantId)),
        fundingStacks: await db.select().from(fundingStacks).where(eq(fundingStacks.tenantId, tenantId)),
        applications: await db.select().from(applicationCases).where(eq(applicationCases.tenantId, tenantId)),
        budgetLines: await db.select().from(budgetLines).where(eq(budgetLines.tenantId, tenantId)),
        canonicalAnswers: await db.select().from(canonicalAnswers).where(eq(canonicalAnswers.tenantId, tenantId)),
        documents: await db
          .select({
            id: documents.id,
            filename: documents.filename,
            contentType: documents.contentType,
            sizeBytes: documents.sizeBytes,
            sha256: documents.sha256,
            kind: documents.kind,
            createdAt: documents.createdAt,
          })
          .from(documents)
          .where(eq(documents.tenantId, tenantId)),
        caseDocuments: await db.select().from(caseDocuments).where(eq(caseDocuments.tenantId, tenantId)),
        submissions: await db.select().from(submissions).where(eq(submissions.tenantId, tenantId)),
        submissionReceipts: await db.select().from(submissionReceipts).where(eq(submissionReceipts.tenantId, tenantId)),
        correspondence: await db.select().from(correspondenceEvents).where(eq(correspondenceEvents.tenantId, tenantId)),
        decisions: await db.select().from(decisions).where(eq(decisions.tenantId, tenantId)),
        reportingRequirements: await db.select().from(reportingRequirements).where(eq(reportingRequirements.tenantId, tenantId)),
        paymentMilestones: await db.select().from(paymentMilestones).where(eq(paymentMilestones.tenantId, tenantId)),
        notifications: await db.select().from(notifications).where(eq(notifications.tenantId, tenantId)),
        purchaseReceipts: await db.select().from(receipts).where(eq(receipts.tenantId, tenantId)),
      };

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'tenant.data_exported',
        entityType: 'tenant',
        entityId: tenantId,
      });

      return reply
        .header('Content-Disposition', `attachment; filename="bidrag-export-${tenantId}.json"`)
        .send(bundle);
    },
  );

  /**
   * Tenant erasure. Deletes upload files, then the tenant row — every
   * tenant-owned table cascades via foreign keys. The audit event is written
   * without tenant reference so the erasure itself remains provable.
   */
  app.delete(
    '/v1/tenant',
    {
      preHandler: app.requireRole('owner'),
      schema: {
        tags: ['gdpr'],
        body: {
          type: 'object',
          required: ['confirm'],
          properties: { confirm: { type: 'string' } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const tenantId = request.auth!.tenantId;
      const { confirm } = request.body as { confirm: string };
      if (confirm !== 'RADERA') {
        return reply.code(422).send({
          error: 'confirmation_required',
          message: 'Skriv "RADERA" i bekräftelsefältet för att radera kontot och all data permanent.',
        });
      }

      const docs = await db
        .select({ storagePath: documents.storagePath })
        .from(documents)
        .where(eq(documents.tenantId, tenantId));
      const storage = getStorage();
      for (const d of docs) {
        await storage.remove(d.storagePath);
      }
      await storage.removePrefix(tenantId);

      // Erasure proof survives the cascade: no tenant FK on the audit row.
      await audit({
        tenantId: null,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'tenant.erased',
        entityType: 'tenant',
        entityId: tenantId,
        before: { documentsDeleted: docs.length },
      });

      // Kvitton är bokföringsunderlag och bevaras (BFL, undantag i GDPR art.
      // 17.3 b) — men e-postadressen är en personuppgift och skrubbas här.
      await db.update(receipts).set({ email: null }).where(eq(receipts.tenantId, tenantId));

      // Beta-instrumentering och feedback har inga FK (raderingen ska aldrig
      // radera aggregerad historik) — koppla loss identiteten i stället.
      await db.update(productEvents).set({ tenantId: null, userId: null }).where(eq(productEvents.tenantId, tenantId));
      await db.update(feedback).set({ tenantId: null, userId: null }).where(eq(feedback.tenantId, tenantId));
      await db.delete(memberships).where(eq(memberships.tenantId, tenantId));
      await db.delete(tenants).where(eq(tenants.id, tenantId));

      // Red team RT03-S2: raderingen tog tidigare bort tenanten men lämnade
      // kvar användarens users-rad (e-post, lösenordshash) och alla
      // autentiseringstoken — Art. 17-raderingen var ofullständig mot löftet
      // "radera kontot och all data permanent". När användaren inte längre har
      // NÅGOT medlemskap (den här var deras sista/enda tenant) raderas users-
      // raden; FK-cascaden städar refresh-/återställnings-/recovery-tokens och
      // ev. kvarvarande medlemskap. auditEvents.actorUserId saknar FK, så
      // raderingsbeviset överlever.
      const remaining = await db
        .select({ id: memberships.id })
        .from(memberships)
        .where(eq(memberships.userId, request.auth!.userId));
      if (remaining.length === 0) {
        await db.update(productEvents).set({ userId: null }).where(eq(productEvents.userId, request.auth!.userId));
        await db.update(feedback).set({ userId: null }).where(eq(feedback.userId, request.auth!.userId));
        await db.delete(users).where(eq(users.id, request.auth!.userId));
      }

      return { ok: true, message: 'Kontots data är raderad.' };
    },
  );
}
