---
document_type: phase-review
status: accepted
authoritative_for:
  - design-space-scaling-skill-adoption-review
last_reviewed_baseline: 1.25.2
---

# Design-space Scaling — Skill Adoption Review

## Scope

本次沒有新增 Skill；只同步 repository-authored `implementing-pencil-flutter-design`，使其不再以 `Stack`、`Positioned`、x/y、`left/top/right/bottom` 的語法名稱作 architecture oracle，而改以 ADR-028 的 layout ownership / UI semantics 判斷。

## Admission

- Problem：舊 Skill wording 會把合法 scaled coordinate 誤判為 fixed-canvas violation，與本次 accepted ADR-028 stable rule 衝突。
- Trigger / workflow order：未改變。
- Inputs / outputs：未改變。
- Tools / MCP / credentials / permissions：未改變。
- Repository mutation scope：只修改既有 Skill wording、Flutter mapping、visual validation 與 pressure scenarios。
- Authority：Skill 不新增平行 authority；ADR-018 / ADR-028 / ADR-032 仍為 stable architecture authority。
- Version / rollback：repository-local source 與本次 commit 綁定；rollback 可回退本次 changes。

## Focused pressure review

- PTF-47：bounded component 使用 scaled x/y / Positioned，必須依 coordinate owner 判斷，不因語法直接 FAIL。
- PTF-48：public `left/top` API 若本身就是 component position contract 可合法；若只是取代 content-flow relationship 才 FAIL。
- PTF-49：generic positioned helper 若只是合法 local/spatial primitive 可合法；機械取代 flow 才 FAIL。
- PTF-52：看到多個 `Stack/Positioned` 就全面禁止，明確為 FAIL。

## Disposition

Approved with restrictions：

1. Scaling legality 必須 property-neutral。
2. Whole-page fixed-coordinate reconstruction 仍可因錯誤 owner 而 FAIL。
3. Skill 不得推翻 ADR 或自行把 coordinate usage 宣告為 architecture violation。
4. 本次不新增新 Skill、不增加 trigger、不增加 tooling/permission。

Open P0 = 0；Open P1 without disposition = 0。
