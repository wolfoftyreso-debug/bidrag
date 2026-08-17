/**
 * Consistency engine v1 (Application Intelligence §11–12).
 *
 * Extraherar sifferpåståenden ("500 deltagare", "60 procent") ur ansökans
 * textsvar och korsjämför: samma storhet med olika värden i olika fält är en
 * sannolik motsägelse som rapporteras före finalisering. Deterministisk och
 * medvetet konservativ — belopp i kronor undantas (olika kostnadsposter har
 * legitimt olika belopp), och en flagga är en uppmaning att kontrollera,
 * aldrig en tyst "rättning": motorn skriver aldrig om användarens uppgifter.
 */

export interface NumericClaim {
  /** Normaliserat värde (t.ex. "1 850" → 1850). */
  value: number;
  /** Storheten ordet efter talet, normaliserad ("deltagare", "procent"). */
  unit: string;
  fieldKey: string;
  /** Textutdraget som påståendet hämtades ur. */
  snippet: string;
}

export interface ConsistencyConflict {
  unit: string;
  values: { fieldKey: string; value: number; snippet: string }[];
  message: string;
}

/**
 * Svenskt organisationsnummer: tio siffror där den sista är Luhn-kontrollsiffra.
 * Ett format- eller kontrollsiffefel är en känd felkälla för formella avslag
 * (§12 organisationsnummer) och flaggas därför i granskningen.
 */
