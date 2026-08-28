import { useCallback, useEffect, useRef, useState } from 'react';
import { ApiError, api, downloadFile, formatDate, get } from '../api';
import { useLabels, useT } from '../i18n';

interface DocRow {
  id: string;
  filename: string;
  contentType: string;
  sizeBytes: number;
  kind: string;
  scanStatus: string;
  createdAt: string;
}

const KIND_VALUES = [
  'cv', 'invitation', 'partner_letter', 'budget', 'stadgar', 'annual_report',
  'project_description', 'activity_programme', 'receipt', 'decision_letter', 'other',
];

export default function DocumentsPage() {
  const t = useT();
  const labels = useLabels();
  const [docs, setDocs] = useState<DocRow[]>([]);
  const [kind, setKind] = useState('other');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const load = useCallback(() => {
    get<{ documents: DocRow[] }>('/v1/documents').then(({ documents }) => setDocs(documents));
  }, []);
  useEffect(load, [load]);

  const upload = async () => {
    const file = fileRef.current?.files?.[0];
    if (!file) return;
    setBusy(true);
    setError(null);
    try {
      const fd = new FormData();
      fd.append('kind', kind);
      fd.append('file', file);
      await api('POST', '/v1/documents', fd);
      if (fileRef.current) fileRef.current.value = '';
      load();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('d.uploadError'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div>
      <h1>{t('d.title')}</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>{t('d.guidance')}</p>
      <div className="card">
        <h2>{t('d.upload')}</h2>
        <div style={{ display: 'flex', gap: '0.6rem', alignItems: 'end', flexWrap: 'wrap' }}>
          <div>
            <label>{t('d.kindLabel')}</label>
            <select value={kind} onChange={(e) => setKind(e.target.value)}>
              {KIND_VALUES.map((k) => <option key={k} value={k}>{labels.doc(k)}</option>)}
            </select>
          </div>
          <div>
            <label>{t('d.fileLabel')}</label>
            <input type="file" ref={fileRef} accept=".pdf,.png,.jpg,.jpeg,.docx,.xlsx,.txt" />
          </div>
          <button disabled={busy} onClick={upload}>{t('d.upload')}</button>
        </div>
        {error && <div className="alert error">{error}</div>}
      </div>
      <div className="card">
        <h2>{t('d.vault', { n: docs.length })}</h2>
        {docs.length === 0 && <p className="meta-line">{t('d.none')}</p>}
        {docs.length > 0 && (
          <table className="data">
            <thead><tr><th>{t('d.thFile')}</th><th>{t('d.thType')}</th><th>{t('d.thSize')}</th><th>{t('d.thSecurity')}</th><th>{t('d.thUploaded')}</th><th /></tr></thead>
            <tbody>
              {docs.map((d) => (
                <tr key={d.id}>
                  <td>{d.filename}</td>
                  <td><span className="badge">{labels.doc(d.kind)}</span></td>
                  <td>{(d.sizeBytes / 1024).toFixed(0)} kB</td>
                  <td>
                    {d.scanStatus === 'clean' && <span className="badge success">{t('d.scanClean')}</span>}
                    {d.scanStatus === 'scan_unavailable' && <span className="badge">{t('d.scanUnavailable')}</span>}
                    {d.scanStatus === 'pending' && <span className="badge warning">{t('d.scanPending')}</span>}
                    {d.scanStatus === 'blocked' && <span className="badge danger">{t('d.scanBlocked')}</span>}
                  </td>
                  <td>{formatDate(d.createdAt)}</td>
                  <td>
                    <button className="subtle" onClick={() => void downloadFile(`/v1/documents/${d.id}/download`, d.filename)}>
                      {t('d.download')}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
