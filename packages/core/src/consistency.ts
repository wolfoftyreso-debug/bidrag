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
