from pathlib import Path
import unittest


REPO_ROOT = Path(__file__).resolve().parents[2]


class CodegenNormalizerContractTest(unittest.TestCase):
    def test_volatile_output_directories_are_pruned_before_recursion(self) -> None:
        script = (REPO_ROOT / "tools/codegen/normalize_generated.dart").read_text(
            encoding="utf-8"
        )

        self.assertNotIn("listSync(recursive: true", script)
        self.assertIn("_walkTrackedGeneratedSources", script)
        self.assertIn("_shouldSkipDirectory", script)
        self.assertIn("current.existsSync()", script)


if __name__ == "__main__":
    unittest.main()
