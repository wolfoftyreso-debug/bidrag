/**
 * Strukturerad källextraktion (§24): deterministiska parsers testade mot
 * svenska fixturer, snapshot-diff med läsbar sammanfattning, materialflaggor,
 * och hela ingestionsvägen (utan nätverk) via recordFetchedContent.
 */
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { desc, eq } from 'drizzle-orm';
import { testServer } from './helpers.ts';
import { db } from '../src/db/client.ts';
import { fundingOpportunities, reviewItems, sources, sourceSnapshots } from '../src/db/schema.ts';
import { extractAmounts, extractDates, extractLinks, htmlToText, parseSource } from '../src/services/parsers/generic.ts';
import { materialFlags, summarizeChange } from '../src/services/parsers/diff.ts';
import { recordFetchedContent } from '../src/services/ingestion.ts';

let app: FastifyInstance;

beforeAll(async () => {
  app = await testServer();
});
afterAll(async () => {
  await app.close();
});

const LISTING_V1 = `<html><body>
  <h1>Sök bidrag</h1>
  <ul>
    <li><a href="/bidrag/resebidrag">Resebidrag för internationellt kulturutbyte</a> — sista ansökningsdag 24 september 2026.</li>
    <li><a href="/bidrag/projektbidrag-musik">Projektbidrag musik</a> — nästa omgång ej publicerad.</li>
  </ul>
  <p>Bidrag på upp till 50 000 kr kan sökas.</p>
</body></html>`;

const LISTING_V2 = `<html><body>
  <h1>Sök bidrag</h1>
  <ul>
    <li><a href="/bidrag/resebidrag">Resebidrag för internationellt kulturutbyte</a> — sista ansökningsdag 15 oktober 2026.</li>
    <li><a href="/bidrag/projektbidrag-musik">Projektbidrag musik</a> — nästa omgång ej publicerad.</li>
    <li><a href="/bidrag/dansresidens">Nytt: Residensbidrag för dansare</a> — ansök senast 2026-11-30.</li>
  </ul>
  <p>Bidrag på upp till 75 000 kr kan sökas.</p>
</body></html>`;

describe('generisk svensk extraktion', () => {
  it('extracts written and ISO dates with deadline context', () => {
    const text = htmlToText(LISTING_V2);
    const dates = extractDates(text);
    expect(dates.map((d) => d.iso)).toEqual(['2026-10-15', '2026-11-30']);
    expect(dates.every((d) => d.nearDeadlinePhrase)).toBe(true);
    expect(dates[0]!.evidence).toContain('sista ansökningsdag');
  });

  it('extracts amounts in öre, including millions', () => {
    const amounts = extractAmounts('Stödet är upp till 50 000 kr, totalt 1,5 miljoner kronor per år.');
    expect(amounts.map((a) => a.amountMinor)).toEqual([5_000_000, 150_000_000]);
  });

  it('extracts links with cleaned text, skipping junk', () => {
    const links = extractLinks(`${LISTING_V1}<a href="mailto:x@y.se">mail</a><a href="/x">ok länk</a>`);
    expect(links.map((l) => l.href)).toEqual(['/bidrag/resebidrag', '/bidrag/projektbidrag-musik', '/x']);
  });

  it('date validation rejects impossible dates', () => {
    expect(extractDates('den 45 januari 2026 och 2026-13-45').length).toBe(0);
  });
});

describe('snapshot-diff och materialflaggor', () => {
  const prev = parseSource(LISTING_V1, 'text/html');
  const curr = parseSource(LISTING_V2, 'text/html');
  const change = summarizeChange(prev, curr);

  it('summarises new links and date changes in plain Swedish', () => {
    expect(change.addedLinks.map((l) => l.href)).toEqual(['/bidrag/dansresidens']);
    expect(change.addedDates).toEqual(expect.arrayContaining(['2026-10-15', '2026-11-30']));
    expect(change.removedDates).toEqual(['2026-09-24']);
    expect(change.summary).toContain('Residensbidrag för dansare');
    expect(change.summary).toContain('Datum som försvunnit: 2026-09-24');
  });

  it('flags a vanished published deadline as a warning', () => {
    const flags = materialFlags(change, curr, [
      { slug: 'kr-rese', title: 'Resebidrag', closesAtIso: '2026-09-24T21:59:59.000Z' },
    ]);
    const warning = flags.find((f) => f.severity === 'warning');
    expect(warning?.message).toContain('2026-09-24');
    expect(warning?.message).toContain('Resebidrag');
    expect(flags.some((f) => f.message.includes('nya länkar'))).toBe(true);
  });
});

describe('ingestion end-to-end med fixturer (inget nätverk)', () => {
  it('first fetch → new; changed fetch → rich review item with flags', async () => {
    const [source] = await db
      .insert(sources)
      .values({ name: 'Fixturkälla', url: 'https://example.org/fixtur', method: 'html', quality: 'A' })
      .returning();

    // Länka ett stöd med deadline 24 sep till källan.
    const [opp] = await db
      .select()
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.slug, 'kulturradet-internationellt-resebidrag-musik'))
      .limit(1);
    await db.update(fundingOpportunities).set({ sourceId: source!.id }).where(eq(fundingOpportunities.id, opp!.id));

    const first = await recordFetchedContent(source!, {
      content: Buffer.from(LISTING_V1),
      contentType: 'text/html',
      httpStatus: 200,
    });
    expect(first.changeStatus).toBe('new');

    const second = await recordFetchedContent(source!, {
      content: Buffer.from(LISTING_V2),
      contentType: 'text/html',
      httpStatus: 200,
    });
    expect(second.changeStatus).toBe('changed');

    const [snap] = await db
      .select()
      .from(sourceSnapshots)
      .where(eq(sourceSnapshots.sourceId, source!.id))
      .orderBy(desc(sourceSnapshots.fetchedAt))
      .limit(1);
    expect(snap!.diffSummary).toContain('Residensbidrag för dansare');

    const items = await db.select().from(reviewItems).where(eq(reviewItems.status, 'pending'));
    const item = items.find((i) => (i.payload as { sourceId?: string }).sourceId === source!.id);
    expect(item).toBeDefined();
    const payload = item!.payload as {
      summary: string;
      flags: { severity: string; message: string }[];
      addedLinks: { text: string }[];
      removedDates: string[];
    };
    expect(payload.addedLinks.map((l) => l.text)).toContain('Nytt: Residensbidrag för dansare');
    expect(payload.removedDates).toContain('2026-09-24');
    // Det försvunna datumet är stödets publicerade deadline → varning.
    expect(payload.flags.some((f) => f.severity === 'warning' && f.message.includes(opp!.title))).toBe(true);

    // Oförändrad tredje hämtning skapar ingen ny granskningspost.
    const third = await recordFetchedContent(source!, {
      content: Buffer.from(LISTING_V2),
      contentType: 'text/html',
      httpStatus: 200,
    });
    expect(third.changeStatus).toBe('unchanged');
    const itemsAfter = await db.select().from(reviewItems).where(eq(reviewItems.status, 'pending'));
    expect(itemsAfter.filter((i) => (i.payload as { sourceId?: string }).sourceId === source!.id)).toHaveLength(1);
  });
});
