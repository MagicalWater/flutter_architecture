from __future__ import annotations

import importlib
import unittest

from tools.ci.change_classifier import classify_paths


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
    def test_validation_planner_contract_is_not_implemented_yet(self) -> None:
        try:
            module = importlib.import_module("tools.ci.validation_planner")
        except ModuleNotFoundError as error:
            if error.name != "tools.ci.validation_planner":
                raise
            self.fail(
                "Milestone 35 expected RED: tools.ci.validation_planner is missing; "
                "the deterministic Minimum Sufficient Validation planner has not "
                "been implemented yet."
            )

        self.assertTrue(
            hasattr(module, "plan_validation"),
            "Milestone 35 expected RED: validation_planner.plan_validation is missing.",
        )
        result = module.plan_validation(CANONICAL_SCENARIOS["docs_content"])
        missing = EXPECTED_PLAN_FIELDS - set(vars(result))
        self.assertFalse(
            missing,
            f"Milestone 35 expected RED: planner schema fields missing: {sorted(missing)}",
        )

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


if __name__ == "__main__":
    unittest.main()
