import copy
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.ci.github_storage_cleanup import (
    GitHubCliApiClient,
    GitHubStorageCleanupError,
    GitHubStorageDeletionError,
    approval_token_for_manifest_id,
    classify_inventory,
    collect_inventory,
    delete_from_manifest,
    load_deletion_manifest,
    write_deletion_manifest,
)


REPOSITORY = "MagicalWater/flutter_architecture"
COLLECTED_AT = "2026-07-30T14:20:00Z"
REPLACEMENT_EVIDENCE = (
    "docs/audits/milestone_32/32-9_runtime_acceptance_review.md"
)


def _artifact(
    object_id: int,
    name: str,
    size_bytes: int,
    run_id: int,
    ref: str,
) -> dict:
    return {
        "id": object_id,
        "name": name,
        "size_in_bytes": size_bytes,
        "created_at": "2026-07-20T01:02:03Z",
        "updated_at": "2026-07-20T01:03:04Z",
        "expired": False,
        "workflow_run": {
            "id": run_id,
            "head_branch": ref.removeprefix("refs/heads/"),
            "head_sha": "a" * 40,
        },
    }


def _cache(object_id: int, key: str, size_bytes: int, ref: str) -> dict:
    return {
        "id": object_id,
        "key": key,
        "version": "cache-version-1",
        "ref": ref,
        "size_in_bytes": size_bytes,
        "created_at": "2026-07-19T02:03:04Z",
        "last_accessed_at": "2026-07-21T03:04:05Z",
    }


class FakeGitHubApiClient:
    def __init__(self) -> None:
        self.repository = REPOSITORY
        self.artifacts = [
            _artifact(
                101,
                "android-production-a1",
                120,
                1001,
                "refs/heads/main",
            ),
            _artifact(
                102,
                "ios-development-b2",
                230,
                1002,
                "refs/heads/main",
            ),
        ]
        self.caches = [
            _cache(201, "linux-pub-cache-a", 340, "refs/heads/main"),
            _cache(202, "macos-pods-cache-b", 450, "refs/heads/main"),
        ]
        self.delete_calls = []
        self.fail_on = None

    def list_artifacts(self):
        return copy.deepcopy(self.artifacts)

    def list_caches(self):
        return copy.deepcopy(self.caches)

    def delete_artifact(self, object_id: int) -> None:
        self.delete_calls.append(("artifact", object_id))
        if self.fail_on == ("artifact", object_id):
            raise RuntimeError("controlled artifact delete failure")

    def delete_cache(self, object_id: int) -> None:
        self.delete_calls.append(("cache", object_id))
        if self.fail_on == ("cache", object_id):
            raise RuntimeError("controlled cache delete failure")


