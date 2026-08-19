from __future__ import annotations

import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(REPOSITORY_ROOT / "tools" / "visual"))

from pencil_implementation_mapping import validate_implementation_mapping  # noqa: E402


class PencilImplementationMappingEvidenceReferenceTest(unittest.TestCase):
    def setUp(self) -> None:
        self.mapping_path = (
            REPOSITORY_ROOT
            / "docs"
            / "visual_authority"
            / "pencil-compatibility-write-precheck"
            / "implementation_mapping.json"
        )
        self.mapping = json.loads(self.mapping_path.read_text(encoding="utf-8"))

    def _validate_with_evidence(self, evidence_ref: str) -> set[str]:
        data = copy.deepcopy(self.mapping)
        data["screen_layouts"][0]["evidence_ref"] = evidence_ref
        with tempfile.NamedTemporaryFile(
            mode="w",
            suffix=".json",
            dir=REPOSITORY_ROOT,
            encoding="utf-8",
            delete=False,
        ) as temporary:
            json.dump(data, temporary)
            temporary_path = Path(temporary.name)
        try:
            return {
                issue.code
                for issue in validate_implementation_mapping(temporary_path)
            }
        finally:
            temporary_path.unlink(missing_ok=True)

    def test_live_repository_relative_evidence_passes(self) -> None:
        codes = self._validate_with_evidence(
            "apps/flutter_architecture/lib/features/pencil_compatibility/"
            "presentation/widgets/write_precheck/write_precheck_content.dart"
        )
        self.assertNotIn("mapping-evidence-missing", codes)
        self.assertNotIn("mapping-evidence-outside-repository", codes)

    def test_missing_evidence_fails_closed(self) -> None:
        codes = self._validate_with_evidence("docs/does-not-exist.md")
        self.assertIn("mapping-evidence-missing", codes)

    def test_repository_escape_fails_closed(self) -> None:
        codes = self._validate_with_evidence("../outside.md")
        self.assertIn("mapping-evidence-outside-repository", codes)


if __name__ == "__main__":
    unittest.main()
