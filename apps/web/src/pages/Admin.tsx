/**
 * Curation console (§43, §64): source registry with health, fetch triggers,
 * snapshots and the human review queue. Curator/administrator roles only.
 */
import { useCallback, useEffect, useState } from 'react';
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
  payload: { sourceName?: string; url?: string };
  createdAt: string;
}

export default function AdminPage() {
  const [sources, setSources] = useState<SourceRow[]>([]);
  const [review, setReview] = useState<ReviewItem[]>([]);
  const [staleMatches, setStaleMatches] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);

  const load = useCallback(() => {
    get<{ sources: SourceRow[] }>('/v1/admin/sources').then(({ sources }) => setSources(sources)).catch((e) => setError(e instanceof ApiError ? e.message : 'Kunde inte hämta källor.'));
    get<{ items: ReviewItem[] }>('/v1/admin/review-queue').then(({ items }) => setReview(items)).catch(() => {});
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
            <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.35rem' }}>
              <button className="secondary" onClick={() => resolve(item.id, 'approved')}>Godkänn</button>
              <button className="subtle" onClick={() => resolve(item.id, 'rejected')}>Avvisa</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
