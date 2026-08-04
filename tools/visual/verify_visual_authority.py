from __future__ import annotations

import hashlib
import math
import re
from dataclasses import dataclass
from pathlib import Path


_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
_TABLE_HEADER = ("Role", "Path", "SHA-256", "Authority status")
_ROLE_STATUS = {
    "primary-source": "primary",
    "derived-preview": "derived",
    "supplementary-reference": "supplementary",
    "historical-benchmark": "benchmark",
}


@dataclass(frozen=True)
class VisualAuthorityIssue:
    code: str
    path: Path
    message: str


@dataclass(frozen=True)
class _AuthorityRow:
    role: str
    raw_path: str
    sha256: str
    status: str


def verify_visual_authority(
    root: Path,
    manifest: Path,
) -> tuple[VisualAuthorityIssue, ...]:
    root = root.resolve()
    manifest = manifest.resolve()
    issues: list[VisualAuthorityIssue] = []
    if not _is_within(manifest, root):
        return (
            VisualAuthorityIssue(
                "visual-authority-manifest-path-escape",
                manifest,
                "manifest must stay inside repository root",
            ),
        )
    if not manifest.is_file():
        return (
            VisualAuthorityIssue(
                "visual-authority-missing-manifest",
                manifest,
                "visual authority manifest is missing",
            ),
        )

    try:
        text = manifest.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        return (
            VisualAuthorityIssue(
                "visual-authority-invalid-manifest",
                manifest,
                f"cannot read manifest: {error}",
            ),
        )

    metadata, body_lines = _parse_frontmatter(text)
    if metadata is None:
        return (
            VisualAuthorityIssue(
                "visual-authority-invalid-manifest",
                manifest,
                "manifest must contain valid YAML-like frontmatter",
            ),
        )

    _check_required_metadata(manifest, metadata, issues)
    _check_viewport(manifest, metadata, issues)
    rows = _parse_table(manifest, body_lines, issues)
    _check_rows(root, manifest, metadata, rows, issues)

    return tuple(
        sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))
    )


def _check_required_metadata(
    manifest: Path,
    metadata: dict[str, str],
    issues: list[VisualAuthorityIssue],
) -> None:
    expected = {
        "document_type": "runtime-evidence",
        "status": "accepted",
    }
    for key, value in expected.items():
        if metadata.get(key) != value:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-invalid-metadata",
                    manifest,
                    f"{key} must equal {value!r}",
                )
            )
    for key in (
        "initiative",
        "authority_file",
        "authority_sha256",
        "canonical_width",
        "canonical_height",
        "canonical_dpr",
    ):
        if not metadata.get(key):
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-invalid-metadata",
                    manifest,
                    f"missing required frontmatter key {key}",
                )
            )

    authority_hash = metadata.get("authority_sha256", "")
    if authority_hash and not _SHA256_RE.fullmatch(authority_hash):
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-metadata",
                manifest,
                "authority_sha256 must be 64-character lowercase hex",
            )
        )


def _check_viewport(
    manifest: Path,
    metadata: dict[str, str],
    issues: list[VisualAuthorityIssue],
) -> None:
    try:
        width = int(metadata["canonical_width"])
        height = int(metadata["canonical_height"])
        dpr = float(metadata["canonical_dpr"])
    except (KeyError, TypeError, ValueError):
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-viewport",
                manifest,
                "canonical viewport must use numeric width, height and DPR",
            )
        )
        return
    if width <= 0 or height <= 0 or dpr <= 0 or not math.isfinite(dpr):
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-viewport",
                manifest,
                "canonical width, height and DPR must be finite positive values",
            )
        )


def _parse_table(
    manifest: Path,
    body_lines: list[str],
    issues: list[VisualAuthorityIssue],
) -> tuple[_AuthorityRow, ...]:
    rows: list[_AuthorityRow] = []
    header_index: int | None = None
    for index, line in enumerate(body_lines):
        cells = _table_cells(line)
        if cells == _TABLE_HEADER:
            header_index = index
            break
    if header_index is None or header_index + 1 >= len(body_lines):
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-table",
                manifest,
                "manifest must contain the fixed Role/Path/SHA-256/Authority status table",
            )
        )
        return ()

    separator = _table_cells(body_lines[header_index + 1])
    if len(separator) != 4 or not all(cell and set(cell) <= {"-", ":"} for cell in separator):
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-table",
                manifest,
                "manifest table separator is invalid",
            )
        )
        return ()

    for line in body_lines[header_index + 2 :]:
        cells = _table_cells(line)
        if not cells:
            if rows:
                break
            continue
        if len(cells) != 4:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-invalid-table",
                    manifest,
                    f"table row must have four cells: {line}",
                )
            )
            continue
        rows.append(_AuthorityRow(*cells))
    if not rows:
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-invalid-table",
                manifest,
                "manifest table must contain authority rows",
            )
        )
    return tuple(rows)


