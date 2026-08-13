/**
 * Application workspace (§14): schema-driven form, budget builder, evidence,
 * validation status, guarded state transitions and the assisted submission
 * flow — the case is only SUBMITTED once a receipt is recorded.
 */
import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ApiError, STATE_LABELS, formatDate, formatSek, get, patch, post } from '../api';

interface FieldDef {
  key: string;
  type: string;
  label: string;
  guidance?: string;
  required: boolean;
  maxLength?: number;
  min?: number;
  max?: number;
  options?: { value: string; label: string }[];
  visibleWhen?: { factPath: string; op: string; expected?: unknown }[];
  section: string;
}
interface SchemaDef {
  title: string;
  sections: { key: string; title: string; description?: string }[];
  fields: FieldDef[];
}
interface Validation {
  fieldIssues: { fieldKey: string; message: string }[];
  budgetFindings: { severity: string; message: string }[];
  missingAttachments: { kind: string; description: string }[];
  ready: boolean;
}
interface BudgetLine {
  id: string;
  category: string;
  description: string;
  quantity: number;
  unitCostMinor: number;
}
interface CaseDoc {
  linkId: string;
  documentId: string;
  filename: string;
  kind: string;
  role: string;
}
interface Submission {
  id: string;
  level: string;
  state: string;
  startedAt: string;
}
interface Decision {
  id: string;
  outcome: 'awarded' | 'partially_awarded' | 'rejected';
  amountMinor: number | null;
  reference: string;
  decidedAt: string;
  note: string;
}
interface ReportingRequirement {
  id: string;
  title: string;
  dueAt: string | null;
  status: 'pending' | 'submitted' | 'accepted';
}
interface CaseData {
  application: {
    id: string;
    state: string;
    answers: Record<string, unknown>;
    answerProvenance: Record<string, string>;
    financing: { requestedMinor: number; ownContributionMinor: number; otherFundingMinor: number; inKindMinor: number } | null;
    deadlineAt: string | null;
    opportunitySnapshot: { opportunity: { title: string; applicationUrl: string | null; applicationMethod: string; sourceUrl: string } };
  };
  schema: SchemaDef | null;
  budgetLines: BudgetLine[];
  documents: CaseDoc[];
  submissions: Submission[];
  decisions: Decision[];
  reportingRequirements: ReportingRequirement[];
  validation: Validation;
}

const BUDGET_CATEGORIES = ['travel', 'accommodation', 'personnel', 'equipment', 'subcontractor', 'overhead', 'other'];
const CATEGORY_LABELS: Record<string, string> = {
  travel: 'Resor',
  accommodation: 'Boende',
  personnel: 'Personal/arvoden',
  equipment: 'Utrustning',
  subcontractor: 'Underleverantörer',
  overhead: 'Overhead',
  other: 'Övrigt',
};

function isVisible(field: FieldDef, answers: Record<string, unknown>): boolean {
  if (!field.visibleWhen?.length) return true;
  return field.visibleWhen.every((cond) => {
    const v = answers[cond.factPath];
    switch (cond.op) {
      case 'is_true': return v === true;
      case 'is_false': return v === false;
      case 'eq': return v === cond.expected;
      default: return true;
    }
  });
}

