from __future__ import annotations

import unittest

from tools.visual.pencil_fidelity_gate import (
    LocalFidelityEvidence,
    evaluate_fidelity_gate,
)


class PencilFidelityGateTest(unittest.TestCase):
    def test_whole_screen_pass_cannot_override_critical_local_failure(self) -> None:
        decision = evaluate_fidelity_gate(
            whole_screen_passed=True,
            local_evidence=(
                LocalFidelityEvidence(
                    evidence_id="status-icon",
                    kind="icon-identity",
                    passed=False,
                ),
            ),
        )

        self.assertFalse(decision.passed)
        self.assertIn("critical-local-failed:status-icon", decision.reasons)

    def test_minimum_sufficient_local_owner_can_pass(self) -> None:
        decision = evaluate_fidelity_gate(
            whole_screen_passed=True,
            local_evidence=(
                LocalFidelityEvidence(
                    evidence_id="sticky-actions",
                    kind="geometry-assertion",
                    passed=True,
                ),
            ),
        )

        self.assertTrue(decision.passed)

    def test_roi_evidence_must_be_locked_before_candidate(self) -> None:
        decision = evaluate_fidelity_gate(
            whole_screen_passed=True,
            local_evidence=(
                LocalFidelityEvidence(
                    evidence_id="header-roi",
                    kind="roi-diff",
                    passed=True,
                    contract_locked=False,
                ),
            ),
        )

        self.assertFalse(decision.passed)
        self.assertIn("roi-contract-not-locked:header-roi", decision.reasons)

    def test_whole_screen_failure_remains_blocking(self) -> None:
        decision = evaluate_fidelity_gate(
            whole_screen_passed=False,
            local_evidence=(),
        )

        self.assertFalse(decision.passed)
        self.assertIn("whole-screen-failed", decision.reasons)


if __name__ == "__main__":
    unittest.main()
