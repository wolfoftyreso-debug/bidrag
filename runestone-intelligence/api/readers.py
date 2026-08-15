"""Runlasare for API-orkestreringen - pluggbart interface.

En reader tar bildbytes och returnerar:

    {"transliteration": str|None, "confidence": float, "abstained": bool,
     "note": str|None, "uncertainties": [{"position", "candidates"}]}

v0.1 har ingen tranad RuneVision-modell. Det doljs inte: NullReader
abstainar med tydlig orsak, sa att API:et ar arligt tills modellen finns.
HttpVlmReader ateranvander baseline-adaptern (Gemma via vLLM/Ollama) sa att
hela API-flodet kan koras skarpt mot en serverad VLM. MockReader ar for
tester och lokala demos.
"""

from __future__ import annotations

import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "models"))


class NullReader:
    """Ingen runlasningsmodell tillganglig - abstainar alltid, ljuger aldrig."""

    name = "null-reader"

    def read(self, image_bytes: bytes) -> dict:
        return {"transliteration": None, "confidence": 0.0, "abstained": True,
                "note": "runlasningsmodell ej tillganglig i denna miljo",
                "uncertainties": []}


class MockReader:
    """Deterministisk lasare for tester/demos: returnerar en given lasning."""

    name = "mock-reader"

    def __init__(self, transliteration: str | None, confidence: float = 0.9,
                 uncertainties: list[dict] | None = None):
        self._reading = transliteration
        self._confidence = confidence
        self._uncertainties = uncertainties or []

    def read(self, image_bytes: bytes) -> dict:
        if self._reading is None:
            return {"transliteration": None, "confidence": 0.0, "abstained": True,
                    "note": "mock: olasbar bild", "uncertainties": []}
        return {"transliteration": self._reading, "confidence": self._confidence,
                "abstained": False, "note": None,
                "uncertainties": list(self._uncertainties)}


class HttpVlmReader:
    """Skarp lasare via models/http_vlm (OpenAI-kompatibel endpoint)."""

    name = "http-vlm-reader"

    def __init__(self):
        from http_vlm import HttpVlmAdapter
        self._adapter = HttpVlmAdapter.from_env()

    def read(self, image_bytes: bytes) -> dict:
        with tempfile.NamedTemporaryFile(suffix=".jpg") as fh:
            fh.write(image_bytes)
            fh.flush()
            pred = self._adapter.predict({"case_id": "api"}, Path(fh.name))
        return {"transliteration": pred.get("transliteration"),
                "confidence": pred.get("confidence", 0.0),
                "abstained": pred.get("abstained", True),
                "note": pred.get("note"), "uncertainties": []}


def build_reader(name: str):
    if name == "null":
        return NullReader()
    if name == "http_vlm":
        return HttpVlmReader()
    raise ValueError(f"okand reader: {name!r} (kanda: null, http_vlm)")
