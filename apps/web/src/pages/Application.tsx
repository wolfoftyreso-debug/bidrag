/**
 * Application workspace (§14): schema-driven form, budget builder, evidence,
 * validation status, guarded state transitions and the assisted submission
 * flow — the case is only SUBMITTED once a receipt is recorded.
 */
import { useCallback, useEffect, useMemo, useState } from 'react';
import { Feedback } from '../components/Feedback';
import { Link, useLocation, useParams } from 'react-router-dom';
import { ApiError, formatDate, formatSek, get, patch, post } from '../api';
import { useLabels, useT } from '../i18n';

type T = ReturnType<typeof useT>;

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
/** Granskningsläget (§30–31): samlad bedömning med prioriterade luckor. */
interface CaseReview {
  overallStatus: 'READY_FOR_SUBMISSION' | 'NOT_READY';
  eligibility: { status: 'PASS' | 'FAIL' | 'UNKNOWN'; missingFacts: { question: string }[] };
  deadline: { deadlineAt: string | null; daysLeft: number | null; passed: boolean };
  criteria: { criterionId: string; description: string; kind: string; outcome: 'pass' | 'fail' | 'unknown'; nonCompensatory: boolean; evidenceLevel: 'E0' | 'E1' | 'E2' | 'E3' }[];
  internalEstimate: { label: string; fitScore: number | null; explanation: string };
  doubleFunding: { status: 'CLEAR' | 'POTENTIAL_OVERLAP' | 'HIGH_RISK'; notes: string[] };
  stateAid: { status: 'NOT_APPLICABLE' | 'STATE_AID_UNKNOWN'; note: string };
  likelyComplementRequests: string[];
  gaps: { id: string; severity: 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW'; area: string; message: string; action: string }[];
}
interface BudgetLine {
  id: string;
  category: string;
  description: string;
  quantity: number;
  activity?: string | null;
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
  generationAvailable?: boolean;
}

const BUDGET_CATEGORIES = ['travel', 'accommodation', 'personnel', 'equipment', 'subcontractor', 'overhead', 'other'];

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
  const t = useT();
  const labels = useLabels();
  const { id } = useParams();
  // Köpbekräftelsen (UX-genomgången 2026-09-02): stödsidan skickar med kvittot när
  // ansökan skapades direkt efter en betalning — visas en gång, försvinner vid omladdning.
  const locState = useLocation().state as { justPaid?: boolean; receiptNumber?: string } | null;
  const justPaid = locState?.justPaid ? locState : null;
  const [data, setData] = useState<CaseData | null>(null);
  const [answers, setAnswers] = useState<Record<string, unknown>>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});
  const [dirty, setDirty] = useState(false);
  const [message, setMessage] = useState<{ tone: string; text: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [submitPrep, setSubmitPrep] = useState<{ submissionId: string; officialUrl: string | null } | null>(null);
  const [receiptRef, setReceiptRef] = useState('');
  const [review, setReview] = useState<CaseReview | null>(null);

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
    load().catch(() => setMessage({ tone: 'error', text: t('aw.loadError') }));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [load]);

  const editable = data ? EDITABLE_STATES.includes(data.application.state) : false;

  const budgetTotal = useMemo(
    () => (data?.budgetLines ?? []).reduce((s, l) => s + l.quantity * l.unitCostMinor, 0),
    [data],
  );

  if (!data) return <p>{t('app.loading')}</p>;
  const { application: app, schema, validation } = data;
  const opp = app.opportunitySnapshot.opportunity;
  const stateInfo = labels.state(app.state);

  const save = async () => {
    setBusy(true);
    setMessage(null);
    try {
      await patch(`/v1/applications/${app.id}`, { answers });
      await load();
      setMessage({ tone: 'success', text: t('aw.saved') });
    } catch (err) {
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : t('aw.saveError') });
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
        setMessage({ tone: 'warning', text: t('aw.notComplete') });
        await load();
      } else {
        setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : t('aw.stateError') });
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
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : t('aw.prepareError') });
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
      setMessage({ tone: 'success', text: t('aw.receiptRegistered') });
    } catch (err) {
      setMessage({ tone: 'error', text: err instanceof ApiError ? err.message : t('aw.receiptError') });
    } finally {
      setBusy(false);
    }
  };

  const addBudgetLine = async (form: HTMLFormElement) => {
    const fd = new FormData(form);
    const kr = Number(fd.get('unitCost'));
    const activity = String(fd.get('activity') ?? '').trim();
    await post(`/v1/applications/${app.id}/budget-lines`, {
      category: String(fd.get('category')),
      description: String(fd.get('description')),
      ...(activity ? { activity } : {}),
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
      <p><Link to="/ansokningar">{t('aw.back')}</Link></p>
      <h1>{opp.title}</h1>
      <p className="meta-line">
        <span className={`badge ${stateInfo.tone}`}>{stateInfo.label}</span>
        {app.deadlineAt && <> · {t('aw.deadline', { datum: formatDate(app.deadlineAt) })}</>}
      </p>
      {justPaid && (
        <div className="alert success" role="status">
          <strong>{t('aw.paidBanner')}</strong>
          {justPaid.receiptNumber && (
            <>
              {' '}{t('aw.paidReceipt', { nr: justPaid.receiptNumber })} <Link to="/konto">{t('aw.paidReceiptLink')}</Link>
            </>
          )}
        </div>
      )}

      {message && <div className={`alert ${message.tone}`}>{message.text}</div>}

      {/* Granskningsläget (Application Intelligence §30–31) */}
      <div className="card">
        <h2>{t('aw.reviewTitle')}</h2>
        <p className="guidance">{t('aw.reviewGuidance')}</p>
        <button
          className="secondary"
          disabled={busy}
          onClick={() => void get<{ review: CaseReview }>(`/v1/applications/${app.id}/review`).then((r) => setReview(r.review))}
        >
          {review ? t('aw.reviewAgain') : t('aw.review')}
        </button>
        {review && (
          <div style={{ marginTop: '0.8rem' }}>
            {review.overallStatus === 'READY_FOR_SUBMISSION' ? (
              <div className="alert success">
                <strong>{t('aw.readyStrong')}</strong> {t('aw.readyBody')}
              </div>
            ) : (
              <div className="alert warning">
                <strong>{t('aw.notReadyStrong')}</strong> {t('aw.notReadyBody')}
              </div>
            )}
            <div className="meta-line" style={{ margin: '0.4rem 0' }}>
              {t('aw.eligibility')}{' '}
              {review.eligibility.status === 'PASS' ? <span className="badge success">{t('aw.eligPass')}</span>
                : review.eligibility.status === 'FAIL' ? <span className="badge danger">{t('aw.eligFail')}</span>
                : <span className="badge warning">{t('aw.eligUnknown')}</span>}
              {review.deadline.daysLeft !== null && !review.deadline.passed && <> · {t('aw.daysToDeadline', { n: review.deadline.daysLeft })}</>}
            </div>
            {review.gaps.map((g, i) => (
              <div className="explain-item" key={`${g.id}-${i}`}>
                <span className={`badge ${g.severity === 'CRITICAL' ? 'danger' : g.severity === 'HIGH' ? 'warning' : ''}`} style={{ flexShrink: 0 }}>
                  {g.severity === 'CRITICAL' ? t('aw.sevCritical') : g.severity === 'HIGH' ? t('aw.sevHigh') : g.severity === 'MEDIUM' ? t('aw.sevMedium') : t('aw.sevLow')}
                </span>
                <span>
                  {g.message}
                  <div className="meta-line">{g.action}</div>
                </span>
              </div>
            ))}
            {review.gaps.length === 0 && <div className="explain-item"><span className="explain-icon pass">✓</span><span>{t('aw.noGaps')}</span></div>}

            {review.likelyComplementRequests.length > 0 && (
              <details style={{ marginTop: '0.8rem' }}>
                <summary style={{ cursor: 'pointer', fontWeight: 600 }}>{t('aw.complementTitle', { n: review.likelyComplementRequests.length })}</summary>
                {review.likelyComplementRequests.map((r, i) => (
                  <div className="explain-item" key={i}><span className="explain-icon unknown">?</span><span>{r}</span></div>
                ))}
              </details>
            )}

            {review.criteria.length > 0 && (
              <details style={{ marginTop: '0.6rem' }}>
                <summary style={{ cursor: 'pointer', fontWeight: 600 }}>{t('aw.criteriaTitle', { n: review.criteria.length })}</summary>
                <p className="guidance" style={{ marginTop: '0.4rem' }}>{t('aw.criteriaGuidance')}</p>
                {review.criteria.map((c) => (
                  <div className="explain-item" key={c.criterionId}>
                    <span className={`explain-icon ${c.outcome === 'pass' ? 'pass' : c.outcome === 'fail' ? 'fail' : 'unknown'}`}>
                      {c.outcome === 'pass' ? '✓' : c.outcome === 'fail' ? '✗' : '?'}
                    </span>
                    <span>
                      {c.description}{' '}
                      <span className="badge">{c.evidenceLevel}</span>
                      {c.nonCompensatory && <span className="badge warning"> {t('aw.nonComp')}</span>}
                    </span>
                  </div>
                ))}
                {review.internalEstimate.fitScore !== null && (
                  <p className="meta-line" style={{ marginTop: '0.4rem' }}>
                    {t('aw.internalEstimate', { poang: review.internalEstimate.fitScore })}{' '}
                    <span className="badge">{review.internalEstimate.label}</span> — {review.internalEstimate.explanation}
                  </p>
                )}
              </details>
            )}

            {review.doubleFunding.status !== 'CLEAR' && (
              <div className={`alert ${review.doubleFunding.status === 'HIGH_RISK' ? 'error' : 'warning'}`} style={{ marginTop: '0.6rem' }}>
                <strong>{review.doubleFunding.status === 'HIGH_RISK' ? t('aw.doubleHigh') : t('aw.doubleOverlap')}</strong>{' '}
                {review.doubleFunding.notes.join(' ')}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Checklist / validation */}
      <div className="card">
        <h2>{t('dash.thStatus')}</h2>
        {validation.ready ? (
          <div className="alert success">{t('aw.allInPlace')}</div>
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
                <span>{t('aw.attachPrefix')} {a.description} — <Link to="/dokument">{t('aw.attachLink')}</Link> {t('aw.attachSuffix')}</span>
              </div>
            ))}
          </>
        )}

        <div style={{ display: 'flex', gap: '0.6rem', marginTop: '0.9rem', flexWrap: 'wrap' }}>
          {app.state === 'SELECTED' && <button disabled={busy} onClick={() => transition('PREPARING')}>{t('aw.startFilling')}</button>}
          {app.state === 'PREPARING' && <button disabled={busy} onClick={() => transition('READY_FOR_REVIEW')}>{t('aw.markReview')}</button>}
          {app.state === 'READY_FOR_REVIEW' && (
            <>
              <button disabled={busy} onClick={() => transition('READY_TO_SUBMIT')}>{t('aw.approve')}</button>
              <button className="secondary" disabled={busy} onClick={() => transition('PREPARING')}>{t('aw.continueEditing')}</button>
            </>
          )}
          {app.state === 'READY_TO_SUBMIT' && !submitPrep && (
            <button disabled={busy} onClick={prepareSubmit}>{t('aw.prepareSubmission')}</button>
          )}
        </div>
      </div>

      {/* Assisted submission */}
      {submitPrep && app.state === 'READY_TO_SUBMIT' && (
        <div className="card" style={{ borderColor: 'var(--primary)' }}>
          <h2>{t('aw.finishTitle')}</h2>
          <p>{t('aw.finishBody')}</p>
          <p>{opp.applicationMethod}</p>
          {submitPrep.officialUrl && (
            <p>
              <a className="btn" href={submitPrep.officialUrl} target="_blank" rel="noreferrer">
                {t('aw.openOfficial')}
              </a>
            </p>
          )}
          <label>{t('aw.pasteRef')}</label>
          <input value={receiptRef} onChange={(e) => setReceiptRef(e.target.value)} placeholder={t('aw.refPlaceholder')} />
          <button style={{ marginTop: '0.6rem' }} disabled={busy || !receiptRef.trim()} onClick={confirmExternal}>
            {t('aw.registerReceipt')}
          </button>
          <p className="guidance">{t('aw.submittedOnlyWithReceipt')}</p>
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
                        <span className="badge" title={t('aw.prefillTitle')}>{t('aw.prefillBadge')}</span>
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
                    {data.generationAvailable && editable && (field.type === 'long_text' || field.type === 'text') &&
                      typeof answers[field.key] === 'string' && (answers[field.key] as string).trim().length >= 20 && (
                      <SuggestImprovement
                        caseId={app.id}
                        fieldKey={field.key}
                        onAccept={(text) => {
                          setAnswers({ ...answers, [field.key]: text });
                          setTouched((t) => ({ ...t, [field.key]: true }));
                          setDirty(true);
                        }}
                      />
                    )}
                  </div>
                ))}
              </section>
            );
          })}
          {editable && (
            <button style={{ marginTop: '1rem' }} disabled={busy || !dirty} onClick={save}>
              {dirty ? t('aw.saveAnswers') : t('aw.savedBtn')}
            </button>
          )}
        </div>
      ) : (
        <div className="card">
          <h2>{t('aw.formTitle')}</h2>
          <p className="meta-line">{t('aw.noSchema')}</p>
        </div>
      )}

      {/* Budget */}
      <div className="card">
        <h2>{t('aw.budget')}</h2>
        {data.budgetLines.length > 0 && (
          <table className="data">
            <thead><tr><th>{t('aw.thCategory')}</th><th>{t('aw.thDescription')}</th><th>{t('aw.thQty')}</th><th>{t('aw.thUnit')}</th><th>{t('aw.thSum')}</th></tr></thead>
            <tbody>
              {data.budgetLines.map((l) => (
                <tr key={l.id}>
                  <td>{labels.budget(l.category)}</td>
                  <td>
                    {l.description}
                    {l.activity && <div className="meta-line">{t('aw.activityLine', { aktivitet: l.activity })}</div>}
                  </td>
                  <td>{l.quantity}</td>
                  <td>{formatSek(l.unitCostMinor)}</td>
                  <td>{formatSek(l.quantity * l.unitCostMinor)}</td>
                </tr>
              ))}
              <tr><td colSpan={4} style={{ fontWeight: 700 }}>{t('aw.total')}</td><td style={{ fontWeight: 700 }}>{formatSek(budgetTotal)}</td></tr>
            </tbody>
          </table>
        )}
        {editable && (
          <form
            style={{ display: 'grid', gridTemplateColumns: '1.2fr 1.6fr 1.6fr 0.7fr 1fr auto', gap: '0.5rem', alignItems: 'end', marginTop: '0.9rem' }}
            onSubmit={(e) => {
              e.preventDefault();
              void addBudgetLine(e.currentTarget);
            }}
          >
            <div>
              <label htmlFor="f-category">{t('aw.thCategory')}</label>
              <select id="f-category" name="category">{BUDGET_CATEGORIES.map((c) => <option key={c} value={c}>{labels.budget(c)}</option>)}</select>
            </div>
            <div><label htmlFor="f-description">{t('aw.thDescription')}</label><input id="f-description" name="description" required maxLength={200} /></div>
            <div><label htmlFor="f-activity">{t('aw.activityLabel')}</label><input id="f-activity" name="activity" maxLength={200} placeholder={t('aw.activityPlaceholder')} /></div>
            <div><label htmlFor="f-quantity">{t('aw.thQty')}</label><input id="f-quantity" name="quantity" type="number" min={1} defaultValue={1} required /></div>
            <div><label htmlFor="f-unitCost">{t('aw.unitKr')}</label><input id="f-unitCost" name="unitCost" type="number" min={0} step="0.01" required /></div>
            <button type="submit">{t('aw.add')}</button>
          </form>
        )}
        <FinancingEditor app={app} editable={editable} budgetTotal={budgetTotal} onSaved={load} t={t} />
      </div>

      {/* Post-award (§49): beslut och redovisningskrav */}
      {(data.decisions.length > 0 || data.reportingRequirements.length > 0 || app.state === 'AWARDED') && (
        <div className="card">
          <h2>{t('aw.decisionsTitle')}</h2>
          {data.decisions.map((d) => (
            <p key={d.id}>
              <span className={`badge ${d.outcome === 'rejected' ? 'danger' : 'success'}`}>
                {d.outcome === 'awarded' ? t('label.msg.award') : d.outcome === 'partially_awarded' ? t('aw.partiallyAwarded') : t('label.msg.rejection')}
              </span>{' '}
              {d.amountMinor != null && <strong>{formatSek(d.amountMinor)}</strong>}
              {d.reference && <> · {d.reference}</>} · {formatDate(d.decidedAt)}
              {d.note && <span className="meta-line"> — {d.note}</span>}
            </p>
          ))}
          {data.reportingRequirements.length > 0 && (
            <>
              <h3>{t('aw.reportingTitle')}</h3>
              {data.reportingRequirements.map((r) => (
                <div className="explain-item" key={r.id}>
                  <span className="explain-icon">{r.status === 'accepted' ? '✓' : '•'}</span>
                  <span>
                    {r.title} {r.dueAt && <span className="meta-line">{t('aw.dueBy', { datum: formatDate(r.dueAt) })}</span>}{' '}
                    <span className={`badge ${r.status === 'accepted' ? 'success' : r.status === 'submitted' ? 'info' : 'warning'}`}>
                      {r.status === 'accepted' ? t('aw.repAccepted') : r.status === 'submitted' ? t('aw.repSubmitted') : t('aw.repPending')}
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
                <label htmlFor="f-title">{t('aw.addReporting')}</label>
                <input id="f-title" name="title" required maxLength={300} placeholder={t('aw.repPlaceholder')} />
              </div>
              <div><label htmlFor="f-dueAt">{t('aw.dueLabel')}</label><input id="f-dueAt" name="dueAt" type="date" /></div>
              <button type="submit" className="secondary">{t('aw.add')}</button>
            </form>
          )}
        </div>
      )}

      {/* Documents */}
      <AttachmentsCard caseId={app.id} documents={data.documents} editable={editable} onChanged={load} t={t} />

      <Feedback page="arbetsyta" />
      <div className="source-line">
        <strong>{t('o.source')}</strong> <a href={opp.sourceUrl} target="_blank" rel="noreferrer">{opp.sourceUrl}</a> {t('aw.sourceNote')}
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
  const t = useT();
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
          <option value="">{t('ds.choose')}</option>
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
          <label htmlFor={field.key}>{field.type === 'boolean' ? t('ob.yes') : t('aw.confirm')}</label>
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
  t,
}: {
  app: CaseData['application'];
  editable: boolean;
  budgetTotal: number;
  onSaved: () => Promise<void>;
  t: T;
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
      <h3>{t('aw.financing')}</h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '0.6rem' }}>
        <div><label htmlFor="f-requested">{t('aw.requested')}</label><input id="f-requested" type="number" disabled={!editable} value={requested} onChange={(e) => setRequested(e.target.value)} /></div>
        <div><label htmlFor="f-own">{t('m.ownContribution')}</label><input id="f-own" type="number" disabled={!editable} value={own} onChange={(e) => setOwn(e.target.value)} /></div>
        <div><label htmlFor="f-other">{t('aw.otherFunding')}</label><input id="f-other" type="number" disabled={!editable} value={other} onChange={(e) => setOther(e.target.value)} /></div>
      </div>
      <p className="meta-line" style={{ marginTop: '0.4rem' }}>
        {t('aw.finTotals', { fin: formatSek(finTotal), budget: formatSek(budgetTotal) })}
        {budgetTotal > 0 && finTotal !== budgetTotal && (
          <span style={{ color: 'var(--warning)' }}> {t('aw.mustBalance')}</span>
        )}
      </p>
      {editable && <button className="secondary" disabled={busy} onClick={save}>{t('aw.saveFinancing')}</button>}
    </div>
  );
}

