import tempfile
import unittest
from pathlib import Path

from tools.ci.benchmark_validation_routing import SCENARIOS, measure_all


class ValidationRoutingBenchmarkTest(unittest.TestCase):
    def test_corpus_covers_required_risk_classes(self) -> None:
        required = {
            "docs-only",
            "single-feature",
            "single-test",
            "leaf-package",
            "app-shared",
            "tooling",
            "database",
            "android-native",
            "ios-native",
            "dependency",
            "validation-engine",
            "unknown",
            "release",
        }
        self.assertTrue(required.issubset(SCENARIOS))

    def test_low_risk_scenarios_reduce_legacy_full_routing(self) -> None:
        by_name = {row.scenario: row for row in measure_all()}
        feature = by_name["single-feature"]
        leaf_package = by_name["leaf-package"]
        self.assertTrue(feature.before_full_ci)
        self.assertFalse(feature.after_android_build)
        self.assertFalse(feature.after_ios_build)
        self.assertEqual(feature.after_validation_level, "affected")
        self.assertLess(feature.after_command_count, feature.before_command_count)
        self.assertTrue(leaf_package.before_full_ci)
        self.assertEqual(leaf_package.after_validation_level, "affected")
        self.assertLess(leaf_package.after_command_count, leaf_package.before_command_count)

    def test_high_risk_and_unknown_keep_fail_safe_escalation(self) -> None:
        by_name = {row.scenario: row for row in measure_all()}
        for scenario in ("dependency", "validation-engine", "release"):
            row = by_name[scenario]
            self.assertGreaterEqual(row.after_command_count, 5)
            self.assertTrue(row.after_android_build)
            self.assertTrue(row.after_ios_build)
        unknown = by_name["unknown"]
        self.assertTrue(unknown.after_fail_safe)
        self.assertEqual(unknown.after_validation_level, "full")
        self.assertTrue(unknown.after_android_build)
        self.assertTrue(unknown.after_ios_build)

    def test_platform_native_changes_only_request_the_affected_platform(self) -> None:
        by_name = {row.scenario: row for row in measure_all()}
        android = by_name["android-native"]
        ios = by_name["ios-native"]
        self.assertTrue(android.after_android_build)
        self.assertFalse(android.after_ios_build)
        self.assertFalse(ios.after_android_build)
        self.assertTrue(ios.after_ios_build)


if __name__ == "__main__":
    unittest.main()
