from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any


SUPPORTED_SCHEMA_VERSION = 1
VALID_CI_EXECUTION_MODES = {"manual-local", "self-hosted", "github-hosted"}
VALID_ARTIFACT_STRATEGIES = {"managed-local"}
VALID_CAPABILITY_DISPOSITIONS = {"configured", "deferred", "not-applicable"}
VALID_ACTIONS_POLICIES = {"managed"}
VALID_BRANCH_PROTECTION = {
    "minimum-safety",
    "team-protected-main",
    "explicit-deferred",
}
VALID_FORK_PR_POLICIES = {"configured", "explicit-deferred", "not-applicable"}

_PRODUCT_KEY_RE = re.compile(r"^[a-z0-9](?:[a-z0-9_-]*[a-z0-9])?$")
_SECRET_VALUE_RE = re.compile(
    r"(?:secret|password|credential|private[ _-]?key|registration[ _-]?token)",
    re.IGNORECASE,
)

_TOP_LEVEL_FIELDS = {
    "schema_version",
    "ci_execution_mode",
    "artifact_store",
    "self_hosted_runner",
    "github",
    "observability_remote_acceptance",
}
_ARTIFACT_FIELDS = {"strategy", "product_key"}
_RUNNER_FIELDS = {"disposition"}
_GITHUB_FIELDS = {
    "actions_policy",
    "branch_protection",
    "fork_pr_policy",
}
_CAPABILITY_FIELDS = {"disposition"}


@dataclass(frozen=True)
class RepositoryInfrastructureIssue:
    code: str
    path: Path
    message: str

    def format(self, root: Path) -> str:
        try:
            display_path = self.path.relative_to(root)
        except ValueError:
            display_path = self.path
        return f"[{self.code}] {display_path}: {self.message}"


def check_repository_infrastructure(
    root: Path,
    manifest_path: Path | None = None,
) -> list[RepositoryInfrastructureIssue]:
    root = root.resolve()
    manifest = (manifest_path or root / "repository_infrastructure.json").resolve()
    if not manifest.is_file():
        return [
            RepositoryInfrastructureIssue(
                "missing-repository-infrastructure",
                manifest,
                "repository infrastructure manifest is required; infrastructure admission must fail closed",
            )
        ]

    try:
        payload = json.loads(manifest.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return [
            RepositoryInfrastructureIssue(
                "invalid-repository-infrastructure-json",
                manifest,
                f"unable to parse repository infrastructure JSON: {error}",
            )
        ]
    if not isinstance(payload, dict):
        return [
            RepositoryInfrastructureIssue(
                "invalid-repository-infrastructure-json",
                manifest,
                "repository infrastructure root must be a JSON object",
            )
        ]

    issues: list[RepositoryInfrastructureIssue] = []
    _check_fields(issues, manifest, payload, _TOP_LEVEL_FIELDS)
    _check_secret_values(issues, manifest, payload)

    schema_version = payload.get("schema_version")
    if (
        not isinstance(schema_version, int)
        or isinstance(schema_version, bool)
        or schema_version != SUPPORTED_SCHEMA_VERSION
    ):
        issues.append(
            RepositoryInfrastructureIssue(
                "unsupported-repository-infrastructure-schema",
                manifest,
                f"schema_version must be {SUPPORTED_SCHEMA_VERSION}",
            )
        )

    ci_mode = payload.get("ci_execution_mode")
    if ci_mode not in VALID_CI_EXECUTION_MODES:
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-ci-execution-mode",
                manifest,
                "ci_execution_mode must be manual-local, self-hosted, or github-hosted",
            )
        )

    artifact = _object_field(issues, manifest, payload, "artifact_store")
    _check_fields(issues, manifest, artifact, _ARTIFACT_FIELDS)
    if artifact.get("strategy") not in VALID_ARTIFACT_STRATEGIES:
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-artifact-store-strategy",
                manifest,
                "artifact_store.strategy must be managed-local",
            )
        )
    product_key = artifact.get("product_key")
    if not isinstance(product_key, str) or not _PRODUCT_KEY_RE.fullmatch(product_key):
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-product-key",
                manifest,
                "artifact_store.product_key must be an explicit safe repository-owned key",
            )
        )

    runner = _object_field(issues, manifest, payload, "self_hosted_runner")
    _check_fields(issues, manifest, runner, _RUNNER_FIELDS)
    runner_disposition = runner.get("disposition")
    if runner_disposition not in VALID_CAPABILITY_DISPOSITIONS:
        issues.append(_invalid_capability(manifest, "self_hosted_runner.disposition"))
    if ci_mode == "self-hosted" and runner_disposition != "configured":
        issues.append(
            RepositoryInfrastructureIssue(
                "self-hosted-runner-disposition-required",
                manifest,
                "self-hosted profile requires configured runner disposition",
            )
        )

    github = _object_field(issues, manifest, payload, "github")
    _check_fields(issues, manifest, github, _GITHUB_FIELDS)
    if github.get("actions_policy") not in VALID_ACTIONS_POLICIES:
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-actions-policy",
                manifest,
                "github.actions_policy must use a supported managed policy",
            )
        )
    branch_protection = github.get("branch_protection")
    if branch_protection not in VALID_BRANCH_PROTECTION:
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-branch-protection-disposition",
                manifest,
                "github.branch_protection has an unsupported disposition",
            )
        )
    fork_pr_policy = github.get("fork_pr_policy")
    if fork_pr_policy not in VALID_FORK_PR_POLICIES:
        issues.append(
            RepositoryInfrastructureIssue(
                "invalid-fork-pr-policy-disposition",
                manifest,
                "github.fork_pr_policy has an unsupported disposition",
            )
        )

    observability = _object_field(
        issues, manifest, payload, "observability_remote_acceptance"
    )
    _check_fields(issues, manifest, observability, _CAPABILITY_FIELDS)
    if observability.get("disposition") not in VALID_CAPABILITY_DISPOSITIONS:
        issues.append(
            _invalid_capability(
                manifest, "observability_remote_acceptance.disposition"
            )
        )

    repository_kind = _read_repository_kind(root)
    if repository_kind == "product" and ci_mode == "self-hosted" and runner_disposition != "configured":
        issues.append(
            RepositoryInfrastructureIssue(
                "product-required-infrastructure-unresolved",
                manifest,
                "product repository cannot finalize with unresolved selected self-hosted profile",
            )
        )

    return sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))


