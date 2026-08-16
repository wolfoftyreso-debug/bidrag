/**
 * Application case service: creation with immutable opportunity snapshots,
 * validation (schema + budget + attachments), and guarded state transitions
 * with audit logging.
 */
import { and, eq, sql } from 'drizzle-orm';
import {
  EXTERNAL_EVIDENCE_KINDS,
  answerLanguageFindings,
  repetitionFindings,
  assertTransition,
  evaluateAll,
  findNumericConflicts,
  findPeriodConflicts,
  isValidSwedishOrgNumber,
  prefillFromCanonical,
  validateAnswers,
  validateBudget,
  type CriterionDef,
  type Answers,
  type AnswerValue,
  type ApplicationSchemaDef,
  type ApplicationState,
  type BudgetFinancing,
  type BudgetLine,
  type BudgetRule,
  type EvidenceRequirement,
  type FieldValidationIssue,
} from '@bidrag/core';
import { db } from '../db/client.ts';
import {
  applicantProfiles,
  applicationCases,
  applicationSchemas,
  budgetLines,
  canonicalAnswers,
  caseDocuments,
  documents,
  fundingOpportunities,
  matches,
  projects,
  reviewItems,
  ruleVersions,
} from '../db/schema.ts';
import { audit } from '../audit.ts';

export interface CaseValidation {
  fieldIssues: FieldValidationIssue[];
  budgetFindings: { ruleId: string; severity: string; message: string }[];
  missingAttachments: { kind: string; description: string }[];
  ready: boolean;
}

// ── Granskningsläget (Application Intelligence §30–31) ───────────────────────

export type GapSeverity = 'CRITICAL' | 'HIGH' | 'MEDIUM' | 'LOW';

export interface ReviewGap {
  id: string;
  severity: GapSeverity;
  area: 'eligibility' | 'fields' | 'evidence' | 'budget' | 'deadline' | 'consistency' | 'coverage' | 'language';
  message: string;
  /** Vad som stänger luckan. */
  action: string;
  /**
   * §5-stoppregeln: bristen kräver en faktisk förändring i omständigheterna —
   * den kan och ska inte "skrivas runt" med bättre text.
   */
  requiresFactualChange: boolean;
}

/**
 * Evaluation matrix light (§7): en rad per kriterium ur den frysta
 * regelversionen, med utfall, icke-kompensatorisk märkning (hard/mandatory
 * kan aldrig vägas upp av styrkor någon annanstans) och evidensnivå.
 * E-nivåerna följer spec §10 — i v1 kan systemet skilja E0 (obesvarat) från
 * E1 (sökandens eget svar); E2 (dokumenterat per kriterium) kräver kurerad
 * kriterium↔bilaga-koppling och är därför aldrig något systemet påstår.
 */
export interface CriterionAssessment {
  criterionId: string;
  description: string;
  kind: 'hard' | 'mandatory' | 'weighted';
  outcome: 'pass' | 'fail' | 'unknown';
  /** Icke-kompensatorisk: svaghet här kan inte vägas upp av andra styrkor. */
  nonCompensatory: boolean;
  /**
   * Var bevisas detta? E0 = obesvarat, E1 = sökandens eget svar,
   * E2 = styrkt av bifogat eget dokument enligt kurerad koppling,
   * E3 = styrkt av bifogat dokument utfärdat av extern part (inbjudan,
   * partnerintyg, läkarintyg) — aldrig äkthetskontrollerat (det vore E4,
   * som inte finns och aldrig påstås).
   */
  evidenceLevel: 'E0' | 'E1' | 'E2' | 'E3';
}

export interface CaseReview {
  overallStatus: 'READY_FOR_SUBMISSION' | 'NOT_READY';
  eligibility: {
    status: 'PASS' | 'FAIL' | 'UNKNOWN';
    excludedBy: { description: string }[];
    missingFacts: { question: string }[];
  };
  fields: { issues: FieldValidationIssue[] };
  evidence: { kind: string; description: string; status: 'ATTACHED' | 'MISSING' }[];
  budget: {
    findings: { ruleId: string; severity: string; message: string }[];
    totalMinor: number;
    financingTotalMinor: number;
    requestedMinor: number;
  };
  deadline: { deadlineAt: string | null; daysLeft: number | null; passed: boolean };
  /** Evaluation matrix light (§7): kriterierna ur den frysta regelversionen. */
  criteria: CriterionAssessment[];
  /**
   * Intern kvalitetsindikator (§8). Märkningen är obligatorisk: detta är
   * "styrkan i tillgängligt beslutsunderlag relativt publicerade krav" —
   * ALDRIG en prognos om myndighetens beslut.
   */
  internalEstimate: { label: 'INTERNAL_ESTIMATE'; fitScore: number | null; explanation: string };
  /** Dubbelfinansiering (§18): CLEAR / POTENTIAL_OVERLAP / HIGH_RISK. */
  doubleFunding: { status: 'CLEAR' | 'POTENTIAL_OVERLAP' | 'HIGH_RISK'; notes: string[] };
  /**
   * Statsstöd (§19): utan kurerade statsstödsuppgifter gissar systemet
   * aldrig — personliga ersättningar är NOT_APPLICABLE, allt annat flaggas
   * STATE_AID_UNKNOWN tills uppgifterna är kurerade.
   */
  stateAid: { status: 'NOT_APPLICABLE' | 'STATE_AID_UNKNOWN'; note: string };
  /**
   * Diligence v1 (§23–24): det en handläggare sannolikt vill kontrollera
   * eller begära komplettering om — informativt, blockerar inte.
   */
  likelyComplementRequests: string[];
  /** Prioriterad åtgärdslista, allvarligast först. */
  gaps: ReviewGap[];
}

