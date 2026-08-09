from pathlib import Path
import tempfile
import unittest

from tools.ci.artifact_transport import (
    FAILURE_ONLY_MAX_BYTES,
    collect_remote_upload_entries,
    resolve_artifact_transport,
)


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = tuple(
    ROOT / ".github/workflows" / name
    for name in (
        "ci.yml",
        "android.yml",
        "ios.yml",
        "observability-acceptance.yml",
    )
)


class ArtifactTransportPolicyTest(unittest.TestCase):
    def test_repository_default_and_non_manual_events_resolve_to_none(self) -> None:
        for event_name in ("push", "pull_request"):
            for requested in ("repository-default", "none", "failure-only", "full"):
                self.assertEqual(resolve_artifact_transport(event_name, requested), "none")

        self.assertEqual(
            resolve_artifact_transport("workflow_dispatch", "repository-default"),
            "none",
        )
        self.assertEqual(
            resolve_artifact_transport("workflow_dispatch", "none"),
            "none",
        )

    def test_manual_dispatch_accepts_only_explicit_bounded_transports(self) -> None:
        self.assertEqual(
            resolve_artifact_transport("workflow_dispatch", "failure-only"),
            "failure-only",
        )
        self.assertEqual(
            resolve_artifact_transport("workflow_dispatch", "full"),
            "full",
        )
        for requested in ("", "artifact", "default", "github"):
            with self.assertRaisesRegex(ValueError, "artifact transport"):
                resolve_artifact_transport("workflow_dispatch", requested)

    def test_failure_only_accepts_bounded_text_and_selected_golden_images(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for relative_path in (
                "logs/build.log",
                "summary/result.txt",
                "manifest/summary.json",
                "golden/master.png",
                "golden/test.png",
                "golden/diff.png",
            ):
                path = root / relative_path
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b"safe")

            entries = collect_remote_upload_entries(
                [root],
                "failure-only",
            )

        self.assertEqual(len(entries), 6)
        self.assertLess(sum(entry.size_bytes for entry in entries), FAILURE_ONLY_MAX_BYTES)

    def test_failure_only_rejects_platform_binary_symbols_mapping_and_provider_config(self) -> None:
        rejected = (
            "app.apk",
            "Runner.app/Runner",
            "Runner.app.dSYM/Contents/Resources/DWARF/Runner",
            "app.symbols",
            "mapping.txt",
            "google-services.json",
            "GoogleService-Info.plist",
            "firebase-service-account.json",
        )
        for relative_path in rejected:
            with self.subTest(relative_path=relative_path):
                with tempfile.TemporaryDirectory() as directory:
                    root = Path(directory)
                    path = root / relative_path
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_bytes(b"unsafe")
                    with self.assertRaises(ValueError):
                        collect_remote_upload_entries([root], "failure-only")

    def test_failure_only_enforces_25_mib_total_preflight(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "logs" / "oversized.log"
            path.parent.mkdir(parents=True)
            path.write_bytes(b"x" * (FAILURE_ONLY_MAX_BYTES + 1))
            with self.assertRaisesRegex(ValueError, "25 MiB"):
                collect_remote_upload_entries([root], "failure-only")

    def test_full_transport_still_rejects_provider_config_and_signing_material(self) -> None:
        rejected = (
            "google-services.json",
            "GoogleService-Info.plist",
            "firebase-service-account.json",
            "release.keystore",
            "auth-key.p8",
            "distribution.mobileprovision",
            ".env",
        )
        for relative_path in rejected:
            with self.subTest(relative_path=relative_path):
                with tempfile.TemporaryDirectory() as directory:
                    path = Path(directory) / relative_path
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_bytes(b"sensitive")
                    with self.assertRaises(ValueError):
                        collect_remote_upload_entries([path], "full")

    def test_full_transport_requires_at_least_one_existing_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            missing = Path(directory) / "missing-artifact"
            with self.assertRaisesRegex(ValueError, "no files"):
                collect_remote_upload_entries([missing], "full")

    def test_remote_diagnostics_secret_scan_blocks_without_echo(self) -> None:
        secret = "-----BEGIN PRIVATE KEY-----"
        with tempfile.TemporaryDirectory() as directory:
            diagnostic = Path(directory) / "build.log"
            diagnostic.write_text(secret, encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "secret leakage") as caught:
                collect_remote_upload_entries([diagnostic], "failure-only")

        self.assertNotIn(secret, str(caught.exception))


class ArtifactWorkflowContractTest(unittest.TestCase):
    def test_all_workflows_expose_the_same_artifact_transport_choice(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertIn("artifact_transport:", text, workflow.name)
            self.assertIn("default: repository-default", text, workflow.name)
            for value in ("repository-default", "none", "failure-only", "full"):
                self.assertIn(value, text, workflow.name)

    def test_workflows_do_not_use_github_actions_cache(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertNotIn("actions/cache@", text, workflow.name)

    def test_self_hosted_jobs_use_external_managed_store_and_local_only_summary(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertIn("vars.CI_ARTIFACT_ROOT", text, workflow.name)
            self.assertIn("CI_MANAGED_EXECUTION_MODE: self-hosted", text, workflow.name)
            self.assertIn("managed-command", text, workflow.name)
            self.assertIn("gh-${{ github.run_id }}-${{ github.run_attempt }}", text, workflow.name)
            self.assertIn("GITHUB_STEP_SUMMARY", text, workflow.name)
            self.assertIn("Local-only evidence; not downloadable from GitHub.", text, workflow.name)

    def test_self_hosted_run_aggregation_happens_after_managed_jobs(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertIn("aggregate-managed-run", text, workflow.name)
            self.assertIn("always()", text, workflow.name)
            self.assertIn("needs:", text, workflow.name)

    def test_managed_shell_blocks_preserve_multiline_commands_and_artifact_root(self) -> None:
        workflow_dir = ROOT / ".github/workflows"
        ci = (workflow_dir / "ci.yml").read_text(encoding="utf-8")
        observability = (
            workflow_dir / "observability-acceptance.yml"
        ).read_text(encoding="utf-8")

        self.assertIn("tools/ci/validation_runner.py --phase quality", ci)
        self.assertIn("tools/ci/validation_planner.py", ci)
        self.assertGreaterEqual(
            observability.count('managed_artifact_dir="$ARTIFACT_DIR"'),
            2,
        )
        self.assertIn(
            'ARTIFACT_DIR="$managed_artifact_dir/android-staging" ' + "\\",
            observability,
        )
        self.assertIn(
            'ARTIFACT_DIR="$managed_artifact_dir/ios-staging" ' + "\\",
            observability,
        )
        self.assertIn(
            "python3 tools/ci/write_observability_acceptance_evidence.py " + "\\",
            observability,
        )

    def test_every_remote_upload_is_manual_github_hosted_and_explicit(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            cursor = 0
            while True:
                index = text.find("actions/upload-artifact@", cursor)
                if index < 0:
                    break
                prefix = text[max(0, index - 900) : index]
                self.assertIn("github.event_name == 'workflow_dispatch'", prefix, workflow.name)
                self.assertIn("runner.environment == 'github-hosted'", prefix, workflow.name)
                self.assertIn("inputs.artifact_transport", prefix, workflow.name)
                self.assertIn("artifact_transport.py preflight", prefix, workflow.name)
                cursor = index + 1

    def test_full_transport_is_one_day_and_emits_storage_warning(self) -> None:
        combined = "\n".join(path.read_text(encoding="utf-8") for path in WORKFLOWS)
        self.assertIn("GitHub storage warning", combined)
        self.assertIn("retention-days: 1", combined)
        self.assertNotIn("retention-days: 14", combined)


if __name__ == "__main__":
    unittest.main()
