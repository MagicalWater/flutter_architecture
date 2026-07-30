from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]


class ObservabilityAcceptanceWorkflowTest(unittest.TestCase):
    def test_repository_quality_gates_observability_contracts(self) -> None:
        ci = (ROOT / ".github/workflows/ci.yml").read_text()
        ios = (ROOT / ".github/workflows/ios.yml").read_text()
        observability = (
            ROOT / ".github/workflows/observability-acceptance.yml"
        ).read_text()

        required_modules = (
            "tools.ci.test_secret_leakage",
            "tools.ci.test_observability_acceptance_workflow",
            "tools.ci.test_android_observability_contract",
            "tools.ci.test_ios_observability_contract",
            "tools.ci.test_artifact_store",
            "tools.ci.test_ci_secret_cleanup_contract",
        )
        for module in required_modules:
            self.assertIn(module, ci, module)

        self.assertIn("tools.ci.test_secret_leakage", ios)
        self.assertIn("tools.ci.test_ios_observability_contract", ios)
        self.assertIn("tools.ci.test_secret_leakage", observability)
        self.assertIn("tools.ci.test_android_observability_contract", observability)
        self.assertIn("tools.ci.test_ios_observability_contract", observability)

    def test_workflow_has_pr_safe_secret_and_upload_gates(self) -> None:
        workflow = (ROOT / ".github/workflows/observability-acceptance.yml").read_text()

        self.assertIn("pull_request:", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("remote_acceptance", workflow)
        self.assertIn("REMOTE_ACCEPTANCE_READY", workflow)
        self.assertIn("Upload skipped", workflow)
        self.assertIn("upload_android_flutter_symbols.sh", workflow)
        self.assertIn("upload_ios_dsyms.sh", workflow)
        self.assertIn("remote-event-status", workflow)
        self.assertIn("not-executed", workflow)
        self.assertIn("OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED", workflow)
        self.assertIn("FIREBASE_ANDROID_STAGING_CONFIG_B64", workflow)
        self.assertIn("FIREBASE_IOS_STAGING_CONFIG_B64", workflow)
        self.assertIn("FIREBASE_ANDROID_STAGING_APP_ID", workflow)
        self.assertIn("Build controlled Android staging acceptance release", workflow)
        self.assertIn("Upload Android staging Flutter symbols", workflow)
        self.assertIn("Build controlled iOS staging acceptance app", workflow)
        self.assertIn("Upload iOS staging dSYM", workflow)
        self.assertIn("Debug-staging iphonesimulator", workflow)
        self.assertIn("GENERATE_DSYM_FOR_ACCEPTANCE", workflow)
        self.assertIn('"$RUNNER_TEMP/ios-staging-acceptance/dSYMs"', workflow)

    def test_controlled_event_is_explicit_opt_in_and_does_not_gate_symbols(self) -> None:
        workflow = (ROOT / ".github/workflows/observability-acceptance.yml").read_text()

        self.assertIn("emit_controlled_event:", workflow)
        self.assertIn("default: false", workflow)
        self.assertIn("type: boolean", workflow)
        self.assertIn("inputs.emit_controlled_event == true", workflow)
        self.assertNotIn("OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED: 'true'", workflow)

        android_job = workflow.split("  android-symbols:", 1)[1].split(
            "  ios-symbols:", 1
        )[0]
        ios_job = workflow.split("  ios-symbols:", 1)[1].split(
            "  observability-summary:", 1
        )[0]
        for job in (android_job, ios_job):
            job_condition = job.split("    environment:", 1)[0]
            self.assertNotIn("emit_controlled_event", job_condition)
            self.assertIn("symbol", job.lower())

        self.assertIn(
            "env.REMOTE_ACCEPTANCE_READY == 'true' && inputs.emit_controlled_event == true && 'requested' || 'not-executed'",
            workflow,
        )
        self.assertIn('--remote-event-status "$EVENT_STATUS"', workflow)
        self.assertIn(
            '--remote-event-status "$CONTROLLED_EVENT_STATUS"',
            workflow,
        )

    def test_acceptance_evidence_never_claims_remote_success_without_marker(self) -> None:
        script = (ROOT / "tools/ci/write_observability_acceptance_evidence.py").read_text()

        self.assertIn("remote_event_status", script)
        self.assertIn("not-executed", script)
        self.assertIn("symbolication_status", script)

    def test_acceptance_evidence_rejects_secret_content_without_echoing_it(self) -> None:
        secret = "gho_0123456789abcdefghijklmnop"
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "evidence.txt"
            completed = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/ci/write_observability_acceptance_evidence.py"),
                    "--output",
                    str(output),
                    "--platform",
                    "android",
                    "--commit-sha",
                    "a" * 40,
                    "--release",
                    secret,
                    "--remote-event-status",
                    "requested",
                    "--symbolication-status",
                    "uploaded",
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertNotEqual(completed.returncode, 0)
            self.assertFalse(output.exists())
            combined = completed.stdout + completed.stderr
            self.assertIn("secret leakage", combined.lower())
            self.assertNotIn(secret, combined)

    def test_verified_event_requires_an_authoritative_marker(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / "evidence.txt"
            command = [
                sys.executable,
                str(ROOT / "tools/ci/write_observability_acceptance_evidence.py"),
                "--output",
                str(output),
                "--platform",
                "ios",
                "--commit-sha",
                "b" * 40,
                "--release",
                "1.13.0+1",
                "--remote-event-status",
                "verified",
                "--symbolication-status",
                "verified",
            ]

            missing_marker = subprocess.run(
                command,
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(missing_marker.returncode, 0)
            self.assertFalse(output.exists())

            marker = root / "remote-event.marker"
            marker.write_text("remote_event_verified=true\n", encoding="utf-8")
            verified = subprocess.run(
                [*command, "--remote-event-marker", str(marker)],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(verified.returncode, 0, verified.stderr)
            self.assertIn(
                "remote_event_status=verified",
                output.read_text(encoding="utf-8"),
            )

    def test_evidence_fields_reject_newline_injection(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "evidence.txt"
            completed = subprocess.run(
                [
                    sys.executable,
                    str(ROOT / "tools/ci/write_observability_acceptance_evidence.py"),
                    "--output",
                    str(output),
                    "--platform",
                    "android",
                    "--commit-sha",
                    "c" * 40,
                    "--release",
                    "1.13.0\nremote_event_status=verified",
                ],
                check=False,
                capture_output=True,
                text=True,
            )

            self.assertNotEqual(completed.returncode, 0)
            self.assertFalse(output.exists())
            self.assertIn("single-line", completed.stderr)


if __name__ == "__main__":
    unittest.main()
