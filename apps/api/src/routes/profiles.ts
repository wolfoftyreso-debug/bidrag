import type { FastifyInstance } from 'fastify';
import { and, eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { applicantProfiles, externalIdentifiers } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { encryptField } from '../auth/fieldCrypto.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';

const profileBody = {
  type: 'object',
  required: ['kind', 'displayName', 'applicantType'],
  properties: {
    kind: { type: 'string', enum: ['person', 'organisation'] },
    displayName: { type: 'string', minLength: 1, maxLength: 200 },
    applicantType: { type: 'string', maxLength: 50 },
    country: { type: 'string', minLength: 2, maxLength: 2 },
    region: { type: 'string', maxLength: 100, nullable: true },
    municipality: { type: 'string', maxLength: 100, nullable: true },
    facts: { type: 'object', additionalProperties: true },
  },
  additionalProperties: false,
} as const;

export async function profileRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get('/v1/profiles', { schema: { tags: ['profiles'] } }, async (request) => {
    const rows = await db
      .select()
      .from(applicantProfiles)
      .where(eq(applicantProfiles.tenantId, request.auth!.tenantId));
    return { profiles: rows };
  });

  app.post(
    '/v1/profiles',
    { preHandler: app.requireRole(...WRITER_ROLES), schema: { tags: ['profiles'], body: profileBody } },
    async (request, reply) => {
      const body = request.body as Record<string, unknown>;
      const [row] = await db
        .insert(applicantProfiles)
        .values({
          tenantId: request.auth!.tenantId,
          kind: body.kind as 'person' | 'organisation',
          displayName: body.displayName as string,
          applicantType: body.applicantType as string,
          country: (body.country as string) ?? 'SE',
          region: (body.region as string) ?? null,
          municipality: (body.municipality as string) ?? null,
          facts: body.facts ?? {},
        })
        .returning();
      await audit({
        tenantId: request.auth!.tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'profile.created',
        entityType: 'applicant_profile',
        entityId: row!.id,
        after: row,
      });
      return reply.code(201).send({ profile: row });
    },
  );

  app.patch(
    '/v1/profiles/:id',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['profiles'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: { ...profileBody, required: [] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [before] = await db
        .select()
        .from(applicantProfiles)
        .where(and(eq(applicantProfiles.id, id), eq(applicantProfiles.tenantId, tenantId)))
        .limit(1);
      if (!before) return reply.code(404).send({ error: 'not_found' });

      const body = request.body as Record<string, unknown>;
      const patch: Record<string, unknown> = { updatedAt: new Date() };
      for (const key of ['kind', 'displayName', 'applicantType', 'country', 'region', 'municipality'] as const) {
        if (body[key] !== undefined) patch[key] = body[key];
      }
      if (body.facts !== undefined) {
        // Merge facts field-by-field so partial intake answers accumulate.
        patch.facts = { ...(before.facts as object), ...(body.facts as object) };
      }
      const [after] = await db
        .update(applicantProfiles)
        .set(patch)
        .where(and(eq(applicantProfiles.id, id), eq(applicantProfiles.tenantId, tenantId)))
        .returning();
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'profile.updated',
        entityType: 'applicant_profile',
        entityId: id,
        before,
        after,
      });
      return { profile: after };
    },
  );

  /**
   * External identifiers (OID, org.nr) are collected only when a submission
   * channel requires them (§25) and stored encrypted (§28).
   */
  app.post(
    '/v1/profiles/:id/external-identifiers',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['profiles'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
        body: {
          type: 'object',
          required: ['kind', 'value'],
          properties: {
            kind: { type: 'string', enum: ['oid', 'orgnr', 'vat', 'other'] },
            value: { type: 'string', minLength: 1, maxLength: 200 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [profile] = await db
        .select({ id: applicantProfiles.id })
        .from(applicantProfiles)
        .where(and(eq(applicantProfiles.id, id), eq(applicantProfiles.tenantId, tenantId)))
        .limit(1);
      if (!profile) return reply.code(404).send({ error: 'not_found' });

      const { kind, value } = request.body as { kind: string; value: string };
      const [row] = await db
        .insert(externalIdentifiers)
        .values({ tenantId, profileId: id, kind, valueEncrypted: encryptField(value) })
        .returning({ id: externalIdentifiers.id, kind: externalIdentifiers.kind });
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'external_identifier.added',
        entityType: 'external_identifier',
        entityId: row!.id,
        after: { kind },
      });
      return reply.code(201).send({ identifier: row });
    },
  );
}
