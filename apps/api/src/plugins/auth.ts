/**
 * Authentication + tenant-context plugin.
 *
 * Tenant isolation is a security invariant (§27): every authenticated request
 * resolves an explicit tenant context from a verified membership. Handlers
 * receive request.auth = { userId, email, tenantId, role } and must scope all
 * queries by tenantId.
 */
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import { and, eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { memberships } from '../db/schema.ts';
import { verifyAccessToken } from '../auth/tokens.ts';

export type Role =
  | 'owner'
  | 'applicant'
  | 'contributor'
  | 'reviewer'
  | 'finance'
  | 'administrator'
  | 'data_curator'
  | 'integration_operator';

export interface AuthContext {
  userId: string;
  email: string;
  tenantId: string;
  role: Role;
}

declare module 'fastify' {
  interface FastifyRequest {
    auth: AuthContext | null;
  }
  interface FastifyInstance {
    requireAuth: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
    requireRole: (...roles: Role[]) => (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
}

/** Roles allowed to write applicant data. */
export const WRITER_ROLES: Role[] = ['owner', 'applicant', 'contributor', 'administrator'];
/**
 * Roles allowed to curate the SHARED funding knowledge graph.
 *
 * Deliberately ONLY `data_curator` — never `administrator`. `administrator` is
 * a tenant-scoped team-management role that a self-service org owner can grant
 * via /v1/tenant/invites; conflating it with curation would let anyone with
 * two accounts escalate to platform-wide authority over the knowledge graph
 * (rule versions, human_verified stamps, source registry) that every tenant
 * matches against. `data_curator` is a platform-trusted role and is therefore
 * NOT invitable (see INVITABLE_ROLES) — it is assigned out-of-band only.
 */
export const CURATOR_ROLES: Role[] = ['data_curator'];

async function resolveAuth(request: FastifyRequest): Promise<AuthContext | null> {
  let token: string | undefined;
  const header = request.headers.authorization;
  if (header?.startsWith('Bearer ')) token = header.slice(7);
  if (!token) token = request.cookies?.['bidrag_access'];
  if (!token) return null;

  const claims = await verifyAccessToken(token);
  if (!claims) return null;

  const requestedTenant = request.headers['x-tenant-id'];
  const rows = await db
    .select()
    .from(memberships)
    .where(
      typeof requestedTenant === 'string' && requestedTenant.length > 0
        ? and(eq(memberships.userId, claims.sub), eq(memberships.tenantId, requestedTenant))
        : eq(memberships.userId, claims.sub),
    )
    // Deterministic default tenant: the oldest membership (the personal one).
    .orderBy(memberships.createdAt)
    .limit(1);

  const membership = rows[0];
  if (!membership) return null;

  return {
    userId: claims.sub,
    email: claims.email,
    tenantId: membership.tenantId,
    role: membership.role as Role,
  };
}

export const authPlugin = fp(async (app: FastifyInstance) => {
  app.decorateRequest('auth', null);

  app.addHook('onRequest', async (request) => {
    request.auth = await resolveAuth(request);
  });

  app.decorate('requireAuth', async (request: FastifyRequest, reply: FastifyReply) => {
    if (!request.auth) {
      await reply.code(401).send({ error: 'unauthenticated', message: 'Du måste vara inloggad.' });
    }
  });

  app.decorate('requireRole', (...roles: Role[]) => {
    return async (request: FastifyRequest, reply: FastifyReply) => {
      if (!request.auth) {
        await reply.code(401).send({ error: 'unauthenticated', message: 'Du måste vara inloggad.' });
        return;
      }
      if (!roles.includes(request.auth.role)) {
        await reply.code(403).send({ error: 'forbidden', message: 'Du saknar behörighet för den här åtgärden.' });
      }
    };
  });
});
