"""Datasetversionering: immutable manifest + deterministisk split pa
sten-/inskriftsniva (ADR-0002).

Splitten hashar inscription_id (inte bild-id): alla bilder av samma sten
hamnar per konstruktion i samma partition. En del av testmangden reserveras
som unknown_stone_test - stenar vars id aldrig far forekomma i traning.
Hashbaserad split ar stabil: nya stenar i en senare version flyttar inte
gamla stenar mellan partitioner.
"""

from __future__ import annotations

import hashlib

from contracts import canonical_json, sha256_of, validated

DEFAULT_FRACTIONS = {"train": 0.8, "val": 0.1, "test": 0.1}


def _bucket(seed: int, inscription_id: str) -> float:
    digest = hashlib.sha256(f"{seed}:{inscription_id}".encode()).hexdigest()
    return int(digest[:12], 16) / 16**12


def stone_level_split(
    inscription_ids: list[str],
    *,
    seed: int,
    fractions: dict | None = None,
    unknown_stone_share_of_test: float = 0.3,
) -> dict[str, str]:
    """-> {inscription_id: 'train'|'val'|'test'|'unknown_stone_test'}"""
    fr = fractions or DEFAULT_FRACTIONS
    if abs(sum(fr.values()) - 1.0) > 1e-9:
        raise ValueError("fractions maste summera till 1.0")

    split: dict[str, str] = {}
    train_edge = fr["train"]
    val_edge = fr["train"] + fr["val"]
    for iid in sorted(set(inscription_ids)):
        b = _bucket(seed, iid)
        if b < train_edge:
            split[iid] = "train"
        elif b < val_edge:
            split[iid] = "val"
        else:
            # Oversta delen av testintervallet viks av till unknown-stone-setet;
            # aven det avgors av hashen sa att det ar stabilt over versioner.
            test_pos = (b - val_edge) / (1.0 - val_edge)
            split[iid] = "unknown_stone_test" if test_pos >= 1.0 - unknown_stone_share_of_test else "test"
    return split


def build_manifest(
    *,
    dataset_name: str,
    dataset_version: str,
    layer: str,
    records: list[dict],
    source_datasets: list[dict],
    created_at: str,
    seed: int,
    parent_version: str | None = None,
) -> dict:
    manifest = {
        "dataset_name": dataset_name,
        "dataset_version": dataset_version,
        "layer": layer,
        "created_at": created_at,
        "immutable": True,
        "records_count": len(records),
        "checksum": sha256_of("\n".join(canonical_json(r) for r in records)),
        "parent_version": parent_version,
        "source_datasets": source_datasets,
        "split_policy": {
            "unit": "inscription_id",
            "unknown_stone_test_set": True,
            "seed": seed,
        },
    }
    valid, errors = validated(manifest, "dataset-manifest")
    if valid is None:
        raise ValueError(f"ogiltigt manifest: {errors}")
    return valid
