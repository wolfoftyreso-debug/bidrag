/**
 * Kuratorspåminnelser: förfallen kunskapsbas ska knacka på hos kuratorerna —
 * inte vänta på att någon öppnar kön. Deduplicerad per dygn, idempotent.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { registerUser, testServer, type TestUser } from './helpers.ts';
import { db } from '../src/db/client.ts';
import { fundingOpportunities, memberships, notifications } from '../src/db/schema.ts';
import { runCuratorReminders } from '../src/jobs/tasks.ts';

let app: FastifyInstance;
let curator: TestUser;

beforeAll(async () => {
  app = await testServer();
  curator = await registerUser(app, 'Kuratorn');
  // Gör användaren till data_curator och en källa förfallen.
  await db.update(memberships).set({ role: 'data_curator' }).where(eq(memberships.userId, curator.userId));
  await db
    .update(fundingOpportunities)
    .set({ nextReviewAt: new Date(Date.now() - 86_400_000) })
    .where(eq(fundingOpportunities.slug, 'majblomman-bidrag-barn'));
});

afterAll(async () => {
  // Återställ granskningsdatumet så andra sviter inte ser en förfallen källa.
  await db
    .update(fundingOpportunities)
    .set({ nextReviewAt: new Date(Date.now() + 30 * 86_400_000) })
    .where(eq(fundingOpportunities.slug, 'majblomman-bidrag-barn'));
  await app.close();
});

describe('kuratorspåminnelser', () => {
  it('notifies curators about overdue reviews — once per day, idempotent on rerun', async () => {
    const first = await runCuratorReminders();
    expect(first.overdue).toBeGreaterThanOrEqual(1);
    expect(first.notified).toBeGreaterThanOrEqual(1);

    const rows = await db
      .select({ kind: notifications.kind, title: notifications.title })
      .from(notifications)
      .where(eq(notifications.userId, curator.userId));
    expect(rows.some((r) => r.kind === 'curator_review_due')).toBe(true);

    // Dubbelkörning samma dygn: ingen ny notis.
    const second = await runCuratorReminders();
    expect(second.notified).toBe(0);
  });
});
