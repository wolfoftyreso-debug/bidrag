/**
 * Jobbkroppar, körbara från två vägar utan kodduplicering:
 *  - pg-boss-workern (containerdrift med långlivad process)
 *  - /v1/internal/cron/:job (Vercel Cron — ingen process mellan anropen)
 * Alla jobb är idempotenta och dedupliceras i data (reminders-tabellen,
 * stale-flaggan, hashade snapshots) — dubbelkörning är alltid säker.
 */
import { eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { matches, projects, sources } from '../db/schema.ts';
import { fetchSource } from '../services/ingestion.ts';
import { recomputeMatchesForProject } from '../services/matching.ts';
import { notify } from '../services/notifications.ts';
import { runDeadlineScan } from '../services/reminders.ts';
import { runRetention } from '../services/retention.ts';

/** Hämta alla aktiva källor sekventiellt; varje källa felisoleras. */
export async function runSourceFetchAll(): Promise<{ fetched: number; failed: number }> {
  const rows = await db.select({ id: sources.id }).from(sources).where(eq(sources.active, true));
  let fetched = 0;
  let failed = 0;
  for (const row of rows) {
    try {
      await fetchSource(row.id);
      fetched++;
    } catch (err) {
      failed++;
      console.error(`source fetch failed for ${row.id}:`, (err as Error).message);
    }
  }
  return { fetched, failed };
}

/** Räkna om matchningar som flaggats stale efter regeländringar (§22, §65). */
export async function runStaleMatchRecalc(): Promise<{ recomputed: number }> {
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
  return { recomputed: staleProjects.length };
}

export const CRON_TASKS: Record<string, () => Promise<unknown>> = {
  'source-fetch': runSourceFetchAll,
  'deadline-scan': runDeadlineScan,
  'stale-match-recalc': runStaleMatchRecalc,
  retention: runRetention,
};
