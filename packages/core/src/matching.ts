/**
 * Layered match engine (§11–12).
 *
 * Match = eligibility gate + weighted strategic fit + evidence readiness
 *         + execution readiness.
 *
 * Deterministic and reproducible: given the same facts, criteria versions and
 * reference date, the result is identical. Semantic similarity can inform
 * discovery, but can NEVER override a deterministic exclusion — this engine
 * only consumes structured criteria.
 */

import type { EligibilityStatus, MatchConfidence } from './types.js';
import { evaluateAll, type CriterionDef, type CriterionResult } from './criteria.js';

export interface EvidenceRequirement {
  id: string;
  /** e.g. 'cv', 'budget', 'partner_letter', 'annual_report' */
  kind: string;
  description: string;
  mandatory: boolean;
}

export interface MatchInput {
  criteria: CriterionDef[];
  facts: Record<string, unknown> & object;
  evidenceRequirements: EvidenceRequirement[];
  /** Evidence kinds the applicant already has in the vault. */
  availableEvidenceKinds: string[];
  /** ISO date of evaluation — makes results reproducible. */
  referenceDate: string;
  deadline?: string | null;
  /** Rough preparation effort in working days, from the opportunity metadata. */
  estimatedEffortDays?: number;
  /** How fresh the underlying rule data is. */
  lastVerifiedAt?: string | null;
}

export interface MatchExplanationItem {
  criterionId: string;
  description: string;
  outcome: 'pass' | 'fail' | 'unknown';
  kind: 'hard' | 'mandatory' | 'weighted';
  weight: number;
}

export interface MissingFact {
  factPath: string;
  question: string;
  criterionId: string;
}

export interface MatchResultComputed {
  eligibilityStatus: EligibilityStatus;
  /** 0–100. Zero when excluded. */
  score: number;
  confidence: MatchConfidence;
  fitScore: number;            // 0–100 over weighted criteria
  evidenceReadiness: number;   // 0–100
  executionReadiness: number;  // 0–100
  mandatoryPassRate: number;   // 0–1 over *known* mandatory criteria
  explanation: MatchExplanationItem[];
  missingFacts: MissingFact[];
  missingEvidence: EvidenceRequirement[];
  excludedBy: MatchExplanationItem[];
  daysToDeadline: number | null;
}

function daysBetween(fromIso: string, toIso: string): number {
  const from = Date.parse(fromIso);
  const to = Date.parse(toIso);
  return Math.floor((to - from) / 86_400_000);
}

function toExplanation(r: CriterionResult): MatchExplanationItem {
  return {
    criterionId: r.criterion.id,
    description: r.criterion.description,
    outcome: r.outcome,
    kind: r.criterion.kind,
    weight: r.criterion.weight ?? 1,
  };
}

