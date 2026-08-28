import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { formatDate, get } from '../api';
import { useLabels, useT } from '../i18n';

interface CaseRow {
  id: string;
  state: string;
  deadlineAt: string | null;
  updatedAt: string;
  opportunityTitle: string;
  projectTitle: string;
}

export default function ApplicationsPage() {
  const t = useT();
  const labels = useLabels();
  const [cases, setCases] = useState<CaseRow[]>([]);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    get<{ applications: CaseRow[] }>('/v1/applications')
      .then(({ applications }) => setCases(applications))
      .finally(() => setLoaded(true));
  }, []);

  if (!loaded) return <p>{t('app.loading')}</p>;

  return (
    <div>
      <h1>{t('dash.myApplications')}</h1>
      <div className="card">
        {cases.length === 0 && (
          <p className="meta-line">
            {t('ap.nonePre')} <Link to="/projekt">{t('nav.projects')}</Link> {t('ap.nonePost')}
          </p>
        )}
        {cases.length > 0 && (
          <table className="data">
            <thead>
              <tr><th>{t('dash.thSupport')}</th><th>{t('dash.thProject')}</th><th>{t('dash.thStatus')}</th><th>{t('dash.thDeadline')}</th><th>{t('ap.thUpdated')}</th></tr>
            </thead>
            <tbody>
              {cases.map((c) => (
                <tr key={c.id}>
                  <td><Link to={`/ansokningar/${c.id}`}>{c.opportunityTitle}</Link></td>
                  <td>{c.projectTitle}</td>
                  <td><span className={`badge ${labels.state(c.state).tone}`}>{labels.state(c.state).label}</span></td>
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
