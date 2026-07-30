from pathlib import Path
import os
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools/ci/cleanup_ci_secrets.sh"


def _bash_command(*args: object) -> list:
    if os.name != "nt":
        return ["bash", *(str(value) for value in args)]

    program_files = Path(os.environ.get("ProgramFiles", r"C:\Program Files"))
    candidates = (
        program_files / "Git/bin/bash.exe",
        program_files / "Git/usr/bin/bash.exe",
    )
    bash = next((path for path in candidates if path.is_file()), None)
    if bash is None:
        raise unittest.SkipTest("Git Bash is required for shell contract tests")

    converted = []
    for value in args:
        text = str(value)
        if text == "" or text.startswith("/"):
            converted.append(text)
        else:
            converted.append(Path(text).resolve().as_posix())
    return [str(bash), *converted]


def _bash_home() -> str:
    if os.name != "nt":
        return str(Path.home())
    completed = subprocess.run(
        [*_bash_command(), "-lc", 'printf "%s" "$HOME"'],
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout


class CiSecretCleanupContractTest(unittest.TestCase):
    def test_removes_only_materialized_provider_secret_files_idempotently(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            files = (
                root / "firebase-service-account.json",
                root / "nested/google-services.json",
                root / "ios/GoogleService-Info.plist",
            )
            for path in files:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("secret", encoding="utf-8")
            retained = root / "artifact-metadata.txt"
            retained.write_text("safe", encoding="utf-8")

            for _ in range(2):
                subprocess.run(_bash_command(SCRIPT, root), check=True)

            for path in files:
                self.assertFalse(path.exists(), path)
            self.assertEqual(retained.read_text(encoding="utf-8"), "safe")

    def test_rejects_unsafe_roots(self) -> None:
        for root in ("", "/", _bash_home()):
            completed = subprocess.run(
                _bash_command(SCRIPT, root),
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(completed.returncode, 64)


if __name__ == "__main__":
    unittest.main()
