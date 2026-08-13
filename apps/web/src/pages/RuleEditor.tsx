/**
 * Kuratorns regeleditor (§43): källa ändrad → uppdatera kriterier → publicera
 * ny regelversion → matchningar räknas om. Servern validerar strukturen och
 * vägrar publicera trasiga regler; editorn visar felen per fält och en
 * klartextförhandsvisning av vad reglerna faktiskt betyder.
 */
import { useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ApiError, formatDate, get, post } from '../api';

interface Criterion {
  id: string;
  kind: 'hard' | 'mandatory' | 'weighted';
  factPath: string;
  op: string;
  expected?: unknown;
  weight?: number;
  description: string;
  intakeQuestion?: string;
}
interface Detail {
  opportunity: { id: string; title: string; sourceUrl: string; lastVerifiedAt: string | null };
  ruleVersion: {
    version: number;
    criteria: Criterion[];
    budgetRules: unknown[];
    evidenceRequirements: unknown[];
    effectiveFrom: string;
  } | null;
}
interface Issue { path: string; message: string }

const KIND_LABEL: Record<string, { label: string; tone: string }> = {
  hard: { label: 'hårt krav', tone: 'danger' },
  mandatory: { label: 'obligatoriskt', tone: 'warning' },
  weighted: { label: 'viktat', tone: 'info' },
};

function tryParse(text: string): { ok: true; value: unknown } | { ok: false; error: string } {
  try {
    return { ok: true, value: JSON.parse(text) };
  } catch (e) {
    return { ok: false, error: (e as Error).message };
  }
}

