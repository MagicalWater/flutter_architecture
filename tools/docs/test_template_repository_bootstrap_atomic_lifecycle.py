from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from tools.docs.verify_repository_identity import check_repository_identity


class TemplateRepositoryBootstrapAtomicLifecycleTest(unittest.TestCase):
    def test_product_transition_requires_prospective_validation_before_final_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            canonical = root / "repository_identity.json"
            candidate = root / "candidate-product.json"

            (root / "VERSION").write_text("1.17.0\n", encoding="utf-8")
            canonical.write_text(
                json.dumps(_identity("template", None), ensure_ascii=False),
                encoding="utf-8",
            )
            self.assertEqual(check_repository_identity(root), [])

            (root / "VERSION").write_text("0.1.0\n", encoding="utf-8")
            canonical_issues = check_repository_identity(root)
            self.assertIn(
                "template-origin-baseline-mismatch",
                {issue.code for issue in canonical_issues},
            )

            product = _identity("product", "Pickup Basketball Acceptance")
            candidate.write_text(json.dumps(product, ensure_ascii=False), encoding="utf-8")
            self.assertEqual(check_repository_identity(root, candidate), [])

            canonical.write_text(json.dumps(product, ensure_ascii=False), encoding="utf-8")
            self.assertEqual(check_repository_identity(root), [])


def _identity(repository_kind: str, product_name: str | None) -> dict[str, object]:
    return {
        "schema_version": 1,
        "repository_kind": repository_kind,
        "product_name": product_name,
        "template_origin": {
            "repository": "MagicalWater/flutter_architecture",
            "baseline": "1.17.0",
        },
    }


if __name__ == "__main__":
    unittest.main()
