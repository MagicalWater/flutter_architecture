from __future__ import annotations

import argparse
import base64
import hashlib
import json
import subprocess
import sys
from dataclasses import dataclass, replace
from pathlib import Path, PurePosixPath
from typing import Iterable, Sequence

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.change_classifier import classify_paths
from tools.ci.change_classifier import classify_change_classes


PLANNER_CONTRACT_VERSION = "2"


@dataclass(frozen=True)
class WorkspacePackage:
    name: str
    path: str
    local_dependencies: tuple[str, ...]


@dataclass(frozen=True)
class ValidationPlan:
    change_classes: tuple[str, ...]
    validation_level: str
    flutter_test_scopes: tuple[str, ...]
    python_test_scopes: tuple[str, ...]
    analyze_scopes: tuple[str, ...]
    docs_check: bool
    generated_check: bool
    android_build: bool
    ios_build: bool
    full_regression: bool
    release_full: bool
    reason: str
    fail_safe: bool
    android_development_build: bool = False
    android_production_build: bool = False
    ios_simulator_build: bool = False
    ios_production_build: bool = False


_LEVEL_RANK = {
    "focused": 0,
    "affected": 1,
    "workspace": 2,
    "full": 3,
    "release": 4,
}

_ROOT_CROSS_PLATFORM_RELEASE_PATHS = {
    "pubspec.yaml",
    "pubspec.lock",
    "melos.yaml",
    ".github/versions.env",
}

_PLANNER_SELECTION_PATHS = {
    "tools/ci/change_classifier.py",
    "tools/ci/validation_planner.py",
    "tools/ci/test_validation_planner.py",
}

_KNOWN_VALIDATION_WORKFLOWS = {
    ".github/workflows/ci.yml",
    ".github/workflows/android.yml",
    ".github/workflows/ios.yml",
}

_ANDROID_DEVELOPMENT_PATHS = {
    "tools/ci/build_android_development.sh",
}

_ANDROID_PRODUCTION_PATHS = {
    "tools/ci/build_android_production.sh",
}

_IOS_SIMULATOR_PATHS = {
    "tools/ci/build_ios_development.sh",
}

_IOS_PRODUCTION_PATHS = {
    "tools/ci/build_ios_production.sh",
}


def _platform_build_kinds(
    paths: Sequence[str],
    *,
    android_build: bool,
    ios_build: bool,
    invalid_range: bool = False,
    manual_mode: str = "",
    release_candidate: bool = False,
) -> tuple[bool, bool, bool, bool]:
    """Select minimum platform build variants without re-classifying change risk."""
    if invalid_range:
        return True, True, True, True

    normalized = tuple(
        dict.fromkeys(
            str(PurePosixPath(path.replace("\\", "/"))).removeprefix("./")
            for path in paths
            if path.strip()
        )
    )

    android_development = False
    android_production = False
    ios_simulator = False
    ios_production = False

    if manual_mode == "android":
        android_development = True
        android_production = True
    if manual_mode == "ios":
        ios_simulator = True
        ios_production = True

    if android_build and not (android_development or android_production):
        android_paths = tuple(
            path
            for path in normalized
            if path.startswith("apps/flutter_architecture/android/")
            or path.startswith("tools/ci/build_android_")
            or path == ".github/workflows/android.yml"
            or path in _ROOT_CROSS_PLATFORM_RELEASE_PATHS
            or path == "tools/ci/verify_environment_contract.py"
        )
        if release_candidate and any(path in _PLANNER_SELECTION_PATHS for path in normalized):
            android_production = True
        for path in android_paths:
            if path in _ANDROID_DEVELOPMENT_PATHS or "/src/development/" in path:
                android_development = True
            elif path in _ANDROID_PRODUCTION_PATHS or "/src/production/" in path:
                android_production = True
            else:
                android_development = True
                android_production = True
        if not android_paths and not android_production:
            android_development = True
            android_production = True

    if ios_build and not (ios_simulator or ios_production):
        ios_paths = tuple(
            path
            for path in normalized
            if path.startswith("apps/flutter_architecture/ios/")
            or path.startswith("tools/ci/build_ios_")
            or path == ".github/workflows/ios.yml"
            or path in _ROOT_CROSS_PLATFORM_RELEASE_PATHS
            or path == "tools/ci/verify_environment_contract.py"
        )
        if release_candidate and any(path in _PLANNER_SELECTION_PATHS for path in normalized):
            ios_production = True
        for path in ios_paths:
            if path in _IOS_SIMULATOR_PATHS or "Debug-development" in path:
                ios_simulator = True
            elif path in _IOS_PRODUCTION_PATHS or "Release-production" in path:
                ios_production = True
            else:
                ios_simulator = True
                ios_production = True
        if not ios_paths and not ios_production:
            ios_simulator = True
            ios_production = True

    return android_development, android_production, ios_simulator, ios_production


