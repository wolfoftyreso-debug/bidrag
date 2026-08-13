/**
 * Prometheus metrics endpoint (§44) — text exposition format, no external
 * dependencies. Intended to be scraped on the cluster network; excluded from
 * rate limiting and auth like the health probes.
 */
import type { FastifyInstance } from 'fastify';
import fp from 'fastify-plugin';
import { sql } from 'drizzle-orm';
import { db, pool } from '../db/client.ts';

interface Counters {
  requestsTotal: Map<string, number>; // key: `${method}|${statusClass}`
  requestDurationSumMs: number;
  requestDurationCount: number;
}

const counters: Counters = {
  requestsTotal: new Map(),
  requestDurationSumMs: 0,
  requestDurationCount: 0,
};

export const metricsPlugin = fp(async (app: FastifyInstance) => {
  app.addHook('onResponse', async (request, reply) => {
    if (request.url === '/metrics' || request.url === '/healthz' || request.url === '/readyz') return;
    const key = `${request.method}|${Math.floor(reply.statusCode / 100)}xx`;
    counters.requestsTotal.set(key, (counters.requestsTotal.get(key) ?? 0) + 1);
    counters.requestDurationSumMs += reply.elapsedTime;
    counters.requestDurationCount += 1;
  });

  app.get('/metrics', { config: { rateLimit: false } }, async (_request, reply) => {
    const lines: string[] = [];
    const push = (name: string, help: string, type: string, samples: [string, number][]) => {
      lines.push(`# HELP ${name} ${help}`, `# TYPE ${name} ${type}`);
      for (const [labels, value] of samples) lines.push(`${name}${labels} ${value}`);
    };

    push('bidrag_http_requests_total', 'HTTP requests by method and status class', 'counter',
      [...counters.requestsTotal.entries()].map(([key, v]) => {
        const [method, status] = key.split('|');
        return [`{method="${method}",status="${status}"}`, v] as [string, number];
      }),
    );
    push('bidrag_http_request_duration_ms_sum', 'Total request duration in ms', 'counter',
      [['', Math.round(counters.requestDurationSumMs)]]);
    push('bidrag_http_request_duration_ms_count', 'Request count for duration average', 'counter',
      [['', counters.requestDurationCount]]);

    const mem = process.memoryUsage();
    push('bidrag_process_resident_memory_bytes', 'Resident set size', 'gauge', [['', mem.rss]]);
    push('bidrag_process_heap_used_bytes', 'V8 heap used', 'gauge', [['', mem.heapUsed]]);
    push('bidrag_process_uptime_seconds', 'Process uptime', 'gauge', [['', Math.round(process.uptime())]]);
    push('bidrag_pg_pool_total', 'Postgres pool size', 'gauge', [['', pool.totalCount]]);
    push('bidrag_pg_pool_idle', 'Postgres pool idle connections', 'gauge', [['', pool.idleCount]]);
    push('bidrag_pg_pool_waiting', 'Postgres pool waiting requests', 'gauge', [['', pool.waitingCount]]);

    // Domain health gauges — cheap indexed counts, the operational §44 signals.
    try {
      const result = await db.execute(sql`
        SELECT
          (SELECT count(*)::int FROM funding_opportunities WHERE status = 'published') AS published,
          (SELECT count(*)::int FROM funding_opportunities WHERE status = 'published'
             AND (next_review_at IS NULL OR next_review_at < now())) AS review_overdue,
          (SELECT count(*)::int FROM matches WHERE stale = true) AS stale_matches,
          (SELECT count(*)::int FROM review_items WHERE status = 'pending') AS pending_review,
          (SELECT count(*)::int FROM sources WHERE active = true AND last_error IS NOT NULL) AS failing_sources
      `);
      const d = result.rows[0] as unknown as { published: number; review_overdue: number; stale_matches: number; pending_review: number; failing_sources: number };
      push('bidrag_opportunities_published', 'Published funding opportunities', 'gauge', [['', d.published]]);
      push('bidrag_opportunities_review_overdue', 'Published opportunities past next_review_at', 'gauge', [['', d.review_overdue]]);
      push('bidrag_matches_stale', 'Matches awaiting recomputation after rule changes', 'gauge', [['', d.stale_matches]]);
      push('bidrag_review_queue_pending', 'Human review queue depth', 'gauge', [['', d.pending_review]]);
      push('bidrag_sources_failing', 'Active sources whose last fetch errored', 'gauge', [['', d.failing_sources]]);
    } catch {
      push('bidrag_domain_metrics_up', 'Domain metric collection healthy', 'gauge', [['', 0]]);
    }

    return reply.header('Content-Type', 'text/plain; version=0.0.4').send(lines.join('\n') + '\n');
  });
});
