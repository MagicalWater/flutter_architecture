from pathlib import Path
import re
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"


class PublicRepositorySecurityContractTest(unittest.TestCase):
    def setUp(self) -> None:
        self.workflows = {
            path.name: path.read_text(encoding="utf-8")
            for path in WORKFLOWS.glob("*.yml")
        }

    @staticmethod
    def _job_blocks(workflow: str) -> list[str]:
        return re.split(r"(?m)^  (?=[a-zA-Z0-9_-]+:\s*$)", workflow)[1:]

    def test_repository_workflows_are_manual_dispatch_only(self) -> None:
        for name, workflow in self.workflows.items():
            trigger = workflow.split("permissions:", 1)[0]
            self.assertIn("workflow_dispatch:", trigger, name)
            self.assertNotIn("pull_request:", trigger, name)
            self.assertNotIn("push:", trigger, name)
            self.assertNotIn("github.event_name", workflow, name)
            self.assertNotIn("github.event.pull_request", workflow, name)
            self.assertNotIn("github.event.before", workflow, name)

    def test_provider_secrets_require_explicit_remote_acceptance(self) -> None:
        observability = self.workflows["observability-acceptance.yml"]
        secret_jobs = [
            block
            for block in self._job_blocks(observability)
            if "${{ secrets." in block
        ]
        self.assertTrue(secret_jobs)
        for job in secret_jobs:
            condition = job.split("    steps:", 1)[0]
            self.assertIn("inputs.remote_acceptance == true", condition)

    def test_pull_request_target_is_not_used(self) -> None:
        for name, workflow in self.workflows.items():
            self.assertNotIn("pull_request_target:", workflow, name)

    def test_repository_owned_workflow_actions_are_pinned_to_full_sha(self) -> None:
        full_sha = re.compile(r"^[0-9a-f]{40}$")
        for name, workflow in self.workflows.items():
            for line in workflow.splitlines():
                stripped = line.strip()
                if not stripped.startswith("uses:"):
                    continue
                action = stripped.removeprefix("uses:").strip()
                if action.startswith("./"):
                    continue
                self.assertIn("@", action, f"{name}: {action}")
                _, ref = action.rsplit("@", 1)
                ref = ref.split("#", 1)[0].strip()
                self.assertRegex(ref, full_sha, f"{name}: {action}")

    def test_secret_material_is_ignored_by_git(self) -> None:
        paths = (
            ".env",
            ".env.production",
            "apps/flutter_architecture/android/app/release.keystore",
            "apps/flutter_architecture/android/key.properties",
            "apps/flutter_architecture/ios/signing.p12",
            "apps/flutter_architecture/ios/private-key.pem",
            "apps/flutter_architecture/android/app/google-services.json",
            "apps/flutter_architecture/ios/Runner/GoogleService-Info.plist",
            "apps/flutter_architecture/lib/firebase_options.dart",
            "firebase-service-account.json",
        )
        for path in paths:
            completed = subprocess.run(
                ["git", "check-ignore", "-q", path],
                cwd=ROOT,
                check=False,
            )
            self.assertEqual(completed.returncode, 0, path)

        examples = (".env.example", ".env.production.example")
        for path in examples:
            completed = subprocess.run(
                ["git", "check-ignore", "-q", path],
                cwd=ROOT,
                check=False,
            )
            self.assertNotEqual(completed.returncode, 0, path)


if __name__ == "__main__":
    unittest.main()
