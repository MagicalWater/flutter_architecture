import argparse
from contextlib import contextmanager
from dataclasses import asdict, dataclass
from datetime import datetime, timedelta, timezone
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import sys
import tempfile
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.artifact_contract import RETENTION_CLASSES, validate_job_manifest


DEFAULT_MAX_BYTES = 30 * 1024 * 1024 * 1024
DEFAULT_MIN_FREE_BYTES = 15 * 1024 * 1024 * 1024
TRASH_RETENTION_HOURS = 24
MAX_PIN_DAYS = 90

_PRIORITY = {
    "verification-success": 0,
    "verification-failure": 1,
    "observability-raw": 2,
    "release-verification": 3,
}


@dataclass(frozen=True)
class CleanupCandidate:
    job_path: str
    paths: Tuple[str, ...]
    bytes: int
    retention_class: str
    completed_at: str
    reasons: Tuple[str, ...]
    suite: str
    git_ref: str
    platform: str
    commit_sha: str
    pinned: bool = False


@dataclass(frozen=True)
class CleanupPlan:
    root: str
    generated_at: str
    store_generation: str
    store_bytes: int
    free_bytes: int
    max_bytes: int
    min_free_bytes: int
    candidates: Tuple[CleanupCandidate, ...]
    candidate_bytes: int
    projected_bytes_after_purge: int
    projected_free_after_purge: int
    blocking_bytes: int
    can_satisfy_capacity: bool


@dataclass(frozen=True)
class _JobRecord:
    job_path: str
    manifest_path: Path
    manifest_sha256: str
    retention_class: str
    completed_at: datetime
    suite: str
    git_ref: str
    platform: str
    commit_sha: str
    raw_paths: Tuple[str, ...]
    raw_bytes: int
    pinned: bool


def evaluate_cleanup(
    root: Path,
    now: datetime,
    max_bytes: int = DEFAULT_MAX_BYTES,
    min_free_bytes: int = DEFAULT_MIN_FREE_BYTES,
) -> CleanupPlan:
    store_root = _validate_store_root(root)
    current_time = _require_aware_utc(now)
    if max_bytes < 0:
        raise ValueError("max_bytes must be non-negative")
    if min_free_bytes < 0:
        raise ValueError("min_free_bytes must be non-negative")

    records = _scan_job_records(store_root, current_time)
    disk = shutil.disk_usage(store_root)
    store_bytes = sum(record.raw_bytes for record in records)

    reasons_by_job: Dict[str, set] = {record.job_path: set() for record in records}
    _mark_age_candidates(records, current_time, reasons_by_job)
    _mark_count_candidates(records, reasons_by_job)

    selected: Dict[str, _JobRecord] = {
        record.job_path: record
        for record in records
        if reasons_by_job[record.job_path] and not record.pinned and record.raw_bytes > 0
    }

    candidates = tuple(
        CleanupCandidate(
            job_path=record.job_path,
            paths=record.raw_paths,
            bytes=record.raw_bytes,
            retention_class=record.retention_class,
            completed_at=_format_time(record.completed_at),
            reasons=tuple(sorted(reasons_by_job[record.job_path])),
            suite=record.suite,
            git_ref=record.git_ref,
            platform=record.platform,
            commit_sha=record.commit_sha,
            pinned=False,
        )
        for record in _sort_records_for_cleanup(selected.values())
    )
    candidate_bytes = sum(candidate.bytes for candidate in candidates)
    projected_store = max(0, store_bytes - candidate_bytes)
    projected_free = disk.free + candidate_bytes
    blocking_bytes = max(
        max(0, projected_store - max_bytes),
        max(0, min_free_bytes - projected_free),
    )

    return CleanupPlan(
        root=str(store_root),
        generated_at=_format_time(current_time),
        store_generation=_compute_store_generation(store_root),
        store_bytes=store_bytes,
        free_bytes=disk.free,
        max_bytes=max_bytes,
        min_free_bytes=min_free_bytes,
        candidates=candidates,
        candidate_bytes=candidate_bytes,
        projected_bytes_after_purge=projected_store,
        projected_free_after_purge=projected_free,
        blocking_bytes=blocking_bytes,
        can_satisfy_capacity=blocking_bytes == 0,
    )


