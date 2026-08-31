from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path


_COMMIT_RE = re.compile(r"^[0-9a-f]{40}$")
_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
_OWNERSHIP_VALUES = {
    "repository-authored",
    "third-party-unmodified",
    "repository-maintained-fork",
}


@dataclass(frozen=True)
class SkillLockIssue:
    code: str
    path: Path
    message: str


@dataclass(frozen=True)
class SkillLockInspection:
    exempt_markdown_paths: frozenset[Path]
    issues: tuple[SkillLockIssue, ...]


def inspect_skill_lock(root: Path) -> SkillLockInspection:
    root = root.resolve()
    lock_path = root / "skills-lock.json"
    if not lock_path.exists():
        return SkillLockInspection(frozenset(), ())

    try:
        payload = json.loads(lock_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return SkillLockInspection(
            frozenset(),
            (
                SkillLockIssue(
                    "skill-lock-invalid-json",
                    lock_path,
                    f"cannot decode skills-lock.json: {error}",
                ),
            ),
        )

    issues: list[SkillLockIssue] = []
    if not isinstance(payload, dict) or payload.get("version") != 1:
        issues.append(
            SkillLockIssue(
                "skill-lock-invalid-schema",
                lock_path,
                "root object must declare version 1",
            )
        )
        return SkillLockInspection(frozenset(), tuple(issues))

    skills = payload.get("skills")
    if not isinstance(skills, dict):
        issues.append(
            SkillLockIssue(
                "skill-lock-invalid-schema",
                lock_path,
                "skills must be an object",
            )
        )
        return SkillLockInspection(frozenset(), tuple(issues))

    exemptions: set[Path] = set()
    install_owners: dict[Path, str] = {}
    for skill_name, raw_entry in skills.items():
        skill_issue_start = len(issues)
        if not isinstance(skill_name, str) or not skill_name or not isinstance(raw_entry, dict):
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    "each skill entry must use a non-empty string name and object value",
                )
            )
            continue

        ownership = raw_entry.get("ownership")
        if ownership not in _OWNERSHIP_VALUES:
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-ownership",
                    lock_path,
                    f"{skill_name} has unsupported ownership {ownership!r}",
                )
            )

        source = raw_entry.get("source")
        if not isinstance(source, dict):
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    f"{skill_name}.source must be an object",
                )
            )
        else:
            commit = source.get("commit")
            if not isinstance(commit, str) or not _COMMIT_RE.fullmatch(commit):
                issues.append(
                    SkillLockIssue(
                        "skill-lock-invalid-commit",
                        lock_path,
                        f"{skill_name}.source.commit must be 40-character lowercase hex",
                    )
                )
            for field in ("repository", "path"):
                if not isinstance(source.get(field), str) or not source[field]:
                    issues.append(
                        SkillLockIssue(
                            "skill-lock-invalid-schema",
                            lock_path,
                            f"{skill_name}.source.{field} must be a non-empty string",
                        )
                    )

        install_raw = raw_entry.get("installPath")
        install_path = _resolve_relative_within(root, install_raw)
        if install_path is None:
            issues.append(
                SkillLockIssue(
                    "skill-lock-install-path-escape",
                    lock_path,
                    f"{skill_name}.installPath must stay inside repository root",
                )
            )
            continue
        previous_owner = install_owners.get(install_path)
        if previous_owner is not None:
            issues.append(
                SkillLockIssue(
                    "skill-lock-duplicate-install-path",
                    lock_path,
                    f"{skill_name} and {previous_owner} share {install_path.relative_to(root)}",
                )
            )
        else:
            install_owners[install_path] = skill_name

        locked_files = _inspect_locked_files(
            root=root,
            lock_path=lock_path,
            skill_name=skill_name,
            install_path=install_path,
            raw_files=raw_entry.get("files"),
            issues=issues,
        )
        _inspect_license(
            root=root,
            lock_path=lock_path,
            skill_name=skill_name,
            raw_license=raw_entry.get("license"),
            issues=issues,
        )

        if ownership == "third-party-unmodified" and len(issues) == skill_issue_start:
            exemptions.update(
                path for path in locked_files if path.suffix.lower() == ".md"
            )

    sorted_issues = tuple(
        sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))
    )
    # third-party-unmodified 的語言豁免是整份 lock 的信任結果；任一 skill/file
    # integrity issue 都必須撤銷所有 exemption，不能只保留「看似沒壞」的項目。
    return SkillLockInspection(
        frozenset() if sorted_issues else frozenset(exemptions),
        sorted_issues,
    )