const SEVERITY_ORDER: GapSeverity[] = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];

/**
 * Deterministisk helhetsgranskning av en ansökan inför inlämning:
 * behörighet (matchmotorns trevärdesbedömning — UNKNOWN blir aldrig ett
 * positivt antagande), obligatoriska fält, obligatorisk bevisning, budgetens
 * matematik och regelefterlevnad samt deadline. Utfallet är READY_FOR_-
 * SUBMISSION eller NOT_READY med en prioriterad åtgärdslista. En FAIL på ett
 * hårt behörighetskrav flaggas som något som kräver ändrade omständigheter —
 * systemet försöker aldrig "skriva runt" den.
 */
export async function reviewCase(caseRow: typeof applicationCases.$inferSelect): Promise<CaseReview> {
  const validation = await validateCase(caseRow);
  const gaps: ReviewGap[] = [];

  // Behörighet ur senaste matchningen för projekt + stöd.
  const [matchRow] = await db
    .select({ result: matches.result })
    .from(matches)
    .where(and(eq(matches.projectId, caseRow.projectId), eq(matches.opportunityId, caseRow.opportunityId)))
    .limit(1);
  const matchResult = matchRow?.result as
    | { eligibilityStatus?: string; excludedBy?: { description: string }[]; missingFacts?: { question: string }[] }
    | undefined;
  const eligibilityStatus: 'PASS' | 'FAIL' | 'UNKNOWN' =
    matchResult?.eligibilityStatus === 'eligible' ? 'PASS' : matchResult?.eligibilityStatus === 'excluded' ? 'FAIL' : 'UNKNOWN';
  const excludedBy = matchResult?.excludedBy ?? [];
  const missingFacts = matchResult?.missingFacts ?? [];

  if (eligibilityStatus === 'FAIL') {
    for (const e of excludedBy.length > 0 ? excludedBy : [{ description: 'Ett obligatoriskt villkor är inte uppfyllt.' }]) {
      gaps.push({
        id: 'eligibility-fail',
        severity: 'CRITICAL',
        area: 'eligibility',
        message: `Behörighetskrav ej uppfyllt: ${e.description}`,
        action:
          'Kravet kan inte lösas med bättre text — det kräver att omständigheterna faktiskt ändras. Kontrollera villkoret hos finansiären innan du går vidare.',
        requiresFactualChange: true,
      });
    }
  } else if (eligibilityStatus === 'UNKNOWN') {
    // Revisionsfynd K1: ett obesvarat behörighetskrav får aldrig passera
    // submission-gaten — UNKNOWN är blockerande tills frågan är besvarad.
    for (const f of missingFacts.slice(0, 5)) {
      gaps.push({
        id: 'eligibility-unknown',
        severity: 'HIGH',
        area: 'eligibility',
        message: `Obesvarad behörighetsfråga: ${f.question}`,
        action: 'Besvara frågan i analysen — ett obesvarat krav räknas aldrig som uppfyllt vid inlämning.',
        requiresFactualChange: false,
      });
    }
  }

  // Deadline: en passerad ansökningsperiod går inte att åtgärda med text.
  const deadlineAt = caseRow.deadlineAt ? new Date(caseRow.deadlineAt).toISOString() : null;
  const daysLeft = caseRow.deadlineAt
    ? Math.floor((new Date(caseRow.deadlineAt).getTime() - Date.now()) / 86_400_000)
    : null;
  const deadlinePassed = daysLeft !== null && daysLeft < 0;
  if (deadlinePassed) {
    gaps.push({
      id: 'deadline-passed',
      severity: 'CRITICAL',
      area: 'deadline',
      message: 'Ansökningsperioden har passerat.',
      action: 'Kontrollera om en ny ansökningsomgång öppnar, eller välj ett annat stöd.',
      requiresFactualChange: true,
    });
  }

  for (const a of validation.missingAttachments) {
    gaps.push({
      id: `evidence-${a.kind}`,
      severity: 'CRITICAL',
      area: 'evidence',
      message: `Obligatorisk bilaga saknas: ${a.description}`,
      action: 'Ladda upp dokumentet i dokumentvalvet och koppla det till ansökan.',
      requiresFactualChange: false,
    });
  }
  for (const i of validation.fieldIssues) {
    gaps.push({
      id: `field-${i.fieldKey}`,
      severity: 'HIGH',
      area: 'fields',
      message: i.message,
      action: 'Fyll i fältet i ansökningsformuläret.',
      requiresFactualChange: false,
    });
  }
  for (const f of validation.budgetFindings) {
    // Revisionsfynd K2: finansiering ≠ budget är en matematisk motsägelse åt
    // BÅDA hållen — även överfinansiering blockerar inlämning.
    const blocking = f.severity === 'error' || f.ruleId === '_financing_balance';
    gaps.push({
      id: `budget-${f.ruleId}`,
      severity: blocking ? 'HIGH' : 'MEDIUM',
      area: 'budget',
      message: f.message,
      action: blocking
        ? 'Justera budgetposterna eller finansieringen så att beloppen stämmer matematiskt.'
        : 'Kontrollera posten — en varning hindrar inte inlämning men kan leda till kompletteringskrav.',
      requiresFactualChange: false,
    });
  }

  const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, caseRow.id));
  const totalMinor = lines.reduce((s, l) => s + Math.round(l.quantity * l.unitCostMinor), 0);
  const financing = (caseRow.financing as BudgetFinancing | null) ?? {
    requestedMinor: 0,
    ownContributionMinor: 0,
    otherFundingMinor: 0,
    inKindMinor: 0,
  };
  const financingTotalMinor =
    financing.requestedMinor + financing.ownContributionMinor + financing.otherFundingMinor + financing.inKindMinor;

  // Revisionsfynd K2: sökt stöd som ensamt överstiger hela budgeten är en
  // stödandel över 100 % — en motsägelse oavsett om stödet saknar explicit
  // andelsregel.
  if (totalMinor > 0 && financing.requestedMinor > totalMinor) {
    gaps.push({
      id: 'budget-requested-exceeds-total',
      severity: 'HIGH',
      area: 'budget',
      message: `Sökt belopp (${(financing.requestedMinor / 100).toLocaleString('sv-SE')} kr) överstiger hela projektbudgeten (${(totalMinor / 100).toLocaleString('sv-SE')} kr).`,
      action: 'Sänk sökt belopp eller komplettera budgetposterna — stödandelen kan inte överstiga 100 %.',
      requiresFactualChange: false,
    });
  }

  const schema = await getCaseSchema(caseRow);

  // Revisionsfynd K3 (fail-safe §18): när stödet saknar digitaliserat
  // ansökningsformulär kan granskningen inte verifiera fälten — det sägs
  // öppet och blockerar, i stället för att tyst godkänna en tom ansökan.
  if (!schema) {
    gaps.push({
      id: 'coverage-no-schema',
      severity: 'HIGH',
      area: 'coverage',
      message: 'Ansökningsformuläret för det här stödet är inte digitaliserat i systemet — granskningen kan inte verifiera att alla obligatoriska fält är besvarade.',
      action: 'Fyll i ansökan hos finansiären enligt deras formulär. Använd granskningens övriga punkter (behörighet, bilagor, budget) som checklista.',
      requiresFactualChange: false,
    });
  }

  // Konsistensmotor v1 (§11–12): sifferpåståenden korsjämförs över fälten,
  // och sökt belopp i formuläret jämförs mot finansieringsplanen.
  const answers = caseRow.answers as Record<string, unknown>;
  for (const c of findNumericConflicts(answers)) {
    gaps.push({
      id: `consistency-${c.unit}`,
      severity: 'MEDIUM',
      area: 'consistency',
      message: c.message,
      action: `Rätta uppgifterna så att samma antal ${c.unit} anges överallt (${c.values.map((v) => `"${v.snippet}"`).join(' · ')}).`,
      requiresFactualChange: false,
    });
  }
  // Periodkonsistens (red team §9 claim propagation): månader i fritexten som
  // ligger utanför den angivna projektperioden är sannolikt kvarglömda efter en
  // periodändring. Flaggas rådgivande — texten eller perioden ska uppdateras.
  const periodField = (schema?.fields ?? []).find((f) => f.type === 'date_range');
  const periodAnswer = periodField ? answers[periodField.key] : undefined;
  if (Array.isArray(periodAnswer) && typeof periodAnswer[0] === 'string' && typeof periodAnswer[1] === 'string') {
    if (periodAnswer[0] > periodAnswer[1]) {
      gaps.push({
        id: 'consistency-period-order',
        severity: 'HIGH',
        area: 'consistency',
        message: `Projektperiodens slut (${periodAnswer[1]}) ligger före dess start (${periodAnswer[0]}).`,
        action: 'Rätta start- och slutdatum så att perioden är möjlig.',
        requiresFactualChange: false,
      });
    } else {
      for (const c of findPeriodConflicts(answers, { start: periodAnswer[0], end: periodAnswer[1] }).slice(0, 3)) {
        gaps.push({
          id: `consistency-period-${c.month}`,
          severity: 'MEDIUM',
          area: 'consistency',
          message: `Texten nämner ${c.month} ("${c.snippet}") men projektperioden är ${periodAnswer[0]}–${periodAnswer[1]}.`,
          action: 'Uppdatera texten eller perioden så att de stämmer överens — kvarglömda datum efter en ändring är en vanlig kompletteringsorsak.',
          requiresFactualChange: false,
        });
      }
    }
  }

  // Partnermotsägelse (§12, CONFLICT-principen): formuläret säger att en
  // bekräftad partner saknas medan fritexten talar om en partner. Systemet
  // väljer aldrig åt användaren — det flaggar och ber om rättning.
  const partnerBool = (schema?.fields ?? []).find(
    (f) => f.type === 'boolean' && /partner/i.test(`${f.key} ${f.label ?? ''}`),
  );
  if (partnerBool && answers[partnerBool.key] === false) {
    const mention = Object.entries(answers).find(
      ([key, v]) => key !== partnerBool.key && typeof v === 'string' && /partner/i.test(v),
    );
    if (mention) {
      gaps.push({
        id: 'consistency-partner',
        severity: 'MEDIUM',
        area: 'consistency',
        message: `Formuläret anger att bekräftad partner saknas, men texten i fältet ${mention[0]} nämner en partner.`,
        action: 'Kontrollera vilket som stämmer: har ni en bekräftad partner anger du det i formuläret, annars bör texten inte tala om en partner som fanns.',
        requiresFactualChange: false,
      });
    }
  }

  // Ödmjukhetsprotokollet (konstitutionen §12–13, PASS 8): ogrundade superlativ
  // och kvantifierade utfallslöften i fritextsvaren flaggas rådgivande (MEDIUM,
  // aldrig blockerande) — ett styrkt starkt påstående får stå kvar, och texten
  // skrivs aldrig om av systemet. Max fem flaggor så att listan förblir läsbar.
  for (const f of answerLanguageFindings(answers).slice(0, 5)) {
    gaps.push({
      id: `language-${f.kind.toLowerCase()}-${f.fieldKey}`,
      severity: 'MEDIUM',
      area: 'language',
      message: `Formuleringen "${f.term}" i fältet ${f.fieldKey} kommer att granskas kritiskt: ${f.excerpt}`,
      action: f.suggestion,
      requiresFactualChange: false,
    });
  }
  // Korrekturvarvet: samma mening i flera fält (kvarglömt klipp-och-klistra)
  // eller dubblerade ord. Rådgivande — texten ägs av sökanden.
  const joinedText = Object.values(answers).filter((v): v is string => typeof v === 'string').join('\n');
  for (const [i, f] of repetitionFindings(joinedText).slice(0, 3).entries()) {
    gaps.push({
      id: `language-repetition-${i}`,
      severity: 'MEDIUM',
      area: 'language',
      message: `Upprepning i ansökan: ${f.excerpt}`,
      action: f.suggestion,
      requiresFactualChange: false,
    });
  }

  const requestedField = (schema?.fields ?? []).find((f) => f.canonicalKey === 'project.requestedAmount');
  const requestedAnswer = requestedField ? answers[requestedField.key] : undefined;
  if (typeof requestedAnswer === 'number' && financing.requestedMinor > 0 && Math.round(requestedAnswer * 100) !== financing.requestedMinor) {
    gaps.push({
      id: 'consistency-requested-amount',
      severity: 'HIGH',
      area: 'consistency',
      message: `Sökt belopp i formuläret (${requestedAnswer.toLocaleString('sv-SE')} kr) stämmer inte med finansieringsplanen (${(financing.requestedMinor / 100).toLocaleString('sv-SE')} kr).`,
      action: 'Ange samma sökta belopp i formuläret och finansieringsplanen.',
      requiresFactualChange: false,
    });
  }

  const snapshot = caseRow.opportunitySnapshot as {
    ruleVersion?: { evidenceRequirements?: EvidenceRequirement[] } | null;
  };
  const required = (snapshot.ruleVersion?.evidenceRequirements ?? []).filter((e) => e.mandatory);
  const missingKinds = new Set(validation.missingAttachments.map((a) => a.kind));
  const evidence = required.map((e) => ({
    kind: e.kind,
    description: e.description,
    status: (missingKinds.has(e.kind) ? 'MISSING' : 'ATTACHED') as 'ATTACHED' | 'MISSING',
  }));

  // ── Evaluation matrix light (§7): kriterierna ur den FRYSTA regelversionen
  // utvärderas mot sökandens aktuella fakta — spårbart till exakt det
  // regelverk ansökan skapades under (§29).
  const [factsRow] = await db
    .select({
      projectFacts: projects.facts,
      profileFacts: applicantProfiles.facts,
      applicantType: applicantProfiles.applicantType,
      profileName: applicantProfiles.displayName,
      applicantCountry: applicantProfiles.country,
      applicantRegion: applicantProfiles.region,
      applicantMunicipality: applicantProfiles.municipality,
    })
    .from(projects)
    .leftJoin(applicantProfiles, eq(projects.profileId, applicantProfiles.id))
    .where(eq(projects.id, caseRow.projectId))
    .limit(1);
  // Samma faktabygge som matchningstjänsten: härledda applicant.*-fakta
  // ingår — annars blir behörighetskriterier felaktigt "obesvarade" här.
  const mergedFacts = {
    'applicant.type': factsRow?.applicantType ?? undefined,
    'applicant.country': factsRow?.applicantCountry ?? undefined,
    'applicant.region': factsRow?.applicantRegion ?? undefined,
    'applicant.municipality': factsRow?.applicantMunicipality ?? undefined,
    ...((factsRow?.profileFacts as Record<string, unknown>) ?? {}),
    ...((factsRow?.projectFacts as Record<string, unknown>) ?? {}),
  };
  const attachedForE2 = await db
    .select({ kind: documents.kind })
    .from(caseDocuments)
    .innerJoin(documents, eq(caseDocuments.documentId, documents.id))
    .where(eq(caseDocuments.caseId, caseRow.id));
  const attachedKindSet = new Set(attachedForE2.map((r) => r.kind));
  const frozenCriteria = ((caseRow.opportunitySnapshot as { ruleVersion?: { criteria?: CriterionDef[] } | null })
    .ruleVersion?.criteria ?? []) as CriterionDef[];
  const criteria: CriterionAssessment[] = evaluateAll(frozenCriteria, mergedFacts as never).map((r) => ({
    criterionId: r.criterion.id,
    description: r.criterion.description,
    kind: r.criterion.kind,
    outcome: r.outcome,
    nonCompensatory: r.criterion.kind !== 'weighted',
    // E0 = obesvarat. E1 = sökandens eget svar. E2/E3 = ett bifogat dokument
    // av en bilagetyp som enligt den KURERADE kopplingen styrker kriteriet —
    // E3 när bilagetypen är utfärdad av extern part (inbjudan, partnerintyg,
    // läkarintyg), annars E2. Aldrig en gissning; utan koppling stannar E1.
    evidenceLevel: ((): 'E0' | 'E1' | 'E2' | 'E3' => {
      if (r.outcome === 'unknown') return 'E0';
      const attached = (r.criterion.evidenceKinds ?? []).filter((k) => attachedKindSet.has(k));
      if (attached.length === 0) return 'E1';
      return attached.some((k) => EXTERNAL_EVIDENCE_KINDS.has(k)) ? 'E3' : 'E2';
    })(),
  }));

  // ── Intern kvalitetsindikator (§8) — obligatoriskt märkt, aldrig en prognos.
  const fitScore = typeof (matchResult as { fitScore?: number } | undefined)?.fitScore === 'number'
    ? (matchResult as { fitScore: number }).fitScore
    : null;
  const internalEstimate = {
    label: 'INTERNAL_ESTIMATE' as const,
    fitScore,
    explanation:
      'Intern indikator på styrkan i tillgängligt beslutsunderlag relativt de publicerade kraven — aldrig en prognos om myndighetens beslut.',
  };

  // ── Dubbelfinansiering (§18): känd motsägelse mot stödordningen blockerar;
  // parallella ansökningar i samma projekt rapporteras som möjlig överlappning.
  const oppSnapshot = (caseRow.opportunitySnapshot as { opportunity?: { excludesOtherPublicFunding?: boolean } | null }).opportunity;
  const dfNotes: string[] = [];
  let dfStatus: 'CLEAR' | 'POTENTIAL_OVERLAP' | 'HIGH_RISK' = 'CLEAR';
  if (oppSnapshot?.excludesOtherPublicFunding && financing.otherFundingMinor > 0) {
    dfStatus = 'HIGH_RISK';
    dfNotes.push(
      `Stödordningen tillåter inte annan offentlig finansiering, men finansieringsplanen anger ${(financing.otherFundingMinor / 100).toLocaleString('sv-SE')} kr i övrig finansiering.`,
    );
    gaps.push({
      id: 'double-funding-excluded',
      severity: 'HIGH',
      area: 'budget',
      message: dfNotes[dfNotes.length - 1]!,
      action:
        'Ta bort den andra offentliga finansieringen ur planen eller välj ett stöd som tillåter samfinansiering — uppgiften får aldrig döljas.',
      requiresFactualChange: true,
    });
  }
  const siblingCases = await db
    .select({ id: applicationCases.id, state: applicationCases.state, opportunityId: applicationCases.opportunityId })
    .from(applicationCases)
    .where(and(eq(applicationCases.projectId, caseRow.projectId), eq(applicationCases.tenantId, caseRow.tenantId)));
  const activeSiblings = siblingCases.filter((s) => s.id !== caseRow.id && !['SELECTED', 'WITHDRAWN', 'REJECTED'].includes(s.state));
  if (activeSiblings.length > 0 && dfStatus === 'CLEAR') {
    dfStatus = 'POTENTIAL_OVERLAP';
    dfNotes.push(
      `Projektet har ${activeSiblings.length} annan pågående ansökan — kontrollera att samma kostnader inte söks två gånger och redovisa annan sökt finansiering öppet.`,
    );
  }

  // ── Statsstöd (§19): utan kurerade uppgifter gissar systemet aldrig.
  const oppMeta = (caseRow.opportunitySnapshot as {
    opportunity?: { instrumentType?: string; nextReviewAt?: string | null } | null;
  }).opportunity;
  const PERSONAL_INSTRUMENTS = new Set(['social_benefit', 'educational_support']);
  const stateAid: CaseReview['stateAid'] =
    oppMeta?.instrumentType && PERSONAL_INSTRUMENTS.has(oppMeta.instrumentType) && factsRow?.applicantType === 'individual'
      ? {
          status: 'NOT_APPLICABLE',
          note: 'Personlig ersättning till privatperson — statsstödsreglerna aktualiseras inte.',
        }
      : {
          status: 'STATE_AID_UNKNOWN',
          note: 'Statsstödsuppgifter är inte kurerade för det här stödet. Kontrollera med finansiären om stödet omfattas av statsstödsregler (t.ex. de minimis) innan du räknar med beloppet.',
        };
  if (stateAid.status === 'STATE_AID_UNKNOWN') {
    gaps.push({
      id: 'state-aid-unknown',
      severity: 'MEDIUM',
      area: 'coverage',
      message: stateAid.note,
      action: 'Fråga finansiären eller läs utlysningens statsstödsavsnitt — systemet gissar aldrig i den här frågan.',
      requiresFactualChange: false,
    });
  }

  // ── Källkonflikt (§3): den officiella källan har ändrats sedan regelverket
  // kurerades och ändringen väntar på kuratorsgranskning ⇒ FLAGGA CONFLICT.
  // Systemet gissar aldrig när källorna pekar åt olika håll.
  const oppSourceId = (caseRow.opportunitySnapshot as { opportunity?: { sourceId?: string | null } | null }).opportunity?.sourceId ?? null;
  if (oppSourceId) {
    const pendingChanges = await db
      .select({ payload: reviewItems.payload })
      .from(reviewItems)
      .where(and(eq(reviewItems.kind, 'source_change'), eq(reviewItems.status, 'pending')));
    const conflict = pendingChanges.some((i) => (i.payload as { sourceId?: string }).sourceId === oppSourceId);
    if (conflict) {
      gaps.push({
        id: 'source-conflict',
        severity: 'MEDIUM',
        area: 'coverage',
        message:
          'CONFLICT: den officiella källan för det här stödet har ändrats sedan regelverket kurerades, och ändringen väntar på granskning — villkoren kan vara inaktuella.',
        action: 'Kontrollera villkoren direkt mot finansiärens aktuella utlysning innan du lämnar in.',
        requiresFactualChange: false,
      });
    }
  }

  // ── §12: organisationsnummer och namn — kända felkällor för formella avslag.
  const schemaFields = schema?.fields ?? [];
  const orgNrField = schemaFields.find((f) => f.canonicalKey === 'organisation.orgNumber');
  const orgNrAnswer = orgNrField ? answers[orgNrField.key] : undefined;
  if (typeof orgNrAnswer === 'string' && orgNrAnswer.trim() !== '' && !isValidSwedishOrgNumber(orgNrAnswer)) {
    gaps.push({
      id: 'consistency-orgnumber',
      severity: 'HIGH',
      area: 'consistency',
      message: `Organisationsnumret "${orgNrAnswer}" är inte giltigt (fel format eller kontrollsiffra).`,
      action: 'Kontrollera organisationsnumret mot registreringsbeviset — ett felaktigt nummer är en vanlig orsak till formellt avslag.',
      requiresFactualChange: false,
    });
  }
  const nameField = schemaFields.find((f) => f.canonicalKey === 'applicant.displayName');
  const nameAnswer = nameField ? answers[nameField.key] : undefined;
  const profileName = factsRow?.profileName?.trim();
  if (typeof nameAnswer === 'string' && nameAnswer.trim() !== '' && profileName && nameAnswer.trim().toLowerCase() !== profileName.toLowerCase()) {
    gaps.push({
      id: 'consistency-applicant-name',
      severity: 'MEDIUM',
      area: 'consistency',
      message: `Namnet i formuläret ("${nameAnswer.trim()}") skiljer sig från profilens ("${profileName}").`,
      action: 'Kontrollera vilket namn som är rätt — samma sökande ska anges överallt.',
      requiresFactualChange: false,
    });
  }

  // ── Källfärskhet (§18 fail-safe): en regelkälla äldre än sitt
  // omverifieringsdatum flaggas — villkoren kan ha ändrats.
  if (oppMeta?.nextReviewAt && Date.parse(oppMeta.nextReviewAt) < Date.now()) {
    gaps.push({
      id: 'source-stale',
      severity: 'MEDIUM',
      area: 'coverage',
      message: 'Regelverket för det här stödet har passerat sitt omverifieringsdatum — villkoren kan ha ändrats sedan de kurerades.',
      action: 'Kontrollera de angivna villkoren mot finansiärens aktuella utlysning innan du lämnar in.',
      requiresFactualChange: false,
    });
  }

  // ── Diligence v1 (§23–24): det en handläggare sannolikt begär komplettering
  // om. Informativt — döljs aldrig, blockerar inte.
  const likelyComplementRequests: string[] = [];
  for (const a of validation.missingAttachments) {
    likelyComplementRequests.push(`Handläggaren kommer att begära den obligatoriska bilagan: ${a.description}.`);
  }
  for (const c of criteria.filter((c) => c.nonCompensatory && c.outcome === 'pass' && c.evidenceLevel === 'E1').slice(0, 5)) {
    likelyComplementRequests.push(
      `"${c.description}" bygger på ditt eget svar (E1) — handläggaren kan begära underlag som styrker det.`,
    );
  }
  for (const g of gaps.filter((g) => g.area === 'consistency')) {
    likelyComplementRequests.push('Motstridiga uppgifter i ansökan leder ofta till en kompletteringsfråga — rätta dem före inlämning.');
    break;
  }

  gaps.sort((a, b) => SEVERITY_ORDER.indexOf(a.severity) - SEVERITY_ORDER.indexOf(b.severity));
  const blocking = gaps.some((g) => g.severity === 'CRITICAL' || g.severity === 'HIGH');

  return {
    overallStatus: blocking ? 'NOT_READY' : 'READY_FOR_SUBMISSION',
    eligibility: { status: eligibilityStatus, excludedBy, missingFacts },
    fields: { issues: validation.fieldIssues },
    evidence,
    budget: { findings: validation.budgetFindings, totalMinor, financingTotalMinor, requestedMinor: financing.requestedMinor },
    deadline: { deadlineAt, daysLeft, passed: deadlinePassed },
    criteria,
    internalEstimate,
    doubleFunding: { status: dfStatus, notes: dfNotes },
    stateAid,
    likelyComplementRequests,
    gaps,
  };
}