def write_cleanup_manifest(root: Path, plan: CleanupPlan) -> str:
    store_root = _validate_store_root(root)
    if Path(plan.root).resolve(strict=False) != store_root:
        raise ValueError("cleanup plan root mismatch")

    candidate_payloads: List[Dict[str, Any]] = []
    for candidate in plan.candidates:
        _validate_relative_path(candidate.job_path)
        for relative_path in candidate.paths:
            _validate_relative_path(relative_path)
            if not _is_descendant_relative(relative_path, candidate.job_path):
                raise ValueError("cleanup candidate path must stay within job path")
        candidate_payloads.append(asdict(candidate))

    body: Dict[str, Any] = {
        "schema_version": 1,
        "root": str(store_root),
        "generated_at": plan.generated_at,
        "store_generation": plan.store_generation,
        "store_bytes": plan.store_bytes,
        "free_bytes": plan.free_bytes,
        "max_bytes": plan.max_bytes,
        "min_free_bytes": plan.min_free_bytes,
        "candidate_bytes": plan.candidate_bytes,
        "projected_bytes_after_purge": plan.projected_bytes_after_purge,
        "projected_free_after_purge": plan.projected_free_after_purge,
        "blocking_bytes": plan.blocking_bytes,
        "can_satisfy_capacity": plan.can_satisfy_capacity,
        "candidates": candidate_payloads,
    }
    manifest_id = _hash_json(body)[:24]
    payload = dict(body)
    payload["manifest_id"] = manifest_id
    payload["manifest_sha256"] = _hash_json(payload)

    manifest_dir = store_root / "cleanup-manifests"
    _ensure_directory(manifest_dir)
    manifest_path = manifest_dir / f"{manifest_id}.json"
    if manifest_path.exists():
        existing = _read_json(manifest_path)
        if existing != payload:
            raise FileExistsError(f"cleanup manifest ID collision: {manifest_id}")
        return manifest_id
    _atomic_write_json(manifest_path, payload)
    return manifest_id


def apply_cleanup(root: Path, manifest_id: str) -> Path:
    store_root = _validate_store_root(root)
    payload = _load_cleanup_manifest(store_root, manifest_id)
    _assert_manifest_root(payload, store_root)
    _assert_no_active_jobs(store_root)
    with _cleanup_operation(store_root):
        _assert_no_active_jobs(store_root)
        sources = _preflight_cleanup_paths(store_root, payload)
        # Manifest 是針對特定 store snapshot 核准；cleanup lock 取得後仍要重驗
        # generation，避免 plan 產生後新增/變更 artifact 卻照舊刪除。
        if payload["store_generation"] != _compute_store_generation(store_root):
            raise ValueError("store generation drift detected")

        cleanup_id = payload["manifest_id"]
        trash_dir = store_root / "trash" / cleanup_id
        if trash_dir.exists():
            raise FileExistsError(f"cleanup trash already exists: {trash_dir}")
        _ensure_directory(trash_dir)

        moved: List[Tuple[Path, Path]] = []
        try:
            # Apply 只搬到可恢復 trash，不直接永久刪除。任何中途失敗都逆序搬回，
            # 保持 cleanup 對 job store 的 all-or-nothing observable semantics。
            for relative_path, source in sources:
                destination = trash_dir / PurePosixPath(relative_path)
                _ensure_directory(destination.parent)
                os.replace(source, destination)
                moved.append((source, destination))
            trash_body = {
                "schema_version": 1,
                "cleanup_id": cleanup_id,
                "manifest_sha256": payload["manifest_sha256"],
                "applied_at": _format_time(_utc_now()),
                "moved_paths": [
                    destination.relative_to(trash_dir).as_posix()
                    for _, destination in moved
                ],
            }
            trash_metadata = dict(trash_body)
            trash_metadata["trash_manifest_sha256"] = _hash_json(trash_body)
            _atomic_write_json(trash_dir / "trash-manifest.json", trash_metadata)
        except Exception:
            for source, destination in reversed(moved):
                if destination.exists() and not source.exists():
                    _ensure_directory(source.parent)
                    os.replace(destination, source)
            shutil.rmtree(trash_dir, ignore_errors=True)
            raise
        return trash_dir


