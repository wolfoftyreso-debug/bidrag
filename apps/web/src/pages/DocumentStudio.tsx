/**
 * Dokumentstudion (§produktsteg 3): "Förbered min ansökan". Ett erbjudande om
 * hjälp — paket i stället för att varje knapp kostar 19 kr till. Frågorna
 * ställs en sektion i taget, dokumentet genereras server-side av domänmotorn
 * och hamnar under Mina dokument (PDF + redigerbar text). Användaren skickar
 * själv in via myndighetens kanal — Bidrag.se beslutar aldrig.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { ApiError, formatDate, formatSek, get, post } from '../api';

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
  prices: { single: number; pack3: number; all: number };
  templates: TemplateInfo[];
}
interface GeneratedDoc { id: string; title: string; opportunityTitle: string; createdAt: string }

export default function DocumentStudioPage() {
  const { projectId } = useParams();
  const [params] = useSearchParams();
  const opportunitySlug = params.get('stod');
  const [info, setInfo] = useState<CreditsInfo | null>(null);
  const [docs, setDocs] = useState<GeneratedDoc[]>([]);
  const [active, setActive] = useState<TemplateInfo | null>(null);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(() => {
    if (!projectId) return;
    get<CreditsInfo>(`/v1/projects/${projectId}/document-credits`).then(setInfo).catch(() => setInfo(null));
    get<{ documents: GeneratedDoc[] }>(`/v1/projects/${projectId}/generated-documents`).then((r) => setDocs(r.documents)).catch(() => {});
  }, [projectId]);
  useEffect(load, [load]);

  if (!projectId || !info) return <p>Laddar…</p>;

  return (
    <div style={{ maxWidth: 680 }}>
      <h1>Förbered din ansökan</h1>
      <p className="guidance">
        Du svarar på frågor — vi skapar färdiga dokument: ansökan, ekonomisk bilaga, behovsbeskrivning och
        förklaringar. Dokumenten sparas på ditt konto och du skickar själv in dem via myndighetens webbplats.
      </p>

      {docs.length > 0 && (
        <div className="card">
          <h2>Mina dokument</h2>
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

      {info.remaining <= 0 && <PackOffer projectId={projectId} prices={info.prices} onPurchased={load} />}

      {info.remaining > 0 && !active && (
        <div className="card">
          <h2>Välj dokument att skapa</h2>
          <p className="guidance">Du har {info.remaining >= 99 ? 'obegränsat antal' : `${info.remaining}`} dokument kvar i ditt paket.</p>
          {info.templates.map((t) => (
            <div className="match-row" key={t.key} style={{ alignItems: 'center' }}>
              <div style={{ flex: 1 }}>
                <strong>{t.title}</strong>
                <div className="meta-line">{t.description}</div>
              </div>
              <button className="secondary" onClick={() => setActive(t)}>Skapa</button>
            </div>
          ))}
        </div>
      )}

      {active && (
        <DocumentForm
          projectId={projectId}
          template={active}
          opportunitySlug={opportunitySlug}
          onDone={() => { setActive(null); load(); }}
          onCancel={() => setActive(null)}
        />
      )}

      {error && <div className="alert error">{error}</div>}
      <p className="meta-line" style={{ marginTop: '1rem' }}>
        Dokumenten bygger på dina egna uppgifter. Slutlig bedömning görs alltid av mottagande myndighet eller
        organisation. <Link to={`/projekt/${projectId}`}>← Tillbaka till analysen</Link>
      </p>
    </div>
  );
}

/** Paketerbjudandet — hjälp, inte styckdebitering. "Gör det själv" är alltid gratis. */
function PackOffer({ projectId, prices, onPurchased }: { projectId: string; prices: CreditsInfo['prices']; onPurchased: () => void }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [payment, setPayment] = useState<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean } } | null>(null);
  const [confirmedNote, setConfirmedNote] = useState(false);

  const buy = async (pack: 'single' | 'pack3' | 'all') => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ paymentId: string; instructions: { method: string; message?: string } }>(
        `/v1/projects/${projectId}/document-pack`, { pack },
      );
      setPayment(res);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Köpet kunde inte startas.');
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
      setError(err instanceof ApiError ? err.message : 'Bekräftelsen misslyckades.');
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
        {payment.instructions.method === 'mock' ? (
          <div className="alert warning">
            <p style={{ fontWeight: 700 }}>{payment.instructions.message}</p>
            <button disabled={busy} onClick={confirmMock}>Bekräfta betalning (simulerad)</button>
          </div>
        ) : (
          <div style={{ textAlign: 'center' }}>
            <h3>Betala med Swish</h3>
            {payment.instructions.qrAvailable && (
              <img src={`/v1/payments/${payment.paymentId}/qr`} alt="Swish QR-kod" width={220} height={220} style={{ display: 'block', margin: '0.5rem auto' }} />
            )}
            {payment.instructions.deepLink && <p><a className="btn" href={payment.instructions.deepLink}>Öppna Swish</a></p>}
            <p className="meta-line">Väntar på betalning…</p>
          </div>
        )}
        {error && <div className="alert error">{error}</div>}
      </div>
    );
  }

  return (
    <div className="card">
      <h2>Vill du ha hjälp med dokumenten?</h2>
      <p className="guidance">
        Du kan alltid ansöka själv — det är gratis, och vi länkar dig direkt till rätt ansökan. Vill du att vi
        förbereder dokumenten åt dig väljer du ett paket. Kvittot hamnar under Mina köp.
      </p>
      <div style={{ display: 'grid', gap: '0.6rem' }}>
        <PackRow label="Ett dokument" price={prices.single} onBuy={() => buy('single')} busy={busy} />
        <PackRow label="Upp till 3 dokument" sub="Räcker för de flesta ansökningar: ansökan + bilaga + beskrivning." price={prices.pack3} onBuy={() => buy('pack3')} busy={busy} recommended />
        <PackRow label="Alla dokument för en ansökan" price={prices.all} onBuy={() => buy('all')} busy={busy} />
      </div>
      {error && <div className="alert error">{error}</div>}
    </div>
  );
}

