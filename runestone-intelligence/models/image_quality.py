"""Image Quality Model v0 - stdlib-heuristik (Modell 1 i arkitekturen).

Utan bildbibliotek i referensmiljon gors det som gar att gora arligt:
dimensioner lases direkt ur JPEG-/PNG-headers och kompressionsgraden
(bytes per pixel) anvands som kvalitetsproxy. Det racker for V1-gaten
"for liten bild -> be om battre foto" - blur/exponering/perspektiv kraver
den tranade modellen (Sprint 5+) och FEJKAS INTE har.

Kontraktet ar detsamma som den riktiga modellens:
    assess(bytes) -> {image_quality, verdict, recommendation, ...}
sa att den kan bytas ut utan att pipelinen andras.

Okant format ger verdict='unknown_format' och image_quality=None -
omatbart rapporteras som omatbart, inte som en siffra.
"""

from __future__ import annotations

import struct

MIN_DIMENSION_PX = 400        # under detta ar ratt beteende att be om nytt foto
LOW_DIMENSION_PX = 1000       # lagupplost men lasbart - sankt score
LOW_BYTES_PER_PIXEL = 0.05    # hart komprimerad JPEG - detaljforlust trolig


def probe_dimensions(data: bytes) -> tuple[int, int] | None:
    """(width, height) ur PNG IHDR eller JPEG SOF-markorer; None om okant."""
    if len(data) > 24 and data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR":
        width, height = struct.unpack(">II", data[16:24])
        return (width, height)

    if len(data) > 4 and data[:2] == b"\xff\xd8":  # JPEG SOI
        i = 2
        while i + 9 < len(data):
            if data[i] != 0xFF:
                i += 1
                continue
            marker = data[i + 1]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                i += 2
                continue
            if i + 4 > len(data):
                break
            length = struct.unpack(">H", data[i + 2:i + 4])[0]
            # SOF0-SOF15 utom DHT/JPG/DAC (C4, C8, CC)
            if 0xC0 <= marker <= 0xCF and marker not in (0xC4, 0xC8, 0xCC):
                if i + 9 <= len(data):
                    height, width = struct.unpack(">HH", data[i + 5:i + 9])
                    return (width, height)
                break
            i += 2 + length
    return None


def assess(data: bytes) -> dict:
    dims = probe_dimensions(data or b"")
    if dims is None:
        return {"image_quality": None, "width": None, "height": None,
                "verdict": "unknown_format",
                "recommendation": None,
                "note": "formatet kunde inte tolkas - kvalitet omatbar i v0"}

    width, height = dims
    min_dim = min(width, height)
    bytes_per_pixel = len(data) / (width * height) if width and height else 0.0

    if min_dim < MIN_DIMENSION_PX:
        return {"image_quality": 0.2, "width": width, "height": height,
                "verdict": "too_small",
                "recommendation": "Flytta kameran narmare - bilden ar for liten for att lasa runor.",
                "note": None}

    score = 0.9 if min_dim >= LOW_DIMENSION_PX else 0.6
    recommendation = None
    if bytes_per_pixel < LOW_BYTES_PER_PIXEL:
        score = round(score - 0.2, 2)
        recommendation = "Bilden ar hart komprimerad - skicka garna i hogre kvalitet."

    return {"image_quality": score, "width": width, "height": height,
            "verdict": "ok", "recommendation": recommendation, "note": None}