def restore_cleanup(root: Path, cleanup_id: str) -> None:
    store_root = _validate_store_root(root)
    _assert_no_active_jobs(store_root)
    with _cleanup_operation(store_root):
        _assert_no_active_jobs(store_root)
        trash_dir = store_root / "trash" / cleanup_id
        metadata_path = trash_dir / "trash-manifest.json"
        if not metadata_path.is_file():
            raise FileNotFoundError(f"trash manifest not found: {cleanup_id}")
        metadata = _load_trash_manifest(metadata_path, cleanup_id)
        moved_paths = metadata.get("moved_paths")
        if not isinstance(moved_paths, list):
            raise ValueError("trash manifest moved_paths is invalid")

        restored: List[Tuple[Path, Path]] = []
        try:
            # Restore 同樣採補償式 move；遇到 destination drift 時撤回本次已還原
            # 的項目，避免同一 cleanup 被恢復成半套狀態。
            for relative_path in reversed(moved_paths):
                _validate_relative_path(relative_path)
                source = _resolve_safe_existing_path(trash_dir, relative_path)
                destination = store_root / PurePosixPath(relative_path)
                if destination.exists():
                    raise FileExistsError(
                        f"restore destination already exists: {destination}"
                    )
                _ensure_directory(destination.parent)
                os.replace(source, destination)
                restored.append((source, destination))
        except Exception:
            for source, destination in reversed(restored):
                if destination.exists() and not source.exists():
                    _ensure_directory(source.parent)
                    os.replace(destination, source)
            raise
        shutil.rmtree(trash_dir)


def purge_trash(root: Path, cleanup_id: str, now: datetime) -> None:
    store_root = _validate_store_root(root)
    current_time = _require_aware_utc(now)
    _assert_no_active_jobs(store_root)
    with _cleanup_operation(store_root):
        _assert_no_active_jobs(store_root)
        trash_dir = store_root / "trash" / cleanup_id
        metadata_path = trash_dir / "trash-manifest.json"
        if not metadata_path.is_file():
            raise FileNotFoundError(f"trash manifest not found: {cleanup_id}")
        metadata = _load_trash_manifest(metadata_path, cleanup_id)
        applied_at = _parse_time(_required_string(metadata, "applied_at"))
        if current_time < applied_at + timedelta(hours=TRASH_RETENTION_HOURS):
            raise ValueError("trash cannot be purged before 24 hours")
        # 只有 retention window 結束後才不可逆刪除；apply/restore 階段都保持可回復。
        shutil.rmtree(trash_dir)


def pin_job(
    root: Path,
    job_path: str,
    owner: str,
    reason: str,
    expires_at: datetime,
    now: Optional[datetime] = None,
) -> str:
    store_root = _validate_store_root(root)
    current_time = _require_aware_utc(now or datetime.now(timezone.utc))
    expiry = _require_aware_utc(expires_at)
    _validate_relative_path(job_path)
    if not owner.strip():
        raise ValueError("pin owner is required")
    if not reason.strip():
        raise ValueError("pin reason is required")
    if expiry <= current_time:
        raise ValueError("pin expires_at must be in the future")
    if expiry > current_time + timedelta(days=MAX_PIN_DAYS):
        raise ValueError("pin cannot exceed 90 days")
    job_dir = _resolve_safe_existing_path(store_root, job_path)
    if not (job_dir / "manifest.json").is_file():
        raise ValueError("pin job_path must identify a finalized job")

    with _cleanup_operation(store_root):
        pin_id = hashlib.sha256(job_path.encode("utf-8")).hexdigest()[:24]
        pin_dir = store_root / "pins"
        _ensure_directory(pin_dir)
        payload = {
            "schema_version": 1,
            "pin_id": pin_id,
            "job_path": job_path,
            "owner": owner.strip(),
            "reason": reason.strip(),
            "created_at": _format_time(current_time),
            "expires_at": _format_time(expiry),
        }
        _atomic_write_json(pin_dir / f"{pin_id}.json", payload)
        return pin_id


