/**
 * Curation console (§43, §64): source registry with health, fetch triggers,
 * snapshots and the human review queue. Curator/administrator roles only.
 */
import { Fragment, useCallback, useEffect, useState } from 'react';
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
  applicationUrl: string | null;
  closesAt: string | null;
  shown30d: number;
  overdue: boolean;
  sourceIsStartPage: boolean;
  lastVerification: { at: string | null; by: string | null; note: string | null } | null;
}
interface SourceCheck {
  checked: boolean;
  changeStatus: 'new' | 'unchanged' | 'changed' | 'error';
  httpStatus: number | null;
  error: string | null;
  diffSummary: string | null;
  fetchedAt: string;
}

/** Granskningsprotokollet (docs/reports/KURATORSMINIMUM_2026-09-03.md §Arbetsgång) — alla fem måste vara ikryssade. */
const CHECKLIST: { key: 'sourceAlive' | 'criteriaMatch' | 'amountMatch' | 'applicationMatch' | 'sourceSpecific'; label: string }[] = [
  { key: 'sourceAlive', label: 'Källsidan är öppnad och stödet finns kvar (inte avskaffat eller ersatt).' },
  { key: 'criteriaMatch', label: 'Villkorstexterna stämmer med sidans ”Vem kan få”.' },
  { key: 'amountMatch', label: 'Beloppet stämmer exakt med sidan, med datum — eller inget belopp anges.' },
  { key: 'applicationMatch', label: 'Ansökningssätt och underlag stämmer med ”Så ansöker du”.' },
  { key: 'sourceSpecific', label: 'Källadressen är stödets egen sida, inte myndighetens startsida.' },
];
const CHANGE_LABEL: Record<SourceCheck['changeStatus'], string> = {
  new: 'första snapshoten sparad', unchanged: 'oförändrad sedan senaste snapshot', changed: 'ÄNDRAD sedan senaste snapshot', error: 'gick inte att hämta',
};

function VerifyPanel({ opp, onDone }: { opp: OppRow; onDone: () => void }) {
  const [checks, setChecks] = useState<Record<string, boolean>>({});
  const [sourceUrl, setSourceUrl] = useState(opp.sourceUrl);
  const [applicationUrl, setApplicationUrl] = useState(opp.applicationUrl ?? '');
  const [note, setNote] = useState('');
  const [check, setCheck] = useState<SourceCheck | null>(null);
  const [checking, setChecking] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const complete = CHECKLIST.every((c) => checks[c.key]);

  const runCheck = async () => {
    setChecking(true); setErr(null);
    try { setCheck(await post<SourceCheck>(`/v1/admin/opportunities/${opp.id}/source-check`)); }
    catch (e) { setErr(e instanceof ApiError ? e.message : 'Källkontrollen misslyckades.'); }
    finally { setChecking(false); }
  };
  const lift = async () => {
    setErr(null);
    try {
      await post(`/v1/admin/opportunities/${opp.id}/verify`, {
        checklist: Object.fromEntries(CHECKLIST.map((c) => [c.key, Boolean(checks[c.key])])),
        note: note.trim() || undefined,
        sourceUrl: sourceUrl.trim() !== opp.sourceUrl ? sourceUrl.trim() : undefined,
        applicationUrl: applicationUrl.trim() && applicationUrl.trim() !== (opp.applicationUrl ?? '') ? applicationUrl.trim() : undefined,
      });
      onDone();
    } catch (e) { setErr(e instanceof ApiError ? e.message : 'Kunde inte spara protokollet.'); }
  };

  return (
    <div className="card" style={{ marginTop: '0.4rem' }}>
      <h3>Granska {opp.title}</h3>
      <p className="guidance">
        Öppna källan, gå igenom punkterna och kryssa bara det du faktiskt kontrollerat. Stämpeln höjs först när alla fem är ikryssade — protokollet sparas med ditt namn och datum.
      </p>
      <p>
        <a href={opp.sourceUrl} target="_blank" rel="noreferrer">Öppna källsidan ↗</a>{' '}
        <button className="secondary" onClick={runCheck} disabled={checking}>{checking ? 'Kontrollerar…' : 'Kontrollera källan nu'}</button>
      </p>
      {check && (
        <p className={`meta-line${check.changeStatus === 'error' || check.changeStatus === 'changed' ? ' badge warning' : ''}`}>
          Källan {check.httpStatus ? `svarade ${check.httpStatus}` : 'svarade inte'} · {CHANGE_LABEL[check.changeStatus]}
          {check.error ? ` · ${check.error}` : ''}{check.diffSummary && check.changeStatus === 'changed' ? ` · ${check.diffSummary}` : ''}
        </p>
      )}
      {CHECKLIST.map((c) => (
        <label key={c.key} style={{ display: 'block', margin: '0.3rem 0' }}>
          <input type="checkbox" checked={Boolean(checks[c.key])} onChange={(e) => setChecks({ ...checks, [c.key]: e.target.checked })} /> {c.label}
        </label>
      ))}
      <label htmlFor={`src-${opp.id}`}>Källadress (stödets egen sida)</label>
      <input id={`src-${opp.id}`} value={sourceUrl} onChange={(e) => setSourceUrl(e.target.value)} />
      {opp.sourceIsStartPage && sourceUrl === opp.sourceUrl && <p className="meta-line">Adressen ser ut som en startsida — leta upp stödets egen sida hos myndigheten (M25).</p>}
      <label htmlFor={`app-${opp.id}`}>Ansökningsadress</label>
      <input id={`app-${opp.id}`} value={applicationUrl} onChange={(e) => setApplicationUrl(e.target.value)} />
      <label htmlFor={`note-${opp.id}`}>Anteckning (vad du jämförde, avvikelser, datum)</label>
      <textarea id={`note-${opp.id}`} rows={2} value={note} onChange={(e) => setNote(e.target.value)} />
      {err && <div className="alert error">{err}</div>}
      <p>
        <button onClick={lift} disabled={!complete}>Lyft till verifierad mot källa</button>{' '}
        {!complete && <span className="meta-line">{CHECKLIST.filter((c) => !checks[c.key]).length} punkter kvar</span>}
      </p>
    </div>
  );
}

