---
document_type: planning-review
status: accepted
authoritative_for:
  - change-aware-ci-spec-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Design Specification Review

## Scope

本review審查：

- `docs/superpowers/specs/2026-07-23-change-aware-ci-execution-design.md`
- `.github/workflows/ci.yml`
- `.github/workflows/android.yml`
- `.github/workflows/ios.yml`
- `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md`
- `docs/guides/ci_cd_operations.md`

人工核准只作為輸入；本文件記錄完整technical review、findings、修正與re-review結果。

## First Review Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-SR01 | P1 | 原spec允許重量job整體skipped，再由不同名稱summary job維持required check；GitHub status check以job name為key，summary不能替代`CI / Tests`、`CI / Generated Consistency`或`iOS / Simulator Build` | 修正為stable job永遠建立，documentation-only在同一job內執行no-op；iOS Simulator job以dynamic runner避免啟動macOS |
| CA-CI-SR02 | P1 | Unknown path段落只明示`full_ci=true`，與其他段落要求fail-safe full matrix矛盾，可能漏掉Android／iOS build | 明確改為`full_ci=true`、`android_build=true`、`ios_build=true` |
| CA-CI-SR03 | P1 | Classifier本身或classification wiring變更未被明確列為兩平台build trigger，可能讓錯誤分類邏輯在沒有平台驗證下進入main | 明確要求classifier、classifier tests與wiring變更強制兩平台build |
| CA-CI-SR04 | P1 | iOS required-check候選與「build job skipped」設計衝突；若job skipped，Branch Protection語意不可靠 | `iOS / Simulator Build`改為永遠建立，docs-only使用Ubuntu no-op；Production Release job維持非required可skipped |
| CA-CI-SR05 | P2 | Android未來若成為required check，現有可skipped設計會重現同類問題 | 文件加入前置條件：成為required前必須轉stable-job internal no-op模式 |
| CA-CI-SR06 | P2 | Event Semantics仍以「重量級jobs skipped」概括PR行為，與required-check同job no-op設計不一致 | 修正為required job執行重量steps或同job no-op，只有非required job可skipped |

## Re-review

修正後重新檢查：

- Required check名稱與job建立語意一致。
- Docs-only不啟動macOS runner。
- Unknown與classification failure均fail-safe full matrix。
- Classifier自身變更不會跳過平台驗證。
- Android目前非required與iOS Simulator required候選的差異有明確處理。
- Release／`VERSION`／manual dispatch仍強制完整矩陣。
- Scope沒有擴張到signing、Store distribution或deployment。

## Gate

```txt
Open P0: 0
Open P1 without disposition: 0
Spec status: Accepted
Plan review allowed: Yes
Implementation allowed: No, pending plan review
```