def unpin_job(root: Path, job_path: str) -> None:
    store_root = _validate_store_root(root)
    _validate_relative_path(job_path)
    with _cleanup_operation(store_root):
        pin_id = hashlib.sha256(job_path.encode("utf-8")).hexdigest()[:24]
        pin_path = store_root / "pins" / f"{pin_id}.json"
        pin_path.unlink(missing_ok=True)


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.command == "evaluate":
        plan = evaluate_cleanup(
            Path(args.root),
            _parse_time(args.now) if args.now else datetime.now(timezone.utc),
            max_bytes=args.max_bytes,
            min_free_bytes=args.min_free_bytes,
        )
        manifest_id = write_cleanup_manifest(Path(args.root), plan)
        _print_json(
            {
                "manifest_id": manifest_id,
                "candidate_count": len(plan.candidates),
                "candidate_bytes": plan.candidate_bytes,
                "blocking_bytes": plan.blocking_bytes,
                "can_satisfy_capacity": plan.can_satisfy_capacity,
                "dry_run": True,
            }
        )
        return 0
    if args.command == "apply":
        trash_dir = apply_cleanup(Path(args.root), args.manifest_id)
        _print_json({"cleanup_id": args.manifest_id, "trash_dir": str(trash_dir)})
        return 0
    if args.command == "restore":
        restore_cleanup(Path(args.root), args.cleanup_id)
        _print_json({"cleanup_id": args.cleanup_id, "restored": True})
        return 0
    if args.command == "purge":
        purge_trash(
            Path(args.root),
            args.cleanup_id,
            _parse_time(args.now) if args.now else datetime.now(timezone.utc),
        )
        _print_json({"cleanup_id": args.cleanup_id, "purged": True})
        return 0
    if args.command == "pin":
        pin_id = pin_job(
            Path(args.root),
            args.job_path,
            args.owner,
            args.reason,
            _parse_time(args.expires_at),
            now=_parse_time(args.now) if args.now else None,
        )
        _print_json({"pin_id": pin_id})
        return 0
    if args.command == "unpin":
        unpin_job(Path(args.root), args.job_path)
        _print_json({"job_path": args.job_path, "unpinned": True})
        return 0
    parser.error(f"unsupported command: {args.command}")
    return 2


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Managed artifact retention and cleanup")
    subparsers = parser.add_subparsers(dest="command", required=True)

    evaluate = subparsers.add_parser("evaluate")
    evaluate.add_argument("--root", required=True)
    evaluate.add_argument("--now")
    evaluate.add_argument("--max-bytes", type=int, default=DEFAULT_MAX_BYTES)
    evaluate.add_argument("--min-free-bytes", type=int, default=DEFAULT_MIN_FREE_BYTES)
    evaluate.add_argument("--dry-run", action="store_true")

    apply_parser = subparsers.add_parser("apply")
    apply_parser.add_argument("--root", required=True)
    apply_parser.add_argument("--manifest-id", required=True)

    restore = subparsers.add_parser("restore")
    restore.add_argument("--root", required=True)
    restore.add_argument("--cleanup-id", required=True)

    purge = subparsers.add_parser("purge")
    purge.add_argument("--root", required=True)
    purge.add_argument("--cleanup-id", required=True)
    purge.add_argument("--now")

    pin = subparsers.add_parser("pin")
    pin.add_argument("--root", required=True)
    pin.add_argument("--job-path", required=True)
    pin.add_argument("--owner", required=True)
    pin.add_argument("--reason", required=True)
    pin.add_argument("--expires-at", required=True)
    pin.add_argument("--now")

    unpin = subparsers.add_parser("unpin")
    unpin.add_argument("--root", required=True)
    unpin.add_argument("--job-path", required=True)
    return parser


def _scan_job_records(root: Path, now: datetime) -> List[_JobRecord]:
    pins = _load_active_pins(root, now)
    records: List[_JobRecord] = []
    runs_dir = root / "runs"
    if not runs_dir.exists():
        return records
    for manifest_path in sorted(runs_dir.glob("*/*/jobs/*/manifest.json")):
        manifest = _read_json(manifest_path)
        validate_job_manifest(manifest)
        retention_class = manifest["cleanup_disposition"]["retention_class"]
        if retention_class == "pinned":
            retention_class = manifest["artifacts"][0]["retention_class"] if manifest["artifacts"] else "verification-success"
        raw_paths = tuple(
            path.relative_to(root).as_posix()
            for path in (manifest_path.parent / "artifacts", manifest_path.parent / "diagnostics")
            if path.exists()
        )
        raw_bytes = sum(_directory_bytes(root / PurePosixPath(path)) for path in raw_paths)
        platform = "unknown"
        if manifest["artifacts"]:
            platform = manifest["artifacts"][0].get("platform") or "unknown"
        job_path = manifest_path.parent.relative_to(root).as_posix()
        records.append(
            _JobRecord(
                job_path=job_path,
                manifest_path=manifest_path,
                manifest_sha256=_sha256_file(manifest_path),
                retention_class=retention_class,
                completed_at=_parse_time(manifest["completed_at"]),
                suite=manifest["suite"],
                git_ref=manifest["git_ref"],
                platform=platform,
                commit_sha=manifest["commit_sha"],
                raw_paths=raw_paths,
                raw_bytes=raw_bytes,
                pinned=job_path in pins,
            )
        )
    return records


