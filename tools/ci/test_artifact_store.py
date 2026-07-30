from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import Any, Dict
import unittest
from unittest import mock

from tools.ci.artifact_store import (
    JobContext,
    aggregate_run,
    begin_job,
    finalize_job,
    main,
    write_github_summary,
)


def _metadata(job: str, suite: str = "quality") -> Dict[str, Any]:
    return {
        "repository": "MagicalWater/flutter_architecture",
        "git_ref": "refs/heads/main",
        "dirty_state": False,
        "run_id": "123",
        "run_attempt": 1,
        "workflow": "CI",
        "job": job,
        "execution_mode": "self-hosted",
        "host_os": "macOS",
        "host_arch": "ARM64",
        "runner_name": "trusted-runner",
        "suite": suite,
        "classifier_reason": "source-change",
        "started_at": "2026-07-30T06:00:00Z",
        "platform": "macos",
        "environment": "development",
        "build_mode": "debug",
        "artifact_kind": "verification-file",
        "sensitivity": "internal-verification",
        "signing": "not-applicable",
        "distribution": "not-for-distribution",
    }


def _cleanup(retention_class: str = "verification-success") -> Dict[str, Any]:
    return {
        "status": "retained",
        "retention_class": retention_class,
        "eligible_at": "2026-08-06T06:05:00Z",
        "reason": "within-policy",
    }


def _validations(result: str = "success") -> list:
    return [
        {
            "label": "primary-command",
            "result": result,
            "started_at": "2026-07-30T06:00:00Z",
            "completed_at": "2026-07-30T06:04:00Z",
            "exit_code": 0 if result == "success" else 1,
        }
    ]


class ArtifactStoreTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.base = Path(self.temp_dir.name)
        self.repo = self.base / "repo"
        self.repo.mkdir()
        self.root = self.base / "managed-store"
        self.commit_sha = "a" * 40
        self.run_key = "gh-123-1"

    def test_begin_and_finalize_publish_an_atomic_checksummed_job(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )

        self.assertTrue(context.staging_dir.is_dir())
        self.assertTrue(context.artifact_dir.is_dir())
        self.assertTrue(context.diagnostics_dir.is_dir())
        self.assertTrue(context.lock_path.is_file())
        self.assertFalse(context.published_dir.exists())

        artifact = context.artifact_dir / "quality" / "result.txt"
        artifact.parent.mkdir(parents=True)
        artifact.write_text("verified", encoding="utf-8")
        diagnostic = context.diagnostics_dir / "primary" / "command.log"
        diagnostic.parent.mkdir(parents=True)
        diagnostic.write_text("command output", encoding="utf-8")

        published = finalize_job(
            context,
            "success",
            _validations(),
            _cleanup(),
        )

        self.assertEqual(published, context.published_dir)
        self.assertFalse(context.staging_dir.exists())
        self.assertFalse(context.lock_path.exists())
        for relative_path in ("manifest.json", "summary.md", "checksums.sha256"):
            self.assertTrue((published / relative_path).is_file(), relative_path)

        manifest = json.loads((published / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["result"], "success")
        self.assertEqual(manifest["evidence_status"], "complete")
        self.assertEqual(len(manifest["artifacts"]), 2)

        checksum_lines = (
            (published / "checksums.sha256").read_text(encoding="utf-8").splitlines()
        )
        self.assertGreaterEqual(len(checksum_lines), 4)
        for line in checksum_lines:
            expected, relative_path = line.split("  ", 1)
            payload = (published / relative_path).read_bytes()
            self.assertEqual(hashlib.sha256(payload).hexdigest(), expected)

        manifest = json.loads((published / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["platform"], "macos")
        self.assertEqual(manifest["environment"], "development")
        self.assertEqual(manifest["build_mode"], "debug")

    def test_begin_requires_target_platform_projection_metadata(self) -> None:
        for field in ("platform", "environment", "build_mode"):
            metadata = _metadata("quality")
            metadata.pop(field)
            with self.subTest(field=field):
                with self.assertRaisesRegex(ValueError, field):
                    begin_job(
                        self.root,
                        self.repo,
                        self.commit_sha,
                        self.run_key,
                        f"missing-{field}",
                        metadata,
                    )

    def test_refuses_to_begin_when_published_job_or_active_lock_exists(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )
        with self.assertRaisesRegex(FileExistsError, "lock"):
            begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                "ci-quality",
                _metadata("quality"),
            )

        artifact = context.artifact_dir / "result.txt"
        artifact.write_text("verified", encoding="utf-8")
        finalize_job(context, "success", _validations(), _cleanup())

        with self.assertRaisesRegex(FileExistsError, "published"):
            begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                "ci-quality",
                _metadata("quality"),
            )

    def test_begin_rejects_invalid_artifact_defaults_before_side_effects(self) -> None:
        metadata = _metadata("quality")
        metadata["artifact_kind"] = {"token": "must-not-be-stringified"}

        with self.assertRaisesRegex(ValueError, "artifact_kind"):
            begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                "ci-quality",
                metadata,
            )

        self.assertFalse(self.root.exists())

    def test_begin_rejects_active_cleanup_operation(self) -> None:
        cleanup_lock = self.root / "locks" / "cleanup-operation.lock"
        cleanup_lock.parent.mkdir(parents=True)
        cleanup_lock.write_text("cleanup active", encoding="utf-8")

        with self.assertRaisesRegex(RuntimeError, "cleanup operation"):
            begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                "ci-quality",
                _metadata("quality"),
            )

    def test_multi_job_aggregation_keeps_every_finalized_job(self) -> None:
        for job_key, suite in (
            ("ci-quality", "quality"),
            ("ios-production", "ios"),
        ):
            context = begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                job_key,
                _metadata(job_key, suite=suite),
            )
            artifact = context.artifact_dir / suite / "result.txt"
            artifact.parent.mkdir(parents=True)
            artifact.write_text(job_key, encoding="utf-8")
            finalize_job(context, "success", _validations(), _cleanup())

        run_manifest_path = aggregate_run(self.root, self.commit_sha, self.run_key)
        run_manifest = json.loads(run_manifest_path.read_text(encoding="utf-8"))

        self.assertEqual(run_manifest["job_count"], 2)
        self.assertEqual(
            [entry["job_key"] for entry in run_manifest["jobs"]],
            ["ci-quality", "ios-production"],
        )
        for entry in run_manifest["jobs"]:
            manifest_path = run_manifest_path.parent / entry["manifest_path"]
            self.assertEqual(
                hashlib.sha256(manifest_path.read_bytes()).hexdigest(),
                entry["manifest_sha256"],
            )
        self.assertTrue((run_manifest_path.parent / "run-summary.md").is_file())

    def test_aggregation_rejects_active_jobs_and_unsafe_commit_sha(self) -> None:
        completed = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )
        (completed.artifact_dir / "result.txt").write_text("done", encoding="utf-8")
        finalize_job(completed, "success", _validations(), _cleanup())

        active = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ios-production",
            _metadata("ios-production", suite="ios"),
        )
        self.addCleanup(active.lock_path.unlink, missing_ok=True)

        with self.assertRaisesRegex(RuntimeError, "active job"):
            aggregate_run(self.root, self.commit_sha, self.run_key)
        with self.assertRaisesRegex(ValueError, "commit_sha"):
            aggregate_run(self.root, "../unsafe", self.run_key)

    def test_primary_failure_survives_summary_render_degradation(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )
        (context.artifact_dir / "failure.txt").write_text("failed", encoding="utf-8")

        with mock.patch(
            "tools.ci.artifact_store._render_job_summary",
            side_effect=RuntimeError("summary unavailable"),
        ):
            published = finalize_job(
                context,
                "failure",
                _validations(result="failure"),
                _cleanup(retention_class="verification-failure"),
            )

        manifest = json.loads((published / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["result"], "failure")
        self.assertEqual(manifest["evidence_status"], "degraded")
        summary = (published / "summary.md").read_text(encoding="utf-8")
        self.assertIn("Primary result: failure", summary)
        self.assertIn("Evidence status: degraded", summary)

    def test_secret_bearing_diagnostics_block_atomic_publish_without_echo(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-secret-diagnostic",
            _metadata("secret-diagnostic"),
        )
        secret = "gho_0123456789abcdefghijklmnop"
        diagnostic = context.diagnostics_dir / "primary" / "command.log"
        diagnostic.parent.mkdir(parents=True)
        diagnostic.write_text(f"authorization={secret}\n", encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "secret leakage") as caught:
            finalize_job(
                context,
                "failure",
                _validations("failure"),
                _cleanup("verification-failure"),
            )

        self.assertNotIn(secret, str(caught.exception))
        self.assertFalse(context.published_dir.exists())
        self.assertFalse(context.staging_dir.exists())
        self.assertFalse(context.lock_path.exists())

    def test_secret_bearing_metadata_is_rejected_before_store_side_effects(self) -> None:
        secret = "gho_0123456789abcdefghijklmnop"
        metadata = _metadata("secret-metadata")
        metadata["classifier_reason"] = f"token={secret}"

        with self.assertRaisesRegex(ValueError, "secret leakage") as caught:
            begin_job(
                self.root,
                self.repo,
                self.commit_sha,
                self.run_key,
                "ci-secret-metadata",
                metadata,
            )

        self.assertNotIn(secret, str(caught.exception))
        self.assertFalse(self.root.exists())

    def test_oversized_diagnostics_block_atomic_publish(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-oversized-diagnostic",
            _metadata("oversized-diagnostic"),
        )
        diagnostic = context.diagnostics_dir / "primary" / "command.log"
        diagnostic.parent.mkdir(parents=True)
        diagnostic.write_bytes(b"x" * (25 * 1024 * 1024 + 1))

        with self.assertRaisesRegex(ValueError, "25 MiB"):
            finalize_job(
                context,
                "failure",
                _validations("failure"),
                _cleanup("verification-failure"),
            )

        self.assertFalse(context.published_dir.exists())
        self.assertFalse(context.staging_dir.exists())
        self.assertFalse(context.lock_path.exists())

    def test_context_file_integrity_prevents_path_redirection(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )
        payload = json.loads(context.context_path.read_text(encoding="utf-8"))
        payload["published_dir"] = str(self.base / "redirected-output")
        context.context_path.write_text(json.dumps(payload), encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "context integrity"):
            JobContext.from_file(context.context_path)

    def test_cli_begin_finalize_aggregate_and_write_summary(self) -> None:
        metadata_path = self.base / "metadata.json"
        metadata_path.write_text(json.dumps(_metadata("quality")), encoding="utf-8")

        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "begin-job",
                    "--root",
                    str(self.root),
                    "--repo-root",
                    str(self.repo),
                    "--commit-sha",
                    self.commit_sha,
                    "--run-key",
                    self.run_key,
                    "--job-key",
                    "ci-quality",
                    "--metadata-json",
                    str(metadata_path),
                ]
            )
        self.assertEqual(exit_code, 0)
        begin_payload = json.loads(output.getvalue())
        context_path = Path(begin_payload["context_path"])
        artifact_dir = Path(begin_payload["artifact_dir"])
        (artifact_dir / "result.txt").write_text("verified", encoding="utf-8")

        validations_path = self.base / "validations.json"
        validations_path.write_text(json.dumps(_validations()), encoding="utf-8")
        cleanup_path = self.base / "cleanup.json"
        cleanup_path.write_text(json.dumps(_cleanup()), encoding="utf-8")

        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "finalize-job",
                    "--context-json",
                    str(context_path),
                    "--result",
                    "success",
                    "--validations-json",
                    str(validations_path),
                    "--cleanup-json",
                    str(cleanup_path),
                ]
            )
        self.assertEqual(exit_code, 0)
        published_dir = Path(json.loads(output.getvalue())["published_dir"])

        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "aggregate-run",
                    "--root",
                    str(self.root),
                    "--commit-sha",
                    self.commit_sha,
                    "--run-key",
                    self.run_key,
                ]
            )
        self.assertEqual(exit_code, 0)
        run_manifest_path = Path(json.loads(output.getvalue())["run_manifest_path"])
        self.assertTrue(run_manifest_path.is_file())

        github_summary = self.base / "github-summary.md"
        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "write-summary",
                    "--manifest",
                    str(published_dir / "manifest.json"),
                    "--output",
                    str(github_summary),
                ]
            )
        self.assertEqual(exit_code, 0)
        summary_text = github_summary.read_text(encoding="utf-8")
        manifest_sha256 = hashlib.sha256(
            (published_dir / "manifest.json").read_bytes()
        ).hexdigest()
        self.assertIn("Local-only evidence", summary_text)
        self.assertIn("Manifest SHA-256", summary_text)
        self.assertIn(manifest_sha256, summary_text)
        self.assertIn("verification-success", summary_text)

    def test_write_summary_does_not_claim_external_parent_permissions(self) -> None:
        context = begin_job(
            self.root,
            self.repo,
            self.commit_sha,
            self.run_key,
            "ci-quality",
            _metadata("quality"),
        )
        (context.artifact_dir / "result.txt").write_text("verified", encoding="utf-8")
        published = finalize_job(context, "success", _validations(), _cleanup())
        output = self.base / "external-summary" / "github-summary.md"
        output.parent.mkdir()

        with mock.patch("tools.ci.artifact_store._ensure_directory") as ensure:
            with mock.patch("tools.ci.artifact_store._chmod_file") as chmod_file:
                write_github_summary(published / "manifest.json", output)

        ensure.assert_called_once_with(output.parent, owner_only=False)
        chmod_file.assert_not_called()

    def test_direct_cli_entrypoints_are_importable(self) -> None:
        for relative_path in (
            "tools/ci/artifact_store.py",
            "tools/ci/artifact_cleanup.py",
        ):
            completed = subprocess.run(
                [sys.executable, relative_path, "--help"],
                cwd=Path(__file__).resolve().parents[2],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(completed.returncode, 0, completed.stderr)

    def test_cli_accepts_inline_json_payloads(self) -> None:
        metadata_json = json.dumps(_metadata("quality"))
        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "begin-job",
                    "--root",
                    str(self.root),
                    "--repo-root",
                    str(self.repo),
                    "--commit-sha",
                    self.commit_sha,
                    "--run-key",
                    self.run_key,
                    "--job-key",
                    "ci-quality",
                    "--metadata-json-value",
                    metadata_json,
                ]
            )
        self.assertEqual(exit_code, 0)
        context_path = Path(json.loads(output.getvalue())["context_path"])
        context = JobContext.from_file(context_path)
        (context.artifact_dir / "result.txt").write_text("verified", encoding="utf-8")

        output = io.StringIO()
        with redirect_stdout(output):
            exit_code = main(
                [
                    "finalize-job",
                    "--context-json",
                    str(context_path),
                    "--result",
                    "success",
                    "--validations-json-value",
                    json.dumps(_validations()),
                    "--cleanup-json-value",
                    json.dumps(_cleanup()),
                ]
            )
        self.assertEqual(exit_code, 0)
        self.assertTrue(Path(json.loads(output.getvalue())["published_dir"]).is_dir())


if __name__ == "__main__":
    unittest.main()