export function isValidSwedishOrgNumber(input: string): boolean {
  const digits = input.replace(/\D/g, '');
  if (digits.length !== 10) return false;
  let sum = 0;
  for (let i = 0; i < 10; i++) {
    let d = Number(digits[i]);
    if (i % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return sum % 10 === 0;
}

/** Monetära enheter undantas — kostnadsposter skiljer sig legitimt åt. */
const MONETARY = new Set(['kr', 'kronor', 'sek', 'öre', 'tkr', 'mkr', 'kr.']);
/** Enhetsord som är för generiska för att jämföras meningsfullt. */
const NOISE = new Set(['och', 'som', 'med', 'för', 'per', 'av', 'i', 'på', 'till', 'st', 'stycken', 'gånger', 'år', 'års']);

const CLAIM_RE = /(\d{1,3}(?:[  ]\d{3})+|\d+)(?:[.,]\d+)?\s+([a-zåäöé]+)/gi;

function normalizeNumber(raw: string): number {
  return Number(raw.replace(/[  ]/g, ''));
}

export function extractNumericClaims(answers: Record<string, unknown>): NumericClaim[] {
  const claims: NumericClaim[] = [];
  for (const [fieldKey, value] of Object.entries(answers)) {
    if (typeof value !== 'string') continue;
    for (const m of value.matchAll(CLAIM_RE)) {
      const unit = m[2]!.toLowerCase();
      if (MONETARY.has(unit) || NOISE.has(unit) || unit.length < 3) continue;
      const start = Math.max(0, m.index! - 20);
      claims.push({
        value: normalizeNumber(m[1]!),
        unit,
        fieldKey,
        snippet: value.slice(start, m.index! + m[0].length + 10).trim(),
      });
    }
  }
  return claims;
}

/**
 * Samma storhet, olika värden, olika fält ⇒ sannolik motsägelse.
 * Samma värde på flera ställen är konsekvent och flaggas inte.
 */
/**
 * Periodkonsistens (claim propagation, red team §9): när projektperioden
 * ändras ska gamla månadsangivelser i fritexten inte leva kvar. Månader som
 * nämns i textsvar men ligger utanför den angivna perioden flaggas — en
 * uppmaning att uppdatera texten eller perioden, aldrig en tyst rättning.
 */
const MONTHS = ['januari', 'februari', 'mars', 'april', 'maj', 'juni', 'juli', 'augusti', 'september', 'oktober', 'november', 'december'];
const MONTH_RE = new RegExp(`\\b(${MONTHS.join('|')})\\b`, 'gi');
/** "14 oktober", "1 februari 2027" — dag + månadsnamn, valfritt år. */
const DAY_MONTH_RE = new RegExp(`\\b([1-9]|[12]\\d|3[01])\\s+(${MONTHS.join('|')})(?:\\s+(20\\d{2}))?\\b`, 'gi');
const ISO_DATE_RE = /\b(20\d{2})-(\d{2})-(\d{2})\b/g;

export interface PeriodConflict {
  /** Det som texten nämner: ett månadsnamn ("januari") eller ett datum ("14 januari 2027"). */
  month: string;
  fieldKey: string;
  snippet: string;
}

function iso(y: number, m: number, d: number): string {
  return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

export function findPeriodConflicts(
  answers: Record<string, unknown>,
  period: { start: string; end: string },
): PeriodConflict[] {
  const start = new Date(period.start);
  const end = new Date(period.end);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || start > end) return [];
  const startIso = period.start.slice(0, 10);
  const endIso = period.end.slice(0, 10);
  // Månader som perioden täcker (kalendermånadsupplösning, max ett varv).
  const covered = new Set<number>();
  const cursor = new Date(Date.UTC(start.getUTCFullYear(), start.getUTCMonth(), 1));
  for (let i = 0; i < 12 && cursor <= end; i++) {
    covered.add(cursor.getUTCMonth());
    cursor.setUTCMonth(cursor.getUTCMonth() + 1);
  }
  const fullYear = covered.size >= 12;

  const conflicts: PeriodConflict[] = [];
  for (const [fieldKey, value] of Object.entries(answers)) {
    if (typeof value !== 'string') continue;
    const clip = (index: number, len: number) => {
      const from = Math.max(0, index - 30);
      return value.slice(from, index + len + 15).trim();
    };
    // Spann som redan hanterats med dagprecision — månadsskanningen hoppar
    // över dem så att "14 januari" aldrig ger dubbla flaggor.
    const daySpans: [number, number][] = [];

    // 1) Exakta ISO-datum: strängjämförelse räcker för åååå-mm-dd.
    for (const m of value.matchAll(ISO_DATE_RE)) {
      daySpans.push([m.index!, m.index! + m[0].length]);
      if (m[0] < startIso || m[0] > endIso) conflicts.push({ month: m[0], fieldKey, snippet: clip(m.index!, m[0].length) });
    }
    // 2) "14 oktober (2026)": med år jämförs exakt; utan år godtas datumet om
    //    NÅGOT av periodens år placerar det inom perioden (årsskiftessäkert).
    for (const m of value.matchAll(DAY_MONTH_RE)) {
      daySpans.push([m.index!, m.index! + m[0].length]);
      const day = Number(m[1]);
      const monthIdx = MONTHS.indexOf(m[2]!.toLowerCase());
      const years = m[3] ? [Number(m[3])] : [...new Set([start.getUTCFullYear(), end.getUTCFullYear()])];
      const inside = years.some((y) => {
        const candidate = iso(y, monthIdx + 1, day);
        return candidate >= startIso && candidate <= endIso;
      });
      if (!inside) conflicts.push({ month: m[0].toLowerCase(), fieldKey, snippet: clip(m.index!, m[0].length) });
    }
    // 3) Ensamma månadsnamn — bara utanför dagspann, och aldrig mot helår.
    if (!fullYear) {
      for (const m of value.matchAll(MONTH_RE)) {
        if (daySpans.some(([a, b]) => m.index! >= a && m.index! < b)) continue;
        const idx = MONTHS.indexOf(m[1]!.toLowerCase());
        if (idx === -1 || covered.has(idx)) continue;
        conflicts.push({ month: MONTHS[idx]!, fieldKey, snippet: clip(m.index!, m[0].length) });
      }
    }
  }
  return conflicts;
}

/**
 * Geografikonsistens (claim register): resmålet i formuläret korsjämförs mot
 * LANDNAMN i fritexten — men bara i resesammanhang, för en ansökan nämner
 * legitimt andra länder (partnern i Portugal, jämförelser, hemlandet).
 * Medvetet smal: partnermeningar undantas, Sverige undantas (hemlandet är
 * aldrig en resmålskonflikt), och utan reseord i meningen flaggas inget.
 */
const COUNTRIES = ['jamaica', 'portugal', 'spanien', 'frankrike', 'tyskland', 'italien', 'grekland', 'polen', 'danmark', 'norge', 'finland', 'island', 'estland', 'lettland', 'litauen', 'nederländerna', 'belgien', 'österrike', 'schweiz', 'storbritannien', 'irland', 'tjeckien', 'ungern', 'rumänien', 'bulgarien', 'kroatien', 'slovenien', 'slovakien', 'usa', 'kanada', 'mexiko', 'brasilien', 'argentina', 'chile', 'japan', 'kina', 'indien', 'sydkorea', 'australien', 'nya zeeland', 'sydafrika', 'kenya', 'ghana', 'nigeria', 'egypten', 'marocko', 'tunisien', 'turkiet', 'ukraina', 'georgien'];
const COUNTRY_RE = new RegExp(`\\b(?:till|i|från)\\s+(${COUNTRIES.join('|')})\\b`, 'gi');
const TRAVEL_RE = /\bres(?:a|an|or|er)?\b|\breser\b|\bavres|\bresmål|\bresiden|\bvistelse|\butbyte|\båker\b|\bturné/i;

export interface PlaceConflict {
  place: string;
  fieldKey: string;
  snippet: string;
}

export function findDestinationConflicts(
  answers: Record<string, unknown>,
  destination: string,
): PlaceConflict[] {
  const dest = destination.trim().toLowerCase();
  if (dest.length < 3) return [];
  const conflicts: PlaceConflict[] = [];
  for (const [fieldKey, value] of Object.entries(answers)) {
    if (typeof value !== 'string') continue;
    for (const sentence of value.split(/(?<=[.!?])\s+|\n+/)) {
      if (/partner|samarbet|jämför/i.test(sentence)) continue;
      if (!TRAVEL_RE.test(sentence)) continue;
      for (const m of sentence.matchAll(COUNTRY_RE)) {
        const country = m[1]!.toLowerCase();
        if (country === 'sverige' || dest.includes(country) || country.includes(dest)) continue;
        conflicts.push({ place: m[1]!, fieldKey, snippet: sentence.trim().slice(0, 140) });
      }
    }
  }
  return conflicts;
}

export function findNumericConflicts(answers: Record<string, unknown>): ConsistencyConflict[] {
  const byUnit = new Map<string, NumericClaim[]>();
  for (const c of extractNumericClaims(answers)) {
    const list = byUnit.get(c.unit) ?? [];
    list.push(c);
    byUnit.set(c.unit, list);
  }

  const conflicts: ConsistencyConflict[] = [];
  for (const [unit, claims] of byUnit) {
    const distinct = new Map<number, NumericClaim>();
    for (const c of claims) if (!distinct.has(c.value)) distinct.set(c.value, c);
    if (distinct.size < 2) continue;
    const values = [...distinct.values()].map((c) => ({ fieldKey: c.fieldKey, value: c.value, snippet: c.snippet }));
    conflicts.push({
      unit,
      values,
      message: `Olika uppgifter om antal ${unit}: ${values.map((v) => v.value).join(' / ')} förekommer i olika fält — kontrollera vilken som stämmer.`,
    });
  }
  return conflicts;
}
