import argparse
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile
from typing import Any, Dict, List, Mapping, Optional, Sequence

from tools.ci.artifact_contract import (
    SCHEMA_VERSION,
    sanitize_key,
    validate_artifact_root,
    validate_job_manifest,
)


_ALLOWED_METADATA_FIELDS = frozenset(
    {
        "repository",
        "git_ref",
        "dirty_state",
        "run_id",
        "run_attempt",
        "workflow",
        "job",
        "execution_mode",
        "host_os",
        "host_arch",
        "runner_name",
        "suite",
        "classifier_reason",
        "started_at",
        "platform",
        "environment",
        "build_mode",
        "artifact_kind",
        "sensitivity",
        "signing",
        "distribution",
    }
)
_REQUIRED_METADATA_FIELDS = frozenset(
    {
        "repository",
        "git_ref",
        "dirty_state",
        "run_id",
        "run_attempt",
        "workflow",
        "job",
        "execution_mode",
        "host_os",
        "host_arch",
        "runner_name",
        "suite",
        "classifier_reason",
        "started_at",
    }
)
_COMMIT_SHA_PATTERN = re.compile(r"^[0-9a-f]{40}$")


@dataclass(frozen=True)
class JobContext:
    root: Path
    repo_root: Path
    commit_sha: str
    run_key: str
    job_key: str
    staging_dir: Path
    published_dir: Path
    lock_path: Path
    metadata: Dict[str, Any]

    @property
    def artifact_dir(self) -> Path:
        return self.staging_dir / "artifacts"

    @property
    def diagnostics_dir(self) -> Path:
        return self.staging_dir / "diagnostics"

    @property
    def context_path(self) -> Path:
        return self.staging_dir / ".job-context.json"

    def to_payload(self) -> Dict[str, Any]:
        return {
            "root": str(self.root),
            "repo_root": str(self.repo_root),
            "commit_sha": self.commit_sha,
            "run_key": self.run_key,
            "job_key": self.job_key,
            "staging_dir": str(self.staging_dir),
            "published_dir": str(self.published_dir),
            "lock_path": str(self.lock_path),
            "metadata": self.metadata,
        }

    @classmethod
    def from_file(cls, path: Path) -> "JobContext":
        payload = _read_json(path)
        if not isinstance(payload, Mapping):
            raise ValueError("context payload must be a mapping")
        context = cls(
            root=Path(_required_payload_string(payload, "root")),
            repo_root=Path(_required_payload_string(payload, "repo_root")),
            commit_sha=_required_payload_string(payload, "commit_sha"),
            run_key=_required_payload_string(payload, "run_key"),
            job_key=_required_payload_string(payload, "job_key"),
            staging_dir=Path(_required_payload_string(payload, "staging_dir")),
            published_dir=Path(_required_payload_string(payload, "published_dir")),
            lock_path=Path(_required_payload_string(payload, "lock_path")),
            metadata=dict(_required_payload_mapping(payload, "metadata")),
        )
        _validate_context_integrity(context, source_path=Path(path))
        return context


