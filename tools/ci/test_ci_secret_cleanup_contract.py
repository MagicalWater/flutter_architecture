from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools/ci/cleanup_ci_secrets.sh"


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
                subprocess.run(["bash", str(SCRIPT), str(root)], check=True)

            for path in files:
                self.assertFalse(path.exists(), path)
            self.assertEqual(retained.read_text(encoding="utf-8"), "safe")

    def test_rejects_unsafe_roots(self) -> None:
        for root in ("", "/", str(Path.home())):
            completed = subprocess.run(
                ["bash", str(SCRIPT), root],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertEqual(completed.returncode, 64)


if __name__ == "__main__":
    unittest.main()
