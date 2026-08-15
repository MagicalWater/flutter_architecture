---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-39-design-spec-review
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Design Spec Review

## Review scope

Review target：

`docs/superpowers/specs/2026-08-15-milestone-39-pencil-flutter-fidelity-enforcement-recovery-design.md`

Requirement authority：

`docs/audits/milestone_39/39-r_requirement_decision.md`

## Focused review

### F-39-0-01 — 不得新增第二個Pencil fidelity Skill

- Severity：P1 if violated。
- Review：Design維持`implementing-pencil-flutter-design`唯一domain owner，重規則放references／tools。
- Result：PASS。

### F-39-0-02 — Machine inventory不得演變成global asset registry

- Severity：P1 scope／authority risk。
- Review：Mapping artifact明確為initiative-local implementation evidence，只收risk-selected critical nodes；不要求全node backfill。
- Result：PASS。

### F-39-0-03 — 不得把corrective簡化為all-icons-raster

- Severity：P1 maintainability／accessibility risk。
- Review：Design保留Milestone 34六類representation，`exact`描述identity/evidence而非檔案格式。
- Result：PASS。

### F-39-0-04 — Critical geometry不得重新導入fixed-canvas思維

- Severity：P1 single-renderer regression risk。
- Review：Geometry gate允許exact size／proportion／edge inset／alignment／relationship，明確不要求所有runtime使用canonical absolute x/y。
- Result：PASS。

### F-39-0-05 — Local fidelity不得取代whole-screen regression

- Severity：P2 test ownership risk。
- Review：whole-screen仍為broad regression owner；local gate只補micro-fidelity blind spot。
- Result：PASS。

### F-39-0-06 — Recovery不得透過修改authority來迎合candidate

- Severity：P1 authority risk。
- Review：wrong representation回classification/provenance；source authority要改則回中央Requirement／Design，禁止implementation修改accepted `.pen`。
- Result：PASS。

### F-39-0-07 — Test scope不得走回test hell

- Severity：P1 governance risk。
- Review：Design採risk-based critical nodes與primary regression owner，明確列出every-node／every-icon／every-section tests為Should-not-add。
- Result：PASS。

## Whole-Task review

Design與Requirement一致：處理critical mapping completeness、mapping disposition、runtime geometry、local fidelity與wrong-representation recovery；沒有擴張到Pencil redesign、global asset framework、第二domain Skill或所有node測試。

Architecture ownership維持：

```txt
ADR-028
→ stable Pencil-to-Flutter boundary

implementing-pencil-flutter-design
→ orchestration / fail-closed / recovery

initiative implementation_mapping.json
→ machine implementation evidence

tools/visual
→ validator runtime truth
```

ADR gate disposition：建議amend ADR-028，不新增第二ADR。

## Current findings

```txt
Open P0: 0
Open P1 without disposition: 0
Design status: accepted
User approval: accepted on 2026-08-15
Implementation Plan: forbidden before approval
```

## Required validation before approval request

- docs policy／metadata validation。
- existing Pencil representation policy tests。
- existing Pencil single-renderer policy tests。
- `git diff --check`。
- Fresh review確認roadmap active state與Requirement／Design status一致。

