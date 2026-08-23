/**
 * Source ingestion (§20–22, §64–65).
 *
 * Fetches registered sources over HTTPS with strict SSRF controls, stores an
 * immutable snapshot with a content hash, detects changes against the previous
 * snapshot, and queues changed sources for human review. Raw evidence is never
 * lost. Parsing into structured rules is a per-source concern; changed content
 * always goes through the review queue before rules are republished.
 */
import { createHash } from 'node:crypto';
import { lookup } from 'node:dns/promises';
import { isIP } from 'node:net';
import { desc, eq } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { fundingOpportunities, reviewItems, sources, sourceSnapshots } from '../db/schema.ts';
import { audit } from '../audit.ts';
import { PARSER_VERSION, parseSource } from './parsers/generic.ts';
import { buildProposals, materialFlags, summarizeChange } from './parsers/diff.ts';

const MAX_FETCH_BYTES = 10 * 1024 * 1024;
const FETCH_TIMEOUT_MS = 30_000;

/** Block private/reserved ranges — ingestion must never reach internal services. */
export function isPrivateAddress(address: string): boolean {
  if (isIP(address) === 6) {
    const lower = address.toLowerCase();
    return (
      lower === '::1' ||
      lower.startsWith('fc') ||
      lower.startsWith('fd') ||
      lower.startsWith('fe80') ||
      lower.startsWith('::ffff:') // v4-mapped — re-check the v4 part below via extraction
    );
  }
  const parts = address.split('.').map(Number);
  if (parts.length !== 4 || parts.some((p) => Number.isNaN(p))) return true;
  const [a, b] = parts as [number, number, number, number];
  return (
    a === 0 ||
    a === 10 ||
    a === 127 ||
    (a === 100 && b >= 64 && b <= 127) ||
    (a === 169 && b === 254) ||
    (a === 172 && b >= 16 && b <= 31) ||
    (a === 192 && b === 168) ||
    a >= 224
  );
}

export async function assertSafeUrl(rawUrl: string): Promise<URL> {
  const url = new URL(rawUrl);
  if (url.protocol !== 'https:' && url.protocol !== 'http:') {
    throw new Error(`Blocked protocol: ${url.protocol}`);
  }
  if (url.username || url.password) throw new Error('Credentials in source URLs are not allowed');
  const host = url.hostname;
  if (isIP(host)) {
    if (isPrivateAddress(host)) throw new Error(`Blocked private address: ${host}`);
    return url;
  }
  const results = await lookup(host, { all: true });
  for (const r of results) {
    if (isPrivateAddress(r.address)) throw new Error(`Host ${host} resolves to private address ${r.address}`);
  }
  return url;
}

export interface FetchOutcome {
  snapshotId: string;
  changeStatus: 'new' | 'unchanged' | 'changed' | 'error';
  httpStatus: number | null;
  error?: string;
}

