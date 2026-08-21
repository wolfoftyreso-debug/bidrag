/**
 * Matches per project (§12, §66–67): transparent scores, eligibility status,
 * missing facts answered inline (adaptive intake round two), freshness and
 * source always visible.
 */
import { useCallback, useEffect, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { PurchaseConsent } from '../components/PurchaseConsent';
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
  applicationUrl: string | null;
  verificationStatus: string;
  lastVerifiedAt: string | null;
  maxAmountMinor: number | null;
  submissionLevel: string;
  result: {
    missingFacts: MissingFact[];
    /** Besvarade intakefrågor — spegeln av missingFacts, för "Dina svar". */
    answeredFacts?: MissingFact[];
    missingEvidence: { kind: string; description: string }[];
    excludedBy: { description: string }[];
    explanation: { kind: string; outcome: string }[];
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

/** Teaser före upplåsning: antal per nivå och kategori — aldrig namn eller källor. */
interface Teaser {
  locked: true;
  priceMinor: number;
  total: number;
  counts: { high: number; possible: number; needsInfo: number };
  rows: { likelihood: string; category: string }[];
  excludedCount: number;
}

export default function MatchesPage() {
  const { projectId } = useParams();
  const navigate = useNavigate();
  const [projects, setProjects] = useState<Project[]>([]);
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [facts, setFacts] = useState<Record<string, unknown>>({});
  // F-ÄNDRA 2: kvitton på att just sparade svar hamnat under "Dina svar".
  const [savedNote, setSavedNote] = useState<number | null>(null);
  const [teaser, setTeaser] = useState<Teaser | null>(null);
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
    get<{ matches?: MatchRow[] } | Teaser>(`/v1/projects/${projectId}/matches`)
      .then((body) => {
        if ('locked' in body && body.locked) {
          setTeaser(body);
          setMatches([]);
        } else {
          setTeaser(null);
          setMatches((body as { matches: MatchRow[] }).matches);
          setFacts((body as { facts?: Record<string, unknown> }).facts ?? {});
        }
      })
      .finally(() => setLoaded(true));
  }, [projectId]);

  useEffect(load, [load]);

  const project = projects.find((p) => p.id === projectId);

  // Adaptive intake round two: only questions that can still change an
  // outcome — hard-excluded opportunities stay excluded regardless of answers.
  // Questions from personal entitlements come first: in a rights
  // investigation, "uteblir underhållet?" matters before "äger du jordbruk?".
  const PERSONAL_Q = new Set(['social_benefit', 'educational_support', 'loan']);
  // Varje fråga bär sin kontext: vilka stöd den avgör. Utan den etiketten är
  // "Har du sparpengar…?" obegriplig mitt i en lista.
  const openQuestions = new Map<string, { question: string; forTitles: string[]; unknowns: number; personal: boolean }>();
  const ordered = [...matches].sort(
    (a, b) => Number(PERSONAL_Q.has(b.instrumentType)) - Number(PERSONAL_Q.has(a.instrumentType)),
  );
  for (const m of ordered) {
    if (m.eligibilityStatus === 'excluded') continue;
    const shortTitle = m.title.split(' — ').pop() ?? m.title;
    for (const f of m.result.missingFacts) {
      // Art. 9: den som avböjt hälsofrågan i intaget ska aldrig få den igen —
      // stöden bakom gaten förblir "behöver utredas" utan att frågan upprepas.
      if (f.factPath === 'person.disabilityOrLongTermIllnessInFamily' && facts['person.sensitiveQuestionDeclined'] === true) continue;
      const entry = openQuestions.get(f.factPath);
      if (entry) {
        if (!entry.forTitles.includes(shortTitle)) entry.forTitles.push(shortTitle);
        if (m.eligibilityStatus === 'unknown') entry.unknowns += 1;
        entry.personal ||= PERSONAL_Q.has(m.instrumentType);
      } else {
        openQuestions.set(f.factPath, {
          question: f.question,
          forTitles: [shortTitle],
          unknowns: m.eligibilityStatus === 'unknown' ? 1 : 0,
          personal: PERSONAL_Q.has(m.instrumentType),
        });
      }
    }
  }
  // Informationsvärde (§7): frågan som kan AVGÖRA flest stöd ställs först —
  // personliga rättigheter före projektbidrag, sedan flest oavgjorda stöd,
  // sedan flest berörda totalt. Aldrig frågor bara för att bygga profil.
  const openList = [...openQuestions.entries()].sort(([, a], [, b]) =>
    Number(b.personal) - Number(a.personal) || b.unknowns - a.unknowns || b.forTitles.length - a.forTitles.length,
  );

  const submitAnswers = async () => {
    if (!projectId || Object.keys(answers).length === 0) return;
    setBusy(true);
    try {
      const saved = Object.keys(answers).length;
      await patch(`/v1/projects/${projectId}`, { facts: answers });
      await post(`/v1/projects/${projectId}/matches`, {});
      setAnswers({});
      setSavedNote(saved);
      load();
    } finally {
      setBusy(false);
    }
  };

  // Dina svar: en besvarad fråga försvinner aldrig — den flyttar hit och kan
  // ändras när som helst; matchningen räknas om direkt. Ändringen skrivs som
  // projektfakta och vinner därmed över intagssvaret i sammanvägningen.
  const answeredQuestions = new Map<string, { question: string; value: boolean; forTitles: string[] }>();
  for (const m of [...matches].sort((a, b) => Number(PERSONAL_Q.has(b.instrumentType)) - Number(PERSONAL_Q.has(a.instrumentType)))) {
    const shortTitle = m.title.split(' — ').pop() ?? m.title;
    for (const f of m.result.answeredFacts ?? []) {
      if (typeof facts[f.factPath] !== 'boolean') continue;
      const entry = answeredQuestions.get(f.factPath);
      if (entry) {
        if (!entry.forTitles.includes(shortTitle)) entry.forTitles.push(shortTitle);
      } else {
        answeredQuestions.set(f.factPath, { question: f.question, value: facts[f.factPath] as boolean, forTitles: [shortTitle] });
      }
    }
  }

  const changeAnswer = async (factPath: string, value: boolean) => {
    if (!projectId || busy) return;
    setBusy(true);
    try {
      await patch(`/v1/projects/${projectId}`, { facts: { [factPath]: value } });
      await post(`/v1/projects/${projectId}/matches`, {});
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

  if (teaser) {
    return (
      <div>
        <h1>{project?.title ?? 'Projekt'}</h1>
        {project?.intent && <p className="meta-line" style={{ marginBottom: '1rem' }}>”{project.intent}”</p>}
        <AnalysisPaywall projectId={projectId} teaser={teaser} onUnlocked={load} />
      </div>
    );
  }

  const PERSONAL_INSTRUMENTS = new Set(['social_benefit', 'educational_support', 'loan']);
  const relevant = matches.filter((m) => m.eligibilityStatus !== 'excluded');
  const excluded = matches.filter((m) => m.eligibilityStatus === 'excluded');
  const personal = relevant.filter((m) => PERSONAL_INSTRUMENTS.has(m.instrumentType));
  // Företagarspåret (F-EGEN): den som driver eget har lovats genomlysning av
  // företagsstöden. De får en egen sektion och sammanfattas aldrig bort, även
  // när frågor återstår. Speglar API:ts BUSINESS_RELEVANT_SLUGS.
  const BUSINESS_SLUGS = new Set([
    'af-stod-start-naringsverksamhet',
    'vinnova-innovativa-startups',
    'tillvaxtverket-affarsutvecklingscheckar',
    'tillvaxtverket-regionalt-investeringsstod',
    'jordbruksverket-startstod-unga',
    'jordbruksverket-investeringsstod',
  ]);
  const isSelfEmployed = facts['person.selfEmployed'] === true;
  const businessForm = facts['person.businessForm'];
  const business = isSelfEmployed ? relevant.filter((m) => BUSINESS_SLUGS.has(m.slug)) : [];
  const excludedBusiness = isSelfEmployed ? excluded.filter((m) => BUSINESS_SLUGS.has(m.slug)) : [];
  const funding = relevant.filter((m) => !PERSONAL_INSTRUMENTS.has(m.instrumentType) && !(isSelfEmployed && BUSINESS_SLUGS.has(m.slug)));

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

      {savedNote !== null && (
        <div className="alert success" role="status" aria-live="polite">
          ✓ {savedNote === 1 ? 'Ditt svar är sparat' : `Dina ${savedNote} svar är sparade`} och analysen omräknad.
          En besvarad fråga försvinner aldrig — du hittar den under{' '}
          <button className="subtle" style={{ padding: 0, textDecoration: 'underline', color: 'inherit', fontWeight: 600 }}
            onClick={() => document.getElementById('dina-svar')?.scrollIntoView({ behavior: 'smooth', block: 'start' })}>
            Dina svar
          </button>{' '}och kan ändra dig när som helst.
        </div>
      )}

      {openQuestions.size > 0 && (
        <div className="card" style={{ borderColor: 'var(--warning)' }}>
          <h2>Några frågor kvar</h2>
          <p className="guidance">Dina svar avgör vilka stöd du faktiskt kan söka. En besvarad fråga försvinner inte — den flyttar till ”Dina svar” nedanför, där du kan ändra dig.</p>
          {openList.slice(0, 6).map(([factPath, q]) => (
            <div key={factPath} style={{ margin: '0.75rem 0' }}>
              <div className="meta-line" style={{ fontSize: '0.78rem', textTransform: 'uppercase', letterSpacing: '0.03em' }}>
                Gäller {q.forTitles.slice(0, 2).join(' och ')}{q.forTitles.length > 2 ? ` + ${q.forTitles.length - 2} till` : ''}
              </div>
              <strong>{q.question}</strong>
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

      {answeredQuestions.size > 0 && (
        <details className="card" open id="dina-svar" style={{ padding: '0.9rem 1.35rem' }}>
          <summary style={{ cursor: 'pointer', fontWeight: 600 }}>
            Dina svar ({answeredQuestions.size}) — granska eller ändra
          </summary>
          <p className="guidance" style={{ marginTop: '0.5rem' }}>
            Ändrar du ett svar räknas hela analysen om direkt.
          </p>
          {[...answeredQuestions.entries()].map(([factPath, q]) => (
            <div key={factPath} style={{ margin: '0.75rem 0' }}>
              <div className="meta-line" style={{ fontSize: '0.78rem', textTransform: 'uppercase', letterSpacing: '0.03em' }}>
                Gäller {q.forTitles.slice(0, 2).join(' och ')}{q.forTitles.length > 2 ? ` + ${q.forTitles.length - 2} till` : ''}
              </div>
              <strong>{q.question}</strong>
              <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem' }}>
                <button className={q.value === true ? '' : 'secondary'} disabled={busy} onClick={() => q.value !== true && void changeAnswer(factPath, true)}>Ja</button>
                <button className={q.value === false ? '' : 'secondary'} disabled={busy} onClick={() => q.value !== false && void changeAnswer(factPath, false)}>Nej</button>
              </div>
            </div>
          ))}
        </details>
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
                  <LikelihoodBadge m={m} />
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
                {m.eligibilityStatus === 'eligible' && (
                  <div style={{ marginTop: '0.4rem' }}>
                    <div className="meta-line">Utifrån dina svar kan det här stödet vara aktuellt. Kontrollera villkoren innan du ansöker. Vad vill du göra?</div>
                    <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem', flexWrap: 'wrap' }}>
                      {m.applicationUrl && (
                        <a className="btn secondary" style={{ fontSize: '0.85rem', padding: '0.25rem 0.7rem' }} href={m.applicationUrl} target="_blank" rel="noreferrer">
                          Ansök själv — gratis ↗
                        </a>
                      )}
                      <Link className="btn secondary" style={{ fontSize: '0.85rem', padding: '0.25rem 0.7rem' }} to={`/dokument/${projectId}?stod=${m.slug}`}>
                        Förbered min ansökan
                      </Link>
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {isSelfEmployed && (business.length > 0 || excludedBusiness.length > 0) && (
        <div className="card">
          <h2>Stöd som rör ditt företagande ({business.length + excludedBusiness.length})</h2>
          {/* F-FÖRETAG (användarfynd): intaget och rapporten ska säga samma sak —
              för aktiebolag görs bolagets genomlysning separat, och stöden visas
              här med skäl i stället för att gömmas längre ner. */}
          <p className="guidance">
            {businessForm === 'sole_trader'
              ? 'Med enskild firma söker du företagsstöden som person — de ingår i din genomlysning här.'
              : businessForm === 'limited_company'
                ? 'Ett aktiebolags stöd söks av bolaget, inte av dig som person — genomlysningen för bolaget görs därför separat (nytt projekt med bolaget som sökande). Här ser du ändå vilka stöd som finns för verksamheten och vad de kräver.'
                : 'Vilka företagsstöd som är aktuella beror på driftsformen — enskild firma söker som person, aktiebolagets stöd söks av bolaget och genomlyses separat.'}
          </p>
          {business.map((m) => (
            <div className="match-row" key={m.matchId}>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>{' '}
                  <LikelihoodBadge m={m} />
                </div>
                <div className="meta-line">
                  {m.authorityName} · <span className="badge info">{INSTRUMENT_LABELS[m.instrumentType] ?? m.instrumentType}</span>
                </div>
                {m.result.missingFacts.length > 0 && (
                  <div className="meta-line" style={{ color: 'var(--warning)' }}>
                    För att veta säkert: {m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ')}
                  </div>
                )}
              </div>
            </div>
          ))}
          {excludedBusiness.map((m) => (
            <div className="match-row" key={m.matchId} style={{ opacity: 0.75 }}>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>{' '}
                  <span className="badge">uppfyller inte kraven</span>
                </div>
                <div className="meta-line">
                  {(m.result.excludedBy ?? []).map((e) => e.description).join(' · ') ||
                    'Uppfyller inte de publicerade kraven.'}
                </div>
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

      {(() => {
        // Företagsstöd som inte uppfylls visas redan inne i företagssektionen.
        const excludedRest = isSelfEmployed ? excluded.filter((m) => !BUSINESS_SLUGS.has(m.slug)) : excluded;
        return excludedRest.length > 0 && (
        <div className="card">
          <h2>Uppfyller inte kraven ({excludedRest.length})</h2>
          {excludedList(excludedRest)}
        </div>
        );
      })()}
      <p className="meta-line" style={{ margin: '1rem 0.25rem' }}>
        Detta är en vägledning och inte ett myndighetsbeslut. Slutligt beslut fattas alltid av respektive myndighet.
      </p>

      <ReceiptLine projectId={projectId} />
    </div>
  );
}

/**
 * Kvittot för upplåsningen: förstaklass i kontot — visas här och finns
 * alltid under Konto & data → Mina köp. Ingen e-post inblandad.
 */
function ReceiptLine({ projectId }: { projectId: string }) {
  const [receipt, setReceipt] = useState<{ receiptNumber: string } | null>(null);
  const [doc, setDoc] = useState<string>('');

  useEffect(() => {
    get<{ receipt: { receiptNumber: string }; document: string }>(`/v1/projects/${projectId}/receipt`)
      .then((r) => { setReceipt(r.receipt); setDoc(r.document); })
      .catch(() => setReceipt(null));
  }, [projectId]);

  if (!receipt) return null;

  return (
    <div className="meta-line" style={{ margin: '0 0.25rem 1rem' }}>
      Kvitto {receipt.receiptNumber} · sparat under <Link to="/konto">Mina köp</Link>
      <details style={{ marginTop: '0.4rem' }}>
        <summary style={{ cursor: 'pointer' }}>Visa kvitto</summary>
        <pre style={{ background: 'var(--card-bg, #f8f8f8)', padding: '0.8rem', borderRadius: 8, overflowX: 'auto', fontSize: '0.8rem' }}>{doc}</pre>
      </details>
    </div>
  );
}

const LIKELIHOOD_TEASER: Record<string, { dot: string; label: string }> = {
  high: { dot: '🟢', label: 'hög relevans' },
  possible: { dot: '🟡', label: 'möjlig' },
  needs_info: { dot: '⚪', label: 'kräver mer information' },
};

/**
 * Betalvägg (§68): visa värdet — antal och nivåer — innan betalning, men
 * aldrig detaljerna. Ett engångsköp låser upp den här analysen; språket är
 * "lås upp din bidragsanalys", aldrig "köp ett bidrag".
 *
 * Kedjan är alltid betalning bekräftad → kvitto → upplåsning. E-postadressen
 * för kvittot samlas in precis före betalningen (tydligt syfte), och kan
 * kompletteras på bekräftelseskärmen om den missades.
 */
function AnalysisPaywall({ projectId, teaser, onUnlocked }: { projectId: string; teaser: Teaser; onUnlocked: () => void }) {
  const [busy, setBusy] = useState(false);
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [payment, setPayment] = useState<{
    paymentId: string;
    instructions: { method: string; message?: string; mockConfirmable?: boolean; deepLink?: string; qrAvailable?: boolean };
  } | null>(null);
  const [confirmed, setConfirmed] = useState<{ receiptNumber: string; email: string | null } | null>(null);

  // F-SCROLL: betalväggens interna vyer (erbjudande → betalning → kvitto)
  // passerar aldrig routern — utan egen återställning startar de i botten.
  useEffect(() => { window.scrollTo(0, 0); }, [payment, confirmed]);

  // Swish: betalningen bekräftas av banken, inte av klienten — vi pollar
  // status tills servern (som själv verifierar mot Swish) säger confirmed.
  useEffect(() => {
    if (!payment || payment.instructions.method !== 'swish' || confirmed) return;
    let stopped = false;
    const tick = async () => {
      try {
        const res = await get<{ state: string; receipt?: { receiptNumber: string; email: string | null } | null }>(
          `/v1/payments/${payment.paymentId}/status`,
        );
        if (stopped) return;
        if (res.state === 'confirmed' && res.receipt) setConfirmed(res.receipt);
        else if (res.state === 'failed') setError('Betalningen genomfördes inte. Du kan försöka igen — inget har debiterats.');
      } catch {
        /* tillfälligt nätverksfel — nästa poll försöker igen */
      }
    };
    const iv = setInterval(tick, 2500);
    return () => { stopped = true; clearInterval(iv); };
  }, [payment, confirmed]);
  const startUnlock = async () => {
    setBusy(true);
    setError(null);
    try {
      const res = await post<{
        alreadyUnlocked?: boolean;
        paymentId?: string;
        instructions?: { method: string; message?: string; mockConfirmable?: boolean };
      }>(`/v1/projects/${projectId}/analysis-unlock`, { immediateDeliveryConsent: true });
      if (res.alreadyUnlocked) return onUnlocked();
      setPayment({ paymentId: res.paymentId!, instructions: res.instructions! });
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Betalningen kunde inte startas. Försök igen.');
    } finally {
      setBusy(false);
    }
  };

  const confirmMock = async () => {
    if (!payment) return;
    setBusy(true);
    setError(null);
    try {
      const res = await post<{ receipt: { receiptNumber: string; email: string | null } }>(
        `/v1/payments/${payment.paymentId}/mock-confirm`,
      );
      setConfirmed(res.receipt);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : 'Bekräftelsen misslyckades.');
    } finally {
      setBusy(false);
    }
  };

  // Betalning genomförd — kvittobekräftelse före rapporten. Kvittot är en
  // förstaklassfunktion i kontot: alltid åtkomligt under Mina köp, ingen
  // e-post inblandad.
  if (confirmed) {
    return (
      <div className="card" style={{ maxWidth: '32rem' }}>
        <h2>Betalning genomförd ✓</h2>
        <p style={{ fontSize: '1.05rem' }}>Din bidragsanalys är nu upplåst.</p>
        <p className="guidance">
          Kvitto <strong>{confirmed.receiptNumber}</strong> är sparat på ditt konto — du hittar det när som helst under{' '}
          <Link to="/konto">Konto &amp; data → Mina köp</Link>.
        </p>
        {error && <div className="alert error">{error}</div>}
        <button onClick={onUnlocked} style={{ fontSize: '1.05rem', marginTop: '0.5rem' }}>Visa min analys</button>
      </div>
    );
  }

  return (
    <div className="card" style={{ maxWidth: '40rem' }}>
      <h2>Vi hittade {teaser.total} stöd som matchar din situation</h2>
      <p className="guidance">
        Dina svar har körts mot hela kunskapsbasen. Bidragens namn och hur du går vidare visas när rapporten är upplåst.
      </p>
      <p style={{ fontSize: '1.05rem', margin: '0.75rem 0' }}>
        {[
          teaser.counts.high > 0 && <span key="h">🟢 <strong>{teaser.counts.high}</strong> med hög relevans</span>,
          teaser.counts.possible > 0 && <span key="p">🟡 <strong>{teaser.counts.possible}</strong> möjliga</span>,
          teaser.counts.needsInfo > 0 && <span key="n">⚪ <strong>{teaser.counts.needsInfo}</strong> kräver mer information</span>,
        ].filter(Boolean).map((el, i) => <span key={i}>{i > 0 && ' · '}{el}</span>)}
      </p>

      <div style={{ margin: '1rem 0' }}>
        {teaser.rows.map((r, i) => {
          const t = LIKELIHOOD_TEASER[r.likelihood] ?? LIKELIHOOD_TEASER.needs_info!;
          // Fast platshållarmask som blurras — namnen lämnar aldrig servern
          // före betalning, så det som blurras bär noll information.
          const mask = ['Xxxxxxxxxxxxxxx — Xxxxxxxxxxx xxxx xxxxxxxxx', 'Xxxxxxxx — Xxxxxxxxxxxx xxx xxxxxx', 'Xxxxxxxxxxxx — Xxxxxxxx xxxxxxxxxxx'][i % 3]!;
          return (
            <div className="match-row" key={i} style={{ alignItems: 'center', gap: '0.6rem' }}>
              <span>{t.dot}</span>
              <span style={{ flex: 1 }}>
                <span style={{ fontWeight: 600 }}>🔒 <span className="blurred-name" aria-hidden="true">{mask}</span></span>
                <span className="meta-line" style={{ display: 'block' }}>{r.category}</span>
              </span>
              <span className="meta-line">{t.label}</span>
            </div>
          );
        })}
        <p className="meta-line" style={{ marginTop: '0.5rem' }}>
          För att se namnen och gå vidare med ansökan låser du upp rapporten.
        </p>
        {teaser.excludedCount > 0 && (
          <p className="meta-line">
            Ytterligare {teaser.excludedCount} stöd har granskats och uteslutits — även varför ingår i analysen.
          </p>
        )}
      </div>

      {!payment && (
        <>
          <PurchaseConsent checked={consent} onChange={setConsent} idSuffix="-analys" />
          <button disabled={busy || !consent} onClick={startUnlock} style={{ fontSize: '1.05rem' }}>
            {busy ? 'Startar betalning…' : `Lås upp din bidragsanalys — ${formatSek(teaser.priceMinor)}`}
          </button>
          <p className="guidance" style={{ marginTop: '0.75rem' }}>
            Engångsbetalning för den här analysen — ingen prenumeration. Du får hela rapporten: vilka stöd det gäller,
            varför de matchar din situation, vilka kriterier som kontrolleras, vad du behöver och vart du vänder dig.
            Kvittot sparas på ditt konto under Mina köp.
          </p>
        </>
      )}

      {payment && payment.instructions.method === 'mock' && (
        <div className="alert warning" role="status" aria-live="polite">
          <p style={{ fontWeight: 700 }}>{payment.instructions.message}</p>
          <button disabled={busy} onClick={confirmMock}>
            {busy ? 'Bekräftar…' : 'Bekräfta betalning (simulerad)'}
          </button>
        </div>
      )}
      {payment && payment.instructions.method === 'swish' && (
        <div style={{ textAlign: 'center', padding: '0.8rem 0' }}>
          <h3 style={{ margin: '0 0 0.4rem' }}>Betala med Swish</h3>
          {payment.instructions.qrAvailable && (
            <img
              src={`/v1/payments/${payment.paymentId}/qr`}
              alt="Swish QR-kod — skanna med Swish-appen"
              width={220}
              height={220}
              style={{ display: 'block', margin: '0.5rem auto', borderRadius: 8 }}
            />
          )}
          <p className="guidance">Skanna QR-koden med Swish-appen{payment.instructions.deepLink ? ', eller öppna Swish direkt på mobilen:' : '.'}</p>
          {payment.instructions.deepLink && (
            <p><a className="btn" href={payment.instructions.deepLink}>Öppna Swish</a></p>
          )}
          <p className="meta-line">Väntar på betalning… Sidan uppdateras automatiskt när banken har bekräftat.</p>
        </div>
      )}
      {payment && payment.instructions.method !== 'mock' && payment.instructions.method !== 'swish' && payment.instructions.message && (
        <div className="alert warning">{payment.instructions.message}</div>
      )}

      {error && <div className="alert error">{error}</div>}

      <p className="meta-line" style={{ marginTop: '1rem' }}>
        Detta är en vägledning och inte ett myndighetsbeslut. Slutligt beslut fattas alltid av respektive myndighet.
      </p>
    </div>
  );
}

/**
 * Rättighetsspråket: aldrig "du är berättigad" — alltid en bedömning.
 * "Hög sannolikhet" kräver att även viktande kriterier talar för (F3):
 * en familj med hög inkomst ser Majblomman som "möjlig", inte "hög".
 */
function LikelihoodBadge({ m }: { m: MatchRow }) {
  if (m.eligibilityStatus !== 'eligible') return <span className="badge warning">behöver utredas</span>;
  const weightedAgainst = m.result.explanation.some((e) => e.kind === 'weighted' && e.outcome === 'fail');
  if (m.result.confidence === 'high' && !weightedAgainst) return <span className="badge success">hög sannolikhet</span>;
  return <span className="badge success">möjlig</span>;
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
