---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-24-pull-request-quality-workflow-review
last_reviewed_baseline: 1.5.1
---

# Milestone 24-2 — Pull Request Quality Workflow Review

## Scope

本 review 驗證 `.github/workflows/ci.yml` 是否把既有 documentation、analysis、tests 與 generated source contract轉為 Pull Request、main push與manual dispatch的repository-level automated gates。

本 Task不建立Android artifact、不讀取secrets、不修改GitHub Branch Protection settings，也不加入production deployment scope。

## Delivered Contract

Workflow events：

```txt
pull_request → main
push → main
workflow_dispatch
```

Stable jobs：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
```

三個jobs互相獨立且平行，不交換generated artifact或workspace build cache。

## Toolchain and Action Review

- Runner固定`ubuntu-24.04`。
- Flutter、Java與distribution由`.github/versions.env`解析為具名step outputs，後續setup與cache key不依賴動態`env` expression行為。
- Flutter固定`3.41.6 stable`，Java固定Temurin 17。
- Checkout、setup-java、Flutter setup與Pub cache Actions全部pin完整commit SHA並保留release註解。
- Checkout使用`persist-credentials: false`，workflow無push需求。

## Quality Review

`Quality`依序執行：

```txt
dart pub get
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

`Generated Consistency`執行tracked lockfile dependency resolution後，呼叫`tools/ci/verify_generated.sh`；script要求clean tree，執行workspace build_runner，並拒絕tracked diff、delete或untracked output。

`Tests`執行全部workspace Flutter tests：

```txt
dart run melos exec -- flutter test
```

## Cache Review

- Flutter Action只cache Flutter SDK。
- `actions/cache`只cache`~/.pub-cache`。
- Pub key包含runner OS、Flutter exact version與root lockfile hash。
- 不cache`.dart_tool`、workspace build output、generated source或test result。
- 每個job即使cache miss仍執行`dart pub get`，cache不是correctness prerequisite。

## Concurrency Review

Concurrency group使用workflow與PR number／ref：

```txt
ci-${workflow}-${pull request number or ref}
```

`cancel-in-progress: true`只取消同一PR或同一ref的較舊quality run；不同PR不互相取消。Android commit artifact traceability不在本workflow，因此不受此策略影響。

## Security and Fork Review

- Workflow permissions只有`contents: read`。
- 未使用`pull_request_target`。
- 未引用repository、environment或organization secrets。
- Fork PR執行的是PR merge context code，但只有read permission且沒有credential persistence。
- Workflow不commit或push generated files。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M24-2-01 Job display name必須穩定供required checks使用 | P1 | 固定為Quality、Generated Consistency、Tests |
| M24-2-02 Floating Action tag會擴大supply-chain風險 | P1 | 四個Actions皆pin完整SHA |
| M24-2-03 Cache不得隱含dependency correctness | P1 | 每個job仍執行`dart pub get`，不cache`.dart_tool` |
| M24-2-04 Fork PR不應取得write token或secrets | P1 | `contents: read`、無secrets、無`pull_request_target`、checkout不持久化credential |
| M24-2-05 Generated job不可依賴其他job輸出 | P2 | 獨立checkout、setup、resolve與generation |
| M24-2-06 `GITHUB_ENV`動態值不應作為後續expression authority | P1 | 改用`steps.versions.outputs.*`明確傳遞 |

Open P0／P1 without disposition：0。

## Verification

```txt
YAML parse / workflow static contract
→ Passed

Pinned Action SHA format and approved action set
→ Passed

python -m unittest tools.docs.test_check_docs
→ Passed

dart run melos run docs_check
→ Passed

git diff --check
→ Passed
```

Hosted GitHub run evidence留待workflow push後與Task 24-5 clean-run review補充；local static review不能冒充GitHub-hosted execution evidence。

## Decision

Task 24-2 accepted。PR quality workflow具備固定event、stable jobs、exact toolchain、minimal permissions、fork-safe boundary、cache independence與generated consistency gate，可進入Task 24-3 Android Verification Artifact Workflow。
