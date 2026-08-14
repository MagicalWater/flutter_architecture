from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


class TemplateRepositoryBootstrapRoutingTest(unittest.TestCase):
    def test_fixed_fresh_admission_reads_repository_identity(self) -> None:
        agents = read("AGENTS.md")

        minimum_set = agents.split("每次進入 repository 的固定最小讀取集：", 1)[1].split("```", 2)[1]
        self.assertIn("repository_identity.json", minimum_set)

    def test_central_governance_reads_repository_identity_before_domain_routing(self) -> None:
        skill = read(".agents/skills/governing-template-development/SKILL.md")

        self.assertIn("repository_identity.json", skill)
        self.assertIn("adopting-template-repository", skill)
        self.assertIn("adopting-template-product-identity", skill)

    def test_bootstrap_skill_is_thin_and_delegates_native_identity(self) -> None:
        skill = read(".agents/skills/adopting-template-repository/SKILL.md")

        self.assertIn("governing-template-development", skill)
        self.assertIn("repository_identity.json", skill)
        self.assertIn("adopting-template-product-identity", skill)
        self.assertIn("template", skill)
        self.assertIn("product", skill)

    def test_pressure_scenarios_cover_required_negative_routes(self) -> None:
        pressure = read(
            ".agents/skills/adopting-template-repository/references/pressure-scenarios.md"
        )

        for required in (
            "product repo再次要求首次 bootstrap",
            "missing",
            "invalid manifest",
            "API-only",
            "visual-only",
            "單一平台",
            "discussion-only",
        ):
            self.assertIn(required, pressure)

    def test_product_identity_skill_does_not_own_repository_lifecycle(self) -> None:
        skill = read(".agents/skills/adopting-template-product-identity/SKILL.md")

        self.assertNotIn("repository_kind", skill)
        self.assertNotIn("template_origin.baseline", skill)

    def test_human_registry_has_bootstrap_skill_without_parallel_authority(self) -> None:
        workflow = read("docs/governance/development_workflow.md")

        self.assertIn("`adopting-template-repository`", workflow)
        self.assertIn("`adopting-template-product-identity`", workflow)
        self.assertIn("repository_identity.json", workflow)


if __name__ == "__main__":
    unittest.main()
