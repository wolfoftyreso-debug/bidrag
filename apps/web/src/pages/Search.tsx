import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { INSTRUMENT_LABELS, formatDate, formatSek, get } from '../api';

interface OppRow {
  id: string;
  slug: string;
  title: string;
  summary: string;
  instrumentType: string;
  authorityName: string;
  maxAmountMinor: number | null;
  closesAt: string | null;
  deadlineModel: string;
  lastVerifiedAt: string | null;
}

export default function SearchPage() {
  const [q, setQ] = useState('');
  const [instrument, setInstrument] = useState('');
  const [openOnly, setOpenOnly] = useState(true);
  const [rows, setRows] = useState<OppRow[]>([]);

  useEffect(() => {
    const params = new URLSearchParams();
    if (q) params.set('q', q);
    if (instrument) params.set('instrumentType', instrument);
    if (openOnly) params.set('openOnly', 'true');
    const t = setTimeout(() => {
      get<{ opportunities: OppRow[] }>(`/v1/funding-opportunities?${params}`).then(({ opportunities }) =>
        setRows(opportunities),
      );
    }, 250);
    return () => clearTimeout(t);
  }, [q, instrument, openOnly]);

  return (
    <div>
      <h1>Sök stöd</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>
        Fritextsökning i kunskapsbasen. För en personlig bedömning av vad just du kan söka — använd{' '}
        <Link to="/projekt">matchningarna</Link>.
      </p>
      <div className="card">
        <div style={{ display: 'flex', gap: '0.6rem', flexWrap: 'wrap', alignItems: 'end' }}>
          <div style={{ flex: 2, minWidth: 220 }}>
            <label>Sök</label>
            <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="t.ex. resebidrag, energi, ungdomsutbyte" />
          </div>
          <div style={{ flex: 1, minWidth: 170 }}>
            <label>Typ av stöd</label>
            <select value={instrument} onChange={(e) => setInstrument(e.target.value)}>
              <option value="">Alla typer</option>
              {Object.entries(INSTRUMENT_LABELS).map(([v, l]) => <option key={v} value={v}>{l}</option>)}
            </select>
          </div>
          <div className="checkbox-row" style={{ margin: 0 }}>
            <input id="open" type="checkbox" checked={openOnly} onChange={(e) => setOpenOnly(e.target.checked)} />
            <label htmlFor="open">Bara öppna</label>
          </div>
        </div>
      </div>
      <div className="card">
        {rows.length === 0 && <p className="meta-line">Inga träffar.</p>}
        {rows.map((o) => (
          <div key={o.id} className="match-row">
            <div style={{ flex: 1 }}>
              <div><Link to={`/stod/${o.slug}`} style={{ fontWeight: 600 }}>{o.title}</Link></div>
              <div className="meta-line">
                {o.authorityName} · <span className="badge info">{INSTRUMENT_LABELS[o.instrumentType] ?? o.instrumentType}</span>
                {o.maxAmountMinor && <> · upp till {formatSek(o.maxAmountMinor)}</>}
                {' · '}
                {o.closesAt ? `stänger ${formatDate(o.closesAt)}` : o.deadlineModel === 'rolling' ? 'löpande' : 'kommande omgång'}
              </div>
              <p className="meta-line">{o.summary}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
