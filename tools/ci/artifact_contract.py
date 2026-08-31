from pathlib import Path, PurePosixPath
import re
from typing import Any, Mapping, Optional, Sequence, Tuple


SCHEMA_VERSION = 1

RETENTION_CLASSES = {
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
}

SECRET_FIELD_PATTERNS: Tuple[str, ...] = (
    "token",
    "secret",
    "password",
    "credential",
    "service_account",
    "private_key",
    "environment_variables",
    "process_environment",
    "provider_config",
)

_EXECUTION_MODES = frozenset(
    {
        "manual-local",
        "self-hosted",
        "github-hosted",
    }
)
_KEY_PATTERN = re.compile(r"[^a-z0-9._-]+")
_SHA1_PATTERN = re.compile(r"^[0-9a-f]{40}$")
_SHA256_PATTERN = re.compile(r"^[0-9a-f]{64}$")
_TRAVERSAL_PATTERN = re.compile(r"(^|[\\/])\.\.([\\/]|$)")
_WINDOWS_DRIVE_PATTERN = re.compile(r"^[A-Za-z]:")

_TOP_LEVEL_FIELDS = frozenset(
    {
        "schema_version",
        "repository",
        "commit_sha",
        "git_ref",
        "dirty_state",
        "run_key",
        "run_id",
        "run_attempt",
        "job_key",
        "workflow",
        "job",
        "execution_mode",
        "host_os",
        "host_arch",
        "runner_name",
        "suite",
        "platform",
        "environment",
        "build_mode",
        "classifier_reason",
        "started_at",
        "completed_at",
        "result",
        "evidence_status",
        "artifacts",
        "validations",
        "cleanup_disposition",
    }
)
_REQUIRED_TOP_LEVEL_FIELDS = _TOP_LEVEL_FIELDS

_ARTIFACT_FIELDS = frozenset(
    {
        "relative_path",
        "kind",
        "platform",
        "environment",
        "build_mode",
        "size_bytes",
        "sha256",
        "retention_class",
        "sensitivity",
        "signing",
        "distribution",
    }
)
_REQUIRED_ARTIFACT_FIELDS = frozenset(
    {
        "relative_path",
        "kind",
        "size_bytes",
        "sha256",
        "retention_class",
    }
)

_VALIDATION_FIELDS = frozenset(
    {
        "label",
        "result",
        "started_at",
        "completed_at",
        "exit_code",
    }
)
_REQUIRED_VALIDATION_FIELDS = frozenset(
    {
        "label",
        "result",
        "started_at",
        "completed_at",
    }
)

_CLEANUP_FIELDS = frozenset(
    {
        "status",
        "retention_class",
        "eligible_at",
        "reason",
        "pinned",
        "pin_expires_at",
    }
)
_REQUIRED_CLEANUP_FIELDS = frozenset(
    {
        "status",
        "retention_class",
        "eligible_at",
        "reason",
    }
)


def resolve_artifact_root(
    explicit_root: Optional[str],
    execution_mode: str,
    platform_name: str,
    environment: Mapping[str, str],
    product_key: str,
) -> Path:
    if execution_mode not in _EXECUTION_MODES:
        raise ValueError(f"Unsupported execution mode: {execution_mode!r}")

    if execution_mode == "github-hosted":
        raise ValueError("github-hosted does not use an implicit managed local root")

    if explicit_root is not None and explicit_root.strip():
        return Path(explicit_root.strip())

    if execution_mode == "self-hosted":
        raise ValueError("CI_ARTIFACT_ROOT is required for self-hosted execution")

    try:
        safe_product_key = sanitize_key(product_key)
    except ValueError as error:
        raise ValueError(f"invalid product_key: {error}") from error
    if safe_product_key != product_key:
        raise ValueError("product_key must already be a safe normalized identifier")

    if platform_name.lower().startswith("win"):
        local_app_data = environment.get("LOCALAPPDATA", "").strip()
        if not local_app_data:
            raise ValueError("LOCALAPPDATA is required for Windows manual-local")
        return Path(local_app_data) / safe_product_key / "ci-artifacts"

    state_home = environment.get("XDG_STATE_HOME", "").strip()
    if state_home:
        return Path(state_home) / safe_product_key / "ci-artifacts"

    home = environment.get("HOME", "").strip()
    if not home:
        raise ValueError("HOME is required for POSIX manual-local")
    return Path(home) / ".local" / "state" / safe_product_key / "ci-artifacts"


