from __future__ import annotations

import json
import unittest

from tools.ci.repository_infrastructure import (
    GitHubApiError,
    ReadBackMismatchError,
    RepositoryInfrastructureManager,
)


REPOSITORY = "MagicalWater/example-product"


class FakeTransport:
    def __init__(self, responses: dict[tuple[str, str], object]) -> None:
        self.responses = responses
        self.calls: list[tuple[str, str, dict[str, object] | None]] = []

    def request(
        self,
        method: str,
        path: str,
        *,
        body: dict[str, object] | None = None,
    ) -> object:
        self.calls.append((method, path, body))
        value = self.responses.get((method, path))
        if isinstance(value, Exception):
            raise value
        if value is None:
            raise AssertionError(f"unexpected request: {method} {path}")
        if isinstance(value, list) and value and callable(value[0]):
            callback = value.pop(0)
            return callback(body)
        return value


class RepositoryInfrastructureSnapshotTest(unittest.TestCase):
    def test_snapshot_contains_required_live_state_without_numeric_ids_or_secret_values(self) -> None:
        transport = FakeTransport(_snapshot_responses())
        manager = RepositoryInfrastructureManager(transport)

        snapshot = manager.snapshot(
            REPOSITORY,
            environments={
                "staging-observability": {
                    "OBSERVABILITY_SERVICE_ACCOUNT_JSON",
                    "OBSERVABILITY_PROVIDER_CONFIG_JSON",
                }
            },
        )

        self.assertEqual(snapshot["repository"]["visibility"], "public")
        self.assertEqual(snapshot["repository"]["default_branch"], "main")
        self.assertEqual(snapshot["ci_execution_mode"], "self-hosted")
        self.assertEqual(
            snapshot["actions"]["default_workflow_permissions"], "read"
        )
        self.assertFalse(snapshot["actions"]["can_approve_pull_request_reviews"])
        self.assertEqual(
            snapshot["fork_pr_contributor_approval"], "first_time_contributors"
        )
        self.assertEqual(snapshot["branch_protection"]["required_checks"], ["CI / Tests"])
        self.assertEqual(snapshot["runners"][0]["status"], "online")
        self.assertEqual(
            snapshot["environments"]["staging-observability"]["secret_names"],
            [
                "OBSERVABILITY_PROVIDER_CONFIG_JSON",
                "OBSERVABILITY_SERVICE_ACCOUNT_JSON",
            ],
        )

        rendered = json.dumps(snapshot, sort_keys=True)
        self.assertNotIn("runner-id-should-not-leak", rendered)
        self.assertNotIn("secret-value-should-never-exist", rendered)
        self.assertNotIn('"id"', rendered)

    def test_optional_404_state_is_reported_as_absent_not_configured(self) -> None:
        responses = _snapshot_responses()
        responses[("GET", "/repos/MagicalWater/example-product/actions/variables/CI_EXECUTION_MODE")] = GitHubApiError(404, "not found")
        responses[("GET", "/repos/MagicalWater/example-product/branches/main/protection")] = GitHubApiError(404, "not found")
        manager = RepositoryInfrastructureManager(FakeTransport(responses))

        snapshot = manager.snapshot(REPOSITORY)

        self.assertIsNone(snapshot["ci_execution_mode"])
        self.assertEqual(snapshot["branch_protection"], {"present": False})

    def test_private_repository_unsupported_fork_approval_is_reported_as_not_available(self) -> None:
        responses = _snapshot_responses()
        responses[("GET", "/repos/MagicalWater/example-product")] = {
            "visibility": "private",
            "default_branch": "main",
        }
        responses[("GET", "/repos/MagicalWater/example-product/actions/permissions/fork-pr-contributor-approval")] = GitHubApiError(
            422,
            "Fork PR approval is not allowed for private repositories",
        )
        manager = RepositoryInfrastructureManager(FakeTransport(responses))

        snapshot = manager.snapshot(REPOSITORY)

        self.assertEqual(snapshot["repository"]["visibility"], "private")
        self.assertIsNone(snapshot["fork_pr_contributor_approval"])


