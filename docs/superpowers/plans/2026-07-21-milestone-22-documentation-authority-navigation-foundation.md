# Milestone 22 — Documentation Authority & Navigation Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立文件 authority、navigation、current snapshot、README coverage 與 automated consistency foundation，使歷史可以持續成長而不污染 AI active context。

**Architecture:** 先修正 P0／P1 current misinformation，再建立 documentation hub 與 reading contract，之後重寫 Project Context、拆分 Roadmap、補齊 README，最後加入 local documentation checker。全面 Decision extraction 與 artifact 搬移不在本計畫內。

**Tech Stack:** Markdown、YAML front matter、Python 3 standard library、Git、Melos local scripts。

---

## Fixed Execution Protocol

每個小階段固定：

```txt
Task implementation
→ immediate Task review
→ fix and re-review
→ next Task
→ whole-phase implementation review
→ fix and re-review
→ commit
→ unified report
```

小階段內不逐 Task 等待使用者確認。

## Phase 22-1 — Current-State Contradiction Remediation

### Task 1: Root README current-state correction

**Files:**

- Modify: `README.md`
- Create: `docs/audits/milestone_22/22-1_current_state_contradiction_review.md`

- [ ] 修正所有將 OTP、Biometric、Milestone 19–21 描述為 future / non-baseline 的 current-tense conflict。
- [ ] 不全面重寫 README。
- [ ] Review baseline、capability、security claim 與 `VERSION` 一致性。

### Task 2: Auth README current authority

**Files:**

- Modify: `apps/flutter_architecture/lib/features/auth/README.md`
- Modify: `docs/audits/milestone_22/22-1_current_state_contradiction_review.md`

- [ ] 更新 Secure credential authority、Legacy migration-only role、OTP presentation、local unlock 與 App-owned navigation。
- [ ] Review 不再將 SharedPreferences 描述為 current credential authority。

### Task 3: Shell README navigation authority

**Files:**

- Modify: `apps/flutter_architecture/lib/features/shell/README.md`
- Modify: `docs/audits/milestone_22/22-1_current_state_contradiction_review.md`

- [ ] 更新 Shell layout responsibility 與 App-owned authentication transition boundary。
- [ ] Review current router / coordinator source consistency。

### Task 4: Legacy path warnings

**Files:**

- Modify: `docs/adr/000-template-positioning.md`
- Modify: `docs/adr/001-why-bloc.md`
- Modify: `docs/adr/002-why-get-it-and-injectable.md`
- Modify: `docs/adr/003-why-flutter-hooks-and-hooked-bloc.md`
- Modify: `docs/adr/004-why-freezed-and-json-serializable.md`
- Modify: `docs/adr/005-why-auto-route.md`
- Modify: `docs/architecture/000-principles.md`
- Modify: `docs/architecture/001-folder-structure.md`
- Modify: `docs/architecture/002-clean-architecture.md`
- Modify: `docs/audits/milestone_22/22-1_current_state_contradiction_review.md`

- [ ] 加入統一 Historical / Superseded warning 與 current authority links。
- [ ] 不搬移、不刪除、不重新編號、不重寫歷史正文。

### Task 5: Interim Docs / Archive routing

**Files:**

- Modify: `docs/README.md`
- Modify: `docs/archive/README.md`
- Modify: `docs/audits/milestone_22/22-1_current_state_contradiction_review.md`

- [ ] 列出真實 document categories 與 interim roles。
- [ ] 標示 legacy `adr/`、`architecture/` status。
- [ ] 不提前完成 22-2 final hub。

### Task 6: 22-1 whole-phase review

- [ ] 重掃 P0／P1 stale phrases。
- [ ] 確認無 production code change、無搬移、無刪除。
- [ ] 記錄 finding closure / partial mitigation。
- [ ] Run `git diff --check`。
- [ ] Commit：`docs(governance): 完成 Milestone 22-1 現況矛盾修正`

## Phase 22-2 — Documentation Index & AI Reading Contract

### Task 1: Documentation authority hub

**Files:**

