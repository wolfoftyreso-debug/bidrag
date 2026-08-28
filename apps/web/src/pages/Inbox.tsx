/**
 * Unified funding inbox (§17): messages from authorities — uploaded, forwarded
 * or manually registered — matched to application cases. No external portal
 * credentials, ever.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ApiError, formatDate, get, post } from '../api';
import { useLabels, useT } from '../i18n';

interface CorrRow {
  id: string;
  caseId: string | null;
  source: string;
  sender: string;
  subject: string;
  body: string;
  messageType: string;
  confidence: string;
  matchedBy: string;
  receivedAt: string;
}
interface CaseRow {
  id: string;
  opportunityTitle: string;
}

export default function InboxPage() {
  const t = useT();
  const labels = useLabels();
  const [rows, setRows] = useState<CorrRow[]>([]);
  const [cases, setCases] = useState<CaseRow[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    get<{ correspondence: CorrRow[] }>('/v1/correspondence').then(({ correspondence }) => setRows(correspondence));
    get<{ applications: CaseRow[] }>('/v1/applications').then(({ applications }) => setCases(applications));
  }, []);
  useEffect(load, [load]);

  const register = async (form: HTMLFormElement) => {
    const fd = new FormData(form);
    setError(null);
    try {
      await post('/v1/correspondence', {
        source: 'manual',
        sender: String(fd.get('sender') ?? ''),
        subject: String(fd.get('subject')),
        body: String(fd.get('body') ?? ''),
        caseId: fd.get('caseId') ? String(fd.get('caseId')) : undefined,
      });
      form.reset();
      setShowForm(false);
      load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('in.registerError'));
    }
  };

  return (
    <div>
      <h1>{t('nav.inbox')}</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>{t('in.guidance')}</p>

      <div className="card">
        <button className="secondary" onClick={() => setShowForm(!showForm)}>
          {showForm ? t('in.cancel') : t('in.registerToggle')}
        </button>
        {showForm && (
          <form
            style={{ marginTop: '0.8rem' }}
            onSubmit={(e) => {
              e.preventDefault();
              void register(e.currentTarget);
            }}
          >
            <label>{t('in.sender')}</label>
            <input name="sender" placeholder={t('in.senderPlaceholder')} maxLength={320} />
            <label>{t('in.subject')}</label>
            <input name="subject" required maxLength={500} />
            <label>{t('in.bodyLabel')}</label>
            <textarea name="body" maxLength={50000} />
            <label>{t('in.linkCase')}</label>
            <select name="caseId">
              <option value="">{t('in.autoLink')}</option>
              {cases.map((c) => <option key={c.id} value={c.id}>{c.opportunityTitle}</option>)}
            </select>
            {error && <div className="alert error">{error}</div>}
            <button type="submit" style={{ marginTop: '0.8rem' }}>{t('in.register')}</button>
          </form>
        )}
      </div>

      <div className="card">
        <h2>{t('in.messages', { n: rows.length })}</h2>
        {rows.length === 0 && <p className="meta-line">{t('in.none')}</p>}
        {rows.map((r) => {
          const msg = labels.msg(r.messageType);
          const linkedCase = cases.find((c) => c.id === r.caseId);
          return (
            <div key={r.id} style={{ padding: '0.7rem 0', borderBottom: '1px solid var(--border)' }}>
              <div>
                <strong>{r.subject}</strong> <span className={`badge ${msg.tone}`}>{msg.label}</span>{' '}
                {r.matchedBy === 'auto' && <span className="badge" title={t('in.autoLinkedTitle')}>{t('in.autoLinked')}</span>}
                {r.matchedBy === 'unmatched' && <span className="badge warning">{t('in.unlinked')}</span>}
              </div>
              <div className="meta-line">
                {r.sender || t('in.unknownSender')} · {formatDate(r.receivedAt)}
                {linkedCase && <> · <Link to={`/ansokningar/${linkedCase.id}`}>{linkedCase.opportunityTitle}</Link></>}
              </div>
              {r.body && <p className="meta-line" style={{ whiteSpace: 'pre-wrap' }}>{r.body.slice(0, 300)}{r.body.length > 300 ? '…' : ''}</p>}
            </div>
          );
        })}
      </div>
    </div>
  );
}
