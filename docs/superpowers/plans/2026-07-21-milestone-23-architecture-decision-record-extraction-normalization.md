---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-23-adr-extraction-implementation-plan
last_reviewed_baseline: 1.5.1
---

# Milestone 23 — Architecture Decision Record Extraction & Normalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 Decision 001–022 安全遷移為可索引、可驗證、可追蹤 supersession且保留歷史連結的 canonical ADR collection。

**Architecture:** 先建立 migration-aware index與 checker，再依低風險到高風險分六批 extraction；aggregate在所有 batch完成前維持完整 authority，最後才獨立 cutover。ADR只保存 durable contract，journal、tests與 releases透過 related evidence routing保存。

**Tech Stack:** Markdown、YAML front matter、Python standard library checker、Melos `docs_check`、Git batch commits。

---

## Task 23-1 — Checker and ADR Index Foundation

**Files:** Create `docs/adr/README.md`、`docs/audits/milestone_23/23-1_checker_index_review.md`; modify `tools/docs/check_docs.py`、`tools/docs/test_check_docs.py`。

- [ ] Add failing fixtures for ADR ID format/uniqueness、filename consistency、missing/orphan index entries。
- [ ] Run `python -m unittest tools.docs.test_check_docs` and verify RED。
- [ ] Implement minimal ADR/index parser without prose inference。
- [ ] Add failing fixtures for missing target、non-reciprocal edge、self edge、cycle、superseded without successor。
- [ ] Implement graph validation and migration-aware coverage；22/22 coverage remains disabled until cutover。
- [ ] Create ADR index skeleton with `aggregate`／`extracted` migration state。
- [ ] Run checker tests、`dart run melos run docs_check`、`git diff --check`。
- [ ] Immediate Task review, fix/re-review, create phase review。
- [ ] Commit: `docs(adr): 建立 ADR 索引與驗證基礎`。

## Task 23-2 — Batch A Foundation Contracts

**Files:** ADR-001、002、003、006、007、008、012; ADR index; manifest; `23-2_batch_a_review.md`。

- [ ] Extract one ADR at a time using fixed sections。
- [ ] Immediately compare each target with source and record semantic result。
- [ ] Add only reviewed relations and index row；aggregate正文不變。
- [ ] Run link/checker validation and whole-batch review。
- [ ] Commit: `docs(adr): 擷取基礎架構決策`。

## Task 23-3 — Batch B Tooling, Governance and Platform Contracts

**Files:** ADR-004、005、009–011、013–014; ADR-012 relation; index; manifest; `23-3_batch_b_review.md`。

- [ ] Normalize ADR-004/012 scope-specific partial supersession。
- [ ] Normalize ADR-005 future tense、ADR-009 governance overlap、ADR-010 platform caveat。
- [ ] Preserve ADR-011 principle but replace stale routing with M22 governance links。
- [ ] Extract ADR-013/014 durable contract and route milestone evidence。
- [ ] Search inbound references, validate, review and commit。
- [ ] Commit: `docs(adr): 正規化治理與平台架構決策`。

## Task 23-4 — Batch C Auth Refresh and Navigation

**Files:** ADR-015、021; index; manifest; `23-4_batch_c_review.md`。

- [ ] Build ADR-015 section disposition map before target writing。
- [ ] Retain refresh/replay/session/failure contract; mark SharedPreferences storage scope superseded。
- [ ] Extract ADR-021 App-owned startup/navigation contract。
- [ ] Review relations with ADR-005–007、012、013、020、022。
- [ ] Validate and commit: `docs(adr): 擷取認證刷新與導航決策`。

## Task 23-5 — Batch D Catalog Data Lifecycle

**Files:** ADR-016、017; index; manifest; `23-5_batch_d_review.md`。

- [ ] Extract pagination/search invariants; route tests/completion evidence。
- [ ] Extract cache/SWR identity、chain、repository、degraded behavior、logout policy。
- [ ] Keep persistence ownership/invariant; route exact DDL/migration history to source/evidence。
- [ ] Validate and commit: `docs(adr): 擷取 Catalog 資料生命週期決策`。

## Task 23-6 — Batch E Presentation Foundations

**Files:** ADR-018–020; index; manifest; `23-6_batch_e_review.md`。

- [ ] Extract Design System/theme authority; remove page sequence/test matrix。
- [ ] Extract localization/locale/failure-copy authority; route completion journal。
- [ ] Extract error/reporting/sensitive-data authority; route 382 tests and audit history。
- [ ] Check cross-ADR terminology, validate and commit。
- [ ] Commit: `docs(adr): 擷取呈現層基礎架構決策`。

## Task 23-7 — Batch F Authentication Security Umbrella

**Files:** ADR-022; ADR-015 relation; index; manifest; `23-7_batch_f_review.md`。

- [ ] Build M19–21 section disposition map。
- [ ] Retain capability split、plugin ownership、security boundaries/non-goals only。
- [ ] Route planning supplements、review gates、tests and versions to audits/plans/CHANGELOG。
- [ ] Finalize ADR-015 credential-storage supersession scope。
- [ ] Perform security semantic review; no expanded OTP/biometric/platform claims。
- [ ] Validate and commit: `docs(adr): 正規化認證安全能力決策`。

## Task 23-8 — Authority Cutover and Legacy Compatibility

**Files:** aggregate、ADR index、legacy `docs/adr/000-*`–`005-*`、`docs/architecture/*`、AGENTS、Documentation Hub、roadmap/current indexes、checker/tests、`23-8_cutover_review.md`。

- [ ] Verify 22/22 accepted semantic/link/checker results。
- [ ] Add RED tests for full coverage and managed legacy routes。
- [ ] Activate full 001–022 coverage checks。
- [ ] Convert aggregate to transitional stable-ID index/stub; do not delete file。
- [ ] Convert old ADR placeholders to `legacy` routing without inventing ADR-000。
- [ ] Preserve historical architecture guides and add canonical authority links。
- [ ] Update all current Architecture task routes to `docs/adr/README.md`。
- [ ] Run tests、docs_check、diff check and rollback rehearsal。
- [ ] Commit: `docs(adr): 切換正式 ADR authority 與相容路由`。

## Task 23-9 — Whole-Milestone Final Review and Archive

**Files:** `23-9_final_review.md`; roadmap/project context/indexes/manifest; VERSION/CHANGELOG only if final release review approves。

- [ ] Close M23-PR01–PR12; no open P0/P1 without disposition。
- [ ] Run `dart pub get`、docs_check、analyze、all Flutter tests、`git diff --check`。
- [ ] Verify unique canonical routing、acyclic graph、22/22 coverage and compatibility paths。
- [ ] Decide PATCH/no-release only at final review。
- [ ] Archive and commit: `docs(governance): 完成並封存 Milestone 23 ADR 正規化`。

## Self-Review

本 plan涵蓋 inventory、分類、non-ADR routing、legacy strategy、format、manifest、batches、semantic/link/checker gates、rollback與 final cutover。Batch G前不移除 aggregate正文，不搬移 audits/plans，不修改 runtime/dependencies/platform configuration。