- Rewrite: `docs/README.md`
- Create: `docs/audits/README.md`
- Create: `docs/superpowers/README.md`
- Create: `docs/milestones/README.md`
- Create: `docs/audits/milestone_22/22-2_documentation_index_review.md`

- [ ] 定義 taxonomy、authority、summary rule 與 historical location。
- [ ] 建立 Audits、Plans／Specs、Milestones indexes。

### Task 2: Task-based AI reading route

**Files:**

- Modify: `AGENTS.md`
- Modify: `docs/conversation_rules.md`
- Modify: `README.md`

- [ ] 收斂 mandatory reading path。
- [ ] 定義 Architecture、Feature、Package、Milestone、Review、Release routing。
- [ ] 移除 Root README 的重複完整 AI policy。

### Task 3: Minimal metadata policy

**Files:**

- Create: `docs/governance/documentation_policy.md`
- Modify: `docs/README.md`

- [ ] 定義 `document_type`、`status`、`authoritative_for`、`last_reviewed_baseline`。
- [ ] 定義 status whitelist、archive trigger、legacy adoption rule。

### Task 4: 22-2 whole-phase review

- [ ] 確認每種 task 有 deterministic route。
- [ ] 確認 indexes 不成為第二份 architecture SSOT。
- [ ] Commit：`docs(governance): 完成 Milestone 22-2 文件索引與讀取契約`

## Phase 22-3 — Current Project Snapshot Rewrite

### Task 1: Project Context migration manifest

**Files:**

- Create: `docs/migrations/m22_project_context_manifest.md`
- Create: `docs/audits/milestone_22/22-3_project_context_review.md`

- [ ] 逐 heading 記錄 source、target authority、disposition、history location。
- [ ] 不允許單純標記 delete。

### Task 2: Current-only Project Context

**Files:**

- Rewrite: `docs/project_context.md`

- [ ] 只保留 baseline、purpose、architecture map、capabilities、constraints、active direction、documentation map、verification commands。
- [ ] 移除 milestone journal、commit、test count、historical next step。

### Task 3: Semantic preservation review

- [ ] 逐 manifest item 確認資訊仍可到達。
- [ ] 掃描 current snapshot 的 stale next-step phrase。

### Task 4: 22-3 whole-phase review

- [ ] Review line budget 與所有 current claims。
- [ ] Commit：`docs(context): 完成 Milestone 22-3 current snapshot 重寫`

## Phase 22-4 — Roadmap Active / Candidate Separation

### Task 1: Roadmap migration manifest

**Files:**

- Create: `docs/migrations/m22_roadmap_manifest.md`
- Create: `docs/audits/milestone_22/22-4_roadmap_review.md`

- [ ] 逐 Milestone 記錄 final status、artifact routing 與 disposition。

### Task 2: Roadmap index / active / candidates

**Files:**

- Rewrite: `docs/roadmap.md`
- Create: `docs/roadmap/active.md`
- Create: `docs/roadmap/candidates.md`

- [ ] Index 只保留 baseline、active、candidates、deferred、closed routing。
- [ ] Active 只表達正式 scope、gate、next action。
- [ ] Candidates 只保存未承諾方向。

### Task 3: Closed milestone routing

**Files:**

- Modify: `docs/milestones/README.md`
- Modify: `docs/archive/README.md`

- [ ] 先索引現有 artifacts，不搬移全部 audit / plan files。

### Task 4: 22-4 whole-phase review

- [ ] 確認 Roadmap 不再含逐 phase journal。
- [ ] Commit：`docs(roadmap): 完成 Milestone 22-4 active 與 archive 分離`

## Phase 22-5 — README Coverage Baseline

### Task 1: App README

- Create: `apps/flutter_architecture/README.md`
- Create: `docs/audits/milestone_22/22-5_readme_coverage_review.md`
- [ ] 記錄 Composition Root、entrypoints、routing、platform adapters、persistence、localization、appearance、commands。

### Task 2: Core README

- Create: `packages/core/README.md`
- [ ] 記錄 Result、Failure、AppException、reporting boundary 與 exports。

### Task 3: API Client README

- Create: `packages/api_client/README.md`
- [ ] 記錄 Dio／Retrofit、interceptors、refresh、safe replay、OTP wire contract。

