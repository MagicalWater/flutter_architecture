from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path


class RepositoryInfrastructureContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self._temporary_directory = tempfile.TemporaryDirectory()
        self.addCleanup(self._temporary_directory.cleanup)
        self.root = Path(self._temporary_directory.name)
        (self.root / "VERSION").write_text("1.18.0\n", encoding="utf-8")
        self._write_identity("template")

    def test_missing_manifest_fails_closed(self) -> None:
        issues = self._check()
        self.assertIn("missing-repository-infrastructure", self._codes(issues))

    def test_malformed_and_unknown_schema_fail_closed(self) -> None:
        manifest = self.root / "repository_infrastructure.json"
        manifest.write_text("{not-json", encoding="utf-8")
        self.assertIn(
            "invalid-repository-infrastructure-json",
            self._codes(self._check()),
        )

        self._write_manifest(schema_version=999)
        self.assertIn(
            "unsupported-repository-infrastructure-schema",
            self._codes(self._check()),
        )

    def test_unknown_ci_mode_artifact_strategy_and_dispositions_fail_closed(self) -> None:
        self._write_manifest(
            ci_execution_mode="mystery",
            artifact_strategy="mystery-store",
            runner_disposition="mystery",
            branch_protection="mystery",
            fork_pr_policy="mystery",
            observability_disposition="mystery",
        )
        codes = self._codes(self._check())
        self.assertIn("invalid-ci-execution-mode", codes)
        self.assertIn("invalid-artifact-store-strategy", codes)
        self.assertIn("invalid-capability-disposition", codes)
        self.assertIn("invalid-branch-protection-disposition", codes)
        self.assertIn("invalid-fork-pr-policy-disposition", codes)

    def test_product_key_is_explicit_safe_and_stable(self) -> None:
        for product_key in ("", "../escape", "C:/absolute", "space key", ".hidden"):
            with self.subTest(product_key=product_key):
                self._write_manifest(product_key=product_key)
                self.assertIn("invalid-product-key", self._codes(self._check()))

        self._write_manifest(product_key="pickup-basketball")
        self.assertNotIn("invalid-product-key", self._codes(self._check()))

    def test_manifest_rejects_secret_shaped_keys_and_values(self) -> None:
        payload = self._manifest_payload()
        payload["runner_token"] = "synthetic-secret-placeholder"
        self._write_payload(payload)
        self.assertIn("forbidden-infrastructure-field", self._codes(self._check()))

        payload = self._manifest_payload()
        payload["github"]["actions_policy"] = "synthetic-secret-placeholder"
        self._write_payload(payload)
        self.assertIn("secret-like-infrastructure-value", self._codes(self._check()))

    def test_self_hosted_profile_requires_runner_disposition(self) -> None:
        self._write_manifest(
            ci_execution_mode="self-hosted",
            runner_disposition="not-applicable",
        )
        self.assertIn(
            "self-hosted-runner-disposition-required",
            self._codes(self._check()),
        )

    def test_product_repository_cannot_keep_unresolved_required_profile_state(self) -> None:
        self._write_identity("product")
        self._write_manifest(
            ci_execution_mode="manual-local",
            branch_protection="explicit-deferred",
            fork_pr_policy="explicit-deferred",
        )
        codes = self._codes(self._check())
        self.assertIn("product-required-infrastructure-unresolved", codes)

    def test_template_repository_accepts_canonical_template_defaults(self) -> None:
        self._write_manifest()
        self.assertEqual(self._check(), [])

    def test_manifest_rejects_absolute_paths_tokens_and_numeric_live_object_ids(self) -> None:
        forbidden_payloads = []

        absolute_path = self._manifest_payload()
        absolute_path["artifact_store"]["root"] = "C:/operator/ci-artifacts"
        forbidden_payloads.append(absolute_path)

        runner_token = self._manifest_payload()
        runner_token["self_hosted_runner"]["registration_token"] = "runner-secret"
        forbidden_payloads.append(runner_token)

        github_id = self._manifest_payload()
        github_id["github"]["environment_id"] = 12345
        forbidden_payloads.append(github_id)

        for payload in forbidden_payloads:
            with self.subTest(payload=payload):
                self._write_payload(payload)
                self.assertIn(
                    "forbidden-infrastructure-field",
                    self._codes(self._check()),
                )

    def _check(self):
        try:
            from tools.docs.verify_repository_infrastructure import (
                check_repository_infrastructure,
            )
        except ModuleNotFoundError as error:
            self.fail(
                "RED: repository infrastructure verifier does not exist yet: "
                f"{error}"
            )
        return check_repository_infrastructure(self.root)

    def _write_identity(self, repository_kind: str) -> None:
        is_product = repository_kind == "product"
        payload = {
            "schema_version": 1,
            "repository_kind": repository_kind,
            "product_name": "Pickup Basketball" if is_product else None,
            "template_origin": {
                "repository": "MagicalWater/flutter_architecture",
                "baseline": "1.18.0",
            },
        }
        (self.root / "repository_identity.json").write_text(
            json.dumps(payload), encoding="utf-8"
        )
        if is_product:
            (self.root / "VERSION").write_text("0.1.0\n", encoding="utf-8")

    def _write_manifest(self, **overrides: object) -> None:
        payload = self._manifest_payload()
        payload["schema_version"] = overrides.get("schema_version", 1)
        payload["ci_execution_mode"] = overrides.get(
            "ci_execution_mode", "self-hosted"
        )
        payload["artifact_store"]["strategy"] = overrides.get(
            "artifact_strategy", "managed-local"
        )
        payload["artifact_store"]["product_key"] = overrides.get(
            "product_key", "flutter_architecture"
        )
        payload["self_hosted_runner"]["disposition"] = overrides.get(
            "runner_disposition", "configured"
        )
        payload["github"]["branch_protection"] = overrides.get(
            "branch_protection", "minimum-safety"
        )
        payload["github"]["fork_pr_policy"] = overrides.get(
            "fork_pr_policy", "configured"
        )
        payload["observability_remote_acceptance"]["disposition"] = overrides.get(
            "observability_disposition", "deferred"
        )
        self._write_payload(payload)

    def _manifest_payload(self) -> dict[str, object]:
        return {
            "schema_version": 1,
            "ci_execution_mode": "self-hosted",
            "artifact_store": {
                "strategy": "managed-local",
                "product_key": "flutter_architecture",
            },
            "self_hosted_runner": {"disposition": "configured"},
            "github": {
                "actions_policy": "managed",
                "branch_protection": "minimum-safety",
                "fork_pr_policy": "configured",
            },
            "observability_remote_acceptance": {"disposition": "deferred"},
        }

    def _write_payload(self, payload: dict[str, object]) -> None:
        (self.root / "repository_infrastructure.json").write_text(
            json.dumps(payload), encoding="utf-8"
        )

    @staticmethod
    def _codes(issues) -> set[str]:
        return {issue.code for issue in issues}


if __name__ == "__main__":
    unittest.main()
