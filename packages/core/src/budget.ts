/**
 * Budget engine (§35).
 *
 * Amounts are stored in minor units (öre/cent) as integers to avoid floating
 * point drift. Budget rules published by a funding opportunity validate the
 * project budget and produce plain-language findings.
 */

export interface BudgetLine {
  id: string;
  /** e.g. 'personnel', 'travel', 'accommodation', 'equipment', 'subcontractor', 'overhead', 'other' */
  category: string;
  description: string;
  quantity: number;
  /** Unit cost in minor units (öre). */
  unitCostMinor: number;
  currency: string;
}

export interface BudgetFinancing {
  /** Requested grant amount, minor units. */
  requestedMinor: number;
  /** Own cash contribution. */
  ownContributionMinor: number;
  /** Other confirmed funding (e.g. another grant in the stack). */
  otherFundingMinor: number;
  /** In-kind contribution where the funder allows it. */
  inKindMinor: number;
}

export interface BudgetRule {
  id: string;
  type:
    | 'max_total'                 // total budget cap
    | 'min_total'
    | 'max_requested'             // cap on requested grant
    | 'min_requested'
    | 'max_funding_share'         // requested / total <= pct
    | 'min_cofinancing_share'     // (own+other+inKind) / total >= pct
    | 'category_cap_amount'       // category total <= amount
    | 'category_cap_share'        // category total / total <= pct
    | 'category_required'         // category must be present
    | 'category_excluded';        // category not eligible
  category?: string;
  amountMinor?: number;
  /** Percentage 0–100. */
  percent?: number;
  description: string;
  sourceRef?: string;
}

export interface BudgetFinding {
  ruleId: string;
  severity: 'error' | 'warning';
  message: string;
}

export function lineTotal(line: BudgetLine): number {
  return Math.round(line.quantity * line.unitCostMinor);
}

export function budgetTotal(lines: BudgetLine[]): number {
  return lines.reduce((s, l) => s + lineTotal(l), 0);
}

export function categoryTotal(lines: BudgetLine[], category: string): number {
  return budgetTotal(lines.filter((l) => l.category === category));
}

export function financingTotal(f: BudgetFinancing): number {
  return f.requestedMinor + f.ownContributionMinor + f.otherFundingMinor + f.inKindMinor;
}

export function validateBudget(
  lines: BudgetLine[],
  financing: BudgetFinancing,
  rules: BudgetRule[],
): BudgetFinding[] {
  const findings: BudgetFinding[] = [];
  const total = budgetTotal(lines);

  // Structural check: financing must cover the budget.
  const finTotal = financingTotal(financing);
  if (total > 0 && finTotal !== total) {
    findings.push({
      ruleId: '_financing_balance',
      severity: finTotal < total ? 'error' : 'warning',
      message:
        finTotal < total
          ? `Finansieringen (${fmt(finTotal)}) täcker inte budgeten (${fmt(total)}).`
          : `Finansieringen (${fmt(finTotal)}) överstiger budgeten (${fmt(total)}).`,
    });
  }

  for (const rule of rules) {
    switch (rule.type) {
      case 'max_total':
        if (rule.amountMinor !== undefined && total > rule.amountMinor)
          findings.push(err(rule, `Total budget ${fmt(total)} överstiger taket ${fmt(rule.amountMinor)}.`));
        break;
      case 'min_total':
        if (rule.amountMinor !== undefined && total < rule.amountMinor)
          findings.push(err(rule, `Total budget ${fmt(total)} understiger minimibeloppet ${fmt(rule.amountMinor)}.`));
        break;
      case 'max_requested':
        if (rule.amountMinor !== undefined && financing.requestedMinor > rule.amountMinor)
          findings.push(err(rule, `Sökt belopp ${fmt(financing.requestedMinor)} överstiger maxbeloppet ${fmt(rule.amountMinor)}.`));
        break;
      case 'min_requested':
        if (rule.amountMinor !== undefined && financing.requestedMinor < rule.amountMinor)
          findings.push(err(rule, `Sökt belopp ${fmt(financing.requestedMinor)} understiger minimibeloppet ${fmt(rule.amountMinor)}.`));
        break;
      case 'max_funding_share': {
        if (rule.percent !== undefined && total > 0) {
          const share = (financing.requestedMinor / total) * 100;
          if (share > rule.percent + 1e-9)
            findings.push(
              err(rule, `Sökt stöd är ${share.toFixed(1)} % av budgeten — max tillåten stödandel är ${rule.percent} %.`),
            );
        }
        break;
      }
      case 'min_cofinancing_share': {
        if (rule.percent !== undefined && total > 0) {
          const co = financing.ownContributionMinor + financing.otherFundingMinor + financing.inKindMinor;
          const share = (co / total) * 100;
          if (share + 1e-9 < rule.percent)
            findings.push(
              err(rule, `Det här stödet kräver att du själv finansierar minst ${rule.percent} % av projektet — din medfinansiering är ${share.toFixed(1)} %.`),
            );
        }
        break;
      }
      case 'category_cap_amount': {
        if (rule.category && rule.amountMinor !== undefined) {
          const ct = categoryTotal(lines, rule.category);
          if (ct > rule.amountMinor)
            findings.push(
              err(rule, `Kategorin "${rule.category}" uppgår till ${fmt(ct)}, men programmet tillåter högst ${fmt(rule.amountMinor)} enligt publicerade regler.`),
            );
        }
        break;
      }
      case 'category_cap_share': {
        if (rule.category && rule.percent !== undefined && total > 0) {
          const share = (categoryTotal(lines, rule.category) / total) * 100;
          if (share > rule.percent + 1e-9)
            findings.push(err(rule, `Kategorin "${rule.category}" är ${share.toFixed(1)} % av budgeten — max ${rule.percent} %.`));
        }
        break;
      }
      case 'category_required':
        if (rule.category && categoryTotal(lines, rule.category) === 0)
          findings.push(err(rule, `Programmet kräver budgetposter i kategorin "${rule.category}".`));
        break;
      case 'category_excluded':
        if (rule.category && categoryTotal(lines, rule.category) > 0)
          findings.push(err(rule, `Kategorin "${rule.category}" är inte en stödberättigad kostnad i det här programmet.`));
        break;
    }
  }

  return findings;
}

function err(rule: BudgetRule, message: string): BudgetFinding {
  return { ruleId: rule.id, severity: 'error', message };
}

function fmt(minor: number): string {
  return `${(minor / 100).toLocaleString('sv-SE')} kr`;
}
