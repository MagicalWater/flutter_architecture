---
document_type: design-spec
status: proposed
authoritative_for:
  - milestone-32-ci-artifact-local-storage-cutover-design
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — CI產物本機化與GitHub儲存空間切換 Design

## Requirement Decision

- Request：將一般CI、Android／iOS verification、Observability與failure evidence的主要artifact ownership從GitHub Actions storage切換至本機／trusted self-hosted環境，同時保留GitHub workflow控制面與偶發`github-hosted`驗證能力。
- Problem：`self-hosted`只避免GitHub-hosted runner分鐘，沒有阻止`actions/upload-artifact`占用GitHub Actions storage；目前本機輸出也沒有run-level metadata、retention、容量與cleanup contract。
- Current behavior：Repository variable為`self-hosted`；Mac runner online；GitHub保有110筆artifacts、7,835,943,504 bytes，以及15筆caches、10,211,585,781 bytes。最近docs-only runs沒有新增artifact，但下次平台build仍會依現有workflow上傳。
- Expected behavior：GitHub保留dispatch、status與summary；Windows／Mac執行repository-owned驗證；大型成功、失敗與Observability evidence由本機managed store擁有；GitHub storage只在明確人工例外時使用。
- Value：解除Actions分鐘與storage quota阻塞，保留SHA traceability、supported-platform evidence、failure diagnosis與可審查cleanup。
- Classification：Level 4 — Architecture／Milestone。
- Decision：Accept。
- Behavioral requirements required：Yes。
- Design Spec required：Yes。
- Implementation Plan required：Yes，且只能在本Design取得使用者核准後建立。
- ADR required：Yes；核准後更新既有ADR-023，不建立平行Decision。
- Task governance mode：Full two-layer governance。
- Worktree／branch：`milestone-32-ci-artifact-storage-cutover`專用managed worktree。
- Regression level：Full repository、platform與runtime acceptance。
- Release required：Yes；預期Template Baseline為1.14.0，最終版本仍由release gate確認。
- Post-release validation：Yes。

## Goals

1. 將`manual-local`與`self-hosted`產生的verification artifacts、diagnostics與Observability evidence寫入同一套repository-owned本機artifact contract。
2. 保留GitHub Actions作為workflow control plane、manual dispatch、checks、logs與summary owner。
3. 停止self-hosted日常成功／失敗證據進入GitHub Actions artifact storage。
4. 為每個run建立commit identity、execution identity、checksums、retention class、容量與cleanup evidence。
5. Windows可執行quality、tests與Android；Mac可執行quality、tests、Android、iOS與Observability。
6. 在新路線完成runtime acceptance後，以核准的exact deletion manifest清理既有GitHub artifacts與caches。

## Non-goals

- 不移除GitHub Actions、`.github/workflows/`或`github-hosted`模式。
- 不導入R2、S3、NAS或其他遠端artifact服務。
- 不實作production signing、Play Store／App Store publishing、GitHub Release或environment promotion。
- 不將credential、keystore、Apple private key、Firebase service account或materialized provider config寫入repository或artifact metadata。
- 不把本機路徑描述成其他協作者可下載的遠端URL。
- 不將Windows宣稱為可執行iOS或Apple symbol pipeline的平台。
- 不把Branch Protection建議誤寫成已套用設定；目前GitHub方案對private repository回覆該功能需升級或公開repository。
- 不在新路線runtime acceptance與cleanup manifest核准前刪除任何GitHub artifact或cache。

## Approaches Considered

### A — Self-hosted control plane + managed local artifact store（採用）

維持`CI_EXECUTION_MODE=self-hosted`作日常預設。GitHub仍負責觸發、排程、check結論與summary；runner將產物寫到repository checkout外的managed store，self-hosted workflow完全禁止`upload-artifact`。

優點：保留自動main驗證與GitHub狀態，不消耗hosted分鐘，也不新增GitHub artifact storage。缺點：artifact只能在owner host存取，需要正式retention、disk safety與operator procedure。

