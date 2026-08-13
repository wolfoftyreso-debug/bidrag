/**
 * Background jobs on pg-boss (Postgres-backed queue — no extra infrastructure).
 * All jobs are idempotent; pg-boss provides retry with backoff and dead-letter
 * via failed-job records (§59).
 */
import PgBoss from 'pg-boss';
import { and, eq, isNull, lt, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { applicationCases, fundingOpportunities, matches, projects, sources } from '../db/schema.ts';
import { config } from '../config.ts';
import { fetchSource } from '../services/ingestion.ts';
import { recomputeMatchesForProject } from '../services/matching.ts';
import { notify } from '../services/notifications.ts';

export const QUEUES = {
  sourceFetch: 'source-fetch',
  deadlineScan: 'deadline-scan',
  staleMatchRecalc: 'stale-match-recalc',
} as const;

export async function startWorker(): Promise<PgBoss> {
  const boss = new PgBoss({ connectionString: config.databaseUrl, schema: 'pgboss' });
  boss.on('error', (err) => console.error('pg-boss error:', err));
  await boss.start();

  for (const q of Object.values(QUEUES)) {
    await boss.createQueue(q).catch(() => undefined);
  }

  // Fetch every active source; each fetch is its own retryable unit.
  await boss.work(QUEUES.sourceFetch, { batchSize: 1 }, async ([job]) => {
    const { sourceId } = (job!.data ?? {}) as { sourceId?: string };
    if (sourceId) {
      await fetchSource(sourceId);
      return;
    }
    const rows = await db.select({ id: sources.id }).from(sources).where(eq(sources.active, true));
    for (const row of rows) {
      await boss.send(QUEUES.sourceFetch, { sourceId: row.id }, { retryLimit: 3, retryBackoff: true });
    }
  });

  // Daily deadline scan: notify tenants with open cases approaching deadline (§36, §53).
  await boss.work(QUEUES.deadlineScan, { batchSize: 1 }, async () => {
    const soon = new Date(Date.now() + 14 * 86_400_000);
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
          lt(applicationCases.deadlineAt, soon),
          sql`${applicationCases.deadlineAt} > now()`,
        ),
      );
    for (const row of rows) {
      const days = Math.ceil((row.deadlineAt!.getTime() - Date.now()) / 86_400_000);
      await notify({
        tenantId: row.tenantId,
        kind: 'deadline_approaching',
        title: `Deadline om ${days} dagar: ${row.title}`,
        body: `Din ansökan är i läget "${row.state}". Se till att den blir klar i tid.`,
        refType: 'application_case',
        refId: row.id,
      });
    }
  });

  // Recompute matches flagged stale after rule changes (§22, §65).
  await boss.work(QUEUES.staleMatchRecalc, { batchSize: 1 }, async () => {
    const staleProjects = await db
      .selectDistinct({ projectId: matches.projectId, tenantId: matches.tenantId })
      .from(matches)
      .where(eq(matches.stale, true))
      .limit(100);
    for (const p of staleProjects) {
      await recomputeMatchesForProject(p.tenantId, p.projectId);
      const [project] = await db.select({ title: projects.title }).from(projects).where(eq(projects.id, p.projectId)).limit(1);
      await notify({
        tenantId: p.tenantId,
        kind: 'rules_changed',
        title: 'Regler har ändrats — dina matchningar har räknats om',
        body: `Ett eller flera stöd som matchats mot projektet "${project?.title ?? ''}" har uppdaterade regler. Din tidigare bedömning är inte längre aktuell.`,
        refType: 'project',
        refId: p.projectId,
      });
    }
  });

  // Schedules (cron in UTC).
  await boss.schedule(QUEUES.sourceFetch, '0 */6 * * *', {}, {});
  await boss.schedule(QUEUES.deadlineScan, '0 6 * * *', {}, {});
  await boss.schedule(QUEUES.staleMatchRecalc, '*/15 * * * *', {}, {});

  return boss;
}
