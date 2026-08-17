/**
 * Notification service (§53). In-app notifications always; email best-effort
 * to the tenant's owner/applicant members via the SMTP adapter. Every email
 * outcome (sent/skipped/failed) is recorded — never silently pretended.
 */
import { and, eq, inArray } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { memberships, notifications, users } from '../db/schema.ts';
import { sendEmail } from './email.ts';

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

  // Email the specific user when known, otherwise the tenant's owners/applicants.
  const recipients = input.userId
    ? await db.select({ email: users.email }).from(users).where(eq(users.id, input.userId))
    : await db
        .select({ email: users.email })
        .from(memberships)
        .innerJoin(users, eq(memberships.userId, users.id))
        .where(and(eq(memberships.tenantId, input.tenantId), inArray(memberships.role, ['owner', 'applicant'])));

  for (const r of recipients) {
    await sendEmail({
      to: r.email,
      subject: `Bidragskoll.se: ${input.title}`,
      text: `${input.body ?? input.title}\n\n—\nBidragskoll.se · Du kan hantera dina notiser när du är inloggad.`,
      tenantId: input.tenantId,
    });
  }
}
