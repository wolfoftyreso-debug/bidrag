/**
 * Swish Handel (Commerce API, CPC) — klient med mTLS.
 *
 * Säkerhetsmodellen är central: Swish-callbacken är INTE signerad och
 * behandlas därför aldrig som sanning. Callbacken (och klientens polling) är
 * bara en väckning — sanningen hämtas alltid server-till-server över mTLS
 * med GET /paymentrequests/{id} innan en betalning bekräftas. Vår klient-
 * identitet bevisas med handelscertifikatet; serverns identitet verifieras
 * mot CA-kedjan. Certifikat och nyckel läses som base64-PEM ur miljön
 * (serverless har inget filsystem för certfiler).
 */
import https from 'node:https';
import { URL } from 'node:url';
import { config } from '../../config.ts';

export interface SwishPaymentStatus {
  id: string;
  status: 'CREATED' | 'PAID' | 'DECLINED' | 'ERROR' | 'CANCELLED';
  amount: number;
  currency: string;
  payeePaymentReference?: string;
  paymentReference?: string;
  datePaid?: string;
  errorCode?: string;
  errorMessage?: string;
}

export function swishConfigured(): boolean {
  const s = config.swish;
  return Boolean(s.merchantAlias && s.certPemBase64 && s.keyPemBase64);
}

function decode(b64: string): Buffer {
  return Buffer.from(b64, 'base64');
}

function tlsOptions(): { cert: Buffer; key: Buffer; passphrase?: string; ca?: Buffer } {
  const s = config.swish;
  return {
    cert: decode(s.certPemBase64!),
    key: decode(s.keyPemBase64!),
    ...(s.keyPassphrase ? { passphrase: s.keyPassphrase } : {}),
    ...(s.caPemBase64 ? { ca: decode(s.caPemBase64) } : {}),
  };
}

/** Minimal mTLS-request utan extra beroenden. Timeout är obligatorisk (§17-regeln: vendors fallerar). */
function request(
  method: string,
  url: string,
  body?: unknown,
  timeoutMs = 10_000,
): Promise<{ status: number; headers: Record<string, string | string[] | undefined>; body: Buffer }> {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const payload = body === undefined ? null : Buffer.from(JSON.stringify(body));
    const req = https.request(
      {
        method,
        hostname: u.hostname,
        port: u.port || 443,
        path: u.pathname + u.search,
        timeout: timeoutMs,
        ...tlsOptions(),
        headers: {
          ...(payload ? { 'Content-Type': 'application/json', 'Content-Length': payload.length } : {}),
        },
      },
      (res) => {
        const chunks: Buffer[] = [];
        res.on('data', (c: Buffer) => chunks.push(c));
        res.on('end', () =>
          resolve({ status: res.statusCode ?? 0, headers: res.headers, body: Buffer.concat(chunks) }),
        );
      },
    );
    req.on('timeout', () => req.destroy(new Error(`Swish timeout efter ${timeoutMs} ms`)));
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

/** Payment request-id i Swish-format: betalnings-uuid utan bindestreck, versaler. */
export function toInstructionUUID(paymentId: string): string {
  return paymentId.replace(/-/g, '').toUpperCase();
}

/**
 * Skapa payment request (m-commerce: ingen payerAlias → PaymentRequestToken
 * för QR/app-öppning). PUT v2 med instruktions-id vi själva bestämmer gör
 * anropet idempotent — nätverksretry kan aldrig skapa dubbla betalningar.
 */
export async function createPaymentRequest(p: {
  paymentId: string;
  amountMinor: number;
  currency: string;
  message: string;
}): Promise<{ instructionUUID: string; token: string | null }> {
  const instructionUUID = toInstructionUUID(p.paymentId);
  const res = await request('PUT', `${config.swish.apiBase}/swish-cpcapi/api/v2/paymentrequests/${instructionUUID}`, {
    payeePaymentReference: instructionUUID.slice(0, 35),
    callbackUrl: `${config.publicBaseUrl}/v1/webhooks/payments/swish`,
    payeeAlias: config.swish.merchantAlias,
    currency: p.currency,
    amount: (p.amountMinor / 100).toFixed(2),
    message: p.message.slice(0, 50),
  });
  if (res.status !== 201) {
    throw Object.assign(
      new Error(`Swish avvisade betalningsförfrågan (${res.status}): ${res.body.toString('utf8').slice(0, 300)}`),
      { statusCode: 502 },
    );
  }
  const token = (res.headers.paymentrequesttoken as string | undefined) ?? null;
  return { instructionUUID, token };
}

/** Hämta betalningens verkliga status — den enda källan vi litar på. */
export async function retrievePaymentRequest(instructionUUID: string): Promise<SwishPaymentStatus> {
  const res = await request('GET', `${config.swish.apiBase}/swish-cpcapi/api/v1/paymentrequests/${instructionUUID}`);
  if (res.status !== 200) {
    throw Object.assign(new Error(`Swish statushämtning misslyckades (${res.status})`), { statusCode: 502 });
  }
  return JSON.parse(res.body.toString('utf8')) as SwishPaymentStatus;
}

/** App-länk för mobil: öppnar Swish direkt med förfrågan. */
export function appLink(token: string): string {
  return `swish://paymentrequest?token=${encodeURIComponent(token)}&callbackurl=${encodeURIComponent(config.publicBaseUrl)}`;
}

/** QR-kod (PNG) för desktop — hämtas från Swish QR-tjänst, proxas till klienten. */
export async function fetchQrPng(token: string, size = 300): Promise<Buffer> {
  const res = await fetch(`${config.swish.qrBase}/qrg-swish/api/v1/commerce`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token, size: String(size), format: 'png', border: '0' }),
    signal: AbortSignal.timeout(10_000),
  });
  if (!res.ok) throw Object.assign(new Error(`Swish QR-tjänst svarade ${res.status}`), { statusCode: 502 });
  return Buffer.from(await res.arrayBuffer());
}