def _check_rows(
    root: Path,
    manifest: Path,
    metadata: dict[str, str],
    rows: tuple[_AuthorityRow, ...],
    issues: list[VisualAuthorityIssue],
) -> None:
    role_counts: dict[str, int] = {}
    resolved_rows: dict[str, tuple[Path, _AuthorityRow]] = {}
    path_roles: dict[Path, str] = {}
    for row in rows:
        role_counts[row.role] = role_counts.get(row.role, 0) + 1
        if role_counts[row.role] > 1:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-duplicate-role",
                    manifest,
                    f"role {row.role!r} appears more than once",
                )
            )
        expected_status = _ROLE_STATUS.get(row.role)
        if expected_status is None:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-invalid-role",
                    manifest,
                    f"unsupported role {row.role!r}",
                )
            )
        elif row.status != expected_status:
            code = (
                "visual-authority-invalid-primary"
                if row.status == "primary" or row.role == "primary-source"
                else "visual-authority-invalid-status"
            )
            issues.append(
                VisualAuthorityIssue(
                    code,
                    manifest,
                    f"role {row.role!r} must use status {expected_status!r}",
                )
            )

        if not _SHA256_RE.fullmatch(row.sha256):
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-invalid-hash",
                    manifest,
                    f"role {row.role!r} must use 64-character lowercase SHA-256",
                )
            )
            continue
        resolved = _resolve_manifest_path(root, manifest, row.raw_path)
        if resolved is None:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-path-escape",
                    manifest,
                    f"role {row.role!r} path escapes repository root",
                )
            )
            continue
        previous_role = path_roles.get(resolved)
        if previous_role is not None:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-duplicate-file",
                    manifest,
                    f"roles {previous_role!r} and {row.role!r} share the same file",
                )
            )
        else:
            path_roles[resolved] = row.role
        resolved_rows[row.role] = (resolved, row)
        if not resolved.is_file():
            issues.append(
                VisualAuthorityIssue(
                    (
                        "visual-authority-missing-authority"
                        if row.role == "primary-source"
                        else "visual-authority-missing-file"
                    ),
                    resolved,
                    f"file for role {row.role!r} is missing",
                )
            )
            continue
        actual_hash = hashlib.sha256(resolved.read_bytes()).hexdigest()
        if actual_hash != row.sha256:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-hash-drift",
                    resolved,
                    f"role {row.role!r} expected {row.sha256}, found {actual_hash}",
                )
            )

    for required_role in _ROLE_STATUS:
        if role_counts.get(required_role, 0) == 0:
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-missing-role",
                    manifest,
                    f"required role {required_role!r} is missing",
                )
            )

    authority_path = _resolve_manifest_path(
        root,
        manifest,
        metadata.get("authority_file", ""),
    )
    if authority_path is None:
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-path-escape",
                manifest,
                "authority_file escapes repository root",
            )
        )
        return
    primary = resolved_rows.get("primary-source")
    if primary is not None and authority_path != primary[0]:
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-primary-mismatch",
                manifest,
                "authority_file must match the primary-source table path",
            )
        )
    if not authority_path.is_file():
        if not any(issue.code == "visual-authority-missing-authority" for issue in issues):
            issues.append(
                VisualAuthorityIssue(
                    "visual-authority-missing-authority",
                    authority_path,
                    "authority_file is missing",
                )
            )
        return
    actual_authority_hash = hashlib.sha256(authority_path.read_bytes()).hexdigest()
    expected_authority_hash = metadata.get("authority_sha256", "")
    if expected_authority_hash and actual_authority_hash != expected_authority_hash:
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-hash-drift",
                authority_path,
                f"authority_sha256 expected {expected_authority_hash}, found {actual_authority_hash}",
            )
        )
    if primary is not None and expected_authority_hash != primary[1].sha256:
        issues.append(
            VisualAuthorityIssue(
                "visual-authority-primary-mismatch",
                manifest,
                "authority_sha256 must match the primary-source table hash",
            )
        )


def _parse_frontmatter(text: str) -> tuple[dict[str, str] | None, list[str]]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None, lines
    try:
        end = next(index for index in range(1, len(lines)) if lines[index].strip() == "---")
    except StopIteration:
        return None, lines
    metadata: dict[str, str] = {}
    for line in lines[1:end]:
        if not line or line.startswith(" ") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        metadata[key.strip()] = value.strip().strip('"\'')
    return metadata, lines[end + 1 :]


def _table_cells(line: str) -> tuple[str, ...]:
    stripped = line.strip()
    if not stripped.startswith("|") or not stripped.endswith("|"):
        return ()
    return tuple(cell.strip() for cell in stripped[1:-1].split("|"))


def _resolve_manifest_path(root: Path, manifest: Path, raw_path: str) -> Path | None:
    path = Path(raw_path)
    if not raw_path or path.is_absolute():
        return None
    resolved = (manifest.parent / path).resolve()
    return resolved if _is_within(resolved, root) else None


def _is_within(path: Path, root: Path) -> bool:
    try:
        path.relative_to(root)
    except ValueError:
        return False
    return True
