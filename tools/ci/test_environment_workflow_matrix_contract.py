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
        self.assertIn("tools/ci/validation_planner.py", self.quality)
        self.assertIn("tools/ci/validation_runner.py --phase quality", self.quality)
        self.assertIn("tools/ci/validation_runner.py --phase tests", self.quality)
        self.assertIn("tools/ci/validation_runner.py --phase generated", self.quality)

    def test_ci_uses_validation_planner_and_preserves_required_job_names(self) -> None:
        self.assertIn("name: Classify Changes", self.quality)
        self.assertIn("tools/ci/validation_planner.py", self.quality)
        self.assertIn("plan_b64:", self.quality)
        self.assertIn("fetch-depth: 0", self.quality)
        self.assertIn("needs.classify-changes.outputs.requires_flutter == 'true'", self.quality)
        self.assertIn("name: Quality", self.quality)
        self.assertIn("name: Generated Consistency", self.quality)
        self.assertIn("name: Tests", self.quality)
        self.assertNotIn("Generated Consistency Gate", self.quality)
        self.assertNotIn("Tests Gate", self.quality)

    def test_ci_planner_execution_failure_falls_back_to_full_matrix(self) -> None:
        classify = self.quality.split("  classify-changes:", 1)[1].split(
            "  quality:", 1
        )[0]

        self.assertIn("if ! python3 tools/ci/validation_planner.py", classify)
        self.assertIn('echo "requires_flutter=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "has_flutter_tests=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "generated_check=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "android_build=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "ios_build=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn(
            'echo "reason=validation planner execution failed; fail-safe full matrix"',
            classify,
        )

    def test_ci_required_jobs_use_internal_noop_instead_of_job_skip(self) -> None:
        generated = self.quality.split("  generated-consistency:", 1)[1].split(
            "  tests:", 1
        )[0]
        tests = self.quality.split("  tests:", 1)[1]

        self.assertIn("needs: classify-changes", generated)
        self.assertIn("CI_EXECUTION_MODE", generated)
        self.assertIn("Skip generated consistency", generated)
        self.assertIn("needs.classify-changes.outputs.generated_check != 'true'", generated)

        self.assertIn("needs: classify-changes", tests)
        self.assertIn("CI_EXECUTION_MODE", tests)
        self.assertIn("Skip Flutter tests", tests)
        self.assertIn("needs.classify-changes.outputs.has_flutter_tests != 'true'", tests)

    def test_ci_quality_uses_planned_validation_for_hosted_and_self_hosted(self) -> None:
        quality = self.quality.split("  quality:", 1)[1].split(
            "  generated-consistency:", 1
        )[0]

        self.assertIn("Run managed self-hosted quality", quality)
        self.assertIn("managed-command quality macos", quality)
        self.assertIn("Run planned quality validation", quality)
        self.assertGreaterEqual(
            quality.count("tools/ci/validation_runner.py --phase quality"), 2
        )
        self.assertIn("needs.classify-changes.outputs.requires_flutter", quality)
        self.assertNotIn("tools.ci.test_environment_contract", quality)
        self.assertNotIn("dart run melos run analyze", quality)

    def test_android_keeps_release_check_and_adds_development_debug(self) -> None:
        self.assertIn("name: Release APK", self.android)
        self.assertIn("name: Development Debug APK", self.android)
        self.assertIn("bash tools/ci/build_android_development.sh", self.android)
        self.assertIn("bash tools/ci/build_android_production.sh", self.android)
        self.assertIn("API_BASE_URL: https://api.acme.test", self.android)
        self.assertIn("android-development-debug-${{ github.sha }}", self.android)
        self.assertIn("android-production-release-${{ github.sha }}", self.android)

    def test_android_uses_validation_planner_and_skips_unneeded_builds(self) -> None:
        self.assertIn("name: Classify Changes", self.android)
        self.assertIn("tools/ci/validation_planner.py", self.android)
        self.assertIn("fetch-depth: 0", self.android)
        self.assertIn("needs.classify-changes.outputs.android_build == 'true'", self.android)
        self.assertIn("name: Android Summary", self.android)

        development = self.android.split("  android-development-debug-apk:", 1)[1].split(
            "  android-release-apk:", 1
        )[0]
        release = self.android.split("  android-release-apk:", 1)[1].split(
            "  android-summary:", 1
        )[0]
        self.assertIn("needs: classify-changes", development)
        self.assertIn("needs.classify-changes.outputs.android_build == 'true'", development)
        self.assertIn("CI_EXECUTION_MODE", development)
        self.assertIn("needs: classify-changes", release)
        self.assertIn("needs.classify-changes.outputs.android_build == 'true'", release)
        self.assertIn("CI_EXECUTION_MODE", release)

    def test_android_planner_failure_falls_back_to_full_matrix(self) -> None:
        classify = self.android.split("  classify-changes:", 1)[1].split(
            "  android-development-debug-apk:", 1
        )[0]
        self.assertIn("if ! python3 tools/ci/validation_planner.py", classify)
        self.assertIn("android_build=true", classify)
        self.assertIn("ios_build=true", classify)
        self.assertIn("reason=validation planner execution failure", classify)

    def test_android_summary_propagates_requested_build_failures(self) -> None:
        summary = self.android.split("  android-summary:", 1)[1]
        self.assertIn("always()", summary)
        self.assertIn("CI_EXECUTION_MODE", summary)
        self.assertIn("needs: [classify-changes, android-development-debug-apk, android-release-apk]", summary)
        self.assertIn("needs.android-development-debug-apk.result", summary)
        self.assertIn("needs.android-release-apk.result", summary)
        self.assertIn("exit 1", summary)
        self.assertIn("Android builds skipped", summary)

    def test_ios_keeps_simulator_check_and_adds_unsigned_production_release(self) -> None:
        self.assertIn("name: Simulator Build", self.ios)
        self.assertIn("name: Production Release Build", self.ios)
        self.assertIn("bash tools/ci/build_ios_development.sh", self.ios)
        self.assertIn("bash tools/ci/build_ios_production.sh", self.ios)
        self.assertNotIn("build_ios_production_simulator.sh", self.ios)
        self.assertIn("API_BASE_URL: https://api.acme.test", self.ios)
        self.assertIn("ios-production-release-${{ github.sha }}", self.ios)

    def test_ios_uses_validation_planner_and_keeps_simulator_job_stable(self) -> None:
        self.assertIn("name: Classify Changes", self.ios)
        self.assertIn("tools/ci/validation_planner.py", self.ios)
        self.assertIn("fetch-depth: 0", self.ios)

        simulator = self.ios.split("  simulator-build:", 1)[1].split(
            "  production-release-build:", 1
        )[0]
        production = self.ios.split("  production-release-build:", 1)[1]

        self.assertIn("needs: classify-changes", simulator)
        self.assertIn("CI_EXECUTION_MODE", simulator)
        self.assertIn(
            "needs.classify-changes.outputs.ios_build == 'true'",
            simulator,
        )
        self.assertIn("macos-15", simulator)
        self.assertIn("ubuntu-24.04", simulator)
        self.assertIn("Skip iOS Simulator build", simulator)
        self.assertIn(
            "needs.classify-changes.outputs.ios_build != 'true'",
            simulator,
        )

        self.assertIn("needs: classify-changes", production)
        self.assertIn("needs.classify-changes.outputs.ios_build == 'true'", production)
        self.assertIn("CI_EXECUTION_MODE", production)

    def test_ios_planner_failure_falls_back_to_full_matrix(self) -> None:
        classify = self.ios.split("  classify-changes:", 1)[1].split(
            "  simulator-build:", 1
        )[0]
        self.assertIn("if ! python3 tools/ci/validation_planner.py", classify)
        self.assertIn("requires_flutter=true", classify)
        self.assertIn("android_build=true", classify)
        self.assertIn("ios_build=true", classify)
        self.assertIn("reason=validation planner execution failure", classify)

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
        self.assertNotIn("retention-days: 14", combined)
        self.assertGreaterEqual(combined.count("retention-days: 1"), 6)
        self.assertIn("inputs.artifact_transport == 'full' && 1 || 7", self.ios)
        self.assertIn("github.event_name == 'workflow_dispatch'", combined)
        self.assertIn("runner.environment == 'github-hosted'", combined)
        self.assertIn("tools/ci/artifact_transport.py preflight", combined)
        artifact_names = re.findall(r"name:\s+([^\n]*\$\{\{ github\.sha \}\}[^\n]*)", combined)
        self.assertGreaterEqual(len(artifact_names), 4)

    def test_ios_uploads_success_toolchain_evidence(self) -> None:
        self.assertIn("Upload iOS development toolchain evidence", self.ios)
        self.assertIn("Upload iOS production toolchain evidence", self.ios)
        self.assertIn("ios-development-toolchain-${{ github.sha }}", self.ios)
        self.assertIn("ios-production-toolchain-${{ github.sha }}", self.ios)
        self.assertIn("ios-diagnostics/toolchain.txt", self.ios)
        self.assertIn("ios-production-diagnostics/toolchain.txt", self.ios)


if __name__ == "__main__":
    unittest.main()
