from pathlib import Path
import re
import unittest


POLICY_FILES = (
    Path(
        "docs/adr/"
        "adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md"
    ),
    Path(
        ".agents/skills/implementing-pencil-flutter-design/references/"
        "flutter-mapping.md"
    ),
    Path(
        ".agents/skills/implementing-pencil-flutter-design/references/"
        "visual-validation.md"
    ),
    Path("docs/guides/pencil_to_flutter_workflow.md"),
)


def _normalized(path: Path) -> str:
    text = path.read_text(encoding="utf-8").lower()
    return re.sub(r"\s+", " ", text)


class PencilSingleRendererPolicyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.text_by_path = {path: _normalized(path) for path in POLICY_FILES}
        cls.all_text = " ".join(cls.text_by_path.values())

    def test_canonical_viewport_is_design_space_not_flutter_breakpoint(self) -> None:
        self.assertIn("design/comparison space", self.all_text)
        self.assertIn("flutter logical breakpoint", self.all_text)

    def test_parallel_whole_screen_renderer_is_forbidden(self) -> None:
        self.assertIn("parallel whole-screen visual renderer", self.all_text)
        self.assertIn("one accepted screen", self.all_text)

    def test_runtime_layout_health_is_not_visual_fidelity(self) -> None:
        self.assertIn("layout health", self.all_text)
        self.assertIn("runtime fidelity", self.all_text)

    def test_supported_runtime_requires_visual_fidelity_evidence(self) -> None:
        self.assertIn("supported runtime", self.all_text)
        self.assertIn("visual fidelity evidence", self.all_text)

    def test_top_level_fixed_canvas_scaling_remains_forbidden(self) -> None:
        self.assertIn("fittedbox", self.all_text)
        self.assertIn("transform.scale", self.all_text)
        self.assertIn("top-level", self.all_text)

    def test_canonical_page_coordinates_are_not_runtime_page_coordinates(self) -> None:
        self.assertIn("canonical page", self.all_text)
        self.assertIn("runtime page coordinate", self.all_text)

    def test_screen_flow_is_constraint_relationship_owned(self) -> None:
        self.assertIn("constraint", self.all_text)
        self.assertIn("relationship", self.all_text)
        self.assertIn("page-flow ownership", self.all_text)

    def test_bounded_local_overlay_remains_legal(self) -> None:
        self.assertIn("bounded local overlay", self.all_text)
        self.assertIn("stack", self.all_text)
        self.assertIn("positioned", self.all_text)

    def test_spatial_canvas_requires_accepted_approval(self) -> None:
        self.assertIn("intentional-spatial-canvas", self.all_text)
        self.assertIn("approval_ref", self.all_text)

    def test_single_renderer_does_not_exempt_coordinate_reconstruction(self) -> None:
        self.assertIn("single-renderer", self.all_text)
        self.assertIn("canonical-coordinate reconstruction", self.all_text)


if __name__ == "__main__":
    unittest.main()
