/**
 * Matches per project (§12, §66–67): transparent scores, eligibility status,
 * missing facts answered inline (adaptive intake round two), freshness and
 * source always visible.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ApiError, ELIGIBILITY_LABELS, INSTRUMENT_LABELS, formatDate, formatSek, get, patch, post } from '../api';

interface StackPlan {
  items: { opportunityId: string; title: string; plannedContributionMinor: number; compatibility: string; compatibilityNote: string }[];
  ownContributionMinor: number;
  totalBudgetMinor: number;
  coveredMinor: number;
  uncoveredMinor: number;
  warnings: string[];
}

interface MissingFact {
  factPath: string;
  question: string;
}
interface MatchRow {
  matchId: string;
  opportunityId: string;
  slug: string;
  title: string;
  authorityName: string;
  instrumentType: string;
  score: number;
  eligibilityStatus: string;
  closesAt: string | null;
  deadlineModel: string;
  sourceUrl: string;
  verificationStatus: string;
  lastVerifiedAt: string | null;
  maxAmountMinor: number | null;
  submissionLevel: string;
  result: {
    missingFacts: MissingFact[];
    missingEvidence: { kind: string; description: string }[];
    excludedBy: { description: string }[];
    fitScore: number;
    evidenceReadiness: number;
    executionReadiness: number;
    confidence: string;
  };
}
interface Project {
  id: string;
  title: string;
  intent: string;
}

export default function MatchesPage() {
  const { projectId } = useParams();
  const navigate = useNavigate();
  const [projects, setProjects] = useState<Project[]>([]);
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [answers, setAnswers] = useState<Record<string, boolean>>({});
  const [busy, setBusy] = useState(false);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    get<{ projects: Project[] }>('/v1/projects').then(({ projects }) => {
      setProjects(projects);
      if (!projectId && projects.length > 0) navigate(`/projekt/${projects[0]!.id}`, { replace: true });
    });
  }, [projectId, navigate]);

  const load = useCallback(() => {
    if (!projectId) return;
    get<{ matches: MatchRow[] }>(`/v1/projects/${projectId}/matches`)
      .then(({ matches }) => setMatches(matches))
      .finally(() => setLoaded(true));
  }, [projectId]);

  useEffect(load, [load]);

  const project = projects.find((p) => p.id === projectId);

  // Adaptive intake round two: only questions that can still change an
  // outcome — hard-excluded opportunities stay excluded regardless of answers.
  // Questions from personal entitlements come first: in a rights
  // investigation, "uteblir underhållet?" matters before "äger du jordbruk?".
  const PERSONAL_Q = new Set(['social_benefit', 'educational_support']);
  const openQuestions = new Map<string, string>();
  const ordered = [...matches].sort(
    (a, b) => Number(PERSONAL_Q.has(b.instrumentType)) - Number(PERSONAL_Q.has(a.instrumentType)),
  );
  for (const m of ordered) {
    if (m.eligibilityStatus === 'excluded') continue;
    for (const f of m.result.missingFacts) {
      if (!openQuestions.has(f.factPath)) openQuestions.set(f.factPath, f.question);
    }
  }

  const submitAnswers = async () => {
    if (!projectId || Object.keys(answers).length === 0) return;
    setBusy(true);
    try {
      await patch(`/v1/projects/${projectId}`, { facts: answers });
      await post(`/v1/projects/${projectId}/matches`, {});
      setAnswers({});
      load();
    } finally {
      setBusy(false);
    }
  };

  if (!projectId) {
    return (
      <div>
        <h1>Projekt</h1>
        <div className="card">
          <p>Du har inga projekt ännu.</p>
          <p><Link className="btn" to="/kom-igang">Kom igång</Link></p>
        </div>
      </div>
    );
  }

  if (!loaded) return <p>Laddar matchningar…</p>;

  const PERSONAL_INSTRUMENTS = new Set(['social_benefit', 'educational_support']);
  const relevant = matches.filter((m) => m.eligibilityStatus !== 'excluded');
  const excluded = matches.filter((m) => m.eligibilityStatus === 'excluded');
  const personal = relevant.filter((m) => PERSONAL_INSTRUMENTS.has(m.instrumentType));
  const funding = relevant.filter((m) => !PERSONAL_INSTRUMENTS.has(m.instrumentType));

  return (
    <div>
      <h1>{project?.title ?? 'Projekt'}</h1>
      {project?.intent && <p className="meta-line" style={{ marginBottom: '1rem' }}>”{project.intent}”</p>}
      {projects.length > 1 && (
        <p>
          {projects.map((p) => (
            <Link key={p.id} to={`/projekt/${p.id}`} style={{ marginRight: '1rem', fontWeight: p.id === projectId ? 700 : 400 }}>
              {p.title}
            </Link>
          ))}
        </p>
      )}

      {openQuestions.size > 0 && (
        <div className="card" style={{ borderColor: 'var(--warning)' }}>
          <h2>Några frågor kvar</h2>
          <p className="guidance">Dina svar avgör vilka stöd du faktiskt kan söka.</p>
          {[...openQuestions.entries()].slice(0, 6).map(([factPath, question]) => (
            <div key={factPath} style={{ margin: '0.6rem 0' }}>
              <strong>{question}</strong>
              <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem' }}>
                <button className={answers[factPath] === true ? '' : 'secondary'} onClick={() => setAnswers({ ...answers, [factPath]: true })}>Ja</button>
                <button className={answers[factPath] === false ? '' : 'secondary'} onClick={() => setAnswers({ ...answers, [factPath]: false })}>Nej</button>
              </div>
            </div>
          ))}
          <button disabled={busy || Object.keys(answers).length === 0} onClick={submitAnswers} style={{ marginTop: '0.5rem' }}>
            {busy ? 'Uppdaterar…' : 'Uppdatera matchningar'}
          </button>
        </div>
      )}

      {personal.length > 0 && (
        <div className="card">
          <h2>Det här ser du ut att kunna ha rätt till</h2>
          <p className="guidance">
            En bedömning utifrån dina svar — slutligt beslut fattas alltid av myndigheten. Vi hjälper dig gärna vidare med
            en ansökan i taget.
          </p>
          {personal.map((m) => (
            <div className="match-row" key={m.matchId}>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>{' '}
                  <LikelihoodBadge status={m.eligibilityStatus} confidence={m.result.confidence} />
                </div>
                <div className="meta-line">
                  {m.authorityName} · <span className="badge info">{INSTRUMENT_LABELS[m.instrumentType] ?? m.instrumentType}</span>
                  {' · '}Senast verifierad {formatDate(m.lastVerifiedAt)}
                </div>
                {m.result.missingFacts.length > 0 && (
                  <div className="meta-line" style={{ color: 'var(--warning)' }}>
                    För att veta säkert: {m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ')}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {(() => {
        // I det personliga spåret visas projektbidrag bara om de faktiskt ser
        // aktuella ut — resten sammanfattas i stället för att skräpa ner listan.
        const shownFunding = personal.length > 0 ? funding.filter((m) => m.eligibilityStatus === 'eligible') : funding;
        const summarised = funding.length - shownFunding.length;
        if (personal.length > 0 && shownFunding.length === 0) {
          return summarised > 0 ? (
            <p className="meta-line" style={{ margin: '0 0 1rem 0.25rem' }}>
              Vi har även gått igenom {summarised} bidrag för projekt och verksamheter — inget av dem ser aktuellt ut för
              din situation just nu.
            </p>
          ) : null;
        }
        return (
      <div className="card">
        <h2>{personal.length > 0 ? `Bidrag och finansiering (${shownFunding.length})` : `Stöd som kan passa (${shownFunding.length})`}</h2>
        {relevant.length === 0 && <p className="meta-line">Inga matchningar ännu — svara på frågorna ovan eller uppdatera projektet.</p>}
        {personal.length > 0 && summarised > 0 && (
          <p className="guidance">Ytterligare {summarised} möjligheter visas inte eftersom uppgifter saknas.</p>
        )}
        {shownFunding.map((m) => (
          <div className="match-row" key={m.matchId}>
            <div className="match-score">
              <div className="n">{m.score}</div>
              <div className="of">av 100</div>
            </div>
            <div style={{ flex: 1 }}>
              <div>
                <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>
              </div>
              <div className="meta-line">
                {m.authorityName} · <span className="badge info">{INSTRUMENT_LABELS[m.instrumentType] ?? m.instrumentType}</span>{' '}
                <span className={`badge ${ELIGIBILITY_LABELS[m.eligibilityStatus]?.tone ?? ''}`}>
                  {ELIGIBILITY_LABELS[m.eligibilityStatus]?.label ?? m.eligibilityStatus}
                </span>
                {m.maxAmountMinor && <> · upp till {formatSek(m.maxAmountMinor)}</>}
              </div>
              <div className="meta-line">
                {m.closesAt
                  ? `Ansökan stänger ${formatDate(m.closesAt)}`
                  : m.deadlineModel === 'rolling'
                    ? 'Löpande ansökan'
                    : 'Nästa omgång ej publicerad'}
                {' · '}Senast verifierad {formatDate(m.lastVerifiedAt)}
              </div>
              {m.result.missingFacts.length > 0 && (
                <div className="meta-line" style={{ color: 'var(--warning)' }}>
                  Saknas: {m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ')}
                </div>
              )}
              {m.result.missingEvidence.length > 0 && (
                <div className="meta-line">Underlag som behövs: {m.result.missingEvidence.map((e) => e.description).join(', ')}</div>
              )}
            </div>
          </div>
        ))}
      </div>
        );
      })()}

      {personal.length === 0 && relevant.length > 1 && <StackPlanner projectId={projectId} />}

      {excluded.length > 0 && (
        <div className="card">
          <h2>Uppfyller inte kraven ({excluded.length})</h2>
          {excludedList(excluded)}
        </div>
      )}
    </div>
  );
}

/**
 * Rättighetsspråket: aldrig "du är berättigad" — alltid en bedömning.
 * eligible+hög konfidens → hög sannolikhet; annars möjlig; okänt → utreds.
 */
