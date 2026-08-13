import { describe, expect, it } from 'vitest';
import { validateRuleSet, validateCriteria } from '../src/validation.js';

const valid = {
  criteria: [
    { id: 'h1', kind: 'hard', factPath: 'applicant.country', op: 'eq', expected: 'SE', description: 'Sverige' },
    { id: 'm1', kind: 'mandatory', factPath: 'person.hasChildrenAtHome', op: 'is_true', description: 'Barn hemma', intakeQuestion: 'Har du barn hemma?' },
    { id: 'w1', kind: 'weighted', factPath: 'project.sector', op: 'in', expected: ['culture'], weight: 2, description: 'Kultur' },
  ],
  budgetRules: [{ id: 'b1', type: 'max_funding_share', percent: 50, description: 'Max 50 %' }],
  evidenceRequirements: [{ id: 'e1', kind: 'cv', description: 'CV', mandatory: true }],
};

describe('rule set validation (curator input)', () => {
  it('accepts a well-formed rule set', () => {
    expect(validateRuleSet(valid)).toEqual([]);
  });

  it('rejects unknown operators, kinds and malformed fact paths', () => {
    const issues = validateCriteria([
      { id: 'x', kind: 'magic', factPath: '1bad path', op: 'similar_to', description: 'x' },
    ]);
    const paths = issues.map((i) => i.path);
    expect(paths).toContain('criteria[0].kind');
    expect(paths).toContain('criteria[0].factPath');
    expect(paths).toContain('criteria[0].op');
  });

  it('requires expected values matched to the operator', () => {
    const issues = validateCriteria([
      { id: 'a', kind: 'hard', factPath: 'x.y', op: 'in', expected: 'not-a-list', description: 'd' },
      { id: 'b', kind: 'hard', factPath: 'x.y', op: 'between', expected: [1], description: 'd' },
      { id: 'c', kind: 'hard', factPath: 'x.y', op: 'gte', expected: 'nope', description: 'd' },
      { id: 'd', kind: 'hard', factPath: 'x.y', op: 'eq', description: 'd' },
    ]);
    expect(issues.filter((i) => i.path.endsWith('.expected'))).toHaveLength(4);
  });

  it('rejects duplicate ids and mandatory criteria without intake questions', () => {
    const issues = validateCriteria([
      { id: 'dup', kind: 'hard', factPath: 'a.b', op: 'exists', description: 'd' },
      { id: 'dup', kind: 'mandatory', factPath: 'a.c', op: 'is_true', description: 'd' },
    ]);
    expect(issues.some((i) => i.message.includes('dubblett'))).toBe(true);
    expect(issues.some((i) => i.path.endsWith('.intakeQuestion'))).toBe(true);
  });

  it('validates budget rules per type', () => {
    const issues = validateRuleSet({
      criteria: [],
      budgetRules: [
        { id: 'b1', type: 'max_requested', description: 'd' }, // saknar amountMinor
        { id: 'b2', type: 'category_cap_share', percent: 150, description: 'd' }, // ogiltig procent + saknar category
        { id: 'b3', type: 'unknown_rule', description: 'd' },
      ],
    });
    const paths = issues.map((i) => i.path);
    expect(paths).toContain('budgetRules[0].amountMinor');
    expect(paths).toContain('budgetRules[1].percent');
    expect(paths).toContain('budgetRules[1].category');
    expect(paths).toContain('budgetRules[2].type');
  });
});
