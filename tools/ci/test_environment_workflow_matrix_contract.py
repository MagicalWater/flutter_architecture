from pathlib import Path
import re
import unittest


ROOT = Path(__file__).resolve().parents[2]
ANDROID = ROOT / ".github" / "workflows" / "android.yml"
IOS = ROOT / ".github" / "workflows" / "ios.yml"
QUALITY = ROOT / ".github" / "workflows" / "ci.yml"


class EnvironmentWorkflowMatrixContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.android = ANDROID.read_text(encoding="utf-8")
        self.ios = IOS.read_text(encoding="utf-8")
        self.quality = QUALITY.read_text(encoding="utf-8")

    def test_quality_gate_enforces_environment_and_workflow_contracts(self) -> None:
        self.assertIn("tools.ci.test_environment_contract", self.quality)
        self.assertIn("tools.ci.test_environment_workflow_matrix_contract", self.quality)
        self.assertIn("tools.ci.test_local_build_commands", self.quality)

    def test_android_keeps_release_check_and_adds_development_debug(self) -> None:
        self.assertIn("name: Release APK", self.android)
        self.assertIn("name: Development Debug APK", self.android)
        self.assertIn("bash tools/ci/build_android_development.sh", self.android)
        self.assertIn("bash tools/ci/build_android_production.sh", self.android)
        self.assertIn("API_BASE_URL: https://api.acme.test", self.android)
        self.assertIn("android-development-debug-${{ github.sha }}", self.android)
        self.assertIn("android-production-release-${{ github.sha }}", self.android)

    def test_ios_keeps_simulator_check_and_adds_unsigned_production_release(self) -> None:
        self.assertIn("name: Simulator Build", self.ios)
        self.assertIn("name: Production Release Build", self.ios)
        self.assertIn("bash tools/ci/build_ios_development.sh", self.ios)
        self.assertIn("bash tools/ci/build_ios_production.sh", self.ios)
        self.assertNotIn("build_ios_production_simulator.sh", self.ios)
        self.assertIn("API_BASE_URL: https://api.acme.test", self.ios)
        self.assertIn("ios-production-release-${{ github.sha }}", self.ios)

    def test_workflows_do_not_read_store_or_signing_secrets(self) -> None:
        combined = f"{self.android}\n{self.ios}"
        self.assertNotIn("secrets.", combined)
        self.assertNotIn("KEYSTORE", combined)
        self.assertNotIn("PROVISIONING_PROFILE", combined)
        self.assertNotIn("MATCH_PASSWORD", combined)
        self.assertNotIn("APP_STORE", combined)

    def test_external_actions_remain_full_sha_pinned(self) -> None:
        for workflow in (self.android, self.ios):
            uses_lines = [line.strip() for line in workflow.splitlines() if "uses:" in line]
            self.assertTrue(uses_lines)
            for line in uses_lines:
                self.assertRegex(
                    line,
                    r"uses:\s+[^@\s]+@[0-9a-f]{40}(?:\s|$)",
                )

    def test_artifact_uploads_are_bounded_and_sha_scoped(self) -> None:
        combined = f"{self.android}\n{self.ios}"
        self.assertGreaterEqual(combined.count("retention-days: 14"), 3)
        self.assertIn("retention-days: 7", self.ios)
        artifact_names = re.findall(r"name:\s+([^\n]*\$\{\{ github\.sha \}\}[^\n]*)", combined)
        self.assertGreaterEqual(len(artifact_names), 4)


if __name__ == "__main__":
    unittest.main()