export async function fetchSource(sourceId: string): Promise<FetchOutcome> {
  const [source] = await db.select().from(sources).where(eq(sources.id, sourceId)).limit(1);
  if (!source) throw new Error('source not found');

  await db.update(sources).set({ lastFetchAt: new Date() }).where(eq(sources.id, sourceId));

  let httpStatus: number | null = null;
  let content: Buffer | null = null;
  let contentType: string | null = null;
  let error: string | undefined;

  try {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
    try {
      // Red team RT03-adversariell SSRF: följ redirects MANUELLT och kör
      // assertSafeUrl på VARJE hop. Med redirect:'follow' återvaliderades
      // aldrig Location, så en källa kunde 302:a till 169.254.169.254 (moln-
      // metadata) eller 127.0.0.1 och läcka interna adresser. Nu blockeras
      // varje hop mot privata adresser; redirect-kedjan är bounded.
      let url = await assertSafeUrl(source.url);
      let res: Response;
      for (let hop = 0; ; hop++) {
        res = await fetch(url, {
          signal: controller.signal,
          redirect: 'manual',
          headers: { 'User-Agent': 'Bidragskoll.se source monitor (+https://bidragskoll.se)' },
        });
        if (res.status < 300 || res.status >= 400) break;
        if (hop >= 5) throw new Error('Too many redirects');
        const location = res.headers.get('location');
        if (!location) break;
        url = await assertSafeUrl(new URL(location, url).href); // varje hop revalideras
      }
      httpStatus = res.status;
      contentType = res.headers.get('content-type');
      const buf = Buffer.from(await res.arrayBuffer());
      if (buf.length > MAX_FETCH_BYTES) throw new Error(`Response too large: ${buf.length} bytes`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      content = buf;
    } finally {
      clearTimeout(timer);
    }
  } catch (e) {
    error = (e as Error).message;
  }

  if (!content) {
    const [snap] = await db
      .insert(sourceSnapshots)
      .values({
        sourceId,
        httpStatus,
        contentType,
        contentHash: 'error',
        changeStatus: 'error',
        diffSummary: error ?? 'unknown error',
      })
      .returning({ id: sourceSnapshots.id });
    await db.update(sources).set({ lastError: error ?? 'unknown error' }).where(eq(sources.id, sourceId));
    return { snapshotId: snap!.id, changeStatus: 'error', httpStatus, error };
  }

  return recordFetchedContent(source, { content, contentType, httpStatus });
}

/**
 * Bearbetar hämtat innehåll: parsar, diffar mot föregående snapshot, lagrar
 * med läsbar sammanfattning och lägger materialflaggor i granskningskön.
 * Åtskild från nätverkshämtningen så att den kan testas med fixturer, och så
 * att partnerfeeds/manuella uppladdningar kan gå samma väg (§20).
 */
export async function recordFetchedContent(
  source: typeof sources.$inferSelect,
  fetched: { content: Buffer; contentType: string | null; httpStatus: number | null },
): Promise<FetchOutcome> {
  const { content, contentType, httpStatus } = fetched;
  const contentHash = createHash('sha256').update(content).digest('hex');
  const [previous] = await db
    .select({ contentHash: sourceSnapshots.contentHash, content: sourceSnapshots.content, contentType: sourceSnapshots.contentType })
    .from(sourceSnapshots)
    .where(eq(sourceSnapshots.sourceId, source.id))
    .orderBy(desc(sourceSnapshots.fetchedAt))
    .limit(1);

  const changeStatus: 'new' | 'unchanged' | 'changed' = !previous
    ? 'new'
    : previous.contentHash === contentHash
      ? 'unchanged'
      : 'changed';

  const isText = (contentType ?? '').includes('text') || (contentType ?? '').includes('json') || (contentType ?? '').includes('xml');

  // Strukturerad extraktion + diff — endast för textinnehåll och bara när
  // något faktiskt hänt. Osäkerhet förblir synlig: allt går via granskning.
  let diffSummary: string | null = null;
  let extracted: ReturnType<typeof parseSource> | null = null;
  let change: ReturnType<typeof summarizeChange> | null = null;
  if (isText && (changeStatus === 'changed' || changeStatus === 'new')) {
    extracted = parseSource(content.toString('utf8'), contentType);
    const prevParsed = previous?.content ? parseSource(previous.content, previous.contentType) : null;
    change = summarizeChange(prevParsed, extracted);
    diffSummary = change.summary;
  } else if (changeStatus === 'changed') {
    diffSummary = 'Binärt innehåll ändrades (hash-diff).';
  }

  const [snap] = await db
    .insert(sourceSnapshots)
    .values({
      sourceId: source.id,
      httpStatus,
      contentType,
      contentHash,
      content: isText ? content.toString('utf8').slice(0, 2_000_000) : null,
      changeStatus,
      diffSummary,
    })
    .returning({ id: sourceSnapshots.id });

  await db
    .update(sources)
    .set({ lastSuccessAt: new Date(), lastError: null, parserVersion: isText ? PARSER_VERSION : source.parserVersion })
    .where(eq(sources.id, source.id));

  if (changeStatus === 'changed') {
    // Materialflaggor mot stöd som pekar på källan (§65) — aldrig autopublicering.
    const linked = await db
      .select({ slug: fundingOpportunities.slug, title: fundingOpportunities.title, closesAt: fundingOpportunities.closesAt })
      .from(fundingOpportunities)
      .where(eq(fundingOpportunities.sourceId, source.id));
    const linkedView = linked.map((o) => ({ slug: o.slug, title: o.title, closesAtIso: o.closesAt?.toISOString() ?? null }));
    const flags = change && extracted ? materialFlags(change, extracted, linkedView) : [];
    const proposals = extracted ? buildProposals(extracted, linkedView, new Date().toISOString()) : [];

    await db.insert(reviewItems).values({
      kind: 'source_change',
      refType: 'source_snapshot',
      refId: snap!.id,
      payload: {
        sourceId: source.id,
        sourceName: source.name,
        url: source.url,
        contentHash,
        summary: diffSummary,
        flags,
        proposals,
        addedLinks: change?.addedLinks ?? [],
        addedDates: change?.addedDates ?? [],
        removedDates: change?.removedDates ?? [],
        deadlineDates: extracted?.dates.filter((d) => d.nearDeadlinePhrase).slice(0, 10) ?? [],
      },
    });
    await audit({
      actorType: 'job',
      action: 'source.change_detected',
      entityType: 'source',
      entityId: source.id,
      after: { snapshotId: snap!.id, contentHash, summary: diffSummary },
    });
  }

  return { snapshotId: snap!.id, changeStatus, httpStatus };
}
