from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path


_SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
_REPRESENTATION_CLASSES = {
    "Layout primitive",
    "Typography",
    "Approved package icon",
    "Vector asset",
    "Raster asset",
    "Dynamic drawing",
}
_DISPOSITIONS = {
    "exact",
    "verified-equivalent",
    "intentional-deviation",
    "unresolved",
}
_SCREEN_LAYOUT_MODELS = {
    "constraint-relationship",
    "intentional-spatial-canvas",
    "unresolved",
}
_UI_DESIGN_OWNERS = {
    "visual-authority",
    "design-system",
    "feature-local",
    "component-local",
}
_UI_DESIGN_DISPOSITIONS = {
    "exact",
    "verified-equivalent",
    "intentional-local",
    "promoted",
    "unresolved",
}
_UI_DESIGN_KINDS = {
    "visual-authority-metadata",
    "semantic-color",
    "typography",
    "geometry",
    "decoration",
    "asset-reference",
}


@dataclass(frozen=True)
class PencilImplementationMappingIssue:
    code: str
    path: Path
    message: str


def validate_implementation_mapping(
    mapping_path: Path,
    *,
    expected_authority_sha256: str | None = None,
    production_acceptance: bool = True,
) -> tuple[PencilImplementationMappingIssue, ...]:
    path = mapping_path.resolve()
    if not path.is_file():
        return (_issue("mapping-artifact-missing", path, "mapping artifact is missing"),)

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        return (_issue("mapping-invalid-json", path, f"cannot read mapping JSON: {error}"),)

    if not isinstance(data, dict):
        return (_issue("mapping-invalid-root", path, "mapping root must be an object"),)

    issues: list[PencilImplementationMappingIssue] = []
    _check_metadata(path, data, expected_authority_sha256, issues)
    _check_nodes(path, data.get("critical_nodes"), production_acceptance, issues)
    _check_screen_layouts(
        path,
        data.get("screen_layouts"),
        production_acceptance,
        issues,
    )
    _check_ui_design_ownerships(
        path,
        data.get("ui_design_ownerships"),
        production_acceptance,
        issues,
    )
    return tuple(sorted(issues, key=lambda issue: (issue.code, issue.message)))


