import { describe, expect, it } from 'vitest';
import { validateBudget, budgetTotal, type BudgetLine, type BudgetFinancing, type BudgetRule } from '../src/budget.js';

const lines: BudgetLine[] = [
  { id: 'l1', category: 'travel', description: 'Flyg Stockholm–Kingston t/r, 4 personer', quantity: 4, unitCostMinor: 450_000, currency: 'SEK' },
  { id: 'l2', category: 'accommodation', description: 'Boende 3 veckor', quantity: 21, unitCostMinor: 60_000, currency: 'SEK' },
  { id: 'l3', category: 'personnel', description: 'Kursavgifter/instruktörer', quantity: 1, unitCostMinor: 2_500_000, currency: 'SEK' },
];

const financing: BudgetFinancing = {
  requestedMinor: 4_000_000,
  ownContributionMinor: 1_560_000,
  otherFundingMinor: 0,
  inKindMinor: 0,
};

describe('budget engine', () => {
  it('computes totals in minor units', () => {
    expect(budgetTotal(lines)).toBe(4 * 450_000 + 21 * 60_000 + 2_500_000);
  });

  it('accepts a balanced budget with no rules', () => {
    expect(validateBudget(lines, financing, [])).toEqual([]);
  });

  it('flags unbalanced financing', () => {
    const f = { ...financing, ownContributionMinor: 0 };
    const findings = validateBudget(lines, f, []);
    expect(findings[0]?.severity).toBe('error');
    expect(findings[0]?.message).toContain('täcker inte');
  });

  it('enforces category caps', () => {
    const rules: BudgetRule[] = [
      { id: 'r1', type: 'category_cap_amount', category: 'travel', amountMinor: 1_500_000, description: 'Resekostnader max 15 000 kr' },
    ];
    const findings = validateBudget(lines, financing, rules);
    expect(findings).toHaveLength(1);
    expect(findings[0]?.message).toContain('travel');
  });

  it('enforces co-financing share', () => {
    const rules: BudgetRule[] = [
      { id: 'r2', type: 'min_cofinancing_share', percent: 30, description: 'Minst 30 % medfinansiering' },
    ];
    const findings = validateBudget(lines, financing, rules);
    expect(findings).toHaveLength(1);
    expect(findings[0]?.message).toContain('30 %');
  });

  it('enforces max funding share and requested cap', () => {
    const rules: BudgetRule[] = [
      { id: 'r3', type: 'max_funding_share', percent: 50, description: 'Max 50 % stödandel' },
      { id: 'r4', type: 'max_requested', amountMinor: 3_000_000, description: 'Max 30 000 kr' },
    ];
    const findings = validateBudget(lines, financing, rules);
    expect(findings.map((f) => f.ruleId).sort()).toEqual(['r3', 'r4']);
  });

  it('flags excluded categories', () => {
    const rules: BudgetRule[] = [
      { id: 'r5', type: 'category_excluded', category: 'personnel', description: 'Personalkostnader ej stödberättigade' },
    ];
    expect(validateBudget(lines, financing, rules)).toHaveLength(1);
  });
});
