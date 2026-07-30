from pathlib import Path
import unittest


REPO_ROOT = Path(__file__).resolve().parents[2]


class ShellPortabilityContractTest(unittest.TestCase):
    def test_artifact_contract_avoids_python_310_union_annotations(self) -> None:
        for relative_path in (
            "tools/ci/artifact_contract.py",
            "tools/ci/artifact_store.py",
            "tools/ci/artifact_cleanup.py",
        ):
            source = (REPO_ROOT / relative_path).read_text(encoding="utf-8")
            self.assertNotRegex(
                source,
                r"\b[A-Za-z_][A-Za-z0-9_\.\[\], ]*\s*\|\s*None\b",
                relative_path,
            )

    def test_generated_verifier_supports_macos_bash_3(self) -> None:
        script = (REPO_ROOT / "tools/ci/verify_generated.sh").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("mapfile", script)

    def test_generated_verifier_resolves_a_working_python_interpreter(self) -> None:
        script = (REPO_ROOT / "tools/ci/verify_generated.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn("resolve_python", script)
        self.assertIn("PYTHON_BIN", script)
        self.assertIn('"$python_bin" -m unittest', script)
        self.assertNotIn("python3 -m unittest", script)

    def test_generated_verifier_uses_content_diff_not_stat_only_status(self) -> None:
        script = (REPO_ROOT / "tools/ci/verify_generated.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn("git diff --quiet --exit-code", script)
        self.assertIn("git ls-files --others --exclude-standard", script)
        self.assertNotIn('status="$(git status --porcelain)"', script)

    def test_android_artifact_metadata_avoids_pipefail_head_pipeline(self) -> None:
        script = (REPO_ROOT / "tools/ci/build_android_environment.sh").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("flutter --version | head", script)
        self.assertNotIn("java -version 2>&1 | head", script)
        self.assertNotIn("mapfile", script)
        self.assertIn("Android Studio.app/Contents/jbr/Contents/Home", script)


if __name__ == "__main__":
    unittest.main()
