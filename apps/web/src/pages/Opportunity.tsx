/**
 * Opportunity detail (§76): plain-Swedish summary, criteria with provenance,
 * source + freshness always visible, honest submission-level statement,
 * "start application" from a project.
 */
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { PurchaseConsent } from '../components/PurchaseConsent';
import { ApiError, INSTRUMENT_LABELS, formatDate, formatSek, get, post } from '../api';

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

const VERIFICATION_LABELS: Record<string, string> = {
  unverified: 'Ej verifierad',
  machine_extracted: 'Automatiskt inläst — ej granskad',
  ai_curated: 'AI-sammanställd från officiell källa — ej granskad av människa',
  human_curated: 'Manuellt sammanställd från officiell källa',
  human_verified: 'Verifierad mot officiell källa',
};

export default function OpportunityPage() {
  const { id } = useParams();
  const [params] = useSearchParams();
  const projectId = params.get('projekt');
  const navigate = useNavigate();
  const [data, setData] = useState<OpportunityDetail | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [priceMinor, setPriceMinor] = useState<number | null>(null);

  useEffect(() => {
    if (id) get<OpportunityDetail>(`/v1/funding-opportunities/${id}`).then(setData).catch(() => setError('Stödet kunde inte hämtas.'));
  }, [id]);

  if (error) return <div className="alert error">{error}</div>;
  if (!data) return <p>Laddar…</p>;

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
      setError(err instanceof ApiError ? err.message : 'Kunde inte skapa ansökan.');
      setBusy(false);
    }
  };

  return (
    <div style={{ maxWidth: 760 }}>
      <p><Link to={projectId ? `/projekt/${projectId}` : '/projekt'}>&larr; Tillbaka till matchningar</Link></p>
      <h1>{opp.title}</h1>
      <p className="meta-line">
        {authority?.name} · <span className="badge info">{INSTRUMENT_LABELS[opp.instrumentType] ?? opp.instrumentType}</span>
      </p>

      <div className="card">
        <p style={{ fontSize: '1.05rem' }}>{opp.summary}</p>
        <p>{opp.description}</p>
        <dl className="kv" style={{ marginTop: '1rem' }}>
          <dt>Belopp</dt>
          <dd>
            {opp.maxAmountMinor ? `Upp till ${formatSek(opp.maxAmountMinor)}` : 'Varierar — se källan'}
            {opp.maxFundingSharePercent ? ` (max ${opp.maxFundingSharePercent} % av kostnaden)` : ''}
          </dd>
          <dt>Ansökan stänger</dt>
          <dd>
            {opp.closesAt
              ? formatDate(opp.closesAt)
              : opp.deadlineModel === 'rolling'
                ? 'Löpande ansökan'
                : 'Nästa omgång är inte publicerad ännu'}
          </dd>
          <dt>Uppskattad arbetsinsats</dt>
          <dd>cirka {opp.estimatedEffortDays} arbetsdagar</dd>
          <dt>Så ansöker du</dt>
          <dd>{opp.applicationMethod}</dd>
        </dl>
        <div className="alert info" style={{ marginTop: '1rem' }}>
          Den slutliga inlämningen görs i myndighetens officiella tjänst. Bidragskoll.se förbereder hela ansökan, håller ordning på
          underlag och deadlines, och hjälper dig hela vägen — men vi påstår aldrig att något är inlämnat utan kvitto.
        </div>
      </div>

      {ruleVersion && (
        <div className="card">
          <h2>Krav och bedömning</h2>
          <p className="guidance">
            Så här bedömer systemet din matchning. Det är en bedömning utifrån publicerade kriterier — inte myndighetens beslut.
          </p>
          <h3>Krav som måste uppfyllas</h3>
          {ruleVersion.criteria
            .filter((c) => c.kind !== 'weighted')
            .map((c) => (
              <div className="explain-item" key={c.id}>
                <span className="explain-icon">•</span>
                <span>{c.description}</span>
              </div>
            ))}
          <h3>Stärker ansökan</h3>
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
              <h3>Underlag som behövs</h3>
              {ruleVersion.evidenceRequirements.map((e) => (
                <div className="explain-item" key={e.kind}>
                  <span className="explain-icon">{e.mandatory ? '!' : '·'}</span>
                  <span>
                    {e.description} {e.mandatory ? <span className="badge warning">obligatorisk</span> : <span className="badge">frivillig</span>}
                  </span>
                </div>
              ))}
            </>
          )}
        </div>
      )}

      {projectId && (
        <div className="card">
          <h2>Redo att börja?</h2>
          <p>Ansökan förifylls med det du redan berättat. Du kan spara och fortsätta när du vill.</p>
          {priceMinor === null ? (
            <button disabled={busy} onClick={startApplication}>Förbered ansökan i systemet</button>
          ) : (
            <ApplicationPurchase projectId={projectId} priceMinor={priceMinor} onPaid={startApplication} />
          )}
        </div>
      )}

      <div className="source-line">
        <strong>Källa:</strong> <a href={opp.sourceUrl} target="_blank" rel="noreferrer">{opp.sourceUrl}</a>
        <br />
        <strong>Senast verifierad:</strong> {formatDate(opp.lastVerifiedAt)} · {VERIFICATION_LABELS[opp.verificationStatus] ?? opp.verificationStatus} · Källkvalitet {opp.sourceQuality}
        {ruleVersion && <> · Regelversion {ruleVersion.version} (gäller från {formatDate(ruleVersion.effectiveFrom)})</>}
        <br />
        Kontrollera alltid aktuella villkor hos källan innan du skickar in.
      </div>
    </div>
  );
}

