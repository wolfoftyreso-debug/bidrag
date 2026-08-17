/**
 * Jobbkroppar, körbara från två vägar utan kodduplicering:
 *  - pg-boss-workern (containerdrift med långlivad process)
 *  - /v1/internal/cron/:job (Vercel Cron — ingen process mellan anropen)
 * Alla jobb är idempotenta och dedupliceras i data (reminders-tabellen,
 * stale-flaggan, hashade snapshots) — dubbelkörning är alltid säker.
 */
import { and, eq, gt, inArray, lt, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { fundingOpportunities, matches, memberships, notifications, projects, reviewItems, sources } from '../db/schema.ts';
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

/**
 * Kuratorspåminnelser (masterrevisionens farligaste risk: kurerad regeldata
 * som åldras i tysthet). Förfallna källgranskningar och väntande källändringar
 * ska inte bara synas i kuratorskön — de ska knacka på. Dedupliceras per
 * kurator och dygn; körningen är idempotent.
 */
export async function runCuratorReminders(): Promise<{ overdue: number; pendingReview: number; notified: number }> {
  const now = new Date();
  const [overdueRow] = await db
    .select({ n: sql<number>`count(*)::int` })
    .from(fundingOpportunities)
    .where(and(eq(fundingOpportunities.status, 'published'), lt(fundingOpportunities.nextReviewAt, now)));
  const [pendingRow] = await db
    .select({ n: sql<number>`count(*)::int` })
    .from(reviewItems)
    .where(eq(reviewItems.status, 'pending'));
  const overdue = Number(overdueRow?.n ?? 0);
  const pendingReview = Number(pendingRow?.n ?? 0);
  if (overdue === 0 && pendingReview === 0) return { overdue, pendingReview, notified: 0 };

  const curators = await db
    .select({ userId: memberships.userId, tenantId: memberships.tenantId })
    .from(memberships)
    .where(inArray(memberships.role, ['administrator', 'data_curator']));
  const cutoff = new Date(now.getTime() - 20 * 3_600_000);
  let notified = 0;
  for (const c of curators) {
    const [recent] = await db
      .select({ id: notifications.id })
      .from(notifications)
      .where(
        and(
          eq(notifications.userId, c.userId),
          eq(notifications.kind, 'curator_review_due'),
          gt(notifications.createdAt, cutoff),
        ),
      )
      .limit(1);
    if (recent) continue;
    await notify({
      tenantId: c.tenantId,
      userId: c.userId,
      kind: 'curator_review_due',
      title: 'Kunskapsbasen behöver kuratorsgranskning',
      body: `${overdue} stöd har passerat sitt granskningsdatum och ${pendingReview} källändringar väntar på beslut. Inaktuella regler är systemets största kvalitetsrisk — gå till kuratorsvyn.`,
      refType: 'admin',
    });
    notified++;
  }
  return { overdue, pendingReview, notified };
}

export const CRON_TASKS: Record<string, () => Promise<unknown>> = {
  'source-fetch': runSourceFetchAll,
  'deadline-scan': runDeadlineScan,
  'stale-match-recalc': runStaleMatchRecalc,
  'curator-reminders': runCuratorReminders,
  retention: runRetention,
};