def _mark_age_candidates(
    records: Iterable[_JobRecord],
    now: datetime,
    reasons_by_job: Dict[str, set],
) -> None:
    for record in records:
        policy = RETENTION_CLASSES.get(record.retention_class)
        if policy is None or record.retention_class == "pinned":
            continue
        if record.completed_at + timedelta(days=policy["max_age_days"]) <= now:
            reasons_by_job[record.job_path].add("age")


def _mark_count_candidates(
    records: Sequence[_JobRecord],
    reasons_by_job: Dict[str, set],
) -> None:
    grouped: Dict[Tuple[str, ...], List[_JobRecord]] = {}
    for record in records:
        if record.retention_class == "verification-success":
            key = (record.retention_class, record.suite, record.git_ref)
        elif record.retention_class == "verification-failure":
            key = (record.retention_class,)
        elif record.retention_class == "observability-raw":
            key = (record.retention_class, record.platform)
        elif record.retention_class == "release-verification":
            key = (record.retention_class,)
        else:
            continue
        grouped.setdefault(key, []).append(record)

    for key, group in grouped.items():
        retention_class = key[0]
        max_count = RETENTION_CLASSES[retention_class]["max_count"]
        if max_count is None:
            continue
        ordered = sorted(group, key=lambda record: record.completed_at, reverse=True)
        if retention_class == "release-verification":
            kept_shas = set()
            for record in ordered:
                if record.commit_sha in kept_shas:
                    continue
                if len(kept_shas) < max_count:
                    kept_shas.add(record.commit_sha)
                else:
                    reasons_by_job[record.job_path].add("count")
        else:
            for record in ordered[max_count:]:
                reasons_by_job[record.job_path].add("count")


def _sort_records_for_cleanup(records: Iterable[_JobRecord]) -> List[_JobRecord]:
    return sorted(
        records,
        key=lambda record: (
            _PRIORITY.get(record.retention_class, 99),
            record.completed_at,
            record.job_path,
        ),
    )


def _load_active_pins(root: Path, now: datetime) -> Dict[str, Dict[str, Any]]:
    active: Dict[str, Dict[str, Any]] = {}
    pin_dir = root / "pins"
    if not pin_dir.exists():
        return active
    for pin_path in sorted(pin_dir.glob("*.json")):
        payload = _read_json(pin_path)
        if payload.get("schema_version") != 1:
            raise ValueError(f"pin schema_version is invalid: {pin_path.name}")
        job_path = _required_string(payload, "job_path")
        _validate_relative_path(job_path)
        expected_pin_id = hashlib.sha256(job_path.encode("utf-8")).hexdigest()[:24]
        if payload.get("pin_id") != expected_pin_id or pin_path.stem != expected_pin_id:
            raise ValueError(f"pin identity mismatch: {pin_path.name}")
        _required_string(payload, "owner")
        _required_string(payload, "reason")
        created_at = _parse_time(_required_string(payload, "created_at"))
        expires_at = _parse_time(_required_string(payload, "expires_at"))
        if expires_at <= created_at:
            raise ValueError("pin expires_at must be after created_at")
        if expires_at > created_at + timedelta(days=MAX_PIN_DAYS):
            raise ValueError("pin cannot exceed 90 days")
        if expires_at > now:
            active[job_path] = payload
    return active


