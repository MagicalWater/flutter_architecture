---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-023-repository-ci-quality-gates-android-verification-artifact
last_reviewed_baseline: 1.5.1
id: ADR-023
title: Repository CI Quality Gates and Android Verification Artifact
supersedes: []
superseded_by: []
related:
  - ADR-002
  - ADR-009
  - ADR-011
  - ADR-014
---

# ADR-023 — Repository CI Quality Gates and Android Verification Artifact

## Status

Accepted。

## Authoritative Scope

本Decision定義repository CI host、required quality gates、toolchain reproducibility、generated source consistency、Android verification artifact與CI security boundary。

## Context

Repository已具備workspace commands、documentation checker、全量tests、tracked generated source與Android supported runner，但這些品質契約仍依賴人工執行。若沒有repository-level automated gates，Pull Request與main commit無法持續證明文件、架構、generated source、tests與Android artifact維持一致。

CI本身也會引入runner drift、floating Action、secret exposure、cache dependency與production artifact誤解，因此需要durable boundary，而不是只新增一份workflow YAML。

## Decision

GitHub Actions是repository CI host。

Pull Request到`main`必須執行穩定命名的quality、generated consistency與test checks。Push到`main`必須重新驗證repository state，並在乾淨Linux runner建立Android release APK verification artifact。Manual dispatch可重跑相同能力。

CI使用固定runner OS major version、exact Flutter version與Java 17。Executable workspace追蹤root `pubspec.lock`，使乾淨runner驗證已知dependency graph。

Generated source維持tracked。CI重跑generator後必須檢查Git tree；任何changed、deleted或untracked generated file都使gate失敗，CI不得自動commit。

Android artifact使用default development／Mock entrypoint與repository既有verification signing。Artifact必須帶commit traceability與明確的非production classification。`flutter build bundle`不能替代Android APK artifact驗證。

Cache只用於加速Pub、Flutter SDK與Gradle dependency取得；cache miss不得改變correctness。`.dart_tool`、workspace build output、generated source與APK不作為shared cache authority。

Workflow permissions採最小權限，不讀取secrets，不使用`pull_request_target`。所有external Actions pin immutable full commit SHA。

Production signing、Store publishing、GitHub Release、environment promotion與deployment credentials必須由未來獨立release workflow與protected Environment決定，不屬本Decision第一版實作。

## Consequences

- Merge contract由人工checklist提升為repository-enforced checks。
- Toolchain與dependency graph變更必須透過reviewable repository change發生。
- Generated source omission會在PR被阻擋。
- Main commit可取得可追溯的Android verification APK，但不會被誤稱為production release。
- CI workflow與pinned Actions需要後續maintenance；Dependabot不因本Decision自動加入。
- GitHub Branch Protection settings仍需repository管理者依文件人工設定，code不能宣稱已完成settings變更。

## Supersession

本Decision未取代既有ADR。

## Related Decisions

- ADR-002：Monorepo與Melos workspace contract。
- ADR-009：版本與變更紀錄治理。
- ADR-011：文件Single Authority原則。
- ADR-014：App environment entrypoint與production validation boundary。

## Related Evidence

- [Milestone 24 planning review](../audits/milestone_24/24-0_planning_review.md)
- [Milestone 24 implementation plan](../superpowers/plans/2026-07-22-milestone-24-ci-cd-foundation.md)

## Last Reviewed Baseline

1.5.1。
