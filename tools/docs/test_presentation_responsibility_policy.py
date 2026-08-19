from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


class PresentationResponsibilityPolicyTest(unittest.TestCase):
    def test_fresh_admission_routes_to_adr_032(self) -> None:
        agents = _read("AGENTS.md")
        feature_skill = _read(".agents/skills/starting-feature-work/SKILL.md")
        guide = _read("docs/guides/how-to-add-feature.md")
        self.assertIn("ADR-032", agents)
        self.assertIn("ADR-032", feature_skill)
        self.assertIn("ADR-032", guide)

    def test_pencil_mapping_uses_responsibility_roles_not_fixed_tree(self) -> None:
        mapping = _read(
            ".agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md"
        )
        self.assertIn("responsibility roles", mapping)
        self.assertIn("不是mandatory", mapping)
        self.assertIn("part`／`part of", mapping)
        self.assertIn("line count", mapping)
        self.assertIn("Cubit", mapping)

    def test_pressure_scenarios_cover_both_monolith_and_formalism(self) -> None:
        scenarios = _read(
            ".agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md"
        )
        for scenario in range(35, 47):
            self.assertIn(f"PTF-{scenario}", scenarios)
        self.assertIn("one-widget-one-file", scenarios)
        self.assertIn("Handwritten part false split", scenarios)
        self.assertIn("Shell launcher versus Dialog owner", scenarios)

    def test_pressure_scenarios_cover_component_constraint_and_color_edges(self) -> None:
        scenarios = _read(
            ".agents/skills/implementing-pencil-flutter-design/references/pressure-scenarios.md"
        )
        for scenario in range(47, 59):
            self.assertIn(f"PTF-{scenario}", scenarios)
        self.assertIn("Bounded component fixed-canvas laundering", scenarios)
        self.assertIn("Public left/top component API", scenarios)
        self.assertIn("Generic positioned-text engine", scenarios)
        self.assertIn("Relationship-owned DataRow", scenarios)
        self.assertIn("Blanket Stack ban", scenarios)
        self.assertIn("Line-count splitting oracle", scenarios)
        self.assertIn("Generic Flow framework inflation", scenarios)
        self.assertIn("Same-semantic RGB drift duplication", scenarios)
        self.assertIn("Near-identical literals, different semantics", scenarios)
        self.assertIn("Intentional component-local decorative color", scenarios)
        self.assertIn("Theme/Design System scope creep", scenarios)

    def test_pencil_mapping_and_human_guide_share_m44_bounded_rules(self) -> None:
        mapping = _read(
            ".agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md"
        )
        guide = _read("docs/guides/pencil_to_flutter_workflow.md")
        self.assertIn("representation noise", mapping)
        self.assertIn("intentional contextual variant", mapping)
        self.assertIn("Theme/Design System production refactor", mapping)
        self.assertIn("Bounded component同樣不取得normal-content coordinate ownership", mapping)
        self.assertIn("local fixed canvas", guide)
        self.assertIn("raw RGB不同", guide)


if __name__ == "__main__":
    unittest.main()