def _compute_store_generation(root: Path) -> str:
    digest = hashlib.sha256()
    paths = (
        [path for path in (root / "runs").rglob("*") if path.is_file() or path.is_symlink()]
        if (root / "runs").exists()
        else []
    )
    paths.extend((root / "pins").glob("*.json") if (root / "pins").exists() else [])
    for path in sorted(paths):
        digest.update(path.relative_to(root).as_posix().encode("utf-8"))
        digest.update(b"\0")
        if path.is_symlink():
            digest.update(b"symlink:")
            digest.update(os.readlink(path).encode("utf-8"))
        else:
            digest.update(_sha256_file(path).encode("ascii"))
        digest.update(b"\n")
    return digest.hexdigest()


def _load_cleanup_manifest(root: Path, manifest_id: str) -> Dict[str, Any]:
    if not manifest_id or any(character not in "0123456789abcdef" for character in manifest_id):
        raise ValueError("cleanup manifest_id is invalid")
    path = root / "cleanup-manifests" / f"{manifest_id}.json"
    payload = _read_json(path)
    if payload.get("manifest_id") != manifest_id:
        raise ValueError("cleanup manifest ID mismatch")
    recorded_hash = payload.get("manifest_sha256")
    if not isinstance(recorded_hash, str):
        raise ValueError("cleanup manifest hash is missing")
    body = dict(payload)
    body.pop("manifest_sha256", None)
    if _hash_json(body) != recorded_hash:
        raise ValueError("cleanup manifest integrity failure")
    candidates = payload.get("candidates")
    if not isinstance(candidates, list):
        raise ValueError("cleanup manifest candidates are invalid")
    for candidate in candidates:
        if not isinstance(candidate, Mapping):
            raise ValueError("cleanup manifest candidate is invalid")
        job_path = _required_string(candidate, "job_path")
        _validate_relative_path(job_path)
        paths = candidate.get("paths")
        if not isinstance(paths, list):
            raise ValueError("cleanup manifest paths are invalid")
        for relative_path in paths:
            if not isinstance(relative_path, str):
                raise ValueError("cleanup manifest path must be a string")
            _validate_relative_path(relative_path)
            if not _is_descendant_relative(relative_path, job_path):
                raise ValueError("cleanup manifest path escapes job")
    return payload


def _load_trash_manifest(path: Path, cleanup_id: str) -> Dict[str, Any]:
    payload = _read_json(path)
    if not isinstance(payload, Mapping):
        raise ValueError("trash manifest must be a mapping")
    if payload.get("schema_version") != 1:
        raise ValueError("trash manifest schema_version is invalid")
    if payload.get("cleanup_id") != cleanup_id:
        raise ValueError("trash manifest cleanup_id mismatch")
    recorded_hash = payload.get("trash_manifest_sha256")
    if not isinstance(recorded_hash, str):
        raise ValueError("trash manifest integrity hash is missing")
    body = dict(payload)
    body.pop("trash_manifest_sha256", None)
    if _hash_json(body) != recorded_hash:
        raise ValueError("trash manifest integrity failure")
    moved_paths = payload.get("moved_paths")
    if not isinstance(moved_paths, list):
        raise ValueError("trash manifest moved_paths is invalid")
    for relative_path in moved_paths:
        if not isinstance(relative_path, str):
            raise ValueError("trash manifest path must be a string")
        _validate_relative_path(relative_path)
    _required_string(payload, "manifest_sha256")
    _parse_time(_required_string(payload, "applied_at"))
    return dict(payload)


def _assert_manifest_root(payload: Mapping[str, Any], root: Path) -> None:
    recorded_root = Path(_required_string(payload, "root")).resolve(strict=False)
    if recorded_root != root:
        raise ValueError("cleanup manifest root mismatch")


def _assert_no_active_jobs(root: Path) -> None:
    locks = root / "locks"
    if locks.exists() and any(
        path.is_file() and path.name != "cleanup-operation.lock"
        for path in locks.rglob("*.lock")
    ):
        raise RuntimeError("active lock prevents cleanup")
    in_progress = root / ".in-progress"
    if in_progress.exists() and any(in_progress.rglob("*")):
        raise RuntimeError("in-progress job prevents cleanup")


