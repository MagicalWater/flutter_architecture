---
document_type: design-spec
status: superseded
authoritative_for:
  - adr-028-stable-decision-draft-history
last_reviewed_baseline: 1.14.0
---

# ADR-028 Draft — Repository-local Pencil-to-Flutter Design Implementation Workflow

> Canonical authority：[ADR-028 — Repository-local Pencil-to-Flutter Design Implementation Workflow](../../adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md)。本文件只保存書面核准與canonicalization前的stable decision歷史。

## Draft Status

Superseded；使用者於2026-08-04核准本stable decision draft後，內容已由Task 33-1建立為canonical ADR-028。

本文件保存canonicalization前的ADR-028 stable decision draft與approval history。Current stable authority由canonical `docs/adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md`擁有。

## Authoritative Scope

本 draft 定義 repository-local `.pen` visual authority、Pencil MCP boundary、第三方 Skill identity／integrity、Flutter architecture mapping與visual acceptance的 stable contract。

它不擁有 Milestone Task sequencing、exact implementation commands、特定畫面的逐像素數值、Taste Skill 上游內容、或某次 review findings。

## Context

Template Baseline 1.14.0 已有 Feature First、App-only Composition Root、Design System、Localization、testing governance與 repository-local Agent workflow，但沒有正式的設計來源到 Flutter implementation contract。

外部 proof 已證明單一 `.pen` 畫面可以被還原成 Flutter UI；然而該 proof 的 source、Skills、Flutter app 與 evidence 都位於模板 repository 外部。直接複製結果無法證明：

- 使用的是哪個 `.pen` 與哪個版本。
- Agent 實際載入哪一份同名 Skill。
- 第三方 Skill 是否被翻譯、修改或漂移。
- 視覺差異是由 design、renderer、font、icon或 architecture mapping造成。
- implementation 是否遵守模板的 router、Localization、Design System與 Feature First。

目前 docs checker 對 `.agents/skills/**/*.md` 一律要求中文，也把未修改的第三方 Skill 誤當成 repository-authored policy。翻譯上游 Skill 會破壞 provenance、hash與 safety／trigger語意，因此需要 ownership-aware contract。

## Decision

### Repository-local source authority

每個 Pencil-to-Flutter initiative 必須把 active design sources 放入 repository：

```txt
docs/design_sources/<initiative>/
docs/visual_authority/<initiative>/manifest.md
```

Manifest 明確指定 primary `.pen`、derived preview、supplementary original reference、historical benchmark、hash、canonical viewport、approval state與supersession。外部 filesystem path 只能作 admission input，不能作 implementation authority。

### Pencil MCP boundary

`.pen` 的結構讀取與修改只透過 approved `pencil-local-mcp` integration。Repository code、scripts與 agents 不得以 native JSON／text parser 或直接 file mutation作 fallback。

Pencil unavailable、錯誤 document state、source drift 或 unsupported construct 必須形成 blocked／finding disposition，不得靜默猜測。

### Third-party Skill identity

Skills 分為：

1. Repository-authored：遵守繁體中文 policy與 repository review。
2. Third-party unmodified：保留上游原始語言、結構與 bytes，以 immutable source、license identity、install path與逐檔 hash鎖定。
3. Repository-maintained fork：任何 bytes 修改後即視為 fork，必須使用明確 identity、記錄 upstream base並遵守 repository-authored governance。

未修改第三方 Skill 只有在 root `skills-lock.json` 完整列出並通過 exact hash validation時，才豁免 Skill 中文檢查。Path-only、name-only或人工宣告不足以取得豁免。

### Skill precedence and collision

Repository 必須驗證 runtime 實際載入 managed-worktree local Skill。若 user-global、DevSpace-local或 configured agent path 的同名 Skill先行遮蔽，workflow fail closed；不得只因 repository 有同名檔案就宣稱載入成功。

### Orchestration ownership

Repository 新增薄型 `implementing-pencil-flutter-design` Skill，負責：

- 委派中央 Requirement／approval／Task governance。
- 驗證 visual authority、Skill lock與 runtime discovery。
- 路由 Pencil MCP extraction。
- 路由 Design System／Localization／Feature First mapping。
- 路由 TDD、visual diff與review evidence。

Taste Skills 只作 stage-specific companions，不擁有 `.pen` authority、Flutter architecture、Task approval、release或closure。

### Flutter mapping

Pencil design 不建立平行 Flutter architecture：

- App 保持唯一 Composition Root。
- Feature 使用 Feature First。
- Visible strings 使用既有 Localization authority。
- Base theme 與 semantic color 優先使用既有 Design System。
- 只有準確且具穩定共用價值的 token／component 才提升到 Design System；單一畫面特有數值保留 feature-local visual specification。
- Presentation-only visual fixture 不建立虛假的 Domain、Data、Repository、Use Case、Bloc或 DI。

### Visual acceptance

每個 initiative 以 manifest 固定 canonical viewport與 comparison contract，至少產生：

- Pencil derived preview。
- Flutter canonical golden。
- Supported runtime screenshot。
- Deterministic diff。
- 人工語意 visual review。

不得以 full-screen raster embedding、全畫面 fixed-canvas scaling、事後擴大 threshold或任意 ignore region取得通過。Pixel evidence與語意 review缺一不可。

## Consequences

- Template 取得可重複、可審查的 Pencil-to-Flutter workflow，而不是只保留一次性還原成果。
- 第三方 Skill 可保留上游原文與 integrity，同時不降低 repository 的 fail-closed治理。
- Agent 必須證明實際載入 worktree-local source，降低 user-global collision與版本漂移風險。
- UI implementation 必須同時滿足 visual authority與既有 Flutter architecture，不會因追求 fidelity繞過 Localization、Design System或 Feature First。
- Visual validation增加 repository artifact與測試成本，但提供可重現的 fidelity evidence與 regression protection。

## Supersession

無。

## Related Decisions

- ADR-009：Project language policy；本 Decision 增加 third-party unmodified content 的 ownership-aware例外。
- ADR-011：Documentation single authority；visual source、manifest、runtime evidence與current state維持分工。
- ADR-018：Design System／Theme boundary；Pencil-specific values只有穩定共用時才提升。
- ADR-019：Localization與 user-facing text contract。

## Related Evidence

- [Milestone 33 Design](2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design.md)
- [Milestone 33 Design review](../../audits/milestone_33/33-0_design_spec_review.md)

## Canonicalization Gate

Task 33-1已以TDD將ADR completeness check改為contiguous highest-ID coverage，並建立canonical ADR-028與index row。Skill、visual source與Flutter implementation仍只能依後續Task gate進行。

## Last Reviewed Baseline

1.14.0。
