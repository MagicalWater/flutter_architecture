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


if __name__ == "__main__":
    unittest.main()
