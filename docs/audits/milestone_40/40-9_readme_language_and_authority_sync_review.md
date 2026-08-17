---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-40-readme-language-and-authority-sync-corrective
last_reviewed_baseline: 1.20.0
---

# Milestone 40-9 — README 語言一致性與 Authority Sync Corrective Review

## Requirement Decision

- Request（需求）：完整審查 root `README.md` 的語言一致性、雙層 review 是否真的成立，以及 Milestone 40 current / historical 文件是否同步。
- Problem（問題）：Milestone 40 local closure 後，root README 仍保留 `Architecture Overview`、`What is included`、`Start a Product`、`Quick Start`、`Documentation` 等一般閱讀層級英文標題；同時兩份 accepted Milestone 40 Design artifact 的 status block 仍顯示 Plan proposed / implementation forbidden，與 current closure 不一致。
- Expected behavior（預期行為）：一般閱讀標題、table headers 與非必要 status prose 使用繁體中文；技術名詞、套件、architecture layer、CLI command 與正式產品／工具名稱可保留英文。Current authority、accepted historical artifacts 與 local closure state 不得互相矛盾。
- Classification（分類）：**Level 1 — Small Fix**。
- Decision（決策）：**Accept**。
- Scope（範圍）：root README user-facing language consistency、Milestone 40 accepted Design / Plan current-status sync、focused + fresh + whole-README review、documentation validation。
- Non-goals（非目標）：不改 title artwork、不改兩張 architecture visuals、不改 architecture contract、不改 Template → Product bootstrap、不升版。
- Design Spec required：否。
- Implementation Plan required：否。
- ADR required：否。
- Task governance mode：Level 1 simplified Task cycle，但依使用者要求執行完整 focused review → fresh re-review → whole-Task holistic review。
- Release required：否；Template Baseline 維持 `1.20.0`。

## Focused review findings

### F-40-9-01 — Root README 一般章節標題語言不一致

- Severity：P1 presentation quality。
- Finding：多個非專有名詞章節標題仍使用英文，例如 `What is included`、`Why this template`、`Quick Start`、`Documentation`。
- Fix：統一改為繁體中文：`架構總覽`、`依賴契約`、`為什麼選擇這個模板`、`模板包含內容`、`開始建立產品`、`快速開始`、`專案結構`、`平台支援`、`文件導覽`、`限制與非目標`。
- Result：FIXED。

### F-40-9-02 — 一般 table header / platform status 不必要地全英文

- Severity：P1 presentation consistency。
- Finding：`Area / Included baseline`、`Platform / Status / Notes`、`Supported / Dependency-ready` 屬一般閱讀文字，不需要以英文呈現。
- Fix：改為 `領域 / 已包含基線`、`平台 / 狀態 / 說明`、`支援 / 依賴就緒`；技術名詞與正式套件名稱保留英文。
- Result：FIXED。

### F-40-9-03 — Accepted Design status block 與 current closure drift

- Severity：P1 documentation authority drift。
- Finding：`2026-08-17-milestone-40-repository-landing-documentation-authority-design.md` frontmatter 已是 `accepted`，但內文仍宣稱 Plan proposed / implementation forbidden；40-7R Design 也仍宣稱 Plan approval pending。
- Fix：同步為實際 accepted / executed disposition；40-7R 額外標記 C01 / C02 rejected、方向已被 40-7T supersede。
- Result：FIXED。

### F-40-9-04 — 已移除 generation integration 的歷史 reference 必須與 current authority 分離

- Severity：P1 routing ambiguity。
- Finding：40-7R Design / Plan 仍包含當時 `chatgpt-web-image` routing。直接刪除會破壞歷史 evidence；不加說明又可能被誤讀為 current tool authority。
- Fix：在 accepted historical Design / Plan status 區加入明確 historical note：舊 tool reference只代表當時 execution contract；current generation route必須 fresh Executor discovery，40-7T 已使用 `chatgpt-web-generation`。
- Result：FIXED。

## Fresh focused re-review

重新由 root `README.md` 第一行掃到最後一行：

- `Flutter Enterprise Architecture Template`：由accepted title artwork承擔README內唯一標題視覺；不再重複保留純文字H1。
- Title artwork：保留 accepted consumer。
- 一般 section headings：全部已改為繁體中文。
- 表格的一般欄名與支援狀態：已改為繁體中文。
- CLI command、package 名稱、Clean Architecture layer、Flutter / Android / iOS、ADR、CI/CD、Pencil、Template → Product 等技術名詞：保留英文或混合寫法，符合 root `AGENTS.md`「技術名詞保留英文」規則。
- 兩張 accepted architecture visuals：仍直接 inline，沒有改 path 或 authority。
- `Template Baseline Version：1.20.0`：保留，未破壞既有 checker contract。

Fresh focused re-review：**PASS**。Open P0 = 0；Open P1 without disposition = 0。

## Whole-README holistic review

逐區塊重新驗收：

1. Title artwork作為唯一README標題視覺：PASS。
2. 產品定位 / baseline / platform summary / adoption CTA：PASS。
3. 架構總覽：PASS；Productized Topology inline 保留。
4. 依賴契約：PASS；C4 Dependency Contract inline 保留。
5. 為什麼選擇這個模板：PASS；語意是產品價值，不是 milestone journal。
6. 模板包含內容：PASS；一般欄位中文化，技術內容保留正式英文名稱。
7. 開始建立產品：PASS；Template → Product bootstrap authority未被 README 取代。
8. 快速開始：PASS；command 未改。
9. 專案結構：PASS；repository layout 未改。
10. 平台支援：PASS；support claim與 current context一致。
11. 文件導覽：PASS；root README 只提供摘要與 route，不成為平行 authority。
12. 限制與非目標：PASS；未擴張產品 capability claim。

Whole-Task holistic review：**PASS**。

## Documentation authority sync review

Current state應一致為：

```txt
Active Milestone: none
Milestone 40: completed locally
Template Baseline: 1.20.0
Current README title artwork: accepted 40-7T asset
40-7 / 40-7R Hero attempts: rejected historical evidence
Current future image-generation authority: fresh discovered chatgpt-web-generation route
```

同步檢查涵蓋：

- `README.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`
- `docs/project_context.md`
- `docs/milestones/README.md`
- `docs/audits/README.md`
- `docs/superpowers/README.md`
- Milestone 40 accepted Design / Plan status blocks

未發現 repository lifecycle、VERSION、architecture ownership 或 Template → Product machine contract 被本次 corrective 改動。

## Validation

Required validation：

```txt
git diff --check
dart run melos run docs_check
README heading / consumer / rejected-consumer deterministic checks
```

## Result

```txt
Focused review: PASS after fixes
Fresh focused re-review: PASS
Whole-README holistic review: PASS
Documentation authority sync: PASS after fixes
Open P0: 0
Open P1 without disposition: 0
Release: not required
Template Baseline: 1.20.0
```
