---
document_type: phase-review
status: active
authoritative_for:
  - milestone-36-task-36-5-tdd-two-layer-behavioral-review
last_reviewed_baseline: 1.16.0
---

# Task 36-5 — Double-Layer Task Governance and TDD Behavioral Review

## Purpose

依accepted Plan，以fresh independent agent context驗證Task數量不會機械轉換成test數量，且`no-new-test justified`不會逃避Required risk或Milestone 35 validation。

## Approved isolated-agent harness

Repository Guide：`docs/guides/skill_behavioral_validation.md`。

本次先嘗試本機Codex CLI automated harness：

```txt
codex-cli: 0.145.0
mode: --ephemeral
sandbox: read-only
worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-98449518
model selected by runtime: gpt-5.6-sol
```

Prompt未提供Milestone 36預期答案或Skill名稱，只要求agent自行讀current repository authority後判斷五個互相獨立scenario：

1. 五個implementation Tasks，但真正新增risk owner只有Bloc debounce／stale-response與Repository cursor duplicate protection。
2. Styling-only Task。
3. Deterministic stale async account-switch bug。
4. Pure passthrough `return repository.getFoo();` UseCase。
5. Irreversible database migration＋Auth security branch。

並要求逐案回答是否新增test、primary owner、若不新增的正式disposition、既有validation是否仍需執行，以及Task數是否應與new test數一對一。

## Execution blocker evidence

Fresh isolated session確實建立，但在任何model response產生前authentication失敗：

```txt
OpenAI Codex v0.145.0
workdir: ...flutter_architecture-98449518
model: gpt-5.6-sol
sandbox: read-only
session id: 019ff4af-0b1e-7972-993a-f11c5e2ab5ea

WebSocket transport:
HTTP 401 Unauthorized

HTTPS fallback:
401 Unauthorized
Missing bearer or basic authentication in header

Process exit code: 1
```

這是execution/authentication failure，**不是behavioral evidence**。沒有產生actual agent answer，因此不得把static scenario、Python GREEN contract或目前ChatGPT對話自我判斷冒充fresh behavioral PASS。

## Existing mechanical GREEN

在blocker前，Milestone 36 repository contract已fresh驗證：

```txt
python -m unittest tools.docs.test_test_authoring_governance
→ PASS (5/5)

python tools\docs\check_docs.py .
→ PASS

git diff --check
→ PASS
```

這些只證明repository bytes／static contract一致，不取代36-5 isolated-agent behavioral requirement。

## Required recovery

可接受的recovery二選一：

1. 恢復Codex CLI authentication後，以新的`--ephemeral` read-only session重跑；或
2. 依`skill_behavioral_validation.md`使用不屬於本Flutter Project的fresh ChatGPT對話，只提供固定pressure prompt與worktree path，再把完整actual response帶回審查。

同一failed session不得在補充正解後重用為GREEN。

## Disposition

```txt
Task 36-5: BLOCKED — external isolated-agent authentication
Behavioral response produced: NO
Mechanical contract: GREEN
Open P0: 0
Open P1 without disposition: 0
Next Task allowed: NO
Required next action: restore an approved isolated-agent harness and rerun fresh
```
