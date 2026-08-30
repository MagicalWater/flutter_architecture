from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path


CANONICAL_TEMPLATE_REPOSITORY = "MagicalWater/flutter_architecture"
SUPPORTED_SCHEMA_VERSION = 1
VALID_REPOSITORY_KINDS = {"template", "product"}
_SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
_TOP_LEVEL_FIELDS = {
    "schema_version",
    "repository_kind",
    "product_name",
    "template_origin",
}
_ORIGIN_FIELDS = {"repository", "baseline"}


@dataclass(frozen=True)
class RepositoryIdentityIssue:
    code: str
    path: Path
    message: str

    def format(self, root: Path) -> str:
        try:
            display_path = self.path.relative_to(root)
        except ValueError:
            display_path = self.path
        return f"[{self.code}] {display_path}: {self.message}"


def check_repository_identity(
    root: Path,
    manifest_path: Path | None = None,
    version_override: str | None = None,
) -> list[RepositoryIdentityIssue]:
    root = root.resolve()
    manifest = (manifest_path or root / "repository_identity.json").resolve()
    version_path = root / "VERSION"

    if not manifest.is_file():
        return [
            RepositoryIdentityIssue(
                "missing-repository-identity",
                manifest,
                "repository identity manifest is required; lifecycle must fail closed",
            )
        ]

    try:
        payload = json.loads(manifest.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return [
            RepositoryIdentityIssue(
                "invalid-repository-identity-json",
                manifest,
                f"unable to parse repository identity JSON: {error}",
            )
        ]

    if not isinstance(payload, dict):
        return [
            RepositoryIdentityIssue(
                "invalid-repository-identity-json",
                manifest,
                "repository identity root must be a JSON object",
            )
        ]

    issues: list[RepositoryIdentityIssue] = []
    _check_unexpected_fields(issues, manifest, payload, _TOP_LEVEL_FIELDS)

    schema_version = payload.get("schema_version")
    if (
        not isinstance(schema_version, int)
        or isinstance(schema_version, bool)
        or schema_version != SUPPORTED_SCHEMA_VERSION
    ):
        issues.append(
            RepositoryIdentityIssue(
                "unsupported-repository-identity-schema",
                manifest,
                f"schema_version must be {SUPPORTED_SCHEMA_VERSION}",
            )
        )

    repository_kind = payload.get("repository_kind")
    if repository_kind not in VALID_REPOSITORY_KINDS:
        issues.append(
            RepositoryIdentityIssue(
                "invalid-repository-kind",
                manifest,
                "repository_kind must be 'template' or 'product'",
            )
        )

    origin = payload.get("template_origin")
    if not isinstance(origin, dict):
        issues.append(
            RepositoryIdentityIssue(
                "invalid-template-origin",
                manifest,
                "template_origin must be a JSON object",
            )
        )
        origin = {}
    else:
        _check_unexpected_fields(issues, manifest, origin, _ORIGIN_FIELDS)

    origin_repository = origin.get("repository")
    origin_baseline = origin.get("baseline")
    product_name = payload.get("product_name")
    version = version_override if version_override is not None else _read_version(version_path, issues)
    if version_override is not None and not _SEMVER_RE.fullmatch(version_override):
        issues.append(
            RepositoryIdentityIssue(
                "invalid-repository-version",
                version_path,
                "prospective VERSION must use semantic version format",
            )
        )

    if repository_kind == "template":
        if product_name is not None:
            issues.append(
                RepositoryIdentityIssue(
                    "template-product-name-present",
                    manifest,
                    "template repository must keep product_name null",
                )
            )
        if origin_repository != CANONICAL_TEMPLATE_REPOSITORY:
            issues.append(
                RepositoryIdentityIssue(
                    "template-origin-repository-mismatch",
                    manifest,
                    f"template origin repository must be {CANONICAL_TEMPLATE_REPOSITORY}",
                )
            )
        if not isinstance(origin_baseline, str) or not _SEMVER_RE.fullmatch(origin_baseline):
            issues.append(
                RepositoryIdentityIssue(
                    "invalid-template-origin-baseline",
                    manifest,
                    "template_origin.baseline must use semantic version format",
                )
            )
        elif version is not None and origin_baseline != version:
            issues.append(
                RepositoryIdentityIssue(
                    "template-origin-baseline-mismatch",
                    manifest,
                    f"template origin baseline {origin_baseline} must equal VERSION {version}",
                )
            )

    if repository_kind == "product":
        if not isinstance(product_name, str) or not product_name.strip():
            issues.append(
                RepositoryIdentityIssue(
                    "product-name-missing",
                    manifest,
                    "product repository requires a non-empty product_name",
                )
            )
        if not isinstance(origin_repository, str) or not origin_repository.strip():
            issues.append(
                RepositoryIdentityIssue(
                    "product-template-origin-repository-missing",
                    manifest,
                    "product repository requires template_origin.repository",
                )
            )
        if not isinstance(origin_baseline, str) or not _SEMVER_RE.fullmatch(origin_baseline):
            issues.append(
                RepositoryIdentityIssue(
                    "invalid-template-origin-baseline",
                    manifest,
                    "template_origin.baseline must use semantic version format",
                )
            )
        if version is None or not _SEMVER_RE.fullmatch(version):
            issues.append(
                RepositoryIdentityIssue(
                    "invalid-product-version",
                    version_path,
                    "product VERSION must use semantic version format",
                )
            )

    return sorted(issues, key=lambda issue: (issue.code, str(issue.path), issue.message))


def _read_version(
    version_path: Path,
    issues: list[RepositoryIdentityIssue],
) -> str | None:
    if not version_path.is_file():
        issues.append(
            RepositoryIdentityIssue(
                "missing-repository-version",
                version_path,
                "VERSION is required by repository identity contract",
            )
        )
        return None
    try:
        return version_path.read_text(encoding="utf-8").strip()
    except (OSError, UnicodeError) as error:
        issues.append(
            RepositoryIdentityIssue(
                "invalid-repository-version",
                version_path,
                f"unable to read VERSION: {error}",
            )
        )
        return None


def _check_unexpected_fields(
    issues: list[RepositoryIdentityIssue],
    manifest: Path,
    payload: dict[str, object],
    expected: set[str],
) -> None:
    for field in sorted(set(payload) - expected):
        issues.append(
            RepositoryIdentityIssue(
                "unexpected-repository-identity-field",
                manifest,
                f"unexpected repository identity field: {field}",
            )
        )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Verify repository lifecycle identity")
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument(
        "--manifest",
        type=Path,
        help="validate a prospective identity manifest without replacing the canonical file",
    )
    parser.add_argument(
        "--version",
        help="validate a prospective VERSION together with --manifest without replacing canonical VERSION",
    )
    arguments = parser.parse_args(argv)
    root = Path(arguments.root).resolve()
    if arguments.version is not None and arguments.manifest is None:
        parser.error("--version requires --manifest")
    issues = check_repository_identity(root, arguments.manifest, arguments.version)
    for issue in issues:
        print(issue.format(root), file=sys.stderr)
    if issues:
        return 1
    print("Repository identity check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
