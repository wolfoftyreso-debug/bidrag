/**
 * Configuration. All secrets come from the environment (Kubernetes Secrets in
 * production) — never from code. Missing critical secrets fail fast in
 * production and fall back to ephemeral values only in development/test.
 */
import { randomBytes } from 'node:crypto';

const env = process.env;
const isProd = env.NODE_ENV === 'production';

function required(name: string, devFallback?: string): string {
  const v = env[name];
  if (v) return v;
  if (isProd) throw new Error(`Missing required environment variable ${name}`);
  return devFallback ?? '';
}

export const config = {
  nodeEnv: env.NODE_ENV ?? 'development',
  isProd,
  port: Number(env.PORT ?? 3000),
  host: env.HOST ?? '0.0.0.0',
  databaseUrl: required('DATABASE_URL', 'postgres://postgres@localhost:5432/bidrag'),
  /** HS256 signing key for short-lived access tokens. */
  authSecret: required('AUTH_SECRET', randomBytes(32).toString('hex')),
  /** AES-256-GCM key (hex, 32 bytes) for field-level encryption of external identifiers. */
  fieldEncryptionKey: required('FIELD_ENCRYPTION_KEY', randomBytes(32).toString('hex')),
  accessTokenTtlSeconds: Number(env.ACCESS_TOKEN_TTL ?? 900),
  refreshTokenTtlDays: Number(env.REFRESH_TOKEN_TTL_DAYS ?? 30),
  cookieSecure: isProd,
  uploadDir: env.UPLOAD_DIR ?? './uploads',
  maxUploadBytes: Number(env.MAX_UPLOAD_BYTES ?? 20 * 1024 * 1024),
  /** Optional SMTP URL; when absent, email notifications are recorded as skipped. */
  smtpUrl: env.SMTP_URL ?? null,
  emailFrom: env.EMAIL_FROM ?? 'no-reply@bidrag.se',
  /** Public base URL used in links. */
  publicBaseUrl: env.PUBLIC_BASE_URL ?? 'http://localhost:5173',
  corsOrigin: env.CORS_ORIGIN ?? 'http://localhost:5173',
  /** ClamAV daemon address (host:port) when malware scanning is deployed. */
  clamavAddress: env.CLAMAV_ADDRESS ?? null,
  /** Global per-IP rate limit per minute (auth endpoints have stricter own limits). */
  rateLimitMax: Number(env.RATE_LIMIT_MAX ?? 300),
  logLevel: env.LOG_LEVEL ?? 'info',
};