const EDITABLE_STATES = ['SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'ACTION_REQUIRED'];

export default function ApplicationPage() {
  const { id } = useParams();
  const [data, setData] = useState<CaseData | null>(null);
  const [answers, setAnswers] = useState<Record<string, unknown>>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [dirty, setDirty] = useState(false);
  const [message, setMessage] = useState<{ tone: string; text: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [submitPrep, setSubmitPrep] = useState<{ submissionId: string; officialUrl: string | null } | null>(null);
  const [receiptRef, setReceiptRef] = useState('');

  const load = useCallback(async () => {
    if (!id) return;
    const d = await get<CaseData>(`/v1/applications/${id}`);
    setData(d);
    setAnswers(d.application.answers ?? {});
    setDirty(false);
    const pending = d.submissions.find((s) => s.level === 'assisted' && s.state === 'pending');
    if (pending) {
      setSubmitPrep({ submissionId: pending.id, officialUrl: d.application.opportunitySnapshot.opportunity.applicationUrl });
    }
  }, [id]);

  useEffect(() => {
    load().catch(() => setMessage({ tone: 'error', text: 'Ansökan kunde inte hämtas.' }));
  }, [load]);

  const editable = data ? EDITABLE_STATES.includes(data.application.state) : false;

  const budgetTotal = useMemo(
    () => (data?.budgetLines ?? []).reduce((s, l) => s + l.quantity * l.unitCostMinor, 0),
    [data],
  );

  if (!data) return <p>Laddar…</p>;
  const { application: app, schema, validation } = data;
  const opp = app.opportunitySnapshot.opportunity;
  const stateInfo = STATE_LABELS[app.state] ?? { label: app.state, tone: '' };

  const save = async () => {
    setBusy(true);
    setMessage(null);
    try {
      await patch(`/v1/applications/${app.id}`, { answers });
      await load();
      setMessage({ tone: 'success', text: 'Sparat.' });
    } catch (err) {
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : 'Kunde inte spara.' });
    } finally {
      setBusy(false);
    }
  };

  const transition = async (to: string) => {
    setBusy(true);
    setMessage(null);
    try {
      await post(`/v1/applications/${app.id}/transition`, { to });
      await load();
    } catch (err) {
      if (err instanceof ApiError && err.status === 422) {
        setMessage({ tone: 'warning', text: 'Ansökan är inte komplett ännu — se listan nedan.' });
        await load();
      } else {
        setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : 'Kunde inte ändra status.' });
      }
    } finally {
      setBusy(false);
    }
  };

  const prepareSubmit = async () => {
    setBusy(true);
    setMessage(null);
    try {
      const res = await post<{ mode: string; submissionId: string; officialUrl: string | null; message: string }>(
        `/v1/applications/${app.id}/submit`,
        { confirm: true },
      );
      setSubmitPrep({ submissionId: res.submissionId, officialUrl: res.officialUrl });
      setMessage({ tone: 'info', text: res.message });
      await load();
    } catch (err) {
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : 'Kunde inte förbereda inlämningen.' });
    } finally {
      setBusy(false);
    }
  };

  const confirmExternal = async () => {
    if (!submitPrep || !receiptRef.trim()) return;
    setBusy(true);
    try {
      await post(`/v1/applications/${app.id}/submissions/${submitPrep.submissionId}/confirm-external`, {
        reference: receiptRef.trim(),
      });
      setSubmitPrep(null);
      await load();
      setMessage({ tone: 'success', text: 'Kvittot är registrerat och ansökan är markerad som inlämnad.' });
    } catch (err) {
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : 'Kunde inte registrera kvittot.' });
    } finally {
      setBusy(false);
    }
  };

  const addBudgetLine = async (form: HTMLFormElement) => {
    const fd = new FormData(form);
    const kr = Number(fd.get('unitCost'));
    await post(`/v1/applications/${app.id}/budget-lines`, {
      category: String(fd.get('category')),
      description: String(fd.get('description')),
      quantity: Number(fd.get('quantity')),
      unitCostMinor: Math.round(kr * 100),
    });
    form.reset();
    await load();
  };

  // Per-field errors only once the user has touched the field or asked for
  // review — a fresh form should read as a to-do list, not a wall of red.
  const strictStates = ['READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'ACTION_REQUIRED'];
  const issueFor = (key: string) =>
    touched[key] || strictStates.includes(app.state)
      ? validation.fieldIssues.find((i) => i.fieldKey === key)?.message
      : undefined;

  return (
    <div style={{ maxWidth: 780 }}>
      <p><Link to="/ansokningar">&larr; Mina ansökningar</Link></p>
      <h1>{opp.title}</h1>
      <p className="meta-line">
        <span className={`badge ${stateInfo.tone}`}>{stateInfo.label}</span>
        {app.deadlineAt && <> · Deadline {formatDate(app.deadlineAt)}</>}
      </p>

      {message && <div className={`alert ${message.tone}`}>{message.text}</div>}

      {/* Checklist / validation */}
      <div className="card">
        <h2>Status</h2>
        {validation.ready ? (
          <div className="alert success">Alla obligatoriska fält och underlag är på plats.</div>
        ) : (
          <>
            {validation.fieldIssues.map((i) => (
              <div className="explain-item" key={i.fieldKey}><span className="explain-icon">✗</span><span>{i.message}</span></div>
            ))}
            {validation.budgetFindings.map((f, idx) => (
              <div className="explain-item" key={idx}><span className="explain-icon">✗</span><span>{f.message}</span></div>
            ))}
            {validation.missingAttachments.map((a) => (
              <div className="explain-item" key={a.kind}>
                <span className="explain-icon">✗</span>
                <span>Bifoga: {a.description} — <Link to="/dokument">ladda upp under Dokument</Link> och bifoga nedan.</span>
              </div>
            ))}
          </>
        )}

        <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.9rem', flexWrap: 'wrap' }}>
          {app.state === 'SELECTED' && <button disabled={busy} onClick={() => transition('PREPARING')}>Börja fylla i</button>}
          {app.state === 'PREPARING' && <button disabled={busy} onClick={() => transition('READY_FOR_REVIEW')}>Markera klar för granskning</button>}
          {app.state === 'READY_FOR_REVIEW' && (
            <>
              <button disabled={busy} onClick={() => transition('READY_TO_SUBMIT')}>Godkänn — klar att skicka in</button>
              <button className="secondary" disabled={busy} onClick={() => transition('PREPARING')}>Fortsätt redigera</button>
            </>
          )}
          {app.state === 'READY_TO_SUBMIT' && !submitPrep && (
            <button disabled={busy} onClick={prepareSubmit}>Förbered inlämning</button>
          )}
        </div>
      </div>

      {/* Assisted submission */}
      {submitPrep && app.state === 'READY_TO_SUBMIT' && (
        <div className="card" style={{ borderColor: 'var(--primary)' }}>
          <h2>Slutför inlämningen hos myndigheten</h2>
          <p>
            Din ansökan är komplett förberedd här. Den slutliga inlämningen gör du i den officiella tjänsten — ha dina svar
            och bilagor från Bidrag.se till hands.
          </p>
          <p>{opp.applicationMethod}</p>
          {submitPrep.officialUrl && (
            <p>
              <a className="btn" href={submitPrep.officialUrl} target="_blank" rel="noreferrer">
                Öppna den officiella ansökningstjänsten ↗
              </a>
            </p>
          )}
          <label>När du är klar: klistra in referens/diarienummer från kvittot</label>
          <input value={receiptRef} onChange={(e) => setReceiptRef(e.target.value)} placeholder="t.ex. KUR-2026-12345" />
          <button style={{ marginTop: '0.6rem' }} disabled={busy || !receiptRef.trim()} onClick={confirmExternal}>
            Registrera kvitto — jag har lämnat in
          </button>
          <p className="guidance">Ansökan markeras som inlämnad först när kvittot är registrerat.</p>
        </div>
      )}

      {/* Form */}
      {schema ? (
        <div className="card">
          <h2>{schema.title}</h2>
          {schema.sections.map((section) => {
            const fields = schema.fields.filter((f) => f.section === section.key && isVisible(f, answers));
            if (fields.length === 0) return null;
            return (
              <section key={section.key}>
                <h3>{section.title}</h3>
                {fields.map((field) => (
                  <div key={field.key}>
                    <label htmlFor={field.key}>
                      {field.label} {field.required && <span style={{ color: 'var(--danger)' }}>*</span>}{' '}
                      {app.answerProvenance[field.key] === 'canonical_prefill' && (
                        <span className="badge" title="Hämtat från dina tidigare svar — kontrollera och ändra vid behov.">förifyllt</span>
                      )}
                    </label>
                    {field.guidance && <p className="guidance">{field.guidance}</p>}
                    <FieldInput
                      field={field}
                      value={answers[field.key]}
                      disabled={!editable}
                      onChange={(v) => {
                        setAnswers({ ...answers, [field.key]: v });
                        setTouched((t) => ({ ...t, [field.key]: true }));
                        setDirty(true);
                      }}
                    />
                    {issueFor(field.key) && <p className="meta-line" style={{ color: 'var(--danger)' }}>{issueFor(field.key)}</p>}
                  </div>
                ))}
              </section>
            );
          })}
          {editable && (
            <button style={{ marginTop: '1rem' }} disabled={busy || !dirty} onClick={save}>
              {dirty ? 'Spara svar' : 'Sparat'}
            </button>
          )}
        </div>
      ) : (
        <div className="card">
          <h2>Ansökningsformulär</h2>
          <p className="meta-line">
            Det här stödet har inte ett digitaliserat formulär ännu — använd checklistan och budgeten här, och fyll i
            myndighetens formulär via länken i källan.
          </p>
        </div>
      )}

      {/* Budget */}
      <div className="card">
        <h2>Budget</h2>
        {data.budgetLines.length > 0 && (
          <table className="data">
            <thead><tr><th>Kategori</th><th>Beskrivning</th><th>Antal</th><th>À-pris</th><th>Summa</th></tr></thead>
            <tbody>
              {data.budgetLines.map((l) => (
                <tr key={l.id}>
                  <td>{CATEGORY_LABELS[l.category] ?? l.category}</td>
                  <td>{l.description}</td>
                  <td>{l.quantity}</td>
                  <td>{formatSek(l.unitCostMinor)}</td>
                  <td>{formatSek(l.quantity * l.unitCostMinor)}</td>
                </tr>
              ))}
              <tr><td colSpan={4} style={{ fontWeight: 700 }}>Totalt</td><td style={{ fontWeight: 700 }}>{formatSek(budgetTotal)}</td></tr>
            </tbody>
          </table>
        )}
        {editable && (
          <form
            style={{ display: 'grid', gridTemplateColumns: '1.2fr 2fr 0.7fr 1fr auto', gap: '0.5rem', alignItems: 'end', marginTop: '0.9rem' }}
            onSubmit={(e) => {
              e.preventDefault();
              void addBudgetLine(e.currentTarget);
            }}
          >
            <div>
              <label>Kategori</label>
              <select name="category">{BUDGET_CATEGORIES.map((c) => <option key={c} value={c}>{CATEGORY_LABELS[c]}</option>)}</select>
            </div>
            <div><label>Beskrivning</label><input name="description" required maxLength={200} /></div>
            <div><label>Antal</label><input name="quantity" type="number" min={1} defaultValue={1} required /></div>
            <div><label>À-pris (kr)</label><input name="unitCost" type="number" min={0} step="0.01" required /></div>
            <button type="submit">Lägg till</button>
          </form>
        )}
        <FinancingEditor app={app} editable={editable} budgetTotal={budgetTotal} onSaved={load} />
      </div>

      {/* Post-award (§49): beslut och redovisningskrav */}
      {(data.decisions.length > 0 || data.reportingRequirements.length > 0 || app.state === 'AWARDED') && (
        <div className="card">
          <h2>Beslut och redovisning</h2>
          {data.decisions.map((d) => (
            <p key={d.id}>
              <span className={`badge ${d.outcome === 'rejected' ? 'danger' : 'success'}`}>
                {d.outcome === 'awarded' ? 'Beviljat' : d.outcome === 'partially_awarded' ? 'Delvis beviljat' : 'Avslag'}
              </span>{' '}
              {d.amountMinor != null && <strong>{formatSek(d.amountMinor)}</strong>}
              {d.reference && <> · {d.reference}</>} · {formatDate(d.decidedAt)}
              {d.note && <span className="meta-line"> — {d.note}</span>}
            </p>
          ))}
          {data.reportingRequirements.length > 0 && (
            <>
              <h3>Redovisningskrav</h3>
              {data.reportingRequirements.map((r) => (
                <div className="explain-item" key={r.id}>
                  <span className="explain-icon">{r.status === 'accepted' ? '✓' : '•'}</span>
                  <span>
                    {r.title} {r.dueAt && <span className="meta-line">— senast {formatDate(r.dueAt)}</span>}{' '}
                    <span className={`badge ${r.status === 'accepted' ? 'success' : r.status === 'submitted' ? 'info' : 'warning'}`}>
                      {r.status === 'accepted' ? 'godkänd' : r.status === 'submitted' ? 'inskickad' : 'väntar'}
                    </span>
                  </span>
                </div>
              ))}
            </>
          )}
          {app.state === 'AWARDED' && (
            <form
              style={{ display: 'flex', gap: '0.5rem', alignItems: 'end', marginTop: '0.8rem', flexWrap: 'wrap' }}
              onSubmit={(e) => {
                e.preventDefault();
                const fd = new FormData(e.currentTarget);
                void post(`/v1/applications/${app.id}/reporting-requirements`, {
                  title: String(fd.get('title')),
                  dueAt: fd.get('dueAt') ? new Date(String(fd.get('dueAt'))).toISOString() : undefined,
                }).then(load);
                e.currentTarget.reset();
              }}
            >
              <div style={{ flex: 2, minWidth: 200 }}>
                <label>Lägg till redovisningskrav</label>
                <input name="title" required maxLength={300} placeholder="t.ex. Slutrapport" />
              </div>
              <div><label>Senast</label><input name="dueAt" type="date" /></div>
              <button type="submit" className="secondary">Lägg till</button>
            </form>
          )}
        </div>
      )}

      {/* Documents */}
      <AttachmentsCard caseId={app.id} documents={data.documents} editable={editable} onChanged={load} />

      <div className="source-line">
        <strong>Källa:</strong> <a href={opp.sourceUrl} target="_blank" rel="noreferrer">{opp.sourceUrl}</a> — villkoren i din
        ansökan utgår från reglerna som gällde när ansökan skapades; väsentliga ändringar meddelas.
      </div>
    </div>
  );
}

