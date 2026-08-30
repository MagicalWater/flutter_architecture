from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from tools.docs.skill_lock import inspect_skill_lock
from tools.docs.verify_repository_identity import check_repository_identity
from tools.docs.verify_repository_infrastructure import check_repository_infrastructure
from tools.visual.verify_visual_authority import verify_visual_authority


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
_README_VERSION_RE = re.compile(
    r"(?:Template Baseline Version|Product Repository Version)[：:]\s*`?\*{0,2}(\d+\.\d+\.\d+)"
)
_ADR_ID_RE = re.compile(r"^ADR-(\d{3})$")
_ADR_FILE_RE = re.compile(r"^adr-(\d{3})-[a-z0-9]+(?:-[a-z0-9]+)*\.md$")
_ADR_INDEX_ROW_RE = re.compile(
    r"^\|\s*(ADR-\d{3})\s*\|\s*([^|]+?)\s*\|\s*(aggregate|extracted)\s*\|$"
)
_CJK_RE = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")


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


def check_repository(
    root: Path,
    identity_manifest_path: Path | None = None,
    version_override: str | None = None,
) -> list[CheckIssue]:
    root = root.resolve()
    markdown_files = sorted(_iter_markdown_files(root))
    issues: list[CheckIssue] = []
    issues.extend(
        CheckIssue(issue.code, issue.path, issue.message)
        for issue in check_repository_identity(root, identity_manifest_path, version_override)
    )
    issues.extend(
        CheckIssue(issue.code, issue.path, issue.message)
        for issue in check_repository_infrastructure(root)
    )
    skill_lock = inspect_skill_lock(root)
    issues.extend(
        CheckIssue(issue.code, issue.path, issue.message)
        for issue in skill_lock.issues
    )
    issues.extend(_check_links(root, markdown_files))
    issues.extend(
        _check_agent_skill_language(
            root,
            markdown_files,
            skill_lock.exempt_markdown_paths,
        )
    )
    issues.extend(_check_visual_authority_manifests(root))
    issues.extend(_check_baseline(root, version_override))
    metadata_by_path, metadata_issues = _check_metadata(root, markdown_files)
    issues.extend(metadata_issues)
    issues.extend(_check_duplicate_ids(root, metadata_by_path))
    issues.extend(_check_status(metadata_by_path))
    issues.extend(_check_adrs(root, metadata_by_path))
    issues.extend(_check_readme_coverage(root))
    issues.extend(_check_milestone_routing(root))
    return sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))


def _check_visual_authority_manifests(root: Path) -> list[CheckIssue]:
    authority_root = root / "docs" / "visual_authority"
    if not authority_root.is_dir():
        return []
    issues: list[CheckIssue] = []
    for manifest in sorted(authority_root.glob("**/manifest.md")):
        issues.extend(
            CheckIssue(issue.code, issue.path, issue.message)
            for issue in verify_visual_authority(root, manifest)
        )
    return issues


def _iter_markdown_files(root: Path) -> Iterable[Path]:
    ignored = {".git", ".dart_tool", "build", "Pods"}
    for path in root.rglob("*.md"):
        if not any(part in ignored for part in path.parts):
            yield path



def _is_agent_skill(path: Path, root: Path) -> bool:
    try:
        relative = path.relative_to(root)
    except ValueError:
        return False
    return len(relative.parts) >= 4 and relative.parts[0:2] == (".agents", "skills") and path.name == "SKILL.md"


def _is_agent_skill_markdown(path: Path, root: Path) -> bool:
    try:
        relative = path.relative_to(root)
    except ValueError:
        return False
    return len(relative.parts) >= 4 and relative.parts[0:2] == (".agents", "skills")


def _check_agent_skill_language(
    root: Path,
    files: list[Path],
    exempt_markdown_paths: frozenset[Path],
) -> list[CheckIssue]:
    issues: list[CheckIssue] = []
    for path in files:
        if not _is_agent_skill_markdown(path, root):
            continue
        if path.resolve() in exempt_markdown_paths:
            continue
        text = path.read_text(encoding="utf-8")
        if path.name == "SKILL.md":
            description = _parse_front_matter(text).get("description")
            if not isinstance(description, str) or not _CJK_RE.search(description):
                issues.append(
                    CheckIssue(
                        "agent-skill-language",
                        path,
                        "frontmatter description must include Chinese prose; repository policy requires Traditional Chinese",
                    )
                )
        body = _without_fenced_code(_without_front_matter(text))
        if not _CJK_RE.search(body):
            issues.append(
                CheckIssue(
                    "agent-skill-language",
                    path,
                    "document body must include Chinese prose; repository policy requires Traditional Chinese",
                )
            )
    return issues


