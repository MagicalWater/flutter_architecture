from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from typing import Any, Protocol
from urllib.parse import quote


VALID_CI_EXECUTION_MODES = {"manual-local", "self-hosted", "github-hosted"}
_REPOSITORY_RE = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
_HTTP_STATUS_RE = re.compile(r"HTTP\s+(\d{3})", re.IGNORECASE)


class RepositoryInfrastructureError(RuntimeError):
    pass


class GitHubApiError(RepositoryInfrastructureError):
    def __init__(self, status: int | None, message: str) -> None:
        self.status = status
        super().__init__(message)


class ReadBackMismatchError(RepositoryInfrastructureError):
    pass


class Transport(Protocol):
    def request(
        self,
        method: str,
        path: str,
        *,
        body: dict[str, object] | None = None,
    ) -> object: ...


@dataclass(frozen=True)
class GhApiTransport:
    executable: str = "gh"

    def request(
        self,
        method: str,
        path: str,
        *,
        body: dict[str, object] | None = None,
    ) -> object:
        command = [
            self.executable,
            "api",
            "--method",
            method,
            "-H",
            "Accept: application/vnd.github+json",
            "-H",
            "X-GitHub-Api-Version: 2026-03-10",
            path,
        ]
        stdin = None
        if body is not None:
            command.extend(["--input", "-"])
            stdin = json.dumps(body, separators=(",", ":"), sort_keys=True)
        completed = subprocess.run(
            command,
            input=stdin,
            capture_output=True,
            text=True,
            check=False,
        )
        if completed.returncode != 0:
            diagnostic = (completed.stderr or completed.stdout).strip()
            match = _HTTP_STATUS_RE.search(diagnostic)
            status = int(match.group(1)) if match else None
            raise GitHubApiError(status, diagnostic or "GitHub API request failed")
        output = completed.stdout.strip()
        if not output:
            return {}
        try:
            return json.loads(output)
        except json.JSONDecodeError as error:
            raise GitHubApiError(None, f"GitHub API returned invalid JSON: {error}") from error


class RepositoryInfrastructureManager:
    def __init__(self, transport: Transport) -> None:
        self._transport = transport

    def snapshot(
        self,
        repository: str,
        *,
        environments: dict[str, set[str]] | None = None,
    ) -> dict[str, object]:
        owner, repo = _split_repository(repository)
        prefix = f"/repos/{owner}/{repo}"

        repository_payload = _object(self._transport.request("GET", prefix), "repository")
        default_branch = _string(repository_payload.get("default_branch"))
        if default_branch is None:
            raise RepositoryInfrastructureError("repository default_branch is missing")

        variable = self._read_optional(
            "GET", f"{prefix}/actions/variables/CI_EXECUTION_MODE"
        )
        actions = _object(
            self._transport.request("GET", f"{prefix}/actions/permissions"),
            "actions permissions",
        )
        workflow_permissions = _object(
            self._transport.request("GET", f"{prefix}/actions/permissions/workflow"),
            "workflow permissions",
        )
        fork_approval = self._read_optional(
            "GET", f"{prefix}/actions/permissions/fork-pr-contributor-approval"
        )
        protection = self._read_optional(
            "GET", f"{prefix}/branches/{quote(default_branch, safe='')}/protection"
        )
        runners = _object(
            self._transport.request("GET", f"{prefix}/actions/runners?per_page=100"),
            "repository runners",
        )

        return {
            "repository": {
                "visibility": _string(repository_payload.get("visibility")),
                "default_branch": default_branch,
            },
            "ci_execution_mode": _variable_value(variable),
            "actions": {
                "enabled": _bool_or_none(actions.get("enabled")),
                "allowed_actions": _string(actions.get("allowed_actions")),
                "default_workflow_permissions": _string(
                    workflow_permissions.get("default_workflow_permissions")
                ),
                "can_approve_pull_request_reviews": _bool_or_none(
                    workflow_permissions.get("can_approve_pull_request_reviews")
                ),
            },
            "fork_pr_contributor_approval": _optional_string_field(
                fork_approval, "approval_policy"
            ),
            "branch_protection": _branch_protection_snapshot(protection),
            "runners": _runner_snapshots(runners),
            "environments": self._environment_snapshots(prefix, environments or {}),
        }

    def set_ci_execution_mode(
        self,
        repository: str,
        mode: str,
    ) -> dict[str, str | None]:
        if mode not in VALID_CI_EXECUTION_MODES:
            raise ValueError("unsupported CI execution mode")
        owner, repo = _split_repository(repository)
        prefix = f"/repos/{owner}/{repo}"
        variable_path = f"{prefix}/actions/variables/CI_EXECUTION_MODE"
        before_payload = self._read_optional("GET", variable_path)
        before = _variable_value(before_payload)

        if before_payload is None:
            self._transport.request(
                "POST",
                f"{prefix}/actions/variables",
                body={"name": "CI_EXECUTION_MODE", "value": mode},
            )
        else:
            self._transport.request("PATCH", variable_path, body={"value": mode})

        after = _variable_value(self._read_optional("GET", variable_path))
        if after != mode:
            raise ReadBackMismatchError(
                f"CI_EXECUTION_MODE read-back mismatch: expected {mode!r}, got {after!r}"
            )
        return {"before": before, "after": after}

    def _read_optional(self, method: str, path: str) -> dict[str, Any] | None:
        try:
            return _object(self._transport.request(method, path), path)
        except GitHubApiError as error:
            if error.status == 404:
                return None
            raise

    def _environment_snapshots(
        self,
        prefix: str,
        environments: dict[str, set[str]],
    ) -> dict[str, object]:
        snapshots: dict[str, object] = {}
        for name in sorted(environments):
            encoded = quote(name, safe="")
            environment = self._read_optional("GET", f"{prefix}/environments/{encoded}")
            if environment is None:
                snapshots[name] = {
                    "exists": False,
                    "secret_names": [],
                    "missing_secret_names": sorted(environments[name]),
                }
                continue
            secrets_payload = _object(
                self._transport.request(
                    "GET", f"{prefix}/environments/{encoded}/secrets?per_page=100"
                ),
                f"environment secrets: {name}",
            )
            secret_names = sorted(
                {
                    secret_name
                    for item in _list(secrets_payload.get("secrets"))
                    if isinstance(item, dict)
                    if (secret_name := _string(item.get("name"))) is not None
                }
            )
            snapshots[name] = {
                "exists": True,
                "secret_names": secret_names,
                "missing_secret_names": sorted(environments[name] - set(secret_names)),
            }
        return snapshots


