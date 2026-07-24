from __future__ import annotations

import unittest
from pathlib import Path


class NoSqfliteAuthorityTest(unittest.TestCase):
    def test_production_lib_has_no_sqflite_import_or_api(self) -> None:
        root = Path("apps/flutter_architecture/lib")
        forbidden = (
            "package:sqflite/",
            "package:sqflite_common_ffi/",
            "package:sqflite_common_ffi_web/",
            "SqfliteAuthUserStore",
            "SqfliteCatalogCacheDao",
            "AppDatabaseSchema",
            "initializeDatabaseFactory",
        )

        findings: list[str] = []
        for path in root.rglob("*.dart"):
            text = path.read_text(encoding="utf-8")
            for token in forbidden:
                if token in text:
                    findings.append(f"{path}: {token}")

        self.assertEqual(findings, [], "\n".join(findings))

    def test_legacy_sqflite_worker_is_removed(self) -> None:
        self.assertFalse(
            Path("apps/flutter_architecture/web/sqflite_sw.js").exists()
        )


if __name__ == "__main__":
    unittest.main()
