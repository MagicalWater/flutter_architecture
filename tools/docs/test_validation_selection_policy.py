from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class ValidationSelectionPolicyTest(unittest.TestCase):
    def test_stable_and_human_authorities_route_to_single_planner(self) -> None:
        paths = (
            "AGENTS.md",
            "docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md",
            "docs/guides/testing_governance.md",
            "docs/guides/how-to-add-feature.md",
            "docs/guides/agent_assisted_development_quick_start.md",
            "docs/guides/ci_cd_operations.md",
        )
        for relative in paths:
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("Minimum Sufficient Validation", text, relative)
            self.assertIn("validation_planner.py", text, relative)

    def test_agents_does_not_require_full_flutter_suite_for_every_commit(self) -> None:
        agents = (ROOT / "AGENTS.md").read_text(encoding="utf-8")

        self.assertNotIn(
            "- `dart run melos exec -- flutter test` 通過。",
            agents,
        )
        self.assertIn("holistic", agents)
        self.assertIn("release", agents)

    def test_feature_guide_uses_affected_validation_not_unconditional_full(self) -> None:
        guide = (ROOT / "docs/guides/how-to-add-feature.md").read_text(
            encoding="utf-8"
        )

        self.assertIn("affected", guide)
        self.assertIn("planner", guide.lower())
        self.assertNotIn(
            "從 workspace root 執行：\n\n```bash\n"
            "dart pub get\n"
            "dart run melos run build_runner\n"
            "dart run melos run docs_check\n"
            "dart run melos run analyze\n"
            "dart run melos exec -- flutter test\n```",
            guide,
        )

    def test_testing_governance_tracks_current_inventory_and_separates_tiers(self) -> None:
        guide = (ROOT / "docs/guides/testing_governance.md").read_text(
            encoding="utf-8"
        )

        self.assertIn("last_reviewed_baseline: 1.15.2", guide)
        self.assertIn("35-3_current_test_inventory.csv", guide)
        self.assertIn("validation level", guide.lower())
        self.assertIn("execution tier", guide.lower())


if __name__ == "__main__":
    unittest.main()
