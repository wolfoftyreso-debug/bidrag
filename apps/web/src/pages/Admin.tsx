/**
 * Curation console (§43, §64): source registry with health, fetch triggers,
 * snapshots and the human review queue. Curator/administrator roles only.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ApiError, formatDate, get, post } from '../api';

interface SourceRow {
  id: string;
  name: string;
  url: string;
  method: string;
  quality: string;
  active: boolean;
  lastFetchAt: string | null;
  lastSuccessAt: string | null;
  lastError: string | null;
  activeOpportunities: number;
  pendingReview: number;
}
interface ReviewItem {
  id: string;
  kind: string;
  payload: {
    sourceName?: string;
    url?: string;
    summary?: string;
    flags?: { severity: 'info' | 'warning'; message: string }[];
    proposals?: { type: string; opportunityTitle: string; currentIso: string | null; proposedIso: string; evidence: string }[];
    addedLinks?: { href: string; text: string }[];
    addedDates?: string[];
    removedDates?: string[];
  };
  createdAt: string;
  affectedOpportunities: { id: string; slug: string; title: string }[];
}
interface OppRow {
  id: string;
  title: string;
  verificationStatus: string;
  lastVerifiedAt: string | null;
  nextReviewAt: string | null;
  sourceUrl: string;
  closesAt: string | null;
}

export default function AdminPage() {
  const [sources, setSources] = useState<SourceRow[]>([]);
  const [review, setReview] = useState<ReviewItem[]>([]);
  const [opportunities, setOpportunities] = useState<OppRow[]>([]);
  const [staleMatches, setStaleMatches] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const load = useCallback(() => {
    get<{ sources: SourceRow[] }>('/v1/admin/sources').then(({ sources }) => setSources(sources)).catch((e) => setError(e instanceof ApiError ? e.message : 'Kunde inte hämta källor.'));
    get<{ items: ReviewItem[] }>('/v1/admin/review-queue').then(({ items }) => setReview(items)).catch(() => {});
    get<{ opportunities: OppRow[] }>('/v1/admin/opportunities').then(({ opportunities }) => setOpportunities(opportunities)).catch(() => {});
    get<{ staleMatches: number }>('/v1/admin/stale-matches').then((d) => setStaleMatches(d.staleMatches)).catch(() => {});
  }, []);
  useEffect(load, [load]);

  const fetchNow = async (id: string) => {
    setBusyId(id);
    try {
      await post(`/v1/admin/sources/${id}/fetch`);
      load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Hämtningen misslyckades.');
    } finally {
      setBusyId(null);
    }
  };

  const resolve = async (id: string, resolution: 'approved' | 'rejected') => {
    await post(`/v1/admin/review-queue/${id}/resolve`, { resolution });
    load();
  };

  if (error) return <div className="alert error">{error}</div>;

  return (
    <div>
      <h1>Administration</h1>

      <div className="grid cols-3">
        <div className="card"><h3>Aktiva källor</h3><div className="score-ring">{sources.filter((s) => s.active).length}</div></div>
        <div className="card"><h3>Väntar på granskning</h3><div className="score-ring">{review.length}</div></div>
        <div className="card"><h3>Inaktuella matchningar</h3><div className="score-ring">{staleMatches}</div><p className="meta-line">Räknas om automatiskt var 15:e minut.</p></div>
      </div>

      <div className="card">
        <h2>Källhälsa</h2>
        <table className="data">
          <thead>
            <tr><th>Källa</th><th>Kvalitet</th><th>Senast hämtad</th><th>Status</th><th>Aktiva stöd</th><th /></tr>
          </thead>
          <tbody>
            {sources.map((s) => (
              <tr key={s.id}>
                <td>
                  <a href={s.url} target="_blank" rel="noreferrer">{s.name}</a>
                </td>
                <td><span className="badge">{s.quality}</span></td>
                <td>{formatDate(s.lastFetchAt)}</td>
                <td>
                  {s.lastError ? (
                    <span className="badge danger" title={s.lastError}>fel</span>
                  ) : s.lastSuccessAt ? (
                    <span className="badge success">ok</span>
                  ) : (
                    <span className="badge">ej hämtad</span>
                  )}
                </td>
                <td>{s.activeOpportunities}</td>
                <td>
                  <button className="secondary" disabled={busyId === s.id} onClick={() => fetchNow(s.id)}>
                    {busyId === s.id ? 'Hämtar…' : 'Hämta nu'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <p className="guidance">
          En trasig källa får aldrig tyst ge inaktuella rekommendationer — fel visas här och ändringar hamnar i
          granskningskön innan regler publiceras om.
        </p>
      </div>

      <div className="card">
        <h2>Granskningskö ({review.length})</h2>
        {review.length === 0 && <p className="meta-line">Inget att granska.</p>}
        {review.map((item) => (
          <div key={item.id} style={{ padding: '0.6rem 0', borderBottom: '1px solid var(--border)' }}>
            <strong>{item.kind === 'source_change' ? 'Källändring' : item.kind}</strong> — {item.payload.sourceName ?? ''}{' '}
            <span className="meta-line">{formatDate(item.createdAt)}</span>
            {item.payload.summary && <div style={{ margin: '0.25rem 0' }}>{item.payload.summary}</div>}
            {(item.payload.flags ?? []).map((f, i) => (
              <div key={i} className={`alert ${f.severity === 'warning' ? 'warning' : 'info'}`} style={{ margin: '0.3rem 0', padding: '0.4rem 0.7rem' }}>
                {f.message}
              </div>
            ))}
            {(item.payload.proposals ?? []).map((p, i) => (
              <div key={i} className="alert info" style={{ margin: '0.3rem 0', padding: '0.5rem 0.8rem' }}>
                <strong>Förslag:</strong> uppdatera deadline för ”{p.opportunityTitle}”: {p.currentIso ?? 'ingen'} → {p.proposedIso}
                <div className="meta-line">Bevis: ”{p.evidence.slice(0, 120)}…”</div>
                <button
                  className="secondary"
                  style={{ marginTop: '0.3rem' }}
                  onClick={() => post(`/v1/admin/review-queue/${item.id}/apply`, { proposalIndex: i }).then(load)}
                >
                  Tillämpa och godkänn
                </button>
              </div>
            ))}
            {(item.payload.addedLinks ?? []).slice(0, 5).map((l, i) => (
              <div className="meta-line" key={i}>+ {l.text}</div>
            ))}
            {item.affectedOpportunities.length > 0 && (
              <div className="meta-line">
                Påverkar: {item.affectedOpportunities.map((o) => o.title).join(' · ')}
              </div>
            )}
            <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.35rem' }}>
              <button className="secondary" onClick={() => resolve(item.id, 'approved')}>Godkänn</button>
              <button className="subtle" onClick={() => resolve(item.id, 'rejected')}>Avvisa</button>
            </div>
          </div>
        ))}
      </div>

      <div className="card">
        <h2>Stöd efter granskningsbehov ({opportunities.length})</h2>
        <p className="guidance">
          Sorterat efter nästa granskningsdatum. ”Verifiera” bekräftar att publicerade regler fortfarande stämmer mot källan
          och flyttar fram granskningsdatumet 30 dagar.
        </p>
        <table className="data">
          <thead>
            <tr><th>Stöd</th><th>Status</th><th>Senast verifierad</th><th>Nästa granskning</th><th /></tr>
          </thead>
          <tbody>
            {opportunities.map((o) => {
              const overdue = !o.nextReviewAt || new Date(o.nextReviewAt) < new Date();
              return (
                <tr key={o.id}>
                  <td><a href={o.sourceUrl} target="_blank" rel="noreferrer">{o.title}</a></td>
                  <td>
                    <span className={`badge ${o.verificationStatus === 'human_verified' ? 'success' : ''}`}>
                      {o.verificationStatus === 'human_verified' ? 'verifierad' : o.verificationStatus === 'human_curated' ? 'kurerad' : o.verificationStatus === 'ai_curated' ? 'AI-sammanställd — ogranskad' : o.verificationStatus}
                    </span>
                  </td>
                  <td>{formatDate(o.lastVerifiedAt)}</td>
                  <td>{overdue ? <span className="badge warning">förfallen</span> : formatDate(o.nextReviewAt)}</td>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    <button className="secondary" onClick={() => post(`/v1/admin/opportunities/${o.id}/verify`).then(load)}>
                      Verifiera
                    </button>{' '}
                    <Link to={`/admin/regler/${o.id}`}>Redigera regler</Link>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
