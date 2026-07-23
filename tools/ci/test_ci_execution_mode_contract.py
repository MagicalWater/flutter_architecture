from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = (
    ROOT / ".github/workflows/ci.yml",
    ROOT / ".github/workflows/android.yml",
    ROOT / ".github/workflows/ios.yml",
    ROOT / ".github/workflows/observability-acceptance.yml",
)


class CiExecutionModeContractTest(unittest.TestCase):
    def test_all_hosted_workflows_support_local_default_and_manual_override(self) -> None:
        for workflow in WORKFLOWS:
            text = workflow.read_text(encoding="utf-8")
            self.assertIn("run_hosted:", text, workflow.name)
            self.assertIn("CI_EXECUTION_MODE", text, workflow.name)
            self.assertIn("inputs.run_hosted == true", text, workflow.name)

    def test_local_entrypoint_exposes_all_supported_suites(self) -> None:
        script = (ROOT / "tools/ci/run_local_ci.sh").read_text(encoding="utf-8")
        for suite in ("quality", "android", "ios", "observability", "all"):
            self.assertIn(f"{suite})", script)
        self.assertIn("build_android_development.sh", script)
        self.assertIn("build_ios_development.sh", script)
        self.assertIn("upload_ios_dsyms.sh", script)


if __name__ == "__main__":
    unittest.main()