def begin_job(
    root: Path,
    repo_root: Path,
    commit_sha: str,
    run_key: str,
    job_key: str,
    metadata: Mapping[str, Any],
) -> JobContext:
    validated_metadata = _validate_begin_metadata(metadata)
    validated_run_key = _require_sanitized_key(run_key, "run_key")
    validated_job_key = _require_sanitized_key(job_key, "job_key")

    runner_workspace = os.environ.get("RUNNER_WORKSPACE")
    runner_work = (
        Path(runner_workspace).resolve(strict=False).parent
        if runner_workspace
        else None
    )
    runner_temp_value = os.environ.get("RUNNER_TEMP")
    runner_temp = Path(runner_temp_value) if runner_temp_value else None
    home = Path.home()
    validated_root = validate_artifact_root(
        Path(root),
        Path(repo_root),
        runner_work=runner_work,
        runner_temp=runner_temp,
        home=home,
    )

    context = JobContext(
        root=validated_root,
        repo_root=Path(repo_root).resolve(strict=False),
        commit_sha=commit_sha,
        run_key=validated_run_key,
        job_key=validated_job_key,
        staging_dir=(
            validated_root / ".in-progress" / validated_run_key / validated_job_key
        ),
        published_dir=(
            validated_root
            / "runs"
            / commit_sha
            / validated_run_key
            / "jobs"
            / validated_job_key
        ),
        lock_path=(
            validated_root
            / "locks"
            / commit_sha
            / validated_run_key
            / f"{validated_job_key}.lock"
        ),
        metadata=validated_metadata,
    )

    preview_manifest = _build_job_manifest(
        context,
        result="success",
        evidence_status="complete",
        artifact_entries=[],
        validation_entries=[],
        cleanup_disposition={
            "status": "retained",
            "retention_class": "verification-success",
            "eligible_at": _utc_now(),
            "reason": "preview-validation",
        },
    )
    validate_job_manifest(preview_manifest)

    if context.published_dir.exists():
        raise FileExistsError(f"published job already exists: {context.published_dir}")
    if context.lock_path.exists():
        raise FileExistsError(f"active lock already exists: {context.lock_path}")
    if context.staging_dir.exists():
        raise FileExistsError(f"staging job already exists: {context.staging_dir}")

    _ensure_directory(context.root)
    _ensure_directory(context.lock_path.parent)
    _create_lock(context.lock_path, context)
    try:
        _ensure_directory(context.artifact_dir)
        _ensure_directory(context.diagnostics_dir)
        _atomic_write_json(context.context_path, context.to_payload())
    except Exception:
        context.lock_path.unlink(missing_ok=True)
        raise
    return context


def finalize_job(
    context: JobContext,
    result: str,
    validation_entries: Sequence[Mapping[str, Any]],
    cleanup_disposition: Mapping[str, Any],
) -> Path:
    _validate_context_integrity(context)
    if result not in {"success", "failure", "cancelled", "skipped"}:
        raise ValueError(f"Unsupported primary result: {result!r}")
    if not context.staging_dir.is_dir():
        raise FileNotFoundError(f"staging job does not exist: {context.staging_dir}")
    if not context.lock_path.is_file():
        raise FileNotFoundError(f"active lock does not exist: {context.lock_path}")
    if context.published_dir.exists():
        raise FileExistsError(f"published job already exists: {context.published_dir}")

    cleanup_payload = dict(cleanup_disposition)
    retention_class = cleanup_payload.get("retention_class")
    if not isinstance(retention_class, str) or not retention_class:
        raise ValueError("cleanup_disposition must include retention_class")

    artifacts = _collect_artifact_entries(context, retention_class)
    validations = [dict(entry) for entry in validation_entries]
    evidence_status = "complete"
    manifest = _build_job_manifest(
        context,
        result=result,
        evidence_status=evidence_status,
        artifact_entries=artifacts,
        validation_entries=validations,
        cleanup_disposition=cleanup_payload,
    )
    validate_job_manifest(manifest)

    try:
        summary = _render_job_summary(manifest)
    except Exception:
        evidence_status = "degraded"
        manifest = _build_job_manifest(
            context,
            result=result,
            evidence_status=evidence_status,
            artifact_entries=artifacts,
            validation_entries=validations,
            cleanup_disposition=cleanup_payload,
        )
        validate_job_manifest(manifest)
        summary = _fallback_job_summary(result, evidence_status)

    _atomic_write_json(context.staging_dir / "manifest.json", manifest)
    _atomic_write_text(context.staging_dir / "summary.md", summary)
    context.context_path.unlink(missing_ok=True)
    _write_checksums(context.staging_dir)

    _ensure_directory(context.published_dir.parent)
    os.replace(context.staging_dir, context.published_dir)
    context.lock_path.unlink(missing_ok=True)
    return context.published_dir