def _preflight_cleanup_paths(
    root: Path,
    payload: Mapping[str, Any],
) -> List[Tuple[str, Path]]:
    sources: List[Tuple[str, Path]] = []
    for candidate in payload["candidates"]:
        for relative_path in candidate["paths"]:
            source = _resolve_safe_existing_path(root, relative_path)
            if not source.exists():
                raise FileNotFoundError(f"cleanup source is missing: {relative_path}")
            sources.append((relative_path, source))
    return sources


@contextmanager
def _cleanup_operation(root: Path):
    lock_path = root / "locks" / "cleanup-operation.lock"
    _ensure_directory(lock_path.parent)
    try:
        descriptor = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as error:
        raise RuntimeError("cleanup operation is already active") from error
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(f"pid={os.getpid()}\n")
            handle.write(f"created_at={_format_time(_utc_now())}\n")
        yield
    finally:
        lock_path.unlink(missing_ok=True)


def _resolve_safe_existing_path(root: Path, relative_path: str) -> Path:
    _validate_relative_path(relative_path)
    candidate = root / PurePosixPath(relative_path)
    current = root
    for part in PurePosixPath(relative_path).parts:
        current = current / part
        if current.is_symlink():
            raise ValueError("cleanup path contains symlink")
    resolved = candidate.resolve(strict=False)
    if root != resolved and root not in resolved.parents:
        raise ValueError("cleanup path escapes root")
    return candidate


def _validate_relative_path(relative_path: str) -> None:
    if not isinstance(relative_path, str) or not relative_path:
        raise ValueError("cleanup path must be a non-empty string")
    if "\\" in relative_path:
        raise ValueError("cleanup path must use forward slashes")
    path = PurePosixPath(relative_path)
    if path.is_absolute() or ".." in path.parts or relative_path in {".", ".."}:
        raise ValueError("cleanup path contains traversal")
    if len(path.parts) > 0 and ":" in path.parts[0]:
        raise ValueError("cleanup path contains drive prefix")


def _is_descendant_relative(candidate: str, parent: str) -> bool:
    candidate_path = PurePosixPath(candidate)
    parent_path = PurePosixPath(parent)
    return candidate_path == parent_path or parent_path in candidate_path.parents


def _validate_store_root(root: Path) -> Path:
    candidate = Path(root)
    if not candidate.is_absolute():
        raise ValueError("artifact store root must be absolute")
    for part_index in range(1, len(candidate.parts) + 1):
        component = Path(*candidate.parts[:part_index])
        if component.is_symlink():
            raise ValueError("artifact store root cannot contain symlink")
    resolved = candidate.resolve(strict=False)
    if resolved == Path(resolved.anchor).resolve(strict=False):
        raise ValueError("artifact store root cannot be filesystem root")
    if resolved == Path.home().resolve(strict=False):
        raise ValueError("artifact store root cannot be home root")
    if not resolved.is_dir():
        raise ValueError("artifact store root must exist and be a directory")
    return resolved


def _directory_bytes(path: Path) -> int:
    total = 0
    for child in path.rglob("*"):
        if child.is_symlink():
            continue
        if child.is_file():
            total += child.stat().st_size
    return total


def _hash_json(payload: Mapping[str, Any]) -> str:
    encoded = json.dumps(
        payload,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def _read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _atomic_write_json(path: Path, payload: Mapping[str, Any]) -> None:
    _ensure_directory(path.parent)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=str(path.parent)
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        try:
            temporary_path.chmod(0o600)
        except OSError:
            pass
        os.replace(temporary_path, path)
    finally:
        temporary_path.unlink(missing_ok=True)


def _ensure_directory(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)
    try:
        path.chmod(0o700)
    except OSError:
        pass


def _required_string(payload: Mapping[str, Any], field: str) -> str:
    value = payload.get(field)
    if not isinstance(value, str) or not value:
        raise ValueError(f"{field} must be a non-empty string")
    return value


def _parse_time(value: str) -> datetime:
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    parsed = datetime.fromisoformat(value)
    return _require_aware_utc(parsed)


def _require_aware_utc(value: datetime) -> datetime:
    if value.tzinfo is None or value.utcoffset() is None:
        raise ValueError("datetime must be timezone-aware")
    return value.astimezone(timezone.utc)


def _format_time(value: datetime) -> str:
    return _require_aware_utc(value).replace(microsecond=0).isoformat().replace(
        "+00:00", "Z"
    )


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _print_json(payload: Mapping[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    sys.exit(main())
