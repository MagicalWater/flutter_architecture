from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


DOCUMENT_TYPES = {
    "agent-policy",
    "project-entry",
    "documentation-hub",
    "current-snapshot",
    "architecture-decision-index",
    "architecture-decision",
    "roadmap-index",
    "active-milestone",
    "roadmap-candidates",
    "backlog",
    "design-spec",
    "implementation-plan",
    "planning-review",
    "phase-review",
    "runtime-evidence",
    "final-review",
    "audit-index",
    "design-plan-index",
    "milestone-index",
    "milestone-archive",
    "guide",
    "knowledge",
    "governance-policy",
    "migration-manifest",
    "app-readme",
    "feature-readme",
    "package-readme",
}

STATUSES = {
    "draft",
    "proposed",
    "accepted",
    "active",
    "completed",
    "archived",
    "superseded",
    "legacy",
}

_SCOPE_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
_VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")
_MARKDOWN_LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
_CHANGELOG_VERSION_RE = re.compile(r"^##\s+\[?(\d+\.\d+\.\d+)\]?")
_README_BASELINE_RE = re.compile(r"Template Baseline Version[：:]\s*`?\*{0,2}(\d+\.\d+\.\d+)")


@dataclass(frozen=True)
class CheckIssue:
    code: str
    path: Path
    message: str

    def format(self, root: Path) -> str:
        try:
            display_path = self.path.relative_to(root)
        except ValueError:
            display_path = self.path
        return f"[{self.code}] {display_path}: {self.message}"


def check_repository(root: Path) -> list[CheckIssue]:
    root = root.resolve()
    markdown_files = sorted(_iter_markdown_files(root))
    issues: list[CheckIssue] = []
    issues.extend(_check_links(root, markdown_files))
    issues.extend(_check_baseline(root))
    metadata_by_path, metadata_issues = _check_metadata(root, markdown_files)
    issues.extend(metadata_issues)
    issues.extend(_check_duplicate_ids(root, metadata_by_path))
    issues.extend(_check_status(metadata_by_path))
    issues.extend(_check_readme_coverage(root))
    return sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))


def _iter_markdown_files(root: Path) -> Iterable[Path]:
    ignored = {".git", ".dart_tool", "build"}
    for path in root.rglob("*.md"):
        if not any(part in ignored for part in path.parts):
            yield path


def _check_links(root: Path, files: list[Path]) -> list[CheckIssue]:
    issues: list[CheckIssue] = []
    for path in files:
        text = _without_fenced_code(path.read_text(encoding="utf-8"))
        for raw_target in _MARKDOWN_LINK_RE.findall(text):
            target = raw_target.strip().split(maxsplit=1)[0].strip("<>")
            if not target or target.startswith(("#", "http://", "https://", "mailto:")):
                continue
            relative = target.split("#", maxsplit=1)[0]
            if not relative:
                continue
            resolved = (path.parent / relative).resolve()
            try:
                resolved.relative_to(root)
            except ValueError:
                issues.append(CheckIssue("broken-link", path, f"link escapes repository: {target}"))
                continue
            if not resolved.exists():
                issues.append(CheckIssue("broken-link", path, f"target does not exist: {target}"))
    return issues


def _without_fenced_code(text: str) -> str:
    output: list[str] = []
    in_fence = False
    fence_marker = ""
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith(("```", "~~~")):
            marker = stripped[:3]
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif marker == fence_marker:
                in_fence = False
                fence_marker = ""
            continue
        if not in_fence:
            output.append(line)
    return "\n".join(output)


def _check_baseline(root: Path) -> list[CheckIssue]:
    version_path = root / "VERSION"
    readme_path = root / "README.md"
    changelog_path = root / "CHANGELOG.md"
    if not all(path.exists() for path in (version_path, readme_path, changelog_path)):
        return []

    version = version_path.read_text(encoding="utf-8").strip()
    readme_match = _README_BASELINE_RE.search(readme_path.read_text(encoding="utf-8"))
    changelog_version = next(
        (
            match.group(1)
            for line in changelog_path.read_text(encoding="utf-8").splitlines()
            if (match := _CHANGELOG_VERSION_RE.match(line))
        ),
        None,
    )
    observed = {
        "VERSION": version,
        "README.md": readme_match.group(1) if readme_match else None,
        "CHANGELOG.md": changelog_version,
    }
    return [
        CheckIssue("baseline-mismatch", root / source, f"expected {version}, found {value!r}")
        for source, value in observed.items()
        if value != version
    ]


