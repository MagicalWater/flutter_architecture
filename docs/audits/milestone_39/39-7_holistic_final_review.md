---
document_type: final-review
status: active
authoritative_for:
  - milestone-39-task-39-7-holistic-release-gate
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Task 39-7 Holistic Final Review / Release Gate

## Current disposition

```txt
Milestone implementation Tasks 39-1～39-6: accepted
Cross-Task Windows release validation: PASS
macOS / iOS release validation: BLOCKED — bridge connector account HTTP 400
Template Baseline release: NOT STARTED
VERSION: 1.19.0
Milestone 39: open / blocked at external iOS gate
```

本文件不把Windows-only成功改寫成Milestone completion。Release planner明確要求Android與iOS；在fresh macOS iOS development／production verification完成前，不得升級`VERSION`、fast-forward main、push release或宣稱Milestone 39 closure。

## Cross-Task consistency review

Tasks 39-1～39-6對accepted Requirement／Design／Plan形成一致chain：

```txt
39-1 missing machine contract RED
→ 39-2 initiative-local critical mapping validator
→ 39-3 runtime geometry + critical local fidelity gate
→ 39-4 wrong-representation invalidation / recovery Skill route
→ 39-5 fresh ChatGPT behavioral pressure acceptance
→ 39-6 ADR-028 / Guide / existing proof mapping authority sync
```

Review確認：

- 唯一Pencil-to-Flutter domain Skill仍為`implementing-pencil-flutter-design`；沒有新增第二Skill。
- 沒有global asset registry或all-node design database。
- 沒有all-icons-raster規則。
- 沒有every-node geometry test、every-icon golden或every-section visual-test quota。
- `exact`／`verified-equivalent`／`intentional-deviation`／`unresolved`與machine validator一致。
- Whole-screen broad regression與critical local owner採AND semantics。
- Critical geometry使用runtime RenderBox／等價runtime evidence，而不是source literal。
- Wrong source／asset／icon／representation一旦被review判定，affected mapping invalid並禁止candidate-specific pixel tuning。
- ADR-028、human Guide、Skill references、machine tooling與existing proof mapping ownership沒有第二authority。

```txt
Open implementation P0: 0
Open implementation P1 without disposition: 0
```

## Release planner

Command：

```powershell
python tools/ci/validation_planner.py --event workflow_dispatch --base afd3f6e3f1c75af04e18dafc80c552720c83e0b9 --head HEAD --stdout-json
```

Result：`validation_level=release`、`release_full=true`、`full_regression=true`，並要求docs、Python `tools`、workspace analyze、generated consistency、full Flutter tests、Android build與iOS build。

## Windows release evidence

### Documentation / Python / analyze

- `python -m unittest discover -s tools -p "test_*.py"`：11 PASS。
- `dart run melos run docs_check`：PASS。
- `dart run melos run analyze`：5 packages SUCCESS，no issues。
- `git diff --check`：PASS。

Milestone-specific focused contracts在39-2～39-6另有fresh evidence；39-6 aggregate mapping／fidelity／representation／single-renderer suite為27 PASS。

### Generated consistency

WSL route先暴露managed-worktree Windows `.git` path與Windows Flutter CRLF wrapper transport incompatibility；沒有把transport error判成generated drift。改由Git for Windows bash執行同一repository-owned verifier：

```txt
C:\Program Files\Git\bin\bash.exe tools/ci/verify_generated.sh
```

Result：build_runner、Drift schema exports、drift worker compile與schema governance全部完成，最終：

```txt
Generated files are consistent with source.
```

Git for Windows autocrlf留下status-only generated line-ending noise；內容diff為空，驗證後已`git restore --worktree .`清除副作用，worktree回到clean。

### Full Flutter regression

Command：

```txt
dart run melos exec -- flutter test
```

Result：SUCCESS across all 5 workspaces。

- `design_system`：43 PASS。
- `core`：4 PASS。
- `api_client`：59 PASS。
- `auth`：156 PASS。
- `flutter_architecture`：494 PASS。

Pencil compatibility canonical/runtime visual regressions亦在full suite中PASS；runtime renderer calibration仍為既有accepted範圍。

### Android development verification

Git for Windows環境的`python3` alias不可用，repository Android script不會像generated verifier自動fallback；顯式設定`PYTHON_BIN=python`後執行同一repository-owned build contract。

Result：PASS。

