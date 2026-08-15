"""Generisk VLM-baseline over HTTP (Gemma m.fl.) for RUNEBENCH.

Anropar en OpenAI-kompatibel chat-completions-endpoint (t.ex. Gemma serverad
via vLLM eller Ollama) med bild + instruktionsprompt och parsar ett strikt
JSON-svar. Stdlib-only (urllib) - inga klientberoenden.

Konfiguration via miljovariabler:

    VLM_ENDPOINT  t.ex. http://localhost:8000/v1/chat/completions
    VLM_MODEL     t.ex. gemma-3-27b-it
    VLM_API_KEY   valfri (Bearer)

Detta ar Phase 1-matstickan (plan §44): "exakt hur daliga/bra ar generella
VLM:er pa riktiga runfotografier?" Adaptern ljuger aldrig at modellens
fordel: saknad bild, ogiltigt svar eller transportfel blir abstention med
orsak - inte en gissning.
"""

from __future__ import annotations

import base64
import json
import os
import re
import urllib.request
from pathlib import Path

PROMPT = (
    "Du ser ett fotografi av en runinskrift. Las runorna och svara ENDAST "
    "med ett JSON-objekt pa formen "
    '{"transliteration": "<vetenskaplig translitterering med latinska tecken>", '
    '"confidence": <0.0-1.0>, "abstain": <true om bilden inte gar att lasa>}. '
    "Gissa inte: satt abstain=true hellre an att fabricera en lasning."
)

_JSON_RE = re.compile(r"\{.*\}", re.DOTALL)


def extract_prediction(reply_text: str) -> dict | None:
    """Plockar ut {transliteration, confidence, abstain} ur ett modellsvar.

    Tolerant mot ```json-staket och omgivande prosa, strikt mot innehallet:
    fel typer eller confidence utanfor [0,1] ger None (=> abstention),
    aldrig en tillrattalagd gissning.
    """
    m = _JSON_RE.search(reply_text or "")
    if not m:
        return None
    try:
        payload = json.loads(m.group(0))
    except json.JSONDecodeError:
        return None
    if not isinstance(payload, dict):
        return None
    abstain = payload.get("abstain", False)
    transliteration = payload.get("transliteration")
    confidence = payload.get("confidence")
    if not isinstance(abstain, bool):
        return None
    if abstain:
        return {"transliteration": None, "confidence": 0.0, "abstained": True}
    if not isinstance(transliteration, str) or not transliteration.strip():
        return None
    if not isinstance(confidence, (int, float)) or isinstance(confidence, bool) or not 0.0 <= confidence <= 1.0:
        return None
    return {"transliteration": transliteration.strip(), "confidence": float(confidence), "abstained": False}


class HttpVlmAdapter:
    name = "http_vlm"
    is_diagnostic = False

    def __init__(self, endpoint: str, model: str, api_key: str | None = None, timeout: int = 120):
        self.endpoint = endpoint
        self.model = model
        self.api_key = api_key
        self.timeout = timeout

    @classmethod
    def from_env(cls) -> "HttpVlmAdapter":
        endpoint = os.environ.get("VLM_ENDPOINT")
        model = os.environ.get("VLM_MODEL")
        if not endpoint or not model:
            raise RuntimeError(
                "http_vlm kraver VLM_ENDPOINT och VLM_MODEL i miljon "
                "(OpenAI-kompatibel chat-completions-endpoint, t.ex. Gemma via vLLM)"
            )
        return cls(endpoint, model, os.environ.get("VLM_API_KEY"))

    def _abstain(self, case: dict, note: str) -> dict:
        return {"case_id": case["case_id"], "transliteration": None,
                "confidence": 0.0, "abstained": True, "note": note}

    def predict(self, case: dict, image_path: Path | None = None) -> dict:
        if image_path is None or not Path(image_path).is_file():
            return self._abstain(case, "bild saknas lokalt")

        image_b64 = base64.b64encode(Path(image_path).read_bytes()).decode("ascii")
        body = json.dumps({
            "model": self.model,
            "temperature": 0,
            "messages": [{
                "role": "user",
                "content": [
                    {"type": "text", "text": PROMPT},
                    {"type": "image_url",
                     "image_url": {"url": f"data:image/jpeg;base64,{image_b64}"}},
                ],
            }],
        }).encode("utf-8")

        headers = {"Content-Type": "application/json"}
        if self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
        request = urllib.request.Request(self.endpoint, data=body, headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            reply = payload["choices"][0]["message"]["content"]
        except Exception as exc:  # transportfel far aldrig bli en gissning
            return self._abstain(case, f"transportfel: {exc}")

        parsed = extract_prediction(reply)
        if parsed is None:
            return self._abstain(case, "ogiltigt modellsvar")
        return {"case_id": case["case_id"], **parsed}
