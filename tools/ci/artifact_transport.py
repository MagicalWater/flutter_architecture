import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import sys
from typing import Iterable, List, Optional, Sequence


if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))


FAILURE_ONLY_MAX_BYTES = 25 * 1024 * 1024
VALID_ARTIFACT_TRANSPORTS = frozenset(
    {"repository-default", "none", "failure-only", "full"}
)
_FAILURE_ONLY_SUFFIXES = frozenset({".txt", ".log", ".md", ".json", ".png"})
_DENIED_NAMES = frozenset(
    {
        ".env",
        "mapping.txt",
        "google-services.json",
        "googleservice-info.plist",
        "firebase-service-account.json",
    }
)
_DENIED_NAME_MARKERS = frozenset(
    {
        "service-account",
        "private-key",
        "provider-config",
        "credentials",
    }
)
_DENIED_SUFFIXES = frozenset(
    {
        ".jks",
        ".keystore",
        ".mobileprovision",
        ".p12",
        ".p8",
        ".pem",
        ".key",
    }
)


@dataclass(frozen=True)
class RemoteUploadEntry:
    path: Path
    size_bytes: int


def resolve_artifact_transport(event_name: str, requested: str) -> str:
    if requested not in VALID_ARTIFACT_TRANSPORTS:
        raise ValueError(f"Unsupported artifact transport: {requested!r}")
    if event_name != "workflow_dispatch":
        return "none"
    if requested == "repository-default":
        return "none"
    return requested


def collect_remote_upload_entries(
    paths: Iterable[Path],
    transport: str,
) -> List[RemoteUploadEntry]:
    if transport not in {"failure-only", "full"}:
        raise ValueError("remote upload preflight requires failure-only or full transport")

    entries: List[RemoteUploadEntry] = []
    for raw_path in paths:
        path = Path(raw_path)
        if path.is_symlink():
            raise ValueError(f"remote upload path cannot be a symlink: {path}")
        if not path.exists():
            continue
        candidates = [path] if path.is_file() else sorted(path.rglob("*"))
        for candidate in candidates:
            if candidate.is_symlink():
                raise ValueError(f"remote upload entry cannot be a symlink: {candidate}")
            if not candidate.is_file():
                continue
            _validate_always_denied_entry(candidate)
            if transport == "failure-only":
                _validate_failure_only_entry(candidate)
            entries.append(
                RemoteUploadEntry(
                    path=candidate,
                    size_bytes=candidate.stat().st_size,
                )
            )

    total_bytes = sum(entry.size_bytes for entry in entries)
    if transport == "failure-only" and total_bytes > FAILURE_ONLY_MAX_BYTES:
        raise ValueError(
            "failure-only diagnostics exceed the 25 MiB total preflight limit"
        )
    if transport == "full" and not entries:
        raise ValueError("full artifact transport resolved no files")
    return entries


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="GitHub artifact transport policy")
    subparsers = parser.add_subparsers(dest="command", required=True)
    preflight = subparsers.add_parser("preflight")
    preflight.add_argument(
        "--transport",
        required=True,
        choices=("failure-only", "full"),
    )
    preflight.add_argument("--path", action="append", default=[], required=True)
    args = parser.parse_args(argv)

    entries = collect_remote_upload_entries(
        [Path(value) for value in args.path],
        args.transport,
    )
    print(
        json.dumps(
            {
                "transport": args.transport,
                "entry_count": len(entries),
                "total_bytes": sum(entry.size_bytes for entry in entries),
            },
            sort_keys=True,
        )
    )
    return 0


def _validate_failure_only_entry(path: Path) -> None:
    lowered_parts = [part.lower() for part in path.parts]
    if any(part.endswith(".app") or part.endswith(".dsym") for part in lowered_parts):
        raise ValueError(f"failure-only transport rejects platform bundle: {path}")
    lowered_name = path.name.lower()
    if lowered_name in _DENIED_NAMES:
        raise ValueError(f"failure-only transport rejects sensitive artifact: {path}")
    if path.suffix.lower() in {".apk", ".aab", ".ipa", ".symbols"}:
        raise ValueError(f"failure-only transport rejects platform artifact: {path}")
    if path.suffix.lower() not in _FAILURE_ONLY_SUFFIXES:
        raise ValueError(f"failure-only transport rejects file type: {path}")
    if path.suffix.lower() == ".png" and not any(
        marker in lowered_name for marker in ("master", "test", "diff")
    ):
        raise ValueError(f"failure-only transport only permits selected golden PNGs: {path}")


def _validate_always_denied_entry(path: Path) -> None:
    lowered_name = path.name.lower()
    if lowered_name in _DENIED_NAMES:
        raise ValueError(f"remote transport rejects sensitive artifact: {path}")
    if path.suffix.lower() in _DENIED_SUFFIXES:
        raise ValueError(f"remote transport rejects signing material: {path}")
    if any(marker in lowered_name for marker in _DENIED_NAME_MARKERS):
        raise ValueError(f"remote transport rejects credential material: {path}")


if __name__ == "__main__":
    raise SystemExit(main())
