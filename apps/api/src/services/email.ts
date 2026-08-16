/**
 * Email delivery adapter (§53, closes LIMITATIONS #4). Provider order:
 * Resend (RESEND_API_KEY) för transaktionsmail, annars SMTP (SMTP_URL),
 * annars hoppas leveransen över och det bokförs ärligt. Failures never break
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

async function sendViaResend(input: EmailInput): Promise<void> {
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { Authorization: `Bearer ${config.resendApiKey}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ from: config.emailFrom, to: [input.to], subject: input.subject, text: input.text }),
  });
  if (!res.ok) throw new Error(`Resend ${res.status}: ${(await res.text()).slice(0, 300)}`);
}

export async function sendEmail(input: EmailInput): Promise<'sent' | 'skipped' | 'failed'> {
  const t = getTransporter();
  if (!config.resendApiKey && !t) {
    await audit({
      tenantId: input.tenantId ?? null,
      actorType: 'system',
      action: 'email.skipped_no_provider',
      entityType: 'email',
      after: { subject: input.subject },
    });
    return 'skipped';
  }
  try {
    if (config.resendApiKey) {
      await sendViaResend(input);
    } else {
      await t!.sendMail({
        from: config.emailFrom,
        to: input.to,
        subject: input.subject,
        text: input.text,
      });
    }
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
