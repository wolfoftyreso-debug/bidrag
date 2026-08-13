import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { STATE_LABELS, formatDate, get } from '../api';

interface CaseRow {
  id: string;
  state: string;
  deadlineAt: string | null;
  updatedAt: string;
  opportunityTitle: string;
  projectTitle: string;
}

export default function ApplicationsPage() {
  const [cases, setCases] = useState<CaseRow[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    get<{ applications: CaseRow[] }>('/v1/applications')
      .then(({ applications }) => setCases(applications))
      .finally(() => setLoaded(true));
  }, []);

  if (!loaded) return <p>Laddar…</p>;

  return (
    <div>
      <h1>Mina ansökningar</h1>
      <div className="card">
        {cases.length === 0 && (
          <p className="meta-line">
            Inga ansökningar ännu. Gå till <Link to="/projekt">Projekt &amp; matchningar</Link> och starta en ansökan från en
            matchning.
          </p>
        )}
        {cases.length > 0 && (
          <table className="data">
            <thead>
              <tr><th>Stöd</th><th>Projekt</th><th>Status</th><th>Deadline</th><th>Uppdaterad</th></tr>
            </thead>
            <tbody>
              {cases.map((c) => (
                <tr key={c.id}>
                  <td><Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link></td>
                  <td>{c.projectTitle}</td>
                  <td><span className={`badge ${STATE_LABELS[c.state]?.tone ?? ''}`}>{STATE_LABELS[c.state]?.label ?? c.state}</span></td>
                  <td>{formatDate(c.deadlineAt)}</td>
                  <td>{formatDate(c.updatedAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
