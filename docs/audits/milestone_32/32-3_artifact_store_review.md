---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-3-artifact-store-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 3 Artifact Store Review

## Task Scope

本Task建立：

```txt
tools/ci/artifact_store.py
tools/ci/test_artifact_store.py
```

責任只包含job context、active lock、in-progress staging、artifact／diagnostic inventory、manifest、summary、checksums、atomic publish、run aggregation與CLI。Retention evaluation、cleanup apply、workflow wiring與正式operator root不屬本Task。

## TDD Evidence

第一輪RED：

```txt
python -m unittest tools.ci.test_artifact_store -v
→ ModuleNotFoundError: tools.ci.artifact_store
```

最小implementation後首次執行為4／5通過；重入測試指出begin path先回報staging，而非active lock。調整檢查順序後，Task 2＋3 suite達27項PASS。

Fresh focused review再加入以下RED：

- context JSON修改`published_dir`時必須被context integrity gate拒絕。
- 尚有active lock／in-progress job時不得aggregate partial run。
- `commit_sha`不得含path traversal或非40字元小寫SHA。
- artifact default metadata必須在建立root／lock前驗證為非空字串。
- GitHub外部summary parent不得被managed-store權限治理接管。

上述tests均先確認失敗，再逐項實作；最終Task 2＋3 focused suite為31項PASS。

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| CLI若直接信任context JSON，可把published／lock path重新導向managed root外 | P1 | `JobContext.from_file`與`finalize_job`都重新計算expected staging／published／lock paths，任何不一致即fail closed |
| Run aggregation在其他job仍active時可能發布partial run manifest | P1 | 檢查同commit／run的active lock與`.in-progress`，存在即拒絕aggregation |
| `commit_sha`若未先驗證可能參與path組合 | P1 | begin context preview、context integrity與aggregate入口都要求40字元小寫hex SHA |
| Summary render failure可能掩蓋primary build／test failure | P1 | `result`與`evidence_status`分離；summary render exception產生degraded fallback，但保留primary result |
| Multi-job aggregation若只覆寫最後job會遺失前序evidence | P1 | 每個job獨立atomic publish；run aggregation重新掃描全部finalized manifests並保存各自manifest SHA-256 |
| Artifact default metadata若為mapping，可能被字串化後帶入manifest | P1 | begin side effect前要求platform／environment／build mode／kind／sensitivity／signing／distribution為非空字串 |
| `write-summary`若對外部parent套用0700，會改變GitHub runner-owned檔案權限 | P1 | Managed store目錄維持owner-only；外部summary parent只確保存在，不chmod parent或output |
| 重入時同時存在lock與staging，錯誤若只指向staging會弱化active ownership訊號 | P2 | begin順序固定為published → active lock → staging |

修正後沒有open P0或未處置P1。

## Fresh Re-review

- `begin_job`先完成metadata、root、key與preview manifest validation，再建立任何directory或lock。
- Lock使用exclusive create；published job、active lock與stale staging都fail closed。
- Job staging固定在同一managed root的`.in-progress/<run>/<job>`，published固定在`runs/<sha>/<run>/jobs/<job>`。
- Finalize先產生allowlist artifact entries及SHA-256，再建立manifest／summary／checksums，最後以same-filesystem `os.replace`發布。
- `.job-context.json`不進checksums，也不進published job。
- Artifact／diagnostic symlink被拒絕。
- Primary failure與evidence degradation分離。
- Run aggregation只讀已finalize jobs，記錄manifest relative path、SHA-256、result、evidence status、artifact count與bytes。
- CLI提供`begin-job`、`finalize-job`、`aggregate-run`與`write-summary`，沒有GitHub API或cleanup delete能力。
- Source使用Python 3.9相容typing與standard library。

## Whole-Task Review

完整生命週期重新檢查：

```txt
validated external root
→ exclusive lock
→ in-progress staging
→ platform writes artifacts／diagnostics
→ allowlist manifest + checksums
→ atomic job publish
→ no-active-job run aggregation
→ local-only summary
```

Task 3只消費Task 2 contract，未建立第二套schema，也未提前實作retention／cleanup。Published job不可被同key覆寫；最後完成的job不會覆蓋其他job evidence。

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Validation

```txt
python -m unittest tools.ci.test_artifact_contract tools.ci.test_artifact_store -v
→ 31 tests PASS

CI contract regression excluding 3 proven baseline Windows host harness tests
→ 117 tests PASS

python -m compileall -q tools/ci/artifact_contract.py tools/ci/artifact_store.py tools/ci/test_artifact_contract.py tools/ci/test_artifact_store.py
→ PASS

Task 3 writer and CLI interface scan
→ PASS
```

提交前仍需fresh執行documentation checks與`git diff --check`。

## Gate

```txt
Task 3 focused review: Passed
Task 3 whole-Task review: Passed
Next Task: Task 4 retention／pins／capacity／trash／restore
Workflow mutation: forbidden until Task 6
GitHub cleanup: forbidden
```
