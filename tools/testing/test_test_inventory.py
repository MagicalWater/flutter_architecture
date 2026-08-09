import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from tools.testing.inventory import (
    count_dart_cases,
    count_python_cases,
    display_output_path,
    discover_test_files,
    inventory_rows,
)


class TestInventoryTest(unittest.TestCase):
    def test_discovers_tracked_test_shapes_and_sorts_paths(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "apps/example/test").mkdir(parents=True)
            (root / "tools/ci").mkdir(parents=True)
            (root / "apps/example/test/z_test.dart").write_text("test('z', () {});\n")
            (root / "tools/ci/test_a.py").write_text(
                "import unittest\nclass A(unittest.TestCase):\n    def test_a(self): pass\n"
            )
            (root / "apps/example/test/helper.dart").write_text("void helper() {}\n")

            files = discover_test_files(root)

            self.assertEqual(
                [path.relative_to(root).as_posix() for path in files],
                ["apps/example/test/z_test.dart", "tools/ci/test_a.py"],
            )

    def test_counts_dart_test_and_test_widgets_declarations(self) -> None:
        source = """
test('one', () {});
testWidgets('two', (tester) async {});
group('not a case', () {});
"""
        self.assertEqual(count_dart_cases(source), 2)

    def test_counts_python_unittest_methods(self) -> None:
        source = """
class Example:
    def test_one(self):
        pass
    async def test_two(self):
        pass
"""
        self.assertEqual(count_python_cases(source), 2)

    def test_inventory_rows_are_repository_relative_and_deterministic(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "packages/auth/test/auth_test.dart"
            path.parent.mkdir(parents=True)
            path.write_text("test('auth', () {});\n")

            rows = inventory_rows(root, [path])

            self.assertEqual(len(rows), 1)
            self.assertEqual(rows[0]["path"], "packages/auth/test/auth_test.dart")
            self.assertEqual(rows[0]["suite"], "Auth")
            self.assertEqual(rows[0]["type"], "dart")
            self.assertEqual(rows[0]["loc"], 1)
            self.assertEqual(rows[0]["static_cases"], 1)
            self.assertEqual(rows[0]["execution_tier"], "Tier 2")

    def test_python_ci_contract_defaults_to_tier_1(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "tools/ci/test_change_classifier.py"
            path.parent.mkdir(parents=True)
            path.write_text("def test_contract(): pass\n")

            row = inventory_rows(root, [path])[0]

            self.assertEqual(row["execution_tier"], "Tier 1")

    def test_non_ci_python_tooling_defaults_to_tier_1(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "tools/testing/test_inventory_contract.py"
            path.parent.mkdir(parents=True)
            path.write_text("def test_inventory(): pass\n")

            row = inventory_rows(root, [path])[0]

            self.assertEqual(row["execution_tier"], "Tier 1")

    def test_migration_and_schema_tests_are_tier_3(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            migration = root / "apps/example/test/database/migration_test.dart"
            schema = root / "tools/ci/test_drift_schema_governance.py"
            migration.parent.mkdir(parents=True)
            schema.parent.mkdir(parents=True)
            migration.write_text("test('migration', () {});\n")
            schema.write_text("def test_schema(): pass\n")

            rows = inventory_rows(root, [migration, schema])

            self.assertEqual(rows[0]["execution_tier"], "Tier 3")
            self.assertEqual(rows[1]["execution_tier"], "Tier 3")

    def test_native_platform_tests_are_tier_4(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            dart_path = root / "apps/example/test/platform/android_bridge_test.dart"
            python_path = root / "tools/ci/test_ios_workflow_contract.py"
            dart_path.parent.mkdir(parents=True)
            python_path.parent.mkdir(parents=True)
            dart_path.write_text("test('platform', () {});\n")
            python_path.write_text("def test_ios(): pass\n")

            rows = inventory_rows(root, [dart_path, python_path])

            self.assertEqual(rows[0]["execution_tier"], "Tier 4")
            self.assertEqual(rows[1]["execution_tier"], "Tier 4")

    def test_display_output_path_uses_posix_relative_path_inside_root(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            output = root / "tmp" / "inventory.csv"

            self.assertEqual(
                display_output_path(output, root),
                "tmp/inventory.csv",
            )

    def test_display_output_path_uses_resolved_absolute_path_outside_root(self) -> None:
        with tempfile.TemporaryDirectory() as root_directory:
            with tempfile.TemporaryDirectory() as output_directory:
                root = Path(root_directory).resolve()
                output = Path(output_directory) / "inventory.csv"

                self.assertEqual(
                    display_output_path(output, root),
                    str(output.resolve()),
                )

    def test_cli_supports_repository_external_output(self) -> None:
        repository_root = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "inventory.csv"

            result = subprocess.run(
                [
                    sys.executable,
                    str(repository_root / "tools/testing/inventory.py"),
                    "--root",
                    str(repository_root),
                    "--output",
                    str(output),
                ],
                cwd=repository_root,
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, msg=result.stderr)
            self.assertTrue(output.is_file())
            self.assertIn(f"output={output.resolve()}", result.stdout)


if __name__ == "__main__":
    unittest.main()
