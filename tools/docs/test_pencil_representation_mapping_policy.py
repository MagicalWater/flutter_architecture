from pathlib import Path
import re
import unittest


ASSET_MAPPING_REFERENCE = Path(
    ".agents/skills/implementing-pencil-flutter-design/references/"
    "asset-and-typography-mapping.md"
)

POLICY_FILES = (
    Path(".agents/skills/implementing-pencil-flutter-design/SKILL.md"),
    Path(
        ".agents/skills/implementing-pencil-flutter-design/references/"
        "flutter-mapping.md"
    ),
    ASSET_MAPPING_REFERENCE,
    Path("docs/guides/pencil_to_flutter_workflow.md"),
)


def _normalized(path: Path) -> str:
    if not path.exists():
        return f"missing policy file: {path.as_posix()}"
    text = path.read_text(encoding="utf-8").lower()
    return re.sub(r"\s+", " ", text)


class PencilRepresentationMappingPolicyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text_by_path = {path: _normalized(path) for path in POLICY_FILES}
        cls.all_text = " ".join(cls.text_by_path.values())

    def assert_contract(self, token: str) -> None:
        self.assertTrue(
            token in self.all_text,
            f"missing representation policy contract: {token}",
        )

    def test_asset_typography_mapping_reference_exists(self) -> None:
        self.assertTrue(
            ASSET_MAPPING_REFERENCE.exists(),
            f"missing policy file: {ASSET_MAPPING_REFERENCE.as_posix()}",
        )

    def test_representation_classification_precedes_flutter_mapping(self) -> None:
        self.assert_contract("representation classification")

    def test_missing_font_authority_fails_closed(self) -> None:
        self.assert_contract("typography authority unresolved")

    def test_approximate_icon_is_not_visual_equivalence(self) -> None:
        self.assert_contract("approximate icon")

    def test_derived_asset_transformation_is_traceable(self) -> None:
        self.assert_contract("derived transformation")

    def test_raster_everything_shortcut_is_forbidden(self) -> None:
        self.assert_contract("raster-everything")

    def test_static_custompainter_overbuild_is_forbidden(self) -> None:
        self.assert_contract("static custompainter")


if __name__ == "__main__":
    unittest.main()
