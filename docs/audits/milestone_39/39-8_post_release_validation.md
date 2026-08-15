---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-39-task-39-7-post-release-validation
last_reviewed_baseline: 1.20.0
---

# Milestone 39 — Post-release Validation

## Published-main admission

Published main was fresh-checked in an isolated worktree at:

```txt
HEAD = origin/main = b3ac4cc77eb3c497c6b1b155758f6bd2d8901780
VERSION = 1.20.0
repository_identity.template_origin.baseline = 1.20.0
```

The published range planner selected release-level full validation, including
Python tools, docs, analyze, generated consistency, full Flutter regression,
Android development/production and iOS development/production.

## Published-main evidence before corrective

Fresh published-main validation already passed:

- Python `tools` discovery: 11 PASS.
- `docs_check`: PASS.
- workspace analyze: all 5 workspaces PASS.
- generated consistency: PASS.
- full Flutter regression: all 5 workspaces PASS; app 494 PASS.
- Pencil mapping/fidelity/policy focused contracts: 30 PASS.
- Android Development verification: PASS at exact published SHA.

## Post-release finding — Android production rerun idempotency

The Android Production verification exposed a deterministic rerun defect.
The first release build can produce Flutter obfuscation symbols, but
`build_android_environment.sh` deletes the stable `ARTIFACT_DIR/flutter-symbols`
directory before every invocation. If Gradle/Flutter then regards the same
release build as up-to-date, the APK build succeeds without re-running AOT,
leaving the newly emptied symbols directory without `.symbols` files. The
verifier correctly fails closed with:

```txt
Expected Flutter symbols were not generated: .../flutter-symbols
```

This is not accepted as a transient failure and does not get bypassed by using
an older artifact.

## Requirement Decision — published-main Android verification rerun corrective

- Request（需求）：修正同一 published commit 重跑 Android Production verification 時可能遺失 Flutter symbols 的 deterministic defect。
- Problem（問題）：stable split-debug-info output directory先被清空，而cached Gradle/Flutter release build可能不重新執行AOT，造成APK成功但symbols gate失敗。
- Current behavior（目前行為）：同SHA首次production verification可成功；緊接著使用相同artifact directory重跑可能因missing symbols失敗。
- Expected behavior（預期行為）：同SHA、同environment、同artifact contract可安全重跑；每次release invocation都取得與該次build一致的新`.symbols`，並在成功後投影回既有`flutter-symbols` artifact path。
- Value（價值）：恢復release/post-release verification的可重跑性，避免cache狀態決定gate結果。
- Classification（分類）：Level 1 — Small Fix。
- Decision（決策）：Accept。
- Scope（範圍）：`tools/ci/build_android_environment.sh`、existing CI tooling regression owner與本post-release evidence。
- Non-goals（非目標）：不改signing、distribution、artifact schema、Android applicationId、Flutter runtime behavior、iOS build contract或release architecture。
- Behavioral requirements required（是否需要行為需求）：以本Requirement Decision的expected behavior作有界行為契約，不另建Design Spec。
- Design Spec required（是否需要 Design Spec）：否；deterministic bounded bug，已有現行artifact/release contract。
- Implementation Plan required（是否需要 Implementation Plan）：否；使用simplified Task cycle。
- ADR required（是否需要 ADR）：否；不改stable architecture boundary。
- Task governance mode（Task 治理模式）：Simplified two-layer Task governance。
- Worktree／branch：`milestone-39-postrelease-closure`，base為published `b3ac4cc`。
- Regression level（Regression 等級）：focused CI tooling regression + planner-selected validation + fresh Android production repeated-run evidence。
- Release required（是否需要發布）：是；published main已有defect，修正後需更新main並重新做post-release closure。
- Post-release validation（發布後驗證）：是；corrective publication後重新fresh published-main verification。
- Required Superpowers skills（必要 Superpowers Skills）：central `governing-template-development`; systematic debugging/TDD semantics由repository current workflow承接。
- Required artifacts（必要 artifacts）：本post-release evidence、direct regression owner、corrective commit與fresh re-review evidence。

Higher-level classification was considered because the failure is release-critical.
It remains Level 1 because the fix restores an already-documented rerun/artifact
invariant without changing the release process, artifact schema, platform claim,
signing or production distribution boundary.

## Test Authoring Decision

Disposition: **Required**.

Reason: this is a deterministic retry/idempotency bug with a reliable direct
regression owner. `tools/ci/test_local_build_commands.py` owns the shell-script
contract nearest the failure source. The RED contract requires release symbols
to be generated in an invocation-specific staging path and only promoted to the
stable `flutter-symbols` artifact path after successful generation.

Task remains open until RED is demonstrated, implementation is reviewed, the
focused test is green, repeated Android Production verification passes, and the
planner-selected validation is complete.

## RED evidence

Focused command:

```txt
python -m unittest tools.ci.test_local_build_commands
```

Result before implementation:

```txt
Ran 17 tests
FAILED (failures=1)
```

The sole failure was the new rerun-idempotency contract because the published
script still wrote `--split-debug-info` directly to the stable
`flutter-symbols` path and had no invocation-specific staging/promotion step.
This is genuine RED against published `b3ac4cc` behavior; the failure is not
backfilled as a historical PASS.

## Corrective implementation

The Android environment verifier now uses:

```txt
ARTIFACT_DIR/.flutter-symbols-build-$$
```

as the release invocation's temporary split-debug-info destination. The path is
different for each shell process, so the Flutter/Gradle release task observes a
new split-debug-info input instead of silently reusing a cached AOT task after
the stable symbol directory was emptied.

The verifier then:

1. requires at least one `.symbols` file in the invocation-specific staging dir;
2. fails closed if the files are absent;
3. promotes the verified staging directory to the existing stable
   `ARTIFACT_DIR/flutter-symbols` contract only after generation succeeds;
4. removes abandoned invocation staging via an EXIT trap bounded to the
   `.flutter-symbols-build-*` child path.

No artifact filename/schema, signing, applicationId, API mode, runtime code or
iOS contract changes.

## Focused implementation review / fresh re-review

Review findings:

- staging path is a child of the caller-provided artifact directory and is
  invocation-specific via `$$`;
- failed generation cannot pass by seeing stale files in the stable directory,
  because the stable directory is removed before the build and validation reads
  the staging directory;
- promotion happens only after `.symbols` validation;
- the EXIT cleanup is bounded to the exact `.flutter-symbols-build-*` prefix;
- the public artifact projection remains `flutter-symbols`;
- no broad `flutter clean` or workspace build-cache deletion was introduced.

Fresh focused validation after implementation:

```txt
python -m unittest tools.ci.test_local_build_commands
→ 17 PASS

bash -n tools/ci/build_android_environment.sh
→ PASS

git diff --check
→ PASS
```

A no-source-mutation probe on the cached published release also confirmed that
changing only the split-debug-info destination caused Flutter/Gradle to rerun
the release AOT path and generated exactly three symbol files:

```txt
app.android-arm.symbols
app.android-arm64.symbols
app.android-x64.symbols
```

The formal repeated-run acceptance is still pending an exact corrective commit
SHA and therefore this Task remains open.
