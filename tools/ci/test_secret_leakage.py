from pathlib import Path
import tempfile
import unittest

from tools.ci.secret_leakage import (
    MAX_DIAGNOSTIC_BYTES,
    scan_evidence_paths,
)


class SecretLeakageTest(unittest.TestCase):
    def test_safe_evidence_passes(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            safe = root / "diagnostics" / "build.log"
            safe.parent.mkdir(parents=True)
            safe.write_text("build failed with exit code 1\n", encoding="utf-8")

            result = scan_evidence_paths([safe], max_total_bytes=MAX_DIAGNOSTIC_BYTES)

        self.assertEqual(result.file_count, 1)
        self.assertGreater(result.total_bytes, 0)

    def test_known_secret_patterns_are_rejected_without_value_disclosure(self) -> None:
        secrets = (
            "-----BEGIN PRIVATE KEY-----",
            '"private_key": "escaped-secret"',
            "gho_0123456789abcdefghijklmnop",
            '<key>CLIENT_ID</key><string>client.apps.googleusercontent.com</string>',
            '"mobilesdk_app_id": "1:123:android:secret"',
        )
        for secret in secrets:
            with self.subTest(secret=secret[:12]):
                with tempfile.TemporaryDirectory() as directory:
                    path = Path(directory) / "diagnostic.log"
                    path.write_text(secret, encoding="utf-8")
                    with self.assertRaisesRegex(ValueError, "secret leakage") as caught:
                        scan_evidence_paths(
                            [path],
                            max_total_bytes=MAX_DIAGNOSTIC_BYTES,
                        )
                self.assertNotIn(secret, str(caught.exception))

    def test_total_size_is_bounded_and_symlinks_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            oversized = root / "oversized.log"
            oversized.write_bytes(b"x" * (MAX_DIAGNOSTIC_BYTES + 1))
            with self.assertRaisesRegex(ValueError, "25 MiB"):
                scan_evidence_paths(
                    [oversized],
                    max_total_bytes=MAX_DIAGNOSTIC_BYTES,
                )

            target = root / "target.log"
            target.write_text("safe", encoding="utf-8")
            link = root / "link.log"
            try:
                link.symlink_to(target)
            except OSError:
                self.skipTest("symlink creation is not available")
            with self.assertRaisesRegex(ValueError, "symlink"):
                scan_evidence_paths([link], max_total_bytes=MAX_DIAGNOSTIC_BYTES)

    def test_provider_config_filename_is_rejected_but_mapping_is_local_safe(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            config = root / "google-services.json"
            config.write_text("{}", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "secret leakage"):
                scan_evidence_paths([config])

            mapping = root / "mapping.txt"
            mapping.write_text("class mapping", encoding="utf-8")
            result = scan_evidence_paths([mapping])
            self.assertEqual(result.file_count, 1)


if __name__ == "__main__":
    unittest.main()
