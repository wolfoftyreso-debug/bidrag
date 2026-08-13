/**
 * Application case state machine (§32).
 *
 * Transitions are enforced server-side; UI buttons never mutate status
 * directly. Every transition is logged as an audit event by the caller.
 *
 * SUBMITTED is only reachable through SUBMITTING (native/structured adapters
 * with verified confirmation) or from READY_TO_SUBMIT via an explicit
 * user-confirmed external submission with a receipt (assisted level).
 */

import type { ApplicationState } from './types.js';

const TRANSITIONS: Record<ApplicationState, ApplicationState[]> = {
  DISCOVERED: ['MATCHED', 'CLOSED'],
  MATCHED: ['SELECTED', 'CLOSED'],
  SELECTED: ['PREPARING', 'CLOSED'],
  PREPARING: ['READY_FOR_REVIEW', 'CLOSED', 'WITHDRAWN'],
  READY_FOR_REVIEW: ['PREPARING', 'READY_TO_SUBMIT', 'CLOSED', 'WITHDRAWN'],
  READY_TO_SUBMIT: ['SUBMITTING', 'SUBMITTED', 'PREPARING', 'WITHDRAWN', 'CLOSED'],
  SUBMITTING: ['SUBMITTED', 'READY_TO_SUBMIT'], // failure falls back safely, never fake success
  SUBMITTED: ['ACKNOWLEDGED', 'UNDER_REVIEW', 'ACTION_REQUIRED', 'DECISION_RECEIVED', 'WITHDRAWN'],
  ACKNOWLEDGED: ['UNDER_REVIEW', 'ACTION_REQUIRED', 'DECISION_RECEIVED', 'WITHDRAWN'],
  UNDER_REVIEW: ['ACTION_REQUIRED', 'DECISION_RECEIVED', 'WITHDRAWN'],
  ACTION_REQUIRED: ['UNDER_REVIEW', 'DECISION_RECEIVED', 'WITHDRAWN'],
  DECISION_RECEIVED: ['AWARDED', 'REJECTED'],
  AWARDED: ['CLOSED'],
  REJECTED: ['CLOSED'],
  WITHDRAWN: ['CLOSED'],
  CLOSED: [],
};

/**
 * Transitions that require verified evidence before they are allowed.
 * The API layer enforces these preconditions.
 */
export const GUARDED_TRANSITIONS: Partial<Record<`${ApplicationState}->${ApplicationState}`, string>> = {
  'READY_TO_SUBMIT->SUBMITTED': 'requires a submission receipt (user-confirmed external submission)',
  'SUBMITTING->SUBMITTED': 'requires a verified submission confirmation from the adapter',
  'READY_FOR_REVIEW->READY_TO_SUBMIT': 'requires all mandatory fields valid and mandatory attachments present',
  'DECISION_RECEIVED->AWARDED': 'requires a recorded decision',
  'DECISION_RECEIVED->REJECTED': 'requires a recorded decision',
};

export function canTransition(from: ApplicationState, to: ApplicationState): boolean {
  return (TRANSITIONS[from] ?? []).includes(to);
}

export function allowedTransitions(from: ApplicationState): ApplicationState[] {
  return TRANSITIONS[from] ?? [];
}

export function transitionGuard(from: ApplicationState, to: ApplicationState): string | null {
  return GUARDED_TRANSITIONS[`${from}->${to}`] ?? null;
}

export class InvalidTransitionError extends Error {
  constructor(
    public readonly from: ApplicationState,
    public readonly to: ApplicationState,
  ) {
    super(`Invalid application state transition: ${from} -> ${to}`);
    this.name = 'InvalidTransitionError';
  }
}

export function assertTransition(from: ApplicationState, to: ApplicationState): void {
  if (!canTransition(from, to)) throw new InvalidTransitionError(from, to);
}

export const APPLICATION_STATES: ApplicationState[] = Object.keys(TRANSITIONS) as ApplicationState[];
