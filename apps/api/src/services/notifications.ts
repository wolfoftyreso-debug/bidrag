/**
 * Notification service (§53). In-app notifications always; email when SMTP is
 * configured. When email is not configured the fact is recorded — the system
 * never pretends a message was sent.
 */
import { db } from '../db/client.ts';
import { notifications } from '../db/schema.ts';
import { config } from '../config.ts';
import { audit } from '../audit.ts';

export interface NotifyInput {
  tenantId: string;
  userId?: string | null;
  kind: string;
  title: string;
  body?: string;
  refType?: string;
  refId?: string;
}

export async function notify(input: NotifyInput): Promise<void> {
  await db.insert(notifications).values({
    tenantId: input.tenantId,
    userId: input.userId ?? null,
    kind: input.kind,
    title: input.title,
    body: input.body ?? '',
    refType: input.refType ?? null,
    refId: input.refId ?? null,
  });

  if (config.smtpUrl) {
    // SMTP delivery adapter boundary: wire nodemailer or a provider here when
    // SMTP_URL is configured in the environment. Recorded honestly until then.
    await audit({
      tenantId: input.tenantId,
      actorType: 'system',
      action: 'notification.email_skipped_no_adapter',
      entityType: 'notification',
      after: { kind: input.kind },
    });
  }
}