export async function createCase(opts: {
  tenantId: string;
  userId: string;
  projectId: string;
  opportunityId: string;
}): Promise<typeof applicationCases.$inferSelect> {
  const [opp] = await db
    .select()
    .from(fundingOpportunities)
    .where(eq(fundingOpportunities.id, opts.opportunityId))
    .limit(1);
  if (!opp || opp.status !== 'published') {
    throw Object.assign(new Error('opportunity not found'), { statusCode: 404 });
  }
  if (!opp.currentRuleVersionId) {
    throw Object.assign(new Error('opportunity has no published rules'), { statusCode: 422 });
  }
  const [rv] = await db.select().from(ruleVersions).where(eq(ruleVersions.id, opp.currentRuleVersionId)).limit(1);

  const [schemaRow] = await db
    .select()
    .from(applicationSchemas)
    .where(eq(applicationSchemas.opportunityId, opp.id))
    .orderBy(sql`${applicationSchemas.version} DESC`)
    .limit(1);

  // Prefill from the tenant's canonical answers — traceable per field (§34).
  let answers: Answers = {};
  let answerProvenance: Record<string, string> = {};
  if (schemaRow) {
    const canonicalRows = await db
      .select()
      .from(canonicalAnswers)
      .where(eq(canonicalAnswers.tenantId, opts.tenantId));
    const canonical: Record<string, AnswerValue> = {};
    for (const row of canonicalRows) canonical[row.canonicalKey] = row.value as AnswerValue;
    const prefilled = prefillFromCanonical(schemaRow.def as ApplicationSchemaDef, {}, canonical);
    answers = prefilled.answers;
    answerProvenance = Object.fromEntries(prefilled.prefilledKeys.map((k) => [k, 'canonical_prefill']));
  }

  // Immutable snapshot of what we knew at selection time (§23).
  const opportunitySnapshot = {
    capturedAt: new Date().toISOString(),
    opportunity: opp,
    ruleVersion: rv ?? null,
    schemaVersion: schemaRow?.version ?? null,
  };

  const [row] = await db
    .insert(applicationCases)
    .values({
      tenantId: opts.tenantId,
      projectId: opts.projectId,
      opportunityId: opp.id,
      ruleVersionId: opp.currentRuleVersionId,
      schemaId: schemaRow?.id ?? null,
      state: 'SELECTED',
      answers,
      answerProvenance,
      opportunitySnapshot,
      deadlineAt: opp.closesAt,
    })
    .returning();

  await audit({
    tenantId: opts.tenantId,
    actorType: 'user',
    actorUserId: opts.userId,
    action: 'application.created',
    entityType: 'application_case',
    entityId: row!.id,
    after: { opportunityId: opp.id, state: 'SELECTED' },
  });

  return row!;
}