### B — 全面改為manual-local（不採用）

Repository default改為`manual-local`，所有GitHub execution jobs skip，由人員自行跑本機腳本。

優點：最小化GitHub使用量。缺點：失去自動main push驗證、runner status與可追溯GitHub checks；容易再次形成「執行過但沒有統一evidence」的人工流程。保留為runner維護或緊急回退，不作長期預設。

### C — 立即導入R2／S3／NAS（Deferred）

把artifact上傳至另一個遠端store。

優點：可跨裝置下載與集中保存。缺點：增加credential、費用、availability、lifecycle與安全治理；目前單一owner與本機Mac／Windows已足以承擔需求。只有未來出現多協作者遠端下載、host容量不足或災難復原需求時，才建立新的Requirement Decision。

## Architecture Overview

```txt
GitHub Actions
  ├─ event policy / dispatch / checks / logs / job summary
  ├─ self-hosted → trusted Mac runner
  └─ github-hosted → explicit exceptional clean-run path

Repository-owned CI scripts
  ├─ quality / tests
  ├─ Android build
  ├─ iOS build
  ├─ Observability symbols / acceptance
  └─ artifact writer / manifest / retention / cleanup

Managed local artifact store
  ├─ runs/<full-sha>/<run-key>/jobs/<job-key>/
  ├─ locks/
  ├─ cleanup-manifests/
  ├─ trash/
  └─ pins/
```

Workflow只負責GitHub event、runner selection、secret materialization與summary。Build與artifact內容仍由repository-owned scripts產生；不得在YAML複製另一套artifact schema或cleanup邏輯。

## Execution Mode and Transport Policy

### `self-hosted`

- 維持repository長期預設。
- 只允許trusted `main` push與manual dispatch進入Mac runner；PR、fork與Dependabot仍不得執行。
- 所有成功、失敗、platform與Observability artifacts寫入本機managed store。
- 四份workflow對`actions/upload-artifact`採contract-level prohibition；GitHub只保存job logs與`$GITHUB_STEP_SUMMARY`。
- Self-hosted不得使用`actions/cache`。

### `manual-local`

- 使用與self-hosted相同的artifact writer、manifest與retention contract。
- 作為Windows／Mac直接驗證、runner離線與緊急回退入口。
- 不產生GitHub check；文件必須明確區分「本機已驗證」與「GitHub run成功」。

### `github-hosted`

- 保留作人工、偶發、乾淨第三方runner驗證。
- 所有GitHub remote cache預設停用；本Milestone不再以`actions/cache`保存Flutter、Pub或Gradle cache。
- 新增manual `artifact_transport`選項：`repository-default`、`none`、`failure-only`、`full`。
- Repository default為`none`：PR、push與manual `repository-default`都不建立GitHub artifact；failure details只存在於GitHub job log／summary。
- `failure-only`只允許`workflow_dispatch`明確選擇，保存有界的文字／log diagnostics，單job上限25 MiB、retention 7天；不得包含APK、`.app`、dSYM、Flutter symbols、mapping或provider config。
- `full`只允許`workflow_dispatch`明確選擇，retention固定1天，summary必須顯示storage warning；PR、push與`repository-default`不得隱式選擇`failure-only`或`full`。

## Host Capability Matrix

| Host／Mode | Quality／Tests | Android | iOS | Observability | Managed store |
|---|---:|---:|---:|---:|---:|
| Windows manual-local | Yes | Yes | No | Android-only bounded support | Yes |
| Mac manual-local | Yes | Yes | Yes | Yes | Yes |
| Mac self-hosted | Yes | Yes | Yes | Yes | Yes |
| GitHub-hosted Ubuntu | Yes | Yes | No | Android only | Remote policy only |
| GitHub-hosted macOS | Yes | Conditional | Yes | Yes | Remote policy only |

