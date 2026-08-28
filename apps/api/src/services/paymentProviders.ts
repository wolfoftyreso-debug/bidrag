/**
 * Betalningsadaptrar (§68). Generiskt kontrakt: skapa betalning → bekräfta →
 * lås upp. Motorn och analysgränssnittet vet ingenting om providern.
 *
 * Swish-adaptern är integrationspunkten för produktion och kräver
 * handelsavtal + klientcertifikat mot Swish kommersiella API — den vägrar
 * ärligt tills SWISH_* är konfigurerat (se docs/LIMITATIONS.md). Mock-
 * providern finns för utveckling/test och Vercel Preview; miljögrinden
 * (aldrig i skarp produktion) ligger samlad i config.paymentsMockEnabled —
 * lägg inga egna NODE_ENV-villkor här, det var så preview-undantaget
 * neutraliserades en gång.
 */
import { config } from '../config.ts';
import { appLink, createPaymentRequest, swishConfigured } from './integrations/swish.ts';
import { createCheckoutSession, stripeConfigured } from './integrations/stripe.ts';

export interface CreatePaymentResult {
  /** Vad klienten behöver för att slutföra betalningen. */
  instructions: {
    method: string;            // 'stripe' | 'swish' | 'mock'
    /** Stripe: hosted Checkout — klienten redirectar hit. */
    redirectUrl?: string;
    /** Swish mobil: swish://paymentrequest?token=... */
    deepLink?: string;
    /** Swish desktop: QR hämtas via GET /v1/payments/:id/qr. */
    qrAvailable?: boolean;
    message: string;           // klartext till användaren
    /** Mock: bekräfta via POST /v1/payments/:id/mock-confirm. */
    mockConfirmable?: boolean;
  };
  providerReference: string | null;
  /** Provider-hemlighet som behövs senare (Swish: QR-token). Lagras, exponeras aldrig rått. */
  providerToken?: string | null;
}

export interface PaymentProvider {
  id: string;
  available(): boolean;
  create(payment: { id: string; amountMinor: number; currency: string; message: string }): Promise<CreatePaymentResult>;
}

/**
 * Swish Handel (m-commerce): payment request skapas idempotent (PUT med
 * instruktions-id härlett ur betalnings-id), token blir QR/app-länk, och
 * bekräftelsen sker ALDRIG här — bara verifierad status över mTLS kan
 * bekräfta (services/payments.ts).
 */
const swishProvider: PaymentProvider = {
  id: 'swish',
  available: swishConfigured,
  async create(p) {
    const { instructionUUID, token } = await createPaymentRequest({
      paymentId: p.id,
      amountMinor: p.amountMinor,
      currency: p.currency,
      message: p.message,
    });
    return {
      instructions: {
        method: 'swish',
        ...(token ? { deepLink: appLink(token), qrAvailable: true } : {}),
        message: 'Öppna Swish och godkänn betalningen. Sidan uppdateras när betalningen är bekräftad.',
      },
      providerReference: instructionUUID,
      providerToken: token,
    };
  },
};

/**
 * Stripe Checkout (kort m.m.) — lanseringsrälsen medan Swish dröjer. Skapar en
 * hosted Checkout Session; klienten redirectas till session.url. Bekräftelse
 * sker ALDRIG här — bara den signaturverifierade webhooken (eller
 * statuspollingens server-till-server-retrieve) kan bekräfta
 * (services/payments.ts verifyStripePayment). success/cancel leder tillbaka in
 * i appen med paymentId så frontend kan polla status.
 */
const stripeProvider: PaymentProvider = {
  id: 'stripe',
  available: stripeConfigured,
  async create(p) {
    const base = config.publicBaseUrl.replace(/\/$/, '');
    const session = await createCheckoutSession({
      paymentId: p.id,
      amountMinor: p.amountMinor,
      currency: p.currency,
      productName: 'Förberedd ansökan — Bidragskoll.se',
      successUrl: `${base}/betalning/klar?payment=${p.id}&status=success`,
      cancelUrl: `${base}/betalning/avbruten?payment=${p.id}&status=cancel`,
    });
    return {
      instructions: {
        method: 'stripe',
        redirectUrl: session.url ?? undefined,
        message: 'Du skickas vidare till Stripes säkra betalsida. Sidan uppdateras när betalningen är bekräftad.',
      },
      providerReference: session.id,
    };
  },
};

const mockProvider: PaymentProvider = {
  id: 'mock',
  available: () => config.paymentsMockEnabled,
  async create(p) {
    return {
      instructions: {
        method: 'mock',
        message: `SIMULERAD BETALNING (${(p.amountMinor / 100).toFixed(0)} kr) — endast utveckling/demo. Bekräfta för att låsa upp.`,
        mockConfirmable: true,
      },
      providerReference: `mock-${p.id}`,
    };
  },
};

// Ordning = prioritet. Riktiga providrar före mock; Stripe är lanseringsrälsen
// (Swish dröjer), så den vinner om båda mot förmodan vore konfigurerade samtidigt.
const providers: PaymentProvider[] = [stripeProvider, swishProvider, mockProvider];

export function activeProvider(): PaymentProvider | null {
  return providers.find((p) => p.available()) ?? null;
}
