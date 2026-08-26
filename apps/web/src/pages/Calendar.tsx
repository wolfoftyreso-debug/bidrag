/**
 * Deadlinekalender (§51): dina ansökningars deadlines och öppna stöd som
 * stänger, grupperade per månad, med interna milstolpar från deadlinemotorn.
 */
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { STATE_LABELS, formatDate, get } from '../api';

interface CaseRow {
  id: string;
  state: string;
  deadlineAt: string | null;
  opportunityTitle: string;
}
interface OppRow {
  id: string;
  slug: string;
  title: string;
  closesAt: string | null;
  authorityName: string;
}
interface Entry {
  date: Date;
  kind: 'application' | 'opportunity';
  title: string;
  sub: string;
  link: string;
  tone: string;
}

export default function CalendarPage() {
  const [entries, setEntries] = useState<Entry[] | null>(null);

  useEffect(() => {
    Promise.all([
      get<{ applications: CaseRow[] }>('/v1/applications'),
      get<{ opportunities: OppRow[] }>('/v1/funding-opportunities?openOnly=true&limit=100'),
    ]).then(([a, o]) => {
      const now = Date.now();
      const list: Entry[] = [];
      for (const c of a.applications) {
        if (!c.deadlineAt || new Date(c.deadlineAt).getTime() < now) continue;
        if (['CLOSED', 'REJECTED', 'WITHDRAWN', 'AWARDED', 'SUBMITTED'].includes(c.state)) continue;
        const days = Math.ceil((new Date(c.deadlineAt).getTime() - now) / 86_400_000);
        list.push({
          date: new Date(c.deadlineAt),
          kind: 'application',
          title: c.opportunityTitle,
          sub: `Din ansökan · ${STATE_LABELS[c.state]?.label ?? c.state} · ${days === 0 ? 'sista dagen idag' : `${days} ${days === 1 ? 'dag' : 'dagar'} kvar`}`,
          link: `/ansokningar/${c.id}`,
          tone: days <= 7 ? 'danger' : days <= 14 ? 'warning' : 'info',
        });
      }
      const caseTitles = new Set(a.applications.map((c) => c.opportunityTitle));
      for (const opp of o.opportunities) {
        if (!opp.closesAt || new Date(opp.closesAt).getTime() < now) continue;
        if (caseTitles.has(opp.title)) continue; // redan i dina ansökningar
        list.push({
          date: new Date(opp.closesAt),
          kind: 'opportunity',
          title: opp.title,
          sub: `${opp.authorityName} · ansökan stänger`,
          link: `/stod/${opp.slug}`,
          tone: '',
        });
      }
      list.sort((x, y) => x.date.getTime() - y.date.getTime());
      setEntries(list);
    });
  }, []);

  if (!entries) return <p>Laddar…</p>;

  const byMonth = new Map<string, Entry[]>();
  for (const e of entries) {
    const key = e.date.toLocaleDateString('sv-SE', { year: 'numeric', month: 'long' });
    byMonth.set(key, [...(byMonth.get(key) ?? []), e]);
  }

  return (
    <div style={{ maxWidth: 720 }}>
      <h1>Kalender</h1>
      <p className="guidance">Deadlines för dina ansökningar och öppna stöd som stänger. Påminnelser skickas automatiskt 14, 7 och 3 dagar före.</p>
      {entries.length === 0 && (
        <div className="card"><p className="meta-line">Inga kommande deadlines. Löpande stöd utan slutdatum visas inte här.</p></div>
      )}
      {[...byMonth.entries()].map(([month, list]) => (
        <div className="card" key={month}>
          <h2 style={{ textTransform: 'capitalize' }}>{month}</h2>
          {list.map((e, i) => (
            <div className="match-row" key={i}>
              <div className="match-score" style={{ minWidth: 54 }}>
                <div className="n" style={{ fontSize: '1.2rem' }}>{e.date.getDate()}</div>
                <div className="of">{e.date.toLocaleDateString('sv-SE', { weekday: 'short' })}</div>
              </div>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={e.link} style={{ fontWeight: 600 }}>{e.title}</Link>{' '}
                  {e.kind === 'application' ? <span className={`badge ${e.tone}`}>din ansökan</span> : <span className="badge">öppet stöd</span>}
                </div>
                <div className="meta-line">{e.sub} · {formatDate(e.date.toISOString())}</div>
              </div>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}