function AttachmentsCard({
  caseId,
  documents,
  editable,
  onChanged,
  t,
}: {
  caseId: string;
  documents: CaseDoc[];
  editable: boolean;
  onChanged: () => Promise<void>;
  t: T;
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
      <h2>{t('aw.attachmentsTitle')}</h2>
      {documents.length === 0 && <p className="meta-line">{t('aw.noAttachments')}</p>}
      {documents.map((d) => (
        <div className="explain-item" key={d.linkId}>
          <span className="explain-icon">📎</span>
          <span>{d.filename} <span className="badge">{d.kind}</span></span>
        </div>
      ))}
      {editable && (
        <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.8rem', alignItems: 'center' }}>
          <select aria-label={t('aw.chooseFromVault')} value={selected} onChange={(e) => setSelected(e.target.value)} style={{ maxWidth: 340 }}>
            <option value="">{t('aw.chooseFromVault')}</option>
            {attachable.map((d) => <option key={d.id} value={d.id}>{d.filename} ({d.kind})</option>)}
          </select>
          <button className="secondary" disabled={busy || !selected} onClick={attach}>{t('aw.attachBtn')}</button>
          <Link to="/dokument">{t('aw.uploadNew')}</Link>
        </div>
      )}
    </div>
  );
}


/**
 * Generation mode (förslag-och-godkänn): förslaget visas bredvid originalet
 * och sparas ALDRIG av systemet — "Använd förslaget" lägger bara in texten i
 * formuläret, och sökanden sparar själv. Vakterna har redan granskat det.
 */