def _ordered_unique(values: Iterable[str]) -> tuple[str, ...]:
    return tuple(dict.fromkeys(value for value in values if value))


def _read_workspace_paths(root: Path) -> tuple[str, ...]:
    source = (root / "pubspec.yaml").read_text(encoding="utf-8")
    paths: list[str] = []
    in_workspace = False
    for raw_line in source.splitlines():
        line = raw_line.rstrip()
        if line == "workspace:":
            in_workspace = True
            continue
        if in_workspace:
            if line and not line.startswith(" "):
                break
            stripped = line.strip()
            if stripped.startswith("- "):
                paths.append(stripped[2:].strip())
    if not paths:
        raise ValueError("workspace paths are missing from root pubspec.yaml")
    return tuple(paths)


def _read_package_metadata(root: Path, relative_path: str) -> WorkspacePackage:
    source = (root / relative_path / "pubspec.yaml").read_text(encoding="utf-8")
    name = ""
    dependency_names: list[str] = []
    section = ""
    for raw_line in source.splitlines():
        line = raw_line.rstrip()
        if line.startswith("name:") and not name:
            name = line.split(":", 1)[1].strip()
            continue
        if line in {"dependencies:", "dev_dependencies:"}:
            section = line[:-1]
            continue
        if line and not line.startswith(" "):
            section = ""
            continue
        if section in {"dependencies", "dev_dependencies"}:
            stripped = line.strip()
            if not stripped or stripped.startswith("#") or stripped.startswith("sdk:") or stripped.startswith("path:"):
                continue
            if ":" in stripped and not stripped.startswith(("sdk:", "path:")):
                key = stripped.split(":", 1)[0].strip()
                if key and not key.startswith("-"):
                    dependency_names.append(key)
    if not name:
        raise ValueError(f"workspace package name missing: {relative_path}")
    return WorkspacePackage(name, relative_path, _ordered_unique(dependency_names))


def load_workspace_packages(repository: Path | str = ".") -> tuple[WorkspacePackage, ...]:
    root = Path(repository).resolve()
    packages = tuple(_read_package_metadata(root, path) for path in _read_workspace_paths(root))
    local_names = {package.name for package in packages}
    return tuple(
        WorkspacePackage(
            package.name,
            package.path,
            tuple(dep for dep in package.local_dependencies if dep in local_names),
        )
        for package in packages
    )


def reverse_dependency_closure(
    package_name: str,
    *,
    repository: Path | str = ".",
) -> tuple[WorkspacePackage, ...]:
    packages = load_workspace_packages(repository)
    by_name = {package.name: package for package in packages}
    if package_name not in by_name:
        raise ValueError(f"unknown workspace package: {package_name}")
    selected = {package_name}
    changed = True
    while changed:
        changed = False
        for package in packages:
            if package.name in selected:
                continue
            if any(dependency in selected for dependency in package.local_dependencies):
                selected.add(package.name)
                changed = True
    return tuple(package for package in packages if package.name in selected)


def _package_from_path(path: str) -> str | None:
    parts = PurePosixPath(path.replace("\\", "/")).parts
    if len(parts) >= 2 and parts[0] == "packages":
        return parts[1]
    return None


def _feature_from_path(path: str) -> str | None:
    parts = PurePosixPath(path.replace("\\", "/")).parts
    prefix = ("apps", "flutter_architecture", "lib", "features")
    if len(parts) > len(prefix) and parts[: len(prefix)] == prefix:
        return parts[len(prefix)]
    return None


