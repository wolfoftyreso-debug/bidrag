import type { FastifyInstance } from 'fastify';
import { and, desc, eq, isNull } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { notifications } from '../db/schema.ts';

export async function notificationRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get(
    '/v1/notifications',
    {
      schema: {
        tags: ['notifications'],
        querystring: {
          type: 'object',
          properties: { unreadOnly: { type: 'boolean' } },
          additionalProperties: false,
        },
      },
    },
    async (request) => {
      const { unreadOnly } = request.query as { unreadOnly?: boolean };
      const conditions = [eq(notifications.tenantId, request.auth!.tenantId)];
      if (unreadOnly) conditions.push(isNull(notifications.readAt));
      const rows = await db
        .select()
        .from(notifications)
        .where(and(...conditions))
        .orderBy(desc(notifications.createdAt))
        .limit(100);
      return { notifications: rows };
    },
  );

  app.post(
    '/v1/notifications/:id/read',
    {
      schema: {
        tags: ['notifications'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const rows = await db
        .update(notifications)
        .set({ readAt: new Date() })
        .where(and(eq(notifications.id, id), eq(notifications.tenantId, request.auth!.tenantId)))
        .returning({ id: notifications.id });
      if (rows.length === 0) return reply.code(404).send({ error: 'not_found' });
      return { ok: true };
    },
  );
}
