import type { FastifyInstance } from 'fastify';
import { timingSafeEqual } from 'node:crypto';
import { and, eq, isNull } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { memberships, passwordResetTokens, recoveryCodes, refreshTokens, tenants, users } from '../db/schema.ts';
import { hashPassword, verifyPassword } from '../auth/password.ts';
import {
  generateRecoveryCode,
  generateRefreshToken,
  hashRecoveryCode,
  hashRefreshToken,
  signAccessToken,
} from '../auth/tokens.ts';
import { audit } from '../audit.ts';
import { trackEvent } from '../services/events.ts';
import { config } from '../config.ts';
import { emailConfigured, sendEmail } from '../services/email.ts';

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
  /** Publik: säger om registreringen kräver inbjudningskod och om betan är på. */
  app.get('/v1/auth/register-policy', { schema: { tags: ['auth'] } }, async () => ({
    inviteRequired: config.betaInviteCodes.length > 0,
    beta: config.betaMode || config.betaInviteCodes.length > 0,
  }));

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
            inviteCode: { type: 'string', maxLength: 80 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { email, password, displayName, inviteCode } = request.body as {
        email: string;
        password: string;
        displayName: string;
        inviteCode?: string;
      };
      const normalizedEmail = email.trim().toLowerCase();

      // Sluten beta (BETA_READINESS B7): med BETA_INVITE_CODES satt krävs en
      // giltig kod. Kontrollen ligger FÖRE dubblettkollen så att en stängd
      // registrering inte läcker vilka e-postadresser som finns.
      if (config.betaInviteCodes.length > 0) {
        const given = Buffer.from((inviteCode ?? '').trim());
        const ok = config.betaInviteCodes.some((c) => {
          const b = Buffer.from(c);
          return b.length === given.length && timingSafeEqual(b, given);
        });
        if (!ok) {
          return reply.code(403).send({ error: 'invite_required', message: 'Registreringen är stängd under betan — du behöver en inbjudningskod.' });
        }
      }

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

      await trackEvent('konto_skapat', { tenantId: tenant!.id, userId: user!.id, props: { beta: config.betaInviteCodes.length > 0 } });
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

  /**
   * Lösenordsåterställning ("innan riktiga kronor"). Svaret är alltid
   * detsamma oavsett om adressen finns — ingen kontouppräkning. Token är
   * engångs, hashad i vila, 60 min TTL; mail via Resend/SMTP-adaptern.
   */
  app.post(
    '/v1/auth/request-password-reset',
    {
      config: { rateLimit: { max: 5, timeWindow: '1 minute' } },
      schema: {
        tags: ['auth'],
        body: {
          type: 'object',
          required: ['email'],
          properties: { email: { type: 'string', format: 'email', maxLength: 320 } },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      // Fail-closed: utan e-postkanal låtsas vi ALDRIG att en länk skickats.
      // Den kanal-lösa vägen är återställningskoder (/v1/auth/recover-with-code).
      if (!emailConfigured()) {
        return reply.code(503).send({
          error: 'recovery_unavailable',
          message:
            'Återställningslänk via e-post är inte tillgänglig i den här miljön. Har du sparade återställningskoder kan du använda en av dem.',
        });
      }
      const email = (request.body as { email: string }).email.trim().toLowerCase();
      const [user] = await db.select({ id: users.id }).from(users).where(eq(users.email, email)).limit(1);
      if (user) {
        const { token, tokenHash } = generateRefreshToken(); // samma kryptografi: 32 slumpbyte + SHA-256
        await db.insert(passwordResetTokens).values({
          userId: user.id,
          tokenHash,
          expiresAt: new Date(Date.now() + 60 * 60_000),
        });
        await sendEmail({
          to: email,
          subject: 'Återställ ditt lösenord — Bidragskoll.se',
          text:
            `Du (eller någon annan) har begärt att återställa lösenordet för det här kontot på Bidragskoll.se.\n\n` +
            `Återställ här (länken gäller i 60 minuter och kan bara användas en gång):\n\n` +
            `${config.publicBaseUrl}/aterstall/${token}\n\n` +
            `Om du inte begärde detta kan du bortse från det här mejlet — lösenordet är oförändrat.`,
        });
        await audit({
          tenantId: null,
          actorType: 'user',
          actorUserId: user.id,
          action: 'auth.password_reset_requested',
          entityType: 'user',
          entityId: user.id,
        });
      }
      return { ok: true };
    },
  );

  app.post(
    '/v1/auth/reset-password',
    {
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
      schema: {
        tags: ['auth'],
        body: {
          type: 'object',
          required: ['token', 'password'],
          properties: {
            token: { type: 'string', minLength: 20, maxLength: 200 },
            password: { type: 'string', minLength: 10, maxLength: 200 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { token, password } = request.body as { token: string; password: string };
      const tokenHash = hashRefreshToken(token);
      const now = new Date();

      // Engångsanvändning atomiskt: used_at sätts i samma UPDATE som villkoret
      // — två samtidiga försök med samma token kan aldrig båda lyckas.
      const claimed = await db
        .update(passwordResetTokens)
        .set({ usedAt: now })
        .where(and(eq(passwordResetTokens.tokenHash, tokenHash), isNull(passwordResetTokens.usedAt)))
        .returning();
      const row = claimed[0];
      if (!row || row.expiresAt < now) {
        return reply.code(422).send({
          error: 'invalid_token',
          message: 'Länken är ogiltig eller har gått ut. Begär en ny återställningslänk.',
        });
      }

      await db.update(users).set({ passwordHash: await hashPassword(password) }).where(eq(users.id, row.userId));
      // Lösenordsbyte dödar alla sessioner — en kapad session överlever inte.
      await db.update(refreshTokens).set({ revokedAt: now }).where(eq(refreshTokens.userId, row.userId));
      await audit({
        tenantId: null,
        actorType: 'user',
        actorUserId: row.userId,
        action: 'auth.password_reset_completed',
        entityType: 'user',
        entityId: row.userId,
      });
      return { ok: true };
    },
  );

  /**
   * Återställningskoder — den kanal-lösa återställningsvägen. Koderna visas
   * EN gång här och lagras enbart hashade; nygenerering ersätter alltid hela
   * uppsättningen (gamla koder slutar gälla omedelbart).
   */
  app.post(
    '/v1/auth/recovery-codes',
    { preHandler: [app.requireAuth], config: { rateLimit: { max: 5, timeWindow: '1 minute' } }, schema: { tags: ['auth'] } },
    async (request) => {
      const userId = request.auth!.userId;
      const fresh = Array.from({ length: 8 }, () => generateRecoveryCode());
      await db.transaction(async (tx) => {
        await tx.delete(recoveryCodes).where(eq(recoveryCodes.userId, userId));
        await tx.insert(recoveryCodes).values(fresh.map((c) => ({ userId, codeHash: c.codeHash })));
      });
      await audit({
        tenantId: null,
        actorType: 'user',
        actorUserId: userId,
        action: 'auth.recovery_codes_generated',
        entityType: 'user',
        entityId: userId,
      });
      return { codes: fresh.map((c) => c.code) };
    },
  );

  app.get('/v1/auth/recovery-codes', { preHandler: [app.requireAuth], schema: { tags: ['auth'] } }, async (request) => {
    const rows = await db
      .select({ usedAt: recoveryCodes.usedAt })
      .from(recoveryCodes)
      .where(eq(recoveryCodes.userId, request.auth!.userId));
    return { total: rows.length, remaining: rows.filter((r) => r.usedAt === null).length };
  });

  app.post(
    '/v1/auth/recover-with-code',
    {
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
      schema: {
        tags: ['auth'],
        body: {
          type: 'object',
          required: ['email', 'code', 'password'],
          properties: {
            email: { type: 'string', format: 'email', maxLength: 320 },
            code: { type: 'string', minLength: 10, maxLength: 40 },
            password: { type: 'string', minLength: 10, maxLength: 200 },
          },
          additionalProperties: false,
        },
      },
    },
    async (request, reply) => {
      const { email, code, password } = request.body as { email: string; code: string; password: string };
      const [user] = await db
        .select({ id: users.id })
        .from(users)
        .where(eq(users.email, email.trim().toLowerCase()))
        .limit(1);

      // Engångsanvändning atomiskt, precis som länk-vägen: used_at sätts i
      // samma UPDATE som villkoret — två samtidiga försök med samma kod kan
      // aldrig båda lyckas. Koden är bunden till kontots e-postadress.
      let claimed = false;
      if (user) {
        const rows = await db
          .update(recoveryCodes)
          .set({ usedAt: new Date() })
          .where(
            and(
              eq(recoveryCodes.userId, user.id),
              eq(recoveryCodes.codeHash, hashRecoveryCode(code)),
              isNull(recoveryCodes.usedAt),
            ),
          )
          .returning();
        claimed = rows.length > 0;
      }
      // Konstant svar oavsett om kontot finns eller koden är fel/förbrukad —
      // ingen kontouppräkning via den här ytan.
      if (!user || !claimed) {
        return reply.code(422).send({
          error: 'invalid_code',
          message: 'Fel e-postadress eller ogiltig/förbrukad återställningskod.',
        });
      }

      const now = new Date();
      await db.update(users).set({ passwordHash: await hashPassword(password) }).where(eq(users.id, user.id));
      // Lösenordsbyte dödar alla sessioner — en kapad session överlever inte.
      await db.update(refreshTokens).set({ revokedAt: now }).where(eq(refreshTokens.userId, user.id));
      await audit({
        tenantId: null,
        actorType: 'user',
        actorUserId: user.id,
        action: 'auth.password_reset_completed',
        entityType: 'user',
        entityId: user.id,
      });
      return { ok: true };
    },
  );

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