def _test_scope_for_changed_test(path: str) -> str | None:
    normalized = path.replace("\\", "/")
    if normalized.endswith(("_test.dart", ".py")):
        return normalized
    return None


def _flutter_scope_has_tests(repository: Path | str, scope: str) -> bool:
    if scope == ".":
        return True
    root = Path(repository).resolve()
    target = root / PurePosixPath(scope.replace("\\", "/"))
    if target.is_file():
        return target.name.endswith("_test.dart")
    if not target.is_dir():
        return False
    return any(target.rglob("*_test.dart"))


def _max_level(current: str, candidate: str) -> str:
    return candidate if _LEVEL_RANK[candidate] > _LEVEL_RANK[current] else current


def plan_validation(
    paths: Sequence[str],
    *,
    repository: Path | str = ".",
    manual: bool = False,
    manual_mode: str = "focused",
    invalid_range: bool = False,
) -> ValidationPlan:
    classification = classify_paths(paths, manual=manual, invalid_range=invalid_range)
    classes = classification.change_classes

    if classification.fail_safe or "unknown" in classes:
        plan = ValidationPlan(
            classes,
            "full",
            (".",),
            ("tools",),
            (".",),
            True,
            True,
            False,
            False,
            True,
            False,
            classification.reason,
            True,
        )
        kinds = _platform_build_kinds(
            paths,
            android_build=plan.android_build,
            ios_build=plan.ios_build,
            invalid_range=invalid_range,
            manual_mode=manual_mode if manual else "",
        )
        return replace(
            plan,
            android_development_build=kinds[0],
            android_production_build=kinds[1],
            ios_simulator_build=kinds[2],
            ios_production_build=kinds[3],
        )

    level = "focused"
    flutter_scopes: list[str] = []
    python_scopes: list[str] = []
    analyze_scopes: list[str] = []
    docs_check = False
    generated_check = False
    android_build = False
    ios_build = False
    full_regression = False
    release_full = False
    reasons: list[str] = []

    normalized_paths = tuple(path.replace("\\", "/") for path in paths if path.strip())

    for change_class in classes:
        reasons.append(change_class)
        if change_class == "docs_content":
            docs_check = True
        elif change_class == "ide_config":
            pass
        elif change_class == "governance":
            docs_check = True
            python_scopes.append("tools/docs")
        elif change_class == "tooling":
            python_scopes.append("tools")
        elif change_class == "test_only":
            for path in normalized_paths:
                scope = _test_scope_for_changed_test(path)
                if scope:
                    if scope.endswith(".py"):
                        python_scopes.append(scope)
                    else:
                        flutter_scopes.append(scope)
        elif change_class == "app_feature":
            level = _max_level(level, "affected")
            for feature in filter(None, (_feature_from_path(path) for path in normalized_paths)):
                flutter_scopes.append(f"apps/flutter_architecture/test/features/{feature}")
            analyze_scopes.append("apps/flutter_architecture")
        elif change_class == "app_shared":
            level = _max_level(level, "workspace")
            flutter_scopes.append("apps/flutter_architecture/test")
            analyze_scopes.append("apps/flutter_architecture")
        elif change_class == "package":
            level = _max_level(level, "affected")
            try:
                package_names = _ordered_unique(
                    package
                    for package in (_package_from_path(path) for path in normalized_paths)
                    if package
                )
                for package_name in package_names:
                    affected = reverse_dependency_closure(package_name, repository=repository)
                    for package in affected:
                        analyze_scopes.append(package.path)
                    changed_package = next(
                        package for package in affected if package.name == package_name
                    )
                    flutter_scopes.append(f"{changed_package.path}/test")
            except (OSError, ValueError):
                plan = ValidationPlan(
                    classes,
                    "full",
                    (".",),
                    ("tools",),
                    (".",),
                    True,
                    True,
                    True,
                    True,
                    True,
                    False,
                    "workspace dependency graph parse failed; fail-safe full matrix",
                    True,
                )
                kinds = _platform_build_kinds(
                    normalized_paths,
                    android_build=plan.android_build,
                    ios_build=plan.ios_build,
                    invalid_range=True,
                )
                return replace(
                    plan,
                    android_development_build=kinds[0],
                    android_production_build=kinds[1],
                    ios_simulator_build=kinds[2],
                    ios_production_build=kinds[3],
                )
        elif change_class == "generated":
            level = _max_level(level, "workspace")
            generated_check = True
            flutter_scopes.append("apps/flutter_architecture/test")
            analyze_scopes.append("apps/flutter_architecture")
        elif change_class == "database":
            level = _max_level(level, "workspace")
            generated_check = True
            flutter_scopes.append("apps/flutter_architecture/test")
            analyze_scopes.append("apps/flutter_architecture")
        elif change_class == "android_native":
            level = _max_level(level, "workspace")
            android_build = True
        elif change_class == "ios_native":
            level = _max_level(level, "workspace")
            ios_build = True
        elif change_class == "platform_shared":
            level = _max_level(level, "workspace")
            android_build = True
            ios_build = True
        elif change_class in {"dependency", "validation_engine"}:
            level = _max_level(level, "full")
            flutter_scopes[:] = ["."]
            python_scopes[:] = ["tools"]
            analyze_scopes[:] = ["."]
            docs_check = True
            generated_check = True
            full_regression = True
        elif change_class == "release_metadata":
            docs_check = True
        elif change_class == "release":
            level = "release"
            flutter_scopes[:] = ["."]
            python_scopes[:] = ["tools"]
            analyze_scopes[:] = ["."]
            docs_check = True
            generated_check = True
            android_build = True
            ios_build = True
            full_regression = True
            release_full = True

    if manual and manual_mode == "release":
        return apply_release_freshness(
            plan_validation([], repository=repository, invalid_range=True),
            (),
            invalid_range=True,
        )
    if manual and manual_mode == "full":
        level = "full"
        flutter_scopes[:] = ["."]
        python_scopes[:] = ["tools"]
        analyze_scopes[:] = ["."]
        docs_check = True
        generated_check = True
        full_regression = True
        reasons.append(f"manual {manual_mode} request")
    elif manual and manual_mode == "android":
        android_build = True
        reasons.append("manual android request")
    elif manual and manual_mode == "ios":
        ios_build = True
        reasons.append("manual ios request")
    elif manual:
        reasons.append("manual focused request")

    flutter_scopes = [
        scope
        for scope in _ordered_unique(flutter_scopes)
        if _flutter_scope_has_tests(repository, scope)
    ]

    plan = ValidationPlan(
        classes,
        level,
        tuple(flutter_scopes),
        _ordered_unique(python_scopes),
        _ordered_unique(analyze_scopes),
        docs_check,
        generated_check,
        android_build,
        ios_build,
        full_regression,
        release_full,
        ", ".join(reasons) or classification.reason,
        False,
    )
    kinds = _platform_build_kinds(
        normalized_paths,
        android_build=plan.android_build,
        ios_build=plan.ios_build,
        invalid_range=invalid_range,
        manual_mode=manual_mode if manual else "",
    )
    return replace(
        plan,
        android_development_build=kinds[0],
        android_production_build=kinds[1],
        ios_simulator_build=kinds[2],
        ios_production_build=kinds[3],
    )


