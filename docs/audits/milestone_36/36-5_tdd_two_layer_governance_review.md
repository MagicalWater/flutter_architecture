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

## Operator constraint update — 2026-08-12

使用者已明確要求後續不得使用Codex。自此起：

- 不再重試Codex CLI、Codex automated harness或其authentication path。
- Task 36-5只接受`skill_behavioral_validation.md`已定義的provider-neutral fresh ChatGPT route。
- Fresh ChatGPT對話不得屬於目前Flutter Project，也不得帶入本對話的Milestone 36結論或預期答案。
- 只有實際fresh response才可計為behavioral evidence；目前對話自我回答、static contract test或docs checker PASS都不能替代。
- 這項operator constraint不推翻Task 36-1～36-4既有machine／static evidence，也不降低36-5的fresh-context requirement。

## Required recovery

2026-08-12使用者已依`skill_behavioral_validation.md`提供不屬於目前Flutter Project的fresh ChatGPT完整回覆。Fresh agent只收到固定read-only pressure prompt與managed worktree path，未被告知Milestone 36預期答案或Skill名稱。

Fresh agent自行發現並採用：

```txt
AGENTS.md
→ governing-template-development
→ references/test-authoring.md
→ docs/guides/testing_governance.md
→ validation_planner.py 作Validation Execution authority
```

逐案review：

| Scenario | Expected | Observed | Verdict |
|---|---|---|---|
| A1 generated DTO 1:1 field | `no-new-test justified` | `no-new-test justified`；沿用generated serializer owner | PASS |
| A2 trivial forwarding UseCase | `Should-not-add` | `Should-not-add`；拒絕called-once interaction test | PASS |
| A3 Bloc debounce／stale response | `Required` | `Required`；Bloc／state owner | PASS |
| A4 styling／copy only | `no-new-test justified` | `no-new-test justified`；planner validation仍required | PASS |
| A5 cursor duplicate-page guard | `Required` | `Required`；Repository policy owner | PASS |
| B styling-only | zero new tests allowed | `no-new-test justified`；仍需validation | PASS |
| C deterministic stale async bug | `Required` | `Required`；closest stale-completion owner，典型為Bloc | PASS |
| D pure passthrough UseCase | `Should-not-add` | `Should-not-add`；明確拒絕verify-called-once | PASS |
| E irreversible migration＋Auth security branch | `Required` | 兩個direct Required owners；不得用no-new-test逃避 | PASS |

Fresh agent最終明確判定：

```txt
5 implementation Tasks != 5 new tests
Scenario A只需要2類新的regression owners
0 new tests可以是正確結果
0 required validation不因此成立
```

這份external fresh response證明中央authoring contract可以在不承接本對話記憶的context下阻止Task-for-test、class-for-test與layer-for-layer imitation。完整actual response由本Task conversation中的使用者原文保存，本review只保存provenance、逐案verdict與disposition。

## Disposition

```txt
Task 36-5: ACCEPTED
Behavioral response produced: YES — provider-neutral fresh ChatGPT
Mechanical contract: GREEN (5/5)
Behavioral pressure: GREEN
Open P0: 0
Open P1 without disposition: 0
Next Task allowed: YES — proceed to Task 36-6
Codex permitted: NO — explicitly disallowed by operator
```
