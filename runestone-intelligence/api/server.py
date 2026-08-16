#!/usr/bin/env python3
"""HTTP-tjanst for Runestone Intelligence API (stdlib-only, v0.1).

    python3 server.py --corpus <corpus-dir> --port 8080 \
        [--reader null|http_vlm] [--observations <fil.jsonl>]

Publikt (enligt api/openapi.yaml):
    POST /v1/analyze        JSON: {"image_b64": ..., "latitude"?, "longitude"?,
                                   "consent"?: {media_storage, training_use, ...}}
                            (multipart/form-data kommer med mobilklienten;
                             JSON-formen ar funktionellt ekvivalent)
Internt:
    POST /knowledge/retrieve  {"text"?, "latitude"?, "longitude"?, "rune_type"?,
                               "region"?, "top_k"?}
    POST /verify              {"observed", "candidates"}
    POST /interpret           {"transliteration"}
    GET  /healthz

Med samtycke appenderas varje analys som validerad faltobservation till
--observations (Atlas-inflodet, ADR-0006). Produktionslagring ar PostgreSQL
enligt deployment/ - JSONL-sanken ar referensimplementationens grans.
"""

from __future__ import annotations

import argparse
import base64
import binascii
import json
import sys
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

_HERE = Path(__file__).parent
sys.path.insert(0, str(_HERE))
sys.path.insert(0, str(_HERE.parent / "atlas"))

from explore import nearby  # noqa: E402
from pipeline import AnalyzePipeline  # noqa: E402
from readers import build_reader  # noqa: E402
from retrieval import CorpusIndex  # noqa: E402  (via pipeline sys.path)
from translate import formulaic_translation  # noqa: E402
from verify import verify_against_candidates  # noqa: E402


def make_handler(pipeline: AnalyzePipeline, index: CorpusIndex,
                 observations_path: Path | None):

    class Handler(BaseHTTPRequestHandler):
        server_version = "RunestoneAPI/0.1"

        def _send(self, status: int, payload: dict) -> None:
            body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def _json_body(self) -> dict | None:
            try:
                length = int(self.headers.get("Content-Length", "0"))
                return json.loads(self.rfile.read(length).decode("utf-8")) if length else {}
            except (ValueError, json.JSONDecodeError):
                return None

        def log_message(self, fmt, *args):  # tyst i tester; stdout i drift
            sys.stderr.write("api: " + fmt % args + "\n")

        def do_GET(self):
            if self.path == "/healthz":
                self._send(200, {"status": "ok"})
            else:
                self._send(404, {"error": "not found"})

        def do_POST(self):
            payload = self._json_body()
            if payload is None:
                self._send(400, {"error": "ogiltig JSON"})
                return

            if self.path == "/v1/analyze":
                self._analyze(payload)
            elif self.path == "/v1/explore":
                self._explore(payload)
            elif self.path == "/knowledge/retrieve":
                self._retrieve(payload)
            elif self.path == "/verify":
                self._verify(payload)
            elif self.path == "/interpret":
                self._interpret(payload)
            else:
                self._send(404, {"error": "not found"})

        def _analyze(self, payload: dict) -> None:
            try:
                image = base64.b64decode(payload.get("image_b64", ""), validate=True) or None
            except binascii.Error:
                self._send(400, {"error": "image_b64 ar inte giltig base64"})
                return
            gps = None
            if payload.get("latitude") is not None and payload.get("longitude") is not None:
                gps = (float(payload["latitude"]), float(payload["longitude"]))

            outcome = pipeline.analyze(
                image, gps=gps, consent=payload.get("consent"),
                inference_timestamp=datetime.now(timezone.utc)
                .strftime("%Y-%m-%dT%H:%M:%SZ"),
            )
            if outcome["observation"] is not None and observations_path is not None:
                with observations_path.open("a", encoding="utf-8") as fh:
                    fh.write(json.dumps(outcome["observation"], ensure_ascii=False) + "\n")
            self._send(outcome["status"], outcome["body"])

        def _explore(self, payload: dict) -> None:
            # NASTA RUNSTEN (ADR-0009): narmaste kanda stenar fran positionen.
            if payload.get("latitude") is None or payload.get("longitude") is None:
                self._send(400, {"error": "latitude/longitude kravs"})
                return
            position = (float(payload["latitude"]), float(payload["longitude"]))
            seen = set(payload.get("seen", []))
            results = nearby(index.records(), position,
                             limit=int(payload.get("limit", 5)),
                             exclude_seen=seen,
                             max_km=payload.get("max_km"))
            self._send(200, {"nearby": results})

        def _retrieve(self, payload: dict) -> None:
            gps = None
            if payload.get("latitude") is not None and payload.get("longitude") is not None:
                gps = (float(payload["latitude"]), float(payload["longitude"]))
            try:
                candidates = index.search(
                    query_text=payload.get("text"), gps=gps,
                    rune_type=payload.get("rune_type"), region=payload.get("region"),
                    top_k=int(payload.get("top_k", 5)))
            except ValueError as exc:
                self._send(400, {"error": str(exc)})
                return
            self._send(200, {"candidates": [c.to_dict() for c in candidates]})

        def _verify(self, payload: dict) -> None:
            observed = payload.get("observed")
            if not observed:
                self._send(400, {"error": "observed saknas"})
                return
            self._send(200, verify_against_candidates(observed, payload.get("candidates", [])))

        def _interpret(self, payload: dict) -> None:
            text = payload.get("transliteration")
            if not text:
                self._send(400, {"error": "transliteration saknas"})
                return
            self._send(200, {"formulaic": formulaic_translation(text)})

    return Handler


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--corpus", required=True, type=Path)
    ap.add_argument("--port", type=int, default=8080)
    ap.add_argument("--reader", default="null")
    ap.add_argument("--observations", type=Path, default=None)
    args = ap.parse_args()

    index = CorpusIndex.from_corpus_dir(args.corpus)
    pipeline = AnalyzePipeline(index, build_reader(args.reader))
    server = ThreadingHTTPServer(
        ("0.0.0.0", args.port), make_handler(pipeline, index, args.observations))
    print(f"RunestoneAPI/0.1 pa :{args.port} (reader={args.reader})")
    server.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
