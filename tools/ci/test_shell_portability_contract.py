from pathlib import Path
import unittest


REPO_ROOT = Path(__file__).resolve().parents[2]


class ShellPortabilityContractTest(unittest.TestCase):
    def test_generated_verifier_supports_macos_bash_3(self) -> None:
        script = (REPO_ROOT / "tools/ci/verify_generated.sh").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("mapfile", script)

    def test_android_artifact_metadata_avoids_pipefail_head_pipeline(self) -> None:
        script = (REPO_ROOT / "tools/ci/build_android_release.sh").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("flutter --version | head", script)
        self.assertNotIn("java -version 2>&1 | head", script)
        self.assertIn("Android Studio.app/Contents/jbr/Contents/Home/bin/java", script)


if __name__ == "__main__":
    unittest.main()
