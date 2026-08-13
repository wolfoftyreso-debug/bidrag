/**
 * Funding stack engine (§13).
 *
 * Never assumes two grants can be stacked merely because both are eligible.
 * Compatibility is explicit data on the opportunity; the default for two
 * public instruments without declared rules is "requires confirmation".
 */

export type StackCompatibility = 'compatible' | 'potentially_overlapping' | 'mutually_exclusive' | 'requires_confirmation';

export interface StackableOpportunity {
  opportunityId: string;
  title: string;
  instrumentType: string;
  /** Max contribution toward this project, minor units; null = unknown. */
  maxContributionMinor: number | null;
  /** Max share of total eligible costs (0–100); null = unknown. */
  maxFundingSharePercent: number | null;
  /** Opportunity IDs explicitly declared incompatible. */
  incompatibleWith: string[];
  /** True when the programme forbids combination with other public funding for the same costs. */
  excludesOtherPublicFunding: boolean;
  matchScore: number;
}

export interface StackItem {
  opportunityId: string;
  title: string;
  plannedContributionMinor: number;
  compatibility: StackCompatibility;
  compatibilityNote: string;
}

export interface FundingStackPlan {
  items: StackItem[];
  ownContributionMinor: number;
  totalBudgetMinor: number;
  coveredMinor: number;
  uncoveredMinor: number;
  warnings: string[];
}

const PUBLIC_INSTRUMENTS = new Set(['public_grant', 'eu_grant', 'project_grant']);

export function pairCompatibility(a: StackableOpportunity, b: StackableOpportunity): StackCompatibility {
  if (a.incompatibleWith.includes(b.opportunityId) || b.incompatibleWith.includes(a.opportunityId))
    return 'mutually_exclusive';
  if (a.excludesOtherPublicFunding && PUBLIC_INSTRUMENTS.has(b.instrumentType)) return 'mutually_exclusive';
  if (b.excludesOtherPublicFunding && PUBLIC_INSTRUMENTS.has(a.instrumentType)) return 'mutually_exclusive';
  // Two public instruments without explicit rules: possible double-funding of
  // the same costs — must be confirmed against both programmes' terms.
  if (PUBLIC_INSTRUMENTS.has(a.instrumentType) && PUBLIC_INSTRUMENTS.has(b.instrumentType))
    return 'requires_confirmation';
  return 'compatible';
}

/**
 * Greedy stack proposal: order candidates by match score, add while budget
 * remains uncovered, respecting per-opportunity caps and pairwise exclusions.
 */
export function proposeStack(
  totalBudgetMinor: number,
  ownContributionMinor: number,
  candidates: StackableOpportunity[],
): FundingStackPlan {
  const items: StackItem[] = [];
  const warnings: string[] = [];
  const chosen: StackableOpportunity[] = [];
  let remaining = totalBudgetMinor - ownContributionMinor;

  const sorted = [...candidates].sort((x, y) => y.matchScore - x.matchScore);

  for (const cand of sorted) {
    if (remaining <= 0) break;

    const conflicts = chosen.map((c) => pairCompatibility(cand, c));
    if (conflicts.includes('mutually_exclusive')) continue;

    let cap = cand.maxContributionMinor ?? remaining;
    if (cand.maxFundingSharePercent !== null) {
      cap = Math.min(cap, Math.floor((totalBudgetMinor * cand.maxFundingSharePercent) / 100));
    }
    const contribution = Math.min(cap, remaining);
    if (contribution <= 0) continue;

    const worst: StackCompatibility = conflicts.includes('requires_confirmation')
      ? 'requires_confirmation'
      : conflicts.includes('potentially_overlapping')
        ? 'potentially_overlapping'
        : 'compatible';

    items.push({
      opportunityId: cand.opportunityId,
      title: cand.title,
      plannedContributionMinor: contribution,
      compatibility: worst,
      compatibilityNote:
        worst === 'requires_confirmation'
          ? 'Kombination med annat offentligt stöd för samma kostnader måste bekräftas mot båda programmens villkor.'
          : worst === 'potentially_overlapping'
            ? 'Kan överlappa med annat stöd i planen — kontrollera kostnadsfördelningen.'
            : 'Inga kända hinder för kombination.',
    });
    chosen.push(cand);
    remaining -= contribution;
  }

  const covered = totalBudgetMinor - Math.max(0, remaining);
  if (remaining > 0)
    warnings.push(
      `Planen täcker inte hela budgeten — ${(remaining / 100).toLocaleString('sv-SE')} kr saknar finansiering.`,
    );
  if (items.some((i) => i.compatibility === 'requires_confirmation'))
    warnings.push('Minst en kombination i planen kräver bekräftelse mot programvillkoren innan du räknar med den.');

  return {
    items,
    ownContributionMinor,
    totalBudgetMinor,
    coveredMinor: covered,
    uncoveredMinor: Math.max(0, remaining),
    warnings,
  };
}
