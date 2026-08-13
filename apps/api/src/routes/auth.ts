import type { FastifyInstance } from 'fastify';
import { and, eq, isNull } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { memberships, refreshTokens, tenants, users } from '../db/schema.ts';
import { hashPassword, verifyPassword } from '../auth/password.ts';
import { generateRefreshToken, hashRefreshToken, signAccessToken } from '../auth/tokens.ts';
import { audit } from '../audit.ts';
import { config } from '../config.ts';

const cookieOpts = {
  httpOnly: true,
  secure: config.cookieSecure,
  sameSite: 'lax' as const,
  path: '/',
};

async function issueSession(reply: import('fastify').FastifyReply, userId: string, email: string) {
  const access = await signAccessToken({ sub: userId, email });
  const { token: refresh, tokenHash } = generateRefreshToken();
  await db.insert(refreshTokens).values({
    userId,
    tokenHash,
    expiresAt: new Date(Date.now() + config.refreshTokenTtlDays * 86_400_000),
  });
  reply
    .setCookie('bidrag_access', access, { ...cookieOpts, maxAge: config.accessTokenTtlSeconds })
    .setCookie('bidrag_refresh', refresh, { ...cookieOpts, maxAge: config.refreshTokenTtlDays * 86_400, path: '/v1/auth' });
}

export async function authRoutes(app: FastifyInstance) {
  app.post(
    '/v1/auth/register',
    {
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
      schema: {
        tags: ['auth'],
        body: {
          type: 'object',
          required: ['email', 'password', 'displayName'],
          properties: {
            email: { type: 'string', format: 'email', maxLength: 320 },
            password: { type: 'string', minLength: 10, maxLength: 200 },
            displayName: { type: 'string', minLength: 1, maxLength: 120 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { email, password, displayName } = request.body as {
        email: string;
        password: string;
        displayName: string;
      };
      const normalizedEmail = email.trim().toLowerCase();

      const existing = await db.select({ id: users.id }).from(users).where(eq(users.email, normalizedEmail)).limit(1);
      if (existing.length > 0) {
        return reply.code(409).send({ error: 'email_taken', message: 'E-postadressen är redan registrerad.' });
      }

      const passwordHash = await hashPassword(password);
      const [user] = await db.insert(users).values({ email: normalizedEmail, passwordHash, displayName }).returning();
      const [tenant] = await db.insert(tenants).values({ name: displayName, kind: 'personal' }).returning();
      await db.insert(memberships).values({ userId: user!.id, tenantId: tenant!.id, role: 'owner' });

      await audit({
        tenantId: tenant!.id,
        actorType: 'user',
        actorUserId: user!.id,
        action: 'user.registered',
        entityType: 'user',
        entityId: user!.id,
      });

      await issueSession(reply, user!.id, normalizedEmail);
      return reply.code(201).send({
        user: { id: user!.id, email: normalizedEmail, displayName },
        tenant: { id: tenant!.id, name: tenant!.name, kind: tenant!.kind },
      });
    },
  );

  app.post(
    '/v1/auth/login',
    {
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
      schema: {
        tags: ['auth'],
        body: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: { type: 'string', maxLength: 320 },
            password: { type: 'string', maxLength: 200 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { email, password } = request.body as { email: string; password: string };
      const [user] = await db.select().from(users).where(eq(users.email, email.trim().toLowerCase())).limit(1);
      // Constant-shape failure: same response whether the user exists or not.
      if (!user || !(await verifyPassword(password, user.passwordHash))) {
        return reply.code(401).send({ error: 'invalid_credentials', message: 'Fel e-post eller lösenord.' });
      }
      await issueSession(reply, user.id, user.email);
      await audit({ actorType: 'user', actorUserId: user.id, action: 'user.login', entityType: 'user', entityId: user.id });
      return { user: { id: user.id, email: user.email, displayName: user.displayName } };
    },
  );

  app.post('/v1/auth/refresh', { schema: { tags: ['auth'] } }, async (request, reply) => {
    const token = request.cookies?.['bidrag_refresh'];
    if (!token) return reply.code(401).send({ error: 'no_refresh_token' });
    const tokenHash = hashRefreshToken(token);
    const [row] = await db
      .select()
      .from(refreshTokens)
      .where(and(eq(refreshTokens.tokenHash, tokenHash), isNull(refreshTokens.revokedAt)))
      .limit(1);
    if (!row || row.expiresAt.getTime() < Date.now()) {
      return reply.code(401).send({ error: 'invalid_refresh_token' });
    }
    // Rotate: revoke old, issue new.
    await db.update(refreshTokens).set({ revokedAt: new Date() }).where(eq(refreshTokens.id, row.id));
    const [user] = await db.select().from(users).where(eq(users.id, row.userId)).limit(1);
    if (!user) return reply.code(401).send({ error: 'invalid_refresh_token' });
    await issueSession(reply, user.id, user.email);
    return { ok: true };
  });

  app.post('/v1/auth/logout', { schema: { tags: ['auth'] } }, async (request, reply) => {
    const token = request.cookies?.['bidrag_refresh'];
    if (token) {
      await db
        .update(refreshTokens)
        .set({ revokedAt: new Date() })
        .where(eq(refreshTokens.tokenHash, hashRefreshToken(token)));
    }
    reply.clearCookie('bidrag_access', { path: '/' }).clearCookie('bidrag_refresh', { path: '/v1/auth' });
    return { ok: true };
  });

  app.get('/v1/auth/me', { preHandler: [app.requireAuth], schema: { tags: ['auth'] } }, async (request) => {
    const auth = request.auth!;
    const rows = await db
      .select({ tenantId: memberships.tenantId, role: memberships.role, name: tenants.name, kind: tenants.kind })
      .from(memberships)
      .innerJoin(tenants, eq(memberships.tenantId, tenants.id))
      .where(eq(memberships.userId, auth.userId));
    return {
      user: { id: auth.userId, email: auth.email },
      activeTenant: { id: auth.tenantId, role: auth.role },
      tenants: rows,
    };
  });
}
