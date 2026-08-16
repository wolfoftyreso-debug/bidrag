/**
 * Betalningsadaptrar (§68). Generiskt kontrakt: skapa betalning → bekräfta →
 * lås upp. Motorn och analysgränssnittet vet ingenting om providern.
 *
 * Swish-adaptern är integrationspunkten för produktion och kräver
 * handelsavtal + klientcertifikat mot Swish kommersiella API — den vägrar
 * ärligt tills SWISH_* är konfigurerat (se docs/LIMITATIONS.md). Mock-
 * providern finns för utveckling/test och kan aldrig aktiveras i produktion.
 */
import { config } from '../config.ts';

export interface CreatePaymentResult {
  /** Vad klienten behöver för att slutföra betalningen. */
  instructions: {
    method: string;            // 'swish' | 'mock'
    /** Swish: swish://paymentrequest?token=... eller QR-underlag. */
    deepLink?: string;
    message: string;           // klartext till användaren
    /** Mock: bekräfta via POST /v1/payments/:id/mock-confirm. */
    mockConfirmable?: boolean;
  };
  providerReference: string | null;
}

export interface PaymentProvider {
  id: string;
  available(): boolean;
  create(payment: { id: string; amountMinor: number; currency: string; message: string }): Promise<CreatePaymentResult>;
}

const swishProvider: PaymentProvider = {
  id: 'swish',
  available: () => Boolean(process.env.SWISH_MERCHANT_ALIAS && process.env.SWISH_CERT_PATH),
  async create() {
    // Integrationspunkt: Swish Commerce API (createPaymentRequest) med mTLS.
    // Utan avtal/certifikat vägrar vi hellre än att fejka.
    throw Object.assign(
      new Error('Swish är inte konfigurerat (kräver handelsavtal, SWISH_MERCHANT_ALIAS och klientcertifikat).'),
      { statusCode: 503 },
    );
  },
};

const mockProvider: PaymentProvider = {
  id: 'mock',
  available: () => config.paymentsMockEnabled && !config.isProd,
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

const providers: PaymentProvider[] = [swishProvider, mockProvider];

export function activeProvider(): PaymentProvider | null {
  return providers.find((p) => p.available()) ?? null;
}
