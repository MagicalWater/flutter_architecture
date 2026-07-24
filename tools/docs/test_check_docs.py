from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from tools.docs.check_docs import check_repository


class DocumentationCheckerTest(unittest.TestCase):
    def test_generated_cocoapods_tree_is_ignored(self) -> None:
        with _fixture() as root:
            _write(
                root,
                "apps/demo/ios/Pods/Firebase/README.md",
                "[Missing](CONTRIBUTING.md)\n",
            )

            self.assertNotIn("broken-link", _codes(root))

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

    def test_allows_agent_skill_frontmatter(self) -> None:
        with _fixture() as root:
            _write(
                root,
                ".agents/skills/example/SKILL.md",
                "---\nname: example\ndescription: Use when testing a repository skill.\n---\n",
            )

            self.assertNotIn("invalid-metadata", _codes(root))

    def test_reports_stale_and_duplicate_milestone_routing(self) -> None:
        with _fixture() as root:
            _write(root, "docs/roadmap/active.md", "目前active milestone：\n\n```txt\nNone\n```\n")
            _write(
                root,
                "docs/milestones/README.md",
                "## Active routing\n\n| Milestone | Status | Primary routing |\n|---|---|---|\n"
                "| 30 | Local release complete; post-release pending | x |\n"
                "## Closed\n| Milestone | Status | Primary routing |\n|---|---|---|\n"
                "| 30 | Completed / Archived | y |\n",
            )

            codes = _codes(root)

            self.assertIn("stale-milestone-routing", codes)
            self.assertIn("duplicate-milestone-routing", codes)

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

    def test_reports_invalid_adr_id_and_filename_mismatch(self) -> None:
        with _fixture() as root:
            _write(
                root,
                "docs/adr/README.md",
                _adr_index("ADR-001", "adr-001-example.md", "extracted")
                + _adr_index_row("ADR-002", "adr-002-mismatch.md", "extracted"),
            )
            _write(root, "docs/adr/adr-001-example.md", _adr("ADR-2"))
            _write(root, "docs/adr/adr-002-mismatch.md", _adr("ADR-003"))

            codes = _codes(root)

            self.assertIn("invalid-adr-id", codes)
            self.assertIn("adr-filename-mismatch", codes)

    def test_reports_missing_and_orphan_adr_index_entries(self) -> None:
        with _fixture() as root:
            _write(root, "docs/adr/README.md", _adr_index("ADR-001", "adr-001-missing.md", "extracted"))
            _write(root, "docs/adr/adr-002-orphan.md", _adr("ADR-002"))

            codes = _codes(root)

            self.assertIn("missing-adr-file", codes)
            self.assertIn("orphan-adr-file", codes)

    def test_allows_aggregate_index_rows_during_migration(self) -> None:
        with _fixture() as root:
            _write(root, "docs/adr/README.md", _adr_index("ADR-001", "-", "aggregate"))

            self.assertNotIn("missing-adr-file", _codes(root))

    def test_reports_invalid_adr_supersession_edges(self) -> None:
        with _fixture() as root:
            _write(
                root,
                "docs/adr/README.md",
                _adr_index("ADR-001", "adr-001-a.md", "extracted")
                + _adr_index_row("ADR-002", "adr-002-b.md", "extracted"),
            )
            _write(root, "docs/adr/adr-001-a.md", _adr("ADR-001", superseded_by=["ADR-001", "ADR-999"]))
            _write(root, "docs/adr/adr-002-b.md", _adr("ADR-002", supersedes=["ADR-001"]))

            codes = _codes(root)

            self.assertIn("adr-self-edge", codes)
            self.assertIn("missing-adr-target", codes)
            self.assertIn("non-reciprocal-adr-edge", codes)

    def test_reports_supersession_cycle_and_missing_successor(self) -> None:
        with _fixture() as root:
            _write(
                root,
                "docs/adr/README.md",
                _adr_index("ADR-001", "adr-001-a.md", "extracted")
                + _adr_index_row("ADR-002", "adr-002-b.md", "extracted")
                + _adr_index_row("ADR-003", "adr-003-c.md", "extracted"),
            )
            _write(root, "docs/adr/adr-001-a.md", _adr("ADR-001", supersedes=["ADR-002"], superseded_by=["ADR-002"]))
            _write(root, "docs/adr/adr-002-b.md", _adr("ADR-002", supersedes=["ADR-001"], superseded_by=["ADR-001"]))
            _write(root, "docs/adr/adr-003-c.md", _adr("ADR-003", status="superseded"))

            codes = _codes(root)

            self.assertIn("adr-supersession-cycle", codes)
            self.assertIn("superseded-without-successor", codes)

    def test_reports_incomplete_full_adr_coverage_after_cutover(self) -> None:
        with _fixture() as root:
            _write(root, "docs/adr/README.md", _adr_index("ADR-001", "adr-001-a.md", "extracted"))
            _write(root, "docs/adr/adr-001-a.md", _adr("ADR-001"))
            _write(
                root,
                "docs/architecture_decisions.md",
                "---\ndocument_type: architecture-decision-index\nstatus: legacy\n"
                "authoritative_for:\n  - architecture-decision-legacy-routing\n"
                "last_reviewed_baseline: 1.5.1\n---\n",
            )

            self.assertIn("incomplete-adr-coverage", _codes(root))

    def test_requires_adr_027_after_cutover(self) -> None:
        with _fixture() as root:
            index = _adr_index("ADR-001", "adr-001-example.md", "extracted")
            for number in range(2, 27):
                identifier = f"ADR-{number:03d}"
                file_name = f"adr-{number:03d}-example.md"
                index += _adr_index_row(identifier, file_name, "extracted")
                _write(root, f"docs/adr/{file_name}", _adr(identifier))
            _write(root, "docs/adr/README.md", index)
            _write(root, "docs/adr/adr-001-example.md", _adr("ADR-001"))
            _write(
                root,
                "docs/architecture_decisions.md",
                "---\ndocument_type: architecture-decision-index\nstatus: legacy\n"
                "authoritative_for:\n  - architecture-decision-legacy-routing\n"
                "last_reviewed_baseline: 1.5.1\n---\n",
            )

            issues = check_repository(root)

            self.assertTrue(
                any(
                    issue.code == "incomplete-adr-coverage" and "ADR-027" in issue.message
                    for issue in issues
                )
            )

    def test_reports_invalid_managed_legacy_adr_route(self) -> None:
        with _fixture() as root:
            _write(root, "docs/adr/000-template-positioning.md", "# Legacy\n")

            self.assertIn("invalid-legacy-adr-route", _codes(root))


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