def _check_milestone_routing(root: Path) -> list[CheckIssue]:
    active_path = root / "docs" / "roadmap" / "active.md"
    index_path = root / "docs" / "milestones" / "README.md"
    if not active_path.exists() or not index_path.exists():
        return []
    active_text = active_path.read_text(encoding="utf-8")
    index_text = _without_fenced_code(index_path.read_text(encoding="utf-8"))
    issues: list[CheckIssue] = []
    if re.search(r"currently? active milestone|目前active milestone", active_text, re.IGNORECASE) and re.search(r"\bNone\b", active_text):
        active_section_match = re.search(r"## Active routing(?P<body>[\s\S]*?)(?=\n## |\Z)", index_text, re.IGNORECASE)
        active_section = active_section_match.group("body") if active_section_match else ""
        if re.search(r"Local release complete|post-release pending|^\|\s*\d+\s*\|", active_section, re.IGNORECASE | re.MULTILINE):
            issues.append(CheckIssue("stale-milestone-routing", index_path, "active milestone is None but milestone index retains pending active routing"))
    rows = re.findall(r"^\|\s*(\d+)\s*\|\s*([^|]+)\|", index_text, re.MULTILINE)
    seen: dict[str, list[str]] = {}
    for number, status in rows:
        seen.setdefault(number, []).append(status.strip())
    for number, statuses in seen.items():
        if len(statuses) > 1 and any("Completed" in status or "Archived" in status for status in statuses):
            issues.append(CheckIssue("duplicate-milestone-routing", index_path, f"Milestone {number} has duplicate routing rows: {statuses}"))
    return issues

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


def _without_front_matter(text: str) -> str:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return text
    try:
        end = next(index for index, line in enumerate(lines[1:], start=1) if line.strip() == "---")
    except StopIteration:
        return text
    return "\n".join(lines[end + 1 :])


def _check_baseline(root: Path, version_override: str | None = None) -> list[CheckIssue]:
    version_path = root / "VERSION"
    readme_path = root / "README.md"
    changelog_path = root / "CHANGELOG.md"
    if not all(path.exists() for path in (version_path, readme_path, changelog_path)):
        return []

    version = version_override or version_path.read_text(encoding="utf-8").strip()
    readme_match = _README_VERSION_RE.search(readme_path.read_text(encoding="utf-8"))
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
        if _is_agent_skill(path, root):
            continue
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


