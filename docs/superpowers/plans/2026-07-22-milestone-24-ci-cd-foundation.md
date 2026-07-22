---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-24-ci-cd-foundation-implementation-plan
last_reviewed_baseline: 1.5.1
---

# Milestone 24 — CI/CD Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將既有repository quality contract轉為GitHub Actions automated gates，並為每個main commit建立可追溯的Android release APK verification artifact。

**Architecture:** 使用兩份workflow分離repository CI與Android artifact。CI jobs平行執行docs/analyze、generated consistency與全量tests；Android workflow在main push或manual dispatch自給自足地完成乾淨build。Version pin、lockfile、cache、permissions與Action SHA均由repository管理，production release維持明確非目標。

**Tech Stack:** GitHub Actions、Flutter 3.41.6、Dart Pub Workspaces、Melos 8、Temurin Java 17、Python documentation checker、Gradle 8.14、Android APK。

---

## Task 24-1 — Toolchain and Reproducibility Foundation

**Files:** Create `.github/versions.env`、`tools/ci/verify_generated.sh`、`tools/ci/build_android_release.sh`、`docs/audits/milestone_24/24-1_tooling_review.md`; modify `.gitignore`; track root `pubspec.lock`。

- [ ] Add exact Flutter／Java version authority with shell-readable format。
- [ ] Add generated consistency script that runs workspace build_runner and fails on tracked diff or untracked output。
- [ ] Add Android build script that builds `apps/flutter_architecture` release APK from `lib/main.dart`, renames it with short SHA and writes metadata。
- [ ] Remove root `pubspec.lock` ignore rule and stage the existing resolved lockfile without dependency upgrade。
- [ ] Run scripts locally where applicable、`dart pub get`、docs_check與`git diff --check`。
- [ ] Immediate Task review：reproducibility、shell safety、paths、metadata與non-production classification。
- [ ] Fix／re-review直到Open P0／P1為0。
- [ ] Commit: `build(ci): 建立工具鏈與可重現性基礎`。

## Task 24-2 — Pull Request Quality Workflow

**Files:** Create `.github/workflows/ci.yml`、`docs/audits/milestone_24/24-2_ci_workflow_review.md`。

- [ ] Add `pull_request` to main、push main與workflow_dispatch events。
- [ ] Add workflow-level `contents: read`與PR/ref concurrency cancellation。
- [ ] Add stable jobs `Quality`、`Generated Consistency`、`Tests`，不建立cross-job artifact dependency。
- [ ] Pin checkout、Java setup、Flutter setup與cache-related Actions to full commit SHA。
- [ ] Execute docs_check、analyze、diff check、generated script與all Flutter tests。
- [ ] Review fork safety、no secrets、no `pull_request_target`、cache miss correctness與required check names。
- [ ] Run YAML/static validation、repository verification、fix/re-review。
- [ ] Commit: `ci: 建立 Pull Request 品質驗證`。

## Task 24-3 — Android Verification Artifact Workflow

**Files:** Create `.github/workflows/android.yml`、`docs/audits/milestone_24/24-3_android_workflow_review.md`。

- [ ] Add push main與workflow_dispatch events。
- [ ] Configure event-aware concurrency that does not cancel distinct main commit artifact builds。
- [ ] Use exact toolchain、root lockfile、Pub／Gradle cache與minimal permissions。
- [ ] Run generated consistency prerequisite, then build release APK through repository script。
- [ ] Upload SHA-named APK and metadata with14-day retention。
- [ ] Review artifact path、entrypoint、signing classification、traceability與failure behavior。
- [ ] Run local release APK build and workflow static validation、fix/re-review。
- [ ] Commit: `ci(android): 建立 main 分支 APK 驗證產物`。

## Task 24-4 — Branch Protection and CI Operations Guide

**Files:** Create `docs/guides/ci_cd_operations.md`、`docs/audits/milestone_24/24-4_governance_review.md`; modify `docs/README.md`、root `README.md`、`AGENTS.md` where routing or commands require update。

- [ ] Document required check names and recommended main Branch Protection settings without claiming settings were changed。
- [ ] Document rerun、cache degradation、generated failure、main artifact failure與workflow rollback procedures。
- [ ] Document artifact naming、retention、metadata與verification-only signing。
- [ ] Document future production release extension point and explicit non-goals。
- [ ] Add managed guide metadata and navigation routes without duplicating ADR contract。
- [ ] Run docs checker、link review、fix/re-review。
- [ ] Commit: `docs(ci): 建立 CI 操作與分支保護指南`。

## Task 24-5 — Clean-run and Workflow Validation

**Files:** Create `docs/audits/milestone_24/24-5_clean_run_review.md`; modify workflows/scripts only for verified fixes。

- [ ] Validate workflow YAML and pinned Action references。
- [ ] Run fresh dependency resolution with tracked lockfile。
- [ ] Run docs_check、analyze、all Flutter tests、generated consistency與`git diff --check`。
- [ ] Remove local build intermediates as appropriate and build release APK from the repository script。
- [ ] Verify APK filename、metadata、SHA traceability、entrypoint與debug-signing warning。
- [ ] Verify cache is not required by repeating critical commands without restored workspace build state。
- [ ] Record exact evidence、review findings、fix/re-review。
- [ ] Commit: `test(ci): 完成乾淨環境與產物驗證`。

## Task 24-6 — Whole-Milestone Final Review and Archive

**Files:** Create `docs/audits/milestone_24/24-6_final_review.md`; modify roadmap、project context、milestone index、candidate/backlog、README、CHANGELOG、VERSION according to final release decision。

- [ ] Close M24-PR01–PR09；Open P0／P1為0。
- [ ] Review events、jobs、dependencies、concurrency、cache、permissions、Action pinning與Branch Protection guidance。
- [ ] Run full repository verification and final Android release APK build。
- [ ] Confirm no production secret／signing／deployment scope entered the milestone。
- [ ] Decide PATCH `1.5.2` versus no release based on delivered repository capability；full implementation預設建議PATCH。
- [ ] Archive Milestone 24 and update current routing without duplicating implementation journal。
- [ ] Commit: `docs(release): 封存 Milestone 24 CI/CD Foundation`。

## Self-Review

本plan涵蓋planning findings、toolchain pin、tracked lockfile、generated consistency、PR/main/manual events、parallel jobs、cache、Android entrypoint與artifact、permissions、Action pinning、Branch Protection、failure／rollback、clean-run evidence與release decision。第一版不包含Store publishing、production signing、iOS build、release automation、flavors或dependency auto-update。
