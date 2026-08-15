from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from tools.ci.change_classifier import classify_paths, classify_range


class ChangeClassifierPathContractTest(unittest.TestCase):
    def test_docs_only_change_skips_heavy_work(self) -> None:
        result = classify_paths(["docs/audits/example.md", "README.md"])

        self.assertEqual(result.change_classes, ("docs_content",))
        self.assertTrue(result.docs_only)
        self.assertFalse(result.full_ci)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)
        self.assertFalse(result.release_full)
        self.assertTrue(result.reason)

    def test_version_change_forces_full_matrix(self) -> None:
        result = classify_paths(["VERSION", "CHANGELOG.md"])

        self.assertFalse(result.docs_only)
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertTrue(result.release_full)

    def test_manual_dispatch_forces_full_matrix(self) -> None:
        result = classify_paths([], manual=True)

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertTrue(result.release_full)

    def test_invalid_range_fails_safe_to_full_matrix(self) -> None:
        result = classify_paths([], invalid_range=True)

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertFalse(result.release_full)

    def test_unknown_path_fails_safe_to_full_matrix(self) -> None:
        result = classify_paths(["unexpected/config.bin"])

        self.assertEqual(result.change_classes, ("unknown",))
        self.assertTrue(result.fail_safe)
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_repository_authored_skill_is_governance(self) -> None:
        result = classify_paths(
            [".agents/skills/implementing-pencil-flutter-design/SKILL.md"]
        )

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)

    def test_repository_identity_manifest_is_governance_without_platform_builds(self) -> None:
        result = classify_paths(["repository_identity.json"])

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)
        self.assertTrue(result.full_ci)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_repository_infrastructure_manifest_is_governance_without_fail_safe(self) -> None:
        result = classify_paths(["repository_infrastructure.json"])

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)
        self.assertTrue(result.full_ci)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_repository_authored_skill_reference_is_governance(self) -> None:
        result = classify_paths(
            [
                ".agents/skills/implementing-pencil-flutter-design/"
                "references/visual-validation.md"
            ]
        )

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)

    def test_third_party_locked_skill_is_governance(self) -> None:
        result = classify_paths([".agents/skills/brandkit/SKILL.md"])

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)

    def test_skill_lock_is_governance_without_fail_safe(self) -> None:
        result = classify_paths(["skills-lock.json"])

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)

    def test_vendored_skill_provenance_is_governance_without_fail_safe(self) -> None:
        result = classify_paths(["third_party/skills/taste-skill/LICENSE"])

        self.assertEqual(result.change_classes, ("governance",))
        self.assertFalse(result.fail_safe)

    def test_skill_and_ordinary_docs_keep_deterministic_union(self) -> None:
        result = classify_paths(
            [
                ".agents/skills/implementing-pencil-flutter-design/SKILL.md",
                "docs/guides/pencil_to_flutter_workflow.md",
            ]
        )

        self.assertEqual(result.change_classes, ("docs_content", "governance"))
        self.assertFalse(result.fail_safe)

    def test_unmanaged_agent_runtime_path_remains_unknown(self) -> None:
        result = classify_paths([".agent-runtime/new-policy.bin"])

        self.assertEqual(result.change_classes, ("unknown",))
        self.assertTrue(result.fail_safe)
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_dart_source_runs_full_ci_and_both_platform_builds(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/lib/features/example/example.dart"]
        )

        self.assertEqual(result.change_classes, ("app_feature",))
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertEqual(result.reason, "classified source or tooling change")

    def test_android_native_change_runs_android_only_platform_build(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/android/app/build.gradle.kts"]
        )

        self.assertEqual(result.change_classes, ("android_native",))
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertFalse(result.ios_build)

    def test_ios_native_change_runs_ios_only_platform_build(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/ios/Runner/Info.plist"]
        )

        self.assertEqual(result.change_classes, ("ios_native",))
        self.assertTrue(result.full_ci)
        self.assertFalse(result.android_build)
        self.assertTrue(result.ios_build)

    def test_package_change_runs_full_matrix(self) -> None:
        result = classify_paths(["packages/core/lib/src/example.dart"])

        self.assertEqual(result.change_classes, ("package",))
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)
        self.assertEqual(result.reason, "classified source or tooling change")

    def test_dependency_change_runs_full_matrix(self) -> None:
        result = classify_paths(["pubspec.lock"])

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_app_pubspec_change_runs_both_platform_builds(self) -> None:
        result = classify_paths(["apps/flutter_architecture/pubspec.yaml"])

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_app_asset_change_runs_both_platform_builds(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/assets/images/example.png"]
        )

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_app_localization_config_change_runs_both_platform_builds(self) -> None:
        result = classify_paths(["apps/flutter_architecture/l10n.yaml"])

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_classifier_change_runs_full_matrix(self) -> None:
        result = classify_paths(["tools/ci/change_classifier.py"])

        self.assertEqual(result.change_classes, ("validation_engine",))
        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_unrelated_tool_change_runs_full_ci_without_platform_builds(self) -> None:
        result = classify_paths(["tools/docs/check_docs.py"])

        self.assertEqual(result.change_classes, ("tooling",))
        self.assertTrue(result.full_ci)
        self.assertFalse(result.android_build)
        self.assertFalse(result.ios_build)

    def test_mixed_known_paths_keep_canonical_classes_instead_of_unknown(self) -> None:
        result = classify_paths(
            ["docs/guides/example.md", "packages/core/lib/src/example.dart"]
        )

        self.assertEqual(result.change_classes, ("docs_content", "package"))
        self.assertFalse(result.fail_safe)
        self.assertTrue(result.full_ci)

    def test_drift_schema_change_runs_database_critical_matrix(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/lib/app/database/schema/app_database.drift"]
        )

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_drift_dao_change_runs_database_critical_matrix(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/lib/app/database/dao/catalog_cache_dao.dart"]
        )

        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_drift_snapshot_change_runs_database_critical_matrix(self) -> None:
        result = classify_paths(
            ["apps/flutter_architecture/test/drift_schemas/app_database/drift_schema_v6.json"]
        )

        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_database_web_asset_change_runs_database_critical_matrix(self) -> None:
        for path in (
            "apps/flutter_architecture/web/sqlite3.wasm",
            "apps/flutter_architecture/web/drift_worker.js",
        ):
            result = classify_paths([path])
            self.assertTrue(result.android_build, path)
            self.assertTrue(result.ios_build, path)

    def test_database_tooling_change_runs_database_critical_matrix(self) -> None:
        result = classify_paths(["tools/database/export_drift_schemas.sh"])

        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)


