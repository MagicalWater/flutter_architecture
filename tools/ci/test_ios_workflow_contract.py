from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
WORKFLOW = ROOT / ".github" / "workflows" / "ios.yml"
QUALITY_WORKFLOW = ROOT / ".github" / "workflows" / "ci.yml"


class IosWorkflowContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.text = WORKFLOW.read_text(encoding="utf-8")

    def test_uses_stable_named_macos_simulator_build_gate(self) -> None:
        self.assertIn("name: iOS", self.text)
        self.assertIn("name: Simulator Build", self.text)
        self.assertIn("runs-on: macos-15", self.text)
        self.assertIn("bash tools/ci/build_ios_development.sh", self.text)
        self.assertIn("name: Production Release Build", self.text)
        self.assertIn("bash tools/ci/build_ios_production.sh", self.text)

    def test_uses_minimal_permissions_exact_toolchain_and_safe_concurrency(self) -> None:
        self.assertRegex(self.text, r"permissions:\s*\n\s+contents: read")
        self.assertIn("source .github/versions.env", self.text)
        self.assertIn("flutter-version: ${{ steps.versions.outputs.flutter_version }}", self.text)
        self.assertIn("cancel-in-progress: true", self.text)
        self.assertNotIn("pull_request_target:", self.text)

    def test_external_actions_are_full_sha_pinned(self) -> None:
        uses_lines = [
            line.strip() for line in self.text.splitlines() if "uses:" in line
        ]
        self.assertTrue(uses_lines)
        for line in uses_lines:
            match = re.search(r"uses:\s+[^@\s]+@([0-9a-f]{40})(?:\s|$)", line)
            self.assertIsNotNone(match, line)

    def test_failure_diagnostics_and_verification_artifacts_are_bounded(self) -> None:
        self.assertIn("if: failure()", self.text)
        self.assertIn("retention-days: 7", self.text)
        self.assertIn("retention-days: 14", self.text)
        self.assertIn("if-no-files-found: ignore", self.text)
        self.assertIn("distribution=not production-ready", (
            ROOT / "tools" / "ci" / "build_ios_environment.sh"
        ).read_text(encoding="utf-8"))

    def test_contract_is_enforced_by_repository_quality_gate(self) -> None:
        quality_text = QUALITY_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("python3 -m unittest", quality_text)
        self.assertIn("tools.ci.test_ios_workflow_contract", quality_text)
        self.assertIn("tools.ci.test_shell_portability_contract", quality_text)
        self.assertIn("tools.ci.test_ios_workflow_contract", self.text)
        self.assertIn(
            "tools.ci.test_environment_workflow_matrix_contract",
            self.text,
        )


if __name__ == "__main__":
    unittest.main()
