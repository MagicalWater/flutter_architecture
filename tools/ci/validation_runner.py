from __future__ import annotations

import argparse
import shlex
import subprocess
import sys
from pathlib import Path, PurePosixPath
from typing import Iterable

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.validation_planner import decode_plan


def _workspace_command(scope: str, verb: str) -> tuple[Path, list[str]]:
    normalized = PurePosixPath(scope.replace("\\", "/"))
    parts = normalized.parts
    if scope == ".":
        if verb == "test":
            return Path("."), ["dart", "run", "melos", "exec", "--", "flutter", "test"]
        return Path("."), ["dart", "run", "melos", "run", "analyze"]

    if len(parts) >= 2 and parts[0] in {"apps", "packages"}:
        workspace = Path(parts[0]) / parts[1]
        relative = PurePosixPath(*parts[2:])
        if verb == "analyze":
            return workspace, ["flutter", "analyze"]
        if not relative.parts:
            relative = PurePosixPath("test")
        return workspace, ["flutter", "test", relative.as_posix()]
    raise ValueError(f"unsupported Flutter scope: {scope}")


def _python_command(scope: str) -> tuple[Path, list[str]]:
    normalized = scope.replace("\\", "/")
    if normalized == "tools":
        return Path("."), [sys.executable, "-m", "unittest", "discover", "-s", "tools", "-p", "test_*.py"]
    if normalized.startswith("tools/") and normalized.endswith(".py"):
        module = normalized[:-3].replace("/", ".")
        return Path("."), [sys.executable, "-m", "unittest", module]
    if normalized.startswith("tools/"):
        return Path("."), [sys.executable, "-m", "unittest", "discover", "-s", normalized, "-p", "test_*.py"]
    raise ValueError(f"unsupported Python scope: {scope}")


def commands_for_phase(plan: dict[str, object], phase: str) -> tuple[tuple[Path, list[str]], ...]:
    commands: list[tuple[Path, list[str]]] = []
    if phase == "quality":
        if bool(plan["docs_check"]):
            commands.append((Path("."), [sys.executable, "tools/docs/check_docs.py", "."]))
        for scope in plan["python_test_scopes"]:
            commands.append(_python_command(str(scope)))
        for scope in plan["analyze_scopes"]:
            commands.append(_workspace_command(str(scope), "analyze"))
        commands.append((Path("."), ["git", "diff", "--check"]))
    elif phase == "tests":
        for scope in plan["flutter_test_scopes"]:
            commands.append(_workspace_command(str(scope), "test"))
    elif phase == "generated":
        if bool(plan["generated_check"]):
            commands.append((Path("."), ["bash", "tools/ci/verify_generated.sh"]))
    else:
        raise ValueError(f"unsupported phase: {phase}")
    return tuple(commands)


def render_commands(commands: Iterable[tuple[Path, list[str]]]) -> str:
    return "\n".join(
        f"{cwd.as_posix()} :: {shlex.join(command)}" for cwd, command in commands
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Execute a serialized validation plan phase")
    parser.add_argument("--phase", required=True, choices=("quality", "tests", "generated"))
    parser.add_argument("--plan-b64", default="")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--repository", type=Path, default=Path("."))
    args = parser.parse_args()

    plan = decode_plan(args.plan_b64)
    commands = commands_for_phase(plan, args.phase)
    if args.dry_run:
        print(render_commands(commands))
        return 0

    root = args.repository.resolve()
    for cwd, command in commands:
        subprocess.run(command, cwd=root / cwd, check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