class ChangeClassifierRangeContractTest(unittest.TestCase):
    def test_valid_git_range_uses_changed_paths(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repository = Path(temp_dir)
            subprocess.run(["git", "init", "-q"], cwd=repository, check=True)
            subprocess.run(
                ["git", "config", "user.email", "ci@example.test"],
                cwd=repository,
                check=True,
            )
            subprocess.run(
                ["git", "config", "user.name", "CI Test"],
                cwd=repository,
                check=True,
            )
            (repository / "README.md").write_text("before\n", encoding="utf-8")
            subprocess.run(["git", "add", "README.md"], cwd=repository, check=True)
            subprocess.run(["git", "commit", "-qm", "initial"], cwd=repository, check=True)
            base = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()

            (repository / "README.md").write_text("after\n", encoding="utf-8")
            subprocess.run(["git", "add", "README.md"], cwd=repository, check=True)
            subprocess.run(["git", "commit", "-qm", "docs"], cwd=repository, check=True)
            head = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], cwd=repository, text=True
            ).strip()

            result = classify_range(base, head, repository=repository)

        self.assertTrue(result.docs_only)
        self.assertFalse(result.full_ci)

    def test_all_zero_base_fails_safe(self) -> None:
        result = classify_range("0" * 40, "deadbeef")

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)

    def test_missing_git_object_fails_safe(self) -> None:
        result = classify_range("deadbeef", "cafebabe")

        self.assertTrue(result.full_ci)
        self.assertTrue(result.android_build)
        self.assertTrue(result.ios_build)


class ChangeClassifierCliContractTest(unittest.TestCase):
    def test_manual_dispatch_writes_github_output_contract(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            output = Path(temp_dir) / "github-output.txt"

            completed = subprocess.run(
                [
                    sys.executable,
                    "tools/ci/change_classifier.py",
                    "--event",
                    "workflow_dispatch",
                    "--output",
                    str(output),
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            values = dict(
                line.split("=", 1)
                for line in output.read_text(encoding="utf-8").splitlines()
            )

        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertEqual(values["docs_only"], "false")
        self.assertEqual(values["full_ci"], "true")
        self.assertEqual(values["android_build"], "true")
        self.assertEqual(values["ios_build"], "true")
        self.assertEqual(values["release_full"], "true")
        self.assertTrue(values["reason"])


if __name__ == "__main__":
    unittest.main()