/**
 * Köpflödet för en ansökan (19 kr per ansökan) — samma betalningsmönster som
 * analysen och dokumentstudion: mock-knapp i utveckling, Swish-QR/deeplink i
 * drift, och ansökan skapas först när betalningen är bekräftad server-side.
 */
function ApplicationPurchase({ projectId, priceMinor, onPaid }: { projectId: string; priceMinor: number; onPaid: () => void }) {
  const [busy, setBusy] = useState(false);
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [payment, setPayment] = useState<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean } } | null>(null);
  const [confirmed, setConfirmed] = useState(false);

  // F-SCROLL: köpflödets vyer är interna tillståndsbyten — börja alltid i toppen.
  useEffect(() => { window.scrollTo(0, 0); }, [payment, confirmed]);

  const buy = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ paymentId: string; instructions: { method: string; message?: string; deepLink?: string; qrAvailable?: boolean } }>(
        `/v1/projects/${projectId}/application-purchase`, { immediateDeliveryConsent: true },
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
      setConfirmed(true);
      onPaid();
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Bekräftelsen misslyckades.');
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

  if (confirmed) return <p className="meta-line">Betalningen är bekräftad — ansökan skapas…</p>;

  if (payment) {
    return payment.instructions.method === 'mock' ? (
      <div className="alert warning">
        <p style={{ fontWeight: 700 }}>{payment.instructions.message}</p>
        <button disabled={busy} onClick={confirmMock}>Bekräfta betalning (simulerad)</button>
        {error && <div className="alert error">{error}</div>}
      </div>
    ) : (
      <div style={{ textAlign: 'center' }}>
        <h3>Betala med Swish</h3>
        {payment.instructions.qrAvailable && (
          <img src={`/v1/payments/${payment.paymentId}/qr`} alt="Swish QR-kod" width={220} height={220} style={{ display: 'block', margin: '0.5rem auto' }} />
        )}
        {payment.instructions.deepLink && <p><a className="btn" href={payment.instructions.deepLink}>Öppna Swish</a></p>}
        <p className="meta-line">Väntar på betalning…</p>
        {error && <div className="alert error">{error}</div>}
      </div>
    );
  }

  return (
    <div>
      <p className="guidance">
        Att förbereda en ansökan i systemet kostar {formatSek(priceMinor)} per ansökan — alla dokument för den
        ansökan ingår. Du kan alltid ansöka själv direkt hos myndigheten, det är gratis.
      </p>
      <PurchaseConsent checked={consent} onChange={setConsent} idSuffix="-ansokan" />
      <button disabled={busy || !consent} onClick={buy}>Förbered ansökan — {formatSek(priceMinor)}</button>
      {error && <div className="alert error">{error}</div>}
    </div>
  );
}
