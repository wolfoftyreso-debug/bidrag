/**
 * Email delivery adapter (§53, closes LIMITATIONS #4). Activated by SMTP_URL;
 * without it, delivery is skipped and honestly recorded. Failures never break
 * the caller — email is best-effort on top of the in-app notification, and
 * every outcome (sent/failed/skipped) is auditable.
 */
import nodemailer, { type Transporter } from 'nodemailer';
import { config } from '../config.ts';
import { audit } from '../audit.ts';

let transporter: Transporter | null | undefined;

/** Test seam: inject a transport (e.g. jsonTransport) instead of SMTP. */
export function setTransportForTesting(t: Transporter | null): void {
  transporter = t;
}

function getTransporter(): Transporter | null {
  if (transporter !== undefined) return transporter;
  transporter = config.smtpUrl ? nodemailer.createTransport(config.smtpUrl) : null;
  return transporter;
}

export interface EmailInput {
  to: string;
  subject: string;
  text: string;
  tenantId?: string | null;
}

export async function sendEmail(input: EmailInput): Promise<'sent' | 'skipped' | 'failed'> {
  const t = getTransporter();
  if (!t) {
    await audit({
      tenantId: input.tenantId ?? null,
      actorType: 'system',
      action: 'email.skipped_no_smtp',
      entityType: 'email',
      after: { subject: input.subject },
    });
    return 'skipped';
  }
  try {
    await t.sendMail({
      from: config.emailFrom,
      to: input.to,
      subject: input.subject,
      text: `${input.text}\n\n—\nBidrag.se · Du kan hantera dina notiser när du är inloggad.`,
    });
    return 'sent';
  } catch (err) {
    await audit({
      tenantId: input.tenantId ?? null,
      actorType: 'system',
      action: 'email.delivery_failed',
      entityType: 'email',
      after: { subject: input.subject, error: (err as Error).message },
    });
    return 'failed';
  }
}