export async function getCaseSchema(caseRow: typeof applicationCases.$inferSelect): Promise<ApplicationSchemaDef | null> {
  if (!caseRow.schemaId) return null;
  const [schemaRow] = await db
    .select()
    .from(applicationSchemas)
    .where(eq(applicationSchemas.id, caseRow.schemaId))
    .limit(1);
  return (schemaRow?.def as ApplicationSchemaDef) ?? null;
}

export async function validateCase(caseRow: typeof applicationCases.$inferSelect): Promise<CaseValidation> {
  const schema = await getCaseSchema(caseRow);
  const fieldIssues = schema ? validateAnswers(schema, caseRow.answers as Answers) : [];

  const lines = await db.select().from(budgetLines).where(eq(budgetLines.caseId, caseRow.id));
  const coreLines: BudgetLine[] = lines.map((l) => ({
    id: l.id,
    category: l.category,
    description: l.description,
    quantity: l.quantity,
    unitCostMinor: l.unitCostMinor,
    currency: l.currency,
  }));

  const snapshot = caseRow.opportunitySnapshot as { ruleVersion?: { budgetRules?: BudgetRule[]; evidenceRequirements?: EvidenceRequirement[] } | null };
  const budgetRules = snapshot.ruleVersion?.budgetRules ?? [];
  const evidenceRequirements = snapshot.ruleVersion?.evidenceRequirements ?? [];

  const financing = (caseRow.financing as BudgetFinancing | null) ?? {
    requestedMinor: 0,
    ownContributionMinor: 0,
    otherFundingMinor: 0,
    inKindMinor: 0,
  };
  const budgetFindings =
    coreLines.length > 0 ? validateBudget(coreLines, financing, budgetRules) : [];

  const attachedRows = await db
    .select({ kind: documents.kind })
    .from(caseDocuments)
    .innerJoin(documents, eq(caseDocuments.documentId, documents.id))
    .where(eq(caseDocuments.caseId, caseRow.id));
  const attachedKinds = new Set(attachedRows.map((r) => r.kind));
  const missingAttachments = evidenceRequirements
    .filter((e) => e.mandatory && !attachedKinds.has(e.kind))
    .map((e) => ({ kind: e.kind, description: e.description }));

  const ready =
    fieldIssues.length === 0 &&
    budgetFindings.filter((f) => f.severity === 'error').length === 0 &&
    missingAttachments.length === 0;

  return { fieldIssues, budgetFindings, missingAttachments, ready };
}