def read_product_key(root: Path, manifest_path: Path | None = None) -> str:
    root = root.resolve()
    issues = check_repository_infrastructure(root, manifest_path)
    if issues:
        raise ValueError("repository infrastructure manifest is invalid")
    manifest = (manifest_path or root / "repository_infrastructure.json").resolve()
    payload = json.loads(manifest.read_text(encoding="utf-8"))
    return payload["artifact_store"]["product_key"]


def _read_repository_kind(root: Path) -> str | None:
    path = root / "repository_identity.json"
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return None
    if not isinstance(payload, dict):
        return None
    kind = payload.get("repository_kind")
    return kind if isinstance(kind, str) else None


def _object_field(
    issues: list[RepositoryInfrastructureIssue],
    manifest: Path,
    payload: dict[str, Any],
    field: str,
) -> dict[str, Any]:
    value = payload.get(field)
    if isinstance(value, dict):
        return value
    issues.append(
        RepositoryInfrastructureIssue(
            "invalid-repository-infrastructure-field",
            manifest,
            f"{field} must be a JSON object",
        )
    )
    return {}


def _check_fields(
    issues: list[RepositoryInfrastructureIssue],
    manifest: Path,
    payload: dict[str, Any],
    expected: set[str],
) -> None:
    for field in sorted(set(payload) - expected):
        issues.append(
            RepositoryInfrastructureIssue(
                "forbidden-infrastructure-field",
                manifest,
                f"repository infrastructure must not persist field: {field}",
            )
        )


def _check_secret_values(
    issues: list[RepositoryInfrastructureIssue],
    manifest: Path,
    value: Any,
) -> None:
    if isinstance(value, dict):
        for nested in value.values():
            _check_secret_values(issues, manifest, nested)
        return
    if isinstance(value, list):
        for nested in value:
            _check_secret_values(issues, manifest, nested)
        return
    if isinstance(value, str) and _SECRET_VALUE_RE.search(value):
        issues.append(
            RepositoryInfrastructureIssue(
                "secret-like-infrastructure-value",
                manifest,
                "repository infrastructure manifest must not persist secret-like values",
            )
        )


def _invalid_capability(manifest: Path, field: str) -> RepositoryInfrastructureIssue:
    return RepositoryInfrastructureIssue(
        "invalid-capability-disposition",
        manifest,
        f"{field} must be configured, deferred, or not-applicable",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Verify repository infrastructure adoption state")
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--manifest", type=Path)
    arguments = parser.parse_args(argv)
    root = Path(arguments.root).resolve()
    issues = check_repository_infrastructure(root, arguments.manifest)
    for issue in issues:
        print(issue.format(root), file=sys.stderr)
    if issues:
        return 1
    print("Repository infrastructure check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
