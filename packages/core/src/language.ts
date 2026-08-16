/**
 * Ödmjukhetsprotokollet (konstitutionen §12) och zero-bullshit-regeln (§13)
 * som deterministisk språkkontroll: sökandens egna formuleringar skannas efter
 * ogrundade superlativ och absoluta utfallsanspråk. Systemet skriver ALDRIG om
 * texten — det flaggar och föreslår, sökanden äger varje ord (§3).
 *
 * Kontrollen är rådgivande (aldrig blockerande): ett starkt påstående kan vara
 * sant och styrkt — då står det kvar. Flaggan säger bara "detta kommer att
 * granskas kritiskt; formulera som mål/förväntan om det inte är ett faktum".
 */

export interface LanguageFinding {
  /** SUPERLATIVE = §12-listan; ABSOLUTE_CLAIM = §13 utfallslöfte med siffra. */
  kind: 'SUPERLATIVE' | 'ABSOLUTE_CLAIM';
  /** Ordet/frasen som utlöste flaggan, som den står i texten. */
  term: string;
  /** Meningen där den förekommer (avkortad). */
  excerpt: string;
  /** Saklig föreslagen hantering — aldrig en automatisk omskrivning. */
  suggestion: string;
}

/** §12-listan: undvik-orden med var sin konkret hantering. */
const SUPERLATIVES: { re: RegExp; suggestion: string }[] = [
  {
    re: /\brevolutionerande\b/gi,
    suggestion: 'Beskriv i stället konkret vad som är nytt och vad det bygger på — "revolutionerande" utan belägg sänker trovärdigheten.',
  },
  {
    re: /\bvärldsledande\b/gi,
    suggestion: 'Stryk eller styrk: vilken jämförelse och vilket underlag visar positionen?',
  },
  {
    re: /\bunik(?:t|a)?\b/gi,
    suggestion: 'Använd "unik" bara med belägg: vad exakt skiljer er från alternativen, och hur vet ni det?',
  },
  {
    re: /\bgaranter(?:ar|at|as|a)\b/gi,
    suggestion: 'Utfall kan inte garanteras i förväg — föredra "bedöms kunna", "förväntas" eller "målet är".',
  },
  {
    re: /\bkommer\s+definitivt\b/gi,
    suggestion: 'Föredra "förväntas" eller "målet är" — "definitivt" om framtida utfall går inte att belägga.',
  },
  {
    re: /\bingen\s+annan\s+(?:gör|erbjuder|arbetar\s+med)\b/gi,
    suggestion: 'Anspråk på att vara ensam kräver belägg — beskriv i stället vad ni gör och hur det kompletterar det som finns.',
  },
  {
    re: /\benorm(?:t|a)?\s+effekt(?:er)?\b/gi,
    suggestion: 'Kvantifiera i stället: hur stor effekt, för vem, mätt hur?',
  },
];

/** §13: "kommer att <utfallsverb> … <siffra>" är ett löfte, inte ett faktum. */
const ABSOLUTE_CLAIM_RE =
  /\bkommer\s+(?:definitivt\s+)?att\s+(?:skapa|ge|leda|öka|minska|resultera|generera|nå)\b/i;

const MAX_EXCERPT = 140;

function sentences(text: string): string[] {
  return text
    .split(/(?<=[.!?])\s+|\n+/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

function clip(s: string): string {
  return s.length <= MAX_EXCERPT ? s : `${s.slice(0, MAX_EXCERPT - 1)}…`;
}

/** Skanna en text. Deterministisk; samma text ger alltid samma flaggor. */
export function humilityFindings(text: string): LanguageFinding[] {
  const findings: LanguageFinding[] = [];
  for (const sentence of sentences(text)) {
    for (const { re, suggestion } of SUPERLATIVES) {
      re.lastIndex = 0;
      const m = re.exec(sentence);
      if (m) findings.push({ kind: 'SUPERLATIVE', term: m[0], excerpt: clip(sentence), suggestion });
    }
    // Utfallslöfte kräver både framtidsverbet och en siffra i samma mening —
    // "kommer att genomföras under våren" flaggas inte.
    const claim = ABSOLUTE_CLAIM_RE.exec(sentence);
    if (claim && /\d/.test(sentence)) {
      findings.push({
        kind: 'ABSOLUTE_CLAIM',
        term: claim[0],
        excerpt: clip(sentence),
        suggestion:
          'Ett kvantifierat framtida utfall är ett mål, inte ett faktum — formulera som "Projektets mål är att …" eller "förväntas", om det inte redan är säkerställt.',
      });
    }
  }
  return findings;
}

/**
 * Skanna fritextsvar (dokumentmallar, ansökningsformulär). Endast strängar
 * skannas — tal, val och booleaner kan inte vara skrytsamma.
 */
export function answerLanguageFindings(
  answers: Record<string, unknown>,
): (LanguageFinding & { fieldKey: string })[] {
  const out: (LanguageFinding & { fieldKey: string })[] = [];
  for (const [fieldKey, value] of Object.entries(answers)) {
    if (typeof value !== 'string' || value.length < 8) continue;
    for (const f of humilityFindings(value)) out.push({ ...f, fieldKey });
  }
  return out;
}
