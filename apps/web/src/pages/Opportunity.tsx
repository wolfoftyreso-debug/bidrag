/**
 * Opportunity detail (§76): plain-Swedish summary, criteria with provenance,
 * source + freshness always visible, honest submission-level statement,
 * "start application" from a project.
 */
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { PurchaseConsent } from '../components/PurchaseConsent';
import { ApiError, formatDate, formatSek, get, post } from '../api';
import { useLabels, useT } from '../i18n';

type T = ReturnType<typeof useT>;

interface Criterion {
  id: string;
  kind: 'hard' | 'mandatory' | 'weighted';
  description: string;
}
interface OpportunityDetail {
  opportunity: {
    id: string;
    slug: string;
    title: string;
    summary: string;
    description: string;
    objective: string;
    instrumentType: string;
    applicantTypes: string[];
    minAmountMinor: number | null;
    maxAmountMinor: number | null;
    amountNote: string | null;
    amountSourceUrl: string | null;
    maxFundingSharePercent: number | null;
    deadlineModel: string;
    opensAt: string | null;
    closesAt: string | null;
    applicationMethod: string;
    applicationUrl: string | null;
    submissionLevel: string;
    estimatedEffortDays: number;
    sourceUrl: string;
    sourceQuality: string;
    verificationStatus: string;
    lastVerifiedAt: string | null;
  };
  authority: { name: string; website: string | null } | null;
  ruleVersion: {
    version: number;
    criteria: Criterion[];
    evidenceRequirements: { kind: string; description: string; mandatory: boolean }[];
    effectiveFrom: string;
  } | null;
  hasApplicationSchema: boolean;
}

