---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-32-task-4-retention-cleanup-review
last_reviewed_baseline: 1.13.0
---

# Milestone 32 — Task 4 Retention and Cleanup Review

## Task Scope

本Task建立：

```txt
tools/ci/artifact_cleanup.py
tools/ci/test_artifact_cleanup.py
```

並對Task 3的`begin_job`補上cleanup-operation互斥檢查。Scope只包含raw artifact retention、bounded pins、capacity evaluation、dry-run cleanup manifest、trash／restore／purge與CLI；不修改workflow、不建立正式operator root，也不接觸GitHub API。

## TDD Evidence

第一輪RED：

```txt
python -m unittest tools.ci.test_artifact_cleanup -v
→ ModuleNotFoundError: tools.ci.artifact_cleanup
```

最小implementation後7項GREEN。Focused與whole-Task review持續加入並先確認下列RED：

- raw artifact改動必須造成generation drift。
- trash保留期必須從實際apply時間開始。
- restore中途衝突必須回滾已restore項目。
- missing／symlink candidate不得被靜默跳過。
- apply／restore／purge／pin／unpin必須使用exclusive cleanup-operation lock。
- cleanup期間新job不得開始。
- 容量不足不得刪除fresh且仍在count內的evidence。
- tampered超90天pin必須fail closed。
- cleanup manifest與trash manifest SHA drift必須拒絕。

每個finding都先由獨立測試證明，再實作最小修正。最終Tasks 2–4 focused suite為51項PASS。

## Focused Findings and Fixes

| Finding | Severity | Fix |
|---|---|---|
| Generation只包含job manifests會漏掉raw artifact改動 | P1 | Store generation涵蓋`runs/`全部files／symlinks及active pin files |
| Trash window若從dry-run產生時間起算，舊manifest可在apply後立即purge | P1 | `applied_at`固定由實際apply時的UTC clock產生 |
| Restore中途遇到destination conflict會形成半restore狀態 | P1 | 記錄已restore項目，任何例外時逆序移回trash |
| Missing candidate若被跳過，apply結果與核准manifest不一致 | P1 | Apply先preflight所有relative paths，missing直接fail closed |
| Symlink與generation drift都存在時只回報generation，弱化path safety evidence | P1 | Preflight path／symlink先於generation比對 |
| Cleanup與writer可能在啟動瞬間競態 | P1 | Cleanup使用exclusive `cleanup-operation.lock`；`begin_job`先取得job lock後檢查cleanup lock，cleanup取得lock後再次檢查job locks |
| 容量不足時選擇fresh evidence違反「仍不足即fail closed」 | P1 | Candidate只來自age或count超限；不足部分明確回報`blocking_bytes`，不擴張刪除範圍 |
| Pin檔可被手動改成365天，形成永久容量豁免 | P1 | 評估時重新驗證schema、pin ID、job path、owner、reason及`created_at + 90 days`上限 |
| Cleanup manifest被改動可改變核准範圍 | P1 | Manifest ID與SHA-256自我驗證，root／generation／relative path再次核對 |
| Trash metadata被改動可偽造`applied_at`提前purge | P1 | Trash manifest加入獨立SHA-256；restore與purge共用完整性驗證入口 |
| Active build期間cleanup可能移動正在使用的raw paths | P1 | Any job lock或non-empty `.in-progress`均阻止apply／restore／purge |
| Windows host既有3項CLI／WSL harness tests仍失敗 | P2 | 已證實與本Task無diff，維持排除並在Task 8／9支援host執行完整suite |

修正後沒有open P0或未處置P1。

## Fresh Focused Re-review

- Success使用7天／每suite-ref最新3次。
- Failure使用14天／全域最新10次。
- Observability使用3天／每platform最新2次。
- Release使用30天／最新3個distinct release SHA。
- Age或count任一超限即成為candidate；fresh且未超count的evidence永不因capacity policy自動加入candidate。
- Capacity與minimum-free不足以`blocking_bytes`／`can_satisfy_capacity=false`表達。
- Pin必須具owner、reason、future expiry且最長90天；tampered pin fail closed。
- Evaluate只產生dry-run manifest；只有`apply`會move raw paths至trash。
- Apply確認root、manifest SHA、store generation、active locks、in-progress、missing、traversal與symlink。
- Apply的多path move具rollback；restore也具transactional rollback。
- Trash保留24小時，未滿期限不得purge。
- Metadata manifests／summaries留在published job，raw `artifacts/`／`diagnostics/`才進trash。
- CLI固定提供`evaluate`、`apply`、`restore`、`purge`、`pin`與`unpin`。

## Whole-Task Review

完整生命週期：

```txt
published jobs + pins
→ UTC age／count evaluation
→ capacity projection
→ dry-run manifest + generation hash
→ independent operator apply
→ exclusive cleanup lock
→ preflight + generation recheck
→ atomic moves to trash
→ 24-hour restore window
→ explicit purge
```

Task 4沒有自動執行delete；即使容量不足，也只處置已由retention policy核准的candidate。Writer與cleanup透過job lock／cleanup lock雙向互斥，不會同時開始。

```txt
Open P0: 0
Open P1 without disposition: 0
```

## Validation

```txt
python -m unittest tools.ci.test_artifact_contract tools.ci.test_artifact_store tools.ci.test_artifact_cleanup tools.ci.test_shell_portability_contract -v
→ 51 tests PASS

CI contract regression excluding 3 proven baseline Windows host harness tests
→ 134 tests PASS

python -m compileall -q <Tasks 2–4 modules and tests>
→ PASS

Task 4 cleanup interface and policy scan
→ PASS
```

提交前仍需fresh通過documentation checks與`git diff --check`。

## Gate

```txt
Task 4 focused review: Passed
Task 4 whole-Task review: Passed
Next Task: Task 5 manual-local and platform build integration
Workflow mutation: forbidden until Task 6
GitHub cleanup: forbidden
```