Host capability是execution claim，不改變目前Supported platform分類。Windows／macOS desktop App仍維持Dependency-ready。

## Artifact Root Resolution

正式變數：

```txt
CI_ARTIFACT_ROOT
```

- Self-hosted runtime必須提供明確的external root；缺值時fail closed，不得回退到runner `_work`、`RUNNER_TEMP`或repository checkout。
- 目前Mac runtime acceptance目標為`/Users/water/Developer/ci-artifacts/flutter_architecture`，但此值只屬operator configuration，不硬編碼於source。
- Manual-local未提供變數時，Windows使用`%LOCALAPPDATA%/flutter_architecture/ci-artifacts`；POSIX使用`${XDG_STATE_HOME:-$HOME/.local/state}/flutter_architecture/ci-artifacts`。
- Root不得位於Git worktree、repository root、runner `_work`、filesystem root或home root本身。
- Store root建立時權限為owner-only；POSIX目錄使用`0700`，敏感但非secret的symbols／dSYM使用`0600`等價權限。

## Run Identity and Directory Layout

```txt
<root>/
  runs/<full-sha>/<run-key>/
    run-manifest.json
    run-summary.md
    jobs/<job-key>/
      manifest.json
      summary.md
      checksums.sha256
      artifacts/<suite>/<platform>/<environment>/...
      diagnostics/<step>/...
  locks/
  cleanup-manifests/
  trash/<cleanup-id>/
  pins/
```

`run-key`：

- GitHub run：`gh-<GITHUB_RUN_ID>-<GITHUB_RUN_ATTEMPT>`。
- Manual-local：`local-<UTC timestamp>-<process id>-<random nonce>`。

`job-key`：

- GitHub job：由sanitized `GITHUB_WORKFLOW`與`GITHUB_JOB`組成。
- Manual-local：由suite與platform組成，例如`quality-windows`、`android-windows`、`ios-macos`。

每個job writer先寫入同一root下的`.in-progress/<run-key>/<job-key>`，完成checksums與job manifest後以atomic rename發佈至`runs/<sha>/<run-key>/jobs/<job-key>`。Summary job或manual orchestrator只聚合已finalize的job manifests，原子更新`run-manifest.json`與`run-summary.md`。Cleanup不得碰觸in-progress、持有active lock的run，或尚未完成aggregation的job。

## Manifest Contract

Job-level `manifest.json`採versioned schema，至少包含：

```txt
schema_version
repository
commit_sha / git_ref / dirty_state
run_key / run_id / run_attempt
job_key / workflow / job
execution_mode / host_os / host_arch / runner_name
suite / classifier_reason
started_at / completed_at / result
artifact entries:
  relative_path
  kind
  platform / environment / build_mode
  size_bytes
  sha256
  retention_class
  sensitivity
  signing / distribution classification
validation entries:
  command label
  result
  started_at / completed_at
cleanup disposition
```

Run-level `run-manifest.json`只聚合job manifest相對路徑、SHA-256、result、artifact totals與aggregation timestamp，不重新序列化environment或複製全部artifact entries。多job run不得由最後完成的job覆蓋前一個job evidence。

Manifest採allowlist writer，不序列化完整environment。禁止保存secret值、API token、service account內容、provider config、OTP／credential、完整home path或任意process environment。

既有Android／iOS `artifact-metadata.txt`保留為platform-local projection；run-level manifest是retention與cleanup authority，不由各build script自行重複實作。

## Retention Classes

| Class | Raw artifact retention | Count bound | Metadata retention |
|---|---|---:|---|
| `verification-success` | 7天 | 每suite／ref最新3次 | 90天 |
| `verification-failure` | 14天 | 最新10次 | 90天 |
| `observability-raw` | 3天 | 每platform最新2次 | 90天 |
| `release-verification` | 30天 | 最新3個release SHA | 365天 |
| `pinned` | 由`expires_at`決定，最長90天 | 必須有reason與owner | 與pin一致 |

