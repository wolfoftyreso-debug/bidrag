/**
 * Stripe-integration — ren fetch mot Stripe REST + node:crypto för
 * webhooksignaturen. Ingen SDK-beroende (samma minimala-beroenden-linje som
 * resten av repot; TS körs direkt). Adaptern (services/paymentProviders.ts)
 * skapar en Checkout Session; den SIGNERADE webhooken (routes/payments.ts) är
 * sanningskällan för bekräftelse, med statuspolling som fallback
 * (services/payments.ts verifyStripePayment).
 *
 * Stripe aktiveras när STRIPE_SECRET_KEY finns. Utan nyckel är stripeConfigured
 * falskt och köpytan vägrar ärligt 503 (config.ts / paymentProviders.ts).
 */
import crypto from 'node:crypto';
import { config } from '../../config.ts';

export function stripeConfigured(): boolean {
  return Boolean(config.stripe.secretKey);
}

/** Form-encoda ett djupt objekt till Stripes bracket-notation (a[b][c]=v). */
function formEncode(obj: Record<string, unknown>, prefix = ''): string {
  const parts: string[] = [];
  for (const [key, value] of Object.entries(obj)) {
    if (value === undefined || value === null) continue;
    const name = prefix ? `${prefix}[${key}]` : key;
    if (typeof value === 'object') {
      parts.push(formEncode(value as Record<string, unknown>, name));
    } else {
      parts.push(`${encodeURIComponent(name)}=${encodeURIComponent(String(value))}`);
    }
  }
  return parts.filter(Boolean).join('&');
}

async function stripeRequest(method: 'GET' | 'POST', path: string, body?: Record<string, unknown>, idempotencyKey?: string) {
  const secret = config.stripe.secretKey;
  if (!secret) throw Object.assign(new Error('Stripe är inte konfigurerat.'), { statusCode: 503 });
  const headers: Record<string, string> = {
    Authorization: `Bearer ${secret}`,
    'Stripe-Version': '2024-06-20',
  };
  let payload: string | undefined;
  if (body) {
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    payload = formEncode(body);
  }
  if (idempotencyKey) headers['Idempotency-Key'] = idempotencyKey;

  const res = await fetch(`${config.stripe.apiBase}${path}`, { method, headers, body: payload });
  const json = (await res.json().catch(() => ({}))) as Record<string, unknown>;
  if (!res.ok) {
    const err = (json.error ?? {}) as { message?: string; code?: string };
    throw Object.assign(new Error(`Stripe ${res.status}: ${err.message ?? 'okänt fel'}`), {
      statusCode: res.status >= 500 ? 502 : res.status,
      stripeCode: err.code,
    });
  }
  return json;
}

export interface StripeSession {
  id: string;
  url: string | null;
  amount_total: number | null;
  currency: string | null;
  payment_status: string | null; // 'paid' | 'unpaid' | 'no_payment_required'
  status: string | null; // 'open' | 'complete' | 'expired'
  metadata?: Record<string, string>;
  client_reference_id?: string | null;
}

/**
 * Skapa en Checkout Session (mode=payment, engångs). Idempotent på paymentId:
 * en retry ger samma session i stället för en dubblett. success/cancel pekar
 * tillbaka in i appen med paymentId så frontend kan polla status.
 */
export async function createCheckoutSession(input: {
  paymentId: string;
  amountMinor: number;
  currency: string;
  productName: string;
  successUrl: string;
  cancelUrl: string;
  customerEmail?: string | null;
}): Promise<StripeSession> {
  const body: Record<string, unknown> = {
    mode: 'payment',
    locale: 'sv',
    success_url: input.successUrl,
    cancel_url: input.cancelUrl,
    client_reference_id: input.paymentId,
    metadata: { paymentId: input.paymentId },
    payment_intent_data: { metadata: { paymentId: input.paymentId } },
    'line_items[0][quantity]': 1,
    'line_items[0][price_data][currency]': input.currency.toLowerCase(),
    'line_items[0][price_data][unit_amount]': input.amountMinor,
    'line_items[0][price_data][product_data][name]': input.productName,
  };
  if (input.customerEmail) body.customer_email = input.customerEmail;
  return (await stripeRequest('POST', '/v1/checkout/sessions', body, `checkout-${input.paymentId}`)) as unknown as StripeSession;
}

export async function retrieveCheckoutSession(sessionId: string): Promise<StripeSession> {
  return (await stripeRequest('GET', `/v1/checkout/sessions/${encodeURIComponent(sessionId)}`)) as unknown as StripeSession;
}

/**
 * Verifiera Stripes webhooksignatur (schema `t=...,v1=...`) mot den RÅA
 * bodyn med HMAC-SHA256 och webhook-hemligheten. Timing-safe jämförelse +
 * toleransfönster mot replay. Kastar vid ogiltig signatur — anroparen svarar
 * då 400 och bekräftar ingenting.
 */
export function verifyWebhookSignature(rawBody: string, signatureHeader: string | undefined, toleranceSeconds = 300): unknown {
  const secret = config.stripe.webhookSecret;
  if (!secret) throw Object.assign(new Error('STRIPE_WEBHOOK_SECRET saknas.'), { statusCode: 503 });
  if (!signatureHeader) throw Object.assign(new Error('Saknar Stripe-signatur.'), { statusCode: 400 });

  const parts = Object.fromEntries(
    signatureHeader.split(',').map((kv) => {
      const i = kv.indexOf('=');
      return [kv.slice(0, i).trim(), kv.slice(i + 1).trim()];
    }),
  ) as { t?: string; v1?: string };
  if (!parts.t || !parts.v1) throw Object.assign(new Error('Ogiltigt signaturformat.'), { statusCode: 400 });

  const expected = crypto.createHmac('sha256', secret).update(`${parts.t}.${rawBody}`, 'utf8').digest('hex');
  const a = Buffer.from(expected);
  const b = Buffer.from(parts.v1);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
    throw Object.assign(new Error('Signaturen matchar inte.'), { statusCode: 400 });
  }
  const age = Math.floor(Date.now() / 1000) - Number(parts.t);
  if (!Number.isFinite(age) || age > toleranceSeconds || age < -toleranceSeconds) {
    throw Object.assign(new Error('Signaturens tidsstämpel utanför toleransen.'), { statusCode: 400 });
  }
  return JSON.parse(rawBody);
}
