from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence

if __package__ in {None, ""}:
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.ci.validation_planner import plan_payload, plan_release_range


_WORKFLOWS = {
    "ci": ".github/workflows/ci.yml",
    "android": ".github/workflows/android.yml",
    "ios": ".github/workflows/ios.yml",
}


@dataclass(frozen=True)
class RunEvidence:
    family: str
    run_id: int
    head_sha: str
    conclusion: str
    url: str
    created_at: str
    started_at: str
    updated_at: str


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


def run_release_validation(
    *,
    repository: Path,
    base: str,
    head: str,
    execution_mode: str,
) -> tuple[RunEvidence, ...]:
    if execution_mode != "github-hosted":
        raise ValueError("first implementation supports only github-hosted execution")

    branch = _current_branch(repository)
    _assert_candidate_identity(repository, branch, head)
    payload = plan_payload(plan_release_range(base, head, repository=repository))
    families = _selected_families(payload)
    if not families:
        raise RuntimeError("release planner selected no evidence families")

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
        description="Fan out planner-selected exact-candidate release validation"
    )
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    parser.add_argument("--repository", type=Path, default=Path("."))
    parser.add_argument(
        "--execution-mode",
        choices=("github-hosted",),
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
