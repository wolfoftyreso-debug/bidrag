"""Signum-normalisering.

Runinskrifter identifieras med signum ("U 489", "Sö 101", "DR 42").
Kallorna skriver dem olika: varierande mellanslag, skiftlage, †-markering
for forsvunna stenar och tidskriftssignum ("U Fv1955;219"). Matchningen
signum <-> inscription <-> image kraver en kanonisk nyckel.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

# Vanliga provinskoder/korpuskoder (svenska landskap + nordiska korpusar).
# Anvands for validering; okanda koder avvisas hellre an gissas.
KNOWN_CODES = {
    "u", "sö", "ög", "vg", "sm", "nä", "vs", "g", "öl", "hs", "gs", "j",
    "m", "bo", "ds", "vr", "d", "sk", "bl", "ha", "lp", "x",
    "dr", "n", "is", "br", "sc", "ir", "fr", "gr",
}

_SIGNUM_RE = re.compile(r"^([A-Za-zÀ-ž]+)\s*(.+)$")


@dataclass(frozen=True)
class Signum:
    code: str        # provins-/korpuskod, gemener ("u", "sö", "dr")
    number: str      # resten av signumet, normaliserad ("489", "fv1955;219")
    lost: bool       # † i kallan: stenen ar forsvunnen

    @property
    def key(self) -> str:
        """Kanonisk matchningsnyckel, t.ex. 'u:489'."""
        return f"{self.code}:{self.number}"

    @property
    def display(self) -> str:
        """Visningsform, t.ex. 'U 489' ('†' visas inte - lost ar metadata)."""
        return f"{self.code.capitalize()} {self.number.upper()}"


class SignumError(ValueError):
    pass


def parse_signum(raw: str) -> Signum:
    if not raw or not raw.strip():
        raise SignumError("tomt signum")
    text = raw.strip()
    lost = "†" in text
    text = text.replace("†", "").strip()

    m = _SIGNUM_RE.match(text)
    if not m:
        raise SignumError(f"kan inte tolka signum: {raw!r}")
    code = m.group(1).lower()
    number = re.sub(r"\s+", " ", m.group(2).strip().lower())
    if code not in KNOWN_CODES:
        raise SignumError(f"okand provins-/korpuskod {code!r} i signum {raw!r}")
    if not number:
        raise SignumError(f"signum saknar nummer: {raw!r}")
    return Signum(code=code, number=number, lost=lost)


def signum_key(raw: str) -> str:
    return parse_signum(raw).key


def signum_slug(raw: str) -> str:
    """Slug for id-bruk: 'U 489' -> 'u-489' (endast [a-z0-9-])."""
    key = signum_key(raw)
    slug = re.sub(r"[^a-z0-9]+", "-", key.replace("ö", "o").replace("ä", "a").replace("å", "a"))
    return slug.strip("-")
