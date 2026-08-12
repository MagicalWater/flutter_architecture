from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


class TestAuthoringGovernanceContract(unittest.TestCase):
    def test_central_skill_separates_authoring_from_validation(self) -> None:
        skill = read(".agents/skills/governing-template-development/SKILL.md")
        self.assertIn("Test Authoring Decision", skill)
        self.assertIn("Validation Execution Decision", skill)
        self.assertIn("no-new-test justified", skill)

    def test_tdd_does_not_require_new_test_per_task(self) -> None:
        skill = read(".agents/skills/governing-template-development/SKILL.md")
        governance = read(
            ".agents/skills/governing-template-development/references/two-layer-task-governance.md"
        )
        combined = skill + governance
        self.assertIn("TDD不等於每個Task新增test", combined)
        self.assertIn("0 new tests", combined)

    def test_feature_guide_rejects_layer_for_layer_quota(self) -> None:
        guide = read("docs/guides/how-to-add-feature.md")
        self.assertIn("不是test-density reference", guide)
        self.assertIn("Test Authoring Disposition", guide)
        self.assertNotIn("至少依實際變更覆蓋：", guide)

    def test_testing_governance_defines_four_dispositions(self) -> None:
        guide = read("docs/guides/testing_governance.md")
        for expected in (
            "Required",
            "Recommended",
            "no-new-test justified",
            "Should-not-add",
        ):
            self.assertIn(expected, guide)

    def test_no_new_test_never_means_no_validation(self) -> None:
        guide = read("docs/guides/testing_governance.md")
        self.assertIn("no-new-test justified", guide)
        self.assertIn("不等於不執行validation", guide)


if __name__ == "__main__":
    unittest.main()
