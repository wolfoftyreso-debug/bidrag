/**
 * Background jobs on pg-boss (Postgres-backed queue — no extra infrastructure).
 * Används i containerdrift (långlivad process). På Vercel körs samma
 * jobbkroppar i stället via /v1/internal/cron/:job (Vercel Cron) — se
 * jobs/tasks.ts. All idempotens ligger i jobben själva (§59).
 */
import PgBoss from 'pg-boss';
import { config } from '../config.ts';
import { fetchSource } from '../services/ingestion.ts';
import { CRON_TASKS, runSourceFetchAll } from './tasks.ts';

export const QUEUES = {
  sourceFetch: 'source-fetch',
  deadlineScan: 'deadline-scan',
  staleMatchRecalc: 'stale-match-recalc',
  retention: 'retention',
} as const;

export async function startWorker(): Promise<PgBoss> {
  const boss = new PgBoss({ connectionString: config.databaseUrl, schema: 'pgboss' });
  boss.on('error', (err) => console.error('pg-boss error:', err));
  await boss.start();

  for (const q of Object.values(QUEUES)) {
    await boss.createQueue(q).catch(() => undefined);
  }

  // Källhämtning: ett riktat jobb (sourceId) är sin egen retry-enhet; utan
  // sourceId hämtas alla aktiva källor (samma kropp som cron-endpointen).
  await boss.work(QUEUES.sourceFetch, { batchSize: 1 }, async ([job]) => {
    const { sourceId } = (job!.data ?? {}) as { sourceId?: string };
    if (sourceId) await fetchSource(sourceId);
    else await runSourceFetchAll();
  });
  await boss.work(QUEUES.deadlineScan, { batchSize: 1 }, async () => {
    await CRON_TASKS['deadline-scan']!();
  });
  await boss.work(QUEUES.staleMatchRecalc, { batchSize: 1 }, async () => {
    await CRON_TASKS['stale-match-recalc']!();
  });
  await boss.work(QUEUES.retention, { batchSize: 1 }, async () => {
    await CRON_TASKS.retention!();
  });

  // Schedules (cron in UTC).
  await boss.schedule(QUEUES.sourceFetch, '0 */6 * * *', {}, {});
  await boss.schedule(QUEUES.deadlineScan, '0 6 * * *', {}, {});
  await boss.schedule(QUEUES.staleMatchRecalc, '*/15 * * * *', {}, {});
  await boss.schedule(QUEUES.retention, '30 4 * * *', {}, {});

  return boss;
}
