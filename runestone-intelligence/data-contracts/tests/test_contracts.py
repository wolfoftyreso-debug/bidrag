"""Tester for data contracts: exempel validerar, och kontrakten avvisar
det de ska avvisa (provenance saknas, fel split-enhet, production utan
benchmark, gold utan verifiering, okand licens som tillater traning)."""

import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from validator import validate_record  # noqa: E402

EXAMPLES = Path(__file__).parent.parent / "examples"


def load_example(name: str) -> tuple[str, dict]:
    with (EXAMPLES / f"{name}.example.json").open(encoding="utf-8") as fh:
        payload = json.load(fh)
    return payload["$schema_name"], payload["record"]


class ExamplesAreValid(unittest.TestCase):
    def test_all_examples_validate(self):
        for path in sorted(EXAMPLES.glob("*.json")):
            with path.open(encoding="utf-8") as fh:
                payload = json.load(fh)
            errors = validate_record(payload["record"], payload["$schema_name"])
            self.assertEqual(errors, [], f"{path.name}: {errors}")


class ProvenanceIsMandatory(unittest.TestCase):
    def test_inscription_without_provenance_fails(self):
        schema, record = load_example("inscription")
        record = copy.deepcopy(record)
        del record["provenance"]
        self.assertTrue(any("provenance" in e for e in validate_record(record, schema)))

    def test_provenance_without_license_fails(self):
        schema, record = load_example("inscription")
        record = copy.deepcopy(record)
        del record["provenance"]["license"]
        self.assertTrue(any("license" in e for e in validate_record(record, schema)))

    def test_bad_checksum_fails(self):
        schema, record = load_example("inscription")
        record = copy.deepcopy(record)
        record["provenance"]["checksum"] = "md5:abc"
        self.assertTrue(validate_record(record, schema))

    def test_unknown_extra_field_fails(self):
        schema, record = load_example("inscription")
        record = copy.deepcopy(record)
        record["free_form_answer"] = "hallucination"
        self.assertTrue(any("free_form_answer" in e for e in validate_record(record, schema)))


class SplitPolicyIsStoneLevel(unittest.TestCase):
    def test_image_level_split_rejected(self):
        schema, record = load_example("dataset-manifest")
        record = copy.deepcopy(record)
        record["split_policy"]["unit"] = "image_id"
        self.assertTrue(validate_record(record, schema))

    def test_mutable_dataset_rejected(self):
        schema, record = load_example("dataset-manifest")
        record = copy.deepcopy(record)
        record["immutable"] = False
        self.assertTrue(validate_record(record, schema))


class ModelGovernance(unittest.TestCase):
    def test_production_without_benchmark_rejected(self):
        schema, record = load_example("model-registry-entry")
        record = copy.deepcopy(record)
        record["status"] = "PRODUCTION"
        record["benchmark_results"] = None
        errors = validate_record(record, schema)
        self.assertTrue(any("benchmark" in e for e in errors))

    def test_training_without_benchmark_is_fine(self):
        schema, record = load_example("model-registry-entry")
        record = copy.deepcopy(record)
        record["status"] = "TRAINING"
        record["benchmark_results"] = None
        self.assertEqual(validate_record(record, schema), [])


class ImageRights(unittest.TestCase):
    def test_unknown_rights_cannot_allow_training(self):
        schema, record = load_example("image-rights")
        record = copy.deepcopy(record)
        record["rights_status"] = "unknown"
        record["usage"]["training_allowed"] = True
        errors = validate_record(record, schema)
        self.assertTrue(any("unknown" in e for e in errors))

    def test_unknown_rights_with_training_disallowed_ok(self):
        schema, record = load_example("image-rights")
        record = copy.deepcopy(record)
        record["rights_status"] = "unknown"
        record["usage"]["training_allowed"] = False
        self.assertEqual(validate_record(record, schema), [])


class BenchmarkGovernance(unittest.TestCase):
    def test_gold_requires_verifier(self):
        schema, record = load_example("benchmark-case")
        record = copy.deepcopy(record)
        record["verified_by"] = None
        errors = validate_record(record, schema)
        self.assertTrue(any("verified_by" in e for e in errors))

    def test_null_inscription_only_for_unknown_stone(self):
        schema, record = load_example("benchmark-case")
        record = copy.deepcopy(record)
        record["inscription_id"] = None
        errors = validate_record(record, schema)
        self.assertTrue(any("kategori I" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
