from __future__ import annotations

import unittest
import json
import subprocess
from pathlib import Path

from unittest import mock

from tools.ci.validation_runner import _execution_command, commands_for_phase
from tools.ci.run_release_validation import (
    RunEvidence,
    _selected_families,
    _wait_for_run,
    run_release_validation,
)
from tools.ci.validation_planner import (
    apply_release_freshness,
    can_reuse_validation_evidence,
    plan_payload,
    plan_validation,
    validation_evidence_identity,
)


class ValidationPlannerCriticalContractTest(unittest.TestCase):
    def test_version_is_metadata_not_release(self) -> None:
        plan = plan_validation(["VERSION"])

        self.assertEqual(plan.validation_level, "focused")
        self.assertFalse(plan.full_regression)
        self.assertFalse(plan.release_full)
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)
        self.assertTrue(plan.docs_check)

    def test_ordinary_feature_change_does_not_build_platforms(self) -> None:
        plan = plan_validation(
            ["apps/flutter_architecture/lib/features/auth/presentation/auth_page.dart"]
        )

        self.assertEqual(plan.validation_level, "affected")
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)
        self.assertFalse(plan.full_regression)

    def test_feature_without_permanent_owner_does_not_fall_back_to_app_suite(self) -> None:
        plan = plan_validation(
            ["apps/flutter_architecture/lib/features/profile/presentation/profile_view.dart"]
        )

        self.assertEqual(plan.validation_level, "affected")
        self.assertEqual(plan.flutter_test_scopes, ())
        self.assertEqual(plan.analyze_scopes, ("apps/flutter_architecture",))

    def test_package_change_uses_affected_scope_without_platform_builds(self) -> None:
        plan = plan_validation(["packages/auth/lib/src/auth_repository.dart"])

        self.assertEqual(plan.validation_level, "affected")
        self.assertEqual(plan.flutter_test_scopes, ("packages/auth/test",))
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)
        self.assertFalse(plan.full_regression)

    def test_zero_test_package_is_not_sent_to_flutter_test(self) -> None:
        plan = plan_validation(["packages/design_system/lib/src/tokens.dart"])

        self.assertNotIn("packages/design_system/test", plan.flutter_test_scopes)
        self.assertEqual(plan.flutter_test_scopes, ())
        self.assertIn("apps/flutter_architecture", plan.analyze_scopes)

    def test_platform_build_scripts_select_real_platform_evidence(self) -> None:
        android_dev = plan_validation(["tools/ci/build_android_development.sh"])
        android = plan_validation(["tools/ci/build_android_production.sh"])
        ios_sim = plan_validation(["tools/ci/build_ios_development.sh"])
        ios = plan_validation(["tools/ci/build_ios_production.sh"])
        shared = plan_validation(["tools/ci/verify_environment_contract.py"])

        self.assertTrue(android_dev.android_development_build)
        self.assertFalse(android_dev.android_production_build)
        self.assertTrue(android.android_build)
        self.assertFalse(android.android_development_build)
        self.assertTrue(android.android_production_build)
        self.assertFalse(android.ios_build)
        self.assertTrue(ios_sim.ios_simulator_build)
        self.assertFalse(ios_sim.ios_production_build)
        self.assertFalse(ios.android_build)
        self.assertTrue(ios.ios_build)
        self.assertFalse(ios.ios_simulator_build)
        self.assertTrue(ios.ios_production_build)
        self.assertTrue(shared.android_build)
        self.assertTrue(shared.ios_build)
        self.assertTrue(shared.android_development_build)
        self.assertTrue(shared.android_production_build)
        self.assertTrue(shared.ios_simulator_build)
        self.assertTrue(shared.ios_production_build)

    def test_database_change_keeps_generated_validation_without_platform_builds(self) -> None:
        plan = plan_validation(
            ["apps/flutter_architecture/lib/app/database/app_database.dart"]
        )

        self.assertTrue(plan.generated_check)
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)

    def test_unknown_path_fails_safe_to_logical_full_without_platform_builds(self) -> None:
        plan = plan_validation(["unexpected/root.file"])

        self.assertEqual(plan.validation_level, "full")
        self.assertTrue(plan.full_regression)
        self.assertTrue(plan.fail_safe)
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)

    def test_manual_focused_is_not_implicit_release(self) -> None:
        plan = plan_validation([], manual=True, manual_mode="focused")

        self.assertEqual(plan.validation_level, "focused")
        self.assertFalse(plan.full_regression)
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)

    def test_manual_full_is_logical_full_without_platforms(self) -> None:
        plan = plan_validation([], manual=True, manual_mode="full")

        self.assertEqual(plan.validation_level, "full")
        self.assertTrue(plan.full_regression)
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)

    def test_manual_platform_modes_are_explicit(self) -> None:
        android = plan_validation([], manual=True, manual_mode="android")
        ios = plan_validation([], manual=True, manual_mode="ios")

        self.assertTrue(android.android_build)
        self.assertTrue(android.android_development_build)
        self.assertTrue(android.android_production_build)
        self.assertFalse(android.ios_build)
        self.assertFalse(ios.android_build)
        self.assertTrue(ios.ios_build)
        self.assertTrue(ios.ios_simulator_build)
        self.assertTrue(ios.ios_production_build)

    def test_release_freshness_preserves_changed_risk_scope(self) -> None:
        cases = (
            (["docs/README.md"], False, False, False, False),
            (["AGENTS.md"], False, False, False, False),
            (
                ["apps/flutter_architecture/lib/app/database/app_database.dart"],
                False,
                True,
                False,
                False,
            ),
            (["apps/flutter_architecture/android/app/build.gradle.kts"], False, False, True, False),
            (["apps/flutter_architecture/ios/Runner/Info.plist"], False, False, False, True),
            (["pubspec.lock"], True, True, True, True),
            (["tools/ci/validation_planner.py"], True, True, True, True),
            ([".github/workflows/android.yml"], True, True, True, False),
            ([".github/workflows/ios.yml"], True, True, False, True),
            ([".github/workflows/ci.yml"], True, True, False, False),
        )

        for paths, full, generated, android, ios in cases:
            with self.subTest(paths=paths):
                plan = apply_release_freshness(plan_validation(paths), paths)
                self.assertEqual(plan.validation_level, "release")
                self.assertTrue(plan.release_full)
                self.assertEqual(plan.full_regression, full)
                self.assertEqual(plan.generated_check, generated)
                self.assertEqual(plan.android_build, android)
                self.assertEqual(plan.ios_build, ios)

        validation_engine = apply_release_freshness(
            plan_validation(["tools/ci/validation_planner.py"]),
            ["tools/ci/validation_planner.py"],
        )
        self.assertFalse(validation_engine.android_development_build)
        self.assertTrue(validation_engine.android_production_build)
        self.assertFalse(validation_engine.ios_simulator_build)
        self.assertTrue(validation_engine.ios_production_build)

        android_workflow = apply_release_freshness(
            plan_validation([".github/workflows/android.yml"]),
            [".github/workflows/android.yml"],
        )
        self.assertTrue(android_workflow.android_development_build)
        self.assertTrue(android_workflow.android_production_build)

        ios_workflow = apply_release_freshness(
            plan_validation([".github/workflows/ios.yml"]),
            [".github/workflows/ios.yml"],
        )
        self.assertTrue(ios_workflow.ios_simulator_build)
        self.assertTrue(ios_workflow.ios_production_build)

    def test_release_invalid_range_fails_safe_to_full_generated_both_platforms(self) -> None:
        plan = apply_release_freshness(
            plan_validation([], invalid_range=True),
            (),
            invalid_range=True,
        )

        self.assertEqual(plan.validation_level, "release")
        self.assertTrue(plan.full_regression)
        self.assertTrue(plan.generated_check)
        self.assertTrue(plan.android_build)
        self.assertTrue(plan.ios_build)
        self.assertTrue(plan.android_development_build)
        self.assertTrue(plan.android_production_build)
        self.assertTrue(plan.ios_simulator_build)
        self.assertTrue(plan.ios_production_build)
        self.assertTrue(plan.fail_safe)

    def test_release_workflows_use_explicit_base_and_classifier_fallback(self) -> None:
        root = Path(__file__).resolve().parents[2]
        for relative in (
            ".github/workflows/ci.yml",
            ".github/workflows/android.yml",
            ".github/workflows/ios.yml",
        ):
            with self.subTest(workflow=relative):
                source = (root / relative).read_text(encoding="utf-8")
                self.assertIn("release_base:", source)
                self.assertIn("inputs.validation_mode == 'release' && inputs.release_base", source)
                self.assertIn("tools/ci/change_classifier.py", source)
                self.assertIn(
                    "logical full fallback with classifier platform impact",
                    source,
                )

        ci = (root / ".github/workflows/ci.yml").read_text(encoding="utf-8")
        android = (root / ".github/workflows/android.yml").read_text(encoding="utf-8")
        ios = (root / ".github/workflows/ios.yml").read_text(encoding="utf-8")
        for workflow in (ci, android, ios):
            self.assertIn("workflow_dispatch:", workflow)
            self.assertNotIn("pull_request:\n", workflow)
        self.assertIn("inputs.validation_mode || 'focused'", android)
        self.assertIn("inputs.validation_mode || 'focused'", ios)
        self.assertIn("android_development_build: ${{ steps.classify.outputs.android_development_build }}", android)
        self.assertIn("android_production_build: ${{ steps.classify.outputs.android_production_build }}", android)
        self.assertIn("needs.classify-changes.outputs.android_development_build == 'true'", android)
        self.assertIn("needs.classify-changes.outputs.android_production_build == 'true'", android)
        self.assertNotIn("tools/ci/verify_generated.sh", android)
        self.assertIn("ios_simulator_build: ${{ steps.classify.outputs.ios_simulator_build }}", ios)
        self.assertIn("ios_production_build: ${{ steps.classify.outputs.ios_production_build }}", ios)
        self.assertIn("needs.classify-changes.outputs.ios_simulator_build == 'true'", ios)
        self.assertIn("needs.classify-changes.outputs.ios_production_build == 'true'", ios)

    def test_release_orchestrator_selects_only_planner_evidence_families(self) -> None:
        self.assertEqual(
            _selected_families(
                {
                    "docs_check": True,
                    "generated_check": False,
                    "flutter_test_scopes": [],
                    "python_test_scopes": [],
                    "analyze_scopes": [],
                    "android_build": False,
                    "ios_build": False,
                }
            ),
            ("ci",),
        )
        self.assertEqual(
            _selected_families(
                {
                    "docs_check": False,
                    "generated_check": False,
                    "flutter_test_scopes": [],
                    "python_test_scopes": [],
                    "analyze_scopes": [],
                    "android_build": True,
                    "ios_build": True,
                }
            ),
            ("android", "ios"),
        )

    @mock.patch("tools.ci.run_release_validation._wait_for_run")
    @mock.patch("tools.ci.run_release_validation._find_run_id")
    @mock.patch("tools.ci.run_release_validation._listed_runs")
    @mock.patch("tools.ci.run_release_validation._dispatch_workflow")
    @mock.patch("tools.ci.run_release_validation._assert_candidate_identity")
    @mock.patch("tools.ci.run_release_validation._current_branch")
    @mock.patch("tools.ci.run_release_validation.plan_release_range")
    def test_release_orchestrator_dispatches_all_families_before_waiting(
        self,
        plan_release: mock.Mock,
        current_branch: mock.Mock,
        assert_identity: mock.Mock,
        dispatch: mock.Mock,
        listed_runs: mock.Mock,
        find_run: mock.Mock,
        wait_run: mock.Mock,
    ) -> None:
        plan_release.return_value = apply_release_freshness(
            plan_validation(["pubspec.lock"]), ["pubspec.lock"]
        )
        current_branch.return_value = "candidate"
        listed_runs.return_value = []
        find_run.side_effect = [101, 102, 103]
        wait_run.side_effect = lambda family, run_id, **_: RunEvidence(
            family, run_id, "head", "success", "url", "c", "s", "u"
        )

        evidence = run_release_validation(
            repository=Path("."),
            base="base",
            head="head",
            execution_mode="github-hosted",
        )

        self.assertEqual([call.args[0] for call in dispatch.call_args_list], ["ci", "android", "ios"])
        self.assertEqual(dispatch.call_count, 3)
        self.assertEqual(find_run.call_count, 3)
        self.assertEqual(wait_run.call_count, 3)
        self.assertEqual(tuple(item.family for item in evidence), ("ci", "android", "ios"))
        assert_identity.assert_called_once()

    @mock.patch("tools.ci.run_release_validation._run")
    def test_release_orchestrator_rejects_run_sha_mismatch(self, run: mock.Mock) -> None:
        run.side_effect = [
            subprocess.CompletedProcess([], 0, "", ""),
            subprocess.CompletedProcess(
                [],
                0,
                json.dumps(
                    {
                        "headSha": "wrong",
                        "conclusion": "success",
                        "url": "url",
                        "createdAt": "c",
                        "startedAt": "s",
                        "updatedAt": "u",
                    }
                ),
                "",
            ),
        ]

        with self.assertRaisesRegex(RuntimeError, "SHA mismatch"):
            _wait_for_run("ci", 101, repository=Path("."), head="expected")

    @mock.patch("tools.ci.validation_runner.shutil.which")
    def test_windows_batch_shim_is_executed_through_cmd(self, which: mock.Mock) -> None:
        which.return_value = r"C:\flutter\bin\dart.bat"

        command = _execution_command(
            ["dart", "run", "melos", "run", "analyze"],
            platform_name="nt",
        )

        self.assertEqual(command[1:4], ["/d", "/s", "/c"])
        self.assertEqual(command[0].lower().replace("/", "\\").split("\\")[-1], "cmd.exe")
        self.assertIn("dart run melos run analyze", command[4])

    @mock.patch("tools.ci.validation_runner.Path.is_file")
    def test_windows_bash_prefers_git_bash_over_wsl_shim(self, is_file: mock.Mock) -> None:
        is_file.side_effect = [True]

        command = _execution_command(
            ["bash", "tools/ci/verify_generated.sh"],
            platform_name="nt",
        )

        normalized = command[0].lower().replace("\\", "/")
        self.assertTrue(normalized.endswith("git/bin/bash.exe"))
        self.assertEqual(command[1:], ["tools/ci/verify_generated.sh"])

    def test_same_identity_can_be_reused_for_holistic_and_post_release(self) -> None:
        plan = plan_validation(["docs/README.md"])
        identity = validation_evidence_identity(
            plan, ["docs/README.md"], phase="quality"
        )

        for gate in ("holistic", "post_release"):
            self.assertTrue(
                can_reuse_validation_evidence(
                    previous_identity=identity,
                    current_identity=identity,
                    same_task=True,
                    previous_passed=True,
                    gate=gate,
                )
            )

    def test_release_gate_requires_fresh_evidence(self) -> None:
        plan = plan_validation(["docs/README.md"])
        identity = validation_evidence_identity(
            plan, ["docs/README.md"], phase="quality"
        )

        self.assertFalse(
            can_reuse_validation_evidence(
                previous_identity=identity,
                current_identity=identity,
                same_task=True,
                previous_passed=True,
                gate="release",
            )
        )


if __name__ == "__main__":
    unittest.main()
