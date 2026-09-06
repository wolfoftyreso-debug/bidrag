/**
 * Granskningskön (prio 5, motförhörets A-fynd): en människa lyfter ett stöd
 * från ai_curated till human_verified — bara med fullständigt protokoll,
 * mot en levande källa, spårbart (vem, när, vad).
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { eq } from 'drizzle-orm';
import { db } from '../src/db/client.ts';
import { fundingOpportunities, memberships, reviewItems, sources } from '../src/db/schema.ts';
import { api, registerUser, testServer, type TestUser } from './helpers.ts';

let app: FastifyInstance;
let curator: TestUser;
let oppId: string;
let originalSourceUrl: string;
let originalSourceId: string | null;

beforeAll(async () => {
  app = await testServer();
  curator = await registerUser(app, 'Granskaren');
  await db.update(memberships).set({ role: 'data_curator' }).where(eq(memberships.userId, curator.userId));
  const [opp] = await db
    .select({ id: fundingOpportunities.id, sourceUrl: fundingOpportunities.sourceUrl, sourceId: fundingOpportunities.sourceId })
    .from(fundingOpportunities)
    .where(eq(fundingOpportunities.slug, 'majblomman-bidrag-barn'))
    .limit(1);
  oppId = opp!.id;
  originalSourceUrl = opp!.sourceUrl;
  originalSourceId = opp!.sourceId;
});

afterAll(async () => {
  await db
    .update(fundingOpportunities)
    .set({ verificationStatus: 'ai_curated', sourceUrl: originalSourceUrl, sourceId: originalSourceId, nextReviewAt: new Date(Date.now() + 30 * 86_400_000) })
    .where(eq(fundingOpportunities.id, oppId));
  await db.delete(reviewItems).where(eq(reviewItems.refId, oppId));
  await app.close();
});

describe('granskningsprotokollet', () => {
  it('vägrar lyfta stämpeln utan fullständigt protokoll', async () => {
    const res = await api(app, curator, 'POST', `/v1/admin/opportunities/${oppId}/verify`, {
      checklist: { sourceAlive: true, criteriaMatch: true, amountMatch: false, applicationMatch: true, sourceSpecific: false },
    });
    expect(res.statusCode).toBe(400);
    const body = res.json() as { error: string; missing: string[] };
    expect(body.error).toBe('checklist_incomplete');
    expect(body.missing.sort()).toEqual(['amountMatch', 'sourceSpecific']);
    const [opp] = await db.select({ v: fundingOpportunities.verificationStatus }).from(fundingOpportunities).where(eq(fundingOpportunities.id, oppId));
    expect(opp!.v).not.toBe('human_verified');
    // Utan protokoll alls: schemat vägrar.
    const none = await api(app, curator, 'POST', `/v1/admin/opportunities/${oppId}/verify`, {});
    expect(none.statusCode).toBe(400);
  });

  it('lyfter till human_verified med fullständigt protokoll, rättar källadressen och sparar vem/när/vad', async () => {
    const res = await api(app, curator, 'POST', `/v1/admin/opportunities/${oppId}/verify`, {
      checklist: { sourceAlive: true, criteriaMatch: true, amountMatch: true, applicationMatch: true, sourceSpecific: true },
      note: 'Kontrollerad mot majblomman.se 2026-09-05 — belopp och villkor oförändrade.',
      sourceUrl: 'https://www.majblomman.se/ansok-om-bidrag/',
    });
    expect(res.statusCode).toBe(200);
    const { opportunity } = res.json() as { opportunity: { verificationStatus: string; sourceUrl: string } };
    expect(opportunity.verificationStatus).toBe('human_verified');
    expect(opportunity.sourceUrl).toBe('https://www.majblomman.se/ansok-om-bidrag/');

    const items = await db.select().from(reviewItems).where(eq(reviewItems.refId, oppId));
    const v = items.find((i) => i.kind === 'verification');
    expect(v).toBeTruthy();
    expect(v!.status).toBe('approved');
    expect(v!.resolvedBy).toBe(curator.userId);
    expect(v!.note).toContain('majblomman.se');
    expect((v!.payload as { sourceUrlBefore: string }).sourceUrlBefore).toBe(originalSourceUrl);

    // Kön visar protokollet, synligheten och startsideflaggan — och lägger förfallna först.
    const q = await api(app, curator, 'GET', '/v1/admin/opportunities');
    expect(q.statusCode).toBe(200);
    const rows = (q.json() as { opportunities: { id: string; shown30d: number; overdue: boolean; sourceIsStartPage: boolean; lastVerification: { by: string | null; note: string | null } | null }[] }).opportunities;
    const mine = rows.find((r) => r.id === oppId)!;
    expect(mine.lastVerification?.by).toBe('Granskaren');
    expect(mine.lastVerification?.note).toContain('majblomman.se');
    expect(typeof mine.shown30d).toBe('number');
    expect(mine.sourceIsStartPage).toBe(false);
    for (let i = 1; i < rows.length; i++) {
      if (rows[i]!.overdue) expect(rows[i - 1]!.overdue).toBe(true); // förfallna först
    }
  });

  it('källkontrollen svarar ärligt när källan inte går att nå', async () => {
    // En källa på en privat adress stoppas av SSRF-vakten — ett snabbt, ärligt "error".
    const [src] = await db
      .insert(sources)
      .values({ name: 'Testkälla (onåbar)', url: 'http://127.0.0.1:9/', method: 'html', quality: 'C', active: false })
      .returning({ id: sources.id });
    await db.update(fundingOpportunities).set({ sourceId: src!.id }).where(eq(fundingOpportunities.id, oppId));
    const res = await api(app, curator, 'POST', `/v1/admin/opportunities/${oppId}/source-check`);
    expect(res.statusCode).toBe(200);
    const body = res.json() as { checked: boolean; changeStatus: string; error: string | null };
    expect(body.checked).toBe(true);
    expect(body.changeStatus).toBe('error');
    expect(body.error).toBeTruthy();
    await db.update(fundingOpportunities).set({ sourceId: originalSourceId }).where(eq(fundingOpportunities.id, oppId));
    await db.delete(sources).where(eq(sources.id, src!.id));
  });

  it('vanlig användare kommer inte åt kön', async () => {
    const user = await registerUser(app, 'Vanlig');
    const res = await api(app, user, 'GET', '/v1/admin/opportunities');
    expect(res.statusCode).toBe(403);
  });
});