```txt
build_mode=debug
environment=development
package_id=com.example.flutterarchitecture.development
artifact=flutter-architecture-development-debug.apk
distribution=not production-ready
```

### Android production verification

使用verification-only API endpoint：`https://api.acme.test`。

Result：PASS。

```txt
build_mode=release
environment=production
package_id=com.example.flutterarchitecture
artifact=flutter-architecture-production-release.apk
flutter_symbols=3
mapping_file=present
signing=debug signing for verification only
distribution=not production-ready
```

## macOS / iOS blocker

Release planner要求iOS build。Fresh嘗試：

1. `bridge-mac` open `/Users/water/Developer/projects/flutter_architecture` → connector account HTTP 400：`We couldn't connect your account. Please try again.`
2. Primary失敗後依bridge failover規則嘗試`bridge-mac-backup` → 相同HTTP 400。

因此尚未接觸macOS repository，也沒有執行或偽造：

```txt
bash tools/ci/build_ios_development.sh
bash tools/ci/build_ios_production.sh
```

Disposition：**external/manual blocker**。Mac bridge恢復後，必須fresh fetch exact Milestone release candidate，完成development＋production iOS verification，再回本Task fresh re-review。

## Release-precondition documentation corrective

Holistic documentation review另發現一個release前P1 authority-consistency finding：ADR-028、development workflow registry、人類Pencil-to-Flutter Guide與domain Skill admission reference仍描述舊的共享`pencil-local-mcp` route，但current governed multi-conversation Pencil-to-Flutter workflow已採`pencil-session-mcp` isolated session。若不修正，fresh Agent可能依repository current authority走到共享active-editor state，與目前隔離session操作契約衝突。

Disposition：**於Task 39-7內直接corrective，不另開Milestone**。Stable ownership不變：`implementing-pencil-flutter-design`仍是唯一Pencil-to-Flutter domain Skill；本corrective只同步Pencil MCP runtime/admission boundary，要求fresh isolated session、exact `sessionId` ownership與`session_get_app_state` active-target verification，並明確禁止在isolated admission失敗時隱式fallback到visible Pencil Desktop／`pencil-local-mcp`。這不建立第二Skill、不改`.pen` authority、不修改Flutter production UI，也不放寬fail-closed behavior。

Focused re-review新增machine regression owner，鎖定`pencil-session-mcp`、`session_create`、`session_get_app_state`、exact `sessionId` ownership與禁止shared Desktop fallback。Fresh validation：

```txt
python -m unittest tools.docs.test_pencil_representation_mapping_policy tools.docs.test_pencil_single_renderer_policy
→ 16 PASS

dart run melos run docs_check
→ PASS

git diff --check
→ PASS

Current forward-route scan
→ no stale positive pencil-local-mcp admission route
```

Re-review disposition：P1 **RESOLVED**。後續再次收斂authority：repository-governed Pencil workflow唯一允許`pencil-session-mcp` isolated session；`pencil-local-mcp`只保留在禁止性文字中，用來明確表達不得作為admission、fallback或single-client替代route。

Focused pressure contract另新增`PTF-26 Single-client local MCP shortcut`，明確拒絕「目前只有一個client所以可改用`pencil-local-mcp`」的合理化。Current authority scan沒有任何正向`pencil-local-mcp` admission；Milestone 33 Design／Plan／Audit中的舊route只保留為historical evidence，不得覆蓋ADR-028、current governance registry、human Guide與domain Skill admission reference。

## Remote drift check

Fresh `git fetch origin`：

```txt
Milestone HEAD: 2fa1458823b66f681e33f0eb570547f3744e3ff9
origin/main:    afd3f6e3f1c75af04e18dafc80c552720c83e0b9
```

Remote main自Milestone base後尚無漂移；目前沒有integration conflict evidence。但release尚未獲得iOS gate，因此不得fast-forward/push。

## Required resume route

```txt
restore bridge-mac or bridge-mac-backup
→ fresh fetch exact release candidate
→ iOS development verification PASS
→ iOS production verification PASS
→ fresh Task 39-7 holistic re-review
→ VERSION / CHANGELOG / project_context / roadmap release sync
→ release commit
→ main fast-forward / push
→ published-main clean checkout validation
→ published-main fresh ChatGPT Skill / representative PTF acceptance
→ 39-8 post-release closure
```

在上述route完成前：

```txt
Open P0: 0
Open P1 without disposition: 0
External blocker: macOS / iOS release gate
Task 39-7 status: blocked
Milestone 39 status: open
```
