import { useCallback, useEffect, useRef, useState } from 'react';
import { ApiError, api, downloadFile, formatDate, get } from '../api';

interface DocRow {
  id: string;
  filename: string;
  contentType: string;
  sizeBytes: number;
  kind: string;
  scanStatus: string;
  createdAt: string;
}

const KINDS = [
  { value: 'cv', label: 'CV / meritförteckning' },
  { value: 'invitation', label: 'Inbjudan / bekräftelse' },
  { value: 'partner_letter', label: 'Partnerbrev' },
  { value: 'budget', label: 'Budget' },
  { value: 'stadgar', label: 'Stadgar' },
  { value: 'annual_report', label: 'Årsredovisning / verksamhetsberättelse' },
  { value: 'project_description', label: 'Projektbeskrivning' },
  { value: 'activity_programme', label: 'Aktivitetsprogram' },
  { value: 'receipt', label: 'Kvitto / bekräftelse' },
  { value: 'decision_letter', label: 'Beslut' },
  { value: 'other', label: 'Övrigt' },
];

export default function DocumentsPage() {
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
      setError(err instanceof ApiError ? err.message : 'Uppladdningen misslyckades.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div>
      <h1>Dokument och underlag</h1>
      <p className="guidance" style={{ maxWidth: 640 }}>
        Ladda upp dina underlag en gång — CV, intyg, budgetar, partnerbrev — och återanvänd dem i alla ansökningar.
      </p>
      <div className="card">
        <h2>Ladda upp</h2>
        <div style={{ display: 'flex', gap: '0.6rem', alignItems: 'end', flexWrap: 'wrap' }}>
          <div>
            <label>Typ av underlag</label>
            <select value={kind} onChange={(e) => setKind(e.target.value)}>
              {KINDS.map((k) => <option key={k.value} value={k.value}>{k.label}</option>)}
            </select>
          </div>
          <div>
            <label>Fil (PDF, PNG, JPG, DOCX, XLSX — max 20 MB)</label>
            <input type="file" ref={fileRef} accept=".pdf,.png,.jpg,.jpeg,.docx,.xlsx,.txt" />
          </div>
          <button disabled={busy} onClick={upload}>Ladda upp</button>
        </div>
        {error && <div className="alert error">{error}</div>}
      </div>
      <div className="card">
        <h2>Mitt valv ({docs.length})</h2>
        {docs.length === 0 && <p className="meta-line">Inga dokument ännu.</p>}
        {docs.length > 0 && (
          <table className="data">
            <thead><tr><th>Fil</th><th>Typ</th><th>Storlek</th><th>Säkerhet</th><th>Uppladdad</th><th /></tr></thead>
            <tbody>
              {docs.map((d) => (
                <tr key={d.id}>
                  <td>{d.filename}</td>
                  <td><span className="badge">{KINDS.find((k) => k.value === d.kind)?.label ?? d.kind}</span></td>
                  <td>{(d.sizeBytes / 1024).toFixed(0)} kB</td>
                  <td>
                    {d.scanStatus === 'clean' && <span className="badge success">skannad</span>}
                    {d.scanStatus === 'scan_unavailable' && <span className="badge">ej skannad</span>}
                    {d.scanStatus === 'pending' && <span className="badge warning">väntar</span>}
                    {d.scanStatus === 'blocked' && <span className="badge danger">stoppad</span>}
                  </td>
                  <td>{formatDate(d.createdAt)}</td>
                  <td>
                    <button className="subtle" onClick={() => void downloadFile(`/v1/documents/${d.id}/download`, d.filename)}>
                      Ladda ner
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