def aggregate_run(root: Path, commit_sha: str, run_key: str) -> Path:
    _validate_commit_sha(commit_sha)
    validated_run_key = _require_sanitized_key(run_key, "run_key")
    resolved_root = Path(root).resolve(strict=False)
    active_lock_dir = resolved_root / "locks" / commit_sha / validated_run_key
    active_staging_dir = resolved_root / ".in-progress" / validated_run_key
    if active_lock_dir.exists() and any(active_lock_dir.glob("*.lock")):
        raise RuntimeError(f"active job prevents run aggregation: {active_lock_dir}")
    if active_staging_dir.exists() and any(active_staging_dir.iterdir()):
        raise RuntimeError(f"active job staging prevents run aggregation: {active_staging_dir}")

    run_dir = resolved_root / "runs" / commit_sha / validated_run_key
    jobs_dir = run_dir / "jobs"
    manifest_paths = sorted(jobs_dir.glob("*/manifest.json"))
    if not manifest_paths:
        raise FileNotFoundError(f"no finalized jobs found for run: {run_dir}")

    jobs: List[Dict[str, Any]] = []
    total_artifacts = 0
    total_bytes = 0
    for manifest_path in manifest_paths:
        manifest = _read_json(manifest_path)
        validate_job_manifest(manifest)
        if manifest["commit_sha"] != commit_sha:
            raise ValueError(f"job commit mismatch: {manifest_path}")
        if manifest["run_key"] != validated_run_key:
            raise ValueError(f"job run mismatch: {manifest_path}")

        artifact_count = len(manifest["artifacts"])
        artifact_bytes = sum(entry["size_bytes"] for entry in manifest["artifacts"])
        total_artifacts += artifact_count
        total_bytes += artifact_bytes
        jobs.append(
            {
                "job_key": manifest["job_key"],
                "manifest_path": manifest_path.relative_to(run_dir).as_posix(),
                "manifest_sha256": _sha256_file(manifest_path),
                "result": manifest["result"],
                "evidence_status": manifest["evidence_status"],
                "artifact_count": artifact_count,
                "total_bytes": artifact_bytes,
            }
        )

    jobs.sort(key=lambda entry: entry["job_key"])
    run_manifest = {
        "schema_version": SCHEMA_VERSION,
        "commit_sha": commit_sha,
        "run_key": validated_run_key,
        "aggregated_at": _utc_now(),
        "result": _aggregate_primary_result([entry["result"] for entry in jobs]),
        "evidence_status": (
            "degraded"
            if any(entry["evidence_status"] != "complete" for entry in jobs)
            else "complete"
        ),
        "job_count": len(jobs),
        "artifact_count": total_artifacts,
        "total_bytes": total_bytes,
        "jobs": jobs,
    }
    run_manifest_path = run_dir / "run-manifest.json"
    _atomic_write_json(run_manifest_path, run_manifest)
    _atomic_write_text(run_dir / "run-summary.md", _render_run_summary(run_manifest))
    return run_manifest_path


