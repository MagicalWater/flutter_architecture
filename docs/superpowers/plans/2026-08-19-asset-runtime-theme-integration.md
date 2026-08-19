# Asset Runtime Ownership & Theme-aware Representation Integration — Implementation Plan

Status: **accepted / implementation complete**

Accepted: 2026-08-19 by explicit user approval after whole-Plan review.

Implementation completed: 2026-08-19. Release disposition remains separate.

## 1. Goal

Implement the accepted Asset Runtime Ownership & Theme-aware Representation Integration Design with the smallest sufficient production footprint:

- adopt FlutterGen as the generated asset accessor;
- add a stable read-only Theme Identity access path for presentation consumers;
- add one bounded App-owned theme-aware visual resolver proving `Default/Ocean × Light/Dark` selection;
- preserve existing ADR-028 representation/provenance authority;
- amend ADR-018 and current package/app documentation so future product repositories inherit the same ownership rules.

Accepted Design:

`docs/superpowers/specs/2026-08-19-asset-runtime-theme-integration-design.md`

## 2. Scope boundaries

In scope:

- `flutter_gen_runner` adoption and package-local generation configuration.
- Minimal reference image assets used only to exercise generated access and theme-aware selection.
- App-level theme identity exposure suitable for presentation consumers.
- A bounded App-owned theme visual resolver using generated accessors.
- One bounded runtime consumer proving the resolver path.
- ADR-018/current docs/README synchronization.
- Focused generation, compile, analyze and resolver behavior evidence.

Out of scope:

- Redesigning `DsThemeDefinition` or Theme persistence.
- Moving product/feature artwork into `packages/design_system` merely because it is theme-aware.
- Creating a global `AppAssets`, universal visual registry, asset service locator or remote theme framework.
- Reworking existing Write Precheck colors/assets or Pencil visual authority.
- Replacing the existing representation/provenance mapping contract.
- Adding broad permanent test matrices.

## 3. Implementation order

### Task A — FlutterGen dependency and generation contract

Files likely affected:

- `apps/flutter_architecture/pubspec.yaml`
- root/workspace dependency state as required by pub resolution
- generated FlutterGen output under the app package

Steps:

1. Add `flutter_gen_runner` as an app dev dependency using the currently verified stable 5.15.x line and let dependency resolution pin the exact lockfile version.
2. Configure FlutterGen in the app `pubspec.yaml` only as needed for the reference assets; do not add unrelated integration packages.
3. Add the reference assets to the app asset declaration.
4. Run the upstream-supported generation flow from the workspace/app context.
5. Verify generated accessor output and that generated files are not hand-authored.

Acceptance:

- generation succeeds;
- generated accessors compile;
- no hand-written duplicated raw paths are introduced in production consumer code.

### Task B — Minimal neutral reference assets

Add four deterministic, repository-owned reference image assets:

```txt
Default Light
Default Dark
Ocean Light
Ocean Dark
```

Constraints:

- intentionally simple neutral fixtures, not new product art direction;
- no image-generation workflow required;
- each file exists only to prove representation selection and bundle access;
- filenames/directories should make App ownership and theme variant purpose obvious;
- no provenance metadata duplicated into runtime constants.

Preferred implementation: create small deterministic PNG fixtures through repository-local tooling/script or another deterministic source-generation mechanism, so bytes are reviewable and reproducible.

### Task C — Stable Theme Identity presentation access

Inspect current `ThemeControllerScope` / App composition pattern first. Implement the smallest read-only presentation access that allows consumers to obtain current `DsThemeId` without depending on preference persistence.

Constraints:

- no new global singleton;
- no feature dependency on `ThemePreferenceStore`;
- no deep coupling to mutable persistence implementation;
- reuse current scope/controller architecture where sufficient.

Possible minimal shape if current scope cannot expose this cleanly:

```dart
DsThemeId currentThemeIdOf(BuildContext context)
```

or a narrowly-scoped inherited read contract. The exact source shape is chosen after current source inspection, not predetermined by this Plan.