function SuggestImprovement({ caseId, fieldKey, onAccept }: { caseId: string; fieldKey: string; onAccept: (text: string) => void }) {
  const t = useT();
  const [state, setState] = useState<{ busy: boolean; suggestion?: { before: string; suggestion: string; reason: string }; error?: string }>({ busy: false });
  const fetchSuggestion = async () => {
    setState({ busy: true });
    try {
      const res = await post<{ before: string; suggestion: string; reason: string }>(`/v1/applications/${caseId}/suggest-field`, { fieldKey });
      setState({ busy: false, suggestion: res });
    } catch (err) {
      setState({ busy: false, error: err instanceof ApiError ? err.message : t('aw.suggestError') });
    }
  };
  if (state.suggestion) {
    return (
      <div className="alert" style={{ marginTop: '0.4rem' }}>
        <strong>{t('aw.suggestionTitle')}</strong>
        <p style={{ margin: '0.3rem 0', whiteSpace: 'pre-wrap' }}>{state.suggestion.suggestion}</p>
        <p className="meta-line">{state.suggestion.reason}</p>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button type="button" className="secondary" onClick={() => { onAccept(state.suggestion!.suggestion); setState({ busy: false }); }}>
            {t('aw.useSuggestion')}
          </button>
          <button type="button" className="secondary" onClick={() => setState({ busy: false })}>{t('aw.keepMine')}</button>
        </div>
      </div>
    );
  }
  return (
    <div style={{ marginTop: '0.3rem' }}>
      <button type="button" className="secondary" style={{ fontSize: '0.82rem', padding: '0.2rem 0.6rem' }} disabled={state.busy} onClick={() => void fetchSuggestion()}>
        {state.busy ? t('aw.fetching') : t('aw.suggest')}
      </button>
      {state.error && <span className="meta-line" style={{ marginInlineStart: '0.5rem', color: 'var(--danger)' }}>{state.error}</span>}
    </div>
  );
}