/**
 * Guarded state transition. Enforces the state machine and the transition
 * guards (receipts for SUBMITTED, validation for READY_TO_SUBMIT).
 */
export async function transitionCase(opts: {
  tenantId: string;
  userId: string | null;
  actorType: 'user' | 'system' | 'job';
  caseId: string;
  to: ApplicationState;
  /** Extra context recorded in the audit trail. */
  context?: Record<string, unknown>;
}): Promise<typeof applicationCases.$inferSelect> {
  const [caseRow] = await db
    .select()
    .from(applicationCases)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .limit(1);
  if (!caseRow) throw Object.assign(new Error('case not found'), { statusCode: 404 });

  const from = caseRow.state as ApplicationState;
  assertTransition(from, opts.to);

  if (opts.to === 'READY_TO_SUBMIT') {
    // Revisionsfynd K5: övergången vaktar på HELA granskningen — behörighet,
    // deadline, konsistens och täckning — inte bara fält/budget/bilagor. En
    // ansökan med olöst eller underkänd behörighet kan aldrig bli klar att
    // skicka in, oavsett hur komplett den ser ut i övrigt.
    const review = await reviewCase(caseRow);
    if (review.overallStatus !== 'READY_FOR_SUBMISSION') {
      throw Object.assign(new Error('application is not complete'), {
        statusCode: 422,
        validation: await validateCase(caseRow),
        review,
      });
    }
  }

  const patch: Record<string, unknown> = { state: opts.to, updatedAt: new Date() };
  if (opts.to === 'SUBMITTED') {
    // Freeze the exact submitted content (§80: preserve historical state).
    patch.submittedSnapshot = {
      submittedAt: new Date().toISOString(),
      answers: caseRow.answers,
      financing: caseRow.financing,
      opportunitySnapshot: caseRow.opportunitySnapshot,
    };
  }

  const [updated] = await db
    .update(applicationCases)
    .set(patch)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .returning();

  await audit({
    tenantId: opts.tenantId,
    actorType: opts.actorType,
    actorUserId: opts.userId,
    action: 'application.state_changed',
    entityType: 'application_case',
    entityId: opts.caseId,
    before: { state: from },
    after: { state: opts.to, ...opts.context },
  });

  return updated!;
}

