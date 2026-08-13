/**
 * Deadline engine (§36). Deadlines are first-class objects with time zones,
 * cutoff times and derived internal milestones.
 */

export interface DeadlineInfo {
  /** ISO timestamp with offset, e.g. "2026-08-25T13:59:59+02:00". */
  closesAt: string | null;
  model: 'one_time' | 'recurring' | 'rolling' | 'upcoming_round';
  /** Estimated preparation effort in working days. */
  estimatedEffortDays: number;
}

export interface DeadlinePlan {
  daysRemaining: number | null;
  /** Recommended internal review deadline (submission minus 3 days). */
  internalReviewBy: string | null;
  /** Recommended evidence-complete date (submission minus 5 days). */
  evidenceReadyBy: string | null;
  feasibility: 'comfortable' | 'tight' | 'unrealistic' | 'closed' | 'open_ended';
  message: string;
}

const DAY_MS = 86_400_000;

export function planDeadline(info: DeadlineInfo, referenceIso: string): DeadlinePlan {
  if (!info.closesAt) {
    return {
      daysRemaining: null,
      internalReviewBy: null,
      evidenceReadyBy: null,
      feasibility: 'open_ended',
      message: info.model === 'rolling' ? 'Löpande ansökan — ingen fast deadline.' : 'Ingen deadline publicerad ännu.',
    };
  }

  const closes = Date.parse(info.closesAt);
  const ref = Date.parse(referenceIso);
  const daysRemaining = Math.floor((closes - ref) / DAY_MS);

  if (daysRemaining < 0) {
    return {
      daysRemaining,
      internalReviewBy: null,
      evidenceReadyBy: null,
      feasibility: 'closed',
      message: 'Ansökningsperioden är stängd.',
    };
  }

  const internalReviewBy = new Date(closes - 3 * DAY_MS).toISOString();
  const evidenceReadyBy = new Date(closes - 5 * DAY_MS).toISOString();

  let feasibility: DeadlinePlan['feasibility'];
  let message: string;
  if (daysRemaining < info.estimatedEffortDays) {
    feasibility = 'unrealistic';
    message = `Endast ${daysRemaining} dagar kvar — ansökan beräknas kräva ${info.estimatedEffortDays} arbetsdagar. Det är sannolikt inte realistiskt att hinna.`;
  } else if (daysRemaining < info.estimatedEffortDays * 2) {
    feasibility = 'tight';
    message = `${daysRemaining} dagar kvar. Tidsplanen är tajt — börja nu.`;
  } else {
    feasibility = 'comfortable';
    message = `${daysRemaining} dagar kvar till deadline.`;
  }

  return { daysRemaining, internalReviewBy, evidenceReadyBy, feasibility, message };
}
