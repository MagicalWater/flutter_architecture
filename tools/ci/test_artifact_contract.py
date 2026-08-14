import os
from pathlib import Path, PureWindowsPath
import tempfile
from typing import Any, Dict
import unittest

from tools.ci.artifact_contract import (
    RETENTION_CLASSES,
    SCHEMA_VERSION,
    resolve_artifact_root,
    sanitize_key,
    validate_artifact_root,
    validate_job_manifest,
)


def _valid_manifest() -> Dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "repository": "MagicalWater/flutter_architecture",
        "commit_sha": "a" * 40,
        "git_ref": "refs/heads/main",
        "dirty_state": False,
        "run_key": "gh-123-1",
        "run_id": "123",
        "run_attempt": 1,
        "job_key": "ci-quality",
        "workflow": "CI",
        "job": "quality",
        "execution_mode": "self-hosted",
        "host_os": "macOS",
        "host_arch": "ARM64",
        "runner_name": "trusted-runner",
        "suite": "quality",
        "platform": "macos",
        "environment": "repository",
        "build_mode": "verification",
        "classifier_reason": "source-change",
        "started_at": "2026-07-30T06:00:00Z",
        "completed_at": "2026-07-30T06:05:00Z",
        "result": "success",
        "evidence_status": "complete",
        "artifacts": [
            {
                "relative_path": "artifacts/android/app.apk",
                "kind": "android-apk",
                "platform": "android",
                "environment": "development",
                "build_mode": "debug",
                "size_bytes": 123,
                "sha256": "b" * 64,
                "retention_class": "verification-success",
                "sensitivity": "internal-verification",
                "signing": "debug-verification",
                "distribution": "not-for-store",
            }
        ],
        "validations": [
            {
                "label": "flutter-test",
                "result": "success",
                "started_at": "2026-07-30T06:00:00Z",
                "completed_at": "2026-07-30T06:04:00Z",
            }
        ],
        "cleanup_disposition": {
            "status": "retained",
            "retention_class": "verification-success",
            "eligible_at": "2026-08-06T06:05:00Z",
            "reason": "within-policy",
        },
    }


class ArtifactRootResolutionTest(unittest.TestCase):
    def test_self_hosted_requires_explicit_root(self) -> None:
        with self.assertRaisesRegex(ValueError, "CI_ARTIFACT_ROOT"):
            resolve_artifact_root(None, "self-hosted", "Darwin", {}, "flutter_architecture")

    def test_windows_manual_default_uses_local_app_data(self) -> None:
        root = resolve_artifact_root(
            None,
            "manual-local",
            "Windows",
            {"LOCALAPPDATA": r"C:\Users\tester\AppData\Local"},
            "pickup-basketball",
        )
        self.assertEqual(
            PureWindowsPath(str(root)),
            PureWindowsPath(
                r"C:\Users\tester\AppData\Local\pickup-basketball\ci-artifacts"
            ),
        )

    def test_posix_manual_default_prefers_xdg_state_home(self) -> None:
        root = resolve_artifact_root(
            None,
            "manual-local",
            "Darwin",
            {"XDG_STATE_HOME": "/state", "HOME": "/home/tester"},
            "pickup-basketball",
        )
        self.assertEqual(root, Path("/state/pickup-basketball/ci-artifacts"))

    def test_posix_manual_default_falls_back_to_home_local_state(self) -> None:
        root = resolve_artifact_root(
            None,
            "manual-local",
            "Linux",
            {"HOME": "/home/tester"},
            "pickup-basketball",
        )
        self.assertEqual(
            root,
            Path("/home/tester/.local/state/pickup-basketball/ci-artifacts"),
        )

    def test_github_hosted_does_not_resolve_an_implicit_local_root(self) -> None:
        with self.assertRaisesRegex(ValueError, "github-hosted"):
            resolve_artifact_root(None, "github-hosted", "Linux", {}, "pickup-basketball")

    def test_explicit_root_wins_for_manual_local(self) -> None:
        self.assertEqual(
            resolve_artifact_root(
                "/external/store",
                "manual-local",
                "Darwin",
                {"HOME": "/home/tester"},
                "pickup-basketball",
            ),
            Path("/external/store"),
        )

    def test_rejects_unknown_execution_mode(self) -> None:
        with self.assertRaisesRegex(ValueError, "execution mode"):
            resolve_artifact_root("/external/store", "local", "Linux", {}, "pickup-basketball")

    def test_manual_default_uses_explicit_product_key_not_repository_folder(self) -> None:
        root = resolve_artifact_root(
            None,
            "manual-local",
            "Linux",
            {"HOME": "/home/tester"},
            "nfc-lab",
        )
        self.assertEqual(root, Path("/home/tester/.local/state/nfc-lab/ci-artifacts"))

    def test_manual_default_rejects_unnormalized_product_key(self) -> None:
        with self.assertRaisesRegex(ValueError, "product_key"):
            resolve_artifact_root(
                None,
                "manual-local",
                "Linux",
                {"HOME": "/home/tester"},
                "../from-folder",
            )


class ArtifactRootSafetyTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.base = Path(self.temp_dir.name).resolve()
        self.repo = self.base / "repo"
        self.repo.mkdir()
        self.external = self.base / "external" / "ci-artifacts"

    def test_accepts_external_absolute_root(self) -> None:
        self.assertEqual(
            validate_artifact_root(self.external, self.repo),
            self.external.resolve(),
        )

    def test_rejects_relative_root(self) -> None:
        with self.assertRaisesRegex(ValueError, "absolute"):
            validate_artifact_root(Path("relative/store"), self.repo)

    def test_rejects_repository_and_descendants(self) -> None:
        for candidate in (self.repo, self.repo / "artifacts"):
            with self.subTest(candidate=candidate):
                with self.assertRaisesRegex(ValueError, "repository"):
                    validate_artifact_root(candidate, self.repo)

    def test_rejects_runner_work_and_temp_descendants(self) -> None:
        runner_work = self.base / "runner" / "_work"
        runner_temp = self.base / "runner" / "_temp"
        for label, candidate, kwargs in (
            (
                "runner work",
                runner_work / "store",
                {"runner_work": runner_work},
            ),
            (
                "runner temp",
                runner_temp / "store",
                {"runner_temp": runner_temp},
            ),
        ):
            with self.subTest(label=label):
                with self.assertRaisesRegex(ValueError, label):
                    validate_artifact_root(candidate, self.repo, **kwargs)

    def test_rejects_filesystem_root_and_home_root_itself(self) -> None:
        filesystem_root = Path(self.base.anchor)
        with self.assertRaisesRegex(ValueError, "filesystem root"):
            validate_artifact_root(filesystem_root, self.repo)

        home = self.base / "home"
        home.mkdir()
        with self.assertRaisesRegex(ValueError, "home root"):
            validate_artifact_root(home, self.repo, home=home)

    def test_allows_descendant_of_home_when_not_otherwise_forbidden(self) -> None:
        home = self.base / "home"
        home.mkdir()
        candidate = home / ".local" / "state" / "ci-artifacts"
        self.assertEqual(
            validate_artifact_root(candidate, self.repo, home=home),
            candidate.resolve(),
        )

    def test_rejects_dot_dot_traversal_even_if_it_normalizes_external(self) -> None:
        candidate = self.base / "external" / "nested" / ".." / "ci-artifacts"
        with self.assertRaisesRegex(ValueError, "traversal"):
            validate_artifact_root(candidate, self.repo)

    def test_rejects_symlink_components(self) -> None:
        target = self.base / "target"
        target.mkdir()
        link = self.base / "linked"
        try:
            os.symlink(target, link, target_is_directory=True)
        except (OSError, NotImplementedError) as error:
            self.skipTest(f"symlink unavailable: {error}")

        with self.assertRaisesRegex(ValueError, "symlink"):
            validate_artifact_root(link / "ci-artifacts", self.repo)


