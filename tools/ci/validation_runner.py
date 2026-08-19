from __future__ import annotations

import argparse
import os
import shlex
import shutil
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
            return Path("."), [
                "dart",
                "run",
                "melos",
                "exec",
                "--scope=flutter_architecture",
                "--scope=auth",
                "--scope=api_client",
                "--",
                "flutter",
                "test",
            ]
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


def _python_commands(scope: str) -> tuple[tuple[Path, list[str]], ...]:
    normalized = scope.replace("\\", "/")
    if normalized == "tools":
        return (
            (
                Path("."),
                [
                    sys.executable,
                    "-m",
                    "unittest",
                    "discover",
                    "-s",
                    "tools/ci",
                    "-p",
                    "test_*.py",
                ],
            ),
            (
                Path("."),
                [
                    sys.executable,
                    "-m",
                    "unittest",
                    "discover",
                    "-s",
                    "tools/docs",
                    "-p",
                    "test_*.py",
                ],
            ),
        )
    if normalized.startswith("tools/") and normalized.endswith(".py"):
        module = normalized[:-3].replace("/", ".")
        return ((Path("."), [sys.executable, "-m", "unittest", module]),)
    if normalized.startswith("tools/"):
        return (
            (
                Path("."),
                [
                    sys.executable,
                    "-m",
                    "unittest",
                    "discover",
                    "-s",
                    normalized,
                    "-p",
                    "test_*.py",
                ],
            ),
        )
    raise ValueError(f"unsupported Python scope: {scope}")


def _whole_workspace_test_name(scope: str) -> str | None:
    normalized = PurePosixPath(scope.replace("\\", "/"))
    parts = normalized.parts
    if len(parts) == 3 and parts[0] in {"apps", "packages"} and parts[2] == "test":
        return parts[1]
    return None


def commands_for_phase(plan: dict[str, object], phase: str) -> tuple[tuple[Path, list[str]], ...]:
    commands: list[tuple[Path, list[str]]] = []
    if phase == "quality":
        if bool(plan["docs_check"]):
            commands.append((Path("."), [sys.executable, "tools/docs/check_docs.py", "."]))
        for scope in plan["python_test_scopes"]:
            commands.extend(_python_commands(str(scope)))
        for scope in plan["analyze_scopes"]:
            commands.append(_workspace_command(str(scope), "analyze"))
        commands.append((Path("."), ["git", "diff", "--check"]))
    elif phase == "tests":
        scopes = [str(scope) for scope in plan["flutter_test_scopes"]]
        whole_workspace_names = [
            name for name in (_whole_workspace_test_name(scope) for scope in scopes) if name
        ]
        grouped_scopes = {
            scope for scope in scopes if _whole_workspace_test_name(scope) is not None
        }
        if len(whole_workspace_names) > 1:
            command = ["dart", "run", "melos", "exec"]
            for name in whole_workspace_names:
                command.append(f"--scope={name}")
            command.extend(["--", "flutter", "test"])
            commands.append((Path("."), command))
        else:
            grouped_scopes.clear()
        for scope in scopes:
            if scope not in grouped_scopes:
                commands.append(_workspace_command(scope, "test"))
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


def _execution_command(command: list[str], *, platform_name: str | None = None) -> list[str]:
    platform = os.name if platform_name is None else platform_name
    if platform != "nt" or not command:
        return command

    resolved: str | None = None
    if command[0].lower() == "bash":
        program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
        for candidate in (
            program_files / "Git" / "bin" / "bash.exe",
            program_files / "Git" / "usr" / "bin" / "bash.exe",
        ):
            if candidate.is_file():
                resolved = str(candidate)
                break
    if resolved is None:
        resolved = shutil.which(command[0])
    if resolved is None:
        return command
    if Path(resolved).suffix.lower() not in {".bat", ".cmd"}:
        return [resolved, *command[1:]]

    return [
        os.environ.get("COMSPEC", "cmd.exe"),
        "/d",
        "/s",
        "/c",
        subprocess.list2cmdline(command),
    ]


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
        subprocess.run(_execution_command(command), cwd=root / cwd, check=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