interface FeedbackRow {
  id: string;
  category: string;
  page: string;
  opportunitySlug: string | null;
  message: string;
  locale: string | null;
  status: string;
  createdAt: string;
}

const FEEDBACK_LABEL: Record<string, string> = {
  facts: 'Faktafel', language: 'Språk', navigation: 'Navigering', missing: 'Saknat stöd', technical: 'Tekniskt', other: 'Annat',
};

export default function AdminPage() {
  const [sources, setSources] = useState<SourceRow[]>([]);
  const [review, setReview] = useState<ReviewItem[]>([]);
  const [opportunities, setOpportunities] = useState<OppRow[]>([]);
  const [staleMatches, setStaleMatches] = useState(0);
  const [feedbackItems, setFeedbackItems] = useState<FeedbackRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [openId, setOpenId] = useState<string | null>(null);

  const load = useCallback(() => {
    get<{ sources: SourceRow[] }>('/v1/admin/sources').then(({ sources }) => setSources(sources)).catch((e) => setError(e instanceof ApiError ? e.message : 'Kunde inte hämta källor.'));
    get<{ items: ReviewItem[] }>('/v1/admin/review-queue').then(({ items }) => setReview(items)).catch(() => {});
    get<{ opportunities: OppRow[] }>('/v1/admin/opportunities').then(({ opportunities }) => setOpportunities(opportunities)).catch(() => {});
    get<{ staleMatches: number }>('/v1/admin/stale-matches').then((d) => setStaleMatches(d.staleMatches)).catch(() => {});
    get<{ items: FeedbackRow[] }>('/v1/admin/feedback').then(({ items }) => setFeedbackItems(items)).catch(() => {});
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
        <h2>Feedback från betan ({feedbackItems.length})</h2>
        <p className="guidance">Nyast först. Faktafel ska till kuratorn: kontrollera källan och rätta seeden eller regelversionen.</p>
        {feedbackItems.length === 0 ? <p className="meta-line">Inga rapporter ännu.</p> : (
          <table className="data">
            <thead><tr><th>När</th><th>Typ</th><th>Sida</th><th>Stöd</th><th>Meddelande</th></tr></thead>
            <tbody>
              {feedbackItems.map((f) => (
                <tr key={f.id}>
                  <td>{new Date(f.createdAt).toLocaleString('sv-SE')}</td>
                  <td><span className={`badge ${f.category === 'facts' ? 'danger' : f.category === 'technical' ? 'warning' : ''}`}>{FEEDBACK_LABEL[f.category] ?? f.category}</span></td>
                  <td>{f.page}</td>
                  <td>{f.opportunitySlug ?? '—'}</td>
                  <td style={{ whiteSpace: 'pre-wrap' }}>{f.message}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
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
        <h2>Granskningskö — stöd efter granskningsbehov ({opportunities.length})</h2>
        <p className="guidance">
          Förfallna först, sedan efter hur ofta stödet visats för riktiga användare de senaste 30 dagarna. ”Granska” öppnar protokollet:
          fem kontrollpunkter mot den levande källan, källadress och anteckning. Stämpeln ”verifierad mot källa” kan bara sättas med alla fem ikryssade.
        </p>
        <table className="data">
          <thead>
            <tr><th>Stöd</th><th>Visningar 30 d</th><th>Status</th><th>Senast granskad</th><th>Nästa granskning</th><th /></tr>
          </thead>
          <tbody>
            {opportunities.map((o) => (
              <Fragment key={o.id}>
                <tr>
                  <td>
                    <a href={o.sourceUrl} target="_blank" rel="noreferrer">{o.title}</a>
                    {o.sourceIsStartPage && <> <span className="badge warning" title="Källan är en startsida — stödets egen sida saknas (M25)">startsida</span></>}
                  </td>
                  <td style={{ fontVariantNumeric: 'tabular-nums' }}>{o.shown30d}</td>
                  <td>
                    <span className={`badge ${o.verificationStatus === 'human_verified' ? 'success' : ''}`}>
                      {o.verificationStatus === 'human_verified' ? 'verifierad' : o.verificationStatus === 'human_curated' ? 'kurerad' : o.verificationStatus === 'ai_curated' ? 'AI-sammanställd' : o.verificationStatus}
                    </span>
                  </td>
                  <td>
                    {formatDate(o.lastVerifiedAt)}
                    {o.lastVerification?.by && <div className="meta-line">av {o.lastVerification.by}{o.lastVerification.note ? ` — ${o.lastVerification.note}` : ''}</div>}
                  </td>
                  <td>{o.overdue ? <span className="badge warning">förfallen</span> : formatDate(o.nextReviewAt)}</td>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    <button className="secondary" onClick={() => setOpenId(openId === o.id ? null : o.id)}>
                      {openId === o.id ? 'Stäng' : 'Granska'}
                    </button>{' '}
                    <Link to={`/admin/regler/${o.id}`}>Redigera regler</Link>
                  </td>
                </tr>
                {openId === o.id && (
                  <tr><td colSpan={6}><VerifyPanel opp={o} onDone={() => { setOpenId(null); load(); }} /></td></tr>
                )}
              </Fragment>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
