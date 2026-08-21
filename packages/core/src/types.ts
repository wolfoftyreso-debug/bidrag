/**
 * Shared domain vocabulary for Bidragskoll.se.
 *
 * These types are deliberately country-agnostic: Sweden is the first market,
 * but countries, authorities, programmes, languages and currencies are data,
 * not code.
 */

/** Financing instruments are never mixed in the UI as if they were the same thing. */
export type InstrumentType =
  | 'public_grant'
  | 'eu_grant'
  | 'scholarship'
  | 'stipend'
  | 'travel_grant'
  | 'project_grant'
  | 'mobility_grant'
  | 'prize'
  | 'reimbursement'
  | 'loan'
  | 'guarantee'
  | 'equity'
  | 'sponsorship'
  | 'procurement'
  | 'social_benefit'
  | 'educational_support'
  | 'other';

export type ApplicantType =
  | 'individual'
  | 'sole_trader'
  | 'company'
  | 'association'          // ideell förening
  | 'economic_association' // ekonomisk förening
  | 'foundation'
  | 'municipality'
  | 'region'
  | 'public_body'
  | 'university'
  | 'school'
  | 'informal_group';      // e.g. Erasmus+ youth groups

/**
 * Separate determinations — a match score is never an official eligibility
 * decision (see product principle 7).
 */
export type EligibilityStatus =
  | 'excluded'      // a hard exclusion rule fired
  | 'unknown'       // required applicant facts are missing
  | 'eligible';     // known mandatory criteria appear satisfied

export type MatchConfidence = 'low' | 'medium' | 'high';

/** Source quality tiers (§41). D-quality data never declares hard eligibility. */
export type SourceQuality = 'A' | 'B' | 'C' | 'D';

export type VerificationStatus =
  | 'unverified'
  | 'machine_extracted'
  | 'ai_curated'
  | 'human_curated'
  | 'human_verified';

/** Application case lifecycle (§32). Transitions are validated server-side. */
export type ApplicationState =
  | 'DISCOVERED'
  | 'MATCHED'
  | 'SELECTED'
  | 'PREPARING'
  | 'READY_FOR_REVIEW'
  | 'READY_TO_SUBMIT'
  | 'SUBMITTING'
  | 'SUBMITTED'
  | 'ACKNOWLEDGED'
  | 'UNDER_REVIEW'
  | 'ACTION_REQUIRED'
  | 'DECISION_RECEIVED'
  | 'AWARDED'
  | 'REJECTED'
  | 'WITHDRAWN'
  | 'CLOSED';

/**
 * Submission levels (§16).
 * native      — supported machine interface exists and is integrated.
 * structured  — maintained adapter over an official web e-service.
 * assisted    — we prepare the full package; the user completes the official
 *               submission and we store the receipt. Never claimed as submitted
 *               without a verified submission event.
 */
export type SubmissionLevel = 'native' | 'structured' | 'assisted';

export type DeadlineModel = 'one_time' | 'recurring' | 'rolling' | 'upcoming_round';

/** Canonical application field types (§15). */
export type CanonicalFieldType =
  | 'text'
  | 'long_text'
  | 'number'
  | 'currency'
  | 'percentage'
  | 'date'
  | 'date_range'
  | 'select'
  | 'multiselect'
  | 'boolean'
  | 'person'
  | 'organisation'
  | 'partner'
  | 'address'
  | 'budget_line'
  | 'attachment'
  | 'rich_text'
  | 'table'
  | 'signature'
  | 'consent'
  | 'declaration';

/**
 * Facts are a flattened view over profile + organisation + project, addressed
 * by dot paths (e.g. "project.countries", "applicant.type", "person.ageBand").
 * `undefined` means the fact has not been collected — which is materially
 * different from `false` or `null`.
 */
export type FactValue = string | number | boolean | string[] | number[] | null;
export type Facts = Record<string, FactValue | undefined>;

export interface MoneyRange {
  min?: number;
  max?: number;
  currency: string;
}
