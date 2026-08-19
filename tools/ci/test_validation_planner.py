from __future__ import annotations

import unittest
from pathlib import Path

from unittest import mock

from tools.ci.validation_runner import _execution_command, commands_for_phase
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
        android = plan_validation(["tools/ci/build_android_production.sh"])
        ios = plan_validation(["tools/ci/build_ios_production.sh"])
        shared = plan_validation(["tools/ci/verify_environment_contract.py"])

        self.assertTrue(android.android_build)
        self.assertFalse(android.ios_build)
        self.assertFalse(ios.android_build)
        self.assertTrue(ios.ios_build)
        self.assertTrue(shared.android_build)
        self.assertTrue(shared.ios_build)

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
        self.assertFalse(android.ios_build)
        self.assertFalse(ios.android_build)
        self.assertTrue(ios.ios_build)

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

        android = (root / ".github/workflows/android.yml").read_text(encoding="utf-8")
        ios = (root / ".github/workflows/ios.yml").read_text(encoding="utf-8")
        self.assertIn("inputs.validation_mode || 'focused'", android)
        self.assertIn("inputs.validation_mode || 'focused'", ios)

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

        self.assertTrue(command[0].lower().endswith(r"git\bin\bash.exe"))
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
