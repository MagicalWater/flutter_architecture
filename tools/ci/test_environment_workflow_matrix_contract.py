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

    def test_ci_uses_change_classifier_and_preserves_required_job_names(self) -> None:
        self.assertIn("name: Classify Changes", self.quality)
        self.assertIn("tools/ci/change_classifier.py", self.quality)
        self.assertIn("fetch-depth: 0", self.quality)
        self.assertIn("needs.classify-changes.outputs.full_ci == 'true'", self.quality)
        self.assertIn("name: Quality", self.quality)
        self.assertIn("name: Generated Consistency", self.quality)
        self.assertIn("name: Tests", self.quality)
        self.assertNotIn("Generated Consistency Gate", self.quality)
        self.assertNotIn("Tests Gate", self.quality)

    def test_ci_classifier_execution_failure_falls_back_to_full_matrix(self) -> None:
        classify = self.quality.split("  classify-changes:", 1)[1].split(
            "  quality:", 1
        )[0]

        self.assertIn("if ! python3 tools/ci/change_classifier.py", classify)
        self.assertIn('echo "docs_only=false" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "full_ci=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "android_build=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "ios_build=true" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn('echo "release_full=false" >> "$GITHUB_OUTPUT"', classify)
        self.assertIn(
            'echo "reason=classifier execution failed; fail-safe full matrix"',
            classify,
        )

    def test_ci_required_jobs_use_internal_noop_instead_of_job_skip(self) -> None:
        generated = self.quality.split("  generated-consistency:", 1)[1].split(
            "  tests:", 1
        )[0]
        tests = self.quality.split("  tests:", 1)[1]

        self.assertIn("needs: classify-changes", generated)
        self.assertNotRegex(generated, r"(?m)^    if:")
        self.assertIn("Skip generated consistency", generated)
        self.assertIn("needs.classify-changes.outputs.full_ci != 'true'", generated)

        self.assertIn("needs: classify-changes", tests)
        self.assertNotRegex(tests, r"(?m)^    if:")
        self.assertIn("Skip Flutter tests", tests)
        self.assertIn("needs.classify-changes.outputs.full_ci != 'true'", tests)

    def test_ci_quality_keeps_light_checks_unconditional(self) -> None:
        quality = self.quality.split("  quality:", 1)[1].split(
            "  generated-consistency:", 1
        )[0]

        for step_name in (
            "Check documentation",
            "Check CI workflow contracts",
            "Check whitespace errors",
        ):
            match = re.search(
                rf"      - name: {re.escape(step_name)}\n(?P<body>(?:        .*\n)*)",
                quality,
            )
            self.assertIsNotNone(match, step_name)
            self.assertNotIn("if:", match.group("body"))

        analyze = re.search(
            r"      - name: Analyze workspace\n(?P<body>(?:        .*\n)*)",
            quality,
        )
        self.assertIsNotNone(analyze)
        self.assertIn(
            "needs.classify-changes.outputs.full_ci == 'true'",
            analyze.group("body"),
        )

    def test_android_keeps_release_check_and_adds_development_debug(self) -> None:
        self.assertIn("name: Release APK", self.android)
        self.assertIn("name: Development Debug APK", self.android)
        self.assertIn("bash tools/ci/build_android_development.sh", self.android)
        self.assertIn("bash tools/ci/build_android_production.sh", self.android)
        self.assertIn("API_BASE_URL: https://api.acme.test", self.android)
        self.assertIn("android-development-debug-${{ github.sha }}", self.android)
        self.assertIn("android-production-release-${{ github.sha }}", self.android)

    def test_android_uses_change_classifier_and_skips_build_jobs_for_docs_only(self) -> None:
        self.assertIn("name: Classify Changes", self.android)
        self.assertIn("tools/ci/change_classifier.py", self.android)
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
        self.assertIn("if: needs.classify-changes.outputs.android_build == 'true'", development)
        self.assertIn("needs: classify-changes", release)
        self.assertIn("if: needs.classify-changes.outputs.android_build == 'true'", release)

    def test_android_classifier_failure_falls_back_to_full_matrix(self) -> None:
        classify = self.android.split("  classify-changes:", 1)[1].split(
            "  android-development-debug-apk:", 1
        )[0]
        self.assertIn("if ! python3 tools/ci/change_classifier.py", classify)
        self.assertIn("android_build=true", classify)
        self.assertIn("ios_build=true", classify)
        self.assertIn("reason=classifier execution failure", classify)

    def test_android_summary_propagates_requested_build_failures(self) -> None:
        summary = self.android.split("  android-summary:", 1)[1]
        self.assertIn("if: always()", summary)
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

    def test_ios_uploads_success_toolchain_evidence(self) -> None:
        self.assertIn("Upload iOS development toolchain evidence", self.ios)
        self.assertIn("Upload iOS production toolchain evidence", self.ios)
        self.assertIn("ios-development-toolchain-${{ github.sha }}", self.ios)
        self.assertIn("ios-production-toolchain-${{ github.sha }}", self.ios)
        self.assertIn("ios-diagnostics/toolchain.txt", self.ios)
        self.assertIn("ios-production-diagnostics/toolchain.txt", self.ios)


if __name__ == "__main__":
    unittest.main()
