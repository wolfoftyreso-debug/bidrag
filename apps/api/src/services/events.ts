/**
 * Produkthändelser (docs/reports/BETA_READINESS_2026-09-03.md B2;
 * måtten QSDR/ARR i docs/LAUNCH_DEMAND_INTELLIGENCE.md §5).
 *
 * Serverside, förstapart, ingen extern analytics. Alltid best effort: en
 * misslyckad händelselogg får aldrig påverka svaret till användaren — därför
 * fångas alla fel här och loggas bara. Namnen är LAUNCH-dokumentets egna
 * (genomgang_startad, genomgang_slutford, nasta_steg_visad, …) så att
 * kontrollrummets paneler kan läsa tabellen rakt av.
 */
import { and, gte, sql } from 'drizzle-orm';
import { db } from '../db/client.ts';
import { productEvents } from '../db/schema.ts';

/** Händelser klienten får skicka via POST /v1/events — inget annat tas emot. */
export const CLIENT_EVENTS: ReadonlySet<string> = new Set([
  'genomgang_startad',
  'nasta_steg_visad',
  'ansok_sjalv_klick',
  'forbered_klick',
  'dokument_kopierat',
  'feedback_oppnad',
]);

/** Serverside-händelser (emitteras av routes/services, aldrig av klienten). */
export const SERVER_EVENTS: ReadonlySet<string> = new Set([
  'genomgang_slutford',
  'ansokan_skapad',
  'betalning_bekraftad',
  'konto_skapat',
  'feedback_skickad',
]);

export interface TrackInput {
  tenantId?: string | null;
  userId?: string | null;
  props?: Record<string, unknown>;
}

export async function trackEvent(name: string, input: TrackInput = {}): Promise<void> {
  try {
    await db.insert(productEvents).values({
      tenantId: input.tenantId ?? null,
      userId: input.userId ?? null,
      name,
      props: input.props ?? {},
    });
  } catch (err) {
    // Aldrig störa huvudflödet — händelseloggen är sekundär.
    console.error('[events] kunde inte logga händelse', name, (err as Error).message);
  }
}

/** Trattsammanställning för kontrollrummet: antal per händelse de senaste N dagarna. */
export async function eventSummary(days: number): Promise<{ since: string; counts: Record<string, number>; qsdr: number | null; arr: number | null }> {
  const since = new Date(Date.now() - days * 86_400_000);
  const rows = await db
    .select({ name: productEvents.name, n: sql<number>`count(*)::int` })
    .from(productEvents)
    .where(and(gte(productEvents.createdAt, since)))
    .groupBy(productEvents.name);
  const counts: Record<string, number> = {};
  for (const r of rows) counts[r.name] = r.n;
  // QSDR = sessioner med ≥1 relevant match OCH visad nästa steg-vy / påbörjade genomgångar.
  // ARR = förberedelser slutförda / utgående "ansök själv"-klick. Båda null när nämnaren är 0.
  const startade = counts.genomgang_startad ?? 0;
  const nasta = counts.nasta_steg_visad ?? 0;
  const utklick = counts.ansok_sjalv_klick ?? 0;
  const skapade = counts.ansokan_skapad ?? 0;
  return {
    since: since.toISOString(),
    counts,
    qsdr: startade > 0 ? Math.min(1, nasta / startade) : null,
    arr: utklick > 0 ? Math.min(1, skapade / utklick) : null,
  };
}
