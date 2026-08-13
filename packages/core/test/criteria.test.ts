import { describe, expect, it } from 'vitest';
import { evaluateCriterion, type CriterionDef } from '../src/criteria.js';

const base: Omit<CriterionDef, 'op' | 'expected' | 'factPath'> = {
  id: 'c1',
  kind: 'mandatory',
  description: 'test',
};

describe('criterion evaluator', () => {
  it('returns unknown when the fact is missing', () => {
    const r = evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'eq', expected: 'individual' }, {});
    expect(r.outcome).toBe('unknown');
  });

  it('eq / neq', () => {
    const facts = { 'applicant.type': 'individual' };
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'eq', expected: 'individual' }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'eq', expected: 'company' }, facts).outcome).toBe('fail');
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'neq', expected: 'company' }, facts).outcome).toBe('pass');
  });

  it('in / not_in', () => {
    const facts = { 'applicant.type': 'association' };
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'in', expected: ['association', 'individual'] }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'not_in', expected: ['company'] }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'applicant.type', op: 'in', expected: ['company'] }, facts).outcome).toBe('fail');
  });

  it('numeric comparisons', () => {
    const facts = { 'person.age': 24 };
    expect(evaluateCriterion({ ...base, factPath: 'person.age', op: 'gte', expected: 18 }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'person.age', op: 'lte', expected: 25 }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'person.age', op: 'between', expected: [13, 30] }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'person.age', op: 'between', expected: [26, 30] }, facts).outcome).toBe('fail');
  });

  it('includes / intersects over arrays', () => {
    const facts = { 'project.countries': ['SE', 'JM'] };
    expect(evaluateCriterion({ ...base, factPath: 'project.countries', op: 'includes', expected: 'JM' }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'project.countries', op: 'intersects', expected: ['JM', 'CU'] }, facts).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'project.countries', op: 'intersects', expected: ['NO'] }, facts).outcome).toBe('fail');
  });

  it('exists treats null as missing', () => {
    expect(evaluateCriterion({ ...base, factPath: 'x', op: 'exists' }, { x: null }).outcome).toBe('fail');
    expect(evaluateCriterion({ ...base, factPath: 'x', op: 'exists' }, { x: 0 }).outcome).toBe('pass');
  });

  it('boolean ops', () => {
    expect(evaluateCriterion({ ...base, factPath: 'f', op: 'is_true' }, { f: true }).outcome).toBe('pass');
    expect(evaluateCriterion({ ...base, factPath: 'f', op: 'is_false' }, { f: true }).outcome).toBe('fail');
  });
});
