/**
 * Opportunity detail (§76): plain-Swedish summary, criteria with provenance,
 * source + freshness always visible, honest submission-level statement,
 * "start application" from a project.
 */
import { useEffect, useState } from 'react';
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom';
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

  useEffect(() => {
    if (id) get<OpportunityDetail>(`/v1/funding-opportunities/${id}`).then(setData).catch(() => setError('Stödet kunde inte hämtas.'));
  }, [id]);

  if (error) return <div className="alert error">{error}</div>;
  if (!data) return <p>Laddar…</p>;

  const { opportunity: opp, authority, ruleVersion } = data;

  const startApplication = async () => {
    if (!projectId) return;
    setBusy(true);
    try {
      const { application } = await post<{ application: { id: string } }>('/v1/applications', {
        projectId,
        opportunityId: opp.id,
      });
      navigate(`/ansokningar/${application.id}`);
    } catch (err) {
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
          <button disabled={busy} onClick={startApplication}>Starta ansökan</button>
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
