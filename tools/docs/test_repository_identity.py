from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.docs.verify_repository_identity import check_repository_identity


class RepositoryIdentityContractTest(unittest.TestCase):
    def test_missing_manifest_fails_closed(self) -> None:
        with _fixture() as root:
            self.assertIn("missing-repository-identity", _codes(root))

    def test_malformed_json_fails_closed(self) -> None:
        with _fixture() as root:
            _write(root, "repository_identity.json", "{not-json\n")

            self.assertIn("invalid-repository-identity-json", _codes(root))

    def test_unknown_schema_and_repository_kind_fail_closed(self) -> None:
        with _fixture() as root:
            _write_identity(root, schema_version=2, repository_kind="unknown")

            codes = _codes(root)

            self.assertIn("unsupported-repository-identity-schema", codes)
            self.assertIn("invalid-repository-kind", codes)

    def test_template_requires_null_product_name_and_canonical_origin(self) -> None:
        with _fixture() as root:
            _write_identity(
                root,
                repository_kind="template",
                product_name="Not a product yet",
                origin_repository="someone/example",
            )

            codes = _codes(root)

            self.assertIn("template-product-name-present", codes)
            self.assertIn("template-origin-repository-mismatch", codes)

    def test_template_origin_baseline_must_match_version(self) -> None:
        with _fixture(version="1.17.0") as root:
            _write_identity(root, repository_kind="template", origin_baseline="1.16.0")

            self.assertIn("template-origin-baseline-mismatch", _codes(root))

    def test_product_requires_name_valid_versions_and_no_product_version_field(self) -> None:
        with _fixture(version="not-semver") as root:
            payload = _identity(
                repository_kind="product",
                product_name="",
                origin_baseline="not-semver",
            )
            payload["product_version"] = "0.1.0"
            _write(root, "repository_identity.json", json.dumps(payload, ensure_ascii=False))

            codes = _codes(root)

            self.assertIn("product-name-missing", codes)
            self.assertIn("invalid-template-origin-baseline", codes)
            self.assertIn("invalid-product-version", codes)
            self.assertIn("unexpected-repository-identity-field", codes)

    def test_valid_template_identity_does_not_depend_on_folder_remote_or_readme_guessing(self) -> None:
        with _fixture(version="1.17.0") as root:
            _write_identity(root, repository_kind="template", origin_baseline="1.17.0")
            _write(root, "README.md", "# 這段 prose 故意寫成某個產品，但不能改變 lifecycle\n")

            self.assertEqual(_codes(root), [])

    def test_valid_product_identity_keeps_current_product_version_only_in_version_file(self) -> None:
        with _fixture(version="0.1.0") as root:
            _write_identity(
                root,
                repository_kind="product",
                product_name="Pickup Basketball Acceptance",
                origin_baseline="1.17.0",
            )

            self.assertEqual(_codes(root), [])


def _codes(root: Path) -> list[str]:
    return [issue.code for issue in check_repository_identity(root)]


def _fixture(version: str = "1.17.0"):
    temp = tempfile.TemporaryDirectory()
    root = Path(temp.name)
    _write(root, "VERSION", f"{version}\n")

    class _FixtureContext:
        def __enter__(self) -> Path:
            return root

        def __exit__(self, exc_type, exc, tb) -> None:
            temp.cleanup()

    return _FixtureContext()


def _identity(
    *,
    schema_version: int = 1,
    repository_kind: str = "template",
    product_name: str | None = None,
    origin_repository: str = "MagicalWater/flutter_architecture",
    origin_baseline: str = "1.17.0",
) -> dict[str, object]:
    return {
        "schema_version": schema_version,
        "repository_kind": repository_kind,
        "product_name": product_name,
        "template_origin": {
            "repository": origin_repository,
            "baseline": origin_baseline,
        },
    }


def _write_identity(root: Path, **overrides: object) -> None:
    payload = _identity(**overrides)
    _write(root, "repository_identity.json", json.dumps(payload, ensure_ascii=False))


def _write(root: Path, relative: str, content: str) -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    unittest.main()
