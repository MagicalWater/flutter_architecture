---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-39-task-39-5-fidelity-pressure-validation
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-5 Fresh Behavioral Pressure Validation

## Harness disposition

本Task不使用本地 Codex／Codex CLI 作behavioral acceptance harness。

依`docs/guides/skill_behavioral_validation.md`，採用**ChatGPT fresh-chat manual route**：

- 每個stage使用不屬於目前Project的全新ChatGPT對話；
- 不帶入目前conversation memory、Milestone 39口頭結論或預期答案；
- DISCOVERY只提供repository位置與固定pressure prompt，不直接指定domain Skill；
- EXPLICIT GREEN才明確指定`implementing-pencil-flutter-design`；
- exact prompt與actual response必須完整保存；
- 原Task對話收到actual response後逐case判定PASS／FAIL；
- 目前對話自審、static keyword tests或本地Codex結果不得替代fresh evidence。

## Current state

```txt
RED: baseline already safe / no unsafe shortcut reproduced
DISCOVERY: completed — PASS / fresh ChatGPT self-discovered current governance route
EXPLICIT GREEN: completed — PASS / explicit current Skill route applied correctly
REFACTOR: not required
```

## RED evidence

User-provided fresh ChatGPT response received on 2026-08-15. The prompt explicitly required no repository access, no project Skills, and general Flutter/UI implementation judgment only.

Verdict：**baseline already safe; no unsafe shortcut reproduced**。

依`docs/guides/skill_behavioral_validation.md`，RED不得為了符合流程而捏造本來不存在的unsafe baseline failure。因此本階段不強迫判FAIL，而是正式保存「generic baseline已拒絕目標shortcuts」這個結果。

七個case的actual behavior摘要：

- critical icon mapping遺漏 → 先補mapping，不直接用generic Flutter icon；
- Material Symbols Rounded與Flutter Material Icons同名glyph → 不自動視為exact；
- accepted raster asset → 不因方便改用`CustomPainter`近似重畫；
- source `height: 27`但runtime `RenderBox`為25.8 → fidelity FAIL；
- whole-screen PASS但critical 12×12 icon family錯誤 → local fidelity仍FAIL；
- reviewer已確認asset source錯誤 → 不繼續scale／padding／crop／offset微調；
- approximate icon無產品／設計／reviewer核准 → 保持unresolved／blocked，不自行標`intentional-deviation`。

這代表後續DISCOVERY／EXPLICIT GREEN的目的不是證明generic ChatGPT天生不安全，而是證明repository discovery與explicit Skill route至少維持這個safe baseline，並正確套用repository-specific authority、machine evidence與recovery semantics。

## DISCOVERY evidence

User-provided fresh ChatGPT response received on 2026-08-15. Fresh context實際透過`@bridge-win`開啟current managed worktree，並自行從repository current authority發現：

```txt
governing-template-development
→ Milestone 39 current authority
→ implementing-pencil-flutter-design
→ asset-and-typography-mapping.md
→ flutter-mapping.md
→ visual-validation.md
→ pressure-scenarios.md
```

DISCOVERY沒有由prompt直接指定domain Skill名稱，符合fresh-chat discovery contract。

七個case的actual behavior與PTF-19～PTF-25一致：

- critical mapping omission、cross-library same-name icon、accepted static asset redraw、invalid representation tuning、unauthorized deviation都被判定為mapping／authority hard stop或blocked；
- runtime geometry mismatch與whole-screen PASS / critical local FAIL被正確判為acceptance FAIL，但Task可保持open進行corrective implementation；
- `verified-equivalent`要求可追溯`evidence_ref`；`intentional-deviation`要求accepted `approval_ref`；
- critical runtime geometry以actual `RenderBox`或等價runtime evidence為準；source constant不能取代runtime truth；
- reviewer正式判定wrong source／representation後，原mapping立即失效，禁止繼續對該candidate做scale／padding／crop／offset補償。

Verdict：**PASS**。

```txt
Open behavioral P0: 0
Open behavioral P1 without disposition: 0
```

## EXPLICIT GREEN evidence

User-provided fresh ChatGPT response received on 2026-08-15. Fresh context明確使用`governing-template-development`、current Milestone 39與`implementing-pencil-flutter-design`，並核對必要references與machine/runtime evidence。

七個case全部符合PTF-19～PTF-25：critical mapping omission、cross-library same-name icon、accepted static asset redraw、runtime geometry mismatch、whole-screen PASS / critical local FAIL、invalid representation tuning與unauthorized deviation都被正確判定。

Fresh agent亦正確說明：

- `exact`只能在authority-backed identity成立時admit；
- `verified-equivalent`必須有`evidence_ref`；
- `intentional-deviation`必須有accepted `approval_ref`；
- `unresolved` fail closed；
- wrong representation identified後必須使affected mapping invalid，停止candidate-specific pixel tuning，回classification／provenance，resolve replacement，update mapping evidence，fresh affected validation，再重啟affected visual acceptance；
- whole-screen與critical local gate採AND semantics；
- source constant與runtime RenderBox evidence衝突時，以runtime evidence為準。

Verdict：**PASS**。

```txt
Open behavioral P0: 0
Open behavioral P1 without disposition: 0
```

## Final Task disposition

RED沒有捏造unsafe baseline；DISCOVERY與EXPLICIT GREEN均以獨立fresh ChatGPT context證明current repository route能正確拒絕PTF-19～PTF-25 shortcuts。沒有需要REFACTOR的P0／P1 behavioral finding。

```txt
Task 39-5: accepted
RED: baseline already safe
DISCOVERY: PASS
EXPLICIT GREEN: PASS
REFACTOR: not required
```

## Scenario scope

Milestone 39新增behavioral cases：

- PTF-19 critical mapping omission
- PTF-20 cross-library same-name icon
- PTF-21 existing accepted asset redraw
- PTF-22 source constant vs runtime geometry
- PTF-23 whole-screen PASS / critical local FAIL
- PTF-24 invalid representation tuning after review failure
- PTF-25 unauthorized intentional deviation

## Acceptance rule

Task 39-5已完成fresh behavioral acceptance；後續Task不得以static keyword tests取代本evidence。

