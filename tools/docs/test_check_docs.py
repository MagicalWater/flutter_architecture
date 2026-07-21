from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.docs.check_docs import check_repository


class DocumentationCheckerTest(unittest.TestCase):
    def test_reports_broken_relative_markdown_link_but_ignores_fenced_example(self) -> None:
        with _fixture() as root:
            _write(root, "README.md", "[Missing](docs/missing.md)\n```md\n[Example](nope.md)\n```\n")

            codes = _codes(root)

            self.assertIn("broken-link", codes)
            self.assertEqual(codes.count("broken-link"), 1)

    def test_reports_duplicate_declared_id(self) -> None:
        with _fixture() as root:
            _write(root, "docs/a.md", "---\nid: M22-PR01\n---\n")
            _write(root, "docs/b.md", "---\nid: M22-PR01\n---\n")

            self.assertIn("duplicate-id", _codes(root))

    def test_reports_baseline_mismatch(self) -> None:
        with _fixture() as root:
            _write(root, "VERSION", "1.5.0\n")
            _write(root, "README.md", "Template Baseline Version：1.4.0\n")
            _write(root, "CHANGELOG.md", "## [1.5.0] - 2026-07-20\n")

            self.assertIn("baseline-mismatch", _codes(root))

    def test_reports_missing_app_package_and_feature_readmes(self) -> None:
        with _fixture() as root:
            _write(root, "apps/demo/pubspec.yaml", "name: demo\n")
            _write(root, "packages/core/pubspec.yaml", "name: core\n")
            _write(root, "apps/demo/lib/features/auth/.keep", "")

            codes = _codes(root)

            self.assertEqual(codes.count("missing-readme"), 3)

    def test_reports_invalid_managed_metadata(self) -> None:
        with _fixture() as root:
            _write(
                root,
                "docs/managed.md",
                "---\ndocument_type: unknown\nstatus: invalid\n"
                "authoritative_for:\n  - Bad Scope\nlast_reviewed_baseline: later\n---\n",
            )

            self.assertIn("invalid-metadata", _codes(root))

    def test_reports_multiple_active_milestones(self) -> None:
        with _fixture() as root:
            metadata = (
                "---\ndocument_type: active-milestone\nstatus: active\n"
                "authoritative_for:\n  - {scope}\nlast_reviewed_baseline: 1.5.0\n---\n"
            )
            _write(root, "docs/roadmap/a.md", metadata.format(scope="active-a"))
            _write(root, "docs/roadmap/b.md", metadata.format(scope="active-b"))

            self.assertIn("status-contradiction", _codes(root))


def _codes(root: Path) -> list[str]:
    return [issue.code for issue in check_repository(root)]


class _fixture:
    def __enter__(self) -> Path:
        self._temp = tempfile.TemporaryDirectory()
        return Path(self._temp.name)

    def __exit__(self, exc_type: object, exc: object, traceback: object) -> None:
        self._temp.cleanup()


def _write(root: Path, relative_path: str, content: str) -> None:
    path = root / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    unittest.main()
