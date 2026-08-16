---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-40-repository-landing-documentation-authority-requirement-decision
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — GitHub Repository Landing Page & Documentation Authority Restructure Requirement Decision

## Requirement Decision

- Request（需求）：把 root `README.md` 從混合型 current project document 重構為真正的 GitHub repository／template product landing page，並重新收斂 README、Documentation Hub、Project Context、Guides、ADR 與 Agent policy 的責任邊界。
- Problem（問題）：Root README 目前同時承載產品介紹、Milestone 狀態、current capability、技術細節、操作 procedure、Web 注意事項、文件 routing 與 Agent continuation 說明；這些內容與既有 canonical owner 重疊，且新增的正式架構圖只以 hyperlink 呈現，沒有形成 GitHub 第一視覺。
- Current behavior（目前行為）：`docs/README.md` 已把 root README 定義為 Human entry，但 README 實際內容遠超 human entry responsibility；`docs/project_context.md`、Guides、Roadmap、Milestone index、CHANGELOG、AGENTS 與 docs checker 都各自依賴 README 的部分 current contract。
- Expected behavior（預期行為）：Root README 成為短而完整的 product landing page；正式架構圖直接 inline preview；詳細 current contract 與 reusable procedure 只保留在各自 canonical authority；README 只提供必要摘要與穩定深連結。
- Value（價值）：改善 GitHub 第一印象、template adoption、newcomer onboarding、閱讀效率與文件可維護性，降低 parallel authority 與 stale current-tense prose 的風險。
- Classification（分類）：Level 4 — Architecture／Milestone。
- Decision（決策）：Accept。
- Scope（範圍）：Root README information architecture、section disposition、inline architecture visual、documentation ownership／routing、template → product bootstrap compatibility、README baseline checker contract、必要 current authority synchronization、migration safety 與 documentation validation。
- Non-goals（非目標）：不改 Flutter runtime architecture、不改 production behavior、不重新設計兩張已接受架構圖、不新增另一份 architecture authority、不把 README 變成完整 docs index、不處理品牌 logo／網站／GitHub Pages。
- Behavioral requirements required（是否需要行為需求）：Yes；observable behavior 是 GitHub human-entry navigation、documentation routing 與 docs checker contract。
- Design Spec required（是否需要 Design Spec）：Yes。
- Implementation Plan required（是否需要 Implementation Plan）：Yes。
- ADR required（是否需要 ADR）：Conditional；若只依既有 Single Authority contract 重分配 presentation owner，優先 amend／reference ADR-011，不新增第二個 documentation authority ADR。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：Required；managed worktree branch `milestone-40-repository-landing-documentation-authority`。
- Regression level（Regression 等級）：Documentation／governance holistic；exact validation 由 `tools/ci/validation_planner.py` 決定。
- Release required（是否需要發布）：Design 階段不預設；Implementation Plan 必須明確 disposition 是否只做 documentation release-neutral change，或需要 baseline release。
- Post-release validation（發布後驗證）：若有 release 則 required；若無 release，仍需 clean checkout／GitHub-rendering-oriented semantic verification disposition。
- Required Superpowers skills（必要 Superpowers Skills）：central governance 已路由 Design／Plan workflow；不得在 Design／Plan acceptance 前進入 implementation。
- Required artifacts（必要 artifacts）：Requirement Decision、Design Spec、Design review evidence、Implementation Plan、Plan review evidence、implementation Task reviews、holistic final review；若搬移大型內容，需 section-level migration manifest／preservation matrix。

## Classification evidence

本工作不是單純把兩個 Markdown link 換成 image syntax。最高適用風險包含：

1. repository-wide documentation ownership 重新分配；
2. root human-entry contract 與 machine docs checker 同時受影響；
3. current reading route／release routing／newcomer route 可能需要同步；
4. 若直接刪減 README，可能造成 current information 遺失或建立 parallel authority；
5. `docs/governance/documentation_policy.md` 對大型拆分要求 migration safety 與 semantic preservation review。

因此採 Level 4；不得在 implementation 期間靜默降級。

## Fresh admission evidence

2026-08-17 fresh read-only admission：

```txt
branch = main
HEAD = dcda3d864dc75a757d45bda43c4c9b7cd1e37165
origin/main = dcda3d864dc75a757d45bda43c4c9b7cd1e37165
working tree = clean
VERSION = 1.20.0
repository_identity.repository_kind = template
repository_identity.template_origin.baseline = 1.20.0
active milestone = None
```

Current architecture visual assets：

```txt
docs/assets/architecture/productized-topology.png
docs/assets/architecture/c4-dependency-contract.png
```

兩張圖已由 `docs/project_context.md` inline 使用，且明確只是 current architecture 的視覺摘要，不取代 canonical authority。

## Stop condition

Design Spec 與 Implementation Plan 均完成完整 review 並取得使用者核准前：

- 不得修改 root README 正文；
- 不得搬移、刪除或拆分既有 canonical documentation；
- 不得修改 docs checker implementation；
- 不得宣稱新的 documentation ownership 已生效。

