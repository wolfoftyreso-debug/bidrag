/**
 * Deadline reminder scan (§36, §53). Idempotent: each case gets at most one
 * notification per threshold bucket (14/7/3 days), deduplicated through the
 * reminders table — running the scan hourly or daily never spams the user.
 */
import { and, eq, lt, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { applicationCases, fundingOpportunities, reminders } from '../db/schema.ts';
import { notify } from './notifications.ts';

const OPEN_STATES = ['SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT'];

function bucketFor(daysLeft: number): string | null {
  if (daysLeft <= 3) return 'deadline_3d';
  if (daysLeft <= 7) return 'deadline_7d';
  if (daysLeft <= 14) return 'deadline_14d';
  return null;
}

export async function runDeadlineScan(now = new Date()): Promise<{ notified: number }> {
  const horizon = new Date(now.getTime() + 14 * 86_400_000);
  const rows = await db
    .select({
      id: applicationCases.id,
      tenantId: applicationCases.tenantId,
      deadlineAt: applicationCases.deadlineAt,
      state: applicationCases.state,
      title: fundingOpportunities.title,
    })
    .from(applicationCases)
    .innerJoin(fundingOpportunities, eq(applicationCases.opportunityId, fundingOpportunities.id))
    .where(
      and(
        sql`${applicationCases.state} IN ('SELECTED','PREPARING','READY_FOR_REVIEW','READY_TO_SUBMIT')`,
        lt(applicationCases.deadlineAt, horizon),
        sql`${applicationCases.deadlineAt} > ${now.toISOString()}::timestamptz`,
      ),
    );

  let notified = 0;
  for (const row of rows) {
    if (!OPEN_STATES.includes(row.state)) continue;
    const daysLeft = Math.ceil((row.deadlineAt!.getTime() - now.getTime()) / 86_400_000);
    const kind = bucketFor(daysLeft);
    if (!kind) continue;

    const [existing] = await db
      .select({ id: reminders.id })
      .from(reminders)
      .where(and(eq(reminders.caseId, row.id), eq(reminders.kind, kind)))
      .limit(1);
    if (existing) continue;

    await db.insert(reminders).values({
      tenantId: row.tenantId,
      caseId: row.id,
      kind,
      dueAt: row.deadlineAt!,
      sentAt: now,
    });
    await notify({
      tenantId: row.tenantId,
      kind: 'deadline_approaching',
      title: `Deadline om ${daysLeft} ${daysLeft === 1 ? 'dag' : 'dagar'}: ${row.title}`,
      body: `Din ansökan är i läget "${row.state}". Se till att den blir klar i tid.`,
      refType: 'application_case',
      refId: row.id,
    });
    notified++;
  }
  return { notified };
}
