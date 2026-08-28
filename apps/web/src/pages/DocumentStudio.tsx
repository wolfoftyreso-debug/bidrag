/**
 * Dokumentstudion (§produktsteg 3): "Förbered min ansökan". Ett pris — 19 kr
 * per ansökan, alla dokument ingår — aldrig styckdebitering per knapp.
 * Frågorna ställs en sektion i taget, dokumentet genereras server-side av
 * domänmotorn och hamnar under Mina dokument (PDF + redigerbar text).
 * Användaren skickar själv in via myndighetens kanal — Bidragskoll.se
 * beslutar aldrig. Mallarnas titlar/frågor kommer från servern (svenska
 * tills I18N fas B).
 */
import { useCallback, useEffect, useState } from 'react';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { PurchaseConsent } from '../components/PurchaseConsent';
import { ApiError, formatDate, formatSek, get, post } from '../api';
import { useT } from '../i18n';

type T = ReturnType<typeof useT>;

interface DocQuestion {
  key: string;
  label: string;
  type: 'text' | 'textarea' | 'number' | 'boolean' | 'select' | 'date';
  required?: boolean;
  guidance?: string;
  options?: { value: string; label: string }[];
  showIf?: { key: string; equals: unknown };
}
interface TemplateInfo { key: string; title: string; description: string; questions: DocQuestion[] }
interface CreditsInfo {
  remaining: number; total: number; used: number;
  prices: { application: number };
  templates: TemplateInfo[];
  /** Förifyllda svar per mall — det systemet redan vet från intaget. */
  prefill?: Record<string, Record<string, unknown>>;
}
interface GeneratedDoc { id: string; title: string; opportunityTitle: string; createdAt: string }
interface LanguageFinding { kind: string; term: string; excerpt: string; suggestion: string; fieldKey: string }

export default function DocumentStudioPage() {
  const t = useT();
  const { projectId } = useParams();
  const [params] = useSearchParams();
  const opportunitySlug = params.get('stod');
  const [info, setInfo] = useState<CreditsInfo | null>(null);
  const [docs, setDocs] = useState<GeneratedDoc[]>([]);
  const [active, setActive] = useState<TemplateInfo | null>(null);
  const [error] = useState<string | null>(null);
  const [langNotes, setLangNotes] = useState<LanguageFinding[]>([]);

  const load = useCallback(() => {
    if (!projectId) return;
    get<CreditsInfo>(`/v1/projects/${projectId}/document-credits`).then(setInfo).catch(() => setInfo(null));
    get<{ documents: GeneratedDoc[] }>(`/v1/projects/${projectId}/generated-documents`).then((r) => setDocs(r.documents)).catch(() => {});
  }, [projectId]);
  useEffect(load, [load]);

  if (!projectId || !info) return <p>{t('app.loading')}</p>;

  return (
    <div style={{ maxWidth: 680 }}>
      <h1>{t('ds.title')}</h1>
      <p className="guidance">{t('ds.guidance')}</p>

      {langNotes.length > 0 && (
        <div className="alert" style={{ marginBottom: '0.8rem' }}>
          <strong>{t('ds.docCreated')}</strong> {t('ds.langNotes')}
          <ul style={{ margin: '0.4rem 0 0', paddingInlineStart: '1.1rem' }}>
            {langNotes.map((f, i) => (
              <li key={i} style={{ margin: '0.25rem 0' }}>
                <em>"{f.term}"</em> — {f.suggestion}
              </li>
            ))}
          </ul>
        </div>
      )}

      {docs.length > 0 && (
        <div className="card">
          <h2>{t('ds.myDocs')}</h2>
          {docs.map((d) => (
            <div className="match-row" key={d.id} style={{ alignItems: 'center' }}>
              <div style={{ flex: 1 }}>
                <strong>{d.title}</strong>
                <div className="meta-line">{d.opportunityTitle} · {formatDate(d.createdAt)}</div>
              </div>
              <div style={{ display: 'flex', gap: '0.4rem' }}>
                <a className="btn secondary" style={{ fontSize: '0.82rem', padding: '0.2rem 0.6rem' }} href={`/v1/generated-documents/${d.id}/download?format=pdf`}>PDF</a>
                <a className="btn secondary" style={{ fontSize: '0.82rem', padding: '0.2rem 0.6rem' }} href={`/v1/generated-documents/${d.id}/download?format=text`}>Text</a>
              </div>
            </div>
          ))}
        </div>
      )}

      {info.remaining <= 0 && <PackOffer projectId={projectId} prices={info.prices} onPurchased={load} t={t} />}

      {info.remaining > 0 && !active && (
        <div className="card">
          <h2>{t('ds.chooseTitle')}</h2>
          <p className="guidance">{t('ds.remaining', { antal: info.remaining >= 99 ? t('ds.remainingUnlimited') : String(info.remaining) })}</p>
          {info.templates.map((tpl) => (
            <div className="match-row" key={tpl.key} style={{ alignItems: 'center' }}>
              <div style={{ flex: 1 }}>
                <strong>{tpl.title}</strong>
                <div className="meta-line">{tpl.description}</div>
              </div>
              <button className="secondary" onClick={() => setActive(tpl)}>{t('ds.create')}</button>
            </div>
          ))}
        </div>
      )}

      {active && (
        <DocumentForm
          projectId={projectId}
          template={active}
          opportunitySlug={opportunitySlug}
          prefill={info.prefill?.[active.key] ?? {}}
          onDone={(findings) => { setActive(null); setLangNotes(findings); load(); }}
          onCancel={() => setActive(null)}
          t={t}
        />
      )}

      {error && <div className="alert error">{error}</div>}
      <p className="meta-line" style={{ marginTop: '1rem' }}>
        {t('ds.footer')} <Link to={`/projekt/${projectId}`}>{t('ds.backToAnalysis')}</Link>
      </p>
    </div>
  );
}