function FieldInput({
  field,
  value,
  disabled,
  onChange,
}: {
  field: FieldDef;
  value: unknown;
  disabled: boolean;
  onChange: (v: unknown) => void;
}) {
  switch (field.type) {
    case 'long_text':
    case 'rich_text':
      return (
        <textarea
          id={field.key}
          disabled={disabled}
          maxLength={field.maxLength}
          value={(value as string) ?? ''}
          onChange={(e) => onChange(e.target.value)}
        />
      );
    case 'number':
    case 'currency':
    case 'percentage':
      return (
        <input
          id={field.key}
          type="number"
          disabled={disabled}
          min={field.min}
          max={field.max}
          value={value === undefined || value === null ? '' : String(value)}
          onChange={(e) => onChange(e.target.value === '' ? null : Number(e.target.value))}
        />
      );
    case 'date':
      return (
        <input id={field.key} type="date" disabled={disabled} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)} />
      );
    case 'date_range': {
      const range = Array.isArray(value) ? (value as string[]) : ['', ''];
      return (
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <input type="date" disabled={disabled} value={range[0] ?? ''} onChange={(e) => onChange([e.target.value, range[1] ?? ''])} />
          <input type="date" disabled={disabled} value={range[1] ?? ''} onChange={(e) => onChange([range[0] ?? '', e.target.value])} />
        </div>
      );
    }
    case 'select':
      return (
        <select id={field.key} disabled={disabled} value={(value as string) ?? ''} onChange={(e) => onChange(e.target.value)}>
          <option value="">Välj…</option>
          {field.options?.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
        </select>
      );
    case 'boolean':
    case 'consent':
    case 'declaration':
      return (
        <div className="checkbox-row">
          <input
            id={field.key}
            type="checkbox"
            disabled={disabled}
            checked={value === true}
            onChange={(e) => onChange(e.target.checked)}
          />
          <label htmlFor={field.key}>{field.type === 'boolean' ? 'Ja' : 'Jag bekräftar'}</label>
        </div>
      );
    default:
      return (
        <input
          id={field.key}
          disabled={disabled}
          maxLength={field.maxLength}
          value={(value as string) ?? ''}
          onChange={(e) => onChange(e.target.value)}
        />
      );
  }
}

