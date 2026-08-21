/**
 * Relevanspolicyn (F-RELEVANS): vilka matchningar som får VISAS för en
 * sökande, ovanpå motorns behörighetsbedömning. En enda källa — API:t
 * (routes/projects.ts), demon och relevansrevisionen (tools/audit-relevans.mjs)
 * konsumerar den härifrån; webbens Matches.tsx speglar konstanterna.
 *
 * Principen: motorn bedömer, policyn kurerar synligheten efter personens
 * DEKLARERADE situation. En person som sökt personligt stöd ska aldrig få
 * projekt-/företagsstöd som "behöver utredas"-brus (jordbruksbidrag till en
 * pensionär), och en projektsökande ska inte dränkas i personliga ersättningar
 * — men allt som bedömts 'eligible' visas alltid, oavsett spår.
 */

/** Instrumenttyper som riktar sig till personen (inte verksamheten). */
export const PERSONAL_INSTRUMENTS: ReadonlySet<string> = new Set([
  'social_benefit',
  'educational_support',
  'loan',
]);

/**
 * Företagsstöd som egenföretagare i personspåret uttryckligen lovats
 * genomlysning av (F-EGEN) — visas för dem även när frågor återstår.
 */
export const BUSINESS_RELEVANT_SLUGS: ReadonlySet<string> = new Set([
  'af-stod-start-naringsverksamhet',
  'vinnova-innovativa-startups',
  'tillvaxtverket-affarsutvecklingscheckar',
  'tillvaxtverket-regionalt-investeringsstod',
  'jordbruksverket-startstod-unga',
  'jordbruksverket-investeringsstod',
]);

/**
 * Sektorsvärdet som personspåret deklarerar: personen har valt personligt
 * stöd, inte projekt/företag. Det är ett SVAR (inte en gissning) och får
 * sektorsgrindade kriterier att utvärderas till 'fail' i stället för
 * 'unknown' — jordbruks-/kultur-/miljöprojektstöd utesluts ärligt.
 * Egenföretagare i personspåret får INTE värdet satt — deras verksamhets-
 * sektor är genuint okänd tills de svarat.
 */
export const PERSONAL_SECTOR = 'personal';

export type RelevanceTrack = 'personal' | 'project' | 'all';

export interface RelevanceRow {
  slug: string;
  instrumentType: string;
  eligibilityStatus: string; // 'eligible' | 'unknown' | 'excluded' | ...
}

/**
 * Härleder spåret ur fakta. OBS: personspårets sektordeklaration
 * (project.sector = 'personal') är en PERSONsignal — utan det undantaget
 * skulle själva deklarationen flippa spåret till 'project' och dölja
 * personstöden (regressionen som relevansrevisionen vaktar mot).
 */
export function detectTrack(facts: Record<string, unknown>): RelevanceTrack {
  if (facts?.['project.sector'] === PERSONAL_SECTOR) return 'personal';
  // Egenföretagaren kommer ur personspåret (projektspåret sätter aldrig
  // person.selfEmployed) och stannar där även när företagsstödens följd-
  // frågor sätter project.*-fakta som startingOrTakingOverFarm.
  if (facts?.['person.selfEmployed'] === true) return 'personal';
  const keys = Object.keys(facts ?? {});
  if (keys.some((k) => k.startsWith('organisation.'))) return 'project';
  // project.sector ENSAMT är ingen projektsignal: personspårets egenföretagare
  // deklarerar sin verksamhetssektor där utan att bli projektsökande. Övriga
  // project.*-fakta sätts bara av projekt-/föreningsspåret.
  if (keys.some((k) => k.startsWith('project.') && k !== 'project.sector')) return 'project';
  if (keys.some((k) => k.startsWith('person.') && k !== 'person.professionalArtist')) return 'personal';
  if (keys.includes('project.sector')) return 'project';
  return 'all';
}

/** Filtrerar matchrader till det som får visas för spåret. */
export function relevantForTrack<T extends RelevanceRow>(
  rows: T[],
  track: RelevanceTrack,
  opts?: { selfEmployed?: boolean },
): T[] {
  if (track === 'personal') {
    return rows.filter(
      (m) =>
        PERSONAL_INSTRUMENTS.has(m.instrumentType) ||
        m.eligibilityStatus === 'eligible' ||
        (opts?.selfEmployed === true && BUSINESS_RELEVANT_SLUGS.has(m.slug)),
    );
  }
  if (track === 'project') {
    return rows.filter((m) => !PERSONAL_INSTRUMENTS.has(m.instrumentType) || m.eligibilityStatus === 'eligible');
  }
  return rows;
}