def write_github_summary(manifest_path: Path, output_path: Path) -> Path:
    manifest = _read_json(manifest_path)
    validate_job_manifest(manifest)
    summary = _render_job_summary(manifest)
    output = Path(output_path)
    _ensure_directory(output.parent, owner_only=False)
    with output.open("a", encoding="utf-8", newline="\n") as handle:
        handle.write(summary)
        if not summary.endswith("\n"):
            handle.write("\n")
    return output


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    if args.command == "begin-job":
        context = begin_job(
            Path(args.root),
            Path(args.repo_root),
            args.commit_sha,
            args.run_key,
            args.job_key,
            _read_json(Path(args.metadata_json)),
        )
        _print_json(
            {
                "context_path": str(context.context_path),
                "staging_dir": str(context.staging_dir),
                "artifact_dir": str(context.artifact_dir),
                "diagnostics_dir": str(context.diagnostics_dir),
                "published_dir": str(context.published_dir),
            }
        )
        return 0

    if args.command == "finalize-job":
        context = JobContext.from_file(Path(args.context_json))
        published = finalize_job(
            context,
            args.result,
            _read_json(Path(args.validations_json)),
            _read_json(Path(args.cleanup_json)),
        )
        _print_json({"published_dir": str(published)})
        return 0

    if args.command == "aggregate-run":
        run_manifest = aggregate_run(
            Path(args.root),
            args.commit_sha,
            args.run_key,
        )
        _print_json({"run_manifest_path": str(run_manifest)})
        return 0

    if args.command == "write-summary":
        output = write_github_summary(Path(args.manifest), Path(args.output))
        _print_json({"summary_path": str(output)})
        return 0

    parser.error(f"unsupported command: {args.command}")
    return 2


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Managed CI artifact store")
    subparsers = parser.add_subparsers(dest="command", required=True)

    begin = subparsers.add_parser("begin-job")
    begin.add_argument("--root", required=True)
    begin.add_argument("--repo-root", required=True)
    begin.add_argument("--commit-sha", required=True)
    begin.add_argument("--run-key", required=True)
    begin.add_argument("--job-key", required=True)
    begin.add_argument("--metadata-json", required=True)

    finalize = subparsers.add_parser("finalize-job")
    finalize.add_argument("--context-json", required=True)
    finalize.add_argument(
        "--result",
        required=True,
        choices=("success", "failure", "cancelled", "skipped"),
    )
    finalize.add_argument("--validations-json", required=True)
    finalize.add_argument("--cleanup-json", required=True)

    aggregate = subparsers.add_parser("aggregate-run")
    aggregate.add_argument("--root", required=True)
    aggregate.add_argument("--commit-sha", required=True)
    aggregate.add_argument("--run-key", required=True)

    summary = subparsers.add_parser("write-summary")
    summary.add_argument("--manifest", required=True)
    summary.add_argument(
        "--output",
        default=os.environ.get("GITHUB_STEP_SUMMARY"),
        required=os.environ.get("GITHUB_STEP_SUMMARY") is None,
    )
    return parser


def _validate_begin_metadata(metadata: Mapping[str, Any]) -> Dict[str, Any]:
    if not isinstance(metadata, Mapping):
        raise ValueError("metadata must be a mapping")
    unknown = sorted(set(metadata) - _ALLOWED_METADATA_FIELDS)
    if unknown:
        raise ValueError(f"unknown metadata field: {unknown[0]}")
    missing = sorted(_REQUIRED_METADATA_FIELDS - set(metadata))
    if missing:
        raise ValueError(f"missing metadata field: {missing[0]}")
    for field in (
        "platform",
        "environment",
        "build_mode",
        "artifact_kind",
        "sensitivity",
        "signing",
        "distribution",
    ):
        if field in metadata:
            value = metadata[field]
            if not isinstance(value, str) or not value:
                raise ValueError(f"metadata {field} must be a non-empty string")
    return dict(metadata)


def _validate_context_integrity(
    context: JobContext,
    source_path: Optional[Path] = None,
) -> None:
    _validate_commit_sha(context.commit_sha)
    run_key = _require_sanitized_key(context.run_key, "run_key")
    job_key = _require_sanitized_key(context.job_key, "job_key")
    metadata = _validate_begin_metadata(context.metadata)

    runner_workspace = os.environ.get("RUNNER_WORKSPACE")
    runner_work = (
        Path(runner_workspace).resolve(strict=False).parent
        if runner_workspace
        else None
    )
    runner_temp_value = os.environ.get("RUNNER_TEMP")
    runner_temp = Path(runner_temp_value) if runner_temp_value else None
    validated_root = validate_artifact_root(
        context.root,
        context.repo_root,
        runner_work=runner_work,
        runner_temp=runner_temp,
        home=Path.home(),
    )

    expected_staging = validated_root / ".in-progress" / run_key / job_key
    expected_published = (
        validated_root
        / "runs"
        / context.commit_sha
        / run_key
        / "jobs"
        / job_key
    )
    expected_lock = (
        validated_root
        / "locks"
        / context.commit_sha
        / run_key
        / f"{job_key}.lock"
    )
    comparisons = (
        (context.staging_dir, expected_staging, "staging_dir"),
        (context.published_dir, expected_published, "published_dir"),
        (context.lock_path, expected_lock, "lock_path"),
    )
    for actual, expected, label in comparisons:
        if actual.resolve(strict=False) != expected.resolve(strict=False):
            raise ValueError(f"context integrity failure for {label}")

    if source_path is not None:
        expected_source = expected_staging / ".job-context.json"
        if source_path.resolve(strict=False) != expected_source.resolve(strict=False):
            raise ValueError("context integrity failure for context_path")

    preview_context = JobContext(
        root=validated_root,
        repo_root=context.repo_root.resolve(strict=False),
        commit_sha=context.commit_sha,
        run_key=run_key,
        job_key=job_key,
        staging_dir=expected_staging,
        published_dir=expected_published,
        lock_path=expected_lock,
        metadata=metadata,
    )
    preview_manifest = _build_job_manifest(
        preview_context,
        result="success",
        evidence_status="complete",
        artifact_entries=[],
        validation_entries=[],
        cleanup_disposition={
            "status": "retained",
            "retention_class": "verification-success",
            "eligible_at": _utc_now(),
            "reason": "context-integrity-validation",
        },
    )
    validate_job_manifest(preview_manifest)


