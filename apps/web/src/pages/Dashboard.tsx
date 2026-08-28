import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { STATE_LABELS, formatDate, get } from '../api';
import { useT } from '../i18n';

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
  const t = useT();
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

  if (!loaded) return <p>{t('app.loading')}</p>;

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
        <h1>{t('dash.welcome')}</h1>
        <div className="card">
          <h2>{t('dash.whatHelp')}</h2>
          <p>{t('dash.introBody')}</p>
          <p style={{ marginTop: '1rem' }}>
            <Link className="btn" to="/kom-igang">{t('dash.getStarted')}</Link>
          </p>
        </div>
      </div>
    );
  }

  return (
    <div>
      <h1>{t('dash.title')}</h1>

      {notifications.length > 0 && (
        <div className="card">
          <h2>{t('dash.newSince')}</h2>
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
          <h3>{t('dash.todo')}</h3>
          {needsAction.length === 0 && <p className="meta-line">{t('dash.noneWaiting')}</p>}
          {needsAction.slice(0, 5).map((c) => (
            <p key={c.id}>
              <Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link>
              <br />
              <span className={`badge ${STATE_LABELS[c.state]?.tone ?? ''}`}>{STATE_LABELS[c.state]?.label ?? c.state}</span>
            </p>
          ))}
        </div>
        <div className="card">
          <h3>{t('dash.upcoming')}</h3>
          {upcoming.length === 0 && <p className="meta-line">{t('dash.noDeadlines')}</p>}
          {upcoming.slice(0, 5).map((c) => (
            <p key={c.id}>
              <Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link>
              <br />
              <span className="meta-line">{t('dash.closes', { datum: formatDate(c.deadlineAt) })}</span>
            </p>
          ))}
        </div>
        <div className="card">
          <h3>{t('dash.myProjects')}</h3>
          {projects.map((p) => (
            <p key={p.id}>
              <Link to={`/projekt/${p.id}`}>{p.title}</Link>
            </p>
          ))}
          <p style={{ marginTop: '0.75rem' }}>
            <Link to="/kom-igang">{t('dash.newProject')}</Link>
          </p>
        </div>
      </div>

      <div className="card">
        <h2>{t('dash.myApplications')}</h2>
        {cases.length === 0 && <p className="meta-line">{t('dash.noApplications')}</p>}
        {cases.length > 0 && (
          <table className="data">
            <thead>
              <tr><th>{t('dash.thSupport')}</th><th>{t('dash.thProject')}</th><th>{t('dash.thStatus')}</th><th>{t('dash.thDeadline')}</th></tr>
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
