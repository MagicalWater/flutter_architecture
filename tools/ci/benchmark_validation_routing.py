from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path

if __package__ in {None, ""}:
    import sys

    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.change_classifier import classify_paths
from tools.ci.validation_planner import plan_payload, plan_validation
from tools.ci.validation_runner import commands_for_phase


SCENARIOS: dict[str, tuple[str, ...]] = {
    "docs-only": ("docs/guides/how-to-add-feature.md",),
    "single-feature": (
        "apps/flutter_architecture/lib/features/profile/presentation/profile_page.dart",
    ),
    "single-test": (
        "apps/flutter_architecture/test/features/profile/presentation/pages/profile_view_test.dart",
    ),
    "leaf-package": ("packages/design_system/lib/src/theme/app_theme.dart",),
    "app-shared": ("apps/flutter_architecture/lib/app/router/app_router.dart",),
    "tooling": ("tools/docs/check_docs.py",),
    "database": ("apps/flutter_architecture/lib/app/database/app_database.dart",),
    "android-native": ("apps/flutter_architecture/android/app/build.gradle.kts",),
    "ios-native": ("apps/flutter_architecture/ios/Runner/AppDelegate.swift",),
    "dependency": ("pubspec.yaml",),
    "validation-engine": ("tools/ci/validation_planner.py",),
    "unknown": ("unexpected/new-root/file.txt",),
    "release": ("VERSION",),
    "mixed-docs-package": (
        "docs/guides/testing_governance.md",
        "packages/core/lib/src/result.dart",
    ),
}


@dataclass(frozen=True)
class RoutingMeasurement:
    scenario: str
    paths: tuple[str, ...]
    before_full_ci: bool
    before_android_build: bool
    before_ios_build: bool
    before_command_count: int
    after_change_classes: tuple[str, ...]
    after_validation_level: str
    after_command_count: int
    after_flutter_process_count: int
    after_flutter_test_scopes: tuple[str, ...]
    after_android_build: bool
    after_ios_build: bool
    after_fail_safe: bool
    reason: str


def _legacy_command_count(full_ci: bool, docs_only: bool) -> int:
    # Mirrors the pre-M35 conceptual execution path rather than workflow step count:
    # docs + CI Python + analyze + generated + Flutter tests + diff check.
    return 2 if docs_only else (6 if full_ci else 2)


def measure_scenario(
    scenario: str,
    paths: tuple[str, ...],
    *,
    repository: Path | str = ".",
) -> RoutingMeasurement:
    before = classify_paths(paths)
    after = plan_validation(paths, repository=repository)
    payload = plan_payload(after)
    commands = tuple(
        command
        for phase in ("quality", "generated", "tests")
        for command in commands_for_phase(payload, phase)
    )
    flutter_processes = sum(
        1
        for _, command in commands
        if "flutter" in command or ("melos" in command and "flutter" in command)
    )
    return RoutingMeasurement(
        scenario=scenario,
        paths=paths,
        before_full_ci=before.full_ci,
        before_android_build=before.android_build,
        before_ios_build=before.ios_build,
        before_command_count=_legacy_command_count(before.full_ci, before.docs_only),
        after_change_classes=after.change_classes,
        after_validation_level=after.validation_level,
        after_command_count=len(commands),
        after_flutter_process_count=flutter_processes,
        after_flutter_test_scopes=after.flutter_test_scopes,
        after_android_build=after.android_build,
        after_ios_build=after.ios_build,
        after_fail_safe=after.fail_safe,
        reason=after.reason,
    )


def measure_all(repository: Path | str = ".") -> tuple[RoutingMeasurement, ...]:
    return tuple(
        measure_scenario(name, paths, repository=repository)
        for name, paths in SCENARIOS.items()
    )


def measure_wall_clock(repository: Path | str = ".") -> list[dict[str, object]]:
    root = Path(repository).resolve()
    cases = {
        "single-feature": SCENARIOS["single-feature"],
        "single-test": SCENARIOS["single-test"],
        "leaf-package": SCENARIOS["leaf-package"],
        "full-regression": ("tools/ci/validation_planner.py",),
    }
    rows: list[dict[str, object]] = []
    for name, paths in cases.items():
        plan = plan_validation(paths, repository=root)
        commands = commands_for_phase(plan_payload(plan), "tests")
        started = time.perf_counter()
        exit_code = 0
        executed: list[str] = []
        tails: list[str] = []
        for cwd, command in commands:
            executed.append(f"{cwd.as_posix()} :: {' '.join(command)}")
            executable = shutil.which(command[0])
            if executable is None:
                raise RuntimeError(f"executable not found for benchmark: {command[0]}")
            resolved_command = [executable, *command[1:]]
            completed = subprocess.run(
                resolved_command,
                cwd=root / cwd,
                text=True,
                capture_output=True,
                check=False,
            )
            tails.append((completed.stdout + "\n" + completed.stderr)[-1000:])
            if completed.returncode != 0:
                exit_code = completed.returncode
                break
        rows.append(
            {
                "case": name,
                "seconds": round(time.perf_counter() - started, 3),
                "exit_code": exit_code,
                "flutter_process_count": len(commands),
                "commands": executed,
                "output_tail": "\n".join(tails)[-2000:],
            }
        )
    return rows


def main() -> int:
    parser = argparse.ArgumentParser(description="Measure repository validation routing")
    parser.add_argument("--repository", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path)
    parser.add_argument("--wall-clock-output", type=Path)
    args = parser.parse_args()

    rows = [asdict(row) for row in measure_all(args.repository)]
    payload = json.dumps(rows, ensure_ascii=False, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload, encoding="utf-8")
    else:
        print(payload, end="")
    if args.wall_clock_output:
        wall_clock = json.dumps(
            measure_wall_clock(args.repository), ensure_ascii=False, indent=2
        ) + "\n"
        args.wall_clock_output.parent.mkdir(parents=True, exist_ok=True)
        args.wall_clock_output.write_text(wall_clock, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
