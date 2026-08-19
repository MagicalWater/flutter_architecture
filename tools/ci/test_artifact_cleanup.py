from dataclasses import replace
from datetime import datetime, timedelta, timezone
import hashlib
import json
import os
from pathlib import Path
import tempfile
from typing import Any, Dict
import unittest
from unittest import mock

from tools.ci.artifact_cleanup import (
    apply_cleanup,
    evaluate_cleanup,
    pin_job,
    purge_trash,
    restore_cleanup,
    unpin_job,
    write_cleanup_manifest,
)
from tools.ci.artifact_contract import SCHEMA_VERSION, validate_job_manifest


NOW = datetime(2026, 7, 30, 6, 0, 0, tzinfo=timezone.utc)


def _iso(value: datetime) -> str:
    return value.replace(microsecond=0).isoformat().replace("+00:00", "Z")


class ArtifactCleanupTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.root = Path(self.temp_dir.name).resolve() / "managed-store"
        self.root.mkdir()
        self._index = 0

    def _write_job(
        self,
        retention_class: str,
        completed_at: datetime,
        size: int = 32,
        suite: str = "quality",
        git_ref: str = "refs/heads/main",
        platform: str = "android",
    ) -> str:
        self._index += 1
        commit_sha = f"{self._index:040x}"
        run_key = f"local-20260730-{self._index}"
        job_key = f"{suite}-{self._index}"
        job_dir = (
            self.root
            / "runs"
            / commit_sha
            / run_key
            / "jobs"
            / job_key
        )
        artifact_path = job_dir / "artifacts" / suite / "result.bin"
        artifact_path.parent.mkdir(parents=True)
        artifact_path.write_bytes(b"x" * size)
        diagnostic_path = job_dir / "diagnostics" / "primary" / "command.log"
        diagnostic_path.parent.mkdir(parents=True)
        diagnostic_path.write_text("diagnostic", encoding="utf-8")

        manifest: Dict[str, Any] = {
            "schema_version": SCHEMA_VERSION,
            "repository": "MagicalWater/flutter_architecture",
            "commit_sha": commit_sha,
            "git_ref": git_ref,
            "dirty_state": False,
            "run_key": run_key,
            "run_id": None,
            "run_attempt": None,
            "job_key": job_key,
            "workflow": None,
            "job": None,
            "execution_mode": "manual-local",
            "host_os": "Windows",
            "host_arch": "AMD64",
            "runner_name": None,
            "suite": suite,
            "platform": platform,
            "environment": "development",
            "build_mode": "debug",
            "classifier_reason": "test-fixture",
            "started_at": _iso(completed_at - timedelta(minutes=5)),
            "completed_at": _iso(completed_at),
            "result": (
                "failure"
                if retention_class == "verification-failure"
                else "success"
            ),
            "evidence_status": "complete",
            "artifacts": [
                {
                    "relative_path": f"artifacts/{suite}/result.bin",
                    "kind": "verification-file",
                    "platform": platform,
                    "environment": "development",
                    "build_mode": "debug",
                    "size_bytes": size,
                    "sha256": hashlib.sha256(b"x" * size).hexdigest(),
                    "retention_class": retention_class,
                    "sensitivity": "internal-verification",
                    "signing": "not-applicable",
                    "distribution": "not-for-distribution",
                }
            ],
            "validations": [],
            "cleanup_disposition": {
                "status": "retained",
                "retention_class": retention_class,
                "eligible_at": _iso(completed_at),
                "reason": "fixture",
            },
        }
        validate_job_manifest(manifest)
        (job_dir / "manifest.json").write_text(
            json.dumps(manifest, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        (job_dir / "summary.md").write_text("summary", encoding="utf-8")
        return job_dir.relative_to(self.root).as_posix()

    def test_bounded_pin_prevents_cleanup_and_rejects_invalid_expiry(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        pin_id = pin_job(
            self.root,
            job_path,
            owner="maintainer",
            reason="manual acceptance",
            expires_at=NOW + timedelta(days=30),
            now=NOW,
        )
        self.assertTrue((self.root / "pins" / f"{pin_id}.json").is_file())

        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        self.assertNotIn(job_path, [candidate.job_path for candidate in plan.candidates])

        with self.assertRaisesRegex(ValueError, "90 days"):
            pin_job(
                self.root,
                job_path,
                owner="maintainer",
                reason="too long",
                expires_at=NOW + timedelta(days=91),
                now=NOW,
            )
        unpin_job(self.root, job_path)
        self.assertFalse((self.root / "pins" / f"{pin_id}.json").exists())

    def test_evaluation_rejects_tampered_unbounded_pin(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        pin_id = hashlib.sha256(job_path.encode("utf-8")).hexdigest()[:24]
        pin_dir = self.root / "pins"
        pin_dir.mkdir()
        (pin_dir / f"{pin_id}.json").write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "pin_id": pin_id,
                    "job_path": job_path,
                    "owner": "maintainer",
                    "reason": "tampered",
                    "created_at": _iso(NOW),
                    "expires_at": _iso(NOW + timedelta(days=365)),
                }
            ),
            encoding="utf-8",
        )

        with self.assertRaisesRegex(ValueError, "90 days"):
            evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)

    def test_apply_moves_to_trash_restore_and_purge_obey_24_hour_gate(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        trash_dir = apply_cleanup(self.root, manifest_id)

        self.assertFalse((self.root / job_path / "artifacts").exists())
        self.assertTrue((trash_dir / job_path / "artifacts").is_dir())
        restore_cleanup(self.root, manifest_id)
        self.assertTrue((self.root / job_path / "artifacts").is_dir())
        self.assertFalse(trash_dir.exists())

        later = NOW + timedelta(minutes=1)
        plan = evaluate_cleanup(self.root, later, max_bytes=10_000, min_free_bytes=0)
        second_manifest_id = write_cleanup_manifest(self.root, plan)
        with mock.patch("tools.ci.artifact_cleanup._utc_now", return_value=later):
            second_trash = apply_cleanup(self.root, second_manifest_id)
        with self.assertRaisesRegex(ValueError, "24 hours"):
            purge_trash(self.root, second_manifest_id, later + timedelta(hours=1))
        purge_trash(self.root, second_manifest_id, later + timedelta(hours=25))
        self.assertFalse(second_trash.exists())

    def test_apply_rejects_generation_drift_and_active_lock(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)

        manifest_path = self.root / job_path / "manifest.json"
        manifest_path.write_text(
            manifest_path.read_text(encoding="utf-8") + "\n",
            encoding="utf-8",
        )
        with self.assertRaisesRegex(ValueError, "generation"):
            apply_cleanup(self.root, manifest_id)

        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        lock = self.root / "locks" / "active.lock"
        lock.parent.mkdir(exist_ok=True)
        lock.write_text("active", encoding="utf-8")
        with self.assertRaisesRegex(RuntimeError, "active lock"):
            apply_cleanup(self.root, manifest_id)

    def test_apply_rejects_cleanup_manifest_hash_tampering(self) -> None:
        self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        manifest_path = self.root / "cleanup-manifests" / f"{manifest_id}.json"
        payload = json.loads(manifest_path.read_text(encoding="utf-8"))
        payload["max_bytes"] = 1
        manifest_path.write_text(json.dumps(payload), encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "manifest integrity"):
            apply_cleanup(self.root, manifest_id)

    def test_apply_rejects_raw_artifact_drift(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        artifact = self.root / job_path / "artifacts" / "quality" / "result.bin"
        artifact.write_bytes(b"changed-after-review")

        with self.assertRaisesRegex(ValueError, "generation"):
            apply_cleanup(self.root, manifest_id)

    def test_restore_rolls_back_when_a_destination_conflicts(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        trash_dir = apply_cleanup(self.root, manifest_id)
        conflict = self.root / job_path / "artifacts"
        conflict.mkdir(parents=True)

        with self.assertRaisesRegex(FileExistsError, "restore destination"):
            restore_cleanup(self.root, manifest_id)

        self.assertTrue((trash_dir / job_path / "artifacts").is_dir())
        self.assertTrue((trash_dir / job_path / "diagnostics").is_dir())
        self.assertFalse((self.root / job_path / "diagnostics").exists())

    def test_trash_manifest_integrity_blocks_tampered_restore_and_purge(self) -> None:
        self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        trash_dir = apply_cleanup(self.root, manifest_id)
        trash_manifest = trash_dir / "trash-manifest.json"
        payload = json.loads(trash_manifest.read_text(encoding="utf-8"))
        payload["applied_at"] = _iso(NOW - timedelta(days=10))
        trash_manifest.write_text(json.dumps(payload), encoding="utf-8")

        with self.assertRaisesRegex(ValueError, "trash manifest integrity"):
            restore_cleanup(self.root, manifest_id)
        with self.assertRaisesRegex(ValueError, "trash manifest integrity"):
            purge_trash(self.root, manifest_id, NOW + timedelta(days=20))

    def test_manifest_rejects_traversal_and_apply_rejects_symlink_escape(self) -> None:
        self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        malicious_candidate = replace(plan.candidates[0], paths=("../outside",))
        malicious_plan = replace(plan, candidates=(malicious_candidate,))
        with self.assertRaisesRegex(ValueError, "traversal"):
            write_cleanup_manifest(self.root, malicious_plan)

        manifest_id = write_cleanup_manifest(self.root, plan)
        candidate = plan.candidates[0]
        artifacts = self.root / candidate.job_path / "artifacts"
        outside = Path(self.temp_dir.name) / "outside"
        outside.mkdir()
        for path in sorted(artifacts.rglob("*"), reverse=True):
            if path.is_file():
                path.unlink()
            elif path.is_dir():
                path.rmdir()
        artifacts.rmdir()
        try:
            os.symlink(outside, artifacts, target_is_directory=True)
        except (OSError, NotImplementedError) as error:
            self.skipTest(f"symlink unavailable: {error}")
        with self.assertRaisesRegex(ValueError, "symlink"):
            apply_cleanup(self.root, manifest_id)

    def test_apply_rejects_missing_source_instead_of_silently_skipping(self) -> None:
        job_path = self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        shutil_target = self.root / job_path / "diagnostics"
        for path in sorted(shutil_target.rglob("*"), reverse=True):
            if path.is_file():
                path.unlink()
            elif path.is_dir():
                path.rmdir()
        shutil_target.rmdir()

        with self.assertRaisesRegex(FileNotFoundError, "cleanup source"):
            apply_cleanup(self.root, manifest_id)

    def test_cleanup_operation_lock_blocks_mutating_operations(self) -> None:
        self._write_job(
            "verification-success",
            NOW - timedelta(days=8),
        )
        plan = evaluate_cleanup(self.root, NOW, max_bytes=10_000, min_free_bytes=0)
        manifest_id = write_cleanup_manifest(self.root, plan)
        lock = self.root / "locks" / "cleanup-operation.lock"
        lock.parent.mkdir()
        lock.write_text("busy", encoding="utf-8")

        with self.assertRaisesRegex(RuntimeError, "cleanup operation"):
            apply_cleanup(self.root, manifest_id)

        lock.unlink()
        trash_dir = apply_cleanup(self.root, manifest_id)
        lock.write_text("busy", encoding="utf-8")
        with self.assertRaisesRegex(RuntimeError, "cleanup operation"):
            restore_cleanup(self.root, manifest_id)
        with self.assertRaisesRegex(RuntimeError, "cleanup operation"):
            purge_trash(self.root, manifest_id, NOW + timedelta(hours=25))
        self.assertTrue(trash_dir.exists())


if __name__ == "__main__":
    unittest.main()
