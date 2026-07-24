---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-30-post-release-validation
last_reviewed_baseline: 1.12.0
---

# Milestone 30 — Post-release Validation

## Release

```txt
Baseline: 1.12.0
Release commit: 940399c3783a008f59246db90e2eb1c87e1c2eb6
Branch: main
Remote sync after release push: main...origin/main = 0/0
```

## Clean-checkout Validation

從遠端`main`建立獨立shallow clean clone，並確認HEAD與release commit一致後執行：

- `VERSION`：`1.12.0`。
- Inventory tooling：4 passed。
- Final inventory：136 files／22,943 LOC／769 cases。
- CI Python contracts：88 passed。
- Documentation checker tests：15 passed。
- `dart run melos run docs_check`：passed。
- `git diff --check`：passed。
- Clean checkout沒有未預期修改。

## Remote Workflow State

Release commit `940399c3783a008f59246db90e2eb1c87e1c2eb6`的GitHub Actions結果：

| Workflow | Run | Final state |
|---|---:|---|
| CI | 30087397065 | success |
| Android | 30087397066 | success |
| iOS | 30087397087 | success on attempt 2 |
| Observability Acceptance | 30087397122 | expected skipped by non-manual gate |

iOS第一輪Simulator Build在`Upload iOS development toolchain evidence`階段被平台取消，annotation為`The operation was canceled.`；同一輪Production Release Build已經success。只重跑failed job後，toolchain evidence、workflow contract、unsigned Simulator build與artifact upload全部success，因此沒有production code、workflow contract或toolchain defect evidence。

驗證期間repository-scoped self-hosted runner `water-mac-flutter-architecture`為online。CI、Android與iOS因單一runner容量依序執行；排隊不是GitHub-hosted額度耗盡。

## Focused Re-review

- Release SHA、遠端`origin/main`與clean clone HEAD一致。
- CI、Android、iOS最終conclusion均為success。
- iOS第一輪failure已明確disposition為transient cancelled upload，並由attempt 2完整成功取代。
- Observability Acceptance在非手動push下skipped符合既有gate。
- Open P0：0。
- Open P1 without disposition：0。

## Closure Gate

- Task 30-0～30-11的focused review、findings、修正、re-review、whole-task review、authority check、validation與commit均有正式evidence。
- Milestone holistic review與Template Baseline 1.12.0 release authority同步完成。
- Release commit已推送。
- Clean-checkout governance validation通過。
- Remote CI、Android與iOS全部success。
- Open P0為0，Open P1 without disposition為0。

```txt
Milestone 30: COMPLETED
Template Baseline: 1.12.0
```
