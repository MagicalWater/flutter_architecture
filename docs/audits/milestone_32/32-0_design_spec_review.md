---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-32-design-spec-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Design Spec Review

## Review Scope

本Task審查：

```txt
docs/superpowers/specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md
docs/roadmap.md
docs/roadmap/active.md
docs/roadmap/candidates.md
docs/project_context.md
docs/milestones/README.md
docs/superpowers/README.md
docs/audits/README.md
```

依據包含fresh GitHub inventory、ADR-023、Milestone 27 self-hosted Design／Plan／runtime evidence、四份current workflows、`tools/ci/run_local_ci.sh`與Android／iOS build metadata contract。

本Review不表示Implementation Plan、ADR mutation、workflow implementation、本機artifact root或GitHub cleanup已完成。

## Promotion Decision

```txt
Milestone: 32 — CI產物本機化與GitHub儲存空間切換
Classification: Level 4 — Architecture／Milestone
Requirement Decision: Accept
Active promotion: Completed
Design status: accepted
User approval: approved at 2026-07-30 13:41 Asia/Taipei
```

Fresh evidence支持promotion：

- `CI_EXECUTION_MODE=self-hosted`。
- Runner`water-mac-flutter-architecture`為online／idle，labels完整。
- GitHub artifacts為110筆、7,835,943,504 bytes。
- GitHub caches為15筆、10,211,585,781 bytes。
- 最新artifact停在2026-07-24；2026-07-30 docs-only runs沒有新增storage，但current workflow的platform／Observability upload仍未gating。
- Branch Protection API對目前private repository回覆403，要求升級GitHub Pro或公開repository。

## Focused Review Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| 若把長期預設改為`manual-local`，會失去自動main push checks與GitHub control-plane value | P1 | Design採`self-hosted`為日常預設，`manual-local`只作離線／維護回退 |
| 把`/Users/water/...`硬編碼會使模板與Windows路線不可移植 | P1 | 使用`CI_ARTIFACT_ROOT`；self-hosted要求明確設定，manual-local提供platform default，目前Mac路徑只屬operator config |
| 只依保留天數無法限制短期大量runs造成容量爆增 | P1 | 每個retention class同時定義age、count bound、30 GiB max與15 GiB minimum-free |
| Self-hosted若仍允許小型`upload-artifact`，容易逐步擴張回大型remote ownership | P1 | Self-hosted採完整prohibition；GitHub只保存logs與job summary |
| GitHub-hosted若保留cache或任何remote artifact預設，quota仍會重新增長 | P1 | Remote cache全面預設停用；`repository-default=none`，`failure-only`與`full`都只允許manual explicit |
| Manifest若序列化完整environment，可能洩漏service account、provider config或token | P1 | Manifest採allowlist schema，禁止任意environment與secret；加入secret leakage scanner |
| GitHub summary顯示本機path可能被誤認為可下載artifact | P1 | Summary強制`local-only`與`not downloadable from GitHub`，禁止建立假download link |
| Observability storage acceptance若綁定controlled event，會重複污染Firebase事件 | P1 | 分離`emit_controlled_event`，預設false；storage／symbol驗證不必製造事件 |
| Cleanup與active writer併發可能刪除未完成run | P1 | 加入`.in-progress`、active lock、atomic finalize與manifest generation check |
| Local delete若直接purge，操作失誤沒有短期復原空間 | P1 | 先atomic move到`trash/<cleanup-id>`保留24小時，再purge |
| GitHub artifact／cache delete不可逆，不能以一般rollback描述 | P1 | 固定exact ID manifest、使用者核准與post-delete re-query；明記無restore API，只能重新build |
| Branch Protection目前不可用，Design若寫成驗收項目會形成虛假claim | P1 | Scope只治理check語意與Guide；settings維持未套用且受plan限制 |
| Windows與Mac若各自建立schema，會形成兩套artifact authority | P1 | 兩平台共用同一writer、manifest、retention與cleanup contract，只區分host capability |
| 同一GitHub workflow run包含多個jobs，只用run ID作目錄與manifest identity會互相覆蓋 | P1 | 加入`job-key`與job-level atomic records；run-level manifest只聚合已finalize job manifests |
| 永久pin會繞過容量治理 | P2 | Pin必須有owner、reason與最長90天`expires_at`，仍計入global capacity |

所有P1 finding已直接回補Design正文；沒有留給implementation自行決定的blocking architecture choice。

## Fresh Focused Re-review

逐項重新核對修正版Design：

- 三種execution mode責任互斥，沒有第四種持久mode。
- Self-hosted與manual-local共用本機artifact owner；GitHub-hosted只保留exception transport。
- Artifact root不在repository、worktree、runner `_work`或temp。
- Run identity、manifest、checksums、result、retention與cleanup ownership完整。
- Multi-job workflow以`run-key + job-key`隔離，最後完成的job不會覆蓋其他job evidence。
- Success、failure、Observability與release evidence有不同retention class。
- Capacity、minimum-free、pin、trash與cleanup manifest都可由contract tests驗證。
- Secret與provider config不進manifest、summary或diagnostics。
- 本機path沒有被描述為遠端可下載能力。
- GitHub cleanup位於runtime acceptance與使用者approval之後。
- Production signing、Store distribution與外部object storage沒有進入scope。

Fresh re-review未發現新的P0／P1。

## Whole-Design Review

第二輪從完整資料流重新檢查：

```txt
event
→ execution mode
→ runner／manual host
→ repository-owned build
→ staged artifact writer
→ manifest／checksums
→ atomic publish
→ GitHub summary
→ retention evaluation
→ local cleanup
→ future GitHub cleanup
```

結果：

- GitHub control plane與artifact storage ownership已分離。
- Existing Android／iOS build scripts可維持platform artifact contract，不需重造build pipeline。
- Self-hosted不再依GitHub artifact或cache storage；github-hosted repository default也不建立remote artifact，例外transport只可由manual explicit選擇。
- Failure evidence不會因writer degradation掩蓋primary result。
- Observability secrets與provider acceptance authority維持原邊界。
- Windows／Mac host差異不會產生平行metadata schema。
- Local cleanup可短期rollback；GitHub cleanup不可逆性被如實記錄。
- Branch Protection與remote collaboration限制沒有被誇大。

Open P0 = 0。Open P1 without disposition = 0。

## Authority Check

- Design Spec擁有behavioral requirements與technical design。
- ADR-023尚未修改；只有Design核准後才承接durable artifact ownership contract。
- Roadmap／Project Context只保存active state與current gate，不複製完整Design。
- Candidate文件已改為promotion route，沒有同時把Milestone 32標成candidate與active。
- Audit只保存findings、fixes、re-review與gate，不成為current architecture authority。
- Handoff舊runtime snapshot仍保留歷史查詢日期，不覆蓋fresh inventory。

## Validation

Design Task要求：

```txt
placeholder／TODO scan
cross-document active／candidate consistency review
python tools/docs/check_docs.py .
git diff --check
```

本Task只修改Design、review與routing文件，不修改source、workflow或runtime behavior，因此不執行Flutter tests或platform builds。

## Gate

```txt
Internal Design review: Passed
Open P0: 0
Open P1 without disposition: 0
Design status: accepted
User approval: completed
Implementation Plan: allowed as a new proposed Task
Implementation: forbidden
GitHub cleanup: forbidden
```

下一步固定為使用`writing-plans`建立proposed Implementation Plan，完成完整Plan Task治理後再次停在使用者核准gate。
