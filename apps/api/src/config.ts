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
  emailFrom: env.EMAIL_FROM ?? 'no-reply@bidragskoll.se',
  /** Public base URL used in links. */
  publicBaseUrl: env.PUBLIC_BASE_URL ?? 'http://localhost:5173',
  corsOrigin: env.CORS_ORIGIN ?? 'http://localhost:5173',
  /** ClamAV daemon address (host:port) when malware scanning is deployed. */
  clamavAddress: env.CLAMAV_ADDRESS ?? null,
  /** Global per-IP rate limit per minute (auth endpoints have stricter own limits). */
  rateLimitMax: Number(env.RATE_LIMIT_MAX ?? 300),
  /**
   * Open Discovery-prismodellen: att upptäcka stöd och se resultaten är gratis
   * (ingen analysupplåsning finns kvar). Det enda som kostar är att förbereda en
   * ansökan i systemet — 19 kr per ansökan, alla dokument för den ansökan ingår.
   * Aldrig styckdebitering per dokument, aldrig prenumeration.
   */
  applicationPriceMinor: Number(env.APPLICATION_PRICE_MINOR ?? 1900),
  /**
   * Mockbetalningar för utveckling/test — kan aldrig aktiveras i skarp
   * produktion. Undantag: Vercels PREVIEW-miljöer (VERCEL_ENV='preview')
   * kör med NODE_ENV=production men är avsedda för test — där tillåts
   * mocken när flaggan uttryckligen är satt, så att hela köpflödet går
   * att felsöka i en deployad fullversion före Swish-avtalet. I
   * produktionsmiljön (VERCEL_ENV='production' eller ingen Vercel alls)
   * är mocken strukturellt avstängd precis som förut.
   */
  paymentsMockEnabled:
    env.PAYMENTS_MOCK_ENABLED === 'true' && (env.NODE_ENV !== 'production' || env.VERCEL_ENV === 'preview'),
  /**
   * Generation mode (AI-spec §32): textförslag via LLM, alltid bakom de
   * deterministiska vakterna i @bidrag/core. Anthropic-nyckeln aktiverar i
   * drift; mocken fungerar ALDRIG i produktion (samma regel som betalmocken).
   */
  anthropicApiKey: env.ANTHROPIC_API_KEY ?? null,
  generationMockEnabled:
    env.GENERATION_MOCK_ENABLED === 'true' && (env.NODE_ENV !== 'production' || env.VERCEL_ENV === 'preview'),
  /**
   * Momssats i baspunkter. Analysupplåsningen och dokumentförberedelsen är
   * elektroniskt levererade tjänster till konsument i Sverige — standardmoms
   * 25 % (ML 7 kap. 1 §). Medvetet inte en miljövariabel: en felkonfigurerad
   * sats skulle ge felaktiga kvitton och fel i momsredovisningen.
   */
  vatRateBps: 2500,
  /**
   * Säljaruppgifter som fryses på varje kvitto/verifikation. Bidragskoll.se drivs
   * av Landvex AB (org.nr 559141-7042, Tyresö); momsregistreringsnumret är
   * standardhärlett (SE + orgnr + 01). Env-variablerna finns kvar som
   * override om bolagsuppgifterna ändras.
   */
  sellerName: env.SELLER_NAME ?? 'Landvex AB',
  sellerOrgNumber: env.SELLER_ORG_NUMBER ?? '559141-7042',
  sellerVatNumber: env.SELLER_VAT_NUMBER ?? 'SE559141704201',
  sellerAddress: env.SELLER_ADDRESS ?? 'Antennvägen 2, 135 48 Tyresö',
  /** Resend för transaktionsmail (kvitton). Faller tillbaka på SMTP_URL, annars ärligt hoppat. */
  resendApiKey: env.RESEND_API_KEY ?? null,
  /**
   * Objektlagring: 'disk' (default — lokal utveckling/test/container) eller
   * 'supabase' (krav på Vercel: funktioner saknar beständigt filsystem).
   */
  storageDriver: (env.STORAGE_DRIVER ?? 'disk') as 'disk' | 'supabase' | 'postgres',
  supabaseUrl: env.SUPABASE_URL ?? null,
  supabaseServiceRoleKey: env.SUPABASE_SERVICE_ROLE_KEY ?? null,
  supabaseStorageBucket: env.SUPABASE_STORAGE_BUCKET ?? 'documents',
  /**
   * Skyddar de interna cron-endpointsen (/v1/internal/cron/:job). Vercel Cron
   * skickar automatiskt "Authorization: Bearer $CRON_SECRET" när variabeln
   * finns i miljön. Utan satt hemlighet är endpointsen avstängda (404).
   */
  cronSecret: env.CRON_SECRET ?? null,
  /**
   * Swish Handel (Commerce API, mTLS). Klientcertifikat + nyckel som
   * base64-PEM i miljövariabler — serverless har inget filsystem för
   * certifikatfiler. SWISH_API_BASE byts till MSS-simulatorn i test/preview
   * (https://mss.cpc.getswish.net) och till den lokala testservern i CI.
   */
  // Läses vid anropstillfället (getters): integrationstester genererar
  // certifikat i runtime, och certrotation i drift kräver ingen omstart av
  // konfigurationsmodulen. I produktion är värdena i praktiken statiska.
  swish: {
    get merchantAlias() { return process.env.SWISH_MERCHANT_ALIAS ?? null; },
    get certPemBase64() { return process.env.SWISH_CERT_BASE64 ?? null; },
    get keyPemBase64() { return process.env.SWISH_KEY_BASE64 ?? null; },
    get keyPassphrase() { return process.env.SWISH_KEY_PASSPHRASE ?? null; },
    /** Extra CA (PEM base64) för att lita på Swish-serverkedjan; krävs i test. */
    get caPemBase64() { return process.env.SWISH_CA_BASE64 ?? null; },
    get apiBase() { return process.env.SWISH_API_BASE ?? 'https://cpc.getswish.net'; },
    get qrBase() { return process.env.SWISH_QR_BASE ?? 'https://mpc.getswish.net'; },
  },
  /**
   * Stripe Checkout (kort m.m.) — lanseringsrälsen medan Swish-avtalet dröjer.
   * STRIPE_SECRET_KEY aktiverar providern; STRIPE_WEBHOOK_SECRET krävs för att
   * bekräfta betalningar (den signerade webhooken är sanningskällan). Utan
   * nycklar vägrar köpytan ärligt 503 — precis som Swish. STRIPE_API_BASE pekas
   * om mot en lokal emulator i integrationstesterna. Getters: ingen omstart
   * krävs vid nyckelrotation, och testerna sätter env i runtime.
   */
  stripe: {
    get secretKey() { return process.env.STRIPE_SECRET_KEY ?? null; },
    get webhookSecret() { return process.env.STRIPE_WEBHOOK_SECRET ?? null; },
    get apiBase() { return process.env.STRIPE_API_BASE ?? 'https://api.stripe.com'; },
  },
  logLevel: env.LOG_LEVEL ?? 'info',
};
