/**
 * Jobbkroppar, körbara från två vägar utan kodduplicering:
 *  - pg-boss-workern (containerdrift med långlivad process)
 *  - /v1/internal/cron/:job (Vercel Cron — ingen process mellan anropen)
 * Alla jobb är idempotenta och dedupliceras i data (reminders-tabellen,
 * stale-flaggan, hashade snapshots) — dubbelkörning är alltid säker.
 */
import { and, eq, gt, inArray, lt, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { feedback, fundingOpportunities, matches, memberships, notifications, payments, projects, receipts, reviewItems, sources } from '../db/schema.ts';
import { config } from '../config.ts';
import { sendEmail } from '../services/email.ts';
import { fetchSource } from '../services/ingestion.ts';
import { recomputeMatchesForProject } from '../services/matching.ts';
import { notify } from '../services/notifications.ts';
import { runDeadlineScan } from '../services/reminders.ts';
import { runRetention } from '../services/retention.ts';

/**
 * Hämta alla aktiva källor sekventiellt; varje källa felisoleras.
 *
 * Räknarna skiljer på tre utfall (revision 2026-09-01, fynd F13):
 *   fetched     — källan svarade med innehåll (2xx) och en snapshot skrevs
 *   httpErrors  — källan svarade men med fel (t.ex. 403/404/5xx); snapshot med
 *                 changeStatus 'error' och sources.last_error är satt
 *   failed      — hämtningen kastade (DNS, timeout, SSRF-vakt, okänd källa)
 * Tidigare räknades httpErrors som fetched, så jobbet rapporterade
 * "37 hämtade, 0 fel" när samtliga 37 var HTTP 403.
 */
export async function runSourceFetchAll(): Promise<{ fetched: number; httpErrors: number; failed: number }> {
  const rows = await db.select({ id: sources.id }).from(sources).where(eq(sources.active, true));
  let fetched = 0;
  let httpErrors = 0;
  let failed = 0;
  for (const row of rows) {
    try {
      const outcome = await fetchSource(row.id);
      if (outcome.changeStatus === 'error') {
        httpErrors++;
        console.error(`source fetch http error for ${row.id}: ${outcome.httpStatus ?? 'no status'} ${outcome.error ?? ''}`.trim());
      } else {
        fetched++;
      }
    } catch (err) {
      failed++;
      console.error(`source fetch failed for ${row.id}:`, (err as Error).message);
    }
  }
  return { fetched, httpErrors, failed };
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

/**
 * Vakthund (BETA_READINESS A9): minsta larmkedja utan extern monitoring.
 * Kontrollerar invarianter som inte får brytas tyst och mejlar ALERT_EMAIL
 * (via samma e-postkanal som kvittona) när något bryter — annars bara logg.
 * Varje kontroll är en egen try/catch: en trasig kontroll får inte dölja de
 * andra. Trösklarna är OPERATIONS.md §Monitoring & alerting.
 */
export async function runWatchdog(): Promise<{ ok: boolean; alarms: string[]; notified: 'sent' | 'skipped' | 'failed' | 'none' }> {
  const alarms: string[] = [];
  const check = async (name: string, fn: () => Promise<string | null>) => {
    try {
      const a = await fn();
      if (a) alarms.push(`${name}: ${a}`);
    } catch (err) {
      alarms.push(`${name}: kontrollen kraschade (${(err as Error).message})`);
    }
  };
  await check('databas', async () => { await db.execute(sql`select 1`); return null; });
  await check('källor', async () => {
    const [r] = await db.select({ n: sql<number>`count(*)::int` }).from(sources).where(sql`${sources.lastError} is not null and (${sources.lastSuccessAt} is null or ${sources.lastSuccessAt} < now() - interval '12 hours')`);
    return r && r.n > 0 ? `${r.n} källa/källor har misslyckats i över 12 timmar` : null;
  });
  await check('betalningar', async () => {
    // Bekräftad betalning utan kvitto är ett brott mot kvittoinvarianten (LIMITATIONS §10).
    const [r] = await db.select({ n: sql<number>`count(*)::int` }).from(payments)
      .where(sql`${payments.state} = 'confirmed' and not exists (select 1 from ${receipts} where ${receipts.paymentId} = ${payments.id})`);
    if (r && r.n > 0) return `${r.n} bekräftad(e) betalning(ar) saknar kvitto`;
    const [p] = await db.select({ n: sql<number>`count(*)::int` }).from(payments)
      .where(sql`${payments.state} = 'pending' and ${payments.createdAt} < now() - interval '24 hours'`);
    return p && p.n > 10 ? `${p.n} betalningar har stått som väntande i över 24 timmar` : null;
  });
  await check('granskning', async () => {
    const [r] = await db.select({ n: sql<number>`count(*)::int` }).from(reviewItems)
      .where(sql`${reviewItems.status} = 'pending' and ${reviewItems.createdAt} < now() - interval '7 days'`);
    return r && r.n > 5 ? `${r.n} granskningsärenden är äldre än 7 dagar` : null;
  });
  await check('feedback', async () => {
    const [r] = await db.select({ n: sql<number>`count(*)::int` }).from(feedback)
      .where(sql`${feedback.status} = 'new' and ${feedback.category} = 'facts' and ${feedback.createdAt} < now() - interval '48 hours'`);
    return r && r.n > 0 ? `${r.n} faktafelsrapport(er) obehandlade i över 48 timmar` : null;
  });

  let notified: 'sent' | 'skipped' | 'failed' | 'none' = 'none';
  if (alarms.length > 0) {
    console.error('[watchdog] LARM', alarms);
    if (config.alertEmail) {
      notified = await sendEmail({
        to: config.alertEmail,
        subject: `[Bidragskoll] Vakthunden larmar: ${alarms.length} avvikelse(r)`,
        text: `Vakthunden (${new Date().toISOString()}) hittade:\n\n- ${alarms.join('\n- ')}\n\nKörbok: docs/OPERATIONS.md §Incident basics.`,
      });
    }
  }
  return { ok: alarms.length === 0, alarms, notified };
}

export const CRON_TASKS: Record<string, () => Promise<unknown>> = {
  watchdog: runWatchdog,
  'source-fetch': runSourceFetchAll,
  'deadline-scan': runDeadlineScan,
  'stale-match-recalc': runStaleMatchRecalc,
  'curator-reminders': runCuratorReminders,
  retention: runRetention,
};