def validate_artifact_root(
    root: Path,
    repo_root: Path,
    runner_work: Optional[Path] = None,
    runner_temp: Optional[Path] = None,
    home: Optional[Path] = None,
) -> Path:
    # Artifact store 之後會執行 cleanup / purge，因此 root 必須先被限制在
    # repository、runner work/temp 與 filesystem/home root 之外，避免路徑誤判
    # 把 destructive cleanup 擴張到 source checkout 或系統目錄。
    candidate = Path(root)
    if ".." in candidate.parts:
        raise ValueError("artifact root contains path traversal")
    if not candidate.is_absolute():
        raise ValueError("artifact root must be absolute")

    _reject_symlink_components(candidate)

    resolved = candidate.resolve(strict=False)
    repository = Path(repo_root).resolve(strict=False)
    if _is_same_or_descendant(resolved, repository):
        raise ValueError("artifact root must be outside the repository")

    filesystem_root = Path(resolved.anchor).resolve(strict=False)
    if resolved == filesystem_root:
        raise ValueError("artifact root cannot be the filesystem root")

    if runner_work is not None:
        work_root = Path(runner_work).resolve(strict=False)
        if _is_same_or_descendant(resolved, work_root):
            raise ValueError("artifact root must be outside runner work")

    if runner_temp is not None:
        temp_root = Path(runner_temp).resolve(strict=False)
        if _is_same_or_descendant(resolved, temp_root):
            raise ValueError("artifact root must be outside runner temp")

    if home is not None and resolved == Path(home).resolve(strict=False):
        raise ValueError("artifact root cannot be the home root itself")

    if resolved.exists() and not resolved.is_dir():
        raise ValueError("artifact root must be a directory")
    return resolved


def sanitize_key(value: str) -> str:
    if not isinstance(value, str):
        raise ValueError("artifact key must be a string")
    if _TRAVERSAL_PATTERN.search(value):
        raise ValueError("artifact key contains traversal")

    normalized = _KEY_PATTERN.sub("-", value.strip().lower())
    normalized = re.sub(r"-+", "-", normalized).strip("-._")
    if not normalized or normalized in {".", ".."}:
        raise ValueError("artifact key is empty after sanitization")
    return normalized


def validate_job_manifest(payload: Mapping[str, Any]) -> None:
    if not isinstance(payload, Mapping):
        raise ValueError("manifest must be a mapping")

    _reject_forbidden_fields(payload)
    _validate_fields(payload, _TOP_LEVEL_FIELDS, _REQUIRED_TOP_LEVEL_FIELDS, "manifest")

    if (
        not isinstance(payload["schema_version"], int)
        or isinstance(payload["schema_version"], bool)
        or payload["schema_version"] != SCHEMA_VERSION
    ):
        raise ValueError("unsupported schema_version")
    _require_string(payload, "repository")

    commit_sha = _require_string(payload, "commit_sha")
    if not _SHA1_PATTERN.fullmatch(commit_sha):
        raise ValueError("commit_sha must be a lowercase 40-character SHA")

    _require_string(payload, "git_ref")
    if not isinstance(payload["dirty_state"], bool):
        raise ValueError("dirty_state must be a boolean")

    for key_name in ("run_key", "job_key"):
        key_value = _require_string(payload, key_name)
        if sanitize_key(key_value) != key_value:
            raise ValueError(f"{key_name} must already be sanitized")

    if payload["execution_mode"] not in _EXECUTION_MODES:
        raise ValueError("unsupported execution_mode")

    for string_field in (
        "host_os",
        "host_arch",
        "suite",
        "platform",
        "environment",
        "build_mode",
        "started_at",
        "completed_at",
        "result",
        "evidence_status",
    ):
        _require_string(payload, string_field)

    for optional_string_field in (
        "run_id",
        "workflow",
        "job",
        "runner_name",
        "classifier_reason",
    ):
        _require_optional_string(payload, optional_string_field)

    run_attempt = payload["run_attempt"]
    if run_attempt is not None and (
        not isinstance(run_attempt, int)
        or isinstance(run_attempt, bool)
        or run_attempt < 1
    ):
        raise ValueError("run_attempt must be a positive integer or null")

    if payload["result"] not in {"success", "failure", "cancelled", "skipped"}:
        raise ValueError("unsupported result")
    if payload["evidence_status"] not in {"complete", "degraded", "unavailable"}:
        raise ValueError("unsupported evidence_status")

    artifacts = _require_sequence(payload, "artifacts")
    for artifact in artifacts:
        _validate_artifact_entry(artifact)

    validations = _require_sequence(payload, "validations")
    for validation in validations:
        _validate_validation_entry(validation)

    cleanup = payload["cleanup_disposition"]
    if not isinstance(cleanup, Mapping):
        raise ValueError("cleanup_disposition must be a mapping")
    _validate_fields(
        cleanup,
        _CLEANUP_FIELDS,
        _REQUIRED_CLEANUP_FIELDS,
        "cleanup_disposition",
    )
    for field in ("status", "eligible_at", "reason"):
        _require_string(cleanup, field)
    if cleanup["retention_class"] not in RETENTION_CLASSES:
        raise ValueError("cleanup_disposition retention_class is unsupported")
    if "pinned" in cleanup and not isinstance(cleanup["pinned"], bool):
        raise ValueError("cleanup_disposition pinned must be a boolean")
    if "pin_expires_at" in cleanup:
        _require_optional_string(cleanup, "pin_expires_at")


