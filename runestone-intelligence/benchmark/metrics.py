"""Metrics for RUNEBENCH (plan §25).

Stdlib-only, deterministiska, enhetstestade mot handraknade varden.
Alla returnerar None nar matningen ar odefinierad (t.ex. inga fall)
i stallet for att gissa 0 eller 1 - en rapport far aldrig se battre ut
for att data saknas.
"""

from __future__ import annotations


def edit_distance(a: str, b: str) -> int:
    """Levenshtein pa teckenniva (eller tokenniva om listor ges)."""
    if a == b:
        return 0
    if not a:
        return len(b)
    if not b:
        return len(a)
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, start=1):
        cur = [i]
        for j, cb in enumerate(b, start=1):
            cur.append(min(
                prev[j] + 1,          # deletion
                cur[j - 1] + 1,       # insertion
                prev[j - 1] + (ca != cb),  # substitution
            ))
        prev = cur
    return prev[-1]


def cer(reference: str, hypothesis: str) -> float | None:
    """Character Error Rate. Odefinierad (None) for tom referens."""
    if not reference:
        return None
    return edit_distance(reference, hypothesis) / len(reference)


def wer(reference: str, hypothesis: str) -> float | None:
    """Word Error Rate pa whitespace-tokens."""
    ref_tokens = reference.split()
    if not ref_tokens:
        return None
    return edit_distance(ref_tokens, hypothesis.split()) / len(ref_tokens)


def rune_accuracy(reference: str, hypothesis: str) -> float | None:
    """Per-tecken-accuracy: 1 - CER, golvad vid 0 (CER kan overstiga 1)."""
    c = cer(reference, hypothesis)
    return None if c is None else max(0.0, 1.0 - c)


def sequence_correct(reference: str, hypothesis: str) -> bool:
    """Hela sekvensen ratt, efter whitespace-normalisering."""
    return " ".join(reference.split()) == " ".join(hypothesis.split())


def expected_calibration_error(pairs: list[tuple[float, bool]], bins: int = 10) -> float | None:
    """ECE: |medelconfidence - faktisk correctness| viktat per bin.

    pairs: (confidence 0..1, correct). Confidence ska jamforas mot faktisk
    correctness - ett officiellt benchmark-krav (plan §25 Calibration).
    """
    if not pairs:
        return None
    buckets: list[list[tuple[float, bool]]] = [[] for _ in range(bins)]
    for conf, correct in pairs:
        idx = min(int(conf * bins), bins - 1)
        buckets[idx].append((conf, correct))
    total = len(pairs)
    ece = 0.0
    for bucket in buckets:
        if not bucket:
            continue
        avg_conf = sum(c for c, _ in bucket) / len(bucket)
        accuracy = sum(1 for _, ok in bucket if ok) / len(bucket)
        ece += (len(bucket) / total) * abs(avg_conf - accuracy)
    return ece


def abstention_metrics(cases: list[dict]) -> dict:
    """Abstention quality (officiellt KPI, plan §25).

    cases: {expected_abstain: bool, abstained: bool, correct: bool|None}.

    - true_abstentions:   borde avsta och avstod
    - false_confidence:   borde avsta men svarade anda (varsta utfallet)
    - over_abstentions:   avstod fast fallet var lasbart
    - abstention_f1:      F1 for att avsta pa ratt fall (None om inga
                          expected_abstain-fall finns)
    """
    tp = sum(1 for c in cases if c["expected_abstain"] and c["abstained"])
    fn = sum(1 for c in cases if c["expected_abstain"] and not c["abstained"])
    fp = sum(1 for c in cases if not c["expected_abstain"] and c["abstained"])
    expected = tp + fn

    precision = tp / (tp + fp) if (tp + fp) else None
    recall = tp / expected if expected else None
    f1 = None
    if precision is not None and recall is not None and (precision + recall) > 0:
        f1 = 2 * precision * recall / (precision + recall)
    elif expected and (tp + fp):
        f1 = 0.0

    return {
        "expected_abstain_cases": expected,
        "true_abstentions": tp,
        "false_confidence": fn,
        "over_abstentions": fp,
        "abstention_precision": precision,
        "abstention_recall": recall,
        "abstention_f1": f1,
    }
