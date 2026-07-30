---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-32-post-release-validation
last_reviewed_baseline: 1.14.0
---

# Milestone 32 — Post-release Validation

## Release

```txt
Baseline: 1.14.0
Release commit: f4f6a8e76eebe13be2e039db72c6e27a9c1df380
Branch: main
Remote sync after release push: main...origin/main = 0/0
```

`origin/main`原HEAD `21dcc3ce00efc5500fda553f524377db3076d5f5`是release commit祖先；整合使用fast-forward，沒有覆蓋平行commit或建立merge commit。

## Remote workflow state

Release SHA的GitHub Actions結果：

| Workflow | Run | Final state |
|---|---:|---|
| CI | 30561753255 | success |
| Android | 30561753236 | success |
| iOS | 30561753276 | success |
| Observability Acceptance | 30561753104 | expected skipped by ordinary push gate |

CI、Android與iOS所有jobs均由repository-scoped runner執行：

```txt
runner: water-mac-flutter-architecture
labels: self-hosted, macOS, ARM64, flutter-architecture, trusted-main
```

沒有job fallback至GitHub-hosted runner。Observability Acceptance在普通`main` push下skipped，符合受控事件只能由人工明確gate觸發的contract。

## Managed local evidence

Release SHA在formal Mac artifact root建立：

```txt
CI: gh-30561753255-1 / 3 jobs
Android: gh-30561753236-1 / 2 jobs
iOS: gh-30561753276-1 / 2 jobs
```

七個job manifests皆為：

```txt
result=success
evidence_status=complete
execution_mode=self-hosted
host_os=macos
```

Run summaries均明示local-only；所有`checksums.sha256`與secret leakage scan通過。Release evidence共305 files／503,786,801 bytes，沒有`DerivedData`或`.build`進入永久store。

## GitHub storage no-growth

Push前、各workflow完成後與closure review時均重新查詢：

```txt
GitHub artifacts: 0 / 0 bytes
GitHub caches: 0 / 0 bytes
```

四個release runs各自的GitHub artifact count亦為0。Release validation沒有重新建立已清除的remote artifact或cache。

## Clean-checkout validation

從`origin/main`建立獨立managed worktree：

```txt
HEAD: f4f6a8e76eebe13be2e039db72c6e27a9c1df380
origin/main: f4f6a8e76eebe13be2e039db72c6e27a9c1df380
VERSION: 1.14.0
```

Fresh validation：

```txt
Repository CI contract tests: 202 passed
Documentation checks: passed
git diff --check: passed
Working tree: clean
```

## Closure gate

- Requirement Decision、Design、Plan與Tasks 1～11均具focused review及whole-task evidence。
- Local full regression、Windows／Mac representative builds與holistic final review通過。
- GitHub exact-ID cleanup成功，113個manifest objects均不存在。
- Release commit已push至`main`。
- Self-hosted CI、Android與iOS全部success。
- Observability ordinary push保持skipped。
- GitHub storage維持0／0。
- Clean-checkout governance validation通過。
- Open P0為0；Open P1 without disposition為0。

```txt
Milestone 32: COMPLETED
Template Baseline: 1.14.0
```
