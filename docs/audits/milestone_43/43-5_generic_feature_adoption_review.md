---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-43-task-43-5-generic-feature-adoption
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Task 43-5 Generic Feature Adoption Review

## Scope

以Catalog、OTP、Shell三組一般Flutter presentation owners驗證ADR-032不是Pencil-only規則，並同時驗證anti-formalism：只在fresh responsibility review找到獨立change reason時extract；正確的local state與surface ownership保留不動。

## Test Authoring Decision

`no-new-test justified`。本Task不新增observable behavior；existing Catalog/Auth/Shell tests與Task 43-3 generic architecture contract已直接覆蓋受影響boundary。

## Catalog disposition

Fresh review確認`CatalogPage`／`CatalogView`仍應保留CatalogBloc binding、screen-level event wiring、`useScrollController()`、load-more threshold listener、reconnect-to-Bloc transition與refresh lifecycle bridge。`ScrollController`是widget lifecycle mechanics，不升級成`CatalogScrollCubit`。

cache status與reconnect status具有共同且獨立於screen orchestration的bounded presentation responsibility，因此一起extract至：

```txt
lib/features/catalog/presentation/widgets/catalog_status_surfaces.dart
```

兩個related status widgets共用同一source，刻意不採one-widget-one-file。

## OTP positive no-refactor

`OtpView`的`Timer.periodic` + local `setState()`只讓resend countdown重新render；OTP challenge、verify、resend、failure與busy workflow仍由`AuthBloc`擁有。

Disposition：PASS / no refactor。新增`OtpCountdownCubit`反而會把純widget lifecycle變成不必要workflow state。

## Shell positive ownership

`ShellPage`保留Appearance／Locale／Local Unlock surface invocation；surface implementation分別由Theme、Localization、Auth app presentation owner持有。

`ShellPage + ShellScaffold`目前共享shell navigation/chrome composition，fresh review未找到需要因lifecycle或change reason強制拆檔的P1。

Disposition：PASS / no refactor。

## Focused review

- 沒有固定`pages/widgets/components` skeleton要求。
- 沒有line count、class count、`setState`或Bloc presence判定。
- Catalog extraction以change reason與bounded surface owner為依據。
- OTP、Shell作positive no-refactor證明。
- Design System promotion沒有擴張；Catalog status仍是feature-local composition，底層使用既有`DsStatusBanner`等validated reusable components。

## Validation evidence

Fresh commands：

```txt
cd apps/flutter_architecture
flutter analyze lib/features/catalog/presentation
→ No issues found

flutter test \
  test/features/catalog/presentation \
  test/features/auth/presentation/pages/otp_page_test.dart \
  test/features/shell/presentation/pages/shell_scaffold_test.dart \
  test/architecture/presentation_responsibility_contract_test.dart
→ 73 tests PASS
```

Completion commit range machine plan：

```txt
python tools/ci/validation_planner.py \
  --event push \
  --base 3e7ca9e606c2d3aba0fdc49fd82e40fa668faf57 \
  --head ef8909b25cfca05d8871a6ccde38f0ca70a6f600 \
  --stdout-json

validation_level = affected
fail_safe = false
docs_check = true
analyze_scopes = apps/flutter_architecture
flutter_test_scopes = apps/flutter_architecture/test/features/catalog
android_build = false
ios_build = false
full_regression = false
```

Planner-selected fresh validation：

```txt
dart run melos run docs_check
→ PASS

cd apps/flutter_architecture
flutter analyze
→ No issues found

flutter test test/features/catalog
→ 122 tests PASS
```

## Whole-Task review

Task 43-5同時證明「需要拆時能拆」與「不需要拆時保持原owner」；沒有把ADR-032退化成folder/file/state-tool形式規則。

```txt
Task 43-5: accepted
Open P0: 0
Open P1 without disposition: 0
```

