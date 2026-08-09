---
document_type: final-review
status: accepted
authoritative_for:
  - validation-planner-skill-governance-classification-holistic-final-review
last_reviewed_baseline: 1.16.0
---

# SG-4 — Skill Governance Classification Holistic Final Review

## Scope and authority

This review closes the implementation Tasks defined by the accepted Requirement Decision, Corrective Design, and Implementation Plan.

Implementation branch:

```text
corrective/skill-governance-validation-classification
planning base: 5aef843aacd8c92a40d378b2775154d7a22df022
SG-1: 8af90cb test(ci): 鎖定 Skill 治理路徑分類契約
SG-2: e4f2479 fix(ci): 補齊 Skill 治理路徑分類
SG-3: 2b166f1 docs(audit): 驗證 Skill 完整性與 consumer contract
```

## Cross-Task implementation review

Only `tools/ci/change_classifier.py` production routing changed. Existing `governance` classification now recognizes:

```text
.agents/skills/**
skills-lock.json
third_party/skills/**
```

No change was made to `validation_planner.py`, `validation_runner.py`, `tools/docs/**`, Flutter production source/tests, or Android/iOS native source. No new change class, semantic parser, duplicate path matrix, broad `.agents/**`, or generic `third_party/**` rule was introduced.

## Design acceptance matrix

| Accepted criterion | Evidence | Result |
|---|---|---|
| `.agents/skills/**` is known governance | SG-1 RED + SG-2 56-test GREEN | PASS |
| `skills-lock.json` is known governance | SG-1 RED + SG-2 direct probe | PASS |
| `third_party/skills/**` is known governance | SG-1 RED + SG-2 direct probe | PASS |
| governance route executes `tools/docs` contracts | SG-3 runner command evidence | PASS |
| locked Skill / license drift remains fail closed | SG-3 36-test + 13 verbose Skill-lock cases | PASS |
| ordinary Skill change does not select Flutter/generated/platform | SG-2 planner probe | PASS |
| unknown path remains full fail-safe | `.agent-runtime/new-policy.bin` negative control | PASS |
| invalid range / validation-engine semantics unchanged | classifier/planner regression + holistic range plan | PASS |
| planner does not replace semantic pressure review | Design/Plan authority boundary unchanged | PASS |

## Planner-selected holistic range

Fresh planner execution over `5aef843...2b166f1` produced:

```text
change_classes = [docs_content, validation_engine]
validation_level = full
flutter_test_scopes = [.]
python_test_scopes = [tools]
analyze_scopes = [.]
docs_check = true
generated_check = true
android_build = true
ios_build = true
full_regression = true
release_full = false
fail_safe = false
```

This full escalation is expected because the corrective changes the classifier itself. It is not the future route for an ordinary Skill-only change.

## Fresh Windows verification

```text
tools/ci discovery: 246 tests PASS
tools/docs discovery: 52 tests PASS
targeted classifier/planner/runner/Skill-lock/docs set: 99 tests PASS
Documentation check: PASS
Analyze: PASS across all five workspaces
```

Fresh full Flutter regression:

```text
flutter_architecture: 493 tests PASS
auth: 156 tests PASS
api_client: 59 tests PASS
design_system: 43 tests PASS
core: 4 tests PASS
```

### Generated consistency

The first bare `bash` invocation resolved to Windows WSL and failed before the repository script could execute correctly because Windows managed-worktree gitdir and CRLF Flutter shell paths are not WSL-compatible. Re-running with installed Git Bash completed successfully:

```text
Generated files are consistent with source.
```

Build-runner created only working-tree EOL effects; tracked content was restored after the consistency result. No generated source was committed.

### Android managed platform gate

The direct build script correctly rejected missing `ARTIFACT_DIR`. The repository-owned managed entrypoint was then used:

```text
Git Bash tools/ci/run_local_ci.sh android
```

Result:

```text
run_key = local-20260809t214003z-1142-26e868d3
development debug APK: PASS
package_id = com.example.flutterarchitecture.development
production release APK: PASS
package_id = com.example.flutterarchitecture
Flutter-reported production APK size = 56.8 MB
flutter_symbols = 3
mapping_file = present
artifact transport = local-only managed store
```

## macOS / iOS platform evidence

The Windows implementation branch was intentionally not pushed merely to obtain platform validation. macOS remained on clean published `6ef1b7d6370097920c4281933558684639f970ac`.

Before accepting cross-host evidence, Git object identity was compared between Windows implementation `2b166f1` and macOS published `6ef1b7d` for all selected iOS build inputs:

```text
apps
packages
pubspec.yaml
pubspec.lock
melos.yaml
.github/versions.env
tools/ci/build_ios_environment.sh
tools/ci/build_ios_production.sh
tools/ci/build_ios_development.sh
```

All nine tree/blob object IDs matched exactly. Therefore this classifier/docs/test-only corrective does not alter the iOS application/build inputs exercised by the platform gate.

On the clean macOS checkout:

```text
bash tools/ci/run_local_ci.sh ios
```

completed successfully:

```text
development Simulator verification build: PASS
production Release-production / iphoneos unsigned verification build: PASS
bundle_id = com.example.flutterarchitecture
dSYM = present
managed local run_key = local-20260809t214407z-26109-536fbdb8
```

This evidence is accepted only as build-input-equivalent platform evidence; it does not claim that commit `2b166f1` exists on the Mac checkout.

## Authority review

Reviewed without modification:

- ADR-023 already states classifier-owned canonical classes, planner-owned selection, and unknown/invalid/engine fail-safe behavior.
- `docs/governance/development_workflow.md` already separates Skill registry semantics from machine validation and Skill-lock provenance.
- `docs/guides/testing_governance.md` already states planner-owned Minimum Sufficient Validation and fail-safe escalation.

Adding the exact three path families to those human documents would duplicate the executable path matrix, so no authority text change is required.

## Release disposition

```text
VERSION change: NO
CHANGELOG release entry: NO
new Template Baseline: NO
release_full: false
```

This corrective makes implementation match already accepted validation-governance semantics and does not add a user-facing template capability or runtime product behavior. Baseline remains `1.16.0` unless a later integration decision explicitly chooses publication metadata.

## Findings

```text
P0 = 0
P1 without disposition = 0
```

Environment observations that are not corrective findings:

1. Windows bare `bash` resolves to WSL; repository shell verification must use Git Bash in this managed-worktree environment.
2. Direct Android build scripts require `ARTIFACT_DIR`; the managed local CI entrypoint correctly owns this contract.

Neither observation requires source modification in this corrective.

## Final disposition

**PASS — SG-1 through SG-4 implementation and holistic review are complete on the corrective branch.**

Integration, push, and managed-worktree cleanup are separate branch-finishing actions.