function PackRow({ label, sub, price, onBuy, busy, recommended }: { label: string; sub?: string; price: number; onBuy: () => void; busy: boolean; recommended?: boolean }) {
  return (
    <div className="match-row" style={{ alignItems: 'center', border: recommended ? '1px solid var(--primary)' : undefined, borderRadius: 8, padding: '0.6rem 0.8rem' }}>
      <div style={{ flex: 1 }}>
        <strong>{label}</strong> {recommended && <span className="badge info">vanligast</span>}
        {sub && <div className="meta-line">{sub}</div>}
      </div>
      <button className="secondary" disabled={busy} onClick={onBuy}>{formatSek(price)}</button>
    </div>
  );
}

/** Formulär genererat ur mallens frågor — villkorade frågor visas adaptivt. */
function DocumentForm({ projectId, template, opportunitySlug, onDone, onCancel }: {
  projectId: string; template: TemplateInfo; opportunitySlug: string | null; onDone: () => void; onCancel: () => void;
}) {
  const [answers, setAnswers] = useState<Record<string, unknown>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const visible = template.questions.filter((q) => !q.showIf || answers[q.showIf.key] === q.showIf.equals);
  const set = (key: string, v: unknown) => setAnswers((a) => ({ ...a, [key]: v }));

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await post(`/v1/projects/${projectId}/generated-documents`, {
        templateKey: template.key,
        answers,
        ...(opportunitySlug ? { opportunitySlug } : {}),
      });
      onDone();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Dokumentet kunde inte skapas.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>{template.title}</h2>
      <p className="guidance">{template.description}</p>
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
                <button type="button" className={answers[q.key] === true ? '' : 'secondary'} onClick={() => set(q.key, true)}>Ja</button>
                <button type="button" className={answers[q.key] === false ? '' : 'secondary'} onClick={() => set(q.key, false)}>Nej</button>
              </div>
            )}
            {q.type === 'select' && (
              <select id={`q-${q.key}`} value={(answers[q.key] as string) ?? ''} onChange={(e) => set(q.key, e.target.value)} style={{ display: 'block', marginTop: '0.25rem' }}>
                <option value="" disabled>Välj…</option>
                {q.options?.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            )}
            {q.guidance && <p className="meta-line" style={{ marginTop: '0.2rem' }}>{q.guidance}</p>}
          </div>
        ))}
        {error && <div className="alert error">{error}</div>}
        <div style={{ display: 'flex', gap: '0.6rem', marginTop: '1rem' }}>
          <button type="submit" disabled={busy}>{busy ? 'Skapar…' : 'Skapa dokumentet'}</button>
          <button type="button" className="secondary" onClick={onCancel}>Avbryt</button>
        </div>
      </form>
    </div>
  );
}