def apply_release_freshness(
    plan: ValidationPlan,
    paths: Sequence[str],
    *,
    invalid_range: bool = False,
) -> ValidationPlan:
    normalized = tuple(
        dict.fromkeys(
            str(PurePosixPath(path.replace("\\", "/"))).removeprefix("./")
            for path in paths
            if path.strip()
        )
    )

    full_regression = plan.full_regression
    generated_check = plan.generated_check
    android_build = plan.android_build
    ios_build = plan.ios_build
    fail_safe = plan.fail_safe

    if invalid_range:
        full_regression = True
        generated_check = True
        android_build = True
        ios_build = True
        fail_safe = True
    elif any(path in _ROOT_CROSS_PLATFORM_RELEASE_PATHS for path in normalized):
        full_regression = True
        generated_check = True
        android_build = True
        ios_build = True
    elif any(path in _PLANNER_SELECTION_PATHS for path in normalized):
        full_regression = True
        generated_check = True
        android_build = True
        ios_build = True
    else:
        if ".github/workflows/android.yml" in normalized:
            android_build = True
        if ".github/workflows/ios.yml" in normalized:
            ios_build = True
        if any(
            path.startswith(".github/workflows/")
            and path not in _KNOWN_VALIDATION_WORKFLOWS
            for path in normalized
        ):
            android_build = True
            ios_build = True

    reason = plan.reason
    if reason:
        reason = f"{reason}, release candidate freshness"
    else:
        reason = "release candidate freshness"

    kinds = _platform_build_kinds(
        normalized,
        android_build=android_build,
        ios_build=ios_build,
        invalid_range=invalid_range,
        release_candidate=True,
    )

    return replace(
        plan,
        validation_level="release",
        generated_check=generated_check,
        android_build=android_build,
        ios_build=ios_build,
        full_regression=full_regression,
        release_full=True,
        reason=reason,
        fail_safe=fail_safe,
        android_development_build=kinds[0],
        android_production_build=kinds[1],
        ios_simulator_build=kinds[2],
        ios_production_build=kinds[3],
    )


