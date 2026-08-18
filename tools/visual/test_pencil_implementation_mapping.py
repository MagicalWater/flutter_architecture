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

    def test_valid_mapping_passes(self) -> None:
        path = self._write(_valid_mapping())

        self.assertEqual(_codes(path), [])

    def test_missing_ui_design_ownerships_fails_closed(self) -> None:
        mapping = _valid_mapping()
        mapping.pop("ui_design_ownerships", None)

        self.assertIn(
            "mapping-missing-ui-design-ownerships", _codes(self._write(mapping))
        )

    def test_missing_screen_layouts_fails_closed(self) -> None:
        mapping = _valid_mapping()
        mapping.pop("screen_layouts")

        self.assertIn("mapping-missing-screen-layouts", _codes(self._write(mapping)))

    def test_unresolved_screen_layout_blocks_acceptance(self) -> None:
        mapping = _valid_mapping()
        mapping["screen_layouts"][0]["layout_model"] = "unresolved"

        self.assertIn(
            "mapping-screen-layout-unresolved",
            _codes(self._write(mapping)),
        )

    def test_spatial_canvas_requires_accepted_approval(self) -> None:
        mapping = _valid_mapping()
        mapping["screen_layouts"][0]["layout_model"] = "intentional-spatial-canvas"

        self.assertIn(
            "mapping-missing-spatial-canvas-approval",
            _codes(self._write(mapping)),
        )

    def test_spatial_canvas_with_approval_passes(self) -> None:
        mapping = _valid_mapping()
        layout = mapping["screen_layouts"][0]
        layout["layout_model"] = "intentional-spatial-canvas"
        layout["approval_ref"] = "docs/superpowers/specs/accepted-spatial-design.md"

        self.assertEqual(_codes(self._write(mapping)), [])

    def test_authority_hash_mismatch_is_rejected(self) -> None:
        path = self._write(_valid_mapping())

        self.assertIn(
            "mapping-authority-hash-mismatch",
            _codes(path, expected_authority_sha256="b" * 64),
        )

    def _write(self, mapping: dict[str, object]) -> Path:
        path = self._root / "implementation_mapping.json"
        path.write_text(json.dumps(mapping), encoding="utf-8")
        return path


def _codes(path: Path, *, expected_authority_sha256: str | None = None) -> list[str]:
    if validate_implementation_mapping is None:
        return ["mapping-validator-missing"]
    return [
        issue.code
        for issue in validate_implementation_mapping(
            path, expected_authority_sha256=expected_authority_sha256
        )
    ]


def _valid_mapping() -> dict[str, object]:
    return {
        "schema_version": 2,
        "initiative": "fixture",
        "pencil_authority_sha256": "a" * 64,
        "screen_layouts": [
            {
                "node_id": "accepted-screen-root",
                "flutter_owner": "FixturePage",
                "layout_model": "constraint-relationship",
                "evidence_ref": "test/fixture_layout_contract_test.dart",
            }
        ],
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
