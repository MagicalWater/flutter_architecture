---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-33-release-sha-validation
  - milestone-33-post-release-closure-evidence
last_reviewed_baseline: 1.15.0
---

# Milestone 33 — Task 33-13 Post-release Validation

## Release identity

```txt
Template Baseline: 1.15.0
Release commit: ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
Release commit message: chore(release): 發布模板1.15.0
Integration strategy: fast-forward only
Force push: no
```

Release commit完成後，local `main`由`c639624a1b231d13854bcd9a70d500120b6ea624` fast-forward至`ced0c07`，並以一般push發布至`origin/main`。第一次發布後確認：

```txt
local main  = ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
origin/main = ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
ahead/behind = 0/0
```

## Fresh clean-checkout authority

發布後驗證沒有重用implementation worktree，而是由DevSpace自release SHA建立新的managed detached worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-0533699a
HEAD: ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
VERSION: 1.15.0
initial status: clean
```

所有下列release-SHA validation都在此clean checkout執行。

## Dependency and generated-source validation

Fresh commands：

```txt
dart pub get
dart run melos run build_runner
```

兩者皆exit 0。Windows codegen完成後，Git曾將部分generated files標為modified；進一步執行content diff確認：

```txt
git diff --exit-code -- .
→ CONTENT_DIFF_NONE
```

因此該狀態只屬Windows LF／CRLF working-tree normalization/stat noise，不是generated source drift。Detached validation worktree隨後`git reset --hard HEAD`回到release SHA，重新確認clean後繼續驗證；沒有任何release source被修改。

## Repository governance and documentation validation

Fresh commands：

```txt
python -m unittest \
  tools.docs.test_skill_lock \
  tools.docs.test_check_docs \
  tools.visual.test_verify_visual_authority

dart run melos run docs_check
dart run melos run analyze
```

Fresh results：

```txt
Skill／Docs／Visual Authority tests: 45 passed
Documentation check: passed
Workspace analyze: 5 packages SUCCESS / No issues found
```

## Full Flutter regression

Fresh command：

```txt
dart run melos exec -- flutter test
```

Result：

```txt
all 5 packages: SUCCESS
App package: +484 All tests passed
```

## Build validation

Development bundle：

```txt
flutter build bundle \
  --target lib/main_development.dart \
  --dart-define=NATIVE_ENVIRONMENT=development
→ exit 0
```

Governed Android development artifact使用repository checkout外的local artifact store：

```txt
ARTIFACT_DIR=%LOCALAPPDATA%\flutter_architecture\ci-artifacts\m33-post-release\ced0c07\android-development
PYTHON_BIN=python
tools/ci/build_android_development.sh
→ exit 0
```

Verified metadata：

```txt
commit_sha=ced0c072db1c9ee5b15a6f2e0af9cb89a54ebe9f
environment=development
platform=android
flavor=development
entrypoint=lib/main_development.dart
api_mode=mock
build_mode=debug
package_id=com.example.flutterarchitecture.development
signing=debug signing for verification only
distribution=not production-ready
```

`zh`的16個untranslated warnings為既有OTP localization debt；Milestone 33新增的`pencilPrecheck*`keys已由Task 33-7／33-9 parity tests證明完整，不把既有warning誤歸因到本release。

## Clean-checkout Skill resolution and collision proof

DevSpace從clean checkout重新載入repository-local Skills，並顯示其路徑全部位於release-SHA worktree。另以machine check驗證五個first-party workflow Skills：

```txt
governing-template-development
starting-feature-work
karpathy-guidelines
adopting-template-product-identity
implementing-pencil-flutter-design
```

每個名稱都只解析到：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-0533699a\.agents\skills\<name>\SKILL.md
```

Machine result：

```txt
REPOSITORY_SKILL_DUPLICATE_NAMES=0
REPOSITORY_SKILL_TOTAL=8
```

三份managed Taste companions也由同一clean checkout載入；`tools.docs.test_skill_lock`重新驗證source／hash／license／install path。Global Codex cache存在一條與本repository無關的missing-path warning，但沒有與repository Skill同名的runtime collision，沒有改變release routing。

## Fresh visual acceptance

未使用`--update-goldens`，fresh執行：

```txt
flutter test test/features/pencil_compatibility/presentation/write_precheck_golden_test.dart
flutter test test/features/pencil_compatibility/presentation/write_precheck_visual_diff_test.dart
```

兩者皆PASS。Fresh metrics：

```txt
canonical viewport: 941 × 1672
differentPixelRatio: 0.07781856825427495
fixed threshold: <= 0.08
meanAbsoluteChannelDelta: 2.995617318947063
fixed threshold: <= 8.0
maxChannelDelta: 243
canonical golden SHA-256:
533cc857149f831046dcce0804c4121d7731118ff8f54915dae103be25d6a020
```

Historical relative comparison也PASS，且維持same-era native-size comparison，不對226×400 historical proof做silent resize。

## Android runtime evidence continuity

Tracked runtime evidence仍存在且bytes未漂移：

```txt
docs/audits/milestone_33/visual_validation/android-runtime-screenshot.png
bytes: 307384
SHA-256:
358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919
```

Task 33-10已驗證其runtime metrics：

```txt
physical: 540 × 960
DPR: 1.5
logical: 360 × 640
textScale: 1.0
```

## Governance closure

Milestone 33不是以release commit取代review：

- Design與ADR先經Design-level Task review及使用者核准。
- Implementation Plan先經Plan-level Task review及使用者核准。
- Tasks 33-1～33-11各自具有focused review、finding disposition、fresh re-review與whole-Task acceptance evidence。
- Task 33-6R與33-10R對Final Review期間發現的current-index／Flutter API相容性finding補做有界corrective governance與獨立commit。
- Task 33-12完成跨Task Holistic Final Review，freeze disposition A，Open P0=0、undispositioned P1=0。
- Task 33-13另行執行release identity、main integration、remote publication與fresh release-SHA validation，release與Milestone closure沒有被合併成同一個未驗證宣稱。

## Final disposition

```txt
Release SHA validation: PASS
Remote release-SHA equality: PASS
Fresh clean-checkout regression: PASS
Clean-checkout Skill resolution: PASS
Fresh canonical visual acceptance: PASS
Open P0: 0
Undispositioned P1: 0
Milestone 33: READY FOR CLOSED / ARCHIVED ROUTING
```

本文件的closure commit在release-SHA validation全部完成後建立；該commit push完成後的local／remote equality由Task 33-13最終執行狀態再次確認。