def plan_payload(plan: ValidationPlan) -> dict[str, object]:
    return {
        "change_classes": list(plan.change_classes),
        "validation_level": plan.validation_level,
        "flutter_test_scopes": list(plan.flutter_test_scopes),
        "python_test_scopes": list(plan.python_test_scopes),
        "analyze_scopes": list(plan.analyze_scopes),
        "docs_check": plan.docs_check,
        "generated_check": plan.generated_check,
        "android_build": plan.android_build,
        "ios_build": plan.ios_build,
        "android_development_build": plan.android_development_build,
        "android_production_build": plan.android_production_build,
        "ios_simulator_build": plan.ios_simulator_build,
        "ios_production_build": plan.ios_production_build,
        "full_regression": plan.full_regression,
        "release_full": plan.release_full,
        "reason": plan.reason,
        "fail_safe": plan.fail_safe,
    }


def encode_plan(plan: ValidationPlan) -> str:
    payload = json.dumps(plan_payload(plan), sort_keys=True, separators=(",", ":"))
    return base64.urlsafe_b64encode(payload.encode("utf-8")).decode("ascii")


def decode_plan(encoded: str) -> dict[str, object]:
    if not encoded:
        return plan_payload(
            plan_validation([], invalid_range=True)
        )
    return json.loads(base64.urlsafe_b64decode(encoded.encode("ascii")).decode("utf-8"))


def _workspace_dependency_payload(repository: Path | str) -> list[dict[str, object]]:
    return [
        {
            "name": package.name,
            "path": package.path,
            "local_dependencies": list(package.local_dependencies),
        }
        for package in load_workspace_packages(repository)
    ]


def _phase_relevant_paths(paths: Sequence[str], phase: str) -> tuple[str, ...]:
    normalized = tuple(
        sorted({str(PurePosixPath(path.replace("\\", "/"))).removeprefix("./") for path in paths if path.strip()})
    )
    if phase == "quality":
        return normalized
    if phase == "generated":
        relevant = {"generated", "database", "dependency", "validation_engine", "release", "unknown"}
    elif phase == "tests":
        relevant = {
            "test_only",
            "app_feature",
            "app_shared",
            "package",
            "generated",
            "database",
            "dependency",
            "validation_engine",
            "release",
            "unknown",
        }
    else:
        raise ValueError(f"unsupported evidence phase: {phase}")
    return tuple(
        path
        for path in normalized
        if any(change_class in relevant for change_class in classify_change_classes([path]))
    )


def validation_evidence_identity(
    plan: ValidationPlan,
    paths: Sequence[str],
    *,
    phase: str,
    repository: Path | str = ".",
) -> str:
    relevant_paths = _phase_relevant_paths(paths, phase)
    relevant_classes = classify_change_classes(relevant_paths) if relevant_paths else ()
    if phase == "tests":
        phase_plan = {
            "change_classes": list(relevant_classes),
            "validation_level": plan.validation_level,
            "flutter_test_scopes": list(plan.flutter_test_scopes),
            "full_regression": plan.full_regression,
            "release_full": plan.release_full,
            "fail_safe": plan.fail_safe,
        }
    elif phase == "generated":
        phase_plan = {
            "change_classes": list(relevant_classes),
            "generated_check": plan.generated_check,
            "fail_safe": plan.fail_safe,
        }
    else:
        phase_plan = plan_payload(plan)
    payload = {
        "planner_contract_version": PLANNER_CONTRACT_VERSION,
        "phase": phase,
        "paths": list(relevant_paths),
        "plan": phase_plan,
        "workspace_dependencies": _workspace_dependency_payload(repository),
    }
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def can_reuse_validation_evidence(
    *,
    previous_identity: str,
    current_identity: str,
    same_task: bool,
    previous_passed: bool,
    failure_recovery: bool = False,
    validation_engine_changed: bool = False,
    gate: str = "task",
) -> bool:
    if gate == "release":
        return False
    if not same_task or not previous_passed:
        return False
    if failure_recovery or validation_engine_changed:
        return False
    return bool(previous_identity) and previous_identity == current_identity