/** Paketerbjudandet — hjälp, inte styckdebitering. "Gör det själv" är alltid gratis. */
function PackOffer({ projectId, prices, onPurchased, t }: { projectId: string; prices: CreditsInfo['prices']; onPurchased: () => void; t: T }) {
  const [busy, setBusy] = useState(false);
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [payment, setPayment] = useState<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean; redirectUrl?: string } } | null>(null);
  const [confirmedNote, setConfirmedNote] = useState(false);

  const buy = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ paymentId: string; instructions: { method: string; message?: string; redirectUrl?: string } }>(
        `/v1/projects/${projectId}/document-pack`, { pack: 'application', immediateDeliveryConsent: consent },
      );
      // Stripe: lämna SPA:n för den hostade betalsidan; returvyn tar användaren tillbaka hit.
      if (res.instructions.method === 'stripe' && res.instructions.redirectUrl) {
        try { sessionStorage.setItem(`bidrag_return_${res.paymentId}`, window.location.pathname + window.location.search); } catch { /* privat läge */ }
        window.location.href = res.instructions.redirectUrl;
        return;
      }
      setPayment(res);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('o.payStartError'));
    } finally {
      setBusy(false);
    }
  };

  const confirmMock = async () => {
    if (!payment) return;
    setBusy(true);
    try {
      await post(`/v1/payments/${payment.paymentId}/mock-confirm`);
      setConfirmedNote(true);
      onPurchased();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('o.payConfirmError'));
    } finally {
      setBusy(false);
    }
  };

  // Swish: polla tills bekräftad (samma mönster som analysens betalvägg).
  useEffect(() => {
    if (!payment || payment.instructions.method !== 'swish' || confirmedNote) return;
    const iv = setInterval(async () => {
      const res = await get<{ state: string }>(`/v1/payments/${payment.paymentId}/status`).catch(() => null);
      if (res?.state === 'confirmed') { setConfirmedNote(true); onPurchased(); }
    }, 2500);
    return () => clearInterval(iv);
  }, [payment, confirmedNote, onPurchased]);

  if (payment && !confirmedNote) {
    return (
      <div className="card">
        {payment.instructions.method === 'stripe' ? (
          <div style={{ textAlign: 'center' }}>
            <p className="guidance">{payment.instructions.message}</p>
            {payment.instructions.redirectUrl
              ? <p><a className="btn" href={payment.instructions.redirectUrl}>{t('o.payContinue')}</a></p>
              : <div className="alert error">{t('o.payPageError')}</div>}
          </div>
        ) : payment.instructions.method === 'mock' ? (
          <div className="alert warning">
            <p style={{ fontWeight: 700 }}>{payment.instructions.message}</p>
            <button disabled={busy} onClick={confirmMock}>{t('o.payMockConfirm')}</button>
          </div>
        ) : (
          <div style={{ textAlign: 'center' }}>
            <h3>{t('o.paySwishTitle')}</h3>
            {payment.instructions.qrAvailable && (
              <img src={`/v1/payments/${payment.paymentId}/qr`} alt={t('o.paySwishQrAlt')} width={220} height={220} style={{ display: 'block', margin: '0.5rem auto' }} />
            )}
            {payment.instructions.deepLink && <p><a className="btn" href={payment.instructions.deepLink}>{t('o.paySwishOpen')}</a></p>}
            <p className="meta-line">{t('o.payWaiting')}</p>
          </div>
        )}
        {error && <div className="alert error">{error}</div>}
      </div>
    );
  }

  return (
    <div className="card">
      <h2>{t('ds.helpTitle')}</h2>
      <p className="guidance">{t('ds.helpGuidance', { pris: formatSek(prices.application) })}</p>
      {/* Red team RT03-T3: samtycket står FÖRE prisknappen — läsordningen
          ska vara villkor → pris → köp, inte tvärtom. */}
      <PurchaseConsent checked={consent} onChange={setConsent} idSuffix="-dokument" />
      <div className="match-row" style={{ alignItems: 'center', border: '1px solid var(--primary)', borderRadius: 8, padding: '0.6rem 0.8rem' }}>
        <div style={{ flex: 1 }}>
          <strong>{t('ds.packTitle')}</strong>
          <div className="meta-line">{t('ds.packDesc')}</div>
        </div>
        <button className="secondary" disabled={busy || !consent} onClick={buy}>{formatSek(prices.application)}</button>
      </div>
      {error && <div className="alert error">{error}</div>}
    </div>
  );
}

