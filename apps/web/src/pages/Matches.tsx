/**
 * Matches per project (§12, §66–67): transparent scores, eligibility status,
 * missing facts answered inline (adaptive intake round two), freshness and
 * source always visible.
 */
import { useCallback, useEffect, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { ApiError, formatDate, formatSek, get, patch, post } from '../api';
import { useLabels, useT } from '../i18n';

/** Översättarfunktionens typ — skickas ned till delkomponenterna. */
type T = ReturnType<typeof useT>;

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
  criterionId?: string;
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
  amountNote?: string | null;
  submissionLevel: string;
  result: {
    missingFacts: MissingFact[];
    /** Besvarade intakefrågor — spegeln av missingFacts, för "Dina svar". */
    answeredFacts?: MissingFact[];
    missingEvidence: { kind: string; description: string }[];
    excludedBy: { description: string }[];
    explanation: { criterionId?: string; description?: string; kind: string; outcome: string }[];
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

/** "Gäller X och Y + 2 till" — lokaliserad ihopsättning av stödtitlarna. */
function appliesLine(t: T, titles: string[]) {
  const shown = titles.slice(0, 2).join(t('m.appliesAnd'));
  const more = titles.length > 2 ? t('m.appliesMore', { n: titles.length - 2 }) : '';
  return t('m.appliesTo', { titlar: shown + more });
}

/**
 * F-INFO (användarfynd): myndighetstydlig fördjupning vid varje fråga —
 * därför ställs den, vilket villkor den prövar per stöd, med länk till
 * stödsidan och den officiella källan. Ingen påhittad text: kravtexterna är
 * de kurerade kriterierna själva.
 */
function QuestionInfo({ details, projectId, t }: {
  details: { title: string; slug: string; requirement: string; kind: string; sourceUrl: string }[];
  projectId: string;
  t: T;
}) {
  return (
    <div className="alert info" role="note" style={{ marginTop: '0.45rem', fontSize: '0.92rem' }}>
      <strong>{t('m.whyTitle')}</strong>
      <ul style={{ margin: '0.35rem 0 0.45rem', paddingInlineStart: '1.1rem' }}>
        {details.map((d) => (
          <li key={d.slug} style={{ marginBottom: '0.3rem' }}>
            <Link to={`/stod/${d.slug}?projekt=${projectId}`}>{d.title}</Link>{' '}
            {d.kind === 'weighted' ? t('m.whyWeighted') : t('m.whyRequirement')}{' '}
            <em>{d.requirement}</em> <a href={d.sourceUrl} target="_blank" rel="noreferrer">{t('m.whySource')}</a>
          </li>
        ))}
      </ul>
      <span className="meta-line">{t('m.whyFooter')}</span>
    </div>
  );
}

function InfoKnapp({ expanded, onClick, t }: { expanded: boolean; onClick: () => void; t: T }) {
  return (
    <button type="button" className="subtle" aria-expanded={expanded} aria-label={t('m.whyAria')}
      title={t('m.whyAria')} onClick={onClick}
      style={{ padding: '0 0.4rem', fontWeight: 700, borderRadius: '50%', lineHeight: 1.4 }}>
      i
    </button>
  );
}

export default function MatchesPage() {
  const t = useT();
  const labels = useLabels();
  const { projectId } = useParams();
  const navigate = useNavigate();
  const [projects, setProjects] = useState<Project[]>([]);
  const [matches, setMatches] = useState<MatchRow[]>([]);
  const [facts, setFacts] = useState<Record<string, unknown>>({});
  const [busy, setBusy] = useState(false);
  // F-STABIL: frågelistan är ett stabilt papper — visade frågor står kvar på
  // sin plats (frusen ordning), besvarade tonas ner och kan ändras direkt.
  const [qOrder, setQOrder] = useState<string[]>([]);
  // Inforutan "Därför ställs frågan" — öppen för högst en fråga åt gången.
  const [openInfo, setOpenInfo] = useState<string | null>(null);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    get<{ projects: Project[] }>('/v1/projects').then(({ projects }) => {
      setProjects(projects);
      if (!projectId && projects.length > 0) navigate(`/projekt/${projects[0]!.id}`, { replace: true });
    });
  }, [projectId, navigate]);

  const load = useCallback(() => {
    if (!projectId) return;
    // Open Discovery: matchningarna är alltid fria — ingen teaser, ingen paywall.
    get<{ matches: MatchRow[]; facts?: Record<string, unknown> }>(`/v1/projects/${projectId}/matches`)
      .then((body) => {
        setMatches(body.matches);
        setFacts(body.facts ?? {});
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
  interface QDetail { title: string; slug: string; requirement: string; kind: string; sourceUrl: string }
  interface QEntry { question: string; forTitles: string[]; unknowns: number; personal: boolean; details: QDetail[] }
  const openQuestions = new Map<string, QEntry>();
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
      const expl = m.result.explanation.find((e) => e.criterionId && e.criterionId === f.criterionId);
      const detail: QDetail = {
        title: shortTitle, slug: m.slug, sourceUrl: m.sourceUrl,
        requirement: expl?.description ?? f.question,
        kind: expl?.kind ?? 'mandatory',
      };
      const entry = openQuestions.get(f.factPath);
      if (entry) {
        if (!entry.forTitles.includes(shortTitle)) entry.forTitles.push(shortTitle);
        if (!entry.details.some((d) => d.slug === detail.slug)) entry.details.push(detail);
        if (m.eligibilityStatus === 'unknown') entry.unknowns += 1;
        entry.personal ||= PERSONAL_Q.has(m.instrumentType);
      } else {
        openQuestions.set(f.factPath, {
          question: f.question,
          forTitles: [shortTitle],
          unknowns: m.eligibilityStatus === 'unknown' ? 1 : 0,
          personal: PERSONAL_Q.has(m.instrumentType),
          details: [detail],
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

  // F-STABIL: frys ordningen — en fråga som visats behåller sin plats; nya
  // frågor läggs alltid sist, så att högst 6 obesvarade visas åt gången.
  const qMeta = useRef(new Map<string, { question: string; forTitles: string[]; details: QDetail[] }>());
  for (const [k, q] of openQuestions) qMeta.current.set(k, { question: q.question, forTitles: q.forTitles, details: q.details });
  useEffect(() => {
    setQOrder((order) => {
      const next = [...order];
      for (const [k] of openList) {
        if (next.filter((path) => typeof facts[path] !== 'boolean').length >= 6) break;
        if (!next.includes(k)) next.push(k);
      }
      return next.length === order.length ? order : next;
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [matches, facts]);

  // Dina svar: en besvarad fråga försvinner aldrig — den flyttar hit och kan
  // ändras när som helst; matchningen räknas om direkt. Ändringen skrivs som
  // projektfakta och vinner därmed över intagssvaret i sammanvägningen.
  const answeredQuestions = new Map<string, { question: string; value: boolean; forTitles: string[]; details: QDetail[] }>();
  for (const m of [...matches].sort((a, b) => Number(PERSONAL_Q.has(b.instrumentType)) - Number(PERSONAL_Q.has(a.instrumentType)))) {
    const shortTitle = m.title.split(' — ').pop() ?? m.title;
    for (const f of m.result.answeredFacts ?? []) {
      if (typeof facts[f.factPath] !== 'boolean') continue;
      const expl = m.result.explanation.find((e) => e.criterionId && e.criterionId === f.criterionId);
      const detail: QDetail = {
        title: shortTitle, slug: m.slug, sourceUrl: m.sourceUrl,
        requirement: expl?.description ?? f.question,
        kind: expl?.kind ?? 'mandatory',
      };
      const entry = answeredQuestions.get(f.factPath);
      if (entry) {
        if (!entry.forTitles.includes(shortTitle)) entry.forTitles.push(shortTitle);
        if (!entry.details.some((d) => d.slug === detail.slug)) entry.details.push(detail);
      } else {
        answeredQuestions.set(f.factPath, { question: f.question, value: facts[f.factPath] as boolean, forTitles: [shortTitle], details: [detail] });
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
        <h1>{t('m.projects')}</h1>
        <div className="card">
          <p>{t('m.noProjects')}</p>
          <p><Link className="btn" to="/kom-igang">{t('dash.getStarted')}</Link></p>
        </div>
      </div>
    );
  }

  if (!loaded) return <p>{t('m.loading')}</p>;

  const PERSONAL_INSTRUMENTS = new Set(['social_benefit', 'educational_support', 'loan']);
  const relevant = matches.filter((m) => m.eligibilityStatus !== 'excluded');
  const excluded = matches.filter((m) => m.eligibilityStatus === 'excluded');
  const personal = relevant.filter((m) => PERSONAL_INSTRUMENTS.has(m.instrumentType));
  // Företagarspåret (F-EGEN): den som driver eget har lovats genomlysning av
  // företagsstöden. De får en egen sektion och sammanfattas aldrig bort, även
  // när frågor återstår. Speglar core:s businessRelevantSlugs (F-BRANSCH:
  // basmängden + den deklarerade verksamhetssektorns branschstöd).
  const SECTOR_SLUGS: Record<string, string[]> = {
    culture: [
      'kulturradet-projektbidrag-musik', 'kulturradet-litteraturstod', 'filminstitutet-kortfilmsstod',
      'musikverket-projektbidrag', 'region-kulturstod', 'nordisk-kulturfond-projektstod',
      'konstnarsnamnden-kulturbryggan',
    ],
    environment: [
      'energimyndigheten-energieffektivisering', 'naturvardsverket-ladda-bilen-organisationer',
      'naturvardsverket-klimatklivet', 'energimyndigheten-industriklivet',
    ],
    innovation: ['vinnova-planeringsbidrag-eu'],
  };
  const declaredSector = facts['project.sector'];
  const BUSINESS_SLUGS = new Set([
    'af-stod-start-naringsverksamhet',
    'vinnova-innovativa-startups',
    'tillvaxtverket-affarsutvecklingscheckar',
    'tillvaxtverket-regionalt-investeringsstod',
    'jordbruksverket-startstod-unga',
    'jordbruksverket-investeringsstod',
    ...(typeof declaredSector === 'string' ? (SECTOR_SLUGS[declaredSector] ?? []) : []),
  ]);
  const isSelfEmployed = facts['person.selfEmployed'] === true;
  const businessForm = facts['person.businessForm'];
  const business = isSelfEmployed ? relevant.filter((m) => BUSINESS_SLUGS.has(m.slug)) : [];
  const excludedBusiness = isSelfEmployed ? excluded.filter((m) => BUSINESS_SLUGS.has(m.slug)) : [];
  const funding = relevant.filter((m) => !PERSONAL_INSTRUMENTS.has(m.instrumentType) && !(isSelfEmployed && BUSINESS_SLUGS.has(m.slug)));

  return (
    <div>
      <h1>{project?.title ?? t('m.projects')}</h1>
      {project?.intent && <p className="meta-line" style={{ marginBottom: '1rem' }}>”{project.intent}”</p>}
      {projects.length > 1 && (
        <p>
          {projects.map((p) => (
            <Link key={p.id} to={`/projekt/${p.id}`} style={{ marginInlineEnd: '1rem', fontWeight: p.id === projectId ? 700 : 400 }}>
              {p.title}
            </Link>
          ))}
        </p>
      )}

      {qOrder.length > 0 && (
        <div className="card" style={{ borderColor: 'var(--warning)' }}>
          <h2 style={{ marginBottom: '0.15rem' }}>{t('m.questionsLeft', { n: openQuestions.size })}</h2>
          <p className="meta-line" style={{ margin: '0 0 0.4rem' }}>
            {t('m.questionsMeta')}
            {openList.some(([k]) => !qOrder.includes(k)) ? t('m.questionsMore') : ''}
          </p>
          {qOrder.map((factPath) => {
            const meta = qMeta.current.get(factPath);
            if (!meta) return null;
            const val = facts[factPath];
            const isAnswered = typeof val === 'boolean';
            const stillNeeded = openQuestions.has(factPath);
            return (
              <div key={factPath} data-qstate={isAnswered ? 'answered' : stillNeeded ? 'open' : 'resolved'}
                style={{ margin: '0.75rem 0', opacity: isAnswered || !stillNeeded ? 0.62 : 1 }}>
                <div className="meta-line" style={{ fontSize: '0.78rem', textTransform: 'uppercase', letterSpacing: '0.03em' }}>
                  {appliesLine(t, meta.forTitles)}
                </div>
                <strong>{meta.question}</strong>{' '}
                <InfoKnapp t={t} expanded={openInfo === factPath} onClick={() => setOpenInfo(openInfo === factPath ? null : factPath)} />
                {openInfo === factPath && <QuestionInfo t={t} details={meta.details} projectId={projectId} />}
                {isAnswered ? (
                  <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem', alignItems: 'center' }}>
                    <button className={val === true ? '' : 'secondary'} disabled={busy} onClick={() => val !== true && void changeAnswer(factPath, true)}>{t('ob.yes')}</button>
                    <button className={val === false ? '' : 'secondary'} disabled={busy} onClick={() => val !== false && void changeAnswer(factPath, false)}>{t('ob.no')}</button>
                    <span className="meta-line" role="status">{t('m.saved')}</span>
                  </div>
                ) : stillNeeded ? (
                  <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem' }}>
                    <button className="secondary" disabled={busy} onClick={() => void changeAnswer(factPath, true)}>{t('ob.yes')}</button>
                    <button className="secondary" disabled={busy} onClick={() => void changeAnswer(factPath, false)}>{t('ob.no')}</button>
                  </div>
                ) : (
                  <p className="meta-line" style={{ margin: '0.25rem 0 0' }}>
                    {t('m.noLongerNeeded', { titel: meta.forTitles[0] ?? '' })}
                  </p>
                )}
              </div>
            );
          })}
        </div>
      )}

      {answeredQuestions.size > 0 && (
        <details className="card" open id="dina-svar" style={{ padding: '0.9rem 1.35rem' }}>
          <summary style={{ cursor: 'pointer', fontWeight: 600 }}>
            {t('m.yourAnswers', { n: answeredQuestions.size })}
          </summary>
          <p className="guidance" style={{ marginTop: '0.5rem' }}>{t('m.changeRecalc')}</p>
          {[...answeredQuestions.entries()].map(([factPath, q]) => (
            <div key={factPath} style={{ margin: '0.75rem 0' }}>
              <div className="meta-line" style={{ fontSize: '0.78rem', textTransform: 'uppercase', letterSpacing: '0.03em' }}>
                {appliesLine(t, q.forTitles)}
              </div>
              <strong>{q.question}</strong>{' '}
              <InfoKnapp t={t} expanded={openInfo === `svar:${factPath}`} onClick={() => setOpenInfo(openInfo === `svar:${factPath}` ? null : `svar:${factPath}`)} />
              {openInfo === `svar:${factPath}` && <QuestionInfo t={t} details={q.details} projectId={projectId} />}
              <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem' }}>
                <button className={q.value === true ? '' : 'secondary'} disabled={busy} onClick={() => q.value !== true && void changeAnswer(factPath, true)}>{t('ob.yes')}</button>
                <button className={q.value === false ? '' : 'secondary'} disabled={busy} onClick={() => q.value !== false && void changeAnswer(factPath, false)}>{t('ob.no')}</button>
              </div>
            </div>
          ))}
        </details>
      )}

      {personal.length > 0 && (
        <div className="card">
          <h2>{t('m.personalTitle')}</h2>
          <p className="guidance">{t('m.personalGuidance')}</p>
          {personal.map((m) => (
            <div className="match-row" key={m.matchId}>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>{' '}
                  <LikelihoodBadge m={m} t={t} />
                </div>
                <div className="meta-line">
                  {m.authorityName} · <span className="badge info">{labels.instr(m.instrumentType)}</span>
                  {' · '}{t('m.lastVerified', { datum: formatDate(m.lastVerifiedAt) })}
                </div>
                {m.result.missingFacts.length > 0 && (
                  <div className="meta-line" style={{ color: 'var(--warning)' }}>
                    {t('m.toKnowForSure', { fragor: m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ') })}
                  </div>
                )}
                {m.eligibilityStatus === 'eligible' && (
                  <div style={{ marginTop: '0.4rem' }}>
                    <div className="meta-line">{t('m.eligibleNote')}</div>
                    <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.3rem', flexWrap: 'wrap' }}>
                      {m.applicationUrl && (
                        <a className="btn secondary" style={{ fontSize: '0.85rem', padding: '0.25rem 0.7rem' }} href={m.applicationUrl} target="_blank" rel="noreferrer">
                          {t('m.applyYourself')}
                        </a>
                      )}
                      <Link className="btn secondary" style={{ fontSize: '0.85rem', padding: '0.25rem 0.7rem' }} to={`/dokument/${projectId}?stod=${m.slug}`}>
                        {t('m.prepareApplication')}
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
          <h2>{t('m.businessTitle', { n: business.length + excludedBusiness.length })}</h2>
          {/* F-FÖRETAG (användarfynd): intaget och rapporten ska säga samma sak —
              för aktiebolag görs bolagets genomlysning separat, och stöden visas
              här med skäl i stället för att gömmas längre ner. */}
          <p className="guidance">
            {businessForm === 'sole_trader' ? t('m.bizSole') : businessForm === 'limited_company' ? t('m.bizAb') : t('m.bizUnknown')}
          </p>
          {business.map((m) => (
            <div className="match-row" key={m.matchId}>
              <div style={{ flex: 1 }}>
                <div>
                  <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>{' '}
                  <LikelihoodBadge m={m} t={t} />
                </div>
                <div className="meta-line">
                  {m.authorityName} · <span className="badge info">{labels.instr(m.instrumentType)}</span>
                </div>
                {m.result.missingFacts.length > 0 && (
                  <div className="meta-line" style={{ color: 'var(--warning)' }}>
                    {t('m.toKnowForSure', { fragor: m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ') })}
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
                  <span className="badge">{t('m.notMeetBadge')}</span>
                </div>
                <div className="meta-line">
                  {(m.result.excludedBy ?? []).map((e) => e.description).join(' · ') || t('m.notMeetFallback')}
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
              {t('m.summarisedNone', { n: summarised })}
            </p>
          ) : null;
        }
        return (
      <div className="card">
        <h2>{personal.length > 0 ? t('m.fundingTitle', { n: shownFunding.length }) : t('m.suitableTitle', { n: shownFunding.length })}</h2>
        {relevant.length === 0 && <p className="meta-line">{t('m.noMatches')}</p>}
        {personal.length > 0 && summarised > 0 && (
          <p className="guidance">{t('m.summarisedHidden', { n: summarised })}</p>
        )}
        {shownFunding.map((m) => (
          <div className="match-row" key={m.matchId}>
            <div className="match-score">
              <div className="n">{m.score}</div>
              <div className="of">{t('m.of100')}</div>
            </div>
            <div style={{ flex: 1 }}>
              <div>
                <Link to={`/stod/${m.slug}?projekt=${projectId}`} style={{ fontWeight: 600 }}>{m.title}</Link>
              </div>
              <div className="meta-line">
                {m.authorityName} · <span className="badge info">{labels.instr(m.instrumentType)}</span>{' '}
                <span className={`badge ${labels.elig(m.eligibilityStatus).tone}`}>
                  {labels.elig(m.eligibilityStatus).label}
                </span>
                {m.amountNote ? <> · {m.amountNote}</> : m.maxAmountMinor ? <> · {t('m.upTo', { belopp: formatSek(m.maxAmountMinor) })}</> : null}
              </div>
              <div className="meta-line">
                {m.closesAt
                  ? t('m.closes', { datum: formatDate(m.closesAt) })
                  : m.deadlineModel === 'rolling'
                    ? t('m.rolling')
                    : t('m.nextRound')}
                {' · '}{t('m.lastVerified', { datum: formatDate(m.lastVerifiedAt) })}
              </div>
              {m.result.missingFacts.length > 0 && (
                <div className="meta-line" style={{ color: 'var(--warning)' }}>
                  {t('m.missing', { fragor: m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ') })}
                </div>
              )}
              {m.result.missingEvidence.length > 0 && (
                <div className="meta-line">{t('m.evidenceNeeded', { lista: m.result.missingEvidence.map((e) => e.description).join(', ') })}</div>
              )}
            </div>
          </div>
        ))}
      </div>
        );
      })()}

      {personal.length === 0 && relevant.length > 1 && <StackPlanner projectId={projectId} t={t} />}

      {(() => {
        // Företagsstöd som inte uppfylls visas redan inne i företagssektionen.
        const excludedRest = isSelfEmployed ? excluded.filter((m) => !BUSINESS_SLUGS.has(m.slug)) : excluded;
        return excludedRest.length > 0 && (
        <div className="card">
          <h2>{t('m.excludedTitle', { n: excludedRest.length })}</h2>
          {excludedList(excludedRest, t)}
        </div>
        );
      })()}
      <p className="meta-line" style={{ margin: '1rem 0.25rem' }}>{t('m.disclaimer')}</p>

      <ReceiptLine projectId={projectId} t={t} />
    </div>
  );
}

/**
 * Kvittot för upplåsningen: förstaklass i kontot — visas här och finns
 * alltid under Konto & data → Mina köp. Ingen e-post inblandad.
 */
function ReceiptLine({ projectId, t }: { projectId: string; t: T }) {
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
      {t('m.receiptLine', { nr: receipt.receiptNumber })} <Link to="/konto">{t('m.myPurchases')}</Link>
      <details style={{ marginTop: '0.4rem' }}>
        <summary style={{ cursor: 'pointer' }}>{t('m.showReceipt')}</summary>
        <pre style={{ background: 'var(--card-bg, #f8f8f8)', padding: '0.8rem', borderRadius: 8, overflowX: 'auto', fontSize: '0.8rem' }}>{doc}</pre>
      </details>
    </div>
  );
}

/**
 * Rättighetsspråket: aldrig "du är berättigad" — alltid en bedömning.
 * "Hög sannolikhet" kräver att även viktande kriterier talar för (F3):
 * en familj med hög inkomst ser Majblomman som "möjlig", inte "hög".
 */
function LikelihoodBadge({ m, t }: { m: MatchRow; t: T }) {
  if (m.eligibilityStatus !== 'eligible') return <span className="badge warning">{t('m.badge.investigate')}</span>;
  const weightedAgainst = m.result.explanation.some((e) => e.kind === 'weighted' && e.outcome === 'fail');
  if (m.result.confidence === 'high' && !weightedAgainst) return <span className="badge success">{t('m.badge.high')}</span>;
  return <span className="badge success">{t('m.badge.possible')}</span>;
}

function excludedList(excluded: MatchRow[], t: T) {
  return (
    <>
      <p className="guidance">{t('m.excludedGuidance')}</p>
      {excluded.map((m) => (
        <div className="match-row" key={m.matchId}>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 600, color: 'var(--text-muted)' }}>{m.title}</div>
            <div className="meta-line">
              {m.result.excludedBy.length > 0
                ? m.result.excludedBy.map((e) => e.description).join(' · ')
                : m.result.missingFacts.length > 0
                  ? t('m.unansweredReq', { fragor: m.result.missingFacts.map((f) => f.question).slice(0, 2).join(' · ') })
                  : t('m.notMeetFallback')}
            </div>
          </div>
        </div>
      ))}
    </>
  );
}

/** Funding stack planner (§13): proposes a combination and flags what needs confirmation. */
function StackPlanner({ projectId, t }: { projectId: string; t: T }) {
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
      setError(err instanceof ApiError ? err.message : t('m.stackError'));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="card">
      <h2>{t('m.stackTitle')}</h2>
      <p className="guidance">{t('m.stackGuidance')}</p>
      <div style={{ display: 'flex', gap: '0.6rem', alignItems: 'end', flexWrap: 'wrap' }}>
        <div>
          <label>{t('m.ownContribution')}</label>
          <input type="number" min={0} value={own} onChange={(e) => setOwn(e.target.value)} placeholder="0" />
        </div>
        <button disabled={busy} onClick={compute}>{t('m.propose')}</button>
      </div>
      {error && <div className="alert error">{error}</div>}
      {plan && (
        <div style={{ marginTop: '1rem' }}>
          <table className="data">
            <thead><tr><th>{t('m.thSupport')}</th><th>{t('m.thPlanned')}</th><th>{t('m.thCombo')}</th></tr></thead>
            <tbody>
              {plan.items.map((i) => (
                <tr key={i.opportunityId}>
                  <td>{i.title}</td>
                  <td>{formatSek(i.plannedContributionMinor)}</td>
                  <td>
                    {i.compatibility === 'compatible' && <span className="badge success">{t('m.comboCompatible')}</span>}
                    {i.compatibility === 'requires_confirmation' && (
                      <span className="badge warning" title={i.compatibilityNote}>{t('m.comboConfirm')}</span>
                    )}
                    {i.compatibility === 'potentially_overlapping' && (
                      <span className="badge warning" title={i.compatibilityNote}>{t('m.comboOverlap')}</span>
                    )}
                  </td>
                </tr>
              ))}
              <tr>
                <td style={{ fontWeight: 600 }}>{t('m.ownRow')}</td>
                <td>{formatSek(plan.ownContributionMinor)}</td>
                <td />
              </tr>
              <tr>
                <td style={{ fontWeight: 700 }}>{t('m.coveredRow')}</td>
                <td style={{ fontWeight: 700 }}>{t('m.coveredOf', { tackt: formatSek(plan.coveredMinor), total: formatSek(plan.totalBudgetMinor) })}</td>
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
