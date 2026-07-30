from dataclasses import dataclass
from pathlib import Path
import re
from typing import Iterable, List, Optional


MAX_DIAGNOSTIC_BYTES = 25 * 1024 * 1024
_SCAN_CHUNK_BYTES = 64 * 1024
_SCAN_OVERLAP_BYTES = 2048

_CONTENT_PATTERNS = (
    (
        "private-key-header",
        re.compile(
            rb"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
            re.IGNORECASE,
        ),
    ),
    (
        "private-key-field",
        re.compile(rb'["\']private_key["\']\s*:', re.IGNORECASE),
    ),
    (
        "github-token",
        re.compile(rb"\bgho_[A-Za-z0-9]{20,}\b"),
    ),
    (
        "firebase-client-id",
        re.compile(
            rb"<key>(?:CLIENT_ID|REVERSED_CLIENT_ID|GOOGLE_APP_ID)</key>",
            re.IGNORECASE,
        ),
    ),
    (
        "firebase-app-id",
        re.compile(rb'["\']mobilesdk_app_id["\']\s*:', re.IGNORECASE),
    ),
    (
        "service-account-email",
        re.compile(
            rb'["\']client_email["\']\s*:\s*["\'][^"\']+gserviceaccount\.com',
            re.IGNORECASE,
        ),
    ),
)

_DENIED_NAMES = frozenset(
    {
        ".env",
        "firebase-service-account.json",
        "google-services.json",
        "googleservice-info.plist",
    }
)
_DENIED_SUFFIXES = frozenset(
    {
        ".jks",
        ".keystore",
        ".key",
        ".mobileprovision",
        ".p12",
        ".p8",
        ".pem",
    }
)


@dataclass(frozen=True)
class EvidenceScanResult:
    file_count: int
    total_bytes: int


def scan_evidence_paths(
    paths: Iterable[Path],
    *,
    max_total_bytes: Optional[int] = None,
) -> EvidenceScanResult:
    files = _collect_regular_files(paths)
    total_bytes = sum(path.stat().st_size for path in files)
    if max_total_bytes is not None and total_bytes > max_total_bytes:
        if max_total_bytes == MAX_DIAGNOSTIC_BYTES:
            raise ValueError("evidence exceeds the 25 MiB diagnostics limit")
        raise ValueError("evidence exceeds the configured size limit")

    for path in files:
        _validate_file_name(path)
        _scan_file_content(path)

    return EvidenceScanResult(
        file_count=len(files),
        total_bytes=total_bytes,
    )


def assert_secret_safe_text(value: str, *, label: str) -> None:
    data = value.encode("utf-8", errors="replace")
    _scan_bytes(data, label=label)


def _collect_regular_files(paths: Iterable[Path]) -> List[Path]:
    files: List[Path] = []
    for raw_path in paths:
        path = Path(raw_path)
        if path.is_symlink():
            raise ValueError(f"evidence path cannot be a symlink: {path.name}")
        if not path.exists():
            continue
        candidates = [path] if path.is_file() else sorted(path.rglob("*"))
        for candidate in candidates:
            if candidate.is_symlink():
                raise ValueError(
                    f"evidence entry cannot be a symlink: {candidate.name}"
                )
            if candidate.is_file():
                files.append(candidate)
    return files


def _validate_file_name(path: Path) -> None:
    lowered_name = path.name.lower()
    if lowered_name in _DENIED_NAMES or path.suffix.lower() in _DENIED_SUFFIXES:
        raise ValueError(
            f"secret leakage detected in evidence file: {path.name}"
        )


def _scan_file_content(path: Path) -> None:
    overlap = b""
    with path.open("rb") as handle:
        while True:
            chunk = handle.read(_SCAN_CHUNK_BYTES)
            if not chunk:
                break
            data = overlap + chunk
            _scan_bytes(data, label=path.name)
            overlap = data[-_SCAN_OVERLAP_BYTES:]


def _scan_bytes(data: bytes, *, label: str) -> None:
    for pattern_name, pattern in _CONTENT_PATTERNS:
        if pattern.search(data):
            raise ValueError(
                "secret leakage detected in evidence "
                f"(pattern={pattern_name}, file={label})"
            )
