from __future__ import annotations

import argparse
import subprocess
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Sequence


@dataclass(frozen=True)
class Classification:
    docs_only: bool
    full_ci: bool
    android_build: bool
    ios_build: bool
    release_full: bool
    reason: str


_FULL_MATRIX = Classification(
    docs_only=False,
    full_ci=True,
    android_build=True,
    ios_build=True,
    release_full=False,
    reason="fail-safe full matrix",
)

_FULL_CI_EXACT = {
    "pubspec.yaml",
    "pubspec.lock",
    "melos.yaml",
    "analysis_options.yaml",
    ".github/versions.env",
}

_PLATFORM_EXACT = {
    "pubspec.yaml",
    "pubspec.lock",
    "melos.yaml",
    ".github/versions.env",
}


def _normalize(path: str) -> str:
    normalized = str(PurePosixPath(path.replace("\\", "/")))
    return normalized.removeprefix("./")


def _is_docs_path(path: str) -> bool:
    return (
        path.endswith(".md")
        or path.startswith("docs/")
        or path in {"README.md", "CHANGELOG.md"}
    )


def _is_full_ci_path(path: str) -> bool:
    return (
        path.startswith("apps/")
        or path.startswith("packages/")
        or path.startswith("tools/")
        or path.startswith(".github/workflows/")
        or path in _FULL_CI_EXACT
    )


def _is_classifier_path(path: str) -> bool:
    return (
        path == "tools/ci/change_classifier.py"
        or path == "tools/ci/test_change_classifier.py"
        or path.startswith(".github/workflows/")
    )


def _is_shared_app_build_path(path: str) -> bool:
    return (
        path.startswith("apps/flutter_architecture/lib/")
        or path.startswith("apps/flutter_architecture/config/")
        or path.startswith("apps/flutter_architecture/assets/")
        or path == "apps/flutter_architecture/pubspec.yaml"
        or path == "apps/flutter_architecture/l10n.yaml"
    )


def _is_android_path(path: str) -> bool:
    return (
        path.startswith("apps/flutter_architecture/android/")
        or _is_shared_app_build_path(path)
        or path.startswith("packages/")
        or path.startswith("tools/ci/build_android_")
        or path == "tools/ci/verify_environment_contract.py"
        or path == ".github/workflows/android.yml"
        or path == ".github/workflows/ci.yml"
        or path in _PLATFORM_EXACT
        or _is_classifier_path(path)
    )


def _is_ios_path(path: str) -> bool:
    return (
        path.startswith("apps/flutter_architecture/ios/")
        or _is_shared_app_build_path(path)
        or path.startswith("packages/")
        or path.startswith("tools/ci/build_ios_")
        or path == "tools/ci/verify_environment_contract.py"
        or path == ".github/workflows/ios.yml"
        or path == ".github/workflows/ci.yml"
        or path in _PLATFORM_EXACT
        or _is_classifier_path(path)
    )


def classify_paths(
    paths: Sequence[str],
    *,
    manual: bool = False,
    invalid_range: bool = False,
) -> Classification:
    normalized = tuple(dict.fromkeys(_normalize(path) for path in paths if path.strip()))

    if manual:
        return Classification(False, True, True, True, True, "manual full matrix")

    if invalid_range or not normalized:
        return _FULL_MATRIX

    if "VERSION" in normalized:
        return Classification(False, True, True, True, True, "VERSION changed")

    if all(_is_docs_path(path) for path in normalized):
        return Classification(True, False, False, False, False, "documentation only")

    known_paths = tuple(path for path in normalized if _is_full_ci_path(path))
    if len(known_paths) != len(normalized):
        return _FULL_MATRIX

    return Classification(
        docs_only=False,
        full_ci=True,
        android_build=any(_is_android_path(path) for path in normalized),
        ios_build=any(_is_ios_path(path) for path in normalized),
        release_full=False,
        reason="classified source or tooling change",
    )


def classify_range(
    base: str,
    head: str,
    *,
    repository: Path | str = ".",
) -> Classification:
    if not base or not head or set(base) == {"0"}:
        return _FULL_MATRIX

    try:
        completed = subprocess.run(
            ["git", "diff", "--name-only", base, head],
            cwd=repository,
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError):
        return _FULL_MATRIX

    return classify_paths(completed.stdout.splitlines())


def _write_output(path: Path, classification: Classification) -> None:
    values = {
        "docs_only": classification.docs_only,
        "full_ci": classification.full_ci,
        "android_build": classification.android_build,
        "ios_build": classification.ios_build,
        "release_full": classification.release_full,
    }
    lines = [f"{key}={str(value).lower()}" for key, value in values.items()]
    lines.append(f"reason={classification.reason.replace(chr(10), ' ')}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify repository changes for CI")
    parser.add_argument(
        "--event",
        required=True,
        choices=("push", "pull_request", "workflow_dispatch"),
    )
    parser.add_argument("--base", default="")
    parser.add_argument("--head", default="")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--repository", default=Path("."), type=Path)
    args = parser.parse_args()

    if args.event == "workflow_dispatch":
        classification = classify_paths([], manual=True)
    else:
        classification = classify_range(
            args.base,
            args.head,
            repository=args.repository,
        )

    _write_output(args.output, classification)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
