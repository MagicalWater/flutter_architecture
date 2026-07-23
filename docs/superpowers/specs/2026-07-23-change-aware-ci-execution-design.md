---
document_type: design-spec
status: proposed
authoritative_for:
  - change-aware-ci-execution-design
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Execution Design

## Status

Proposed / Awaiting Review。

本文件定義repository CI從「任何`main` push都執行完整分析、測試與Android／iOS編譯」調整為change-aware execution的設計。它不直接修改workflow implementation。

## Problem

目前`.github/workflows/ci.yml`、`android.yml`與`ios.yml`只限制branch，沒有變更分類：

```yaml
push:
  branches:
    - main
```

因此純Markdown、audit evidence或routing修正也會：

- 執行workspace analyze、generated consistency與全部Flutter tests。
- 建立development／production Android artifacts。
- 使用macOS runner建立development／production iOS artifacts。

這可確保每個`main` commit都有完整證據，但會增加等待時間、GitHub Actions成本，並讓「remote evidence文件本身再次觸發完整remote evidence」形成不必要的循環。

## Goals

- 純文件變更只執行文件、workflow contract與whitespace等輕量檢查。
- Dart、package、native、dependency、toolchain或CI implementation變更仍執行完整相關驗證。
- `VERSION`、release contract或manual dispatch強制執行完整CI、Android與iOS代表矩陣。
- Required check名稱維持穩定，不因workflow-level path filtering而永久pending。
- Change classification本身必須可測試、fail-safe且有正式operations documentation。

## Non-goals

- 不縮減release commit的完整remote validation。
- 不讓source變更只因分類錯誤而跳過必要測試或build。
- 不新增production signing、Store publishing或deployment automation。
- 不導入第三方path-filter action；第一版使用repository-owned script與Git diff。
- 不把每個package建立成獨立動態matrix。

## Considered Approaches

### A. Workflow-level `paths-ignore`

在Android／iOS workflow直接忽略`docs/**`與Markdown。

優點：設定最少、純文件push不建立workflow。

缺點：若workflow或job名稱是required check，GitHub可能因run未建立而維持pending；也無法一致表達release override與跨workflow分類。拒絕作為主要方案。

### B. Job-level inline path expressions

每份workflow各自以`git diff`或複雜`if:`判斷是否執行。

優點：workflow仍建立，required check較穩定。

缺點：三份workflow會複製分類規則，容易drift，難以單元測試。拒絕作為正式authority。

### C. Repository-owned change classifier with stable gate jobs

新增單一repository-owned classifier，輸出`docs_only`、`full_ci`、`android_build`、`ios_build`與`release_full`。每份workflow先執行輕量classification job，再由重量級job使用`if:`判斷；必要時以穩定summary/gate job收斂結果。

優點：分類規則集中、可測試、可文件化、required check名稱可保持穩定，並可明確支援release override。

缺點：workflow結構稍增，需處理push、pull request與manual dispatch的base/head range。

採用Approach C。

## Change Classes

### Documentation-only

只包含下列文件與evidence變更，且沒有其他路徑：

```txt
**/*.md
docs/**
README.md
CHANGELOG.md
```

例外：`VERSION`不屬於documentation-only；它永遠觸發release full matrix。

Documentation-only執行：

- Documentation checker與link／metadata治理。
- CI workflow contract tests。
- Change classifier contract tests。
- `git diff --check`。

不執行：

- Workspace analyze。
- Generated consistency。
- 全部Flutter tests。
- Android／iOS代表build。

### Full CI source change

下列任一範圍變更時執行analyze、generated consistency與全部Flutter tests：

```txt
apps/**
packages/**
tools/**
pubspec.yaml
pubspec.lock
melos.yaml
analysis_options.yaml
.github/versions.env
.github/workflows/**
```

未知或無法分類的路徑採fail-safe：`full_ci=true`。

### Android build change

下列任一範圍變更時執行Android development與production代表build：

```txt
apps/flutter_architecture/android/**
apps/flutter_architecture/lib/**
apps/flutter_architecture/config/**
packages/**
tools/ci/build_android_*
tools/ci/verify_environment_contract.py
pubspec.yaml
pubspec.lock
melos.yaml
.github/versions.env
.github/workflows/android.yml
.github/workflows/ci.yml
```