export function computeMatch(input: MatchInput): MatchResultComputed {
  const results = evaluateAll(input.criteria, input.facts as never);

  const hard = results.filter((r) => r.criterion.kind === 'hard');
  const mandatory = results.filter((r) => r.criterion.kind === 'mandatory');
  const weighted = results.filter((r) => r.criterion.kind === 'weighted');

  const daysToDeadline = input.deadline ? daysBetween(input.referenceDate, input.deadline) : null;

  // Layer 1 — hard exclusions. A failed hard criterion or a closed deadline excludes.
  const excludedBy = hard.filter((r) => r.outcome === 'fail').map(toExplanation);
  const deadlineClosed = daysToDeadline !== null && daysToDeadline < 0;

  const missingFacts: MissingFact[] = results
    .filter((r) => r.outcome === 'unknown')
    .map((r) => ({
      factPath: r.criterion.factPath,
      question: r.criterion.intakeQuestion ?? r.criterion.description,
      criterionId: r.criterion.id,
    }));

  const missingEvidence = input.evidenceRequirements.filter(
    (e) => e.mandatory && !input.availableEvidenceKinds.includes(e.kind),
  );

  const explanation = results.map(toExplanation);

  if (excludedBy.length > 0 || deadlineClosed) {
    if (deadlineClosed) {
      explanation.push({
        criterionId: '_deadline',
        description: 'Ansökningsperioden är stängd',
        outcome: 'fail',
        kind: 'hard',
        weight: 1,
      });
      excludedBy.push(explanation[explanation.length - 1]!);
    }
    return {
      eligibilityStatus: 'excluded',
      score: 0,
      confidence: 'high',
      fitScore: 0,
      evidenceReadiness: 0,
      executionReadiness: 0,
      mandatoryPassRate: 0,
      explanation,
      missingFacts,
      missingEvidence,
      excludedBy,
      daysToDeadline,
    };
  }

  // Layer 2 — mandatory criteria over known facts.
  const mandatoryKnown = mandatory.filter((r) => r.outcome !== 'unknown');
  const mandatoryFailed = mandatoryKnown.filter((r) => r.outcome === 'fail');
  const mandatoryUnknown = mandatory.filter((r) => r.outcome === 'unknown');
  const hardUnknown = hard.filter((r) => r.outcome === 'unknown');
  const mandatoryPassRate =
    mandatoryKnown.length === 0 ? 1 : (mandatoryKnown.length - mandatoryFailed.length) / mandatoryKnown.length;

  let eligibilityStatus: EligibilityStatus;
  if (mandatoryFailed.length > 0) {
    // A failed mandatory criterion is an exclusion in practice.
    eligibilityStatus = 'excluded';
  } else if (mandatoryUnknown.length > 0 || hardUnknown.length > 0) {
    eligibilityStatus = 'unknown';
  } else {
    eligibilityStatus = 'eligible';
  }

  if (eligibilityStatus === 'excluded') {
    return {
      eligibilityStatus,
      score: 0,
      confidence: 'high',
      fitScore: 0,
      evidenceReadiness: 0,
      executionReadiness: 0,
      mandatoryPassRate,
      explanation,
      missingFacts,
      missingEvidence,
      excludedBy: mandatoryFailed.map(toExplanation),
      daysToDeadline,
    };
  }

  // Layer 3 — weighted strategic fit. Unknown weighted criteria count as 0 fit
  // (not as failure) so missing optional facts lower the score without excluding.
  const totalWeight = weighted.reduce((s, r) => s + (r.criterion.weight ?? 1), 0);
  const passedWeight = weighted
    .filter((r) => r.outcome === 'pass')
    .reduce((s, r) => s + (r.criterion.weight ?? 1), 0);
  const fitScore = totalWeight === 0 ? 100 : Math.round((passedWeight / totalWeight) * 100);

  // Layer 4 — evidence completeness.
  const mandatoryEvidence = input.evidenceRequirements.filter((e) => e.mandatory);
  const evidenceReadiness =
    mandatoryEvidence.length === 0
      ? 100
      : Math.round(
          (mandatoryEvidence.filter((e) => input.availableEvidenceKinds.includes(e.kind)).length /
            mandatoryEvidence.length) *
            100,
        );

  // Layer 5 — execution readiness: can this realistically be submitted in time?
  let executionReadiness = 100;
  if (daysToDeadline !== null) {
    const effort = input.estimatedEffortDays ?? 5;
    if (daysToDeadline < effort) executionReadiness = 20;
    else if (daysToDeadline < effort * 2) executionReadiness = 60;
    else executionReadiness = 100;
  }

  // Composite. Eligibility gate passed → base 40, then fit 35, evidence 15, execution 10.
  const eligibilityBase = eligibilityStatus === 'eligible' ? 40 : 40 * mandatoryPassRateKnownShare(mandatory);
  const score = Math.round(
    eligibilityBase + (fitScore / 100) * 35 + (evidenceReadiness / 100) * 15 + (executionReadiness / 100) * 10,
  );

  const unknownShare =
    input.criteria.length === 0 ? 0 : missingFacts.length / input.criteria.length;
  const confidence: MatchConfidence =
    eligibilityStatus === 'eligible' && unknownShare === 0
      ? 'high'
      : unknownShare < 0.34
        ? 'medium'
        : 'low';

  return {
    eligibilityStatus,
    score: Math.min(100, Math.max(0, score)),
    confidence,
    fitScore,
    evidenceReadiness,
    executionReadiness,
    mandatoryPassRate,
    explanation,
    missingFacts,
    missingEvidence,
    excludedBy: [],
    daysToDeadline,
  };
}

/** Share of mandatory criteria that are known — dampens the base for 'unknown' status. */
function mandatoryPassRateKnownShare(mandatory: CriterionResult[]): number {
  if (mandatory.length === 0) return 1;
  const known = mandatory.filter((r) => r.outcome !== 'unknown').length;
  return 0.5 + 0.5 * (known / mandatory.length);
}
