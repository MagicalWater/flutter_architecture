---
document_type: runtime-evidence
status: active
authoritative_for:
  - milestone-34-task-34-3-asset-typography-pressure-evidence
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Task 34-3 Asset / Typography Pressure Evidence

## Current Disposition

```txt
Task 34-3: BLOCKED
Reason: automated Codex harness authentication unavailable; external fresh-chat validation pending
Completion commit: FORBIDDEN while blocked
Task 34-4 / 34-5: NOT STARTED
```

Static PTF-13～PTF-18 contract已加入domain Skill reference，但依`writing-skills`與accepted Implementation Plan，static text存在**不等於behavioral GREEN**。

## Required Isolated-Agent Protocol

2026-08-09使用者核准將harness改為provider-neutral。真正的requirement是「fresh independent agent context」，不是Codex CLI本身。

Accepted harness例如：

```txt
Codex CLI ephemeral session
Claude Code fresh session
獨立、非目前Flutter Project的ChatGPT新對話
其他可讀repository authority且能保存actual prompt/response的isolated agent runtime
```

每個harness都必須符合：

```txt
no current-task conversational memory
repository-readable
actual prompt retained
actual response retained
runtime/model identity recorded when available
```

Behavioral protocol維持：

```txt
RED: repository外，ignore user config，不載入本repository Skills
DISCOVERY: managed worktree root，不顯式指定domain Skill
EXPLICIT GREEN: managed worktree root，明確指定implementing-pencil-flutter-design與necessary references
REFACTOR: 若GREEN仍出現shortcut rationalization，修Skill wording後fresh rerun affected cases
```

每個stage都必須是fresh context，且必須取得actual model response。對ChatGPT manual fresh-chat route，使用者需開啟不屬於目前Flutter專案Project的新對話，貼上固定Prompt，不附加本對話背景，再把完整回覆帶回本對話審查。

## Harness Admission

Command：

```powershell
codex --version
```

Observed：

```txt
codex-cli 0.145.0
```

Fresh context probe使用：

```powershell
echo Reply exactly PROBE_OK. | codex exec --ephemeral --ignore-user-config --skip-git-repo-check -s read-only -m gpt-5.6-sol -
```

Runtime metadata成功初始化：

```txt
model: gpt-5.6-sol
provider: openai
approval: never
sandbox: read-only
```

但provider authentication失敗，WebSocket重試後HTTPS fallback同樣失敗：

```txt
401 Unauthorized
Missing bearer or basic authentication in header
```

Process exit code：`1`。

因此沒有產生`PROBE_OK`或任何behavioral response，不能計為RED、DISCOVERY、EXPLICIT GREEN或REFACTOR evidence。

## PTF-13～PTF-18 Contract Prepared

已加入：

1. PTF-13 Complex ornament shortcut。
2. PTF-14 Silent font fallback。
3. PTF-15 Approximate icon substitution。
4. PTF-16 Untracked derived raster。
5. PTF-17 Raster-everything shortcut。
6. PTF-18 Static CustomPainter overbuild。

Expected behavior與Milestone 34 accepted Design一致，但目前只屬static behavioral contract，尚未取得actual independent-agent proof。

## Finding

### F-34-3-01 — Automated Codex harness authentication unavailable

- Severity：P2 harness failure；若沒有其他isolated-agent harness才升級為P1 external blocker。
- Status：Superseded as sole blocker by approved fresh-chat route。
- Finding：Codex CLI可啟動ephemeral read-only harness，但OpenAI provider未提供有效authentication，因此fresh context無法產生模型response。
- Impact：Codex automated path不可用，但這不等於behavioral validation本身不可執行。
- Required recovery：優先使用已核准的external fresh-chat route；若使用者無法提供fresh chat，再恢復任一其他isolated-agent runtime。
- Scope guard：不以目前ChatGPT對話的自我審查、static text assertion或mechanical policy tests替代independent behavioral evidence。

### F-34-3-02 — External fresh-chat behavioral evidence pending

- Severity：P1 execution dependency。
- Status：Waiting for external validation。
- Finding：PTF-13～PTF-18仍缺actual fresh-agent response。
- Recovery：由使用者開啟**不屬於目前Flutter專案Project**的新ChatGPT對話，貼上repository提供的fixed validation prompt；回覆帶回後由本Task逐case判定PASS／FAIL。
- Completion gate：actual fresh-chat evidence未回收前，Task 34-3仍不得completion commit。

## Mechanical Validation While Blocked

Blocked不撤銷Task 34-2已成立的mechanical GREEN。可執行：

```powershell
python tools/docs/test_pencil_representation_mapping_policy.py
python tools/docs/test_pencil_single_renderer_policy.py
dart run melos run docs_check
git diff --check
```

這些只證明repository contract與documentation一致，不會把Task 34-3升級為PASS。

## Open Findings

Open P0：0。

Open P1 without disposition：1（F-34-3-02，waiting for external fresh-chat validation）。

