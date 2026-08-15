from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path


try:
    from tools.visual.pencil_implementation_mapping import (
        validate_implementation_mapping,
    )
except ModuleNotFoundError:
    validate_implementation_mapping = None


class PencilImplementationMappingContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temp = tempfile.TemporaryDirectory()
        self.addCleanup(self._temp.cleanup)
        self._root = Path(self._temp.name)

    def test_missing_artifact_fails_closed(self) -> None:
        path = self._root / "missing.json"
        self.assertIn("mapping-artifact-missing", _codes(path))

    def test_duplicate_node_id_is_rejected(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"].append(dict(mapping["critical_nodes"][0]))

        self.assertIn("mapping-duplicate-node-id", _codes(self._write(mapping)))

    def test_unknown_representation_class_is_rejected(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"][0]["representation_class"] = "MagicShape"

        self.assertIn(
            "mapping-unknown-representation-class", _codes(self._write(mapping))
        )

    def test_unknown_disposition_is_rejected(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"][0]["disposition"] = "close-enough"

        self.assertIn("mapping-unknown-disposition", _codes(self._write(mapping)))

    def test_unresolved_is_blocking_for_production_acceptance(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"][0]["disposition"] = "unresolved"

        self.assertIn("mapping-unresolved", _codes(self._write(mapping)))

    def test_verified_equivalent_requires_evidence_ref(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"][0]["disposition"] = "verified-equivalent"

        self.assertIn(
            "mapping-missing-equivalence-evidence", _codes(self._write(mapping))
        )

    def test_intentional_deviation_requires_approval_ref(self) -> None:
        mapping = _valid_mapping()
        mapping["critical_nodes"][0]["disposition"] = "intentional-deviation"

        self.assertIn(
            "mapping-missing-deviation-approval", _codes(self._write(mapping))
        )

    def test_asset_mapping_requires_provenance_fields(self) -> None:
        mapping = _valid_mapping()
        node = mapping["critical_nodes"][0]
        node["representation_class"] = "Raster asset"
        node["asset"] = {"source_identity": "assets/example.png"}

        self.assertIn(
            "mapping-incomplete-asset-provenance", _codes(self._write(mapping))
        )

    def _write(self, mapping: dict[str, object]) -> Path:
        path = self._root / "implementation_mapping.json"
        path.write_text(json.dumps(mapping), encoding="utf-8")
        return path


def _codes(path: Path) -> list[str]:
    if validate_implementation_mapping is None:
        return ["mapping-validator-missing"]
    return [issue.code for issue in validate_implementation_mapping(path)]


def _valid_mapping() -> dict[str, object]:
    return {
        "schema_version": 1,
        "initiative": "fixture",
        "pencil_authority_sha256": "a" * 64,
        "critical_nodes": [
            {
                "node_id": "critical-icon-1",
                "role": "primary status icon",
                "representation_class": "Approved package icon",
                "disposition": "exact",
                "flutter_owner": "FixtureStatusIcon",
                "consumer": "FixturePage",
                "icon": {
                    "library": "Material Symbols Rounded",
                    "glyph": "gpp_maybe",
                    "weight": 400,
                    "bounds": {"width": 12, "height": 12},
                    "fill": "#E1535F",
                    "resolved_identity": "fixture:gpp_maybe:rounded:400",
                },
            }
        ],
    }


if __name__ == "__main__":
    unittest.main()
