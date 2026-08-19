from __future__ import annotations

import unittest

from tools.ci.validation_planner import (
    can_reuse_validation_evidence,
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

    def test_package_change_uses_affected_scope_without_platform_builds(self) -> None:
        plan = plan_validation(["packages/auth/lib/src/auth_repository.dart"])

        self.assertEqual(plan.validation_level, "affected")
        self.assertFalse(plan.android_build)
        self.assertFalse(plan.ios_build)
        self.assertFalse(plan.full_regression)

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

    def test_manual_release_requests_full_platform_matrix(self) -> None:
        plan = plan_validation([], manual=True, manual_mode="release")

        self.assertEqual(plan.validation_level, "release")
        self.assertTrue(plan.full_regression)
        self.assertTrue(plan.release_full)
        self.assertTrue(plan.android_build)
        self.assertTrue(plan.ios_build)

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