Age與count任一超限即成為cleanup candidate。Pin不得永久存在，也不得跳過全域容量計算。

## Capacity and Disk Safety

預設policy：

```txt
CI_ARTIFACT_MAX_BYTES = 30 GiB
CI_ARTIFACT_MIN_FREE_BYTES = 15 GiB
```

每次run開始前與結束後執行retention dry evaluation。若超過max bytes或free space低於下限：

1. 清理已過期且未pin的success artifacts。
2. 清理超過count bound的舊failure artifacts。
3. 清理過期Observability raw artifacts。
4. 清理過期release raw artifacts；保留仍在metadata retention內的manifest與checksums。
5. 若仍不符合，run在build前fail closed，列出被pin或尚未過期的blocking bytes，不偷偷刪除。

容量值可由operator環境提高，但降低minimum free或提高max超過100 GiB需要明確review；source預設不可依host剩餘空間無上限增長。

## Local Cleanup Safety

- Cleanup CLI預設只輸出dry-run manifest；實際刪除必須使用`--apply <manifest-id>`，且manifest內容與store generation一致。
- Apply先將candidate以atomic move移至`trash/<cleanup-id>`，保留24小時後才可purge。
- Cleanup manifest記錄run key、relative paths、bytes、retention reason、pin status與manifest SHA-256。
- Path traversal、symlink逃逸、root mismatch、active lock、in-progress run或manifest drift均fail closed。
- Cleanup failure不得把run標成成功；原驗證結果與cleanup degradation分開記錄。

## GitHub Summary Contract

Self-hosted GitHub job summary至少包含：

```txt
execution_mode=self-hosted
artifact_transport=local-only
commit_sha
run_key
suite / result
manifest_sha256
artifact_count / total_bytes
retention_class
local_store_alias
```

Summary必須明確顯示：

```txt
Local-only evidence; not downloadable from GitHub.
```

可顯示owner host上的absolute path供操作者尋找，但不得產生假的markdown download link或聲稱遠端協作者可存取。

## Failure Evidence

- 每個suite以`always()`完成run manifest；失敗時保存有界diagnostics、step result與原始exit code。
- Diagnostic collection採allowlist，禁止打包整個workspace、home、DerivedData、`.gradle`、`.pub-cache`或`RUNNER_TEMP`。
- Golden failure只保存review需要的master／test／diff images與文字摘要。
- Writer或cleanup本身失敗時不得覆蓋primary failure；summary同時顯示primary result與evidence degradation。

## Observability Boundary

- Firebase service account與Android／iOS provider config仍只在GitHub Environment materialize，並由既有`always()` cleanup移除。
- Managed store只接受App、dSYM、Flutter symbols、mapping、redacted evidence與checksums；provider config與service account永遠排除。
- `observability-raw`使用3天／2次上限，避免iOS acceptance單筆數百MB長期累積。
- Manual Observability新增`emit_controlled_event` boolean，預設`false`。Artifact transport acceptance、symbol upload與dSYM驗證可在不製造新Firebase事件的情況下執行；只有明確驗證remote ingestion時才設為`true`。
- Symbol upload成功仍不等於remote event已symbolicated；provider Console evidence繼續由Observability review擁有。

## Required Checks and Branch Protection Semantics

- `self-hosted` main push checks保持自動且可追溯；PR在self-hosted模式仍是skipped，`skipped ≠ verified`。
- `manual-local`結果不冒充GitHub required check。
- `github-hosted`仍可建立PR checks，但目前不是日常模式。
- GitHub API已確認目前private repository無法使用Branch Protection功能；本Milestone只治理stable job names、mode semantics與operator guide，不宣稱settings已套用。
- 未來方案升級後，必須先確認required check在當時mode會建立run，才可人工啟用。

## GitHub Artifact and Cache Cleanup

GitHub cleanup是獨立、晚於本機route acceptance的不可逆操作：

