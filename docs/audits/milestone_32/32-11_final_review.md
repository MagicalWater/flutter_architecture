---
document_type: final-review
status: accepted
authoritative_for:
  - milestone-32-final-review
last_reviewed_baseline: 1.14.0
---

# Milestone 32 — Holistic Final Review

## Scope

本review涵蓋Requirement Decision、accepted Design、accepted Implementation Plan、Tasks 1～11、artifact ownership、schema、multi-job aggregation、retention、capacity、secret boundary、Observability、failure evidence、GitHub transport、rollback與不可逆cleanup。

## Cross-Task findings

### F-32-11-01 — Windows與macOS測試fixture path semantics不同

Severity：P1。Disposition：Resolved。測試fixture正規化macOS `/var → /private/var` alias，Windows default path使用host-independent比較；production symlink與root安全規則未放寬。

### F-32-11-02 — Windows `apkanalyzer.bat`未被Unix-only resolver找到

Severity：P1。Disposition：Resolved。Resolver支援SDK roots與`.bat`，並以TDD驗證；Windows與Mac APK application ID均可受控解析。

### F-32-11-03 — Codegen normalizer進入volatile Gradle build目錄

Severity：P1。Disposition：Resolved。Traversal在遞迴前排除`.dart_tool`、`build`與`.git`，不再因建置期間目錄消失造成假失敗。

### F-32-11-04 — iOS DerivedData誤進永久evidence

Severity：P1。Disposition：Resolved。Xcode workspace改至job-local `.build`，finalize前只允許精確移除該目錄；iOS evidence由約3.06 GB／23,689 files降至約232.8 MB／271 files，保留`.app`、dSYM與metadata。

### F-32-11-05 — GitHub cache自動淘汰使reviewed manifest漂移

Severity：P1。Disposition：Resolved。所有scope變動都回到Task 10重新inventory／review／approval；沒有沿用舊核准。Final execution只涵蓋當時仍存在的110個artifacts與3個caches。

### F-32-11-06 — Provider `expired`旗標造成非DELETE scope假漂移

Severity：P1。Disposition：Resolved。TDD將fingerprint收斂為exact deletion candidate scope；ID、bytes、名稱、時間、workflow run或ref任何變動仍fail closed。

## Architecture and security review

- GitHub Actions維持control plane；manual-local與self-hosted的raw evidence由external managed store擁有。
- Workflow與build scripts沒有平行artifact schema；job／run manifest是retention與cleanup authority。
- Multi-job finalize使用獨立job paths與run aggregation，不覆蓋其他job。
- Secret、service account、provider config、signing material與完整environment不進manifest；failure／Observability evidence先掃描。
- Local cleanup只接受exact external root與immutable manifest；trash可在24小時窗口restore，purge後不可恢復。
- GitHub cleanup只使用exact-ID endpoints，並具review、approval、fresh GET與fail-closed gates；不存在prefix／workflow／ref批量刪除路線。
- Production signing、Store distribution與physical-device acceptance仍為deferred，不因verification artifact成功而提升claim。

## Validation evidence

```txt
Repository CI contract tests: 202 passed
Documentation checks: passed
Workspace analyze: passed in 5 packages
All Flutter package tests: passed
App Flutter suite: 463 passed
Generated consistency: passed
Mac manual-local Android: passed
Mac manual-local iOS: passed
Windows manual-local Android: passed
All representative checksums: passed
Managed evidence secret scan: passed
GitHub exact deletion attempts: 113 deleted / 0 failed
GitHub post-delete inventory: 0 objects / 0 bytes
Exact-ID absence verification: 113 / 113 passed
```

## Release decision

Milestone新增可選且可重用的CI artifact ownership、retention、cleanup與GitHub quota cutover能力，符合MINOR版本。Template Baseline由1.13.0提升至1.14.0；不是App上架版本。

## Final disposition

```txt
Tasks 1–11 implementation and local review: ACCEPTED
Template Baseline: 1.14.0
Open P0: 0
Open P1 without disposition: 0
Release commit: f4f6a8e76eebe13be2e039db72c6e27a9c1df380
Post-release self-hosted validation: PASSED
Formal remote closure: COMPLETED
```

Release SHA已完成self-hosted CI／Android／iOS、Observability ordinary push skipped、GitHub storage 0／0與clean-checkout驗證。Post-release authority由`32-12_post_release_validation.md`保存，Milestone可正式closure。