def _validate_commit_sha(commit_sha: str) -> None:
    if not isinstance(commit_sha, str) or not _COMMIT_SHA_PATTERN.fullmatch(commit_sha):
        raise ValueError("commit_sha must be a lowercase 40-character SHA")


def _build_job_manifest(
    context: JobContext,
    result: str,
    evidence_status: str,
    artifact_entries: Sequence[Mapping[str, Any]],
    validation_entries: Sequence[Mapping[str, Any]],
    cleanup_disposition: Mapping[str, Any],
) -> Dict[str, Any]:
    metadata = context.metadata
    return {
        "schema_version": SCHEMA_VERSION,
        "repository": metadata["repository"],
        "commit_sha": context.commit_sha,
        "git_ref": metadata["git_ref"],
        "dirty_state": metadata["dirty_state"],
        "run_key": context.run_key,
        "run_id": metadata["run_id"],
        "run_attempt": metadata["run_attempt"],
        "job_key": context.job_key,
        "workflow": metadata["workflow"],
        "job": metadata["job"],
        "execution_mode": metadata["execution_mode"],
        "host_os": metadata["host_os"],
        "host_arch": metadata["host_arch"],
        "runner_name": metadata["runner_name"],
        "suite": metadata["suite"],
        "classifier_reason": metadata["classifier_reason"],
        "started_at": metadata["started_at"],
        "completed_at": _utc_now(),
        "result": result,
        "evidence_status": evidence_status,
        "artifacts": [dict(entry) for entry in artifact_entries],
        "validations": [dict(entry) for entry in validation_entries],
        "cleanup_disposition": dict(cleanup_disposition),
    }


def _collect_artifact_entries(
    context: JobContext,
    retention_class: str,
) -> List[Dict[str, Any]]:
    entries: List[Dict[str, Any]] = []
    for directory, default_kind in (
        (context.artifact_dir, context.metadata.get("artifact_kind", "verification-artifact")),
        (context.diagnostics_dir, "diagnostic"),
    ):
        for path in sorted(directory.rglob("*")):
            if path.is_symlink():
                raise ValueError(f"artifact entries cannot be symlinks: {path}")
            if not path.is_file():
                continue
            entry: Dict[str, Any] = {
                "relative_path": path.relative_to(context.staging_dir).as_posix(),
                "kind": str(default_kind),
                "size_bytes": path.stat().st_size,
                "sha256": _sha256_file(path),
                "retention_class": retention_class,
            }
            for field in (
                "platform",
                "environment",
                "build_mode",
                "sensitivity",
                "signing",
                "distribution",
            ):
                value = context.metadata.get(field)
                if value is not None:
                    entry[field] = value
            entries.append(entry)
    return entries


def _render_job_summary(manifest: Mapping[str, Any]) -> str:
    artifact_count = len(manifest["artifacts"])
    total_bytes = sum(entry["size_bytes"] for entry in manifest["artifacts"])
    return (
        "# CI Artifact Evidence\n\n"
        f"- Execution mode: {manifest['execution_mode']}\n"
        f"- Commit: `{manifest['commit_sha']}`\n"
        f"- Run key: `{manifest['run_key']}`\n"
        f"- Job key: `{manifest['job_key']}`\n"
        f"- Primary result: {manifest['result']}\n"
        f"- Evidence status: {manifest['evidence_status']}\n"
        f"- Artifact count: {artifact_count}\n"
        f"- Total bytes: {total_bytes}\n\n"
        "Local-only evidence; not downloadable from GitHub.\n"
    )


