from __future__ import annotations

import argparse
import hashlib
import hmac
import json
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, Iterator, List, Optional, Sequence, Tuple

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.artifact_contract import validate_artifact_root
from tools.ci.secret_leakage import assert_secret_safe_text


SCHEMA_VERSION = 1
DEFAULT_REPLACEMENT_EVIDENCE_ROUTE = (
    "docs/audits/milestone_32/32-9_runtime_acceptance_review.md"
)
_REPOSITORY_PATTERN = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
_SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")
_REVIEW_STATUSES = frozenset({"pending", "reviewed"})


class GitHubStorageCleanupError(ValueError):
    pass


class GitHubStorageDeletionError(RuntimeError):
    def __init__(
        self,
        *,
        manifest_id: str,
        attempts: Sequence["DeletionAttempt"],
        failed_object_type: str,
        failed_object_id: int,
    ) -> None:
        super().__init__(
            "GitHub storage deletion stopped after an exact-ID API failure "
            f"({failed_object_type}:{failed_object_id})"
        )
        self.manifest_id = manifest_id
        self.attempts = tuple(attempts)
        self.failed_object_type = failed_object_type
        self.failed_object_id = failed_object_id


def _canonical_json(value: Any) -> bytes:
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")


def _sha256_json(value: Any) -> str:
    return hashlib.sha256(_canonical_json(value)).hexdigest()