```txt
fresh inventory freeze
→ 產生exact deletion manifest
→ focused review
→ whole-cleanup review
→ 使用者明確核准
→ 依artifact／cache ID刪除
→ fresh count／bytes re-query
→ post-cleanup regression
```

Deletion manifest至少包含GitHub object ID、name／key、bytes、created／last-accessed、workflow run、classification、reason與total bytes。工具預設dry-run，不允許依name prefix直接批量刪除。

GitHub deletion沒有restore API。核准前必須確認replacement local runtime evidence已存在；刪除後的rollback只包括停止後續刪除、revert workflow與從仍可checkout的commit重新產生artifact，不能聲稱能恢復原GitHub object。

## Rollback

### Cutover前／cleanup前

- Revert workflow gating與artifact writer commits。
- 將`CI_EXECUTION_MODE`維持或切回`manual-local`，不得自動fallback到付費runner。
- Local store run可由cleanup dry-run或24小時trash恢復。

### GitHub cleanup後

- 已刪除GitHub artifact／cache不可恢復。
- Source可重建的verification artifact依原commit重新產生；無法重建的historical remote object必須在cleanup approval中明確接受永久消失。
- Runtime evidence與review文件不得改寫成「GitHub object仍存在」。

## Validation Strategy

### Static and contract validation

- Workflow YAML parsing與`actionlint`。
- Self-hosted禁止`actions/upload-artifact`與`actions/cache`的contract tests。
- GitHub-hosted `artifact_transport` event／mode矩陣，包含`repository-default=none`與只有manual explicit才可使用`failure-only`／`full`。
- Root validation、path traversal、symlink、lock、atomic finalize與manifest schema tests。
- Retention age／count、capacity、minimum-free與pin expiry tests。
- Local cleanup RED／GREEN、dry-run／apply、trash recovery與manifest drift tests。
- GitHub deletion manifest dry-run tests；不得在unit test呼叫實際delete API。
- Secret leakage scanner對manifest、summary與diagnostics執行。

### Runtime acceptance

1. Windows manual-local：quality／tests與Android development／production，確認managed store、manifest、checksums與cleanup dry-run。
2. Mac manual-local：iOS development／production與Observability secret-safe build，`emit_controlled_event=false`。
3. Mac self-hosted：受控source change觸發CI、Android、iOS，確認GitHub checks成功、本機artifact存在，且GitHub artifact／cache count與bytes不增加。
4. Failure injection：至少各驗證quality／platform failure evidence與writer degradation，不洩漏secret。
5. Runner offline：job queued且不fallback；manual-local仍可產生相同schema。
6. GitHub-hosted：額度受限期間只做static contract；實際`full` run需要使用者另行明確核准，不得以self-hosted evidence冒充。
7. Cleanup：本機cleanup acceptance後建立GitHub exact deletion manifest；取得使用者核准後才執行並re-query。

## Documentation and Authority

- ADR-023：Design核准後更新artifact ownership、transport、retention與cleanup durable contract。
- `docs/guides/ci_cd_operations.md`：mode、artifact root、查詢、pin、cleanup、rollback與GitHub cleanup操作。
- `docs/project_context.md`：只保存current capability與限制。
- `docs/roadmap/active.md`：保存current Task與next gate。
- `docs/audits/milestone_32/`：保存Design、Plan、逐Task、runtime、cleanup與post-release evidence。
- Source、tests、manifests與GitHub API fresh queries：保存runtime truth。

## Approval and Stop Gate

本Design已完成repository內部focused review、findings修正、fresh re-review、whole-Design review與documentation validation，但目前仍為`proposed`。

使用者核准前：

```txt
不得建立Implementation Plan
不得更新ADR-023為新contract
不得修改workflow或CI scripts
不得建立本機artifact root
不得修改GitHub variable
不得刪除GitHub artifacts或caches
```

使用者明確核准後，Design才轉為`accepted`，下一個獨立Task才是使用`writing-plans`建立Implementation Plan。
