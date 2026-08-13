import { describe, expect, it } from 'vitest';
import { proposeStack, pairCompatibility, type StackableOpportunity } from '../src/stacking.js';

function opp(id: string, over: Partial<StackableOpportunity> = {}): StackableOpportunity {
  return {
    opportunityId: id,
    title: id,
    instrumentType: 'public_grant',
    maxContributionMinor: null,
    maxFundingSharePercent: null,
    incompatibleWith: [],
    excludesOtherPublicFunding: false,
    matchScore: 80,
    ...over,
  };
}

describe('funding stack engine', () => {
  it('two public grants default to requires_confirmation, never silent compatibility', () => {
    expect(pairCompatibility(opp('a'), opp('b'))).toBe('requires_confirmation');
  });

  it('explicit incompatibility is mutually exclusive', () => {
    expect(pairCompatibility(opp('a', { incompatibleWith: ['b'] }), opp('b'))).toBe('mutually_exclusive');
  });

  it('a foundation scholarship stacks compatibly with a public grant', () => {
    expect(pairCompatibility(opp('a', { instrumentType: 'scholarship' }), opp('b'))).toBe('compatible');
  });

  it('builds the 100k example stack with caps and flags uncovered remainder', () => {
    // Project total SEK 100 000, own contribution SEK 35 000.
    const plan = proposeStack(10_000_000, 3_500_000, [
      opp('A', { maxContributionMinor: 3_500_000, matchScore: 95 }),
      opp('B', { maxContributionMinor: 2_000_000, matchScore: 90 }),
      opp('C', { instrumentType: 'scholarship', maxContributionMinor: 1_000_000, matchScore: 70 }),
    ]);
    expect(plan.items.map((i) => i.opportunityId)).toEqual(['A', 'B', 'C']);
    expect(plan.coveredMinor).toBe(10_000_000);
    expect(plan.uncoveredMinor).toBe(0);
    expect(plan.items.find((i) => i.opportunityId === 'B')?.compatibility).toBe('requires_confirmation');
    expect(plan.warnings.some((w) => w.includes('bekräftelse'))).toBe(true);
  });

  it('skips mutually exclusive candidates and warns about uncovered budget', () => {
    const plan = proposeStack(10_000_000, 0, [
      opp('A', { excludesOtherPublicFunding: true, maxContributionMinor: 4_000_000, matchScore: 99 }),
      opp('B', { maxContributionMinor: 5_000_000, matchScore: 90 }),
    ]);
    expect(plan.items.map((i) => i.opportunityId)).toEqual(['A']);
    expect(plan.uncoveredMinor).toBe(6_000_000);
    expect(plan.warnings.some((w) => w.includes('saknar finansiering'))).toBe(true);
  });

  it('respects max funding share caps', () => {
    const plan = proposeStack(10_000_000, 0, [opp('A', { maxFundingSharePercent: 50 })]);
    expect(plan.items[0]?.plannedContributionMinor).toBe(5_000_000);
  });
});
