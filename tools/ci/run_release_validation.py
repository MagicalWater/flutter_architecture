from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Sequence

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.validation_planner import encode_plan, plan_payload, plan_release_range
from tools.ci.validation_runner import _execution_command


_WORKFLOWS = {
    "ci": ".github/workflows/ci.yml",
    "android": ".github/workflows/android.yml",
    "ios": ".github/workflows/ios.yml",
}


@dataclass(frozen=True)
class RunEvidence:
    family: str
    run_id: int | None
    head_sha: str
    conclusion: str
    url: str
    created_at: str
    started_at: str
    updated_at: str
    backend: str = "github-hosted"
    evidence_ref: str = ""


def _run(command: Sequence[str], *, repository: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        list(command),
        cwd=repository,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )


def _selected_families(payload: dict[str, object]) -> tuple[str, ...]:
    logical = bool(
        payload.get("docs_check")
        or payload.get("generated_check")
        or payload.get("flutter_test_scopes")
        or payload.get("python_test_scopes")
        or payload.get("analyze_scopes")
    )
    selected: list[str] = []
    if logical:
        selected.append("ci")
    if payload.get("android_build"):
        selected.append("android")
    if payload.get("ios_build"):
        selected.append("ios")
    return tuple(selected)


def _current_branch(repository: Path) -> str:
    branch = _run(["git", "branch", "--show-current"], repository=repository).stdout.strip()
    if not branch:
        raise RuntimeError("release validation requires a named candidate branch")
    return branch


def _assert_candidate_identity(repository: Path, branch: str, head: str) -> None:
    dirty = _run(["git", "status", "--porcelain"], repository=repository).stdout.strip()
    if dirty:
        raise RuntimeError("release validation requires a clean candidate worktree")
    local_head = _run(["git", "rev-parse", "HEAD"], repository=repository).stdout.strip()
    if local_head != head:
        raise RuntimeError(f"candidate HEAD mismatch: expected {head}, got {local_head}")
    remote = _run(
        ["git", "ls-remote", "origin", f"refs/heads/{branch}"], repository=repository
    ).stdout.strip()
    remote_head = remote.split("\t", 1)[0] if remote else ""
    if remote_head != head:
        raise RuntimeError(
            f"remote candidate mismatch for {branch}: expected {head}, got {remote_head or 'missing'}"
        )


def _dispatch_workflow(
    family: str,
    *,
    repository: Path,
    branch: str,
    base: str,
    execution_mode: str,
) -> None:
    _run(
        [
            "gh",
            "workflow",
            "run",
            _WORKFLOWS[family],
            "--ref",
            branch,
            "-f",
            "validation_mode=release",
            "-f",
            f"release_base={base}",
            "-f",
            f"execution_mode={execution_mode}",
            "-f",
            "artifact_transport=none",
        ],
        repository=repository,
    )


def _listed_runs(
    family: str,
    *,
    repository: Path,
    branch: str,
) -> list[dict[str, object]]:
    result = _run(
        [
            "gh",
            "run",
            "list",
            "--workflow",
            _WORKFLOWS[family],
            "--branch",
            branch,
            "--event",
            "workflow_dispatch",
            "--limit",
            "20",
            "--json",
            "databaseId,headSha,createdAt",
        ],
        repository=repository,
    )
    return list(json.loads(result.stdout or "[]"))


def _find_run_id(
    family: str,
    *,
    repository: Path,
    branch: str,
    head: str,
    excluded_ids: frozenset[int],
) -> int:
    deadline = time.monotonic() + 60
    while time.monotonic() < deadline:
        for item in _listed_runs(family, repository=repository, branch=branch):
            run_id = int(item["databaseId"])
            if item.get("headSha") == head and run_id not in excluded_ids:
                return run_id
        time.sleep(1)
    raise RuntimeError(f"timed out locating {family} workflow run for {head}")