def _check_adrs(root: Path, metadata_by_path: dict[Path, dict[str, object]]) -> list[CheckIssue]:
    adr_dir = root / "docs" / "adr"
    index_path = adr_dir / "README.md"
    canonical_files = sorted(path for path in adr_dir.glob("adr-*.md") if path.is_file())
    adr_metadata = {
        path: metadata_by_path.get(path, {})
        for path in canonical_files
    }
    issues: list[CheckIssue] = []

    index_rows = _parse_adr_index(index_path)
    indexed_files: set[str] = set()
    for identifier, file_name, state in index_rows:
        if state == "aggregate":
            continue
        indexed_files.add(file_name)
        target = adr_dir / file_name
        if not target.exists():
            issues.append(CheckIssue("missing-adr-file", index_path, f"{identifier} targets missing {file_name}"))

    for path in canonical_files:
        if path.name not in indexed_files:
            issues.append(CheckIssue("orphan-adr-file", path, "canonical ADR is not listed as extracted in index"))

    records: dict[str, tuple[Path, dict[str, object]]] = {}
    for path, metadata in adr_metadata.items():
        identifier = metadata.get("id")
        match = _ADR_ID_RE.fullmatch(identifier) if isinstance(identifier, str) else None
        if not match:
            issues.append(CheckIssue("invalid-adr-id", path, f"expected ADR-NNN, found {identifier!r}"))
            continue
        file_match = _ADR_FILE_RE.fullmatch(path.name)
        if not file_match or file_match.group(1) != match.group(1):
            issues.append(
                CheckIssue("adr-filename-mismatch", path, f"id {identifier} does not match filename {path.name}")
            )
        records[identifier] = (path, metadata)

    for identifier, (path, metadata) in records.items():
        supersedes = _metadata_list(metadata, "supersedes")
        superseded_by = _metadata_list(metadata, "superseded_by")
        if metadata.get("status") == "superseded" and not superseded_by:
            issues.append(CheckIssue("superseded-without-successor", path, f"{identifier} has no superseded_by target"))
        for relation, targets in (("supersedes", supersedes), ("superseded_by", superseded_by)):
            for target in targets:
                if target == identifier:
                    issues.append(CheckIssue("adr-self-edge", path, f"{identifier} has self edge in {relation}"))
                    continue
                target_record = records.get(target)
                if target_record is None:
                    issues.append(CheckIssue("missing-adr-target", path, f"{relation} target {target} does not exist"))
                    continue
                reverse_key = "superseded_by" if relation == "supersedes" else "supersedes"
                if identifier not in _metadata_list(target_record[1], reverse_key):
                    issues.append(
                        CheckIssue(
                            "non-reciprocal-adr-edge",
                            path,
                            f"{identifier} {relation} {target} lacks reciprocal {reverse_key}",
                        )
                    )

    graph = {
        identifier: [target for target in _metadata_list(metadata, "superseded_by") if target in records]
        for identifier, (_, metadata) in records.items()
    }
    for identifier in _cycle_nodes(graph):
        issues.append(CheckIssue("adr-supersession-cycle", records[identifier][0], f"{identifier} is in a cycle"))

    aggregate_path = root / "docs" / "architecture_decisions.md"
    aggregate_metadata = metadata_by_path.get(aggregate_path, {})
    if aggregate_metadata.get("status") == "legacy":
        extracted = {identifier for identifier, _, state in index_rows if state == "extracted"}
        expected = _expected_adr_coverage(extracted)
        if extracted != expected:
            missing = sorted(expected - extracted)
            extra = sorted(extracted - expected)
            highest = max(int(identifier.removeprefix("ADR-")) for identifier in expected)
            issues.append(
                CheckIssue(
                    "incomplete-adr-coverage",
                    index_path,
                    f"expected ADR-001..ADR-{highest:03d}; missing={missing}, extra={extra}",
                )
            )

    for name in (
        "000-template-positioning.md",
        "001-why-bloc.md",
        "002-why-get-it-and-injectable.md",
        "003-why-flutter-hooks-and-hooked-bloc.md",
        "004-why-freezed-and-json-serializable.md",
        "005-why-auto-route.md",
    ):
        path = adr_dir / name
        if not path.exists():
            continue
        metadata = metadata_by_path.get(path, {})
        text = path.read_text(encoding="utf-8")
        if metadata.get("status") != "legacy" or "[Canonical ADR index](README.md)" not in text:
            issues.append(
                CheckIssue(
                    "invalid-legacy-adr-route",
                    path,
                    "managed legacy ADR path must declare legacy metadata and link to README.md",
                )
            )
    return issues


def _expected_adr_coverage(extracted: set[str]) -> set[str]:
    numbers = [int(identifier.removeprefix("ADR-")) for identifier in extracted]
    highest = max([27, *numbers])
    return {f"ADR-{number:03d}" for number in range(1, highest + 1)}


def _parse_adr_index(path: Path) -> list[tuple[str, str, str]]:
    if not path.exists():
        return []
    rows: list[tuple[str, str, str]] = []
    for line in _without_fenced_code(path.read_text(encoding="utf-8")).splitlines():
        if match := _ADR_INDEX_ROW_RE.fullmatch(line.strip()):
            rows.append((match.group(1), match.group(2).strip().strip("`"), match.group(3)))
    return rows


def _metadata_list(metadata: dict[str, object], key: str) -> list[str]:
    value = metadata.get(key)
    if isinstance(value, list):
        return [item for item in value if isinstance(item, str) and item]
    if value in (None, "[]"):
        return []
    return [value] if isinstance(value, str) and value else []


def _cycle_nodes(graph: dict[str, list[str]]) -> set[str]:
    visited: set[str] = set()
    active: list[str] = []
    active_set: set[str] = set()
    cycles: set[str] = set()

    def visit(node: str) -> None:
        if node in active_set:
            cycles.update(active[active.index(node) :])
            return
        if node in visited:
            return
        visited.add(node)
        active.append(node)
        active_set.add(node)
        for target in graph.get(node, []):
            visit(target)
        active.pop()
        active_set.remove(node)

    for node in graph:
        visit(node)
    return cycles


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
    parser.add_argument(
        "--manifest",
        type=Path,
        help="validate docs against a prospective repository identity manifest",
    )
    parser.add_argument(
        "--version",
        help="validate docs against a prospective repository VERSION together with --manifest",
    )
    args = parser.parse_args(argv)
    if args.version is not None and args.manifest is None:
        parser.error("--version requires --manifest")
    root = Path(args.root).resolve()
    issues = check_repository(root, args.manifest, args.version)
    if issues:
        for issue in issues:
            print(issue.format(root))
        print(f"Documentation check failed with {len(issues)} issue(s).")
        return 1
    print("Documentation check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
