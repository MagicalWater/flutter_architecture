import json
from pathlib import Path
import tempfile
import unittest

from tools.database.normalize_drift_schema_json import (
    normalize_schema_file,
    normalize_schema_payload,
)


class DriftSchemaNormalizerTest(unittest.TestCase):
    def test_normalizes_crlf_and_lone_cr_inside_nested_strings(self) -> None:
        payload = {
            "sql": "CREATE INDEX x\r\nON table_name (value);",
            "nested": ["line1\rline2", {"stable": "line1\nline2"}],
        }

        normalized = normalize_schema_payload(payload)

        self.assertEqual(
            normalized,
            {
                "sql": "CREATE INDEX x\nON table_name (value);",
                "nested": ["line1\nline2", {"stable": "line1\nline2"}],
            },
        )

    def test_file_output_is_deterministic_and_preserves_json_semantics(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "schema.json"
            path.write_text(
                json.dumps(
                    {
                        "version": 6,
                        "entities": [
                            {
                                "name": "index",
                                "sql": "CREATE INDEX x\r\nON table_name (value);",
                            }
                        ],
                    },
                    indent=2,
                ),
                encoding="utf-8",
            )

            normalize_schema_file(path)
            first = path.read_bytes()
            normalize_schema_file(path)
            second = path.read_bytes()

            self.assertEqual(first, second)
            self.assertTrue(first.endswith(b"\n"))
            self.assertNotIn(b"\\r", first)
            decoded = json.loads(first.decode("utf-8"))
            self.assertEqual(
                decoded["entities"][0]["sql"],
                "CREATE INDEX x\nON table_name (value);",
            )

    def test_export_script_runs_normalizer_with_resolved_python(self) -> None:
        script = Path("tools/database/export_drift_schemas.sh").read_text(
            encoding="utf-8"
        )

        self.assertIn("resolve_python", script)
        self.assertIn("PYTHON_BIN", script)
        self.assertIn("normalize_drift_schema_json.py", script)
        self.assertIn('"$python_bin"', script)


if __name__ == "__main__":
    unittest.main()
