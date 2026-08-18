---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-5-ui-design-owner-migration
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-5 UI Design Owner Migration Review

## Scope

Retire `PencilCompatibilityVisualSpec` catch-all，並把仍有production consumer的UI design values移至窄責任owner；不建立等價`*VisualTokens`／`*UiSpec`／`*StyleConfig` replacement。

## Fresh usage audit

舊class包含的下列值沒有任何production consumer，因此直接退休，不建立replacement token：

```txt
canonicalSize
canonicalDevicePixelRatio
maxContentWidth
cardRadius / recordRadius / buttonRadius / pillRadius / guidanceRadius
pageGradient / surfaceGradient
backgroundDeep / surface / surfaceRaised / border / borderSoft
cyan / cyanBright / cyanDeep / gold / goldSoft
```

Canonical viewport/DPR仍由repository visual authority manifest擁有，不再建立Dart visual-spec owner。

真正仍有consumer的shared proof values只有：

- `background / text / muted / dim`；
- `Noto Sans TC`與fallback。

## New focused owners

```txt
widgets/write_precheck/write_precheck_palette.dart
→ WritePrecheck proof shared palette only

widgets/write_precheck/write_precheck_typography.dart
→ WritePrecheck proof typography only
```

兩者都是窄責任feature-local owner，對應Task 42-2 mapping中的`intentional-local` disposition。它們不是template Theme Identity，也不得在沒有新的semantic/shared-owner evidence時promotion至Design System。

Component-only geometry與decorative values仍由實際bounded component implementation持有，不建立新的geometry/gradient token mega-class。

## Asset disposition

Current Write Precheck reference沒有需要新增asset path owner。本Task沒有建立asset constants registry；既有raster/vector/icon/font representation與provenance仍由Milestone 34 established mapping contract擁有。未來asset consumer只能引用resolved asset owner/evidence，不得塞回visual token/spec class。

## Test migration

舊`write_precheck_copy_test.dart`曾把整個`PencilCompatibilityVisualSpec`當stable contract，連unused values也鎖死。這正是catch-all architecture的一部分，因此改為只驗證仍有runtime responsibility的focused palette與typography identity。

Canonical viewport/DPR不是被刪除驗證；其authority已由visual manifest/hash validator覆蓋。

`write_precheck_view_test.dart`同步更新content owner import，避免test繼續依賴已退休page implementation path。

## Fresh validation

```txt
dart analyze lib/features/pencil_compatibility/presentation
→ No issues found

flutter test test/features/pencil_compatibility
→ 22 tests PASS
```

22 tests包含architecture contract、copy、route、view、responsive/semantics、critical geometry、canonical golden、runtime golden與visual diff owners。

## Focused review findings

- P1：直接把old class rename成`WritePrecheckVisualTokens`。Resolved：不存在此class；unused values直接刪除，shared values拆成palette/typography窄責任owner。
- P1：把proof palette強制promotion進Design System。Resolved：mapping已記錄其非template-wide Theme Identity理由，保持feature-local。
- P1：canonical viewport/DPR被誤放Design System或新的Dart token class。Resolved：只留visual authority manifest ownership。
- P1：test繼續把所有舊magic values當stable contract，導致catch-all復活。Resolved：test只鎖仍有實際owner的focused identity；visual authority由既有machine owner驗證。

## Whole-Task disposition

```txt
Task 42-5: PASS / ACCEPTED
PencilCompatibilityVisualSpec: RETIRED
Equivalent generic mega-class replacement: none
Task 42-4 recovery validation: PASS
Open P0: 0
Open P1 without disposition: 0
```
