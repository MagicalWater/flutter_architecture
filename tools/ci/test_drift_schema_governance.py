from __future__ import annotations

import hashlib
import unittest
from pathlib import Path


class DriftSchemaGovernanceTest(unittest.TestCase):
    def test_all_historical_and_current_snapshots_exist(self) -> None:
        root = Path(
            "apps/flutter_architecture/test/drift_schemas/app_database"
        )
        expected = [root / f"drift_schema_v{version}.json" for version in range(1, 7)]
        expected.append(root / "drift_schema_current.json")

        for snapshot in expected:
            self.assertTrue(snapshot.is_file(), snapshot)
            self.assertGreater(snapshot.stat().st_size, 100, snapshot)

    def test_web_wasm_matches_resolved_sqlite_asset(self) -> None:
        wasm = Path("apps/flutter_architecture/web/sqlite3.wasm")
        digest = hashlib.sha256(wasm.read_bytes()).hexdigest()

        self.assertEqual(
            digest,
            "41cf968998241465d8b1dfffb1eb60dd10c35de5022a3647e14174ea3af84143",
        )


if __name__ == "__main__":
    unittest.main()