### Task 4: Auth README

- Create: `packages/auth/README.md`
- [ ] 記錄 Domain／Data／Session、credential、migration、OTP、local presence 與 App adapter boundary。

### Task 5: Feature README normalization

- Modify: `apps/flutter_architecture/lib/features/auth/README.md`
- Modify: `apps/flutter_architecture/lib/features/catalog/README.md`
- Modify: `apps/flutter_architecture/lib/features/profile/README.md`
- Modify: `apps/flutter_architecture/lib/features/protected/README.md`
- Modify: `apps/flutter_architecture/lib/features/shell/README.md`
- [ ] 套用固定 responsibility、non-responsibility、dependencies、flow、tests、related decisions、baseline metadata。

### Task 6: Design System README normalization

- Modify: `packages/design_system/README.md`
- [ ] 保留 current contract，收斂 Milestone 15 journal。

### Task 7: 22-5 whole-phase review

- [ ] App／Feature／Package README coverage 100%。
- [ ] 無平行 internal contract。
- [ ] Commit：`docs(readme): 完成 Milestone 22-5 README coverage baseline`

## Phase 22-6 — Documentation Lint Foundation

### Task 1: Checker tests

**Files:**

- Create: `tools/docs/test_check_docs.py`
- Create: `docs/audits/milestone_22/22-6_documentation_lint_review.md`

- [ ] 以 fixture 驗證 broken link、duplicate ID、baseline mismatch、missing README、status contradiction、invalid metadata。
- [ ] Run `python -m unittest tools.docs.test_check_docs`，確認 initial failure。

### Task 2: Relative Markdown link checker

- Create: `tools/docs/check_docs.py`
- [ ] 只使用 Python standard library。
- [ ] 忽略 fenced code examples。

### Task 3: Baseline consistency

- [ ] 比較 `VERSION`、Root README current baseline、CHANGELOG 最新正式版本。

### Task 4: ID and status consistency

- [ ] 檢查 Decision／Finding／Milestone ID duplicate、status whitelist、active/archive contradiction。

### Task 5: README coverage

- [ ] 檢查所有 App／Package／Feature README，允許明確 ignore list。

### Task 6: Local command integration

**Files:**

- Modify: `pubspec.yaml`
- Modify: `AGENTS.md`
- Modify: `docs/governance/documentation_policy.md`

- [ ] 提供固定 `docs_check` command，不新增第三方 dependency 或遠端 CI。

### Task 7: 22-6 whole-phase review

- [ ] Unit tests、repository docs check、`git diff --check` 通過。
- [ ] Commit：`test(docs): 完成 Milestone 22-6 文件一致性檢查`

## Phase 22-7 — Final Review & Decision Extraction Gate

### Task 1: Final inventory

- Create: `docs/audits/milestone_22/22-7_final_review.md`
- [ ] 記錄文件數、active context、README coverage、metadata、links 與 finding status。

### Task 2: Finding closure

- [ ] M22-PR01 至 M22-PR15 都有 implementation evidence 或正式 deferred disposition。
- [ ] 不允許 Open P0／P1。

### Task 3: Decision extraction readiness

- [ ] Review index contract、stable IDs、manifest、stub、semantic procedure。
- [ ] 建議下一個獨立 extraction Milestone，不在 22-7 執行 extraction。

### Task 4: Full verification

```bash
dart pub get
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
cd apps/flutter_architecture
flutter build bundle
```

### Task 5: Final documentation and release review

- [ ] 同步 current documents 與 Milestone 22 final status。
- [ ] 獨立判斷是否提升 Template Baseline，不預先假設版本變更。
- [ ] Commit：`docs(governance): 完成並封存 Milestone 22 文件治理基礎`

## Plan Self-Review

- [x] 15 項 planning findings 均有 target phase。
- [x] 每個 phase 都有 Task-level review 與 whole-phase review。
- [x] 不全面拆分 Decision 001–022。
- [x] 不一次搬移全部 historical artifacts。
- [x] 不修改 production runtime behavior。
- [x] 22-6 採 TDD 與 Python standard library。
- [x] 沒有 TBD、TODO 或未定義 scope。