class ArtifactKeyTest(unittest.TestCase):
    def test_sanitizes_to_lowercase_ascii_path_key(self) -> None:
        self.assertEqual(sanitize_key("CI / Quality (macOS)"), "ci-quality-macos")
        self.assertEqual(sanitize_key("job_name.v1"), "job_name.v1")

    def test_rejects_empty_and_traversal_keys(self) -> None:
        for value in ("", "   ", "...", "../job", ".."):
            with self.subTest(value=value):
                with self.assertRaises(ValueError):
                    sanitize_key(value)


class ArtifactManifestTest(unittest.TestCase):
    def test_accepts_versioned_allowlist_manifest(self) -> None:
        validate_job_manifest(_valid_manifest())

    def test_rejects_unknown_or_secret_bearing_fields_recursively(self) -> None:
        for key, value in (
            ("environment_variables", {"SAFE": "value"}),
            ("token", "gho_example"),
            ("service_account_json", "{}"),
            ("provider_config", {"client_id": "example"}),
        ):
            payload = _valid_manifest()
            payload["cleanup_disposition"] = dict(
                payload["cleanup_disposition"], **{key: value}
            )
            with self.subTest(key=key):
                with self.assertRaisesRegex(ValueError, "forbidden manifest field"):
                    validate_job_manifest(payload)

        payload = _valid_manifest()
        payload["unexpected"] = "value"
        with self.assertRaisesRegex(ValueError, "unknown manifest field"):
            validate_job_manifest(payload)

    def test_rejects_invalid_schema_version_and_execution_mode(self) -> None:
        payload = _valid_manifest()
        payload["schema_version"] = SCHEMA_VERSION + 1
        with self.assertRaisesRegex(ValueError, "schema_version"):
            validate_job_manifest(payload)

        payload = _valid_manifest()
        payload["schema_version"] = True
        with self.assertRaisesRegex(ValueError, "schema_version"):
            validate_job_manifest(payload)

        payload = _valid_manifest()
        payload["execution_mode"] = "local"
        with self.assertRaisesRegex(ValueError, "execution_mode"):
            validate_job_manifest(payload)

    def test_rejects_unsafe_artifact_paths_hashes_and_retention_classes(self) -> None:
        for field, value, message in (
            ("relative_path", "../secret.txt", "relative_path"),
            ("relative_path", "/absolute/file", "relative_path"),
            ("relative_path", "C:/absolute/file", "relative_path"),
            ("relative_path", "C:drive-relative-file", "relative_path"),
            ("sha256", "not-a-hash", "sha256"),
            ("retention_class", "forever", "retention_class"),
            ("size_bytes", -1, "size_bytes"),
        ):
            payload = _valid_manifest()
            payload["artifacts"] = [dict(payload["artifacts"][0], **{field: value})]
            with self.subTest(field=field, value=value):
                with self.assertRaisesRegex(ValueError, message):
                    validate_job_manifest(payload)

    def test_retention_constants_match_the_accepted_design(self) -> None:
        self.assertEqual(
            RETENTION_CLASSES,
            {
                "verification-success": {
                    "max_age_days": 7,
                    "max_count": 3,
                    "metadata_days": 90,
                },
                "verification-failure": {
                    "max_age_days": 14,
                    "max_count": 10,
                    "metadata_days": 90,
                },
                "observability-raw": {
                    "max_age_days": 3,
                    "max_count": 2,
                    "metadata_days": 90,
                },
                "release-verification": {
                    "max_age_days": 30,
                    "max_count": 3,
                    "metadata_days": 365,
                },
                "pinned": {
                    "max_age_days": 90,
                    "max_count": None,
                    "metadata_days": 90,
                },
            },
        )


if __name__ == "__main__":
    unittest.main()
