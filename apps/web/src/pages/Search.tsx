import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { INSTRUMENT_LABELS, formatDate, formatSek, get } from '../api';
import { useLabels, useT } from '../i18n';

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
  const t = useT();
  const labels = useLabels();
  const [q, setQ] = useState('');
  const [instrument, setInstrument] = useState('');
  const [openOnly, setOpenOnly] = useState(true);
  const [rows, setRows] = useState<OppRow[]>([]);

  useEffect(() => {
    const params = new URLSearchParams();
    if (q) params.set('q', q);
    if (instrument) params.set('instrumentType', instrument);
    if (openOnly) params.set('openOnly', 'true');
    const timer = setTimeout(() => {
      get<{ opportunities: OppRow[] }>(`/v1/funding-opportunities?${params}`).then(({ opportunities }) =>
        setRows(opportunities),
      );
    }, 250);
    return () => clearTimeout(timer);
  }, [q, instrument, openOnly]);

  return (
    <div>
      <h1>{t('nav.search')}</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>
        {t('s.guidancePre')} <Link to="/projekt">{t('s.guidanceLink')}</Link>.
      </p>
      <div className="card">
        <div style={{ display: 'flex', gap: '0.6rem', flexWrap: 'wrap', alignItems: 'end' }}>
          <div style={{ flex: 2, minWidth: 220 }}>
            <label>{t('s.search')}</label>
            <input value={q} onChange={(e) => setQ(e.target.value)} placeholder={t('s.searchPlaceholder')} />
          </div>
          <div style={{ flex: 1, minWidth: 170 }}>
            <label>{t('s.type')}</label>
            <select value={instrument} onChange={(e) => setInstrument(e.target.value)}>
              <option value="">{t('s.allTypes')}</option>
              {Object.keys(INSTRUMENT_LABELS).map((v) => <option key={v} value={v}>{labels.instr(v)}</option>)}
            </select>
          </div>
          <div className="checkbox-row" style={{ margin: 0 }}>
            <input id="open" type="checkbox" checked={openOnly} onChange={(e) => setOpenOnly(e.target.checked)} />
            <label htmlFor="open">{t('s.openOnly')}</label>
          </div>
        </div>
      </div>
      <div className="card">
        {rows.length === 0 && <p className="meta-line">{t('s.noHits')}</p>}
        {rows.map((o) => (
          <div key={o.id} className="match-row">
            <div style={{ flex: 1 }}>
              <div><Link to={`/stod/${o.slug}`} style={{ fontWeight: 600 }}>{o.title}</Link></div>
              <div className="meta-line">
                {o.authorityName} · <span className="badge info">{labels.instr(o.instrumentType)}</span>
                {o.maxAmountMinor && <> · {t('m.upTo', { belopp: formatSek(o.maxAmountMinor) })}</>}
                {' · '}
                {o.closesAt ? t('s.closesShort', { datum: formatDate(o.closesAt) }) : o.deadlineModel === 'rolling' ? t('s.rollingShort') : t('s.upcomingShort')}
              </div>
              <p className="meta-line">{o.summary}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