class GitHubStorageCleanupTest(unittest.TestCase):
    def setUp(self) -> None:
        self.client = FakeGitHubApiClient()
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.output_root = Path(self.temp_dir.name).resolve()

    def _inventory(self):
        return collect_inventory(self.client, now=COLLECTED_AT)

    def _plan(self):
        return classify_inventory(
            self._inventory(),
            replacement_evidence_route=REPLACEMENT_EVIDENCE,
        )

    def _write_reviewed_manifest(self) -> Path:
        return Path(
            write_deletion_manifest(
                self._plan(),
                self.output_root,
                review_status="reviewed",
                reviewed_by="milestone-32-task-10-review",
                reviewed_at="2026-07-30T14:30:00Z",
            )
        )

    def test_manifest_tampering_is_rejected_before_any_delete(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        envelope = json.loads(manifest_path.read_text(encoding="utf-8"))
        envelope["payload"]["candidates"][0]["bytes"] = 999999
        manifest_path.write_text(json.dumps(envelope), encoding="utf-8")

        with self.assertRaisesRegex(GitHubStorageCleanupError, "integrity"):
            load_deletion_manifest(manifest_path)

        self.assertEqual(self.client.delete_calls, [])

    def test_rehashed_manifest_id_tampering_is_rejected(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        envelope = json.loads(manifest_path.read_text(encoding="utf-8"))
        envelope["payload"]["manifest_id"] = "f" * 24
        envelope["payload_sha256"] = hashlib.sha256(
            json.dumps(
                envelope["payload"],
                sort_keys=True,
                separators=(",", ":"),
            ).encode("utf-8")
        ).hexdigest()
        encoded = (
            json.dumps(envelope, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
        ).encode("utf-8")
        manifest_path.write_bytes(encoded)
        (manifest_path.parent / "deletion-manifest.sha256").write_text(
            f"{hashlib.sha256(encoded).hexdigest()}  {manifest_path.name}\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(GitHubStorageCleanupError, "manifest id"):
            load_deletion_manifest(manifest_path)

    def test_rehashed_approval_token_tampering_is_rejected(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        envelope = json.loads(manifest_path.read_text(encoding="utf-8"))
        envelope["payload"]["approval"]["token_sha256"] = hashlib.sha256(
            b"attacker-selected-token"
        ).hexdigest()
        envelope["payload_sha256"] = hashlib.sha256(
            json.dumps(
                envelope["payload"],
                sort_keys=True,
                separators=(",", ":"),
            ).encode("utf-8")
        ).hexdigest()
        encoded = (
            json.dumps(envelope, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
        ).encode("utf-8")
        manifest_path.write_bytes(encoded)
        (manifest_path.parent / "deletion-manifest.sha256").write_text(
            f"{hashlib.sha256(encoded).hexdigest()}  {manifest_path.name}\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(GitHubStorageCleanupError, "approval token"):
            load_deletion_manifest(manifest_path)

    def test_delete_requires_reviewed_manifest_and_exact_approval_token(self) -> None:
        pending_path = Path(
            write_deletion_manifest(
                self._plan(),
                self.output_root,
                review_status="pending",
            )
        )
        pending = load_deletion_manifest(pending_path)
        token = approval_token_for_manifest_id(pending["manifest_id"])

        with self.assertRaisesRegex(GitHubStorageCleanupError, "reviewed"):
            delete_from_manifest(self.client, pending_path, token)

        reviewed_path = self._write_reviewed_manifest()
        with self.assertRaisesRegex(GitHubStorageCleanupError, "approval token"):
            delete_from_manifest(self.client, reviewed_path, "wrong-token")

        self.assertEqual(self.client.delete_calls, [])

    def test_inventory_id_or_byte_drift_blocks_all_deletes(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        payload = load_deletion_manifest(manifest_path)
        token = approval_token_for_manifest_id(payload["manifest_id"])
        self.client.artifacts[0]["size_in_bytes"] += 1

        with self.assertRaisesRegex(GitHubStorageCleanupError, "inventory drift"):
            delete_from_manifest(self.client, manifest_path, token)

        self.assertEqual(self.client.delete_calls, [])

    def test_delete_uses_exact_ids_artifacts_first_then_caches(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        payload = load_deletion_manifest(manifest_path)
        token = approval_token_for_manifest_id(payload["manifest_id"])

        result = delete_from_manifest(self.client, manifest_path, token)

        self.assertEqual(
            self.client.delete_calls,
            [
                ("artifact", 101),
                ("artifact", 102),
                ("cache", 201),
                ("cache", 202),
            ],
        )
        self.assertEqual(result.deleted_artifact_ids, (101, 102))
        self.assertEqual(result.deleted_cache_ids, (201, 202))

    def test_delete_stops_immediately_on_unknown_failure(self) -> None:
        manifest_path = self._write_reviewed_manifest()
        payload = load_deletion_manifest(manifest_path)
        token = approval_token_for_manifest_id(payload["manifest_id"])
        self.client.fail_on = ("artifact", 102)

        with self.assertRaises(GitHubStorageDeletionError) as context:
            delete_from_manifest(self.client, manifest_path, token)

        self.assertEqual(
            self.client.delete_calls,
            [("artifact", 101), ("artifact", 102)],
        )
        self.assertEqual(
            [
                (attempt.object_type, attempt.object_id, attempt.status)
                for attempt in context.exception.attempts
            ],
            [
                ("artifact", 101, "deleted"),
                ("artifact", 102, "failed"),
            ],
        )
        self.assertEqual(context.exception.failed_object_type, "artifact")
        self.assertEqual(context.exception.failed_object_id, 102)

    def test_secret_bearing_object_name_is_rejected_without_echo(self) -> None:
        secret = "gho_ABCDEFGHIJKLMNOPQRSTUVWXYZ123456"
        self.client.artifacts[0]["name"] = secret

        with self.assertRaises(GitHubStorageCleanupError) as context:
            self._inventory()

        self.assertIn("secret leakage", str(context.exception))
        self.assertNotIn(secret, str(context.exception))

    def test_output_root_symlink_is_rejected(self) -> None:
        real_root = self.output_root / "real"
        real_root.mkdir()
        linked_root = self.output_root / "linked"
        linked_root.symlink_to(real_root, target_is_directory=True)

        with self.assertRaisesRegex(GitHubStorageCleanupError, "symlink"):
            write_deletion_manifest(self._plan(), linked_root)

    @mock.patch("tools.ci.github_storage_cleanup.subprocess.run")
    def test_production_delete_client_uses_only_exact_id_endpoints(
        self,
        run: mock.Mock,
    ) -> None:
        client = GitHubCliApiClient(REPOSITORY)

        client.delete_artifact(101)
        client.delete_cache(201)

        self.assertEqual(
            [call.args[0] for call in run.call_args_list],
            [
                [
                    "gh",
                    "api",
                    "--method",
                    "DELETE",
                    f"repos/{REPOSITORY}/actions/artifacts/101",
                ],
                [
                    "gh",
                    "api",
                    "--method",
                    "DELETE",
                    f"repos/{REPOSITORY}/actions/caches/201",
                ],
            ],
        )
        self.assertTrue(all(call.kwargs["check"] for call in run.call_args_list))


if __name__ == "__main__":
    unittest.main()
