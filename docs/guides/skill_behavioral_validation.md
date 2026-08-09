---
document_type: guide
status: active
authoritative_for:
  - manual-fresh-chat-skill-behavioral-validation
last_reviewed_baseline: 1.15.1
---

# Skill Behavioral Validation — Fresh Chat Protocol

## Purpose

本Guide定義repository Skill需要behavioral pressure validation，但本機automated agent harness不可用或不適合時，如何使用**獨立fresh chat**取得可信的actual agent behavior evidence。

它不取代`governing-template-development`、accepted Design／Plan或各Skill pressure scenarios；只定義manual context isolation與evidence回收方法。

## Core Contract

Behavioral validation要求：

```txt
fresh independent agent context
≠ Codex CLI hard dependency
```

可使用任一approved isolated-agent harness，只要符合：

- 不承接目前執行Task的conversation memory。
- 能讀取指定repository／managed worktree。
- 不預先餵入正在驗證的答案或Milestone口頭背景。
- exact prompt與actual response都能保存。
- model／runtime identity可取得時一併記錄。

## ChatGPT Fresh-Chat Route

使用ChatGPT人工驗證時：

1. 開啟**不屬於目前專案Project**的全新對話。
2. 不貼本對話交接摘要、Milestone結論或預期答案。
3. 只貼Task提供的固定validation prompt。
4. 讓新對話透過`@bridge-win`讀取指定managed worktree與repository authority。
5. 不修改repository；除非validation prompt另有明確要求，預設read-only。
6. 保留完整的新對話回覆，不只摘錄PASS句子。
7. 把完整回覆貼回原Task對話，由原Task依pressure scenario逐項判定。

## Stages

### RED

不載入正在驗證的repository Skill；確認一般agent是否會出現target shortcut。RED只需要對confirmed gap具代表性的case，不得捏造本來就安全的baseline failure。

### DISCOVERY

新對話可讀repository，但Prompt不寫出domain Skill名稱。Agent應自行依`AGENTS.md`與中央治理發現正確route。

### EXPLICIT GREEN

Prompt明確要求使用正在驗證的Skill與必要references，確認contract在隔離context下能阻止shortcut。

### REFACTOR

若DISCOVERY或EXPLICIT仍有P0／P1 shortcut，回原Task修Skill wording，再用**另一個fresh context**重跑受影響case。不能在同一聊天串告訴agent正解後再計為fresh GREEN。

## Evidence Requirements

每次validation至少保存：

```txt
stage
scenario IDs
exact prompt
actual response
worktree / repository identity
model/runtime identity when available
review verdict per case
findings / refactor disposition
```

Static Markdown存在、Python keyword test通過、目前工作對話自我回答，都不能取代actual isolated-agent response。

## Failure Rules

- 新對話若屬於同一Project，或明顯取得目前Project conversation context，不計為fresh evidence。
- 使用者若在Prompt中直接告訴agent預期答案，該case不計DISCOVERY evidence。
- 只貼摘要、不保留actual response，不得宣稱behavioral PASS。
- 所有可用isolated-agent harness都不可用時，Task才標記external blocker。
