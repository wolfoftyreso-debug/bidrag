/**
 * Background jobs on pg-boss (Postgres-backed queue — no extra infrastructure).
 * All jobs are idempotent; pg-boss provides retry with backoff and dead-letter
 * via failed-job records (§59).
 */
import PgBoss from 'pg-boss';
import { eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { matches, projects, sources } from '../db/schema.ts';
import { config } from '../config.ts';
import { fetchSource } from '../services/ingestion.ts';
import { recomputeMatchesForProject } from '../services/matching.ts';
import { notify } from '../services/notifications.ts';
import { runDeadlineScan } from '../services/reminders.ts';

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

  // Deadline scan: at most one notification per case and threshold bucket
  // (deduplicated via the reminders table — safe at any schedule frequency).
  await boss.work(QUEUES.deadlineScan, { batchSize: 1 }, async () => {
    await runDeadlineScan();
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