function FinancingEditor({
  app,
  editable,
  budgetTotal,
  onSaved,
}: {
  app: CaseData['application'];
  editable: boolean;
  budgetTotal: number;
  onSaved: () => Promise<void>;
}) {
  const f = app.financing ?? { requestedMinor: 0, ownContributionMinor: 0, otherFundingMinor: 0, inKindMinor: 0 };
  const [requested, setRequested] = useState(String(f.requestedMinor / 100));
  const [own, setOwn] = useState(String(f.ownContributionMinor / 100));
  const [other, setOther] = useState(String(f.otherFundingMinor / 100));
  const [busy, setBusy] = useState(false);

  const save = async () => {
    setBusy(true);
    try {
      await patch(`/v1/applications/${app.id}`, {
        financing: {
          requestedMinor: Math.round(Number(requested || 0) * 100),
          ownContributionMinor: Math.round(Number(own || 0) * 100),
          otherFundingMinor: Math.round(Number(other || 0) * 100),
          inKindMinor: 0,
        },
      });
      await onSaved();
    } finally {
      setBusy(false);
    }
  };

  const finTotal = Math.round((Number(requested || 0) + Number(own || 0) + Number(other || 0)) * 100);

  return (
    <div style={{ marginTop: '1.2rem' }}>
      <h3>Finansiering</h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '0.6rem' }}>
        <div><label>Sökt bidrag (kr)</label><input type="number" disabled={!editable} value={requested} onChange={(e) => setRequested(e.target.value)} /></div>
        <div><label>Egen insats (kr)</label><input type="number" disabled={!editable} value={own} onChange={(e) => setOwn(e.target.value)} /></div>
        <div><label>Annan finansiering (kr)</label><input type="number" disabled={!editable} value={other} onChange={(e) => setOther(e.target.value)} /></div>
      </div>
      <p className="meta-line" style={{ marginTop: '0.4rem' }}>
        Finansiering totalt {formatSek(finTotal)} · Budget totalt {formatSek(budgetTotal)}
        {budgetTotal > 0 && finTotal !== budgetTotal && (
          <span style={{ color: 'var(--warning)' }}> — behöver gå jämnt ut</span>
        )}
      </p>
      {editable && <button className="secondary" disabled={busy} onClick={save}>Spara finansiering</button>}
    </div>
  );
}

