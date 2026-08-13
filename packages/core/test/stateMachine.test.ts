import { describe, expect, it } from 'vitest';
import { assertTransition, canTransition, transitionGuard, InvalidTransitionError, APPLICATION_STATES } from '../src/stateMachine.js';

describe('application state machine', () => {
  it('allows the happy path', () => {
    const path = ['DISCOVERED', 'MATCHED', 'SELECTED', 'PREPARING', 'READY_FOR_REVIEW', 'READY_TO_SUBMIT', 'SUBMITTING', 'SUBMITTED', 'ACKNOWLEDGED', 'UNDER_REVIEW', 'DECISION_RECEIVED', 'AWARDED', 'CLOSED'] as const;
    for (let i = 0; i < path.length - 1; i++) {
      expect(canTransition(path[i]!, path[i + 1]!)).toBe(true);
    }
  });

  it('forbids skipping straight to SUBMITTED from PREPARING', () => {
    expect(canTransition('PREPARING', 'SUBMITTED')).toBe(false);
    expect(() => assertTransition('PREPARING', 'SUBMITTED')).toThrow(InvalidTransitionError);
  });

  it('forbids reopening a closed case', () => {
    for (const to of APPLICATION_STATES) {
      expect(canTransition('CLOSED', to)).toBe(false);
    }
  });

  it('SUBMITTING can fall back to READY_TO_SUBMIT on failure', () => {
    expect(canTransition('SUBMITTING', 'READY_TO_SUBMIT')).toBe(true);
  });

  it('guards submission transitions with receipt requirements', () => {
    expect(transitionGuard('READY_TO_SUBMIT', 'SUBMITTED')).toMatch(/receipt/);
    expect(transitionGuard('SUBMITTING', 'SUBMITTED')).toMatch(/confirmation/);
    expect(transitionGuard('SELECTED', 'PREPARING')).toBeNull();
  });

  it('rejected/awarded only from DECISION_RECEIVED', () => {
    expect(canTransition('UNDER_REVIEW', 'AWARDED')).toBe(false);
    expect(canTransition('DECISION_RECEIVED', 'AWARDED')).toBe(true);
    expect(canTransition('DECISION_RECEIVED', 'REJECTED')).toBe(true);
  });
});