def _utc_now() -> str:
    return (
        datetime.now(timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )


def _require_repository(value: Any) -> str:
    if not isinstance(value, str) or not _REPOSITORY_PATTERN.fullmatch(value):
        raise GitHubStorageCleanupError("repository must use owner/name format")
    return value


def _require_positive_int(value: Any, *, label: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
        raise GitHubStorageCleanupError(f"{label} must be a positive integer")
    return value


def _require_non_negative_int(value: Any, *, label: str) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise GitHubStorageCleanupError(f"{label} must be a non-negative integer")
    return value


def _require_text(value: Any, *, label: str, allow_empty: bool = False) -> str:
    if not isinstance(value, str):
        raise GitHubStorageCleanupError(f"{label} must be text")
    if not allow_empty and not value.strip():
        raise GitHubStorageCleanupError(f"{label} cannot be empty")
    if "\n" in value or "\r" in value:
        raise GitHubStorageCleanupError(f"{label} cannot contain newlines")
    return value


def _optional_text(value: Any, *, label: str) -> Optional[str]:
    if value is None:
        return None
    return _require_text(value, label=label)


def _require_secret_safe_text(value: Any, *, label: str) -> str:
    text = _require_text(value, label=label)
    try:
        assert_secret_safe_text(text, label=label)
    except ValueError as error:
        raise GitHubStorageCleanupError(str(error)) from None
    return text


@dataclass(frozen=True)
class GitHubArtifact:
    object_id: int
    name: str
    bytes: int
    created_at: str
    updated_at: str
    expired: bool
    workflow_run_id: Optional[int]
    ref: Optional[str]
    head_sha: Optional[str]

    def to_inventory_dict(self) -> Dict[str, Any]:
        return {
            "object_type": "artifact",
            "object_id": self.object_id,
            "name": self.name,
            "bytes": self.bytes,
            "created_at": self.created_at,
            "updated_at": self.updated_at,
            "expired": self.expired,
            "workflow_run_id": self.workflow_run_id,
            "ref": self.ref,
            "head_sha": self.head_sha,
        }


@dataclass(frozen=True)
class GitHubCache:
    object_id: int
    key: str
    version: str
    ref: str
    bytes: int
    created_at: str
    last_accessed_at: str

    def to_inventory_dict(self) -> Dict[str, Any]:
        return {
            "object_type": "cache",
            "object_id": self.object_id,
            "key": self.key,
            "version": self.version,
            "ref": self.ref,
            "bytes": self.bytes,
            "created_at": self.created_at,
            "last_accessed_at": self.last_accessed_at,
        }


@dataclass(frozen=True)
class Inventory:
    repository: str
    collected_at: str
    artifacts: Tuple[GitHubArtifact, ...]
    caches: Tuple[GitHubCache, ...]

    @property
    def artifact_bytes(self) -> int:
        return sum(item.bytes for item in self.artifacts)

    @property
    def cache_bytes(self) -> int:
        return sum(item.bytes for item in self.caches)

    @property
    def total_bytes(self) -> int:
        return self.artifact_bytes + self.cache_bytes

    @property
    def total_count(self) -> int:
        return len(self.artifacts) + len(self.caches)

    def scope_dict(self) -> Dict[str, Any]:
        return {
            "repository": self.repository,
            "artifacts": [item.to_inventory_dict() for item in self.artifacts],
            "caches": [item.to_inventory_dict() for item in self.caches],
        }

    def deletion_scope_dict(self) -> Dict[str, Any]:
        return {
            "repository": self.repository,
            "artifacts": [
                {
                    "object_type": "artifact",
                    "object_id": item.object_id,
                    "name": item.name,
                    "bytes": item.bytes,
                    "created_at": item.created_at,
                    "updated_at": item.updated_at,
                    "workflow_run_id": item.workflow_run_id,
                    "ref": item.ref,
                }
                for item in self.artifacts
            ],
            "caches": [
                {
                    "object_type": "cache",
                    "object_id": item.object_id,
                    "key": item.key,
                    "ref": item.ref,
                    "bytes": item.bytes,
                    "created_at": item.created_at,
                    "last_accessed_at": item.last_accessed_at,
                }
                for item in self.caches
            ],
        }

    @property
    def sha256(self) -> str:
        return _sha256_json(self.deletion_scope_dict())

    def totals_dict(self) -> Dict[str, Dict[str, int]]:
        return {
            "artifacts": {
                "count": len(self.artifacts),
                "bytes": self.artifact_bytes,
            },
            "caches": {
                "count": len(self.caches),
                "bytes": self.cache_bytes,
            },
            "all": {
                "count": self.total_count,
                "bytes": self.total_bytes,
            },
        }

    def to_dict(self) -> Dict[str, Any]:
        payload = self.scope_dict()
        payload.update(
            {
                "schema_version": SCHEMA_VERSION,
                "collected_at": self.collected_at,
                "inventory_sha256": self.sha256,
                "totals": self.totals_dict(),
            }
        )
        return payload


@dataclass(frozen=True)
class DeletionCandidate:
    object_type: str
    object_id: int
    display_name: str
    bytes: int
    created_at: str
    updated_or_accessed_at: str
    workflow_run_id: Optional[int]
    ref: Optional[str]
    classification: str
    reason: str
    replacement_evidence_route: str

    def to_dict(self) -> Dict[str, Any]:
        return {
            "object_type": self.object_type,
            "object_id": self.object_id,
            "name_or_key": self.display_name,
            "bytes": self.bytes,
            "created_at": self.created_at,
            "updated_or_accessed_at": self.updated_or_accessed_at,
            "workflow_run_id": self.workflow_run_id,
            "ref": self.ref,
            "classification": self.classification,
            "reason": self.reason,
            "replacement_evidence_route": self.replacement_evidence_route,
        }


@dataclass(frozen=True)
class ClassificationResult(Sequence[DeletionCandidate]):
    inventory: Inventory
    candidates: Tuple[DeletionCandidate, ...]

    @property
    def inventory_sha256(self) -> str:
        return self.inventory.sha256

    def __getitem__(self, index):
        return self.candidates[index]

    def __len__(self) -> int:
        return len(self.candidates)

    def __iter__(self) -> Iterator[DeletionCandidate]:
        return iter(self.candidates)


@dataclass(frozen=True)
class DeletionResult:
    manifest_id: str
    deleted_artifact_ids: Tuple[int, ...]
    deleted_cache_ids: Tuple[int, ...]
    attempts: Tuple["DeletionAttempt", ...]


@dataclass(frozen=True)
class DeletionAttempt:
    object_type: str
    object_id: int
    status: str
    attempted_at: str
    error_type: Optional[str]


def _parse_artifact(raw: Dict[str, Any]) -> GitHubArtifact:
    workflow_run = raw.get("workflow_run")
    if workflow_run is not None and not isinstance(workflow_run, dict):
        raise GitHubStorageCleanupError("artifact workflow_run must be an object")
    workflow_run = workflow_run or {}
    workflow_run_id = workflow_run.get("id")
    if workflow_run_id is not None:
        workflow_run_id = _require_positive_int(
            workflow_run_id,
            label="artifact workflow run id",
        )
    head_sha = _optional_text(
        workflow_run.get("head_sha"),
        label="artifact workflow head sha",
    )
    if head_sha is not None and not re.fullmatch(r"[0-9a-fA-F]{40}", head_sha):
        raise GitHubStorageCleanupError("artifact workflow head sha must be 40 hex")
    head_branch = _optional_text(
        workflow_run.get("head_branch"),
        label="artifact workflow head branch",
    )
    ref = f"refs/heads/{head_branch}" if head_branch is not None else None
    expired = raw.get("expired", False)
    if not isinstance(expired, bool):
        raise GitHubStorageCleanupError("artifact expired must be boolean")
    return GitHubArtifact(
        object_id=_require_positive_int(raw.get("id"), label="artifact id"),
        name=_require_secret_safe_text(raw.get("name"), label="artifact name"),
        bytes=_require_non_negative_int(
            raw.get("size_in_bytes"),
            label="artifact bytes",
        ),
        created_at=_require_text(
            raw.get("created_at"),
            label="artifact created_at",
        ),
        updated_at=_require_text(
            raw.get("updated_at"),
            label="artifact updated_at",
        ),
        expired=expired,
        workflow_run_id=workflow_run_id,
        ref=ref,
        head_sha=head_sha.lower() if head_sha is not None else None,
    )


def _parse_cache(raw: Dict[str, Any]) -> GitHubCache:
    return GitHubCache(
        object_id=_require_positive_int(raw.get("id"), label="cache id"),
        key=_require_secret_safe_text(raw.get("key"), label="cache key"),
        version=_require_text(raw.get("version"), label="cache version"),
        ref=_require_text(raw.get("ref"), label="cache ref"),
        bytes=_require_non_negative_int(
            raw.get("size_in_bytes"),
            label="cache bytes",
        ),
        created_at=_require_text(raw.get("created_at"), label="cache created_at"),
        last_accessed_at=_require_text(
            raw.get("last_accessed_at"),
            label="cache last_accessed_at",
        ),
    )


def collect_inventory(api_client, now: Optional[str] = None) -> Inventory:
    repository = _require_repository(api_client.repository)
    collected_at = _require_text(now or _utc_now(), label="collected_at")
    raw_artifacts = api_client.list_artifacts()
    raw_caches = api_client.list_caches()
    if not isinstance(raw_artifacts, list) or not isinstance(raw_caches, list):
        raise GitHubStorageCleanupError("GitHub inventory responses must be lists")

    artifacts = tuple(sorted((_parse_artifact(item) for item in raw_artifacts), key=lambda item: item.object_id))
    caches = tuple(sorted((_parse_cache(item) for item in raw_caches), key=lambda item: item.object_id))
    object_keys = [
        *(f"artifact:{item.object_id}" for item in artifacts),
        *(f"cache:{item.object_id}" for item in caches),
    ]
    if len(object_keys) != len(set(object_keys)):
        raise GitHubStorageCleanupError("GitHub inventory contains duplicate object ids")
    return Inventory(
        repository=repository,
        collected_at=collected_at,
        artifacts=artifacts,
        caches=caches,
    )


def classify_inventory(
    inventory: Inventory,
    *,
    replacement_evidence_route: str = DEFAULT_REPLACEMENT_EVIDENCE_ROUTE,
) -> ClassificationResult:
    route = _require_text(
        replacement_evidence_route,
        label="replacement evidence route",
    )
    candidates: List[DeletionCandidate] = []
    for artifact in inventory.artifacts:
        candidates.append(
            DeletionCandidate(
                object_type="artifact",
                object_id=artifact.object_id,
                display_name=artifact.name,
                bytes=artifact.bytes,
                created_at=artifact.created_at,
                updated_or_accessed_at=artifact.updated_at,
                workflow_run_id=artifact.workflow_run_id,
                ref=artifact.ref,
                classification="legacy-github-artifact",
                reason=(
                    "Task 9 verified the managed local replacement route and "
                    "GitHub storage no-growth"
                ),
                replacement_evidence_route=route,
            )
        )
    for cache in inventory.caches:
        candidates.append(
            DeletionCandidate(
                object_type="cache",
                object_id=cache.object_id,
                display_name=cache.key,
                bytes=cache.bytes,
                created_at=cache.created_at,
                updated_or_accessed_at=cache.last_accessed_at,
                workflow_run_id=None,
                ref=cache.ref,
                classification="legacy-github-cache",
                reason=(
                    "Current workflow contracts do not use actions/cache and "
                    "Task 9 confirmed no new GitHub cache objects"
                ),
                replacement_evidence_route=route,
            )
        )
    return ClassificationResult(
        inventory=inventory,
        candidates=tuple(candidates),
    )


def approval_token_for_manifest_id(manifest_id: str) -> str:
    safe_id = _require_text(manifest_id, label="manifest id")
    if not re.fullmatch(r"[0-9a-f]{24}", safe_id):
        raise GitHubStorageCleanupError("manifest id must be 24 lowercase hex")
    return f"DELETE-GITHUB-STORAGE-{safe_id}"


def _assert_safe_output_dir(output_dir: Path) -> Path:
    path = output_dir.expanduser()
    if not path.is_absolute():
        raise GitHubStorageCleanupError("manifest output directory must be absolute")
    for component in (path, *path.parents):
        if component.exists() and component.is_symlink():
            raise GitHubStorageCleanupError(
                f"manifest output directory contains symlink: {component}"
            )
    path.mkdir(parents=True, exist_ok=True, mode=0o700)
    if path.is_symlink():
        raise GitHubStorageCleanupError("manifest output directory cannot be a symlink")
    return path


def _manifest_scope(plan: ClassificationResult) -> Dict[str, Any]:
    return {
        "repository": plan.inventory.repository,
        "inventory_sha256": plan.inventory.sha256,
        "pre_delete_totals": plan.inventory.totals_dict(),
        "candidates": [item.to_dict() for item in plan],
        "replacement_evidence_routes": sorted(
            {item.replacement_evidence_route for item in plan}
        ),
    }


def _atomic_write(path: Path, data: bytes) -> None:
    if path.exists() and path.is_symlink():
        raise GitHubStorageCleanupError(f"refusing to overwrite symlink: {path}")
    with tempfile.NamedTemporaryFile(
        mode="wb",
        dir=str(path.parent),
        prefix=f".{path.name}.",
        delete=False,
    ) as handle:
        temp_path = Path(handle.name)
        handle.write(data)
        handle.flush()
        os.fsync(handle.fileno())
    try:
        temp_path.replace(path)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def write_deletion_manifest(
    candidates: Sequence[DeletionCandidate],
    output_dir: Path,
    *,
    review_status: str = "pending",
    reviewed_by: Optional[str] = None,
    reviewed_at: Optional[str] = None,
) -> str:
    if not isinstance(candidates, ClassificationResult):
        raise GitHubStorageCleanupError(
            "manifest creation requires the complete classified inventory"
        )
    if review_status not in _REVIEW_STATUSES:
        raise GitHubStorageCleanupError("review status must be pending or reviewed")
    if review_status == "reviewed":
        reviewed_by = _require_text(reviewed_by, label="reviewed_by")
        reviewed_at = _require_text(reviewed_at or _utc_now(), label="reviewed_at")
    else:
        if reviewed_by is not None or reviewed_at is not None:
            raise GitHubStorageCleanupError(
                "pending manifest cannot contain review attestation"
            )

    scope = _manifest_scope(candidates)
    manifest_id = _sha256_json(scope)[:24]
    token = approval_token_for_manifest_id(manifest_id)
    payload = {
        "schema_version": SCHEMA_VERSION,
        "manifest_id": manifest_id,
        "repository": candidates.inventory.repository,
        "generated_at": candidates.inventory.collected_at,
        "inventory_sha256": candidates.inventory.sha256,
        "pre_delete_totals": candidates.inventory.totals_dict(),
        "candidates": [item.to_dict() for item in candidates],
        "replacement_evidence_routes": scope["replacement_evidence_routes"],
        "review": {
            "status": review_status,
            "reviewed_by": reviewed_by,
            "reviewed_at": reviewed_at,
        },
        "approval": {
            "required": True,
            "token_sha256": hashlib.sha256(token.encode("utf-8")).hexdigest(),
            "token_delivery": "out-of-band after reviewed manifest reporting",
        },
    }
    envelope = {
        "payload": payload,
        "payload_sha256": _sha256_json(payload),
    }

    root = _assert_safe_output_dir(Path(output_dir))
    manifest_dir = _assert_safe_output_dir(root / manifest_id)
    manifest_path = manifest_dir / "deletion-manifest.json"
    manifest_bytes = (
        json.dumps(envelope, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    ).encode("utf-8")
    _atomic_write(manifest_path, manifest_bytes)
    sidecar = (
        f"{hashlib.sha256(manifest_bytes).hexdigest()}  {manifest_path.name}\n"
    ).encode("utf-8")
    _atomic_write(manifest_dir / "deletion-manifest.sha256", sidecar)
    return str(manifest_path)


def load_deletion_manifest(manifest_path: Path) -> Dict[str, Any]:
    path = Path(manifest_path)
    if not path.is_file() or path.is_symlink():
        raise GitHubStorageCleanupError("deletion manifest must be a regular file")
    sidecar = path.parent / "deletion-manifest.sha256"
    if not sidecar.is_file() or sidecar.is_symlink():
        raise GitHubStorageCleanupError("deletion manifest integrity sidecar is missing")

    manifest_bytes = path.read_bytes()
    sidecar_parts = sidecar.read_text(encoding="utf-8").strip().split()
    if len(sidecar_parts) != 2 or sidecar_parts[1] != path.name:
        raise GitHubStorageCleanupError("deletion manifest integrity sidecar is invalid")
    if not _SHA256_PATTERN.fullmatch(sidecar_parts[0]):
        raise GitHubStorageCleanupError("deletion manifest integrity hash is invalid")
    if not hmac.compare_digest(
        hashlib.sha256(manifest_bytes).hexdigest(),
        sidecar_parts[0],
    ):
        raise GitHubStorageCleanupError("deletion manifest integrity check failed")

    try:
        envelope = json.loads(manifest_bytes)
    except json.JSONDecodeError as error:
        raise GitHubStorageCleanupError(
            "deletion manifest integrity JSON is invalid"
        ) from error
    if not isinstance(envelope, dict) or set(envelope) != {
        "payload",
        "payload_sha256",
    }:
        raise GitHubStorageCleanupError("deletion manifest envelope is invalid")
    payload = envelope["payload"]
    payload_sha256 = envelope["payload_sha256"]
    if not isinstance(payload, dict) or not isinstance(payload_sha256, str):
        raise GitHubStorageCleanupError("deletion manifest payload is invalid")
    if not _SHA256_PATTERN.fullmatch(payload_sha256) or not hmac.compare_digest(
        _sha256_json(payload),
        payload_sha256,
    ):
        raise GitHubStorageCleanupError("deletion manifest payload integrity failed")
    _validate_manifest_payload(payload)
    return payload


def _validate_manifest_payload(payload: Dict[str, Any]) -> None:
    required_keys = {
        "schema_version",
        "manifest_id",
        "repository",
        "generated_at",
        "inventory_sha256",
        "pre_delete_totals",
        "candidates",
        "replacement_evidence_routes",
        "review",
        "approval",
    }
    if set(payload) != required_keys:
        raise GitHubStorageCleanupError("deletion manifest payload fields are invalid")
    if payload["schema_version"] != SCHEMA_VERSION:
        raise GitHubStorageCleanupError("unsupported deletion manifest schema")
    manifest_id = payload["manifest_id"]
    approval_token_for_manifest_id(manifest_id)
    _require_repository(payload["repository"])
    _require_text(payload["generated_at"], label="generated_at")
    if not isinstance(payload["inventory_sha256"], str) or not _SHA256_PATTERN.fullmatch(
        payload["inventory_sha256"]
    ):
        raise GitHubStorageCleanupError("inventory sha256 is invalid")
    if not isinstance(payload["candidates"], list):
        raise GitHubStorageCleanupError("deletion candidates must be a list")
    seen = set()
    artifact_count = artifact_bytes = cache_count = cache_bytes = 0
    for item in payload["candidates"]:
        if not isinstance(item, dict):
            raise GitHubStorageCleanupError("deletion candidate must be an object")
        if set(item) != {
            "object_type",
            "object_id",
            "name_or_key",
            "bytes",
            "created_at",
            "updated_or_accessed_at",
            "workflow_run_id",
            "ref",
            "classification",
            "reason",
            "replacement_evidence_route",
        }:
            raise GitHubStorageCleanupError("deletion candidate fields are invalid")
        object_type = item.get("object_type")
        if object_type not in {"artifact", "cache"}:
            raise GitHubStorageCleanupError("deletion candidate type is invalid")
        object_id = _require_positive_int(
            item.get("object_id"),
            label="deletion candidate id",
        )
        key = (object_type, object_id)
        if key in seen:
            raise GitHubStorageCleanupError("deletion candidate ids must be unique")
        seen.add(key)
        size_bytes = _require_non_negative_int(
            item.get("bytes"),
            label="deletion candidate bytes",
        )
        _require_text(item.get("name_or_key"), label="deletion candidate name")
        _require_text(item.get("created_at"), label="deletion candidate created_at")
        _require_text(
            item.get("updated_or_accessed_at"),
            label="deletion candidate updated_or_accessed_at",
        )
        workflow_run_id = item.get("workflow_run_id")
        if workflow_run_id is not None:
            _require_positive_int(
                workflow_run_id,
                label="deletion candidate workflow run id",
            )
        _optional_text(item.get("ref"), label="deletion candidate ref")
        _require_text(item.get("classification"), label="classification")
        _require_text(item.get("reason"), label="reason")
        _require_text(
            item.get("replacement_evidence_route"),
            label="replacement evidence route",
        )
        if object_type == "artifact":
            artifact_count += 1
            artifact_bytes += size_bytes
        else:
            cache_count += 1
            cache_bytes += size_bytes
    expected_totals = {
        "artifacts": {"count": artifact_count, "bytes": artifact_bytes},
        "caches": {"count": cache_count, "bytes": cache_bytes},
        "all": {
            "count": artifact_count + cache_count,
            "bytes": artifact_bytes + cache_bytes,
        },
    }
    if payload["pre_delete_totals"] != expected_totals:
        raise GitHubStorageCleanupError("deletion manifest totals are invalid")
    routes = payload["replacement_evidence_routes"]
    if not isinstance(routes, list) or sorted(set(routes)) != routes or not routes:
        raise GitHubStorageCleanupError("replacement evidence routes are invalid")
    candidate_routes = sorted(
        {item["replacement_evidence_route"] for item in payload["candidates"]}
    )
    if routes != candidate_routes:
        raise GitHubStorageCleanupError(
            "replacement evidence routes do not match deletion candidates"
        )
    expected_manifest_id = _sha256_json(
        {
            "repository": payload["repository"],
            "inventory_sha256": payload["inventory_sha256"],
            "pre_delete_totals": payload["pre_delete_totals"],
            "candidates": payload["candidates"],
            "replacement_evidence_routes": routes,
        }
    )[:24]
    if not hmac.compare_digest(manifest_id, expected_manifest_id):
        raise GitHubStorageCleanupError(
            "manifest id does not match the exact deletion scope"
        )
    review = payload["review"]
    if not isinstance(review, dict) or set(review) != {
        "status",
        "reviewed_by",
        "reviewed_at",
    }:
        raise GitHubStorageCleanupError("manifest review fields are invalid")
    if review["status"] not in _REVIEW_STATUSES:
        raise GitHubStorageCleanupError("manifest review status is invalid")
    if review["status"] == "reviewed":
        _require_text(review["reviewed_by"], label="reviewed_by")
        _require_text(review["reviewed_at"], label="reviewed_at")
    elif review["reviewed_by"] is not None or review["reviewed_at"] is not None:
        raise GitHubStorageCleanupError("pending manifest cannot be reviewed")
    approval = payload["approval"]
    if not isinstance(approval, dict) or set(approval) != {
        "required",
        "token_sha256",
        "token_delivery",
    }:
        raise GitHubStorageCleanupError("manifest approval fields are invalid")
    if approval["required"] is not True:
        raise GitHubStorageCleanupError("manifest approval must be required")
    if not isinstance(approval["token_sha256"], str) or not _SHA256_PATTERN.fullmatch(
        approval["token_sha256"]
    ):
        raise GitHubStorageCleanupError("approval token hash is invalid")
    expected_token_hash = hashlib.sha256(
        approval_token_for_manifest_id(manifest_id).encode("utf-8")
    ).hexdigest()
    if not hmac.compare_digest(approval["token_sha256"], expected_token_hash):
        raise GitHubStorageCleanupError(
            "approval token hash does not match manifest id"
        )


def _candidate_scope(payload: Dict[str, Any]) -> List[Tuple[str, int, int]]:
    return [
        (item["object_type"], item["object_id"], item["bytes"])
        for item in payload["candidates"]
    ]


def delete_from_manifest(
    api_client,
    manifest_path: Path,
    approval_token: str,
) -> DeletionResult:
    payload = load_deletion_manifest(manifest_path)
    if payload["review"]["status"] != "reviewed":
        raise GitHubStorageCleanupError("deletion manifest must be reviewed")
    token = _require_text(approval_token, label="approval token")
    if not hmac.compare_digest(
        hashlib.sha256(token.encode("utf-8")).hexdigest(),
        payload["approval"]["token_sha256"],
    ):
        raise GitHubStorageCleanupError("approval token does not match manifest")
    if _require_repository(api_client.repository) != payload["repository"]:
        raise GitHubStorageCleanupError("manifest repository does not match API client")

    fresh_inventory = collect_inventory(api_client)
    fresh_plan = classify_inventory(
        fresh_inventory,
        replacement_evidence_route=payload["replacement_evidence_routes"][0],
    )
    if (
        fresh_inventory.sha256 != payload["inventory_sha256"]
        or fresh_inventory.totals_dict() != payload["pre_delete_totals"]
        or [
            (item.object_type, item.object_id, item.bytes) for item in fresh_plan
        ]
        != _candidate_scope(payload)
    ):
        raise GitHubStorageCleanupError(
            "GitHub inventory drift detected; regenerate and review manifest"
        )

    deleted_artifact_ids: List[int] = []
    deleted_cache_ids: List[int] = []
    attempts: List[DeletionAttempt] = []
    for item in payload["candidates"]:
        if item["object_type"] != "artifact":
            continue
        attempted_at = _utc_now()
        try:
            api_client.delete_artifact(item["object_id"])
        except Exception as error:
            attempts.append(
                DeletionAttempt(
                    object_type="artifact",
                    object_id=item["object_id"],
                    status="failed",
                    attempted_at=attempted_at,
                    error_type=type(error).__name__,
                )
            )
            raise GitHubStorageDeletionError(
                manifest_id=payload["manifest_id"],
                attempts=attempts,
                failed_object_type="artifact",
                failed_object_id=item["object_id"],
            ) from error
        attempts.append(
            DeletionAttempt(
                object_type="artifact",
                object_id=item["object_id"],
                status="deleted",
                attempted_at=attempted_at,
                error_type=None,
            )
        )
        deleted_artifact_ids.append(item["object_id"])
    for item in payload["candidates"]:
        if item["object_type"] != "cache":
            continue
        attempted_at = _utc_now()
        try:
            api_client.delete_cache(item["object_id"])
        except Exception as error:
            attempts.append(
                DeletionAttempt(
                    object_type="cache",
                    object_id=item["object_id"],
                    status="failed",
                    attempted_at=attempted_at,
                    error_type=type(error).__name__,
                )
            )
            raise GitHubStorageDeletionError(
                manifest_id=payload["manifest_id"],
                attempts=attempts,
                failed_object_type="cache",
                failed_object_id=item["object_id"],
            ) from error
        attempts.append(
            DeletionAttempt(
                object_type="cache",
                object_id=item["object_id"],
                status="deleted",
                attempted_at=attempted_at,
                error_type=None,
            )
        )
        deleted_cache_ids.append(item["object_id"])
    return DeletionResult(
        manifest_id=payload["manifest_id"],
        deleted_artifact_ids=tuple(deleted_artifact_ids),
        deleted_cache_ids=tuple(deleted_cache_ids),
        attempts=tuple(attempts),
    )


class GitHubCliApiClient:
    def __init__(self, repository: str) -> None:
        self.repository = _require_repository(repository)

    def _list_pages(self, endpoint: str) -> List[Dict[str, Any]]:
        result = subprocess.run(
            ["gh", "api", "--paginate", "--slurp", endpoint],
            check=True,
            capture_output=True,
            text=True,
        )
        payload = json.loads(result.stdout)
        if not isinstance(payload, list) or not all(
            isinstance(page, dict) for page in payload
        ):
            raise GitHubStorageCleanupError("gh api pagination response is invalid")
        return payload

    def list_artifacts(self) -> List[Dict[str, Any]]:
        pages = self._list_pages(
            f"repos/{self.repository}/actions/artifacts?per_page=100"
        )
        return [item for page in pages for item in page.get("artifacts", [])]

    def list_caches(self) -> List[Dict[str, Any]]:
        pages = self._list_pages(
            f"repos/{self.repository}/actions/caches?per_page=100"
        )
        return [item for page in pages for item in page.get("actions_caches", [])]

    def delete_artifact(self, object_id: int) -> None:
        safe_id = _require_positive_int(object_id, label="artifact id")
        subprocess.run(
            [
                "gh",
                "api",
                "--method",
                "DELETE",
                f"repos/{self.repository}/actions/artifacts/{safe_id}",
            ],
            check=True,
        )

    def delete_cache(self, object_id: int) -> None:
        safe_id = _require_positive_int(object_id, label="cache id")
        subprocess.run(
            [
                "gh",
                "api",
                "--method",
                "DELETE",
                f"repos/{self.repository}/actions/caches/{safe_id}",
            ],
            check=True,
        )


def _write_json_output(payload: Dict[str, Any], output: Optional[str]) -> None:
    text = json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    if output is None:
        sys.stdout.write(text)
        return
    path = Path(output).expanduser()
    if not path.is_absolute():
        raise GitHubStorageCleanupError("output path must be absolute")
    path.parent.mkdir(parents=True, exist_ok=True)
    _atomic_write(path, text.encode("utf-8"))


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Inventory and exact-ID GitHub Actions storage cleanup"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    inventory_parser = subparsers.add_parser("inventory")
    inventory_parser.add_argument("--repository", required=True)
    inventory_parser.add_argument("--output")

    manifest_parser = subparsers.add_parser("manifest")
    manifest_parser.add_argument("--repository", required=True)
    manifest_parser.add_argument("--root", required=True)
    manifest_parser.add_argument(
        "--replacement-evidence-route",
        default=DEFAULT_REPLACEMENT_EVIDENCE_ROUTE,
    )
    manifest_parser.add_argument("--reviewed", action="store_true")
    manifest_parser.add_argument("--reviewed-by")

    delete_parser = subparsers.add_parser("delete")
    delete_parser.add_argument("--repository", required=True)
    delete_parser.add_argument("--manifest", required=True)
    delete_parser.add_argument("--approval-token", required=True)
    delete_parser.add_argument("--execute-delete", action="store_true")
    return parser


def main(argv: Optional[Sequence[str]] = None) -> int:
    args = _build_parser().parse_args(argv)
    client = GitHubCliApiClient(args.repository)
    if args.command == "inventory":
        inventory = collect_inventory(client)
        _write_json_output(inventory.to_dict(), args.output)
        return 0
    if args.command == "manifest":
        root = Path(args.root).expanduser()
        repo_root = Path.cwd()
        validated_root = validate_artifact_root(root, repo_root, home=Path.home())
        inventory = collect_inventory(client)
        plan = classify_inventory(
            inventory,
            replacement_evidence_route=args.replacement_evidence_route,
        )
        manifest_path = write_deletion_manifest(
            plan,
            validated_root / "cleanup-manifests" / "github",
            review_status="reviewed" if args.reviewed else "pending",
            reviewed_by=args.reviewed_by,
        )
        payload = load_deletion_manifest(Path(manifest_path))
        _write_json_output(
            {
                "manifest_id": payload["manifest_id"],
                "manifest_path": manifest_path,
                "payload_sha256": _sha256_json(payload),
                "review_status": payload["review"]["status"],
                "pre_delete_totals": payload["pre_delete_totals"],
            },
            None,
        )
        return 0
    if args.command == "delete":
        if not args.execute_delete:
            raise GitHubStorageCleanupError(
                "delete command requires the explicit --execute-delete gate"
            )
        result = delete_from_manifest(
            client,
            Path(args.manifest),
            args.approval_token,
        )
        _write_json_output(
            {
                "manifest_id": result.manifest_id,
                "deleted_artifact_ids": list(result.deleted_artifact_ids),
                "deleted_cache_ids": list(result.deleted_cache_ids),
                "attempts": [
                    {
                        "object_type": attempt.object_type,
                        "object_id": attempt.object_id,
                        "status": attempt.status,
                        "attempted_at": attempt.attempted_at,
                        "error_type": attempt.error_type,
                    }
                    for attempt in result.attempts
                ],
            },
            None,
        )
        return 0
    raise GitHubStorageCleanupError("unsupported command")


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except GitHubStorageDeletionError as error:
        print(
            json.dumps(
                {
                    "error": str(error),
                    "manifest_id": error.manifest_id,
                    "failed_object_type": error.failed_object_type,
                    "failed_object_id": error.failed_object_id,
                    "attempts": [
                        {
                            "object_type": attempt.object_type,
                            "object_id": attempt.object_id,
                            "status": attempt.status,
                            "attempted_at": attempt.attempted_at,
                            "error_type": attempt.error_type,
                        }
                        for attempt in error.attempts
                    ],
                },
                ensure_ascii=False,
            ),
            file=sys.stderr,
        )
        raise SystemExit(3)
    except GitHubStorageCleanupError as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(2)
