---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-7-observability-failure-evidence-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 7 Observability and Failure Evidence Review

## Task Scope

本Task收斂Observability acceptance與failure evidence的安全邊界：

```txt
emit_controlled_event預設false
symbol upload／dSYM驗證不依賴controlled event
manifest／summary／diagnostics內容掃描
remote failure evidence內容掃描
local diagnostics上限25 MiB
blocked evidence不得publish
```

主要變更：

```txt
.github/workflows/ci.yml
.github/workflows/ios.yml
.github/workflows/observability-acceptance.yml
tools/ci/write_observability_acceptance_evidence.py
tools/ci/secret_leakage.py
tools/ci/artifact_store.py
tools/ci/artifact_transport.py
```

本Task沒有建立正式operator artifact root、沒有修改`CI_EXECUTION_MODE`、沒有刪除GitHub artifacts／caches，也沒有執行secret-backed remote acceptance。

## TDD Evidence

### RED

- Observability workflow沒有`emit_controlled_event`input，staging build固定設為`true`。
- Symbol upload與dSYM acceptance缺少「event disabled仍可執行」契約。
- Evidence writer接受GitHub token、private key內容與換行欄位注入。
- `remote_event_status=verified`不要求authoritative marker。
- Local job finalize不掃描manifest／summary／diagnostics內容。
- Remote failure／full preflight只驗證路徑、類型與大小，不掃描內容。
- Diagnostic超過25 MiB仍可publish到managed store。
- Scanner阻止publish後會留下含敏感內容的staging與永久active lock。
- `emit_controlled_event=true`但provider secrets未就緒時，evidence可能誤標為`requested`。
- 新scanner tests未被repository CI／iOS／Observability quality gates執行。
- Observability explicit `full`仍會把staging app、symbols或dSYM送進GitHub artifact。

所有RED均由fresh Python tests或workflow contract先重現，再進入implementation。

### GREEN

新增manual boolean input：

```txt
emit_controlled_event
default: false
type: boolean
```

只有以下條件同時成立時，staging build才投影event flag：

```txt
remote_acceptance=true
provider secrets ready
emit_controlled_event=true
```

即使event為false，以下流程仍可執行：

```txt
Android production／staging symbol build
Android Flutter symbol upload
iOS production／staging dSYM build
iOS dSYM upload
managed local artifact／evidence storage
```

Evidence status語意：

```txt
not-executed: 未請求或prerequisite未就緒
requested: build明確啟用controlled event，但尚無remote verification marker
verified: 必須提供包含remote_event_verified=true的authoritative marker
failed: 明確remote acceptance失敗
```

## Secret Leakage Scanner

新增`tools/ci/secret_leakage.py`，對以下內容執行fail-closed掃描：

```txt
job metadata
job manifest
job summary
local diagnostics
GitHub failure-only／full preflight files
Observability evidence與remote marker
```

目前阻擋模式包含：

```txt
private key PEM header
private_key JSON field
gho_ GitHub token
Firebase CLIENT_ID／REVERSED_CLIENT_ID／GOOGLE_APP_ID plist keys
mobilesdk_app_id provider config marker
service-account client_email
provider config filenames
keystore／Apple key／provisioning suffixes
symlink evidence entries
```

錯誤只輸出pattern label與安全檔名，不輸出matched secret value。

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| Workflow固定啟用acceptance event | P1 | 新增`emit_controlled_event=false`，Android／iOS hosted與self-hosted staging build均投影明確boolean |
| Event input可能誤成symbol／dSYM job gate | P1 | Job-level條件只依`remote_acceptance`與provider readiness；event只影響runtime dart define |
| Provider secrets未就緒仍可能記錄requested | P1 | `EVENT_STATUS`同時要求`REMOTE_ACCEPTANCE_READY=true`與explicit opt-in |
| Evidence writer可接受secret與欄位換行注入 | P1 | Closed status enums、SHA validation、bounded single-line fields與content scan後才atomic write |
| `verified`可由CLI文字直接宣稱 | P1 | `verified`必須提供authoritative marker，且marker本身通過scanner |
| Manifest／summary／diagnostics未掃描 | P1 | Metadata在begin side effects前掃描；finalize在atomic publish前掃描summary／manifest content與diagnostic tree |
| Diagnostic evidence可無界增長 | P1 | Local diagnostic tree與failure-only remote set固定25 MiB上限 |
| Scanner failure留下敏感staging與永久lock | P1 | 掃描失敗先刪除blocked staging，成功後才解除lock；刪除失敗保留lock並fail closed |
| Remote full仍可帶出Observability raw app／symbols／dSYM | P1 | Observability GitHub artifact縮限為redacted evidence；raw app／symbols／dSYM只留managed local store或直接上傳Firebase provider |
| Scanner只由本機discover執行 | P1 | CI quality、iOS contract與Observability PR-safe contract均明確加入scanner與platform observability tests |

修正後：

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Fresh Focused Re-review

- `emit_controlled_event`預設false且不是job-level execution gate。
- Symbol upload／dSYM upload在event=false時仍保持原執行路徑。
- `requested`不等於`verified`，沒有marker不得宣稱remote success。
- Evidence writer在validation及scan完成前不建立正式輸出。
- Secret-bearing metadata在store root建立前即被拒絕。
- Secret-bearing或oversized diagnostics不會進入published run tree。
- Blocked staging刪除成功後lock會解除，不造成永久false-active狀態。
- 若blocked staging刪除失敗，lock保留並以generic error fail closed。
- Scanner錯誤不包含完整secret。
- Failure-only仍只接受bounded text／JSON／Markdown／selected golden PNG。
- Full transport仍拒絕provider config、service account與signing material。
- Observability GitHub `full`只保存redacted evidence，不保存raw symbols、mapping、dSYM或staging app。
- Self-hosted Observability raw outputs仍保存於external managed store。

## Whole-Task Review

完整資料流重新核對：

```txt
workflow_dispatch
→ remote_acceptance gate
→ provider readiness gate
→ emit_controlled_event explicit boolean
→ production／staging symbol or dSYM build
→ optional Firebase provider upload
→ event status = not-executed or requested
→ redacted evidence writer
→ managed local begin／finalize
→ metadata／manifest／summary／diagnostic scan
→ atomic publish

or explicit GitHub remote evidence exception
→ artifact_transport preflight
→ filename／type／size／content scan
→ redacted evidence-only upload
```

Task 7完成安全與bounded evidence contract，但正式Mac self-hosted／iOS／Observability runtime acceptance仍屬Tasks 8–9。

## Validation

```txt
python -m unittest focused Task 7 matrix
Result: 52 passed

python -m unittest discover -s tools/ci -p "test_*.py"
Result: 183 passed

python -m py_compile secret／evidence／artifact tooling
Result: passed

Git Bash -n cleanup_ci_secrets.sh run_local_ci.sh
Result: passed

actionlint v1.7.12 -shellcheck=
Result: passed

PyYAML workflow parse
git diff --check
Result: passed
```

## Gate

```txt
Task 7 focused review: Passed
Task 7 whole-Task review: Passed
Controlled event default: false
Secret leakage gate: Active
Observability GitHub raw artifact transport: Forbidden
Official operator artifact root: Not created
GitHub cleanup: Forbidden
Next Task: Task 8 Operations Guide, Static Regression and Runtime Readiness
```
