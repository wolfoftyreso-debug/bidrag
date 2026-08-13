/**
 * Snapshot-till-snapshot-diff (§22, §65): översätter två parsade versioner av
 * en källa till en mänskligt läsbar sammanfattning och materialflaggor mot
 * publicerade stöd. Kuratorn ska se "ny utlysning: X" och "deadline 2026-09-24
 * har försvunnit ur källan" — inte "hashen ändrades".
 */
import type { ParsedSource } from './generic.ts';

export interface MaterialFlag {
  severity: 'info' | 'warning';
  message: string;
}

export interface ChangeSummary {
  addedLinks: { href: string; text: string }[];
  removedLinks: { href: string; text: string }[];
  addedDates: string[];
  removedDates: string[];
  summary: string;
}

export function summarizeChange(previous: ParsedSource | null, current: ParsedSource): ChangeSummary {
  const prevLinks = new Map((previous?.links ?? []).map((l) => [l.href, l]));
  const currLinks = new Map(current.links.map((l) => [l.href, l]));

  const addedLinks = [...currLinks.values()].filter((l) => !prevLinks.has(l.href)).slice(0, 25);
  const removedLinks = [...prevLinks.values()].filter((l) => !currLinks.has(l.href)).slice(0, 25);

  const prevDates = new Set((previous?.dates ?? []).map((d) => d.iso));
  const currDates = new Set(current.dates.map((d) => d.iso));
  const addedDates = [...currDates].filter((d) => !prevDates.has(d));
  const removedDates = [...prevDates].filter((d) => !currDates.has(d));

  const parts: string[] = [];
  if (!previous) parts.push('Första hämtningen av källan.');
  if (addedLinks.length > 0)
    parts.push(`Nya länkar (${addedLinks.length}): ${addedLinks.slice(0, 5).map((l) => `”${l.text}”`).join(', ')}${addedLinks.length > 5 ? ' …' : ''}`);
  if (removedLinks.length > 0)
    parts.push(`Borttagna länkar (${removedLinks.length}): ${removedLinks.slice(0, 5).map((l) => `”${l.text}”`).join(', ')}${removedLinks.length > 5 ? ' …' : ''}`);
  if (addedDates.length > 0) parts.push(`Nya datum i källan: ${addedDates.join(', ')}`);
  if (removedDates.length > 0) parts.push(`Datum som försvunnit: ${removedDates.join(', ')}`);
  if (parts.length === 0) parts.push('Innehållet ändrades utan att länkar eller datum påverkades (textändring).');

  return { addedLinks, removedLinks, addedDates, removedDates, summary: parts.join(' · ') };
}

/**
 * Förslagsutkast för ett-klicks-godkännande (§65): när källan innehåller
 * exakt ETT framtida datum i deadlinesammanhang som skiljer sig från ett
 * kopplat stöds publicerade deadline föreslås en uppdatering — med textbevis.
 * Medvetet konservativt: fler än ett kandidatdatum → inget förslag, bara
 * flaggor. Kuratorn beslutar alltid; förslaget tillämpas aldrig automatiskt.
 */
export interface ChangeProposal {
  type: 'update_deadline';
  opportunitySlug: string;
  opportunityTitle: string;
  currentIso: string | null;
  proposedIso: string;
  evidence: string;
}

export function buildProposals(
  current: ParsedSource,
  opportunities: { slug: string; title: string; closesAtIso: string | null }[],
  nowIso: string,
): ChangeProposal[] {
  const today = nowIso.slice(0, 10);
  const futureDeadlineDates = current.dates.filter((d) => d.nearDeadlinePhrase && d.iso > today);
  if (futureDeadlineDates.length !== 1) return [];

  const candidate = futureDeadlineDates[0]!;
  const proposals: ChangeProposal[] = [];
  for (const opp of opportunities) {
    const currentDay = opp.closesAtIso?.slice(0, 10) ?? null;
    if (currentDay === candidate.iso) continue;
    proposals.push({
      type: 'update_deadline',
      opportunitySlug: opp.slug,
      opportunityTitle: opp.title,
      currentIso: currentDay,
      proposedIso: candidate.iso,
      evidence: candidate.evidence,
    });
  }
  return proposals;
}

/**
 * Materialflaggor: jämför källändringen med de publicerade stöd som pekar på
 * källan. Ett datum som försvinner och som är ett stöds publicerade deadline
 * är en varning; nya deadlinenära datum är information.
 */
export function materialFlags(
  change: ChangeSummary,
  current: ParsedSource,
  opportunities: { slug: string; title: string; closesAtIso: string | null }[],
): MaterialFlag[] {
  const flags: MaterialFlag[] = [];

  for (const opp of opportunities) {
    if (!opp.closesAtIso) continue;
    const day = opp.closesAtIso.slice(0, 10);
    if (change.removedDates.includes(day)) {
      flags.push({
        severity: 'warning',
        message: `Publicerad deadline ${day} för ”${opp.title}” finns inte längre i källan — kontrollera om den flyttats eller stängts.`,
      });
    }
  }

  const deadlineDates = current.dates.filter((d) => d.nearDeadlinePhrase);
  for (const iso of change.addedDates) {
    const near = deadlineDates.find((d) => d.iso === iso);
    if (near) {
      const matchesPublished = opportunities.some((o) => o.closesAtIso?.slice(0, 10) === iso);
      if (!matchesPublished) {
        flags.push({
          severity: 'info',
          message: `Nytt datum i deadlinesammanhang: ${iso} (”${near.evidence.slice(0, 90)}…”) — matchar ingen publicerad deadline.`,
        });
      }
    }
  }

  if (change.addedLinks.length > 0) {
    flags.push({
      severity: 'info',
      message: `${change.addedLinks.length} nya länkar kan vara nya utlysningar — granska om något ska kureras in.`,
    });
  }

  return flags;
}
