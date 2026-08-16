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
  /**
   * SUPERLATIVE = §12-listan; ABSOLUTE_CLAIM = §13 utfallslöfte med siffra;
   * GENERIC_CONTENT = standardfras som kunde stå i vilken ansökan som helst
   * (red team §21) — det som får en ansökan att kännas standardiserad.
   */
  kind: 'SUPERLATIVE' | 'ABSOLUTE_CLAIM' | 'GENERIC_CONTENT' | 'REPETITION';
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

/**
 * Standardfraser (red team §21, konstitutionen §22): meningar som kunde stå
 * nästan oförändrade i vilken ansökan som helst gör texten anonym — tonen ska
 * avspegla den verkliga situationen och personen. Kurerad lista över svensk
 * ansöknings-boilerplate; varje förslag pekar mot det specifika i stället.
 */
const GENERIC_PHRASES: { re: RegExp; suggestion: string }[] = [
  {
    re: /\bhärmed\s+ansöker\b/gi,
    suggestion: 'Kanslisvenska som inte tillför något — börja direkt med saken: vad du söker och varför.',
  },
  {
    re: /\bi\s+dagens\s+samhälle\b/gi,
    suggestion: 'Tom inledning som passar alla ansökningar — beskriv i stället den konkreta situationen hos er.',
  },
  {
    re: /\bstödet\s+är\s+avgörande\b/gi,
    suggestion: 'Påstår utan att visa — skriv vad som konkret inte blir av utan stödet.',
  },
  {
    re: /\bbrinner\s+för\b/gi,
    suggestion: 'Engagemang visas bäst genom det ni redan gjort — ersätt med en konkret erfarenhet eller handling.',
  },
  {
    re: /\bser\s+fram\s+emot\s+ett\s+positivt\s+besked\b/gi,
    suggestion: 'Påverkar inte prövningen och tar plats från sak — kan strykas.',
  },
  {
    re: /\bfantastisk(?:t|a)?\s+möjlighet\b/gi,
    suggestion: 'Värdeord utan innehåll — beskriv vad möjligheten konkret består i för just er.',
  },
  {
    re: /\bföreligger\s+ett?\s+stort\s+behov\b/gi,
    suggestion: 'Vems behov, och hur vet ni det? Konkreta observationer eller siffror väger tyngre än formeln.',
  },
  {
    re: /\bsom\s+bekant\b/gi,
    suggestion: 'Det som är bekant behöver inte sägas; det som inte är det behöver beläggas — stryk eller belägg.',
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
    for (const { re, suggestion } of GENERIC_PHRASES) {
      re.lastIndex = 0;
      const m = re.exec(sentence);
      if (m) findings.push({ kind: 'GENERIC_CONTENT', term: m[0], excerpt: clip(sentence), suggestion });
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
 * Korrekturvarvet (användardirektiv: "upprepningar får inte förekomma"):
 * upptäcker (1) samma mening som återkommer flera gånger i dokumentet — ofta
 * ett kvarglömt klipp-och-klistra mellan fält — och (2) dubblerade ord i
 * följd ("och och"). Flaggar, skriver aldrig om: att stryka en upprepning är
 * sökandens beslut, inte motorns.
 */
export function repetitionFindings(text: string): LanguageFinding[] {
  const findings: LanguageFinding[] = [];

  // 1) Upprepade meningar: normaliserad jämförelse, bara meningar med substans.
  const seen = new Map<string, { first: string; count: number }>();
  for (const sentence of sentences(text)) {
    const normalized = sentence.toLowerCase().replace(/[.!?:,]+$/g, '').replace(/\s+/g, ' ').trim();
    if (normalized.length < 25) continue; // korta rader (rubriker, etiketter) jämförs inte
    const entry = seen.get(normalized);
    if (entry) entry.count += 1;
    else seen.set(normalized, { first: sentence, count: 1 });
  }
  for (const { first, count } of seen.values()) {
    if (count < 2) continue;
    findings.push({
      kind: 'REPETITION',
      term: clip(first),
      excerpt: clip(first),
      suggestion: `Samma mening förekommer ${count} gånger i dokumentet — stryk upprepningen eller skriv om ett av ställena så att varje stycke tillför något nytt.`,
    });
  }

  // 2) Dubblerat ord i följd: "och och", "att att".
  for (const m of text.matchAll(/\b([a-zåäöé]{2,})\s+\1\b/gi)) {
    const from = Math.max(0, m.index! - 30);
    findings.push({
      kind: 'REPETITION',
      term: m[0],
      excerpt: clip(text.slice(from, m.index! + m[0].length + 15).trim()),
      suggestion: 'Dubblerat ord — troligen ett skrivfel.',
    });
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