def _check_metadata(
    path: Path,
    data: dict[str, object],
    expected_authority_sha256: str | None,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    if data.get("schema_version") != 2:
        issues.append(_issue("mapping-unsupported-schema", path, "schema_version must equal 2"))

    initiative = data.get("initiative")
    if not isinstance(initiative, str) or not initiative.strip():
        issues.append(_issue("mapping-missing-initiative", path, "initiative is required"))

    authority_hash = data.get("pencil_authority_sha256")
    if not isinstance(authority_hash, str) or not _SHA256_RE.fullmatch(authority_hash):
        issues.append(
            _issue(
                "mapping-invalid-authority-hash",
                path,
                "pencil_authority_sha256 must be 64-character lowercase hex",
            )
        )
    elif expected_authority_sha256 is not None and authority_hash != expected_authority_sha256:
        issues.append(
            _issue(
                "mapping-authority-hash-mismatch",
                path,
                "mapping authority hash does not match accepted visual authority",
            )
        )


def _check_nodes(
    path: Path,
    raw_nodes: object,
    production_acceptance: bool,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    if not isinstance(raw_nodes, list):
        issues.append(_issue("mapping-invalid-critical-nodes", path, "critical_nodes must be a list"))
        return

    seen_ids: set[str] = set()
    for index, raw_node in enumerate(raw_nodes):
        if not isinstance(raw_node, dict):
            issues.append(
                _issue("mapping-invalid-node", path, f"critical_nodes[{index}] must be an object")
            )
            continue

        node_id = raw_node.get("node_id")
        if not isinstance(node_id, str) or not node_id.strip():
            issues.append(_issue("mapping-missing-node-id", path, f"critical_nodes[{index}] needs node_id"))
            node_label = f"index {index}"
        else:
            node_label = node_id
            if node_id in seen_ids:
                issues.append(
                    _issue("mapping-duplicate-node-id", path, f"duplicate critical node ID {node_id!r}")
                )
            seen_ids.add(node_id)

        for field in ("role", "flutter_owner", "consumer"):
            value = raw_node.get(field)
            if not isinstance(value, str) or not value.strip():
                issues.append(
                    _issue("mapping-missing-owner-field", path, f"{node_label}: {field} is required")
                )

        representation = raw_node.get("representation_class")
        if representation not in _REPRESENTATION_CLASSES:
            issues.append(
                _issue(
                    "mapping-unknown-representation-class",
                    path,
                    f"{node_label}: unsupported representation_class {representation!r}",
                )
            )

        disposition = raw_node.get("disposition")
        if disposition not in _DISPOSITIONS:
            issues.append(
                _issue(
                    "mapping-unknown-disposition",
                    path,
                    f"{node_label}: unsupported disposition {disposition!r}",
                )
            )
        elif disposition == "unresolved" and production_acceptance:
            issues.append(
                _issue("mapping-unresolved", path, f"{node_label}: unresolved mapping blocks acceptance")
            )
        elif disposition == "verified-equivalent" and not _non_empty(raw_node.get("evidence_ref")):
            issues.append(
                _issue(
                    "mapping-missing-equivalence-evidence",
                    path,
                    f"{node_label}: verified-equivalent requires evidence_ref",
                )
            )
        elif disposition == "intentional-deviation" and not _non_empty(raw_node.get("approval_ref")):
            issues.append(
                _issue(
                    "mapping-missing-deviation-approval",
                    path,
                    f"{node_label}: intentional-deviation requires approval_ref",
                )
            )

        if representation in {"Raster asset", "Vector asset"}:
            _check_asset_provenance(path, node_label, raw_node.get("asset"), issues)


def _check_screen_layouts(
    path: Path,
    raw_layouts: object,
    production_acceptance: bool,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    if not isinstance(raw_layouts, list) or not raw_layouts:
        issues.append(
            _issue(
                "mapping-missing-screen-layouts",
                path,
                "screen_layouts must contain at least one accepted screen root",
            )
        )
        return

    seen_ids: set[str] = set()
    for index, raw_layout in enumerate(raw_layouts):
        if not isinstance(raw_layout, dict):
            issues.append(
                _issue(
                    "mapping-invalid-screen-layout",
                    path,
                    f"screen_layouts[{index}] must be an object",
                )
            )
            continue

        node_id = raw_layout.get("node_id")
        if not _non_empty(node_id):
            issues.append(
                _issue(
                    "mapping-missing-screen-layout-node-id",
                    path,
                    f"screen_layouts[{index}] requires node_id",
                )
            )
            label = f"index {index}"
        else:
            assert isinstance(node_id, str)
            label = node_id
            if node_id in seen_ids:
                issues.append(
                    _issue(
                        "mapping-duplicate-screen-layout-node-id",
                        path,
                        f"duplicate screen layout node ID {node_id!r}",
                    )
                )
            seen_ids.add(node_id)

        if not _non_empty(raw_layout.get("flutter_owner")):
            issues.append(
                _issue(
                    "mapping-missing-screen-layout-owner",
                    path,
                    f"{label}: flutter_owner is required",
                )
            )

        model = raw_layout.get("layout_model")
        if model not in _SCREEN_LAYOUT_MODELS:
            issues.append(
                _issue(
                    "mapping-unknown-screen-layout-model",
                    path,
                    f"{label}: unsupported layout_model {model!r}",
                )
            )
            continue

        if model == "unresolved" and production_acceptance:
            issues.append(
                _issue(
                    "mapping-screen-layout-unresolved",
                    path,
                    f"{label}: unresolved screen layout blocks acceptance",
                )
            )
        elif model == "intentional-spatial-canvas" and not _non_empty(
            raw_layout.get("approval_ref")
        ):
            issues.append(
                _issue(
                    "mapping-missing-spatial-canvas-approval",
                    path,
                    f"{label}: intentional-spatial-canvas requires approval_ref",
                )
            )

        if model != "unresolved":
            evidence_ref = raw_layout.get("evidence_ref")
            if not _non_empty(evidence_ref):
                issues.append(
                    _issue(
                        "mapping-missing-screen-layout-evidence",
                        path,
                        f"{label}: resolved screen layout requires evidence_ref",
                    )
                )
            else:
                assert isinstance(evidence_ref, str)
                _check_live_repository_reference(path, label, evidence_ref, issues)


def _check_live_repository_reference(
    mapping_path: Path,
    label: str,
    evidence_ref: str,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    repository_root = _find_repository_root(mapping_path.parent)
    if repository_root is None:
        issues.append(
            _issue(
                "mapping-repository-root-unresolved",
                mapping_path,
                f"{label}: cannot resolve repository root for evidence_ref",
            )
        )
        return

    reference_path = Path(evidence_ref)
    if reference_path.is_absolute():
        issues.append(
            _issue(
                "mapping-evidence-outside-repository",
                mapping_path,
                f"{label}: evidence_ref must be repository-relative",
            )
        )
        return

    resolved = (repository_root / reference_path).resolve()
    try:
        resolved.relative_to(repository_root)
    except ValueError:
        issues.append(
            _issue(
                "mapping-evidence-outside-repository",
                mapping_path,
                f"{label}: evidence_ref escapes repository root",
            )
        )
        return

    if not resolved.is_file():
        issues.append(
            _issue(
                "mapping-evidence-missing",
                mapping_path,
                f"{label}: evidence_ref does not resolve to a live file: {evidence_ref}",
            )
        )


def _find_repository_root(start: Path) -> Path | None:
    current = start.resolve()
    for candidate in (current, *current.parents):
        if (candidate / "repository_identity.json").is_file():
            return candidate
    return None


def _check_ui_design_ownerships(
    path: Path,
    raw_ownerships: object,
    production_acceptance: bool,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    if not isinstance(raw_ownerships, list) or not raw_ownerships:
        issues.append(
            _issue(
                "mapping-missing-ui-design-ownerships",
                path,
                "ui_design_ownerships must contain risk-selected UI design ownership evidence",
            )
        )
        return

    seen_ids: set[str] = set()
    for index, raw_ownership in enumerate(raw_ownerships):
        if not isinstance(raw_ownership, dict):
            issues.append(
                _issue(
                    "mapping-invalid-ui-design-ownership",
                    path,
                    f"ui_design_ownerships[{index}] must be an object",
                )
            )
            continue

        ownership_id = raw_ownership.get("id")
        if not _non_empty(ownership_id):
            issues.append(
                _issue(
                    "mapping-missing-ui-design-ownership-id",
                    path,
                    f"ui_design_ownerships[{index}] requires id",
                )
            )
            label = f"index {index}"
        else:
            assert isinstance(ownership_id, str)
            label = ownership_id
            if ownership_id in seen_ids:
                issues.append(
                    _issue(
                        "mapping-duplicate-ui-design-ownership-id",
                        path,
                        f"duplicate UI design ownership ID {ownership_id!r}",
                    )
                )
            seen_ids.add(ownership_id)

        kind = raw_ownership.get("kind")
        if kind not in _UI_DESIGN_KINDS:
            issues.append(
                _issue(
                    "mapping-unknown-ui-design-kind",
                    path,
                    f"{label}: unsupported kind {kind!r}",
                )
            )

        for field in ("semantic_role", "consumer_scope"):
            if not _non_empty(raw_ownership.get(field)):
                issues.append(
                    _issue(
                        "mapping-missing-ui-design-owner-field",
                        path,
                        f"{label}: {field} is required",
                    )
                )

        owner = raw_ownership.get("owner")
        if owner not in _UI_DESIGN_OWNERS:
            issues.append(
                _issue(
                    "mapping-unknown-ui-design-owner",
                    path,
                    f"{label}: unsupported owner {owner!r}",
                )
            )

        disposition = raw_ownership.get("disposition")
        if disposition not in _UI_DESIGN_DISPOSITIONS:
            issues.append(
                _issue(
                    "mapping-unknown-ui-design-disposition",
                    path,
                    f"{label}: unsupported disposition {disposition!r}",
                )
            )
        elif disposition == "unresolved" and production_acceptance:
            issues.append(
                _issue(
                    "mapping-ui-design-unresolved",
                    path,
                    f"{label}: unresolved UI design ownership blocks acceptance",
                )
            )

        if owner == "design-system":
            public_ref = raw_ownership.get("public_owner_ref")
            if not _non_empty(public_ref):
                issues.append(
                    _issue(
                        "mapping-missing-design-system-public-owner",
                        path,
                        f"{label}: design-system owner requires public_owner_ref",
                    )
                )
            elif isinstance(public_ref, str) and ("/src/" in public_ref or "\\src\\" in public_ref):
                issues.append(
                    _issue(
                        "mapping-design-system-deep-import",
                        path,
                        f"{label}: design-system owner must use public API",
                    )
                )

        if disposition == "intentional-local" and not _non_empty(
            raw_ownership.get("local_scope_reason")
        ):
            issues.append(
                _issue(
                    "mapping-missing-local-scope-reason",
                    path,
                    f"{label}: intentional-local requires local_scope_reason",
                )
            )

        if kind == "visual-authority-metadata" and owner != "visual-authority":
            issues.append(
                _issue(
                    "mapping-visual-authority-owner-mismatch",
                    path,
                    f"{label}: visual-authority metadata must be owned by visual-authority",
                )
            )

        if kind == "asset-reference":
            if not _non_empty(raw_ownership.get("evidence_ref")):
                issues.append(
                    _issue(
                        "mapping-asset-reference-missing-evidence",
                        path,
                        f"{label}: asset-reference must point to existing representation/provenance evidence",
                    )
                )
            forbidden_asset_registry_fields = (
                "asset_path",
                "source_identity",
                "derived_transformation",
                "destination",
                "content_hash",
            )
            if any(field in raw_ownership for field in forbidden_asset_registry_fields):
                issues.append(
                    _issue(
                        "mapping-ui-design-asset-registry-leak",
                        path,
                        f"{label}: UI ownership must reference, not duplicate, asset provenance",
                    )
                )


def _check_asset_provenance(
    path: Path,
    node_label: str,
    raw_asset: object,
    issues: list[PencilImplementationMappingIssue],
) -> None:
    required = ("source_identity", "derived_transformation", "destination", "content_hash")
    if not isinstance(raw_asset, dict):
        issues.append(
            _issue("mapping-incomplete-asset-provenance", path, f"{node_label}: asset provenance is required")
        )
        return
    missing = [field for field in required if not _non_empty(raw_asset.get(field))]
    content_hash = raw_asset.get("content_hash")
    if missing or not isinstance(content_hash, str) or not _SHA256_RE.fullmatch(content_hash):
        issues.append(
            _issue(
                "mapping-incomplete-asset-provenance",
                path,
                f"{node_label}: asset provenance requires source/transformation/destination/valid content hash",
            )
        )


def _non_empty(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def _issue(code: str, path: Path, message: str) -> PencilImplementationMappingIssue:
    return PencilImplementationMappingIssue(code=code, path=path, message=message)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Pencil → Flutter critical implementation mapping evidence.")
    parser.add_argument("mapping", type=Path)
    parser.add_argument("--authority-sha256")
    parser.add_argument("--allow-unresolved", action="store_true")
    args = parser.parse_args()

    issues = validate_implementation_mapping(
        args.mapping,
        expected_authority_sha256=args.authority_sha256,
        production_acceptance=not args.allow_unresolved,
    )
    for issue in issues:
        print(f"{issue.code}: {issue.message}")
    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
