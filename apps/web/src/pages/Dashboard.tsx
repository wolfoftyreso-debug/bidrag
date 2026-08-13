import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { STATE_LABELS, formatDate, get } from '../api';

interface CaseRow {
  id: string;
  state: string;
  deadlineAt: string | null;
  opportunityTitle: string;
  projectTitle: string;
}
interface NotificationRow {
  id: string;
  kind: string;
  title: string;
  body: string;
  createdAt: string;
  readAt: string | null;
}
interface ProjectRow {
  id: string;
  title: string;
}

export default function DashboardPage() {
  const [cases, setCases] = useState<CaseRow[]>([]);
  const [notifications, setNotifications] = useState<NotificationRow[]>([]);
  const [projects, setProjects] = useState<ProjectRow[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    Promise.all([
      get<{ applications: CaseRow[] }>('/v1/applications'),
      get<{ notifications: NotificationRow[] }>('/v1/notifications?unreadOnly=true'),
      get<{ projects: ProjectRow[] }>('/v1/projects'),
    ])
      .then(([a, n, p]) => {
        setCases(a.applications);
        setNotifications(n.notifications);
        setProjects(p.projects);
      })
      .finally(() => setLoaded(true));
  }, []);

  if (!loaded) return <p>Laddar…</p>;

  const active = cases.filter((c) => !['CLOSED', 'REJECTED', 'WITHDRAWN'].includes(c.state));
  const upcoming = active
    .filter((c) => c.deadlineAt && new Date(c.deadlineAt) > new Date())
    .sort((a, b) => new Date(a.deadlineAt!).getTime() - new Date(b.deadlineAt!).getTime());
  const needsAction = active.filter((c) =>
    ['SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'ACTION_REQUIRED'].includes(c.state),
  );

  if (projects.length === 0) {
    return (
      <div style={{ maxWidth: 640 }}>
        <h1>Välkommen till Bidrag.se</h1>
        <div className="card">
          <h2>Vad behöver du hjälp med?</h2>
          <p>
            Berätta om din situation — eller vad du vill göra — så tar vi reda på vilka stöd, ersättningar och bidrag du
            kan ha rätt till. Du behöver inte veta vad något heter. En fråga i taget.
          </p>
          <p style={{ marginTop: '1rem' }}>
            <Link className="btn" to="/kom-igang">Kom igång</Link>
          </p>
        </div>
      </div>
    );
  }

  return (
    <div>
      <h1>Översikt</h1>

      {notifications.length > 0 && (
        <div className="card">
          <h2>Nytt sedan sist</h2>
          {notifications.slice(0, 5).map((n) => (
            <div key={n.id} style={{ padding: '0.35rem 0' }}>
              <strong>{n.title}</strong>
              {n.body && <p className="meta-line">{n.body}</p>}
            </div>
          ))}
        </div>
      )}

      <div className="grid cols-3">
        <div className="card">
          <h3>Att göra nu</h3>
          {needsAction.length === 0 && <p className="meta-line">Inga ansökningar väntar på dig.</p>}
          {needsAction.slice(0, 5).map((c) => (
            <p key={c.id}>
              <Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link>
              <br />
              <span className={`badge ${STATE_LABELS[c.state]?.tone ?? ''}`}>{STATE_LABELS[c.state]?.label ?? c.state}</span>
            </p>
          ))}
        </div>
        <div className="card">
          <h3>Kommande deadlines</h3>
          {upcoming.length === 0 && <p className="meta-line">Inga bevakade deadlines.</p>}
          {upcoming.slice(0, 5).map((c) => (
            <p key={c.id}>
              <Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link>
              <br />
              <span className="meta-line">Stänger {formatDate(c.deadlineAt)}</span>
            </p>
          ))}
        </div>
        <div className="card">
          <h3>Mina projekt</h3>
          {projects.map((p) => (
            <p key={p.id}>
              <Link to={`/projekt/${p.id}`}>{p.title}</Link>
            </p>
          ))}
          <p style={{ marginTop: '0.75rem' }}>
            <Link to="/kom-igang">+ Nytt projekt</Link>
          </p>
        </div>
      </div>

      <div className="card">
        <h2>Mina ansökningar</h2>
        {cases.length === 0 && <p className="meta-line">Inga ansökningar ännu — börja från en matchning under Projekt.</p>}
        {cases.length > 0 && (
          <table className="data">
            <thead>
              <tr><th>Stöd</th><th>Projekt</th><th>Status</th><th>Deadline</th></tr>
            </thead>
            <tbody>
              {cases.map((c) => (
                <tr key={c.id}>
                  <td><Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link></td>
                  <td>{c.projectTitle}</td>
                  <td><span className={`badge ${STATE_LABELS[c.state]?.tone ?? ''}`}>{STATE_LABELS[c.state]?.label ?? c.state}</span></td>
                  <td>{formatDate(c.deadlineAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