### Task D — App-owned bounded theme visual resolver

Create a small App-owned contract only for the reference consumer, conceptually:

```dart
abstract interface class AppThemeVisuals {
  AssetGenImage get referenceVisual;
}

AppThemeVisuals resolveAppThemeVisuals({
  required DsThemeId themeId,
  required Brightness brightness,
})
```

Requirements:

- resolve all four Default/Ocean × Light/Dark combinations;
- consume FlutterGen generated asset types/paths only;
- unknown/removed theme ID behavior follows existing registry/default-theme semantics rather than inventing a second fallback policy;
- no provenance fields in the resolver;
- no generic registry for feature assets.

### Task E — Bounded runtime reference consumer

Integrate the resolver into one existing App-owned presentation surface or a narrowly bounded template reference surface without disturbing product flows.

Requirements:

- consumer derives `Brightness` from `Theme.of(context)`;
- consumer gets Theme Identity through the stable presentation access from Task C;
- consumer renders the selected generated asset;
- no raw path literal and no raw-color-based selection;
- do not refactor unrelated screens.

If no existing surface can host the reference without contaminating product UX, use the smallest internal/reference presentation location already present in the template rather than creating a general-purpose asset gallery framework.

### Task F — Stable authority synchronization

Update:

- `docs/adr/adr-018-design-system-theme-boundaries.md`
- `packages/design_system/README.md` only where the non-ownership boundary needs clarification
- App/current project documentation where runtime asset ownership and FlutterGen generation procedure belongs
- relevant human guide only if required to avoid an authority gap

ADR-018 must capture:

```txt
ownership axis != selection axis != provenance axis
```

and:

- FlutterGen is generated-access mechanism, not semantic authority;
- Theme Identity/Brightness may select a representation without changing its App/Feature/Component owner;
- existing generated accessor should be consumed instead of duplicated raw bundle paths;
- theme-aware visual ownership does not automatically belong to Design System.

ADR-028 remains unchanged unless implementation review finds an actual wording conflict; a cross-reference-only edit is allowed if necessary.

## 4. Test Authoring Decision

Default disposition: **temporary/focused evidence first; no broad permanent suite**.

Candidate evidence:

1. generation success;
2. compile/analyze success;
3. one focused resolver mapping check covering four combinations;
4. optional bounded widget/runtime evidence if source integration cannot otherwise prove selection.

Retention rule:

- keep a permanent resolver test only if review determines the four-way mapping is a stable invariant whose regression would not be caught by compile/analyze or a simple runtime smoke;
- otherwise delete temporary tests before closure and record Retention Decision.

## 5. Review questions

Whole implementation review must answer:

1. Did FlutterGen remain only a generated-access mechanism?
2. Did any new code create a mega `AppAssets`/registry?
3. Can a feature access Theme Identity without persistence coupling?
4. Does the resolver use `DsThemeId + Brightness`, not raw colors?
5. Did App/Feature/Component ownership remain independent of theme selection?
6. Was provenance kept in the existing mapping authority only?
7. Were generated files left generated and unmodified by hand?
8. Did the reference consumer avoid unrelated product/UI refactors?

## 6. Validation

During implementation:

- FlutterGen generation command;
- `dart format` / generated formatting as owned by upstream tool;
- relevant `flutter analyze` / package analyze;
- focused resolver evidence;
- `dart run tools/docs/run_check.dart` when documentation changes land;
- `git diff --check`.

Before completion:

Run repository machine authority:

```txt
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

Execute exactly planner-selected validation; do not auto-upgrade to full regression solely because this is architecture work.

## 7. Completion and release disposition

This is repository-wide stable architecture adoption, so after implementation and holistic review:

- synchronize current authority docs;
- explicitly decide whether Template Baseline should increment;
- if release/promotion is chosen, merge/push and perform required post-release identity/artifact verification;
- if no release is chosen, leave the branch/worktree clean and document the disposition.

Implementation may not begin until this Plan passes review and receives explicit user approval.

