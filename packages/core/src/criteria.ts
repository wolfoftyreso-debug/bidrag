/**
 * Eligibility criterion DSL and evaluator.
 *
 * Every criterion is a deterministic predicate over applicant/project facts.
 * Criteria are data (stored, versioned, provenance-tracked) — never code.
 *
 * Three-valued logic: a criterion evaluates to pass / fail / unknown.
 * `unknown` means a required fact has not been collected, and is surfaced
 * to the user as "missing information", never hidden.
 */

import type { Facts, FactValue } from './types.js';

export type CriterionOp =
  | 'eq'
  | 'neq'
  | 'in'          // fact value is one of expected[]
  | 'not_in'
  | 'gte'
  | 'lte'
  | 'between'     // expected: [min, max]
  | 'includes'    // fact array includes expected scalar
  | 'intersects'  // fact array intersects expected[]
  | 'exists'      // fact has been collected (non-undefined, non-null)
  | 'is_true'
  | 'is_false';

export type CriterionKind =
  /** Layer 1 — failing means hard exclusion; unknown does NOT exclude. */
  | 'hard'
  /** Layer 2 — mandatory published criterion; all must pass for 'eligible'. */
  | 'mandatory'
  /** Layer 3 — weighted strategic fit; contributes to score, never gates. */
  | 'weighted';

export interface CriterionDef {
  id: string;
  kind: CriterionKind;
  /** Dot-path into the facts object, e.g. "project.countries". */
  factPath: string;
  op: CriterionOp;
  expected?: FactValue | [number, number];
  /** Weight for 'weighted' criteria (default 1). Ignored for gates. */
  weight?: number;
  /** Plain-language description shown in match explanations (Swedish-first). */
  description: string;
  /** Question to ask the user when the fact is missing (adaptive intake). */
  intakeQuestion?: string;
  /** Pointer into the provenance store: which source evidence backs this rule. */
  sourceRef?: string;
}

export type CriterionOutcome = 'pass' | 'fail' | 'unknown';

export interface CriterionResult {
  criterion: CriterionDef;
  outcome: CriterionOutcome;
  actual: FactValue | undefined;
}

export function getFact(facts: Facts, path: string): FactValue | undefined {
  return facts[path];
}

function asArray(v: FactValue): (string | number)[] {
  if (Array.isArray(v)) return v;
  if (v === null) return [];
  if (typeof v === 'boolean') return [];
  return [v];
}

export function evaluateCriterion(c: CriterionDef, facts: Facts): CriterionResult {
  const actual = getFact(facts, c.factPath);

  if (c.op === 'exists') {
    return { criterion: c, actual, outcome: actual !== undefined && actual !== null ? 'pass' : 'fail' };
  }

  if (actual === undefined) {
    return { criterion: c, actual, outcome: 'unknown' };
  }

  const expected = c.expected;
  let pass: boolean;

  switch (c.op) {
    case 'eq':
      pass = actual === expected;
      break;
    case 'neq':
      pass = actual !== expected;
      break;
    case 'in':
      pass = Array.isArray(expected) && (expected as (string | number)[]).some((e) => e === actual);
      break;
    case 'not_in':
      pass = Array.isArray(expected) && !(expected as (string | number)[]).some((e) => e === actual);
      break;
    case 'gte':
      pass = typeof actual === 'number' && typeof expected === 'number' && actual >= expected;
      break;
    case 'lte':
      pass = typeof actual === 'number' && typeof expected === 'number' && actual <= expected;
      break;
    case 'between': {
      const [min, max] = (expected as [number, number]) ?? [NaN, NaN];
      pass = typeof actual === 'number' && actual >= min && actual <= max;
      break;
    }
    case 'includes':
      pass = Array.isArray(actual) && (actual as (string | number)[]).some((a) => a === expected);
      break;
    case 'intersects': {
      const a = asArray(actual);
      const e = Array.isArray(expected) ? (expected as (string | number)[]) : [];
      pass = a.some((x) => e.some((y) => y === x));
      break;
    }
    case 'is_true':
      pass = actual === true;
      break;
    case 'is_false':
      pass = actual === false;
      break;
    default:
      pass = false;
  }

  return { criterion: c, actual, outcome: pass ? 'pass' : 'fail' };
}

export function evaluateAll(criteria: CriterionDef[], facts: Facts): CriterionResult[] {
  return criteria.map((c) => evaluateCriterion(c, facts));
}
