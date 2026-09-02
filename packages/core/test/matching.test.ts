import { describe, expect, it } from 'vitest';
import { computeMatch, type MatchInput } from '../src/matching.js';
import type { CriterionDef } from '../src/criteria.js';

const REF = '2026-08-13T00:00:00Z';

const criteria: CriterionDef[] = [
  { id: 'h1', kind: 'hard', factPath: 'applicant.type', op: 'in', expected: ['individual', 'association'], description: 'Sökande måste vara privatperson eller förening' },
  { id: 'h2', kind: 'hard', factPath: 'applicant.country', op: 'eq', expected: 'SE', description: 'Sökande måste vara verksam i Sverige' },
  { id: 'm1', kind: 'mandatory', factPath: 'project.hasInternationalComponent', op: 'is_true', description: 'Projektet måste ha internationell dimension', intakeQuestion: 'Har projektet en internationell del?' },
  { id: 'w1', kind: 'weighted', factPath: 'project.sector', op: 'eq', expected: 'culture', weight: 2, description: 'Kulturprojekt prioriteras' },
  { id: 'w2', kind: 'weighted', factPath: 'project.targetGroups', op: 'includes', expected: 'youth', weight: 1, description: 'Ungdomar som målgrupp' },
];

function input(overrides: Partial<MatchInput> = {}): MatchInput {
  return {
    criteria,
    facts: {
      'applicant.type': 'individual',
      'applicant.country': 'SE',
      'project.hasInternationalComponent': true,
      'project.sector': 'culture',
      'project.targetGroups': ['youth', 'professionals'],
    },
    evidenceRequirements: [
      { id: 'e1', kind: 'cv', description: 'CV', mandatory: true },
      { id: 'e2', kind: 'partner_letter', description: 'Partnerbrev', mandatory: true },
    ],
    availableEvidenceKinds: ['cv'],
    referenceDate: REF,
    deadline: '2026-09-30T21:59:59Z',
    estimatedEffortDays: 5,
    ...overrides,
  };
}

describe('match engine', () => {
  it('full pass yields eligible with high score and explanation', () => {
    const m = computeMatch(input());
    expect(m.eligibilityStatus).toBe('eligible');
    expect(m.score).toBeGreaterThan(80);
    expect(m.fitScore).toBe(100);
    expect(m.evidenceReadiness).toBe(50);
    expect(m.missingEvidence.map((e) => e.kind)).toEqual(['partner_letter']);
    expect(m.explanation.length).toBe(5);
  });

  it('hard exclusion zeroes the score regardless of fit', () => {
    const m = computeMatch(input({ facts: { ...input().facts, 'applicant.country': 'NO' } }));
    expect(m.eligibilityStatus).toBe('excluded');
    expect(m.score).toBe(0);
    expect(m.excludedBy.some((e) => e.criterionId === 'h2')).toBe(true);
  });

  it('failed mandatory criterion excludes', () => {
    const m = computeMatch(input({ facts: { ...input().facts, 'project.hasInternationalComponent': false } }));
    expect(m.eligibilityStatus).toBe('excluded');
    expect(m.score).toBe(0);
  });

  it('missing mandatory fact yields unknown status with missing-fact question', () => {
    const facts = { ...input().facts } as Record<string, unknown>;
    delete facts['project.hasInternationalComponent'];
    const m = computeMatch(input({ facts: facts as MatchInput['facts'] }));
    expect(m.eligibilityStatus).toBe('unknown');
    expect(m.score).toBeGreaterThan(0);
    expect(m.missingFacts[0]?.question).toBe('Har projektet en internationell del?');
    expect(m.confidence).not.toBe('high');
  });

  it('closed deadline is a hard exclusion', () => {
    const m = computeMatch(input({ deadline: '2026-08-01T00:00:00Z' }));
    expect(m.eligibilityStatus).toBe('excluded');
    expect(m.excludedBy.some((e) => e.criterionId === '_deadline')).toBe(true);
  });

  it('imminent deadline lowers execution readiness, not eligibility', () => {
    const m = computeMatch(input({ deadline: '2026-08-16T00:00:00Z', estimatedEffortDays: 10 }));
    expect(m.eligibilityStatus).toBe('eligible');
    expect(m.executionReadiness).toBe(20);
  });

  it('unknown weighted criteria reduce fit without excluding', () => {
    const facts = { ...input().facts } as Record<string, unknown>;
    delete facts['project.sector'];
    const m = computeMatch(input({ facts: facts as MatchInput['facts'] }));
    expect(m.eligibilityStatus).toBe('eligible');
    expect(m.fitScore).toBeLessThan(100);
  });

  it('is reproducible for identical input', () => {
    const a = computeMatch(input());
    const b = computeMatch(input());
    expect(a).toEqual(b);
  });
});

describe('deadlineModel — återkommande omgång som stängt (motorsimuleringen 2026-09-01)', () => {
  const base = { criteria: [], facts: {}, evidenceRequirements: [], availableEvidenceKinds: [], referenceDate: '2026-09-01' };
  it('one_time med passerat datum utesluts som förut', () => {
    const r = computeMatch({ ...base, deadline: '2026-08-25', deadlineModel: 'one_time' });
    expect(r.eligibilityStatus).toBe('excluded');
    expect(r.excludedBy.some((e) => e.criterionId === '_deadline')).toBe(true);
  });
  it('recurring med passerat datum är INTE uteslutet — nästa omgång väntas, status unknown med förklaring', () => {
    const r = computeMatch({ ...base, deadline: '2026-08-25', deadlineModel: 'recurring' });
    expect(r.eligibilityStatus).toBe('unknown');
    expect(r.excludedBy).toHaveLength(0);
    expect(r.explanation.some((e) => e.criterionId === '_deadline' && e.outcome === 'unknown')).toBe(true);
  });
  it('recurring med framtida datum påverkas inte', () => {
    const r = computeMatch({ ...base, deadline: '2027-02-25', deadlineModel: 'recurring' });
    expect(r.eligibilityStatus).toBe('eligible');
  });
  it('utan modell (gamla anropare) behålls det gamla beteendet', () => {
    expect(computeMatch({ ...base, deadline: '2026-08-25' }).eligibilityStatus).toBe('excluded');
  });
});