def plan_range(
    base: str,
    head: str,
    *,
    repository: Path | str = ".",
) -> ValidationPlan:
    if not base or not head or set(base) == {"0"}:
        return plan_validation([], repository=repository, invalid_range=True)
    try:
        completed = subprocess.run(
            ["git", "diff", "--name-only", base, head],
            cwd=repository,
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError):
        return plan_validation([], repository=repository, invalid_range=True)
    return plan_validation(completed.stdout.splitlines(), repository=repository)


def plan_release_range(
    base: str,
    head: str,
    *,
    repository: Path | str = ".",
) -> ValidationPlan:
    if not base or not head or set(base) == {"0"}:
        return apply_release_freshness(
            plan_validation([], repository=repository, invalid_range=True),
            (),
            invalid_range=True,
        )
    try:
        completed = subprocess.run(
            ["git", "diff", "--name-only", base, head],
            cwd=repository,
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError):
        return apply_release_freshness(
            plan_validation([], repository=repository, invalid_range=True),
            (),
            invalid_range=True,
        )
    paths = completed.stdout.splitlines()
    return apply_release_freshness(
        plan_validation(paths, repository=repository),
        paths,
    )


def _write_output(path: Path, plan: ValidationPlan) -> None:
    payload = plan_payload(plan)
    requires_flutter = bool(
        payload["flutter_test_scopes"]
        or payload["analyze_scopes"]
        or payload["generated_check"]
        or payload["android_build"]
        or payload["ios_build"]
    )
    values = {
        "plan_b64": encode_plan(plan),
        "validation_level": plan.validation_level,
        "requires_flutter": requires_flutter,
        "has_flutter_tests": bool(plan.flutter_test_scopes),
        "docs_check": plan.docs_check,
        "generated_check": plan.generated_check,
        "android_build": plan.android_build,
        "ios_build": plan.ios_build,
        "android_development_build": plan.android_development_build,
        "android_production_build": plan.android_production_build,
        "ios_simulator_build": plan.ios_simulator_build,
        "ios_production_build": plan.ios_production_build,
        "full_ci": plan.full_regression,
        "release_full": plan.release_full,
        "fail_safe": plan.fail_safe,
        "reason": plan.reason,
    }
    lines = [
        f"{key}={str(value).lower() if isinstance(value, bool) else value}"
        for key, value in values.items()
    ]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Plan minimum sufficient repository validation")
    parser.add_argument(
        "--event",
        required=True,
        choices=("push", "workflow_dispatch"),
    )
    parser.add_argument("--base", default="")
    parser.add_argument("--head", default="")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--repository", default=Path("."), type=Path)
    parser.add_argument("--stdout-json", action="store_true")
    parser.add_argument(
        "--mode",
        choices=("focused", "full", "android", "ios", "release"),
        default="focused",
        help="Explicit workflow_dispatch validation intent",
    )
    args = parser.parse_args()

    if args.event == "workflow_dispatch" and args.mode == "release":
        plan = plan_release_range(
            args.base,
            args.head,
            repository=args.repository,
        )
    elif args.event == "workflow_dispatch":
        plan = plan_validation(
            [], repository=args.repository, manual=True, manual_mode=args.mode
        )
    else:
        plan = plan_range(args.base, args.head, repository=args.repository)

    if args.output is not None:
        _write_output(args.output, plan)
    if args.stdout_json:
        print(json.dumps(plan_payload(plan), sort_keys=True, separators=(",", ":")))
    if args.output is None and not args.stdout_json:
        print(encode_plan(plan))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
