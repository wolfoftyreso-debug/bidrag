import type { FastifyInstance } from 'fastify';
import { and, eq } from 'drizzle-orm';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { randomUUID } from 'node:crypto';
import { db } from '../db/client.ts';
import { documents } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { config } from '../config.ts';
import { WRITER_ROLES } from '../plugins/auth.ts';
import { checkUpload, scanBuffer, sha256 } from '../services/uploads.ts';

export async function documentRoutes(app: FastifyInstance) {
  app.addHook('preHandler', app.requireAuth);

  app.get('/v1/documents', { schema: { tags: ['documents'] } }, async (request) => {
    const rows = await db
      .select({
        id: documents.id,
        filename: documents.filename,
        contentType: documents.contentType,
        sizeBytes: documents.sizeBytes,
        kind: documents.kind,
        scanStatus: documents.scanStatus,
        createdAt: documents.createdAt,
      })
      .from(documents)
      .where(eq(documents.tenantId, request.auth!.tenantId));
    return { documents: rows };
  });

  /** Multipart upload. Field name: "file"; optional field "kind" (evidence kind). */
  app.post(
    '/v1/documents',
    { preHandler: app.requireRole(...WRITER_ROLES), schema: { tags: ['documents'] } },
    async (request, reply) => {
      const file = await request.file();
      if (!file) return reply.code(400).send({ error: 'no_file', message: 'Ingen fil bifogades.' });

      const content = await file.toBuffer();
      const kindField = file.fields['kind'];
      const kind =
        kindField && 'value' in kindField && typeof kindField.value === 'string' ? kindField.value : 'other';

      const check = checkUpload(file.filename, file.mimetype, content);
      if (!check.ok) {
        return reply.code(422).send({ error: 'invalid_file', message: check.reason });
      }

      const scanStatus = await scanBuffer(content);
      if (scanStatus === 'blocked') {
        await audit({
          tenantId: request.auth!.tenantId,
          actorType: 'user',
          actorUserId: request.auth!.userId,
          action: 'document.blocked_by_scan',
          entityType: 'document',
          after: { filename: file.filename },
        });
        return reply.code(422).send({ error: 'malware_detected', message: 'Filen stoppades av säkerhetskontrollen.' });
      }

      const tenantId = request.auth!.tenantId;
      const digest = sha256(content);
      // Tenant-scoped storage path with opaque name (§27).
      const relPath = path.join(tenantId, `${randomUUID()}${path.extname(file.filename.toLowerCase())}`);
      const absPath = path.join(config.uploadDir, relPath);
      await mkdir(path.dirname(absPath), { recursive: true });
      await writeFile(absPath, content);

      const [row] = await db
        .insert(documents)
        .values({
          tenantId,
          filename: file.filename,
          contentType: file.mimetype,
          sizeBytes: content.length,
          sha256: digest,
          storagePath: relPath,
          kind,
          scanStatus,
          uploadedBy: request.auth!.userId,
        })
        .returning();

      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'document.uploaded',
        entityType: 'document',
        entityId: row!.id,
        after: { filename: file.filename, kind, sha256: digest, scanStatus },
      });

      return reply.code(201).send({ document: row });
    },
  );

  app.get(
    '/v1/documents/:id/download',
    {
      schema: {
        tags: ['documents'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const [row] = await db
        .select()
        .from(documents)
        .where(and(eq(documents.id, id), eq(documents.tenantId, request.auth!.tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      const content = await readFile(path.join(config.uploadDir, row.storagePath));
      return reply
        .header('Content-Type', row.contentType)
        .header('Content-Disposition', `attachment; filename="${encodeURIComponent(row.filename)}"`)
        .header('X-Content-Type-Options', 'nosniff')
        .send(content);
    },
  );

  app.delete(
    '/v1/documents/:id',
    {
      preHandler: app.requireRole(...WRITER_ROLES),
      schema: {
        tags: ['documents'],
        params: { type: 'object', properties: { id: { type: 'string', format: 'uuid' } }, required: ['id'] },
      },
    },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const tenantId = request.auth!.tenantId;
      const [row] = await db
        .select()
        .from(documents)
        .where(and(eq(documents.id, id), eq(documents.tenantId, tenantId)))
        .limit(1);
      if (!row) return reply.code(404).send({ error: 'not_found' });
      await db.delete(documents).where(and(eq(documents.id, id), eq(documents.tenantId, tenantId)));
      await audit({
        tenantId,
        actorType: 'user',
        actorUserId: request.auth!.userId,
        action: 'document.deleted',
        entityType: 'document',
        entityId: id,
        before: { filename: row.filename },
      });
      return { ok: true };
    },
  );
}