def _adr_index(identifier: str, file_name: str, state: str) -> str:
    return (
        "---\ndocument_type: architecture-decision-index\nstatus: active\n"
        "authoritative_for:\n  - architecture-decision-routing\n"
        "last_reviewed_baseline: 1.5.1\n---\n\n"
        "| ID | File | Migration state |\n|---|---|---|\n"
        + _adr_index_row(identifier, file_name, state)
    )


def _adr_index_row(identifier: str, file_name: str, state: str) -> str:
    return f"| {identifier} | {file_name} | {state} |\n"


def _adr(
    identifier: str,
    *,
    status: str = "accepted",
    supersedes: list[str] | None = None,
    superseded_by: list[str] | None = None,
) -> str:
    def yaml_list(name: str, values: list[str] | None) -> str:
        if not values:
            return f"{name}: []\n"
        return f"{name}:\n" + "".join(f"  - {value}\n" for value in values)

    return (
        "---\ndocument_type: architecture-decision\n"
        f"status: {status}\nauthoritative_for:\n  - adr-contract\n"
        "last_reviewed_baseline: 1.5.1\n"
        f"id: {identifier}\ntitle: Example\n"
        + yaml_list("supersedes", supersedes)
        + yaml_list("superseded_by", superseded_by)
        + "related: []\n---\n"
    )


if __name__ == "__main__":
    unittest.main()