/** Formulär genererat ur mallens frågor — villkorade frågor visas adaptivt. */
function DocumentForm({ projectId, template, opportunitySlug, prefill, onDone, onCancel, t }: {
  projectId: string; template: TemplateInfo; opportunitySlug: string | null;
  prefill: Record<string, unknown>; onDone: (findings: LanguageFinding[]) => void; onCancel: () => void; t: T;
}) {
  // Färdigifyllt + autospar: formuläret börjar med allt systemet redan vet
  // från intaget (förifyllnaden), och varje rad skrivs till webbläsarens
  // lagring medan användaren fyller i — ett påbörjat utkast vinner över
  // förifyllnaden, och en omladdning tappar aldrig ett halvskrivet underlag.
  // Utkastet rensas när dokumentet genererats (då äger servern innehållet).
  const draftKey = `bidrag.dok.v1.${projectId}.${template.key}`;
  const [answers, setAnswers] = useState<Record<string, unknown>>(() => {
    try {
      const raw = localStorage.getItem(draftKey);
      if (raw) {
        const d = JSON.parse(raw) as unknown;
        if (d && typeof d === 'object' && !Array.isArray(d)) return { ...prefill, ...(d as Record<string, unknown>) };
      }
    } catch { /* privat läge — formuläret fungerar ändå */ }
    return { ...prefill };
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    try { localStorage.setItem(draftKey, JSON.stringify(answers)); } catch { /* ofarligt */ }
  }, [draftKey, answers]);

  const visible = template.questions.filter((q) => !q.showIf || answers[q.showIf.key] === q.showIf.equals);
  const set = (key: string, v: unknown) => setAnswers((a) => ({ ...a, [key]: v }));

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ languageFindings?: LanguageFinding[] }>(`/v1/projects/${projectId}/generated-documents`, {
        templateKey: template.key,
        answers,
        ...(opportunitySlug ? { opportunitySlug } : {}),
      });
      try { localStorage.removeItem(draftKey); } catch { /* ofarligt */ }
      onDone(res.languageFindings ?? []);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('ds.formError'));
    } finally {
      setBusy(false);
    }
  };

  const prefillCount = Object.keys(prefill).filter((k) => prefill[k] !== undefined).length;

  return (
    <div className="card">
      <h2>{template.title}</h2>
      <p className="guidance">{template.description}</p>
      {prefillCount > 0 && (
        <div className="alert success" style={{ marginTop: '0.6rem' }}>
          {prefillCount === 1 ? t('ds.prefilledOne') : t('ds.prefilled', { n: prefillCount })}
        </div>
      )}
      <form onSubmit={submit}>
        {visible.map((q) => (
          <div key={q.key} style={{ margin: '0.8rem 0' }}>
            <label htmlFor={`q-${q.key}`} style={{ fontWeight: 600 }}>
              {q.label}{q.required ? ' *' : ''}
            </label>
            {q.type === 'textarea' && (
              <textarea id={`q-${q.key}`} rows={3} value={(answers[q.key] as string) ?? ''} onChange={(e) => set(q.key, e.target.value)} style={{ width: '100%' }} />
            )}
            {(q.type === 'text' || q.type === 'date') && (
              <input id={`q-${q.key}`} type={q.type === 'date' ? 'date' : 'text'} value={(answers[q.key] as string) ?? ''} onChange={(e) => set(q.key, e.target.value)} style={{ width: '100%' }} />
            )}
            {q.type === 'number' && (
              <input id={`q-${q.key}`} type="number" value={(answers[q.key] as number | '') ?? ''} onChange={(e) => set(q.key, e.target.value === '' ? undefined : Number(e.target.value))} style={{ maxWidth: '12rem', display: 'block' }} />
            )}
            {q.type === 'boolean' && (
              <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.25rem' }}>
                <button type="button" className={answers[q.key] === true ? '' : 'secondary'} onClick={() => set(q.key, true)}>{t('ob.yes')}</button>
                <button type="button" className={answers[q.key] === false ? '' : 'secondary'} onClick={() => set(q.key, false)}>{t('ob.no')}</button>
              </div>
            )}
            {q.type === 'select' && (
              <select id={`q-${q.key}`} value={(answers[q.key] as string) ?? ''} onChange={(e) => set(q.key, e.target.value)} style={{ display: 'block', marginTop: '0.25rem' }}>
                <option value="" disabled>{t('ds.choose')}</option>
                {q.options?.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            )}
            {q.guidance && <p className="meta-line" style={{ marginTop: '0.2rem' }}>{q.guidance}</p>}
          </div>
        ))}
        {error && <div className="alert error">{error}</div>}
        <div style={{ display: 'flex', gap: '0.6rem', marginTop: '1rem' }}>
          <button type="submit" disabled={busy}>{busy ? t('ds.creating') : t('ds.createDoc')}</button>
          <button type="button" className="secondary" onClick={onCancel}>{t('in.cancel')}</button>
        </div>
      </form>
    </div>
  );
}