`VERSION`與manual dispatch強制`android_build=true`。

### iOS build change

下列任一範圍變更時執行iOS Development Simulator與Production unsigned device代表build：

```txt
apps/flutter_architecture/ios/**
apps/flutter_architecture/lib/**
apps/flutter_architecture/config/**
packages/**
tools/ci/build_ios_*
tools/ci/verify_environment_contract.py
pubspec.yaml
pubspec.lock
melos.yaml
.github/versions.env
.github/workflows/ios.yml
.github/workflows/ci.yml
```

`VERSION`與manual dispatch強制`ios_build=true`。

## Event Semantics

### Pull request

比較PR base SHA與head SHA。Workflow必須建立，以維持required checks穩定；重量級jobs依classification執行或skipped。

### Push to `main`

比較event before SHA與after SHA。首次push或無有效before SHA時採fail-safe full matrix。

### Manual dispatch

視為明確要求完整驗證：

```txt
full_ci=true
android_build=true
ios_build=true
release_full=true
```

### Release override

`VERSION`變更時，即使其他變更只有文件，仍強制完整CI與兩平台代表build。

## Workflow Design

### CI workflow

保留穩定check名稱：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
```

`CI / Quality`永遠執行輕量治理檢查；只有`full_ci=true`時額外執行dependency resolution與workspace analyze。

`Generated Consistency`與`Tests`在`full_ci=true`時執行。若因documentation-only而跳過，workflow應提供穩定成功的gate／summary，不讓required status缺失。

### Android workflow

Workflow在每次`main` push與manual dispatch建立。Build jobs只有`android_build=true`時執行；documentation-only時由輕量summary job成功結束，不上傳artifact。

### iOS workflow

Workflow在PR、`main` push與manual dispatch建立。兩個build jobs只有`ios_build=true`時執行；documentation-only時由輕量summary job成功結束，避免macOS runner使用。

分類job優先使用Ubuntu runner；不得為了判斷是否需要iOS build而先啟動macOS runner。

## Documentation Authority

- Durable CI architecture與required-check原則：ADR-023摘要更新。
- 日常trigger matrix、manual override、skip semantics與failure handling：`docs/guides/ci_cd_operations.md`。
- 本設計與implementation plan：`docs/superpowers/`。
- Review findings與remote behavior evidence：`docs/audits/`。

Current project context只需摘要「CI已採change-aware execution」，不得複製完整path matrix。

## Testing Strategy

- 新增classifier unit tests，覆蓋documentation-only、Dart source、Android-only native、iOS-only native、package、workflow、dependency、`VERSION`與未知路徑。
- 新增event range tests，覆蓋PR、push、invalid before SHA與manual dispatch。
- 更新workflow contract tests，確認classification job、job-level conditions、stable gate names、release override與secret boundary。
- YAML parse、shell portability、docs checker與link checker必須通過。
- Local simulation應證明：
  - docs-only：不要求Android／iOS build。
  - source：執行full CI與相關平台build。
  - `VERSION`：完整矩陣。
- 推送後以三類commit或manual dispatch取得remote evidence；至少驗證一個docs-only commit未啟動macOS build job。

## Rollback

若classification造成必要job錯誤跳過：

1. 立即以`workflow_dispatch`執行完整矩陣。
2. 將classifier default改為fail-safe full matrix。
3. Revert change-aware conditions，恢復所有push完整執行。
4. 保留finding與remote evidence，不以降低required checks掩蓋問題。

## Acceptance Criteria

- 純文件push不使用Android／iOS build runner，也不執行完整Flutter test／generated jobs。
- `VERSION`變更固定執行完整CI、Android與iOS代表矩陣。
- Source、package、native、dependency、toolchain與workflow變更不會被誤判為docs-only。
- Unknown path與classification failure採full matrix。
- Required check名稱與Branch Protection guidance保持可預測。
- CI operations guide完整說明trigger matrix與manual full-validation方式。
- Local contracts與remote evidence均通過，Open P0／P1 without disposition為0。
