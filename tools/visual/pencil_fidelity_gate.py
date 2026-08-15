from __future__ import annotations

from dataclasses import dataclass


_LOCAL_EVIDENCE_KINDS = {
    "component-golden",
    "roi-diff",
    "asset-identity",
    "icon-identity",
    "geometry-assertion",
}


@dataclass(frozen=True)
class LocalFidelityEvidence:
    evidence_id: str
    kind: str
    passed: bool
    critical: bool = True
    contract_locked: bool = True


@dataclass(frozen=True)
class FidelityGateDecision:
    passed: bool
    reasons: tuple[str, ...]


def evaluate_fidelity_gate(
    *,
    whole_screen_passed: bool,
    local_evidence: tuple[LocalFidelityEvidence, ...],
) -> FidelityGateDecision:
    reasons: list[str] = []
    if not whole_screen_passed:
        reasons.append("whole-screen-failed")

    seen_ids: set[str] = set()
    for evidence in local_evidence:
        if evidence.evidence_id in seen_ids:
            reasons.append(f"duplicate-local-evidence:{evidence.evidence_id}")
        seen_ids.add(evidence.evidence_id)

        if evidence.kind not in _LOCAL_EVIDENCE_KINDS:
            reasons.append(f"unknown-local-evidence-kind:{evidence.evidence_id}")
            continue

        if evidence.kind == "roi-diff" and not evidence.contract_locked:
            reasons.append(f"roi-contract-not-locked:{evidence.evidence_id}")

        if evidence.critical and not evidence.passed:
            reasons.append(f"critical-local-failed:{evidence.evidence_id}")

    return FidelityGateDecision(passed=not reasons, reasons=tuple(reasons))
