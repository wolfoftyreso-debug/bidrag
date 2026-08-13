/**
 * Structural validation for curator-supplied rule data (§43). The rule editor
 * and the rule-versions API must never publish malformed criteria — a bad
 * factPath or operator would silently break matching for every tenant.
 */
import type { CriterionDef, CriterionKind, CriterionOp } from './criteria.js';
import type { BudgetRule } from './budget.js';
import type { EvidenceRequirement } from './matching.js';

const OPS: CriterionOp[] = ['eq', 'neq', 'in', 'not_in', 'gte', 'lte', 'between', 'includes', 'intersects', 'exists', 'is_true', 'is_false'];
const KINDS: CriterionKind[] = ['hard', 'mandatory', 'weighted'];
const BUDGET_RULE_TYPES = new Set([
  'max_total', 'min_total', 'max_requested', 'min_requested', 'max_funding_share',
  'min_cofinancing_share', 'category_cap_amount', 'category_cap_share', 'category_required', 'category_excluded',
]);

export interface RuleValidationIssue {
  path: string;
  message: string;
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}

export function validateCriteria(input: unknown): RuleValidationIssue[] {
  const issues: RuleValidationIssue[] = [];
  if (!Array.isArray(input)) return [{ path: 'criteria', message: 'criteria måste vara en lista' }];

  const seenIds = new Set<string>();
  input.forEach((c, i) => {
    const p = `criteria[${i}]`;
    if (!isRecord(c)) {
      issues.push({ path: p, message: 'kriteriet måste vara ett objekt' });
      return;
    }
    if (typeof c.id !== 'string' || c.id.length === 0) issues.push({ path: `${p}.id`, message: 'id krävs' });
    else if (seenIds.has(c.id)) issues.push({ path: `${p}.id`, message: `dubblett-id: ${c.id}` });
    else seenIds.add(c.id);

    if (!KINDS.includes(c.kind as CriterionKind)) issues.push({ path: `${p}.kind`, message: `kind måste vara ${KINDS.join('/')}` });
    if (typeof c.factPath !== 'string' || !/^[a-zA-Z][a-zA-Z0-9_.]*$/.test(c.factPath))
      issues.push({ path: `${p}.factPath`, message: 'factPath måste vara en punktsökväg, t.ex. person.ageUnder29' });
    if (!OPS.includes(c.op as CriterionOp)) issues.push({ path: `${p}.op`, message: `okänd operator: ${String(c.op)}` });
    if (typeof c.description !== 'string' || c.description.length === 0)
      issues.push({ path: `${p}.description`, message: 'description (klartext) krävs' });

    const op = c.op as CriterionOp;
    const needsExpected: CriterionOp[] = ['eq', 'neq', 'in', 'not_in', 'gte', 'lte', 'between', 'includes', 'intersects'];
    if (needsExpected.includes(op) && c.expected === undefined)
      issues.push({ path: `${p}.expected`, message: `operatorn ${op} kräver ett förväntat värde` });
    if ((op === 'in' || op === 'not_in' || op === 'intersects') && !Array.isArray(c.expected))
      issues.push({ path: `${p}.expected`, message: `operatorn ${op} kräver en lista` });
    if (op === 'between' && (!Array.isArray(c.expected) || c.expected.length !== 2 || c.expected.some((x) => typeof x !== 'number')))
      issues.push({ path: `${p}.expected`, message: 'between kräver [min, max] som tal' });
    if ((op === 'gte' || op === 'lte') && typeof c.expected !== 'number')
      issues.push({ path: `${p}.expected`, message: `${op} kräver ett tal` });
    if (c.kind === 'weighted' && c.weight !== undefined && (typeof c.weight !== 'number' || c.weight <= 0))
      issues.push({ path: `${p}.weight`, message: 'weight måste vara ett positivt tal' });
    if (c.kind === 'mandatory' && typeof c.intakeQuestion !== 'string')
      issues.push({ path: `${p}.intakeQuestion`, message: 'obligatoriska kriterier bör ha en intakeQuestion så att saknade uppgifter kan frågas efter' });
  });

  return issues;
}

export function validateBudgetRules(input: unknown): RuleValidationIssue[] {
  const issues: RuleValidationIssue[] = [];
  if (input === undefined) return issues;
  if (!Array.isArray(input)) return [{ path: 'budgetRules', message: 'budgetRules måste vara en lista' }];
  input.forEach((r, i) => {
    const p = `budgetRules[${i}]`;
    if (!isRecord(r)) { issues.push({ path: p, message: 'regeln måste vara ett objekt' }); return; }
    if (typeof r.id !== 'string' || r.id.length === 0) issues.push({ path: `${p}.id`, message: 'id krävs' });
    if (!BUDGET_RULE_TYPES.has(r.type as string)) issues.push({ path: `${p}.type`, message: `okänd regeltyp: ${String(r.type)}` });
    if (typeof r.description !== 'string' || r.description.length === 0) issues.push({ path: `${p}.description`, message: 'description krävs' });
    const t = r.type as BudgetRule['type'];
    if (['max_total', 'min_total', 'max_requested', 'min_requested', 'category_cap_amount'].includes(t) && typeof r.amountMinor !== 'number')
      issues.push({ path: `${p}.amountMinor`, message: `${t} kräver amountMinor (ören)` });
    if (['max_funding_share', 'min_cofinancing_share', 'category_cap_share'].includes(t) && (typeof r.percent !== 'number' || r.percent < 0 || r.percent > 100))
      issues.push({ path: `${p}.percent`, message: `${t} kräver percent 0–100` });
    if (t?.startsWith('category_') && typeof r.category !== 'string')
      issues.push({ path: `${p}.category`, message: `${t} kräver category` });
  });
  return issues;
}

export function validateEvidenceRequirements(input: unknown): RuleValidationIssue[] {
  const issues: RuleValidationIssue[] = [];
  if (input === undefined) return issues;
  if (!Array.isArray(input)) return [{ path: 'evidenceRequirements', message: 'evidenceRequirements måste vara en lista' }];
  input.forEach((e, i) => {
    const p = `evidenceRequirements[${i}]`;
    if (!isRecord(e)) { issues.push({ path: p, message: 'kravet måste vara ett objekt' }); return; }
    if (typeof e.id !== 'string' || e.id.length === 0) issues.push({ path: `${p}.id`, message: 'id krävs' });
    if (typeof e.kind !== 'string' || e.kind.length === 0) issues.push({ path: `${p}.kind`, message: 'kind krävs (t.ex. cv, budget)' });
    if (typeof e.description !== 'string' || e.description.length === 0) issues.push({ path: `${p}.description`, message: 'description krävs' });
    if (typeof e.mandatory !== 'boolean') issues.push({ path: `${p}.mandatory`, message: 'mandatory (true/false) krävs' });
  });
  return issues;
}

export function validateRuleSet(payload: {
  criteria: unknown;
  budgetRules?: unknown;
  evidenceRequirements?: unknown;
}): RuleValidationIssue[] {
  return [
    ...validateCriteria(payload.criteria),
    ...validateBudgetRules(payload.budgetRules),
    ...validateEvidenceRequirements(payload.evidenceRequirements),
  ];
}
