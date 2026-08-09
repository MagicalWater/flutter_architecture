from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from tools.ci.change_classifier import classify_paths
from tools.ci.validation_planner import (
    can_reuse_validation_evidence,
    load_workspace_packages,
    plan_validation,
    reverse_dependency_closure,
    validation_evidence_identity,
)


CANONICAL_SCENARIOS = {
    "docs_content": ["docs/guides/example.md"],
    "governance": ["AGENTS.md"],
    "tooling": ["tools/docs/check_docs.py"],
    "test_only": [
        "apps/flutter_architecture/test/features/profile/profile_bloc_test.dart"
    ],
    "app_feature": [
        "apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart"
    ],
    "app_shared": ["apps/flutter_architecture/lib/app/router/app_router.dart"],
    "package": ["packages/core/lib/src/result.dart"],
    "generated": ["apps/flutter_architecture/lib/app/router/app_router.gr.dart"],
    "database": ["apps/flutter_architecture/lib/app/database/app_database.dart"],
    "android_native": ["apps/flutter_architecture/android/app/build.gradle.kts"],
    "ios_native": ["apps/flutter_architecture/ios/Runner/Info.plist"],
    "dependency": ["pubspec.lock"],
    "validation_engine": ["tools/ci/change_classifier.py"],
    "unknown": ["unexpected/config.bin"],
    "release": ["VERSION"],
    "mixed": [
        "docs/guides/example.md",
        "packages/core/lib/src/result.dart",
    ],
}


EXPECTED_PLAN_FIELDS = {
    "change_classes",
    "validation_level",
    "flutter_test_scopes",
    "python_test_scopes",
    "analyze_scopes",
    "docs_check",
    "generated_check",
    "android_build",
    "ios_build",
    "full_regression",
    "release_full",
    "reason",
    "fail_safe",
}


class ValidationPlannerContractRedTest(unittest.TestCase):
    def test_validation_planner_schema_is_complete(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["docs_content"])
        missing = EXPECTED_PLAN_FIELDS - set(vars(result))
        self.assertFalse(missing, f"planner schema fields missing: {sorted(missing)}")

    def test_current_feature_change_still_over_escalates(self) -> None:
        result = classify_paths(CANONICAL_SCENARIOS["app_feature"])

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_current_package_change_still_over_escalates(self) -> None:
        result = classify_paths(CANONICAL_SCENARIOS["package"])

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)


