---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-24-toolchain-reproducibility-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-1 — Toolchain and Reproducibility Foundation Review

## Scope

本 review檢查 ADR-023、canonical checker coverage、exact toolchain authority、tracked root lockfile policy、generated consistency script與 Android release artifact script。

本 Task不建立正式 GitHub Actions workflow，也不修改 production signing或 repository settings。

## Delivered Result

- 新增 ADR-023，定義 GitHub Actions host、quality gates、generated authority、Android verification artifact與 CI security boundary。
- ADR index與 checker full-coverage contract由 ADR-001–022擴充至 ADR-001–023。
- Checker新增 regression，確認 authority cutover後缺少 ADR-023會失敗。
- `.github/versions.env`固定 Ubuntu 24.04、Flutter 3.41.6、Temurin Java 17。
- Root `pubspec.lock`不再被忽略，成為 executable workspace的 dependency reproducibility authority。
- `tools/ci/verify_generated.sh`要求乾淨 Git tree，執行 workspace build runner後拒絕任何 tracked或untracked變更。
- `tools/ci/build_android_release.sh`建立 `lib/main.dart` release APK，輸出 SHA命名artifact與 verification-only metadata。
- `artifacts/`加入 ignore，避免本地 artifact evidence污染 repository。

## Review Findings

### M24-1-R01 — Generated check可能誤判既有工作區變更

**Severity：P1**

第一版 script若直接在任意 dirty tree比較結果，無法可靠區分既有修改與 generator新變更。

**Disposition：Closed**

Script改為先要求 clean Git working tree。這與 GitHub Actions乾淨 checkout契約一致，也讓本地使用者得到明確失敗訊息，而不是模糊 diff。

### M24-1-R02 — Artifact output可能成為untracked noise

**Severity：P2**

Build script輸出 repository-local `artifacts/android`，若未忽略會影響後續 generated consistency與一般 Git review。

**Disposition：Closed**

Root `.gitignore`加入 `artifacts/`。APK仍由 workflow artifact保存，不由Git追蹤。

### M24-1-R03 — ADR full coverage仍固定在22

**Severity：P1**

只新增 ADR file與index row會讓 checker的cutover coverage contract與正式authority不一致。

**Disposition：Closed**

Expected range更新至 ADR-023，並新增缺少 ADR-023的fixture regression。

### M24-1-R04 — Windows checkout與WSL Git對line ending判定不同

**Severity：P2**

Windows Git使用`core.autocrlf=true`時工作區為clean，但同一路徑由WSL Git讀取會將部分CRLF檔案判定為modified，導致CI專用clean-tree script在本機WSL產生false positive。

**Disposition：Accepted environment limitation**

正式CI runner固定為Ubuntu fresh checkout，不存在Windows Git與WSL Git共用working tree。Task 24-1保留`bash -n`與Windows Git clean-state證據；完整script execution移至Task 24-2的Ubuntu GitHub Actions run與Task 24-5 clean-run evidence。此限制不得以放寬dirty-tree gate處理。

Open P0／P1：0。

## Verification

```txt
python -m unittest tools.docs.test_check_docs
→ 14 tests passed

dart run melos run docs_check
→ Documentation check passed

bash -n tools/ci/verify_generated.sh
→ Passed

bash -n tools/ci/build_android_release.sh
→ Passed

git diff --check
→ Passed
```

Generated consistency的完整 Ubuntu clean-tree execution與 Android APK實際build會在後續workflow run及 Task 24-5 clean-run gate驗證；目前不以Windows／WSL mixed-Git false positive偽造通過結果。

## Decision

Task 24-1 implementation review通過。可提交本 phase；提交後先在 clean tree執行 generated consistency，再進入 Task 24-2 Pull Request Quality Workflow。