export default function RuleEditorPage() {
  const { id } = useParams();
  const [detail, setDetail] = useState<Detail | null>(null);
  const [criteriaText, setCriteriaText] = useState('');
  const [budgetText, setBudgetText] = useState('');
  const [evidenceText, setEvidenceText] = useState('');
  const [changeNote, setChangeNote] = useState('');
  const [issues, setIssues] = useState<Issue[]>([]);
  const [message, setMessage] = useState<{ tone: string; text: string } | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!id) return;
    get<Detail>(`/v1/funding-opportunities/${id}`).then((d) => {
      setDetail(d);
      setCriteriaText(JSON.stringify(d.ruleVersion?.criteria ?? [], null, 2));
      setBudgetText(JSON.stringify(d.ruleVersion?.budgetRules ?? [], null, 2));
      setEvidenceText(JSON.stringify(d.ruleVersion?.evidenceRequirements ?? [], null, 2));
    });
  }, [id]);

  const parsedCriteria = useMemo(() => tryParse(criteriaText), [criteriaText]);
  const parsedBudget = useMemo(() => tryParse(budgetText), [budgetText]);
  const parsedEvidence = useMemo(() => tryParse(evidenceText), [evidenceText]);
  const jsonErrors = [
    !parsedCriteria.ok && `Kriterier: ${parsedCriteria.error}`,
    !parsedBudget.ok && `Budgetregler: ${parsedBudget.error}`,
    !parsedEvidence.ok && `Underlagskrav: ${parsedEvidence.error}`,
  ].filter(Boolean) as string[];

  const publish = async () => {
    if (!id || !parsedCriteria.ok || !parsedBudget.ok || !parsedEvidence.ok) return;
    setBusy(true);
    setIssues([]);
    setMessage(null);
    try {
      await post(`/v1/admin/opportunities/${id}/rule-versions`, {
        criteria: parsedCriteria.value,
        budgetRules: parsedBudget.value,
        evidenceRequirements: parsedEvidence.value,
        changeNote,
      });
      setMessage({ tone: 'success', text: 'Ny regelversion publicerad. Berörda matchningar är markerade för omräkning och räknas om automatiskt.' });
      setChangeNote('');
      const d = await get<Detail>(`/v1/funding-opportunities/${id}`);
      setDetail(d);
    } catch (err) {
      if (err instanceof ApiError && err.status === 422) {
        setIssues(((err.body as { issues?: Issue[] }).issues ?? []) as Issue[]);
        setMessage({ tone: 'error', text: 'Servern vägrade publicera — åtgärda felen nedan.' });
      } else {
        setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : 'Publiceringen misslyckades.' });
      }
    } finally {
      setBusy(false);
    }
  };

  if (!detail) return <p>Laddar…</p>;
  const preview = parsedCriteria.ok && Array.isArray(parsedCriteria.value) ? (parsedCriteria.value as Criterion[]) : [];

  return (
    <div style={{ maxWidth: 860 }}>
      <p><Link to="/admin">&larr; Administration</Link></p>
      <h1>Regler — {detail.opportunity.title}</h1>
      <p className="meta-line">
        Nuvarande version: {detail.ruleVersion?.version ?? '—'} (gäller från {formatDate(detail.ruleVersion?.effectiveFrom ?? null)}) ·{' '}
        <a href={detail.opportunity.sourceUrl} target="_blank" rel="noreferrer">källa ↗</a> · senast verifierad {formatDate(detail.opportunity.lastVerifiedAt)}
      </p>

      {message && <div className={`alert ${message.tone}`}>{message.text}</div>}
      {jsonErrors.map((e) => <div key={e} className="alert error">{e}</div>)}
      {issues.length > 0 && (
        <div className="alert error">
          {issues.map((i) => <div key={`${i.path}:${i.message}`}><code>{i.path}</code> — {i.message}</div>)}
        </div>
      )}

      <div className="card">
        <h2>Kriterier</h2>
        <p className="guidance">
          Varje kriterium: <code>id</code>, <code>kind</code> (hard/mandatory/weighted), <code>factPath</code>,{' '}
          <code>op</code>, ev. <code>expected</code>, <code>description</code> på klarsvenska, och{' '}
          <code>intakeQuestion</code> för obligatoriska krav.
        </p>
        <textarea
          value={criteriaText}
          onChange={(e) => setCriteriaText(e.target.value)}
          spellCheck={false}
          style={{ fontFamily: 'monospace', fontSize: '0.82rem', minHeight: 260 }}
        />
        {preview.length > 0 && (
          <>
            <h3>Så läser systemet reglerna</h3>
            {preview.map((c, i) => (
              <div className="explain-item" key={c.id ?? i}>
                <span className={`badge ${KIND_LABEL[c.kind]?.tone ?? ''}`} style={{ flexShrink: 0 }}>
                  {KIND_LABEL[c.kind]?.label ?? c.kind}
                </span>
                <span>
                  {c.description || <em>saknar beskrivning</em>}{' '}
                  <span className="meta-line">({c.factPath} {c.op}{c.expected !== undefined ? ` ${JSON.stringify(c.expected)}` : ''})</span>
                </span>
              </div>
            ))}
          </>
        )}
      </div>

      <div className="card">
        <h2>Budgetregler</h2>
        <textarea value={budgetText} onChange={(e) => setBudgetText(e.target.value)} spellCheck={false} style={{ fontFamily: 'monospace', fontSize: '0.82rem', minHeight: 120 }} />
        <h2>Underlagskrav</h2>
        <textarea value={evidenceText} onChange={(e) => setEvidenceText(e.target.value)} spellCheck={false} style={{ fontFamily: 'monospace', fontSize: '0.82rem', minHeight: 120 }} />
      </div>

      <div className="card">
        <h2>Publicera ny version</h2>
        <label>Ändringsnotering (visas i historiken och för berörda användare)</label>
        <input value={changeNote} onChange={(e) => setChangeNote(e.target.value)} placeholder='t.ex. "Programmet införde medfinansieringskrav 2026-09-01"' maxLength={2000} />
        <p className="guidance">
          Publicering effektivdaterar den gamla versionen, markerar berörda matchningar som inaktuella (omräknas automatiskt)
          och notifierar berörda användare. Redan inlämnade ansökningar påverkas aldrig.
        </p>
        <button disabled={busy || jsonErrors.length > 0 || changeNote.trim().length === 0} onClick={publish}>
          {busy ? 'Publicerar…' : 'Publicera ny regelversion'}
        </button>
      </div>
    </div>
  );
}