class ValidationPlannerRoutingTest(unittest.TestCase):
    def test_docs_content_is_focused_docs_only(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["docs_content"])

        self.assertEqual(result.change_classes, ("docs_content",))
        self.assertEqual(result.validation_level, "focused")
        self.assertTrue(result.docs_check)
        self.assertFalse(result.full_regression)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_feature_source_is_affected_without_platform_builds(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["app_feature"])

        self.assertEqual(result.change_classes, ("app_feature",))
        self.assertEqual(result.validation_level, "affected")
        self.assertIn(
            "apps/flutter_architecture/test/features/profile",
            result.flutter_test_scopes,
        )
        self.assertFalse(result.full_regression)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_leaf_test_change_runs_only_changed_test(self) -> None:
        path = CANONICAL_SCENARIOS["test_only"][0]
        result = plan_validation([path])

        self.assertEqual(result.validation_level, "focused")
        self.assertEqual(result.flutter_test_scopes, (path,))
        self.assertFalse(result.full_regression)

    def test_android_native_only_escalates_android(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["android_native"])

        self.assertEqual(result.change_classes, ("android_native",))
        self.assertTrue(result.android_build)
        self.assertFalse(result.ios_build)
        self.assertFalse(result.full_regression)

    def test_ios_native_only_escalates_ios(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["ios_native"])

        self.assertEqual(result.change_classes, ("ios_native",))
        self.assertFalse(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertFalse(result.full_regression)

    def test_unknown_path_fails_safe_to_full(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["unknown"])

        self.assertEqual(result.validation_level, "full")
        self.assertTrue(result.full_regression)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertTrue(result.fail_safe)

    def test_release_requires_full_and_both_platforms(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["release"])

        self.assertEqual(result.validation_level, "release")
        self.assertTrue(result.full_regression)
        self.assertTrue(result.release_full)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_workspace_metadata_loads_all_members(self) -> None:
        packages = load_workspace_packages(Path("."))

        self.assertEqual(
            {package.name for package in packages},
            {"flutter_architecture", "api_client", "auth", "core", "design_system"},
        )

    def test_design_system_reverse_dependency_reaches_app_only(self) -> None:
        affected = reverse_dependency_closure("design_system", repository=Path("."))

        self.assertEqual(
            {package.name for package in affected},
            {"design_system", "flutter_architecture"},
        )

    def test_leaf_package_plan_uses_real_reverse_dependents(self) -> None:
        result = plan_validation(
            ["packages/design_system/lib/src/theme/app_theme.dart"],
            repository=Path("."),
        )

        self.assertEqual(result.validation_level, "affected")
        self.assertEqual(
            set(result.flutter_test_scopes),
            {"packages/design_system/test", "apps/flutter_architecture/test"},
        )
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_validation_engine_change_is_full_fail_safe_verification(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["validation_engine"])

        self.assertEqual(result.validation_level, "full")
        self.assertTrue(result.full_regression)
        self.assertTrue(result.generated_check)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_mixed_docs_and_package_change_uses_higher_risk_scope(self) -> None:
        result = plan_validation(CANONICAL_SCENARIOS["mixed"])

        self.assertEqual(result.change_classes, ("docs_content", "package"))
        self.assertEqual(result.validation_level, "affected")
        self.assertTrue(result.docs_check)
        self.assertFalse(result.full_regression)

    def test_direct_script_cli_runs_from_repository_root(self) -> None:
        completed = subprocess.run(
            [
                sys.executable,
                "tools/ci/validation_planner.py",
                "--event",
                "workflow_dispatch",
                "--stdout-json",
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(completed.returncode, 0, completed.stderr)
        payload = json.loads(completed.stdout)
        self.assertEqual(payload["validation_level"], "release")
        self.assertTrue(payload["full_regression"])

    def test_direct_script_cli_writes_ci_output(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "output.txt"
            completed = subprocess.run(
                [
                    sys.executable,
                    "tools/ci/validation_planner.py",
                    "--event",
                    "workflow_dispatch",
                    "--output",
                    str(output),
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertEqual(completed.returncode, 0, completed.stderr)
            values = dict(
                line.split("=", 1)
                for line in output.read_text(encoding="utf-8").splitlines()
            )
            self.assertEqual(values["requires_flutter"], "true")
            self.assertEqual(values["has_flutter_tests"], "true")
            self.assertTrue(values["plan_b64"])


class ValidationEvidenceReuseTest(unittest.TestCase):
    def test_review_audit_text_does_not_invalidate_flutter_test_identity(self) -> None:
        source = "apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart"
        before_paths = [source]
        after_paths = [source, "docs/audits/milestone_35/review.md"]
        before_plan = plan_validation(before_paths)
        after_plan = plan_validation(after_paths)

        before = validation_evidence_identity(before_plan, before_paths, phase="tests")
        after = validation_evidence_identity(after_plan, after_paths, phase="tests")

        self.assertEqual(before, after)
        self.assertTrue(
            can_reuse_validation_evidence(
                previous_identity=before,
                current_identity=after,
                same_task=True,
                previous_passed=True,
            )
        )

    def test_selected_source_mutation_changes_flutter_test_identity(self) -> None:
        first_paths = [
            "apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart"
        ]
        second_paths = [
            *first_paths,
            "apps/flutter_architecture/lib/features/profile/presentation/profile_bloc.dart",
        ]
        first = validation_evidence_identity(
            plan_validation(first_paths), first_paths, phase="tests"
        )
        second = validation_evidence_identity(
            plan_validation(second_paths), second_paths, phase="tests"
        )

        self.assertNotEqual(first, second)

    def test_path_order_does_not_change_evidence_identity(self) -> None:
        paths = [
            "apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart",
            "apps/flutter_architecture/lib/features/profile/presentation/profile_bloc.dart",
        ]
        plan = plan_validation(paths)

        first = validation_evidence_identity(plan, paths, phase="tests")
        second = validation_evidence_identity(plan, list(reversed(paths)), phase="tests")

        self.assertEqual(first, second)

    def test_workspace_dependency_metadata_changes_evidence_identity(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "apps/app").mkdir(parents=True)
            (root / "packages/core").mkdir(parents=True)
            (root / "pubspec.yaml").write_text(
                "name: root\nworkspace:\n  - apps/app\n  - packages/core\n",
                encoding="utf-8",
            )
            (root / "packages/core/pubspec.yaml").write_text(
                "name: core\nenvironment:\n  sdk: ^3.0.0\n",
                encoding="utf-8",
            )
            app_pubspec = root / "apps/app/pubspec.yaml"
            app_pubspec.write_text(
                "name: app\nenvironment:\n  sdk: ^3.0.0\n",
                encoding="utf-8",
            )
            paths = ["apps/flutter_architecture/lib/features/profile/profile.dart"]
            plan = plan_validation(paths)
            before = validation_evidence_identity(
                plan, paths, phase="tests", repository=root
            )

            app_pubspec.write_text(
                "name: app\nenvironment:\n  sdk: ^3.0.0\ndependencies:\n  core:\n    path: ../../packages/core\n",
                encoding="utf-8",
            )
            after = validation_evidence_identity(
                plan, paths, phase="tests", repository=root
            )

        self.assertNotEqual(before, after)

    def test_failure_recovery_and_engine_change_require_fresh_validation(self) -> None:
        identity = "same"
        for kwargs in (
            {"failure_recovery": True},
            {"validation_engine_changed": True},
        ):
            self.assertFalse(
                can_reuse_validation_evidence(
                    previous_identity=identity,
                    current_identity=identity,
                    same_task=True,
                    previous_passed=True,
                    **kwargs,
                )
            )

    def test_cross_task_holistic_release_and_post_release_never_reuse(self) -> None:
        identity = "same"
        self.assertFalse(
            can_reuse_validation_evidence(
                previous_identity=identity,
                current_identity=identity,
                same_task=False,
                previous_passed=True,
            )
        )
        for gate in ("holistic", "release", "post_release"):
            self.assertFalse(
                can_reuse_validation_evidence(
                    previous_identity=identity,
                    current_identity=identity,
                    same_task=True,
                    previous_passed=True,
                    gate=gate,
                )
            )


if __name__ == "__main__":
    unittest.main()