function LikelihoodBadge({ status, confidence }: { status: string; confidence: string }) {
  if (status === 'eligible' && confidence === 'high') return <span className="badge success">hög sannolikhet</span>;
  if (status === 'eligible') return <span className="badge success">möjlig</span>;
  return <span className="badge warning">behöver utredas</span>;
}

function excludedList(excluded: MatchRow[]) {
  return (
    <>
      <p className="guidance">Vi visar varför — kraven kommer från respektive källa.</p>
      {excluded.map((m) => (
        <div className="match-row" key={m.matchId}>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 600, color: 'var(--text-muted)' }}>{m.title}</div>
            <div className="meta-line">
              {m.result.excludedBy.length > 0
                ? m.result.excludedBy.map((e) => e.description).join(' · ')
                : m.result.missingFacts.length > 0
                  ? `Obesvarade krav: ${m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ')}`
                  : 'Uppfyller inte de publicerade kraven.'}
            </div>
          </div>
        </div>
      ))}
    </>
  );
}

/** Funding stack planner (§13): proposes a combination and flags what needs confirmation. */
function StackPlanner({ projectId }: { projectId: string }) {
  const [own, setOwn] = useState('');
  const [plan, setPlan] = useState<StackPlan | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const compute = async () => {
    setBusy(true);
    setError(null);
    try {
      const { stack } = await post<{ stack: { plan: StackPlan } }>(`/v1/projects/${projectId}/funding-stack`, {
        ownContributionMinor: Math.round(Number(own || 0) * 100),
      });
      setPlan(stack.plan);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Kunde inte ta fram en plan.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>Finansieringsplan</h2>
      <p className="guidance">
        Hur kan flera stöd kombineras för att täcka hela budgeten? Vi antar aldrig att två stöd kan kombineras — allt som
        behöver bekräftas flaggas.
      </p>
      <div style={{ display: 'flex', gap: '0.6rem', alignItems: 'end', flexWrap: 'wrap' }}>
        <div>
          <label>Egen insats (kr)</label>
          <input type="number" min={0} value={own} onChange={(e) => setOwn(e.target.value)} placeholder="0" />
        </div>
        <button disabled={busy} onClick={compute}>Föreslå plan</button>
      </div>
      {error && <div className="alert error">{error}</div>}
      {plan && (
        <div style={{ marginTop: '1rem' }}>
          <table className="data">
            <thead><tr><th>Stöd</th><th>Planerat belopp</th><th>Kombination</th></tr></thead>
            <tbody>
              {plan.items.map((i) => (
                <tr key={i.opportunityId}>
                  <td>{i.title}</td>
                  <td>{formatSek(i.plannedContributionMinor)}</td>
                  <td>
                    {i.compatibility === 'compatible' && <span className="badge success">kompatibel</span>}
                    {i.compatibility === 'requires_confirmation' && (
                      <span className="badge warning" title={i.compatibilityNote}>kräver bekräftelse</span>
                    )}
                    {i.compatibility === 'potentially_overlapping' && (
                      <span className="badge warning" title={i.compatibilityNote}>kan överlappa</span>
                    )}
                  </td>
                </tr>
              ))}
              <tr>
                <td style={{ fontWeight: 600 }}>Egen insats</td>
                <td>{formatSek(plan.ownContributionMinor)}</td>
                <td />
              </tr>
              <tr>
                <td style={{ fontWeight: 700 }}>Täckt av planen</td>
                <td style={{ fontWeight: 700 }}>{formatSek(plan.coveredMinor)} av {formatSek(plan.totalBudgetMinor)}</td>
                <td />
              </tr>
            </tbody>
          </table>
          {plan.warnings.map((w, i) => (
            <div key={i} className="alert warning">{w}</div>
          ))}
        </div>
      )}
    </div>
  );
}
