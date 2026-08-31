from __future__ import annotations

import argparse
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Sequence


@dataclass(frozen=True)
class Classification:
    change_classes: tuple[str, ...]
    docs_only: bool
    full_ci: bool
    android_build: bool
    ios_build: bool
    release_full: bool
    fail_safe: bool
    reason: str


_FULL_MATRIX = Classification(
    change_classes=("unknown",),
    docs_only=False,
    full_ci=True,
    android_build=False,
    ios_build=False,
    release_full=False,
    fail_safe=True,
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


def _is_ide_config_path(path: str) -> bool:
    return path.startswith(".run/") and path.endswith(".run.xml")


def _is_governance_path(path: str) -> bool:
    return (
        path == "AGENTS.md"
        or path == "repository_identity.json"
        or path == "repository_infrastructure.json"
        or path.startswith(".agents/skills/")
        or path == "skills-lock.json"
        or path.startswith("third_party/skills/")
        or path in {
            "docs/governance/development_workflow.md",
            "docs/guides/testing_governance.md",
            "docs/guides/how-to-add-feature.md",
            "docs/guides/agent_assisted_development_quick_start.md",
            "docs/guides/ci_cd_operations.md",
        }
    )


def _is_test_path(path: str) -> bool:
    return (
        "/test/" in f"/{path}"
        or "/integration_test/" in f"/{path}"
        or path.startswith("tools/")
        and PurePosixPath(path).name.startswith("test_")
    )


def _is_generated_path(path: str) -> bool:
    return path.endswith((".g.dart", ".freezed.dart", ".gr.dart")) or path.endswith(
        "injection.config.dart"
    )


def _is_dependency_path(path: str) -> bool:
    return (
        path in {"pubspec.yaml", "pubspec.lock", "melos.yaml", ".github/versions.env"}
        or path.endswith("/pubspec.yaml")
    )


def _classify_path(path: str) -> str | None:
    if path == "VERSION":
        return "release_metadata"
    if re.match(r"^apps/[^/]+/android/", path) or path.startswith(
        "tools/ci/build_android_"
    ):
        return "android_native"
    if re.match(r"^apps/[^/]+/ios/", path) or path.startswith(
        "tools/ci/build_ios_"
    ):
        return "ios_native"
    if path == "tools/ci/verify_environment_contract.py":
        return "platform_shared"
    if _is_classifier_path(path) or path == "tools/ci/validation_planner.py" or path == "tools/ci/test_validation_planner.py":
        return "validation_engine"
    if _is_ide_config_path(path):
        return "ide_config"
    if _is_governance_path(path):
        return "governance"
    if _is_database_critical_path(path):
        return "database"
    if _is_dependency_path(path):
        return "dependency"
    if _is_generated_path(path):
        return "generated"
    if _is_test_path(path):
        return "test_only"
    if re.match(r"^apps/[^/]+/lib/features/", path):
        return "app_feature"
    if re.match(r"^apps/[^/]+/lib/", path):
        return "app_shared"
    if path.startswith("packages/"):
        return "package"
    if path.startswith("tools/"):
        return "tooling"
    if _is_docs_path(path):
        return "docs_content"
    if re.match(r"^apps/[^/]+/assets/", path) or re.match(r"^apps/[^/]+/l10n\.yaml$", path):
        return "app_shared"
    return None


_CHANGE_CLASS_ORDER = (
    "docs_content",
    "ide_config",
    "governance",
    "tooling",
    "test_only",
    "app_feature",
    "app_shared",
    "package",
    "generated",
    "database",
    "android_native",
    "ios_native",
    "platform_shared",
    "dependency",
    "validation_engine",
    "release_metadata",
    "release",
    "unknown",
)


def classify_change_classes(paths: Sequence[str]) -> tuple[str, ...]:
    normalized = tuple(dict.fromkeys(_normalize(path) for path in paths if path.strip()))
    classes = {_classify_path(path) or "unknown" for path in normalized}
    return tuple(change_class for change_class in _CHANGE_CLASS_ORDER if change_class in classes)


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
        or path.startswith(".github/workflows/")
    )


def _is_shared_app_build_path(path: str) -> bool:
    return (
        re.match(r"^apps/[^/]+/(lib|config|assets)/", path) is not None
        or re.match(r"^apps/[^/]+/(pubspec\.yaml|l10n\.yaml)$", path) is not None
    )


def _is_database_critical_path(path: str) -> bool:
    return (
        re.match(r"^apps/[^/]+/lib/app/database/", path) is not None
        or re.match(r"^apps/[^/]+/test/drift_schemas/", path) is not None
        or re.match(r"^apps/[^/]+/web/(sqlite3\.wasm|drift_worker\.dart|drift_worker\.js)$", path) is not None
        or path.startswith("tools/database/")
    )


def _is_android_path(path: str) -> bool:
    return (
        re.match(r"^apps/[^/]+/android/", path) is not None
        or path.startswith("tools/ci/build_android_")
        or path == "tools/ci/verify_environment_contract.py"
        or path == ".github/workflows/android.yml"
        or path in _PLATFORM_EXACT
    )


def _is_ios_path(path: str) -> bool:
    return (
        re.match(r"^apps/[^/]+/ios/", path) is not None
        or path.startswith("tools/ci/build_ios_")
        or path == "tools/ci/verify_environment_contract.py"
        or path == ".github/workflows/ios.yml"
        or path in _PLATFORM_EXACT
    )


def classify_paths(
    paths: Sequence[str],
    *,
    manual: bool = False,
    invalid_range: bool = False,
) -> Classification:
    normalized = tuple(dict.fromkeys(_normalize(path) for path in paths if path.strip()))

    if manual:
        return Classification(
            ("manual",), False, False, False, False, False, False, "manual focused request"
        )

    if invalid_range or not normalized:
        # 無法可信取得 changed paths 時必須 fail closed。空集合不能解讀成
        # 「沒有風險」，否則 git range / caller defect 會靜默跳過必要 validation。
        return _FULL_MATRIX

    if "VERSION" in normalized:
        return Classification(
            classify_change_classes(normalized),
            False,
            False,
            False,
            False,
            False,
            False,
            "VERSION metadata changed",
        )

    if all(_is_docs_path(path) for path in normalized):
        change_classes = classify_change_classes(normalized)
        if "governance" not in change_classes:
            return Classification(
                change_classes,
                True,
                False,
                False,
                False,
                False,
                False,
                "documentation only",
            )

    change_classes = classify_change_classes(normalized)
    if "unknown" in change_classes:
        return _FULL_MATRIX

    return Classification(
        change_classes=change_classes,
        docs_only=False,
        full_ci=True,
        android_build=any(_is_android_path(path) for path in normalized),
        ios_build=any(_is_ios_path(path) for path in normalized),
        release_full=False,
        fail_safe=False,
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
        "fail_safe": classification.fail_safe,
    }
    lines = [f"{key}={str(value).lower()}" for key, value in values.items()]
    lines.append(f"reason={classification.reason.replace(chr(10), ' ')}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Classify repository changes for CI")
    parser.add_argument(
        "--event",
        required=True,
        choices=("push", "workflow_dispatch"),
    )
    parser.add_argument("--base", default="")
    parser.add_argument("--head", default="")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--repository", default=Path("."), type=Path)
    args = parser.parse_args()

    if args.event == "workflow_dispatch" and args.base and args.head:
        classification = classify_range(
            args.base,
            args.head,
            repository=args.repository,
        )
    elif args.event == "workflow_dispatch":
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