function AttachmentsCard({
  caseId,
  documents,
  editable,
  onChanged,
}: {
  caseId: string;
  documents: CaseDoc[];
  editable: boolean;
  onChanged: () => Promise<void>;
}) {
  const [available, setAvailable] = useState<{ id: string; filename: string; kind: string }[]>([]);
  const [selected, setSelected] = useState('');
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    get<{ documents: { id: string; filename: string; kind: string }[] }>('/v1/documents').then(({ documents }) =>
      setAvailable(documents),
    );
  }, []);

  const attach = async () => {
    if (!selected) return;
    setBusy(true);
    try {
      await post(`/v1/applications/${caseId}/documents`, { documentId: selected, role: 'evidence' });
      setSelected('');
      await onChanged();
    } finally {
      setBusy(false);
    }
  };

  const attachedIds = new Set(documents.map((d) => d.documentId));
  const attachable = available.filter((d) => !attachedIds.has(d.id));

  return (
    <div className="card">
      <h2>Bilagor och underlag</h2>
      {documents.length === 0 && <p className="meta-line">Inga bilagor ännu.</p>}
      {documents.map((d) => (
        <div className="explain-item" key={d.linkId}>
          <span className="explain-icon">📎</span>
          <span>{d.filename} <span className="badge">{d.kind}</span></span>
        </div>
      ))}
      {editable && (
        <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.8rem', alignItems: 'center' }}>
          <select value={selected} onChange={(e) => setSelected(e.target.value)} style={{ maxWidth: 340 }}>
            <option value="">Välj dokument från valvet…</option>
            {attachable.map((d) => <option key={d.id} value={d.id}>{d.filename} ({d.kind})</option>)}
          </select>
          <button className="secondary" disabled={busy || !selected} onClick={attach}>Bifoga</button>
          <Link to="/dokument">Ladda upp nytt ↗</Link>
        </div>
      )}
    </div>
  );
}
