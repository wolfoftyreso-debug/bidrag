"""IDENTITY LOCK - vagvalet mellan Known Stone Path och Unknown Stone Path
(ADR-0008).

    score >= 0.95      LOCK      hamta verifierad post, las inte om runorna
    0.70 <= s < 0.95   REVIEW    jamfor flera kandidater innan beslut
    score < 0.70       FALLBACK  Unknown Stone Path: faktisk runlasning

Sparrar som alltid galler oavsett score:

- En gps_only-kandidat kan aldrig ge LOCK eller REVIEW-underlag - GPS ar
  signal, inte facit (ADR-0007). Den kan bara sanka till FALLBACK med
  forslag.
- En LOW-match fran verifieringen bryter LOCK: om den observerade lasningen
  motsager den kanonicka texten ar identiteten inte last, oavsett hur bra
  bildmatchningen ar. Avvikelsen kan vara fel sten - eller en forandring
  pa stenen (Atlas-signal).
"""

from __future__ import annotations

from dataclasses import dataclass, field

LOCK_THRESHOLD = 0.95
REVIEW_THRESHOLD = 0.70


@dataclass
class IdentityDecision:
    mode: str                      # "lock" | "review" | "fallback"
    locked: dict | None = None     # kandidaten vid lock
    candidates: list = field(default_factory=list)  # vid review: topplistan
    reason: str = ""

    def to_dict(self) -> dict:
        return {"mode": self.mode,
                "locked": self.locked,
                "candidates": self.candidates,
                "reason": self.reason}


def decide(candidates: list[dict], *, verification_match: str | None = None) -> IdentityDecision:
    """candidates: dict-form fran retrieval (Candidate.to_dict), rankade.
    verification_match: HIGH/MEDIUM/LOW nar en lasning har verifierats mot
    toppkandidaten, annars None (t.ex. ren bildidentifiering)."""
    identifiable = [c for c in candidates if not c.get("gps_only")]
    if not identifiable:
        return IdentityDecision(
            mode="fallback", candidates=candidates,
            reason="endast GPS-forslag - GPS kan aldrig lasa identitet")

    top = identifiable[0]
    score = top.get("score", 0.0)

    if verification_match == "LOW":
        return IdentityDecision(
            mode="fallback", candidates=identifiable[:5],
            reason="lasningen motsager kandidaten - identitet ej last, alternativ analys")

    if score >= LOCK_THRESHOLD:
        return IdentityDecision(
            mode="lock", locked=top,
            reason=f"score {score:.3f} >= {LOCK_THRESHOLD}: verifierad post anvands")

    if score >= REVIEW_THRESHOLD:
        return IdentityDecision(
            mode="review", candidates=identifiable[:5],
            reason=f"score {score:.3f} i granskningsbandet "
                   f"[{REVIEW_THRESHOLD}, {LOCK_THRESHOLD}): jamfor kandidater")

    return IdentityDecision(
        mode="fallback", candidates=identifiable[:5],
        reason=f"score {score:.3f} < {REVIEW_THRESHOLD}: Unknown Stone Path (runlasning)")