export default function OpportunityPage() {
  const t = useT();
  const labels = useLabels();
  const { id } = useParams();
  const [params] = useSearchParams();
  const projectId = params.get('projekt');
  const navigate = useNavigate();
  const [data, setData] = useState<OpportunityDetail | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [priceMinor, setPriceMinor] = useState<number | null>(null);

  useEffect(() => {
    if (id) get<OpportunityDetail>(`/v1/funding-opportunities/${id}`).then(setData).catch(() => setError(t('o.loadError')));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  if (error) return <div className="alert error">{error}</div>;
  if (!data) return <p>{t('app.loading')}</p>;

  const { opportunity: opp, authority, ruleVersion } = data;

  const startApplication = async () => {
    if (!projectId) return;
    setBusy(true);
    setError(null);
    try {
      const { application } = await post<{ application: { id: string } }>('/v1/applications', {
        projectId,
        opportunityId: opp.id,
      });
      navigate(`/ansokningar/${application.id}`);
    } catch (err) {
      // Prismodellen: 19 kr per ansökan — 402 startar köpflödet i stället för
      // att visas som ett fel. När betalningen bekräftats skapas ansökan.
      if (err instanceof ApiError && err.status === 402) {
        setPriceMinor((err.body as { priceMinor?: number }).priceMinor ?? 1900);
        setBusy(false);
        return;
      }
      setError(err instanceof ApiError ? err.message : t('o.createError'));
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 760 }}>
      <p><Link to={projectId ? `/projekt/${projectId}` : '/projekt'}>{t('o.backToMatches')}</Link></p>
      <h1>{opp.title}</h1>
      <p className="meta-line">
        {authority?.name} · <span className="badge info">{labels.instr(opp.instrumentType)}</span>
      </p>

      <div className="card">
        <p style={{ fontSize: '1.05rem' }}>{opp.summary}</p>
        <p>{opp.description}</p>
        <dl className="kv" style={{ marginTop: '1rem' }}>
          <dt>{t('o.amount')}</dt>
          <dd>
            {opp.amountNote ? opp.amountNote : opp.maxAmountMinor ? t('o.amountUpTo', { belopp: formatSek(opp.maxAmountMinor) }) : t('o.amountVaries')}
            {opp.maxFundingSharePercent ? t('o.amountShare', { procent: opp.maxFundingSharePercent }) : ''}
          </dd>
          <dt>{t('o.closes')}</dt>
          <dd>
            {opp.closesAt
              ? formatDate(opp.closesAt)
              : opp.deadlineModel === 'rolling'
                ? t('m.rolling')
                : t('o.nextRoundLong')}
          </dd>
          <dt>{t('o.effort')}</dt>
          <dd>{t('o.effortDays', { n: opp.estimatedEffortDays })}</dd>
          <dt>{t('o.howToApply')}</dt>
          <dd>{opp.applicationMethod}</dd>
        </dl>
        <div className="alert info" style={{ marginTop: '1rem' }}>{t('o.submissionNote')}</div>
      </div>

      {ruleVersion && (
        <div className="card">
          <h2>{t('o.criteriaTitle')}</h2>
          <p className="guidance">{t('o.criteriaGuidance')}</p>
          <h3>{t('o.mustMeet')}</h3>
          {ruleVersion.criteria
            .filter((c) => c.kind !== 'weighted')
            .map((c) => (
              <div className="explain-item" key={c.id}>
                <span className="explain-icon">•</span>
                <span>{c.description}</span>
              </div>
            ))}
          <h3>{t('o.strengthens')}</h3>
          {ruleVersion.criteria
            .filter((c) => c.kind === 'weighted')
            .map((c) => (
              <div className="explain-item" key={c.id}>
                <span className="explain-icon">+</span>
                <span>{c.description}</span>
              </div>
            ))}
          {ruleVersion.evidenceRequirements.length > 0 && (
            <>
              <h3>{t('o.evidenceTitle')}</h3>
              {ruleVersion.evidenceRequirements.map((e) => (
                <div className="explain-item" key={e.kind}>
                  <span className="explain-icon">{e.mandatory ? '!' : '·'}</span>
                  <span>
                    {e.description} {e.mandatory ? <span className="badge warning">{t('o.mandatory')}</span> : <span className="badge">{t('o.optional')}</span>}
                  </span>
                </div>
              ))}
            </>
          )}
        </div>
      )}

      {projectId && (
        <div className="card">
          <h2>{t('o.readyTitle')}</h2>
          <p>{t('o.readyBody')}</p>
          {priceMinor === null ? (
            <button disabled={busy} onClick={startApplication}>{t('o.prepareInSystem')}</button>
          ) : (
            <ApplicationPurchase projectId={projectId} priceMinor={priceMinor} onPaid={startApplication} t={t} />
          )}
        </div>
      )}

      <div className="source-line">
        <strong>{t('o.source')}</strong> <a href={opp.sourceUrl} target="_blank" rel="noreferrer">{opp.sourceUrl}</a>
        <br />
        <strong>{t('o.lastVerifiedLabel')}</strong> {formatDate(opp.lastVerifiedAt)} · {labels.verif(opp.verificationStatus)} · {t('o.sourceQuality', { kvalitet: opp.sourceQuality })}
        {ruleVersion && <> · {t('o.ruleVersion', { version: ruleVersion.version, datum: formatDate(ruleVersion.effectiveFrom) })}</>}
        <br />
        {t('o.checkSource')}
      </div>
    </div>
  );
}

/**
 * Köpflödet för en ansökan (19 kr per ansökan) — samma betalningsmönster som
 * analysen och dokumentstudion: mock-knapp i utveckling, Swish-QR/deeplink i
 * drift, och ansökan skapas först när betalningen är bekräftad server-side.
 * OBS: ångerrättssamtycket (PurchaseConsent) har bindande svensk lydelse —
 * det översätts inte i fas A (I18N_PROGRAM §gränser).
 */
function ApplicationPurchase({ projectId, priceMinor, onPaid, t }: { projectId: string; priceMinor: number; onPaid: () => void; t: T }) {
  const [busy, setBusy] = useState(false);
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [payment, setPayment] = useState<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean; redirectUrl?: string } } | null>(null);
  const [confirmed, setConfirmed] = useState(false);

  // F-SCROLL: köpflödets vyer är interna tillståndsbyten — börja alltid i toppen.
  useEffect(() => { window.scrollTo(0, 0); }, [payment, confirmed]);

  const buy = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean; redirectUrl?: string } }>(
        `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: consent },
      );
      // Stripe: lämna SPA:n för den hostade betalsidan. Spara vart användaren ska
      // tillbaka (samma stödsida) så returvyn kan navigera hem efter bekräftelsen.
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
      setConfirmed(true);
      onPaid();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : t('o.payConfirmError'));
      setBusy(false);
    }
  };

  useEffect(() => {
    if (!payment || payment.instructions.method !== 'swish' || confirmed) return;
    const iv = setInterval(async () => {
      const res = await get<{ state: string }>(`/v1/payments/${payment.paymentId}/status`).catch(() => null);
      if (res?.state === 'confirmed') { setConfirmed(true); onPaid(); }
    }, 2500);
    return () => clearInterval(iv);
  }, [payment, confirmed, onPaid]);

  if (confirmed) return <p className="meta-line">{t('o.payConfirmed')}</p>;

  if (payment) {
    // Stripe redirectar normalt bort direkt; hit når vi bara om redirect-URL:en
    // saknades — erbjud en manuell länk i stället för att fastna.
    if (payment.instructions.method === 'stripe') {
      return (
        <div style={{ textAlign: 'center' }}>
          <p className="guidance">{payment.instructions.message}</p>
          {payment.instructions.redirectUrl
            ? <p><a className="btn" href={payment.instructions.redirectUrl}>{t('o.payContinue')}</a></p>
            : <div className="alert error">{t('o.payPageError')}</div>}
        </div>
      );
    }
    return payment.instructions.method === 'mock' ? (
      <div className="alert warning">
        <p style={{ fontWeight: 700 }}>{payment.instructions.message}</p>
        <button disabled={busy} onClick={confirmMock}>{t('o.payMockConfirm')}</button>
        {error && <div className="alert error">{error}</div>}
      </div>
    ) : (
      <div style={{ textAlign: 'center' }}>
        <h3>{t('o.paySwishTitle')}</h3>
        {payment.instructions.qrAvailable && (
          <img src={`/v1/payments/${payment.paymentId}/qr`} alt={t('o.paySwishQrAlt')} width={220} height={220} style={{ display: 'block', margin: '0.5rem auto' }} />
        )}
        {payment.instructions.deepLink && <p><a className="btn" href={payment.instructions.deepLink}>{t('o.paySwishOpen')}</a></p>}
        <p className="meta-line">{t('o.payWaiting')}</p>
        {error && <div className="alert error">{error}</div>}
      </div>
    );
  }

  return (
    <div>
      <p className="guidance">{t('o.payGuidance', { pris: formatSek(priceMinor) })}</p>
      <PurchaseConsent checked={consent} onChange={setConsent} idSuffix="-ansokan" />
      <button disabled={busy || !consent} onClick={buy}>{t('o.payButton', { pris: formatSek(priceMinor) })}</button>
      {error && <div className="alert error">{error}</div>}
    </div>
  );
}
