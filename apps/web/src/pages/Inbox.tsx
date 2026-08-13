/**
 * Unified funding inbox (§17): messages from authorities — uploaded, forwarded
 * or manually registered — matched to application cases. No external portal
 * credentials, ever.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ApiError, formatDate, get, post } from '../api';

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

const TYPE_LABELS: Record<string, { label: string; tone: string }> = {
  award: { label: 'Beviljat', tone: 'success' },
  rejection: { label: 'Avslag', tone: 'danger' },
  decision: { label: 'Beslut', tone: 'info' },
  clarification_request: { label: 'Komplettering begärs', tone: 'warning' },
  missing_document: { label: 'Dokument saknas', tone: 'warning' },
  deadline_extension: { label: 'Förlängd tid', tone: 'info' },
  payment_notice: { label: 'Utbetalning', tone: 'success' },
  reporting_request: { label: 'Redovisning begärs', tone: 'warning' },
  acknowledgement: { label: 'Mottagningsbekräftelse', tone: '' },
  other: { label: 'Övrigt', tone: '' },
};

export default function InboxPage() {
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
      setError(err instanceof ApiError ? err.message : 'Kunde inte registrera meddelandet.');
    }
  };

  return (
    <div>
      <h1>Inkorg</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>
        Samla svar från myndigheter och stiftelser på ett ställe. Registrera brev och e-post du fått — systemet kopplar dem
        till rätt ansökan och tolkar vad de betyder. Bidrag.se loggar aldrig in på myndigheters portaler åt dig.
      </p>

      <div className="card">
        <button className="secondary" onClick={() => setShowForm(!showForm)}>
          {showForm ? 'Avbryt' : '+ Registrera meddelande'}
        </button>
        {showForm && (
          <form
            style={{ marginTop: '0.8rem' }}
            onSubmit={(e) => {
              e.preventDefault();
              void register(e.currentTarget);
            }}
          >
            <label>Avsändare</label>
            <input name="sender" placeholder="t.ex. Kulturrådet" maxLength={320} />
            <label>Ämne</label>
            <input name="subject" required maxLength={500} />
            <label>Innehåll (klistra in texten)</label>
            <textarea name="body" maxLength={50000} />
            <label>Koppla till ansökan (frivilligt — annars försöker systemet själv)</label>
            <select name="caseId">
              <option value="">Automatisk koppling</option>
              {cases.map((c) => <option key={c.id} value={c.id}>{c.opportunityTitle}</option>)}
            </select>
            {error && <div className="alert error">{error}</div>}
            <button type="submit" style={{ marginTop: '0.8rem' }}>Registrera</button>
          </form>
        )}
      </div>

      <div className="card">
        <h2>Meddelanden ({rows.length})</h2>
        {rows.length === 0 && <p className="meta-line">Inga meddelanden ännu.</p>}
        {rows.map((r) => {
          const t = TYPE_LABELS[r.messageType] ?? TYPE_LABELS.other!;
          const linkedCase = cases.find((c) => c.id === r.caseId);
          return (
            <div key={r.id} style={{ padding: '0.7rem 0', borderBottom: '1px solid var(--border)' }}>
              <div>
                <strong>{r.subject}</strong> <span className={`badge ${t.tone}`}>{t.label}</span>{' '}
                {r.matchedBy === 'auto' && <span className="badge" title="Automatiskt kopplad — du kan ändra kopplingen.">auto-kopplad</span>}
                {r.matchedBy === 'unmatched' && <span className="badge warning">ej kopplad</span>}
              </div>
              <div className="meta-line">
                {r.sender || 'Okänd avsändare'} · {formatDate(r.receivedAt)}
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
