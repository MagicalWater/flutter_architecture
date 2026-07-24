#!/usr/bin/env python3
"""Generate a deterministic repository test inventory using stdlib only."""

from __future__ import annotations

import argparse
import ast
import csv
import re
import subprocess
from pathlib import Path
from typing import Iterable


DART_CASE_RE = re.compile(r"\b(?:test|testWidgets|blocTest)\s*(?:<[^>]+>)?\s*\(")

FIELDNAMES = [
    "path",
    "suite",
    "type",
    "loc",
    "static_cases",
    "primary_category",
    "coverage_owner",
    "implementation_classification",
    "execution_tier",
    "disposition",
    "replacement_or_notes",
]


def count_dart_cases(source: str) -> int:
    return len(DART_CASE_RE.findall(source))


def count_python_cases(source: str) -> int:
    tree = ast.parse(source)
    return sum(
        1
        for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
        and node.name.startswith("test_")
    )


def _is_test_path(path: Path) -> bool:
    normalized = path.as_posix()
    return (
        path.name.endswith("_test.dart")
        or (path.name.startswith("test_") and path.suffix == ".py")
        or "/integration_test/" in f"/{normalized}"
        and path.suffix == ".dart"
    )


def discover_test_files(root: Path) -> list[Path]:
    try:
        output = subprocess.check_output(
            ["git", "ls-files"], cwd=root, text=True, stderr=subprocess.DEVNULL
        )
        candidates = [root / line for line in output.splitlines() if line]
    except (subprocess.CalledProcessError, FileNotFoundError):
        candidates = [path for path in root.rglob("*") if path.is_file()]
    return sorted(
        (path for path in candidates if path.is_file() and _is_test_path(path)),
        key=lambda path: path.relative_to(root).as_posix(),
    )


def classify_suite(relative: str) -> str:
    path = relative.lower()
    if "catalog" in path:
        return "Catalog"
    if any(token in path for token in ("auth", "credential", "session", "local_unlock")):
        return "Auth"
    if "database" in path or "drift" in path or "sqflite" in path:
        return "Database"
    if "observability" in path or "error_reporting" in path:
        return "Observability"
    if "design_system" in path:
        return "Design System"
    if "theme" in path:
        return "Theme"
    if "localization" in path or "locale" in path:
        return "Localization"
    if "connectivity" in path:
        return "Connectivity"
    if "platform" in path or "ios_" in path or "android_" in path:
        return "Platform"
    if relative.startswith("tools/ci/"):
        return "CI"
    if relative.startswith("tools/docs/"):
        return "Documentation"
    if relative.startswith("packages/api_client/"):
        return "API Client"
    return "Other"


def classify_metadata(relative: str, suite: str) -> dict[str, str]:
    path = relative.lower()
    historical = any(
        token in path
        for token in (
            "historical",
            "legacy_fixture",
            "rollback_compatibility",
            "expected_migration",
            "milestone_19_5",
        )
    )
    if historical:
        return {
            "primary_category": "Historical-only",
            "coverage_owner": "Historical compatibility harness",
            "implementation_classification": "historical",
            "execution_tier": "Tier 4",
            "disposition": "Keep/Audit",
            "replacement_or_notes": "Migration, rollback or fixture oracle; do not delete by name.",
        }
    if relative.startswith("tools/ci/"):
        return {
            "primary_category": "CI",
            "coverage_owner": "CI tooling",
            "implementation_classification": "current",
            "execution_tier": "Tier 1",
            "disposition": "Audit",
            "replacement_or_notes": "Review duplicate workflow and classifier assertions.",
        }
    if relative.startswith("tools/docs/"):
        return {
            "primary_category": "CI",
            "coverage_owner": "Documentation tooling",
            "implementation_classification": "current",
            "execution_tier": "Tier 1",
            "disposition": "Keep/Audit",
            "replacement_or_notes": "Documentation governance contract.",
        }
    if "golden" in path:
        category = "Visual"
    elif suite in {"Platform"}:
        category = "Platform"
    elif "migration" in path:
        category = "Migration compatibility"
    elif any(token in path for token in ("di/", "contract", "boundary")):
        category = "Architecture boundary"
    elif any(token in path for token in ("store", "adapter", "dao", "data_source")):
        category = "Implementation contract"
    else:
        category = "Business invariant"
    notes = "Focused ownership review required."
    classification = "current"
    disposition = "Keep/Audit"
    if "sqflite_auth_user_store_test.dart" in path:
        classification = "historical-mixed"
        disposition = "Rewrite/Archive"
        notes = "Historical implementation contract; separate from current Drift owner."
    elif suite == "Catalog" and "test/features/catalog/data/" in path:
        classification = "current-with-historical-fixture"
        disposition = "Rewrite/Audit"
        notes = "Verify whether current behavior should use Drift or a narrow fake."
    return {
        "primary_category": category,
        "coverage_owner": suite,
        "implementation_classification": classification,
        "execution_tier": "Tier 1",
        "disposition": disposition,
        "replacement_or_notes": notes,
    }


def inventory_rows(root: Path, files: Iterable[Path]) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for path in sorted(files, key=lambda item: item.relative_to(root).as_posix()):
        relative = path.relative_to(root).as_posix()
        source = path.read_text(encoding="utf-8")
        file_type = "dart" if path.suffix == ".dart" else "python"
        suite = classify_suite(relative)
        metadata = classify_metadata(relative, suite)
        rows.append(
            {
                "path": relative,
                "suite": suite,
                "type": file_type,
                "loc": len(source.splitlines()),
                "static_cases": count_dart_cases(source)
                if file_type == "dart"
                else count_python_cases(source),
                **metadata,
            }
        )
    return rows


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=FIELDNAMES,
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("docs/audits/milestone_30/30-2_test_inventory.csv"),
    )
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    rows = inventory_rows(root, discover_test_files(root))
    write_csv(output, rows)
    print(
        f"files={len(rows)} loc={sum(int(row['loc']) for row in rows)} "
        f"cases={sum(int(row['static_cases']) for row in rows)} output={output.relative_to(root)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
