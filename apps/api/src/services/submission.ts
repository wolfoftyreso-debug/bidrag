/**
 * Submission gateway (§16, §46).
 *
 * Adapters are registered per opportunity/authority. Levels:
 *   native     — supported machine interface; submits and returns verifiable confirmation.
 *   structured — maintained adapter over an official web e-service.
 *   assisted   — we prepare the complete package; the user completes the
 *                official submission and records the receipt. The case is
 *                never marked SUBMITTED without a receipt.
 *
 * No native or structured adapters ship yet, because none of the wave-1
 * authorities exposes a supported public submission API (see docs/LIMITATIONS.md).
 * The registry is the integration boundary: adding an authorised adapter does
 * not change the application flow.
 */
import { createHash } from 'node:crypto';

export interface SubmissionPayload {
  caseId: string;
  opportunitySlug: string;
  answers: Record<string, unknown>;
  budgetLines: unknown[];
  financing: unknown;
  attachments: { documentId: string; filename: string; sha256: string }[];
}

export interface AdapterResult {
  ok: boolean;
  confirmationReference?: string;
  error?: string;
}

export interface SubmissionAdapter {
  id: string;
  level: 'native' | 'structured';
  /** Which opportunity slugs (or authority ids) this adapter serves. */
  supports(opportunitySlug: string): boolean;
  submit(payload: SubmissionPayload): Promise<AdapterResult>;
}

const registry: SubmissionAdapter[] = [];

export function registerAdapter(adapter: SubmissionAdapter): void {
  registry.push(adapter);
}

export function findAdapter(opportunitySlug: string): SubmissionAdapter | undefined {
  return registry.find((a) => a.supports(opportunitySlug));
}

/** Deterministic hash of the exact prepared package — submission evidence. */
export function hashPayload(payload: SubmissionPayload): string {
  return createHash('sha256').update(JSON.stringify(payload)).digest('hex');
}
