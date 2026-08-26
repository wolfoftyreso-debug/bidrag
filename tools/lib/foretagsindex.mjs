/**
 * Företagsbidragsindex — intern domäntjänst (§76 "API-first internally"). SAMMA
 * beräkning driver den publika sidan, metodiken och (framtida) API:t, så ingen
 * kanal skapar sin egen version av fakta (§2 sanningslager).
 *
 * ÄRLIGHET FRAMFÖR SIFFROR (§1, §13, §60): beräknar BARA metrics som går att
 * reproducera ur den verifierade seeden. Allt annat returneras som `unavailable`
 * med explicit skäl — aldrig påhittad statistik. Deterministisk: referensdatum =
 * seedens CURATED_AT, aldrig klockan.
 */
const COMPANY_TYPES = ['company', 'economic_association'];

export function computeFundingIndex(opportunities, authorities, CURATED_AT) {
  const now = CURATED_AT.slice(0, 10);
  const authName = Object.fromEntries(authorities.map((a) => [a.key, a.name]));
  const company = opportunities.filter((o) => (o.applicantTypes ?? []).some((t) => COMPANY_TYPES.includes(t)));

  const countBy = (arr, keyFn) => {
    const m = new Map();
    for (const o of arr) for (const k of [].concat(keyFn(o))) if (k) m.set(k, (m.get(k) ?? 0) + 1);
    return [...m.entries()].map(([key, count]) => ({ key, count })).sort((a, b) => b.count - a.count || a.key.localeCompare(b.key, 'sv'));
  };

  const withAmount = company.filter((o) => o.maxAmountMinor != null);
  const upcoming = company.filter((o) => o.deadlineModel === 'upcoming_round' || (o.opensAt && o.opensAt.slice(0, 10) > now));
  const withCloseDate = company.filter((o) => o.closesAt);

  const metrics = {
    // Reproducerbara ur seeden (verifierade):
    openCompanyGrants: { value: company.length, unit: 'count', quality: 'verified' },
    upcomingCompanyGrants: { value: upcoming.length, unit: 'count', quality: 'verified' },
    grantsWithDeadlineDate: { value: withCloseDate.length, unit: 'count', quality: 'verified' },
    verifiedAvailableFunding: {
      // §6.3 / §60: summera ENDAST kända belopp, och redovisa täckningen ärligt.
      knownCount: withAmount.length,
      totalCount: company.length,
      coveragePct: company.length ? Math.round((withAmount.length / company.length) * 100) : 0,
      sumKnownMinor: withAmount.reduce((a, o) => a + o.maxAmountMinor, 0),
      unit: 'sek',
      quality: 'partial',
      note: 'Endast stöd med känt maxbelopp summeras. Täckningen är låg — resten: uppgift saknas.',
    },
  };

  const dimensions = {
    bySector: countBy(company, (o) => o.sectors ?? []),
    byProvider: countBy(company, (o) => authName[o.authorityKey] ?? o.authorityKey),
    byInstrument: countBy(company, (o) => o.instrumentType),
    byApplicant: countBy(company, (o) => (o.applicantTypes ?? []).filter((t) => COMPANY_TYPES.includes(t))),
  };

  // §1/§13: explicit "uppgift saknas" i stället för påhittade siffror.
  const unavailable = [
    { metric: 'compositeIndexValue', reason: 'Ett indexvärde med baslinje (100) kräver en historisk startperiod som ännu inte samlats. Ingen påhittad poäng.' },
    { metric: 'monthOverMonthChange', reason: 'Ingen tidsserie ännu — dagliga snapshots historiseras först efter deploy med live-DB och cron.' },
    { metric: 'newGrantsThisPeriod', reason: 'Kräver change-events/versionshistorik som börjar samlas efter deploy.' },
    { metric: 'closedGrantsThisPeriod', reason: 'Kräver livscykel-historik (samma som ovan).' },
    { metric: 'awards', reason: 'Aggregerad beslutsdata saknas — kräver import av officiell öppen data (finns ej i kunskapsbasen).' },
    { metric: 'disbursements', reason: 'Utbetalningsdata saknas — kräver officiell öppen data.' },
    { metric: 'applicationStatistics', reason: 'Ansöknings-/beviljandegrad saknas — kräver officiell statistik.' },
    { metric: 'unallocatedFunding', reason: 'Jämförbar programbudget vs beviljanden saknas — beräknas inte utan verifierbara, jämförbara underlag (§13).' },
    { metric: 'recipientProfiles', reason: 'Mottagardata saknas; publiceras aldrig utan tillräckligt sample och tillåten återanvändning (§14/§65).' },
  ];

  return { referenceDate: now, methodologyVersion: '1.0', company: company.length, metrics, dimensions, unavailable };
}