/** Persist answers (only in editable states) and update canonical reuse store. */
export async function saveAnswers(opts: {
  tenantId: string;
  userId: string;
  caseId: string;
  answers: Answers;
}): Promise<typeof applicationCases.$inferSelect> {
  const [caseRow] = await db
    .select()
    .from(applicationCases)
    .where(and(eq(applicationCases.id, opts.caseId), eq(applicationCases.tenantId, opts.tenantId)))
    .limit(1);
  if (!caseRow) throw Object.assign(new Error('case not found'), { statusCode: 404 });

  const editable: ApplicationState[] = ['SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'ACTION_REQUIRED'];
  if (!editable.includes(caseRow.state as ApplicationState)) {
    throw Object.assign(new Error(`answers cannot be edited in state ${caseRow.state}`), { statusCode: 409 });
  }

  const merged: Answers = { ...(caseRow.answers as Answers), ...opts.answers };
  const provenance = { ...(caseRow.answerProvenance as Record<string, string>) };
  for (const key of Object.keys(opts.answers)) provenance[key] = `user:${opts.userId}`;

  const [updated] = await db
    .update(applicationCases)
    .set({ answers: merged, answerProvenance: provenance, updatedAt: new Date() })
    .where(eq(applicationCases.id, opts.caseId))
    .returning();

  // Update canonical answers for reuse across applications (§34) — the value
  // remains traceable to the case it came from and is never silently rewritten.
  const schema = await getCaseSchema(caseRow);
  if (schema) {
    for (const field of schema.fields) {
      if (!field.canonicalKey) continue;
      const value = opts.answers[field.key];
      if (value === undefined || value === null || value === '') continue;
      await db
        .insert(canonicalAnswers)
        .values({ tenantId: opts.tenantId, canonicalKey: field.canonicalKey, value, sourceCaseId: opts.caseId, updatedAt: new Date() })
        .onConflictDoUpdate({
          target: [canonicalAnswers.tenantId, canonicalAnswers.canonicalKey],
          set: { value, sourceCaseId: opts.caseId, updatedAt: new Date() },
        });
    }
  }

  await audit({
    tenantId: opts.tenantId,
    actorType: 'user',
    actorUserId: opts.userId,
    action: 'application.answers_updated',
    entityType: 'application_case',
    entityId: opts.caseId,
    after: { keys: Object.keys(opts.answers) },
  });

  return updated!;
}