def _check_metadata(
    root: Path, files: list[Path]
) -> tuple[dict[Path, dict[str, object]], list[CheckIssue]]:
    metadata_by_path: dict[Path, dict[str, object]] = {}
    issues: list[CheckIssue] = []
    for path in files:
        metadata = _parse_front_matter(path.read_text(encoding="utf-8"))
        if not metadata:
            continue
        metadata_by_path[path] = metadata
        required = {"document_type", "status", "authoritative_for", "last_reviewed_baseline"}
        missing = sorted(required - metadata.keys())
        invalid: list[str] = []
        if missing:
            invalid.append(f"missing fields: {', '.join(missing)}")
        if metadata.get("document_type") not in DOCUMENT_TYPES:
            invalid.append(f"unsupported document_type: {metadata.get('document_type')!r}")
        if metadata.get("status") not in STATUSES:
            invalid.append(f"unsupported status: {metadata.get('status')!r}")
        scopes = metadata.get("authoritative_for")
        if not isinstance(scopes, list) or not scopes or any(
            not isinstance(scope, str) or not _SCOPE_RE.fullmatch(scope) for scope in scopes
        ):
            invalid.append("authoritative_for must be a non-empty kebab-case list")
        baseline = metadata.get("last_reviewed_baseline")
        if not isinstance(baseline, str) or not _VERSION_RE.fullmatch(baseline):
            invalid.append("last_reviewed_baseline must use semantic version format")
        if invalid:
            issues.append(CheckIssue("invalid-metadata", path, "; ".join(invalid)))
    return metadata_by_path, issues


def _parse_front_matter(text: str) -> dict[str, object]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    try:
        end = next(index for index, line in enumerate(lines[1:], start=1) if line.strip() == "---")
    except StopIteration:
        return {}

    result: dict[str, object] = {}
    current_list: str | None = None
    for line in lines[1:end]:
        if line.startswith("  - ") and current_list:
            value = line[4:].strip()
            cast_list = result.setdefault(current_list, [])
            if isinstance(cast_list, list):
                cast_list.append(value)
            continue
        if ":" not in line:
            continue
        key, raw_value = line.split(":", maxsplit=1)
        key = key.strip()
        value = raw_value.strip().strip('"\'')
        if value:
            result[key] = value
            current_list = None
        else:
            result[key] = []
            current_list = key
    return result


def _check_duplicate_ids(
    root: Path, metadata_by_path: dict[Path, dict[str, object]]
) -> list[CheckIssue]:
    declared: dict[str, list[Path]] = {}
    for path, metadata in metadata_by_path.items():
        identifier = metadata.get("id")
        if isinstance(identifier, str) and identifier:
            declared.setdefault(identifier, []).append(path)
    issues: list[CheckIssue] = []
    for identifier, paths in declared.items():
        if len(paths) > 1:
            for path in paths:
                issues.append(CheckIssue("duplicate-id", path, f"declared id {identifier!r} is duplicated"))
    return issues


def _check_status(metadata_by_path: dict[Path, dict[str, object]]) -> list[CheckIssue]:
    active = [
        path
        for path, metadata in metadata_by_path.items()
        if metadata.get("document_type") == "active-milestone" and metadata.get("status") == "active"
    ]
    if len(active) <= 1:
        return []
    return [
        CheckIssue("status-contradiction", path, "more than one active milestone document exists")
        for path in active
    ]


def _check_readme_coverage(root: Path) -> list[CheckIssue]:
    issues: list[CheckIssue] = []
    for parent in (root / "apps", root / "packages"):
        if not parent.exists():
            continue
        for pubspec in parent.glob("*/pubspec.yaml"):
            directory = pubspec.parent
            if not (directory / "README.md").exists():
                issues.append(CheckIssue("missing-readme", directory, "App/Package README.md is required"))

    for apps_root in (root / "apps",):
        if not apps_root.exists():
            continue
        for features_dir in apps_root.glob("*/lib/features"):
            for feature in sorted(path for path in features_dir.iterdir() if path.is_dir()):
                if not (feature / "README.md").exists():
                    issues.append(CheckIssue("missing-readme", feature, "Feature README.md is required"))
    return issues


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate repository documentation consistency.")
    parser.add_argument("root", nargs="?", default=".", help="repository root")
    args = parser.parse_args(argv)
    root = Path(args.root).resolve()
    issues = check_repository(root)
    if issues:
        for issue in issues:
            print(issue.format(root))
        print(f"Documentation check failed with {len(issues)} issue(s).")
        return 1
    print("Documentation check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