def _fallback_job_summary(result: str, evidence_status: str) -> str:
    return (
        "# CI Artifact Evidence\n\n"
        f"- Primary result: {result}\n"
        f"- Evidence status: {evidence_status}\n\n"
        "Local-only evidence; not downloadable from GitHub.\n"
    )


def _render_run_summary(run_manifest: Mapping[str, Any]) -> str:
    lines = [
        "# CI Artifact Run Summary",
        "",
        f"- Commit: `{run_manifest['commit_sha']}`",
        f"- Run key: `{run_manifest['run_key']}`",
        f"- Result: {run_manifest['result']}",
        f"- Evidence status: {run_manifest['evidence_status']}",
        f"- Jobs: {run_manifest['job_count']}",
        f"- Artifacts: {run_manifest['artifact_count']}",
        f"- Total bytes: {run_manifest['total_bytes']}",
        "",
        "Local-only evidence; not downloadable from GitHub.",
        "",
    ]
    return "\n".join(lines)


def _write_checksums(staging_dir: Path) -> None:
    checksum_path = staging_dir / "checksums.sha256"
    paths = [
        path
        for path in staging_dir.rglob("*")
        if path.is_file()
        and path != checksum_path
        and path.name != ".job-context.json"
    ]
    lines = [
        f"{_sha256_file(path)}  {path.relative_to(staging_dir).as_posix()}"
        for path in sorted(paths)
    ]
    _atomic_write_text(checksum_path, "\n".join(lines) + "\n")


def _aggregate_primary_result(results: Sequence[str]) -> str:
    for candidate in ("failure", "cancelled", "success", "skipped"):
        if candidate in results:
            return candidate
    raise ValueError("run has no recognized job result")


def _create_lock(path: Path, context: JobContext) -> None:
    payload = json.dumps(
        {
            "pid": os.getpid(),
            "created_at": _utc_now(),
            "commit_sha": context.commit_sha,
            "run_key": context.run_key,
            "job_key": context.job_key,
        },
        sort_keys=True,
    ).encode("utf-8")
    try:
        descriptor = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError as error:
        raise FileExistsError(f"active lock already exists: {path}") from error
    with os.fdopen(descriptor, "wb") as handle:
        handle.write(payload)


def _ensure_directory(path: Path, owner_only: bool = True) -> None:
    path.mkdir(parents=True, exist_ok=True)
    if owner_only:
        try:
            path.chmod(0o700)
        except OSError:
            pass


def _chmod_file(path: Path) -> None:
    try:
        path.chmod(0o600)
    except OSError:
        pass


def _atomic_write_json(path: Path, payload: Mapping[str, Any]) -> None:
    _atomic_write_text(
        path,
        json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
    )


def _atomic_write_text(path: Path, content: str) -> None:
    _ensure_directory(path.parent)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.",
        suffix=".tmp",
        dir=str(path.parent),
    )
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8", newline="\n") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        _chmod_file(temporary_path)
        os.replace(temporary_path, path)
        _chmod_file(path)
    finally:
        temporary_path.unlink(missing_ok=True)


def _read_json(path: Path) -> Any:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _require_sanitized_key(value: str, label: str) -> str:
    sanitized = sanitize_key(value)
    if sanitized != value:
        raise ValueError(f"{label} must already be sanitized")
    return sanitized


def _required_payload_string(payload: Mapping[str, Any], field: str) -> str:
    value = payload.get(field)
    if not isinstance(value, str) or not value:
        raise ValueError(f"context {field} must be a non-empty string")
    return value


def _required_payload_mapping(
    payload: Mapping[str, Any],
    field: str,
) -> Mapping[str, Any]:
    value = payload.get(field)
    if not isinstance(value, Mapping):
        raise ValueError(f"context {field} must be a mapping")
    return value


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace(
        "+00:00", "Z"
    )


def _print_json(payload: Mapping[str, Any]) -> None:
    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    sys.exit(main())
