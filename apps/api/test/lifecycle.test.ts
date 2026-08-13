/**
 * Lifecycle services: retention purging, email adapter outcomes, and
 * server-side rule validation on the curator API.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { and, eq } from 'drizzle-orm';
import nodemailer from 'nodemailer';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';
import { db } from '../src/db/client.ts';
import { fundingOpportunities, memberships, notifications, refreshTokens, sources, sourceSnapshots } from '../src/db/schema.ts';
import { runRetention } from '../src/services/retention.ts';
import { notify } from '../src/services/notifications.ts';
import { sendEmail, setTransportForTesting } from '../src/services/email.ts';

let app: FastifyInstance;
let user: TestUser;

beforeAll(async () => {
  app = await testServer();
  user = await registerUser(app, 'Livscykel');
});

afterAll(async () => {
  setTransportForTesting(null);
  await app.close();
});

describe('retention job (GDPR storage limitation)', () => {
  it('purges expired tokens and old read notifications, keeps recent data', async () => {
    const old = new Date(Date.now() - 120 * 86_400_000);
    await db.insert(refreshTokens).values({
      userId: user.userId,
      tokenHash: `expired-${Date.now()}`,
      expiresAt: old,
    });
    await db.insert(notifications).values([
      { tenantId: user.tenantId, kind: 'x', title: 'Gammal läst', readAt: old, createdAt: old },
      { tenantId: user.tenantId, kind: 'x', title: 'Gammal oläst', createdAt: old },
      { tenantId: user.tenantId, kind: 'x', title: 'Ny läst', readAt: new Date() },
    ]);

    const result = await runRetention();
    expect(result.refreshTokens).toBeGreaterThanOrEqual(1);
    expect(result.notifications).toBeGreaterThanOrEqual(1);

    const remaining = await db
      .select({ title: notifications.title })
      .from(notifications)
      .where(eq(notifications.tenantId, user.tenantId));
    const titles = remaining.map((n) => n.title);
    expect(titles).not.toContain('Gammal läst');   // läst + gammal → bort
    expect(titles).toContain('Gammal oläst');       // oläst behålls
    expect(titles).toContain('Ny läst');            // ny behålls
  });

  it('prunes source snapshots beyond the per-source cap, newest kept', async () => {
    const [src] = await db
      .insert(sources)
      .values({ name: 'Retentionkälla', url: 'https://example.org/ret', method: 'html', quality: 'A' })
      .returning();
    for (let i = 0; i < 30; i++) {
      await db.insert(sourceSnapshots).values({
        sourceId: src!.id,
        contentHash: `h${i}`,
        changeStatus: 'unchanged',
        fetchedAt: new Date(Date.now() - (30 - i) * 3_600_000),
      });
    }
    const result = await runRetention();
    expect(result.snapshots).toBeGreaterThanOrEqual(5);
    const left = await db.select({ hash: sourceSnapshots.contentHash }).from(sourceSnapshots).where(eq(sourceSnapshots.sourceId, src!.id));
    expect(left.length).toBe(25);
    expect(left.map((s) => s.hash)).toContain('h29'); // nyaste kvar
  });
});

describe('email adapter', () => {
  it('delivers notification emails through the transport to tenant owners', async () => {
    const transport = nodemailer.createTransport({ jsonTransport: true });
    const sent: unknown[] = [];
    const original = transport.sendMail.bind(transport);
    transport.sendMail = (async (opts: never) => {
      sent.push(opts);
      return original(opts);
    }) as never;
    setTransportForTesting(transport);

    await notify({ tenantId: user.tenantId, kind: 'test', title: 'Testnotis', body: 'Innehåll' });
    expect(sent).toHaveLength(1);
    expect((sent[0] as { to: string }).to).toBe(user.email);
    expect((sent[0] as { subject: string }).subject).toContain('Testnotis');
  });

  it('reports failed delivery without throwing, and skips without transport', async () => {
    const failing = nodemailer.createTransport({ jsonTransport: true });
    failing.sendMail = (async () => {
      throw new Error('SMTP nere');
    }) as never;
    setTransportForTesting(failing);
    await expect(sendEmail({ to: 'x@test.example', subject: 's', text: 't' })).resolves.toBe('failed');

    setTransportForTesting(null);
    // transporter=null betyder "ingen SMTP konfigurerad" → skipped, aldrig kastat.
    await expect(sendEmail({ to: 'x@test.example', subject: 's', text: 't' })).resolves.toBe('skipped');
  });
});

describe('rule-versions API validates curator input', () => {
  it('rejects malformed criteria with per-field issues; publishes valid ones', async () => {
    const curator = await registerUser(app, 'Regelkurator');
    await db.update(memberships).set({ role: 'data_curator' }).where(eq(memberships.tenantId, curator.tenantId));
    const [opp] = await db
      .select({ id: fundingOpportunities.id })
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.slug, 'csn-studiemedel'))
      .limit(1);

    const bad = await api(app, curator, 'POST', `/v1/admin/opportunities/${opp!.id}/rule-versions`, {
      criteria: [{ id: 'x', kind: 'magic', factPath: 'bad path', op: 'similar_to', description: '' }],
      changeNote: 'test',
    });
    expect(bad.statusCode).toBe(422);
    const issues = (bad.json() as { issues: { path: string }[] }).issues;
    expect(issues.length).toBeGreaterThanOrEqual(3);

    const good = await api(app, curator, 'POST', `/v1/admin/opportunities/${opp!.id}/rule-versions`, {
      criteria: [
        { id: 'csn-h1', kind: 'hard', factPath: 'applicant.type', op: 'eq', expected: 'individual', description: 'Privatperson' },
        { id: 'csn-m1', kind: 'mandatory', factPath: 'person.isOrPlansStudying', op: 'is_true', description: 'Studerar', intakeQuestion: 'Studerar du?' },
      ],
      changeNote: 'Validerad uppdatering',
    });
    expect(good.statusCode).toBe(201);
  });
});
