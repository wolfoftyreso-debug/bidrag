"""Baseline-adaptrar for RUNEBENCH (Sprint 4, plan §16/§44).

En adapter tar ett benchmarkfall (+ ev. bildfil) och returnerar en
prediction i exakt det format benchmark/evaluate.py konsumerar:

    {"case_id": ..., "transliteration": ..., "confidence": ..., "abstained": ...}

Tre diagnostiska baselines ar korbara utan ML-beroenden:

  oracle    - svarar facit. INTE en modell: ovre sanity-grans som verifierar
              att harnesset ger 100 % nar svaren ar perfekta.
  abstain   - avstar alltid: golv for abstention-metrics och beviset att
              "avsta pa allt" inte ger poang pa lasning.
  constant  - svarar traningssplittens vanligaste translitterering:
              prior-golvet en riktig modell maste sla.

Diagnostiska adaptrar markeras is_diagnostic=True och kan aldrig utgora
ett "baseline-resultat" i rapporter - de ar matstickor for harnesset.
Riktiga baselines (Gemma/generell VLM) kors via http_vlm.HttpVlmAdapter.
"""

from __future__ import annotations

from collections import Counter


class OracleAdapter:
    name = "oracle"
    is_diagnostic = True

    def predict(self, case: dict, image_path=None) -> dict:
        return {
            "case_id": case["case_id"],
            "transliteration": case["expected"]["transliteration"],
            "confidence": 0.99,
            "abstained": False,
        }


class AbstainAdapter:
    name = "abstain"
    is_diagnostic = True

    def predict(self, case: dict, image_path=None) -> dict:
        return {
            "case_id": case["case_id"],
            "transliteration": None,
            "confidence": 0.0,
            "abstained": True,
        }


class ConstantAdapter:
    """Svarar alltid den vanligaste translittereringen i traningsdatat.

    Byggs fran train-partitionen (aldrig test - aven ett golv respekterar
    splitten). Confidence = den vanligaste strangens andel av traningsdatat:
    arligt lag, sa att kalibreringsmatningen far ett meningsfullt golv.
    """

    name = "constant"
    is_diagnostic = True

    def __init__(self, train_transliterations: list[str]):
        if not train_transliterations:
            raise ValueError("constant-baseline kraver traningsdata (train-partitionens translittereringar)")
        counts = Counter(train_transliterations)
        self._answer, top = counts.most_common(1)[0]
        self._confidence = top / len(train_transliterations)

    def predict(self, case: dict, image_path=None) -> dict:
        return {
            "case_id": case["case_id"],
            "transliteration": self._answer,
            "confidence": self._confidence,
            "abstained": False,
        }


def build_adapter(name: str, *, train_transliterations: list[str] | None = None):
    if name == "oracle":
        return OracleAdapter()
    if name == "abstain":
        return AbstainAdapter()
    if name == "constant":
        return ConstantAdapter(train_transliterations or [])
    if name == "http_vlm":
        from http_vlm import HttpVlmAdapter
        return HttpVlmAdapter.from_env()
    raise ValueError(f"okand adapter: {name!r} (kanda: oracle, abstain, constant, http_vlm)")
