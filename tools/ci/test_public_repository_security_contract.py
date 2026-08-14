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

    def test_pull_request_paths_do_not_select_trusted_self_hosted_runner(self) -> None:
        for name, workflow in self.workflows.items():
            if "pull_request:" not in workflow:
                continue
            self.assertNotIn(
                "github.event_name == 'pull_request' && vars.CI_EXECUTION_MODE == 'self-hosted'",
                workflow,
                name,
            )

            for job in self._job_blocks(workflow):
                runner_lines = [
                    line for line in job.splitlines()
                    if "runs-on:" in line and "self-hosted" in line
                ]
                if not runner_lines:
                    continue
                condition = job.split("    steps:", 1)[0]
                for line in runner_lines:
                    self.assertNotIn("pull_request", line, name)
                    if "github.event_name" in line:
                        continue
                    self.assertTrue(
                        "github.event_name == 'push'" in condition
                        or "github.event_name == 'workflow_dispatch'" in condition,
                        name,
                    )

    def test_pull_request_ci_is_not_disabled_by_repository_execution_mode(self) -> None:
        ci = self.workflows["ci.yml"]
        classify = next(
            block
            for block in self._job_blocks(ci)
            if block.startswith("classify-changes:\n")
            or block.startswith("classify-changes:\r\n")
        )
        condition = classify.split("    runs-on:", 1)[0]
        self.assertIn("github.event_name == 'pull_request'", condition)
        self.assertNotIn(
            "github.event_name == 'pull_request' && vars.CI_EXECUTION_MODE",
            condition,
        )

    def test_provider_secrets_are_not_available_to_pull_request_jobs(self) -> None:
        observability = self.workflows["observability-acceptance.yml"]
        secret_jobs = [
            block
            for block in self._job_blocks(observability)
            if "${{ secrets." in block
        ]
        self.assertTrue(secret_jobs)
        for job in secret_jobs:
            condition = job.split("    steps:", 1)[0]
            self.assertIn("github.event_name == 'workflow_dispatch'", condition)
            self.assertNotIn("pull_request", condition)

    def test_pull_request_target_is_not_used(self) -> None:
        for name, workflow in self.workflows.items():
            self.assertNotIn("pull_request_target:", workflow, name)

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