class RepositoryInfrastructureMutationTest(unittest.TestCase):
    def test_ci_execution_mode_update_records_before_and_fresh_read_back(self) -> None:
        path = "/repos/MagicalWater/example-product/actions/variables/CI_EXECUTION_MODE"
        transport = FakeTransport(
            {
                ("GET", path): [
                    lambda _: {"name": "CI_EXECUTION_MODE", "value": "manual-local"},
                    lambda _: {"name": "CI_EXECUTION_MODE", "value": "github-hosted"},
                ],
                ("PATCH", path): lambda body: {},
            }
        )
        manager = RepositoryInfrastructureManager(transport)

        result = manager.set_ci_execution_mode(REPOSITORY, "github-hosted")

        self.assertEqual(result, {"before": "manual-local", "after": "github-hosted"})
        self.assertIn(("PATCH", path, {"value": "github-hosted"}), transport.calls)

    def test_ci_execution_mode_create_is_read_back(self) -> None:
        variable_path = "/repos/MagicalWater/example-product/actions/variables/CI_EXECUTION_MODE"
        collection_path = "/repos/MagicalWater/example-product/actions/variables"
        transport = FakeTransport(
            {
                ("GET", variable_path): [
                    lambda _: (_raise(GitHubApiError(404, "not found"))),
                    lambda _: {"name": "CI_EXECUTION_MODE", "value": "manual-local"},
                ],
                ("POST", collection_path): lambda body: {},
            }
        )
        manager = RepositoryInfrastructureManager(transport)

        result = manager.set_ci_execution_mode(REPOSITORY, "manual-local")

        self.assertEqual(result, {"before": None, "after": "manual-local"})
        self.assertIn(
            (
                "POST",
                collection_path,
                {"name": "CI_EXECUTION_MODE", "value": "manual-local"},
            ),
            transport.calls,
        )

    def test_unknown_ci_mode_is_rejected_before_mutation(self) -> None:
        transport = FakeTransport({})
        manager = RepositoryInfrastructureManager(transport)

        with self.assertRaisesRegex(ValueError, "unsupported CI execution mode"):
            manager.set_ci_execution_mode(REPOSITORY, "local")

        self.assertEqual(transport.calls, [])

    def test_read_back_mismatch_fails_closed(self) -> None:
        path = "/repos/MagicalWater/example-product/actions/variables/CI_EXECUTION_MODE"
        transport = FakeTransport(
            {
                ("GET", path): [
                    lambda _: {"name": "CI_EXECUTION_MODE", "value": "manual-local"},
                    lambda _: {"name": "CI_EXECUTION_MODE", "value": "manual-local"},
                ],
                ("PATCH", path): lambda body: {},
            }
        )
        manager = RepositoryInfrastructureManager(transport)

        with self.assertRaises(ReadBackMismatchError):
            manager.set_ci_execution_mode(REPOSITORY, "self-hosted")


def _raise(error: Exception) -> object:
    raise error


def _snapshot_responses() -> dict[tuple[str, str], object]:
    prefix = "/repos/MagicalWater/example-product"
    return {
        ("GET", prefix): {
            "visibility": "public",
            "default_branch": "main",
            "id": 123,
        },
        ("GET", f"{prefix}/actions/variables/CI_EXECUTION_MODE"): {
            "name": "CI_EXECUTION_MODE",
            "value": "self-hosted",
        },
        ("GET", f"{prefix}/actions/permissions"): {
            "enabled": True,
            "allowed_actions": "selected",
            "selected_actions_url": "https://api.github.com/example",
        },
        ("GET", f"{prefix}/actions/permissions/workflow"): {
            "default_workflow_permissions": "read",
            "can_approve_pull_request_reviews": False,
        },
        ("GET", f"{prefix}/actions/permissions/fork-pr-contributor-approval"): {
            "approval_policy": "first_time_contributors"
        },
        ("GET", f"{prefix}/branches/main/protection"): {
            "required_status_checks": {
                "strict": False,
                "contexts": ["CI / Tests"],
            },
            "enforce_admins": {"enabled": False},
            "required_pull_request_reviews": {
                "required_approving_review_count": 1,
            },
            "required_conversation_resolution": {"enabled": True},
            "allow_force_pushes": {"enabled": False},
            "allow_deletions": {"enabled": False},
            "url": "https://api.github.com/secret-ish-url",
        },
        ("GET", f"{prefix}/actions/runners?per_page=100"): {
            "total_count": 1,
            "runners": [
                {
                    "id": "runner-id-should-not-leak",
                    "name": "product-mac",
                    "os": "macos",
                    "status": "online",
                    "busy": False,
                    "labels": [
                        {"id": 1, "name": "self-hosted"},
                        {"id": 2, "name": "ARM64"},
                        {"id": 3, "name": "trusted-main"},
                    ],
                }
            ],
        },
        ("GET", f"{prefix}/environments/staging-observability"): {
            "name": "staging-observability",
            "id": 456,
        },
        ("GET", f"{prefix}/environments/staging-observability/secrets?per_page=100"): {
            "total_count": 2,
            "secrets": [
                {"name": "OBSERVABILITY_SERVICE_ACCOUNT_JSON", "updated_at": "x"},
                {"name": "OBSERVABILITY_PROVIDER_CONFIG_JSON", "updated_at": "y"},
            ],
            "secret-value-should-never-exist": "must-not-copy",
        },
    }


if __name__ == "__main__":
    unittest.main()