def _validate_artifact_entry(value: Any) -> None:
    if not isinstance(value, Mapping):
        raise ValueError("artifact entry must be a mapping")
    _validate_fields(value, _ARTIFACT_FIELDS, _REQUIRED_ARTIFACT_FIELDS, "artifact")

    relative_path = _require_string(value, "relative_path")
    if "\\" in relative_path:
        raise ValueError("artifact relative_path must use forward slashes")
    path = PurePosixPath(relative_path)
    if (
        path.is_absolute()
        or _WINDOWS_DRIVE_PATTERN.match(relative_path)
        or ".." in path.parts
        or relative_path in {".", ".."}
    ):
        raise ValueError("artifact relative_path must be safe and relative")

    _require_string(value, "kind")
    size_bytes = value["size_bytes"]
    if (
        not isinstance(size_bytes, int)
        or isinstance(size_bytes, bool)
        or size_bytes < 0
    ):
        raise ValueError("artifact size_bytes must be a non-negative integer")

    sha256 = _require_string(value, "sha256")
    if not _SHA256_PATTERN.fullmatch(sha256):
        raise ValueError("artifact sha256 must be a lowercase 64-character hash")
    if value["retention_class"] not in RETENTION_CLASSES:
        raise ValueError("artifact retention_class is unsupported")

    for optional_field in (
        "platform",
        "environment",
        "build_mode",
        "sensitivity",
        "signing",
        "distribution",
    ):
        if optional_field in value:
            _require_optional_string(value, optional_field)


def _validate_validation_entry(value: Any) -> None:
    if not isinstance(value, Mapping):
        raise ValueError("validation entry must be a mapping")
    _validate_fields(
        value,
        _VALIDATION_FIELDS,
        _REQUIRED_VALIDATION_FIELDS,
        "validation",
    )
    for field in ("label", "result", "started_at", "completed_at"):
        _require_string(value, field)
    if "exit_code" in value:
        exit_code = value["exit_code"]
        if not isinstance(exit_code, int) or isinstance(exit_code, bool):
            raise ValueError("validation exit_code must be an integer")


def _validate_fields(
    payload: Mapping[str, Any],
    allowed: frozenset,
    required: frozenset,
    label: str,
) -> None:
    unknown = sorted(set(payload) - allowed)
    if unknown:
        raise ValueError(f"unknown {label} field: {unknown[0]}")
    missing = sorted(required - set(payload))
    if missing:
        raise ValueError(f"missing {label} field: {missing[0]}")


def _require_string(payload: Mapping[str, Any], field: str) -> str:
    value = payload[field]
    if not isinstance(value, str) or not value:
        raise ValueError(f"{field} must be a non-empty string")
    return value


def _require_optional_string(payload: Mapping[str, Any], field: str) -> Optional[str]:
    value = payload[field]
    if value is not None and (not isinstance(value, str) or not value):
        raise ValueError(f"{field} must be a non-empty string or null")
    return value


def _require_sequence(payload: Mapping[str, Any], field: str) -> Sequence[Any]:
    value = payload[field]
    if not isinstance(value, Sequence) or isinstance(value, (str, bytes, bytearray)):
        raise ValueError(f"{field} must be a sequence")
    return value


def _reject_forbidden_fields(value: Any) -> None:
    if isinstance(value, Mapping):
        for key, nested in value.items():
            normalized = str(key).lower().replace("-", "_")
            if any(pattern in normalized for pattern in SECRET_FIELD_PATTERNS):
                raise ValueError(f"forbidden manifest field: {key}")
            _reject_forbidden_fields(nested)
    elif isinstance(value, Sequence) and not isinstance(value, (str, bytes, bytearray)):
        for nested in value:
            _reject_forbidden_fields(nested)


def _reject_symlink_components(path: Path) -> None:
    current = Path(path.anchor)
    for part in path.parts[1:]:
        current = current / part
        if current.is_symlink():
            raise ValueError("artifact root cannot contain symlink components")


def _is_same_or_descendant(candidate: Path, parent: Path) -> bool:
    return candidate == parent or parent in candidate.parents
