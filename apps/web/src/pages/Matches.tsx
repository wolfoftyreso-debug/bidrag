/**
 * Matches per project (§12, §66–67): transparent scores, eligibility status,
 * missing facts answered inline (adaptive intake round two), freshness and
 * source always visible.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ELIGIBILITY_LABELS, INSTRUMENT_LABELS, formatDate, formatSek, get, patch, post } from '../api';

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
  const openQuestions = new Map<string, string>();
  for (const m of matches) {
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

  const relevant = matches.filter((m) => m.eligibilityStatus !== 'excluded');
  const excluded = matches.filter((m) => m.eligibilityStatus === 'excluded');

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

      <div className="card">
        <h2>Stöd som kan passa ({relevant.length})</h2>
        {relevant.length === 0 && <p className="meta-line">Inga matchningar ännu — svara på frågorna ovan eller uppdatera projektet.</p>}
        {relevant.map((m) => (
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

      {excluded.length > 0 && (
        <div className="card">
          <h2>Uppfyller inte kraven ({excluded.length})</h2>
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
        </div>
      )}
    </div>
  );
}
