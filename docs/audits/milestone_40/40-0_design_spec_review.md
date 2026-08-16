---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-40-repository-landing-documentation-authority-design-review
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — Design Spec Review

## Review scope

Review target：

`docs/superpowers/specs/2026-08-17-milestone-40-repository-landing-documentation-authority-design.md`

Requirement authority：

`docs/audits/milestone_40/40-r_requirement_decision.md`

## Focused review — first pass

### F-40-0-01 — `docs/conversation_rules.md` 仍會把 detailed contract 推回 README

- Severity：P1 documentation-authority regression risk。
- Evidence：Current Rule 5 宣告新增啟動方式、驗證方式、平台限制、重要依賴、文件導覽時「必須同步更新 README」。若 README 改為 landing-page human entry，這條規則會持續要求複製 detailed current facts，重新造成 bloat／parallel authority。
- First-pass result：FAIL。
- Fix：Design responsibility matrix與routing section已加入 `docs/conversation_rules.md`，要求把 Rule 5 收斂成 public/newcomer summary contract，且不得取得 executable reading／routing authority。
- Fresh re-review：PASS。新 Design 明確讓 detailed procedure／dependency／architecture contract只更新 canonical owner，README只同步 public summary。

### F-40-0-02 — Template → Product bootstrap compatibility 未被明確保護

- Severity：P1 product-adoption compatibility risk。
- Evidence：`docs/guides/template_repository_adoption.md` 明確把 root `README.md` 列為首次 bootstrap 必須從 template current authority轉為product current authority的檔案之一。第一版 Design 雖保留 adoption CTA，卻沒有明確要求新 landing-page structure 對 product transition 保持 bounded compatibility。
- First-pass result：FAIL。
- Fix：Design新增 Template → Product bootstrap compatibility contract，保護 template/product version phrase、Hero positioning與 bounded transition。
- Fresh re-review：PASS。

### F-40-0-03 — README baseline projection不得因產品化版面重構而破壞 docs checker

- Severity：P1 machine-contract risk。
- Review：Design保留 `Template Baseline Version：x.y.z`／`Product Repository Version：x.y.z` compatibility，預設不修改 checker regex。
- Result：PASS。

### F-40-0-04 — Inline architecture images不得升格成 architecture authority

- Severity：P1 parallel-authority risk。
- Review：Design明確保留圖片為visual summary consumer；machine manifest、Project Context、canonical ADR與production source仍為 authority。
- Result：PASS。

### F-40-0-05 — README縮減不得造成資訊遺失

- Severity：P1 semantic-preservation risk。
- Review：Design要求 implementation 前建立 section-level preservation matrix，且 `Remove from root` 必須先證明 canonical destination 已存在。
- Result：PASS。

### F-40-0-06 — 不得把 root README 變成第二份 Documentation Hub

- Severity：P1 ownership risk。
- Review：README Documentation section只保留 high-value deep links；taxonomy與task route仍由 `docs/README.md` 擁有。
- Result：PASS。

### F-40-0-07 — Quick Start不得重新導入每次 full regression

- Severity：P1 validation-cost regression risk。
- Review：Design只保留 first-run minimum，testing routing交回current planner／testing governance，沒有固定 full workspace test contract。
- Result：PASS。

### F-40-0-08 — 不得為縮短 README 新建 aggregate dumping ground

- Severity：P1 documentation-growth risk。
- Review：Design禁止建立 `docs/readme_details.md` 類 aggregate document，也禁止把舊 README 全文藏在 `<details>`。
- Result：PASS。

## Fresh focused re-review

第一輪兩個 P1 finding 均已在 Design 本身修正：

```txt
F-40-0-01 = CLOSED
F-40-0-02 = CLOSED
Open P0 = 0
Open P1 without disposition = 0
```

Fresh re-read確認修正沒有擴大 scope：沒有修改 root README、沒有搬移 canonical docs、沒有修改 checker implementation，也沒有新增第二個 documentation ADR。

## Whole-Design holistic review

### Requirement coverage

Design已覆蓋 Requirement 的八個核心問題：

1. root README product landing architecture；
2. architecture visual inline preview；
3. current sections keep／compress／re-home／remove disposition；
4. Agent／Guide／governance／workflow dependency audit；
5. canonical destination／single authority；
6. README／Docs Hub／Project Context／Guides／ADR／AGENTS responsibility boundary；
7. documentation policy／reading route／newcomer／bootstrap compatibility；
8. final section order／information density／GitHub rendering acceptance。

### Authority consistency

Design符合：

- ADR-011 one fact / one authority；
- Documentation Governance Policy migration safety；
- `docs/README.md` Human entry／Documentation Hub split；
- `AGENTS.md` mandatory AI policy owner；
- `VERSION` + README + CHANGELOG baseline checker contract；
- Template → Product bootstrap README transition contract。

### Scope control

Explicitly excluded：Flutter runtime、production code、architecture redraw、image generation、GitHub Pages、brand redesign、new aggregate docs、unnecessary checker change。

### ADR gate

New ADR：not required by default。

Current stable principle已由 ADR-011擁有；只有 implementation證明 existing ADR／policy wording 與新 boundary衝突時才 amend，不得因Level 4機械新增ADR。

## Mechanical validation

Fresh result：

```txt
git diff --check = PASS
dart run melos run docs_check = PASS
```

## Review conclusion

```txt
Focused review: PASS after fixes
Fresh re-review: PASS
Whole-Design holistic review: PASS
Open P0: 0
Open P1 without disposition: 0
Design status: accepted
User approval: accepted on 2026-08-17
Implementation Plan: allowed to draft after user approval; implementation still forbidden until Plan acceptance
```

本 review 已完成雙層 Design gate 的 machine／semantic／holistic部分；使用者已於2026-08-17明確核准，Design Spec與本review均為`accepted`，現在允許建立Implementation Plan，但Plan完成雙層review並取得使用者核准前仍不得開始implementation。
