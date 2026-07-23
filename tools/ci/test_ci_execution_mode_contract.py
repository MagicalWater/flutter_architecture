from pathlib import Path
import unittest

from tools.ci.ci_execution_mode_contract import (
    VALID_EXECUTION_MODES,
    resolve_execution_mode,
)


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = (
    ROOT / ".github/workflows/ci.yml",
    ROOT / ".github/workflows/android.yml",
    ROOT / ".github/workflows/ios.yml",
    ROOT / ".github/workflows/observability-acceptance.yml",
)


class CiExecutionModeContractTest(unittest.TestCase):
    def test_accepts_only_three_explicit_modes(self) -> None:
        self.assertEqual(
            VALID_EXECUTION_MODES,
            frozenset({"manual-local", "self-hosted", "github-hosted"}),
        )
        for value in ("manual-local", "self-hosted", "github-hosted"):
            self.assertEqual(resolve_execution_mode(value, None), value)

    def test_rejects_legacy_local_and_unknown_values(self) -> None:
        for value in ("local", "", "unexpected", None):
            with self.assertRaises(ValueError):
                resolve_execution_mode(value, None)

    def test_manual_override_wins_without_mutating_repository_value(self) -> None:
        repository_value = "manual-local"
        self.assertEqual(
            resolve_execution_mode(repository_value, "self-hosted"),
            "self-hosted",
        )
        self.assertEqual(repository_value, "manual-local")

    def test_repository_default_uses_repository_value(self) -> None:
        self.assertEqual(
            resolve_execution_mode("self-hosted", "repository-default"),
            "self-hosted",
        )

    def test_repository_default_is_not_a_runtime_mode(self) -> None:
        self.assertNotIn("repository-default", VALID_EXECUTION_MODES)

    def test_workflows_expose_execution_mode_choice_and_reject_legacy_switches(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertIn("execution_mode:", text, workflow.name)
            self.assertIn("default: repository-default", text, workflow.name)
            for value in (
                "repository-default",
                "manual-local",
                "self-hosted",
                "github-hosted",
            ):
                self.assertIn(value, text, workflow.name)
            self.assertNotIn("run_hosted:", text, workflow.name)
            self.assertNotIn("inputs.run_hosted", text, workflow.name)
            self.assertNotIn("CI_EXECUTION_MODE == 'local'", text, workflow.name)

    def test_self_hosted_jobs_require_the_complete_trusted_label_set(self) -> None:
        required = (
            '"self-hosted"',
            '"macOS"',
            '"ARM64"',
            '"flutter-architecture"',
            '"trusted-main"',
        )
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            for label in required:
                self.assertIn(label, text, workflow.name)
            self.assertNotRegex(text, r"runs-on:\s*self-hosted\s*$")

    def test_self_hosted_policy_is_main_or_manual_only(self) -> None:
        ci = WORKFLOWS[0].read_text(encoding="utf-8")
        ios = WORKFLOWS[2].read_text(encoding="utf-8")
        for text in (ci, ios):
            self.assertIn("github.event_name == 'pull_request'", text)
            self.assertIn("vars.CI_EXECUTION_MODE == 'github-hosted'", text)
            self.assertNotIn(
                "github.event_name == 'pull_request' && vars.CI_EXECUTION_MODE == 'self-hosted'",
                text,
            )

        observability = WORKFLOWS[3].read_text(encoding="utf-8")
        self.assertIn("github.event_name == 'workflow_dispatch'", observability)
        self.assertIn("inputs.remote_acceptance == true", observability)
        self.assertNotIn("github.event_name == 'push' || inputs.remote_acceptance", observability)

    def test_local_entrypoint_exposes_all_supported_suites(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")
        for suite in ("quality", "android", "ios", "observability", "all"):
            self.assertIn(f"{suite})", script)
        self.assertIn("build_android_development.sh", script)
        self.assertIn("build_ios_development.sh", script)
        self.assertIn("upload_ios_dsyms.sh", script)
        self.assertIn("manual-local", script)
        self.assertNotIn("CI_EXECUTION_MODE=local", script)


if __name__ == "__main__":
    unittest.main()
