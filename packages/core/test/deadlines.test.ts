import { describe, expect, it } from 'vitest';
import { planDeadline } from '../src/deadlines.js';

const REF = '2026-08-13T08:00:00Z';

describe('deadline engine', () => {
  it('handles rolling deadlines', () => {
    const p = planDeadline({ closesAt: null, model: 'rolling', estimatedEffortDays: 5 }, REF);
    expect(p.feasibility).toBe('open_ended');
    expect(p.daysRemaining).toBeNull();
  });

  it('flags closed deadlines', () => {
    const p = planDeadline({ closesAt: '2026-08-01T21:59:59Z', model: 'one_time', estimatedEffortDays: 5 }, REF);
    expect(p.feasibility).toBe('closed');
  });

  it('flags unrealistic timelines before deadline', () => {
    const p = planDeadline({ closesAt: '2026-08-16T21:59:59Z', model: 'one_time', estimatedEffortDays: 10 }, REF);
    expect(p.feasibility).toBe('unrealistic');
    expect(p.message).toContain('inte realistiskt');
  });

  it('computes internal milestones for comfortable deadlines', () => {
    const p = planDeadline({ closesAt: '2026-09-30T21:59:59Z', model: 'one_time', estimatedEffortDays: 5 }, REF);
    expect(p.feasibility).toBe('comfortable');
    expect(p.daysRemaining).toBe(48);
    expect(Date.parse(p.internalReviewBy!)).toBeLessThan(Date.parse('2026-09-30T21:59:59Z'));
    expect(Date.parse(p.evidenceReadyBy!)).toBeLessThan(Date.parse(p.internalReviewBy!));
  });
});
