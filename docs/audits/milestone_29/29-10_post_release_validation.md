---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-29-post-release-validation
last_reviewed_baseline: 1.11.0
---

# Milestone 29 — Post-release Validation

## Release

```txt
Baseline: 1.11.0
Release commit: c9a71c7c9200a57d110a005dbec4fe13068fea3e
Branch: main
Remote sync after release push: main...origin/main = 0/0
```

## Clean-checkout Validation

從release commit建立獨立shallow clean clone後執行：

- `dart pub get`：passed。
- `bash tools/ci/verify_generated.sh`：passed。
- build_runner clean generation：passed。
- v1～v6/current Drift schema export：passed。
- `drift_worker.js` clean rebuild：passed。
- no-sqflite authority與schema governance contracts：4 passed。
- 最終輸出：`Generated files are consistent with source.`。

## Remote Workflow State

Release commit `c9a71c7c9200a57d110a005dbec4fe13068fea3e`建立的第一批
GitHub Actions runs中，Android成功完成；CI與iOS因後續post-release evidence
commit `7689e9a0b05c0899d8353ab9d4f87f352d39ed40`推送至同一`main` branch，觸發
workflow既有`cancel-in-progress: true` concurrency policy而被取代。這不是額度耗盡、
GitHub-hosted runner排隊或self-hosted runner離線。

替代commit `7689e9a0b05c0899d8353ab9d4f87f352d39ed40`的remote validation結果：

| Workflow | Run | Final state |
|---|---:|---|
| CI | 30081569765 | success |
| Android | 30081569893 | success |
| iOS | 30081569824 | success |
| Observability Acceptance | 30081569756 | expected skipped by non-manual gate |

被替代的release-commit runs保留歷史disposition：

| Workflow | Run | Disposition |
|---|---:|---|
| CI | 30081244678 | classifier success；後續jobs由新commit依concurrency policy取消 |
| Android | 30081244583 | success |
| iOS | 30081244543 | classifier success；後續jobs由新commit依concurrency policy取消 |
| Observability Acceptance | 30081244494 | expected skipped |

## Current Disposition

- Local release、push、clean checkout、dependency resolution、generation與authority contracts均通過。
- Repository variable為`CI_EXECUTION_MODE=self-hosted`；Mac runner
  `water-mac-flutter-architecture`在驗證時為online，未使用GitHub-hosted付費Mac runner。
- Remote workflow routing、classifiers與替代commit的CI／Android／iOS jobs均成功。
- Release commit第一批CI／iOS run的cancelled結論已由後續同branch commit的完整成功run取代，
  原因是workflow concurrency policy，不是使用量上限或runner故障。
- Open P0：0。
- Open P1 without disposition：0。
- Dispositioned P1：0。

## Closure Gate

以下closure gates全部成立：

- Task 29-0～29-9的focused review、findings、修正、re-review、whole-task review、
  documentation authority、validation與P0/P1 gate已有正式evidence。
- Task 29-10 final holistic review與release authority同步完成。
- Baseline `1.11.0`已commit並推送。
- Clean-checkout generated consistency通過。
- Remote CI、Android與iOS替代commit workflows全部success。
- Open P0為0，Open P1 without disposition為0。

```txt
Milestone 29: COMPLETED
Template Baseline: 1.11.0
```

## Focused Re-review and Whole-task Closure

- Remote run IDs、commit SHA與workflow conclusions已重新查核，沒有把cancelled舊run誤記為failure。
- `CI_EXECUTION_MODE=self-hosted`與runner online狀態已核對；沒有額度耗盡證據。
- Post-release evidence只記錄驗證結果，不取代`29-10_final_review.md`、`CHANGELOG.md`、
  `VERSION`或Roadmap authority。
- 本文件由`active`更新為`completed`後，Milestone 29不再有pending external gate。
- Open P0：0。
- Open P1 without disposition：0。
