/**
 * Email delivery adapter — VALFRI i produktion, aldrig ett produktkrav.
 * Kvitton är förstaklass i det autentiserade kontot (Mina köp), notiser
 * finns i Inkorgen och inbjudningar har delbara länkar; mail är enbart en
 * best-effort-dublett när en kanal är konfigurerad (Resend-nyckel eller
 * SMTP_URL), annars bokförs utskicket ärligt som 'skipped'.
 *
 * Undantaget är lösenordsåterställning, som KRÄVER en kanal — den ytan
 * stänger fail-closed (503) när emailConfigured() är false i stället för
 * att låtsas skicka något (se routes/auth.ts).
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

/** Läses lazily: tester och drift kan slå av/på kanalen utan processomstart. */
export function emailConfigured(): boolean {
  return Boolean(process.env.RESEND_API_KEY || process.env.SMTP_URL);
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
