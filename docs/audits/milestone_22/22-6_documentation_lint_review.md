---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-22-phase-6-review-evidence
last_reviewed_baseline: 1.5.0
---

# Milestone 22-6 — Documentation Lint Foundation Review

## Scope

本階段以 Python standard library 建立 repository documentation checker，涵蓋 relative Markdown links、baseline consistency、managed metadata、declared ID uniqueness、active milestone status 與 App／Package／Feature README coverage。

## Task Review Log

### Task 1 — Checker tests

狀態：Completed / Reviewed。

先建立六個 fixture tests，覆蓋：

- Broken relative Markdown link，且 fenced code example 不應被誤判。
- Duplicate explicit metadata ID。
- `VERSION`、Root README、CHANGELOG baseline mismatch。
- App、Package、Feature README 缺失。
- Invalid managed metadata。
- 同時存在多份 active milestone document。

RED evidence：

```txt
python -m unittest tools.docs.test_check_docs
→ FAILED
→ ModuleNotFoundError: No module named 'tools.docs.check_docs'
```

失敗原因是 checker implementation 尚不存在，符合預期 RED。

### Task 2 — Relative Markdown link checker

狀態：Completed / Reviewed。

`tools/docs/check_docs.py` 使用 Python standard library：

- 掃描 repository Markdown。
- 忽略 `.git`、`.dart_tool`、`build`。
- 忽略 fenced code 內的示例連結。
- 忽略 anchor、HTTP(S) 與 mailto target。
- 驗證 relative target 存在且不逃出 repository root。

### Task 3 — Baseline consistency

狀態：Completed / Reviewed。

比較：

```txt
VERSION
README.md 的 Template Baseline Version
CHANGELOG.md 第一個正式版本 heading
```

缺少或不一致時回報 `baseline-mismatch`。

### Task 4 — ID、metadata 與 status consistency

狀態：Completed / Reviewed。

Checker 驗證：

- Managed metadata required fields。
- `document_type` whitelist。
- `status` whitelist。
- `authoritative_for` non-empty kebab-case list。
- `last_reviewed_baseline` semantic version format。
- Explicit metadata `id` uniqueness。
- Active milestone document 最多一份。

Historical Markdown 未採用 managed metadata 時不會被強制失敗，符合 legacy adoption rule。

### Task 5 — README coverage

狀態：Completed / Reviewed。

檢查：

- `apps/*/pubspec.yaml` 對應 App README。
- `packages/*/pubspec.yaml` 對應 Package README。
- `apps/*/lib/features/*` 對應 production Feature README。

目前 repository coverage 為 10 / 10。

### Task 6 — Local command integration

狀態：Completed / Reviewed。

新增 Melos command：

```bash
dart run melos run docs_check
```

並同步：

- `AGENTS.md` 常用命令與 commit gate。
- `docs/governance/documentation_policy.md` automated check contract。
- Current Project Context verification commands。

未新增第三方 Python dependency、遠端 CI 或 production package dependency。

## Whole-phase Implementation Review

### Behavior review

- Fixture tests 驗證 checker 的失敗行為，不只驗證 happy path。
- Fenced example 不會造成 broken-link false positive。
- Legacy documents 不會因沒有 metadata 被全量阻擋。
- README coverage 依實際 App／Package／Feature directory discovery，不依硬編碼名稱。
- CLI 有明確 exit code：issue 存在時 `1`，通過時 `0`。

### Boundary review

- Checker 只做 deterministic structural checks，不嘗試判斷 prose semantic correctness。
- Tooling 只使用 Python standard library。
- Melos 僅提供 command entry，不引入 runtime dependency。
- 沒有修改 Dart production source、generated files 或 platform configuration。

### Review finding `22-6-R01` — Automation contract initially absent from governance and entry commands

- Severity：P1 within phase scope。
- Observation：Checker與tests建立後，若未同步 Melos、AGENTS與governance policy，工具會成為隱藏且不可重複使用的 script。
- Remediation：新增 `docs_check` Melos command，加入 AI commit gate，並定義 checker scope與新增規則的 TDD contract。
- Re-review：Passed。

## Finding Disposition

| Finding | Result |
|---|---|
| `M22-PR14` Metadata is inconsistent | Further mitigated：managed metadata 現在有 automated validation |
| `M22-PR15` No documentation consistency checker | Closed |

## Verification

```txt
python -m unittest tools.docs.test_check_docs
→ 6 tests passed

python tools/docs/check_docs.py .
→ Documentation check passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed
```

## Phase Decision

Milestone 22-6 已通過 final fresh verification，可提交。下一個允許階段為 Milestone 22-7 Final Review & Decision Extraction Gate。