def _wait_for_run(
    family: str,
    run_id: int,
    *,
    repository: Path,
    head: str,
) -> RunEvidence:
    _run(["gh", "run", "watch", str(run_id), "--exit-status"], repository=repository)
    result = _run(
        [
            "gh",
            "run",
            "view",
            str(run_id),
            "--json",
            "conclusion,headSha,url,createdAt,startedAt,updatedAt",
        ],
        repository=repository,
    )
    item = json.loads(result.stdout)
    evidence = RunEvidence(
        family=family,
        run_id=run_id,
        head_sha=str(item.get("headSha", "")),
        conclusion=str(item.get("conclusion", "")),
        url=str(item.get("url", "")),
        created_at=str(item.get("createdAt", "")),
        started_at=str(item.get("startedAt", "")),
        updated_at=str(item.get("updatedAt", "")),
    )
    if evidence.head_sha != head:
        raise RuntimeError(
            f"{family} run {run_id} SHA mismatch: expected {head}, got {evidence.head_sha}"
        )
    if evidence.conclusion != "success":
        raise RuntimeError(
            f"{family} run {run_id} did not succeed: {evidence.conclusion or 'unknown'}"
        )
    return evidence


def _utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _manual_local_commands(payload: dict[str, object], plan_b64: str) -> dict[str, tuple[tuple[str, ...], ...]]:
    commands: dict[str, list[tuple[str, ...]]] = {"ci": [], "android": [], "ios": []}
    if "ci" in _selected_families(payload):
        if bool(payload.get("docs_check")) or payload.get("python_test_scopes") or payload.get(
            "analyze_scopes"
        ):
            commands["ci"].append(("__validation_phase__", "quality", plan_b64))
        if payload.get("flutter_test_scopes"):
            commands["ci"].append(("__validation_phase__", "tests", plan_b64))
        if bool(payload.get("generated_check")):
            commands["ci"].append(("__validation_phase__", "generated", plan_b64))
    if bool(payload.get("android_development_build")):
        commands["android"].append(("bash", "tools/ci/build_android_development.sh"))
    if bool(payload.get("android_production_build")):
        commands["android"].append(("bash", "tools/ci/build_android_production.sh"))
    if bool(payload.get("ios_simulator_build")):
        commands["ios"].append(("bash", "tools/ci/build_ios_development.sh"))
    if bool(payload.get("ios_production_build")):
        commands["ios"].append(("bash", "tools/ci/build_ios_production.sh"))
    return {family: tuple(items) for family, items in commands.items()}


def _manual_platform(family: str, command: Sequence[str]) -> str:
    if family == "ci":
        return "repository"
    if family == "android":
        return "android"
    if family == "ios":
        return "ios"
    raise ValueError(f"unsupported manual-local family: {family}")


def _manual_job_key(family: str, command: Sequence[str]) -> str:
    if family == "ci":
        return f"release-ci-{command[1]}"
    target = Path(command[-1]).stem.replace("_", "-")
    return f"release-{family}-{target}"


def _run_managed_local_command(
    family: str,
    command: Sequence[str],
    *,
    repository: Path,
    run_key: str,
) -> None:
    env = os.environ.copy()
    env.update(
        {
            "CI_MANAGED_EXECUTION_MODE": "manual-local",
            "CI_RUN_KEY": run_key,
            "CI_JOB_KEY": _manual_job_key(family, command),
            "CI_RETENTION_CLASS": "release-verification",
            "CI_CLASSIFIER_REASON": "release-planner-selected-manual-local",
        }
    )
    if family == "ci":
        managed_command = [
            "bash",
            "tools/ci/run_local_ci.sh",
            "managed-validation-phase",
            command[1],
            command[2],
        ]
    else:
        managed_command = [
            "bash",
            "tools/ci/run_local_ci.sh",
            "managed-command",
            f"release-{family}",
            _manual_platform(family, command),
            *command,
        ]
    subprocess.run(
        _execution_command(managed_command),
        cwd=repository,
        env=env,
        check=True,
    )


