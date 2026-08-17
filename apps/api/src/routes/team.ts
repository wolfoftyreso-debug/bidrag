/**
 * Organisationer och samarbete (§26–27): skapa organisationstenants, bjud in
 * medlemmar med roll via e-post, acceptera med token, hantera medlemmar.
 * Inbjudningstoken lagras hashad; accepterande användares e-post måste matcha
 * inbjudan. Ägarrollen kan aldrig delas ut via inbjudan.
 */
import type { FastifyInstance } from 'fastify';
import { createHash, randomBytes } from 'node:crypto';
import { and, eq, isNull } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { invites, memberships, tenants, users } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { sendEmail } from '../services/email.ts';
import { config } from '../config.ts';

const INVITABLE_ROLES = ['applicant', 'contributor', 'reviewer', 'finance', 'administrator', 'data_curator'] as const;
const INVITE_TTL_DAYS = 14;

const hashToken = (t: string) => createHash('sha256').update(t).digest('hex');

export async function teamRoutes(app: FastifyInstance) {
  /** Skapa en organisationstenant — skaparen blir ägare. */
  app.post(
    '/v1/tenants',
    {
      preHandler: [app.requireAuth],
      schema: {
        tags: ['team'],
        body: {
          type: 'object',
          required: ['name'],
          properties: { name: { type: 'string', minLength: 2, maxLength: 200 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { name } = request.body as { name: string };
      const [tenant] = await db.insert(tenants).values({ name, kind: 'organisation' }).returning();
      await db.insert(memberships).values({ userId: request.auth!.userId, tenantId: tenant!.id, role: 'owner' });
      await audit({
        tenantId: tenant!.id,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'tenant.created',
        entityType: 'tenant',
        entityId: tenant!.id,
        after: { name, kind: 'organisation' },
      });
      return reply.code(201).send({ tenant });
    },
  );

  /** Lista medlemmar i aktiv tenant. */
  app.get('/v1/tenant/members', { preHandler: [app.requireAuth] }, async (request) => {
    const rows = await db
      .select({ userId: users.id, email: users.email, displayName: users.displayName, role: memberships.role })
      .from(memberships)
      .innerJoin(users, eq(memberships.userId, users.id))
      .where(eq(memberships.tenantId, request.auth!.tenantId));
    return { members: rows };
  });

  /** Bjud in en medlem (ägare/administratör). */
  app.post(
    '/v1/tenant/invites',
    {
      preHandler: [app.requireAuth, app.requireRole('owner', 'administrator')],
      schema: {
        tags: ['team'],
        body: {
          type: 'object',
          required: ['email', 'role'],
          properties: {
            email: { type: 'string', format: 'email', maxLength: 320 },
            role: { type: 'string', enum: INVITABLE_ROLES as unknown as string[] },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const tenantId = request.auth!.tenantId;
      const { email, role } = request.body as { email: string; role: (typeof INVITABLE_ROLES)[number] };
      const normalized = email.trim().toLowerCase();

      const [existingMember] = await db
        .select({ id: memberships.id })
        .from(memberships)
        .innerJoin(users, eq(memberships.userId, users.id))
        .where(and(eq(memberships.tenantId, tenantId), eq(users.email, normalized)))
        .limit(1);
      if (existingMember) {
        return reply.code(409).send({ error: 'already_member', message: 'Personen är redan medlem.' });
      }

      const token = randomBytes(24).toString('base64url');
      const [invite] = await db
        .insert(invites)
        .values({
          tenantId,
          email: normalized,
          role,
          tokenHash: hashToken(token),
          invitedBy: request.auth!.userId,
          expiresAt: new Date(Date.now() + INVITE_TTL_DAYS * 86_400_000),
        })
        .returning({ id: invites.id, email: invites.email, role: invites.role, expiresAt: invites.expiresAt });

      const [tenant] = await db.select({ name: tenants.name }).from(tenants).where(eq(tenants.id, tenantId)).limit(1);
      const inviteUrl = `${config.publicBaseUrl}/inbjudan/${token}`;
      await sendEmail({
        to: normalized,
        subject: `Du har bjudits in till ${tenant?.name ?? 'en organisation'} på Bidragskoll.se`,
        text: `Du har bjudits in som ${role}. Acceptera inbjudan här (giltig ${INVITE_TTL_DAYS} dagar):\n\n${inviteUrl}`,
        tenantId,
      });

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'invite.created',
        entityType: 'invite',
        entityId: invite!.id,
        after: { email: normalized, role },
      });

      // Länken returneras också i svaret så att ägaren kan dela den själv när
      // e-post inte är konfigurerad — ärligt i stället for tyst beroende.
      return reply.code(201).send({ invite, inviteUrl });
    },
  );

  app.get('/v1/tenant/invites', { preHandler: [app.requireAuth, app.requireRole('owner', 'administrator')] }, async (request) => {
    const rows = await db
      .select({ id: invites.id, email: invites.email, role: invites.role, expiresAt: invites.expiresAt, createdAt: invites.createdAt })
      .from(invites)
      .where(and(eq(invites.tenantId, request.auth!.tenantId), isNull(invites.acceptedAt), isNull(invites.revokedAt)));
    return { invites: rows };
  });

  app.delete(
    '/v1/tenant/invites/:id',
    {
      preHandler: [app.requireAuth, app.requireRole('owner', 'administrator')],
      schema: { params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] } },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const rows = await db
        .update(invites)
        .set({ revokedAt: new Date() })
        .where(and(eq(invites.id, id), eq(invites.tenantId, request.auth!.tenantId), isNull(invites.acceptedAt)))
        .returning({ id: invites.id });
      if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
      return { ok: true };
    },
  );

  /** Visa vad en inbjudan avser — token är hemligheten. */
  app.get(
    '/v1/invites/:token',
    { schema: { params: { type: 'object', properties: { token: { type: 'string', maxLength: 64 } }, required: ['token'] } } },
    async (request, reply) => {
      const { token } = request.params as { token: string };
      const [invite] = await db
        .select({ email: invites.email, role: invites.role, expiresAt: invites.expiresAt, acceptedAt: invites.acceptedAt, revokedAt: invites.revokedAt, tenantId: invites.tenantId })
        .from(invites)
        .where(eq(invites.tokenHash, hashToken(token)))
        .limit(1);
      if (!invite || invite.revokedAt) return reply.code(404).send({ error: 'not_found' });
      if (invite.acceptedAt) return reply.code(410).send({ error: 'already_accepted', message: 'Inbjudan är redan använd.' });
      if (invite.expiresAt.getTime() < Date.now()) return reply.code(410).send({ error: 'expired', message: 'Inbjudan har gått ut.' });
      const [tenant] = await db.select({ name: tenants.name }).from(tenants).where(eq(tenants.id, invite.tenantId)).limit(1);
      return { invite: { email: invite.email, role: invite.role, tenantName: tenant?.name ?? '' } };
    },
  );

  /** Acceptera — inloggad användare vars e-post matchar inbjudan. */
  app.post(
    '/v1/invites/:token/accept',
    {
      preHandler: [app.requireAuth],
      schema: { params: { type: 'object', properties: { token: { type: 'string', maxLength: 64 } }, required: ['token'] } },
    },
    async (request, reply) => {
      const { token } = request.params as { token: string };
      const [invite] = await db.select().from(invites).where(eq(invites.tokenHash, hashToken(token))).limit(1);
      if (!invite || invite.revokedAt) return reply.code(404).send({ error: 'not_found' });
      if (invite.acceptedAt) return reply.code(410).send({ error: 'already_accepted' });
      if (invite.expiresAt.getTime() < Date.now()) return reply.code(410).send({ error: 'expired' });

      const [me] = await db.select({ email: users.email }).from(users).where(eq(users.id, request.auth!.userId)).limit(1);
      if (!me || me.email.toLowerCase() !== invite.email) {
        return reply.code(403).send({
          error: 'email_mismatch',
          message: 'Inbjudan är ställd till en annan e-postadress. Logga in med den adress inbjudan skickades till.',
        });
      }

      await db.insert(memberships).values({ userId: request.auth!.userId, tenantId: invite.tenantId, role: invite.role });
      await db.update(invites).set({ acceptedAt: new Date() }).where(eq(invites.id, invite.id));
      await audit({
        tenantId: invite.tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'invite.accepted',
        entityType: 'invite',
        entityId: invite.id,
        after: { role: invite.role },
      });
      const [tenant] = await db.select({ id: tenants.id, name: tenants.name }).from(tenants).where(eq(tenants.id, invite.tenantId)).limit(1);
      return { tenant, role: invite.role };
    },
  );
}
