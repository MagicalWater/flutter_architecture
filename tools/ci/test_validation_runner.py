from __future__ import annotations

import subprocess
import sys
import unittest

from tools.ci.validation_planner import encode_plan, plan_validation
from tools.ci.validation_runner import commands_for_phase


class ValidationRunnerContractTest(unittest.TestCase):
    def test_docs_plan_runs_docs_and_diff_without_flutter_tests(self) -> None:
        plan = plan_validation(["docs/guides/example.md"])
        payload = vars(plan) | {
            "change_classes": list(plan.change_classes),
            "flutter_test_scopes": list(plan.flutter_test_scopes),
            "python_test_scopes": list(plan.python_test_scopes),
            "analyze_scopes": list(plan.analyze_scopes),
        }

        quality = commands_for_phase(payload, "quality")
        tests = commands_for_phase(payload, "tests")

        self.assertTrue(any("tools/docs/check_docs.py" in command for _, command in quality))
        self.assertTrue(any(command[:3] == ["git", "diff", "--check"] for _, command in quality))
        self.assertEqual(tests, ())

    def test_feature_plan_executes_only_feature_test_scope(self) -> None:
        plan = plan_validation(
            ["apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart"]
        )
        payload = vars(plan) | {
            "change_classes": list(plan.change_classes),
            "flutter_test_scopes": list(plan.flutter_test_scopes),
            "python_test_scopes": list(plan.python_test_scopes),
            "analyze_scopes": list(plan.analyze_scopes),
        }

        tests = commands_for_phase(payload, "tests")

        self.assertEqual(len(tests), 1)
        cwd, command = tests[0]
        self.assertEqual(cwd.as_posix(), "apps/flutter_architecture")
        self.assertEqual(command, ["flutter", "test", "test/features/profile"])

    def test_full_fail_safe_plan_executes_workspace_flutter_tests(self) -> None:
        plan = plan_validation(["unexpected/config.bin"])
        payload = vars(plan) | {
            "change_classes": list(plan.change_classes),
            "flutter_test_scopes": list(plan.flutter_test_scopes),
            "python_test_scopes": list(plan.python_test_scopes),
            "analyze_scopes": list(plan.analyze_scopes),
        }

        tests = commands_for_phase(payload, "tests")

        self.assertEqual(
            tests,
            ((
                __import__("pathlib").Path("."),
                ["dart", "run", "melos", "exec", "--", "flutter", "test"],
            ),),
        )

    def test_generated_phase_is_empty_for_feature_and_present_for_database(self) -> None:
        feature = plan_validation(
            ["apps/flutter_architecture/lib/features/profile/profile.dart"]
        )
        database = plan_validation(
            ["apps/flutter_architecture/lib/app/database/app_database.dart"]
        )
        feature_payload = vars(feature) | {
            "change_classes": list(feature.change_classes),
            "flutter_test_scopes": list(feature.flutter_test_scopes),
            "python_test_scopes": list(feature.python_test_scopes),
            "analyze_scopes": list(feature.analyze_scopes),
        }
        database_payload = vars(database) | {
            "change_classes": list(database.change_classes),
            "flutter_test_scopes": list(database.flutter_test_scopes),
            "python_test_scopes": list(database.python_test_scopes),
            "analyze_scopes": list(database.analyze_scopes),
        }

        self.assertEqual(commands_for_phase(feature_payload, "generated"), ())
        self.assertEqual(
            commands_for_phase(database_payload, "generated")[0][1],
            ["bash", "tools/ci/verify_generated.sh"],
        )

    def test_encoded_plan_is_non_empty_for_ci_transport(self) -> None:
        encoded = encode_plan(plan_validation(["docs/guides/example.md"]))

        self.assertTrue(encoded)
        self.assertNotIn("\n", encoded)

    def test_direct_runner_script_accepts_plan_in_dry_run(self) -> None:
        encoded = encode_plan(plan_validation(["docs/guides/example.md"]))
        completed = subprocess.run(
            [
                sys.executable,
                "tools/ci/validation_runner.py",
                "--phase",
                "quality",
                "--plan-b64",
                encoded,
                "--dry-run",
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertIn("tools/docs/check_docs.py", completed.stdout)
        self.assertIn("git diff --check", completed.stdout)


if __name__ == "__main__":
    unittest.main()