def _aggregate_managed_local_run(*, repository: Path, run_key: str) -> None:
    env = os.environ.copy()
    env.update(
        {
            "CI_MANAGED_EXECUTION_MODE": "manual-local",
            "CI_RUN_KEY": run_key,
            "CI_RETENTION_CLASS": "release-verification",
        }
    )
    subprocess.run(
        _execution_command(
            ["bash", "tools/ci/run_local_ci.sh", "aggregate-managed-run"]
        ),
        cwd=repository,
        env=env,
        check=True,
    )


def _run_manual_local(
    *,
    repository: Path,
    head: str,
    payload: dict[str, object],
    plan_b64: str,
) -> tuple[RunEvidence, ...]:
    families = _selected_families(payload)
    if "ios" in families and sys.platform != "darwin":
        raise RuntimeError(
            "manual-local release validation requires macOS when iOS evidence is selected"
        )

    commands = _manual_local_commands(payload, plan_b64)
    empty_families = [family for family in families if not commands[family]]
    if empty_families:
        raise RuntimeError(
            "manual-local planner selected family without executable evidence: "
            + ", ".join(empty_families)
        )
    run_key = f"release-{head[:12]}-{int(time.time())}"
    evidence: list[RunEvidence] = []
    for family in families:
        started_at = _utc_now()
        for command in commands[family]:
            _run_managed_local_command(
                family,
                command,
                repository=repository,
                run_key=run_key,
            )
        finished_at = _utc_now()
        evidence.append(
            RunEvidence(
                family=family,
                run_id=None,
                head_sha=head,
                conclusion="success",
                url="",
                created_at=started_at,
                started_at=started_at,
                updated_at=finished_at,
                backend="manual-local",
                evidence_ref=run_key,
            )
        )
    _aggregate_managed_local_run(repository=repository, run_key=run_key)
    return tuple(evidence)


def run_release_validation(
    *,
    repository: Path,
    base: str,
    head: str,
    execution_mode: str,
) -> tuple[RunEvidence, ...]:
    if execution_mode not in {"github-hosted", "manual-local"}:
        raise ValueError(f"unsupported execution mode: {execution_mode}")

    branch = _current_branch(repository)
    _assert_candidate_identity(repository, branch, head)
    plan = plan_release_range(base, head, repository=repository)
    payload = plan_payload(plan)
    families = _selected_families(payload)
    if not families:
        raise RuntimeError("release planner selected no evidence families")

    if execution_mode == "manual-local":
        return _run_manual_local(
            repository=repository,
            head=head,
            payload=payload,
            plan_b64=encode_plan(plan),
        )

    previous_ids = {
        family: frozenset(
            int(item["databaseId"])
            for item in _listed_runs(family, repository=repository, branch=branch)
            if item.get("headSha") == head
        )
        for family in families
    }

    # Dispatch every independent family before locating or waiting for any one of them.
    for family in families:
        _dispatch_workflow(
            family,
            repository=repository,
            branch=branch,
            base=base,
            execution_mode=execution_mode,
        )

    run_ids = {
        family: _find_run_id(
            family,
            repository=repository,
            branch=branch,
            head=head,
            excluded_ids=previous_ids[family],
        )
        for family in families
    }
    with ThreadPoolExecutor(max_workers=len(run_ids)) as executor:
        futures = {
            family: executor.submit(
                _wait_for_run,
                family,
                run_id,
                repository=repository,
                head=head,
            )
            for family, run_id in run_ids.items()
        }
        return tuple(futures[family].result() for family in families)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Execute planner-selected exact-candidate release validation"
    )
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    parser.add_argument("--repository", type=Path, default=Path("."))
    parser.add_argument(
        "--execution-mode",
        choices=("github-hosted", "manual-local"),
        default="github-hosted",
    )
    args = parser.parse_args()

    evidence = run_release_validation(
        repository=args.repository.resolve(),
        base=args.base,
        head=args.head,
        execution_mode=args.execution_mode,
    )
    print(
        json.dumps(
            [item.__dict__ for item in evidence],
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
