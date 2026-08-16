"""Tester for Image Quality v0: headerparsning och kvalitetsgaten."""

import struct
import sys
import unittest
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from image_quality import assess, probe_dimensions  # noqa: E402


def png_bytes(width: int, height: int, pad: int = 0) -> bytes:
    """Minimal giltig PNG-header (IHDR) + utfyllnad for storlekstester."""
    ihdr = struct.pack(">II", width, height) + b"\x08\x02\x00\x00\x00"
    chunk = b"IHDR" + ihdr
    return (b"\x89PNG\r\n\x1a\n" + struct.pack(">I", len(ihdr)) + chunk
            + struct.pack(">I", zlib.crc32(chunk)) + b"\x00" * pad)


def jpeg_bytes(width: int, height: int, pad: int = 0) -> bytes:
    """Minimal JPEG: SOI + APP0 + SOF0 med dimensioner."""
    app0 = b"\xff\xe0" + struct.pack(">H", 16) + b"JFIF\x00" + b"\x00" * 9
    sof = b"\xff\xc0" + struct.pack(">H", 11) + b"\x08" + struct.pack(">HH", height, width) + b"\x01\x11\x00"
    return b"\xff\xd8" + app0 + sof + b"\x00" * pad


class ProbeTests(unittest.TestCase):
    def test_png_dimensions(self):
        self.assertEqual(probe_dimensions(png_bytes(3024, 4032)), (3024, 4032))

    def test_jpeg_dimensions(self):
        self.assertEqual(probe_dimensions(jpeg_bytes(4000, 3000)), (4000, 3000))

    def test_unknown_format(self):
        self.assertIsNone(probe_dimensions(b"fake-image-bytes"))
        self.assertIsNone(probe_dimensions(b""))


class AssessTests(unittest.TestCase):
    def test_too_small_gate(self):
        result = assess(png_bytes(300, 200))
        self.assertEqual(result["verdict"], "too_small")
        self.assertEqual(result["image_quality"], 0.2)
        self.assertIn("narmare", result["recommendation"])

    def test_good_resolution_scores_high(self):
        result = assess(png_bytes(3024, 4032, pad=3024 * 4032 // 10))
        self.assertEqual(result["verdict"], "ok")
        self.assertEqual(result["image_quality"], 0.9)
        self.assertIsNone(result["recommendation"])

    def test_low_resolution_scores_lower(self):
        result = assess(png_bytes(800, 600, pad=800 * 600 // 10))
        self.assertEqual(result["verdict"], "ok")
        self.assertEqual(result["image_quality"], 0.6)

    def test_heavy_compression_flagged(self):
        result = assess(jpeg_bytes(4000, 3000))  # nastan inga bytes/pixel
        self.assertEqual(result["verdict"], "ok")
        self.assertAlmostEqual(result["image_quality"], 0.7)
        self.assertIn("komprimerad", result["recommendation"])

    def test_unknown_format_is_unmeasured_not_scored(self):
        result = assess(b"fake-image-bytes")
        self.assertEqual(result["verdict"], "unknown_format")
        self.assertIsNone(result["image_quality"])


if __name__ == "__main__":
    unittest.main()
