import Fastify, { type FastifyInstance } from 'fastify';
import cookie from '@fastify/cookie';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import multipart from '@fastify/multipart';
import rateLimit from '@fastify/rate-limit';
import fastifyStatic from '@fastify/static';
import swagger from '@fastify/swagger';
import { randomUUID } from 'node:crypto';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { config } from './config.ts';
import { pool } from './db/client.ts';
import { authPlugin } from './plugins/auth.ts';
import { metricsPlugin } from './plugins/metrics.ts';
import { originGuardPlugin } from './plugins/originGuard.ts';
import { gdprRoutes } from './routes/gdpr.ts';
import { teamRoutes } from './routes/team.ts';
import { paymentRoutes, paymentWebhookRoutes } from './routes/payments.ts';
import { authRoutes } from './routes/auth.ts';
import { profileRoutes } from './routes/profiles.ts';
import { projectRoutes } from './routes/projects.ts';
import { opportunityRoutes } from './routes/opportunities.ts';
import { applicationRoutes } from './routes/applications.ts';
import { documentRoutes } from './routes/documents.ts';
import { correspondenceRoutes } from './routes/correspondence.ts';
import { notificationRoutes } from './routes/notifications.ts';
import { adminRoutes } from './routes/admin.ts';
import { internalRoutes } from './routes/internal.ts';
import { documentStudioRoutes } from './routes/documentStudio.ts';

export async function buildServer(): Promise<FastifyInstance> {
  const app = Fastify({
    logger: {
      level: config.logLevel,
      redact: ['req.headers.authorization', 'req.headers.cookie'],
    },
    genReqId: () => randomUUID(),
    bodyLimit: 1 * 1024 * 1024,
    trustProxy: true,
  });

  await app.register(helmet, {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        imgSrc: ["'self'", 'data:'],
        objectSrc: ["'none'"],
        frameAncestors: ["'none'"],
      },
    },
  });
  await app.register(cors, {
    origin: config.corsOrigin.split(','),
    credentials: true,
  });
  await app.register(cookie);
  await app.register(rateLimit, {
    max: config.rateLimitMax,
    timeWindow: '1 minute',
  });
  await app.register(multipart, {
    limits: { fileSize: config.maxUploadBytes, files: 1 },
  });
  await app.register(swagger, {
    openapi: {
      openapi: '3.1.0',
      info: {
        title: 'Bidrag.se API',
        description: 'Funding discovery, eligibility, application and case-management platform.',
        version: '1.0.0',
      },
      servers: [{ url: '/' }],
    },
  });

  // User-safe error handling (§61) — MUST be set before route registration:
  // encapsulated route contexts capture the error handler at register time,
  // so a handler set afterwards never applies to them. Found by failure
  // injection (a DB outage leaked "connect ECONNREFUSED" to the client).
  app.setErrorHandler((error: Error & { validation?: unknown; statusCode?: number }, request, reply) => {
    if (error.validation) {
      return reply.code(400).send({ error: 'validation_error', message: error.message });
    }
    const status = error.statusCode ?? 500;
    if (status >= 500) {
      request.log.error({ err: error, reqId: request.id }, 'unhandled error');
      return reply.code(500).send({ error: 'internal_error', message: 'Ett oväntat fel inträffade.', requestId: request.id });
    }
    return reply.code(status).send({ error: error.name, message: error.message });
  });

  await app.register(originGuardPlugin);
  await app.register(authPlugin);
  await app.register(metricsPlugin);

  // Liveness/readiness probes (§63).
  app.get('/healthz', async () => ({ ok: true }));
  app.get('/readyz', async (_request, reply) => {
    try {
      await pool.query('SELECT 1');
      return { ok: true };
    } catch {
      return reply.code(503).send({ ok: false });
    }
  });

  app.get('/v1/openapi.json', async () => app.swagger());

  await app.register(authRoutes);
  await app.register(profileRoutes);
  await app.register(projectRoutes);
  await app.register(opportunityRoutes);
  await app.register(applicationRoutes);
  await app.register(documentRoutes);
  await app.register(correspondenceRoutes);
  await app.register(notificationRoutes);
  await app.register(gdprRoutes);
  await app.register(teamRoutes);
  await app.register(paymentRoutes);
  await app.register(paymentWebhookRoutes);
  await app.register(documentStudioRoutes);
  await app.register(internalRoutes);
  await app.register(adminRoutes);

  // Serve the built SPA when co-deployed (WEB_DIST) with an SPA fallback.
  const webDist = process.env.WEB_DIST ? path.resolve(process.env.WEB_DIST) : null;
  if (webDist && existsSync(webDist)) {
    await app.register(fastifyStatic, { root: webDist, wildcard: false });
    app.setNotFoundHandler(async (request, reply) => {
      if (request.method === 'GET' && !request.url.startsWith('/v1/')) {
        return reply.sendFile('index.html');
      }
      return reply.code(404).send({ error: 'not_found' });
    });
  }

  return app;
}
