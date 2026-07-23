from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class ObservabilityAcceptanceWorkflowTest(unittest.TestCase):
    def test_workflow_has_pr_safe_secret_and_upload_gates(self) -> None:
        workflow = (ROOT / ".github/workflows/observability-acceptance.yml").read_text()

        self.assertIn("pull_request:", workflow)
        self.assertIn("workflow_dispatch:", workflow)
        self.assertIn("remote_acceptance", workflow)
        self.assertIn("REMOTE_ACCEPTANCE_READY", workflow)
        self.assertIn("Upload skipped", workflow)
        self.assertIn("upload_android_flutter_symbols.sh", workflow)
        self.assertIn("upload_ios_dsyms.sh", workflow)
        self.assertIn("remote-event-status not-executed", workflow)
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

    def test_acceptance_evidence_never_claims_remote_success_without_marker(self) -> None:
        script = (ROOT / "tools/ci/write_observability_acceptance_evidence.py").read_text()

        self.assertIn("remote_event_status", script)
        self.assertIn("not-executed", script)
        self.assertIn("symbolication_status", script)


if __name__ == "__main__":
    unittest.main()
