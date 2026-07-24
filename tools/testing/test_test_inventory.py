import tempfile
import unittest
from pathlib import Path

from tools.testing.test_inventory import (
    count_dart_cases,
    count_python_cases,
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


if __name__ == "__main__":
    unittest.main()