def _split_repository(repository: str) -> tuple[str, str]:
    if not _REPOSITORY_RE.fullmatch(repository):
        raise ValueError("repository must use owner/name format")
    owner, repo = repository.split("/", 1)
    return owner, repo


def _object(value: object, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise RepositoryInfrastructureError(f"{label} response must be a JSON object")
    return value


def _list(value: object) -> list[object]:
    return value if isinstance(value, list) else []


def _string(value: object) -> str | None:
    return value if isinstance(value, str) and value else None


def _bool_or_none(value: object) -> bool | None:
    return value if isinstance(value, bool) else None


def _variable_value(payload: dict[str, Any] | None) -> str | None:
    if payload is None:
        return None
    return _string(payload.get("value"))


def _optional_string_field(payload: dict[str, Any] | None, key: str) -> str | None:
    return None if payload is None else _string(payload.get(key))


def _branch_protection_snapshot(payload: dict[str, Any] | None) -> dict[str, object]:
    if payload is None:
        return {"present": False}
    required_status_checks = payload.get("required_status_checks")
    checks: list[str] = []
    strict: bool | None = None
    if isinstance(required_status_checks, dict):
        strict = _bool_or_none(required_status_checks.get("strict"))
        checks = sorted(
            {
                name
                for name in (
                    _string(item.get("context"))
                    for item in _list(required_status_checks.get("checks"))
                    if isinstance(item, dict)
                )
                if name is not None
            }
            | {
                name
                for name in (
                    _string(item)
                    for item in _list(required_status_checks.get("contexts"))
                )
                if name is not None
            }
        )
    reviews = payload.get("required_pull_request_reviews")
    approvals = None
    if isinstance(reviews, dict):
        raw = reviews.get("required_approving_review_count")
        approvals = raw if isinstance(raw, int) and not isinstance(raw, bool) else None
    return {
        "present": True,
        "strict_required_checks": strict,
        "required_checks": checks,
        "enforce_admins": _nested_enabled(payload.get("enforce_admins")),
        "required_approving_review_count": approvals,
        "required_conversation_resolution": _nested_enabled(
            payload.get("required_conversation_resolution")
        ),
        "allow_force_pushes": _nested_enabled(payload.get("allow_force_pushes")),
        "allow_deletions": _nested_enabled(payload.get("allow_deletions")),
    }


def _nested_enabled(value: object) -> bool | None:
    return _bool_or_none(value.get("enabled")) if isinstance(value, dict) else None


def _runner_snapshots(payload: dict[str, Any]) -> list[dict[str, object]]:
    snapshots: list[dict[str, object]] = []
    for runner in _list(payload.get("runners")):
        if not isinstance(runner, dict):
            continue
        labels = sorted(
            {
                name
                for item in _list(runner.get("labels"))
                if isinstance(item, dict)
                if (name := _string(item.get("name"))) is not None
            }
        )
        snapshots.append(
            {
                "name": _string(runner.get("name")),
                "os": _string(runner.get("os")),
                "status": _string(runner.get("status")),
                "busy": _bool_or_none(runner.get("busy")),
                "labels": labels,
            }
        )
    return sorted(snapshots, key=lambda item: str(item.get("name")))


def _parse_environment(value: str) -> tuple[str, set[str]]:
    name, separator, secrets = value.partition(":")
    if not name:
        raise ValueError("environment name is required")
    required = {item for item in secrets.split(",") if item} if separator else set()
    return name, required


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Read back or safely update product repository GitHub infrastructure."
    )
    parser.add_argument("--repository", required=True, help="GitHub repository as owner/name")
    subparsers = parser.add_subparsers(dest="command", required=True)

    snapshot = subparsers.add_parser("snapshot", help="Read sanitized live repository state")
    snapshot.add_argument(
        "--environment",
        action="append",
        default=[],
        metavar="NAME[:SECRET1,SECRET2]",
        help="Read environment existence and required secret names only",
    )

    set_mode = subparsers.add_parser(
        "set-ci-execution-mode",
        help="Set CI_EXECUTION_MODE and fail closed unless fresh read-back matches",
    )
    set_mode.add_argument("--mode", required=True, choices=sorted(VALID_CI_EXECUTION_MODES))
    return parser


def main(argv: list[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    manager = RepositoryInfrastructureManager(GhApiTransport())
    try:
        if args.command == "snapshot":
            environment_map = dict(_parse_environment(value) for value in args.environment)
            result = manager.snapshot(args.repository, environments=environment_map)
        else:
            result = manager.set_ci_execution_mode(args.repository, args.mode)
    except (RepositoryInfrastructureError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