def _inspect_locked_files(
    *,
    root: Path,
    lock_path: Path,
    skill_name: str,
    install_path: Path,
    raw_files: object,
    issues: list[SkillLockIssue],
) -> set[Path]:
    if not isinstance(raw_files, list):
        issues.append(
            SkillLockIssue(
                "skill-lock-invalid-schema",
                lock_path,
                f"{skill_name}.files must be a list",
            )
        )
        return set()

    locked_files: set[Path] = set()
    for index, raw_file in enumerate(raw_files):
        if not isinstance(raw_file, dict):
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    f"{skill_name}.files[{index}] must be an object",
                )
            )
            continue
        relative_path = raw_file.get("path")
        file_path = _resolve_relative_within(install_path, relative_path)
        if file_path is None:
            issues.append(
                SkillLockIssue(
                    "skill-lock-file-path-escape",
                    lock_path,
                    f"{skill_name}.files[{index}].path must stay inside installPath",
                )
            )
            continue
        if file_path in locked_files:
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    f"{skill_name} lists duplicate file {relative_path!r}",
                )
            )
            continue
        locked_files.add(file_path)

        expected_hash = raw_file.get("sha256")
        if not isinstance(expected_hash, str) or not _SHA256_RE.fullmatch(expected_hash):
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    f"{skill_name}.files[{index}].sha256 must be 64-character lowercase hex",
                )
            )
            continue
        if not file_path.is_file():
            issues.append(
                SkillLockIssue(
                    "skill-lock-missing-file",
                    file_path,
                    f"locked file is missing for {skill_name}",
                )
            )
            continue
        actual_hash = _sha256(file_path)
        if actual_hash != expected_hash:
            issues.append(
                SkillLockIssue(
                    "skill-lock-hash-drift",
                    file_path,
                    f"expected {expected_hash}, found {actual_hash}",
                )
            )

    actual_files = {
        path.resolve()
        for path in install_path.rglob("*")
        if path.is_file()
    } if install_path.is_dir() else set()
    for unknown in sorted(actual_files - locked_files):
        issues.append(
            SkillLockIssue(
                "skill-lock-unknown-file",
                unknown,
                f"file exists under {skill_name}.installPath but is absent from lock inventory",
            )
        )
    return locked_files


def _inspect_license(
    *,
    root: Path,
    lock_path: Path,
    skill_name: str,
    raw_license: object,
    issues: list[SkillLockIssue],
) -> None:
    if not isinstance(raw_license, dict):
        issues.append(
            SkillLockIssue(
                "skill-lock-invalid-schema",
                lock_path,
                f"{skill_name}.license must be an object",
            )
        )
        return

    for field in ("identity", "sourcePath"):
        if not isinstance(raw_license.get(field), str) or not raw_license[field]:
            issues.append(
                SkillLockIssue(
                    "skill-lock-invalid-schema",
                    lock_path,
                    f"{skill_name}.license.{field} must be a non-empty string",
                )
            )

    license_path = _resolve_relative_within(root, raw_license.get("localPath"))
    if license_path is None:
        issues.append(
            SkillLockIssue(
                "skill-lock-license-path-escape",
                lock_path,
                f"{skill_name}.license.localPath must stay inside repository root",
            )
        )
        return
    expected_hash = raw_license.get("sha256")
    if not isinstance(expected_hash, str) or not _SHA256_RE.fullmatch(expected_hash):
        issues.append(
            SkillLockIssue(
                "skill-lock-invalid-schema",
                lock_path,
                f"{skill_name}.license.sha256 must be 64-character lowercase hex",
            )
        )
        return
    if not license_path.is_file():
        issues.append(
            SkillLockIssue(
                "skill-lock-missing-license",
                license_path,
                f"locked license is missing for {skill_name}",
            )
        )
        return
    actual_hash = _sha256(license_path)
    if actual_hash != expected_hash:
        issues.append(
            SkillLockIssue(
                "skill-lock-license-hash-drift",
                license_path,
                f"expected {expected_hash}, found {actual_hash}",
            )
        )


def _resolve_relative_within(base: Path, raw_path: object) -> Path | None:
    if not isinstance(raw_path, str) or not raw_path:
        return None
    path = Path(raw_path)
    if path.is_absolute():
        return None
    resolved_base = base.resolve()
    resolved_path = (resolved_base / path).resolve()
    try:
        resolved_path.relative_to(resolved_base)
    except ValueError:
        return None
    return resolved_path


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()
