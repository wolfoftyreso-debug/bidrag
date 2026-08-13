/**
 * Retention job (§29, GDPR storage limitation). Time-based purging of data
 * that has served its purpose. Everything here is deliberately conservative
 * and logged; applicant content (profiles, cases, documents) is NEVER purged
 * automatically — that is the user's own data, removed via erasure.
 */
import { and, isNotNull, lt, or, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { notifications, refreshTokens, sourceSnapshots } from '../db/schema.ts';
import { audit } from '../audit.ts';

export interface RetentionPolicy {
  /** Revoked or expired refresh tokens older than this many days. */
  refreshTokenDays: number;
  /** Read notifications older than this many days. */
  readNotificationDays: number;
  /** Keep at most this many snapshots per source (raw evidence for the newest is always kept). */
  snapshotsPerSource: number;
}

export const DEFAULT_RETENTION: RetentionPolicy = {
  refreshTokenDays: 35,
  readNotificationDays: 90,
  snapshotsPerSource: 25,
};

export async function runRetention(policy: RetentionPolicy = DEFAULT_RETENTION, now = new Date()): Promise<{
  refreshTokens: number;
  notifications: number;
  snapshots: number;
}> {
  const tokenCutoff = new Date(now.getTime() - policy.refreshTokenDays * 86_400_000);
  const deletedTokens = await db
    .delete(refreshTokens)
    .where(or(lt(refreshTokens.expiresAt, tokenCutoff), and(isNotNull(refreshTokens.revokedAt), lt(refreshTokens.createdAt, tokenCutoff))))
    .returning({ id: refreshTokens.id });

  const notifCutoff = new Date(now.getTime() - policy.readNotificationDays * 86_400_000);
  const deletedNotifs = await db
    .delete(notifications)
    .where(and(isNotNull(notifications.readAt), lt(notifications.createdAt, notifCutoff)))
    .returning({ id: notifications.id });

  // Prune old source snapshots beyond the newest N per source. The newest
  // snapshot (current evidence) and anything a rule version might reference
  // by recency is retained.
  const pruned = await db.execute(sql`
    DELETE FROM source_snapshots WHERE id IN (
      SELECT id FROM (
        SELECT id, row_number() OVER (PARTITION BY source_id ORDER BY fetched_at DESC) AS rn
        FROM source_snapshots
      ) ranked WHERE rn > ${policy.snapshotsPerSource}
    ) RETURNING id
  `);

  const result = {
    refreshTokens: deletedTokens.length,
    notifications: deletedNotifs.length,
    snapshots: pruned.rows.length,
  };

  if (result.refreshTokens + result.notifications + result.snapshots > 0) {
    await audit({
      actorType: 'job',
      action: 'retention.purged',
      entityType: 'retention_run',
      after: result,
    });
  }
  return result;
}
