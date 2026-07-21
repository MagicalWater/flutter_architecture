# 文件索引

本文件是Milestone 22 migration期間的暫時文件入口，用來避免讀者或AI把歷史文件誤認為Template Baseline 1.5.0的current authority。

完整的documentation taxonomy、AI task-based reading contract與各類索引會在Milestone 22-2正式建立。本階段不搬移或刪除既有文件。

## Current authority

目前判斷專案狀態時優先使用：

```txt
VERSION
README.md
docs/project_context.md
docs/architecture_decisions.md
docs/roadmap.md
docs/backlog.md
```

注意：`docs/project_context.md`、`docs/architecture_decisions.md`與`docs/roadmap.md`目前仍包含大量歷史內容。讀取時應以最新current-state段落、`VERSION`與已完成Milestone的final review交叉驗證；它們會在Milestone 22後續階段逐步收斂。

## 文件分類

### Current與Governance

- `docs/project_context.md`：目前仍是current context入口，但混有歷史內容；22-3將重寫為current-only snapshot。
- `docs/architecture_decisions.md`：Decision 001至022的現有aggregate authority；全面單檔extraction不屬於22-1。
- `docs/roadmap.md`：現有roadmap aggregate；22-4將分離active、candidate與closed routing。
- `docs/backlog.md`：future、deferred與explicitly not planned scope。
- `docs/conversation_rules.md`：目前協作規則；22-2將與`AGENTS.md`一起收斂AI reading contract。

### Review與Runtime Evidence

- `docs/audits/`：Planning Review、phase review、final review、findings與runtime evidence。
- `docs/audits/milestone_22_planning_review.md`：Milestone 22治理規劃審查。
- `docs/audits/milestone_22/`：Milestone 22各小階段review evidence。

Audit文件是當時review與evidence artifact，不取代current snapshot或Architecture Decision。

### Plans與Specs

- `docs/superpowers/specs/`：核准前後的design specifications。
- `docs/superpowers/plans/`：可執行implementation plans。

Plan與Spec不代表工作已完成；實際完成狀態應由current roadmap、final review、CHANGELOG與VERSION判斷。

### Historical Archive

- `docs/archive/`：已明確封存的milestone摘要與舊版進度文件。
- 目前部分已完成milestone evidence仍保留於`docs/audits/`與`docs/superpowers/`；Milestone 22會先建立穩定索引，再決定是否需要物理搬移。

### Guides與Knowledge

- `docs/guides/`：可重複使用的操作指南。
- `docs/mistakes/`：已知反模式與錯誤案例。
- `docs/evolution/`：演進文件入口；目前內容有限。

### Legacy Paths

- `docs/adr/`：第一階段placeholder，不是正式ADR集合，不得作為current authority。
- `docs/architecture/`：第一階段historical／partially superseded guidance；內文中的current-tense scope不可直接套用至1.5.0。

上述legacy文件已加上醒目warning，但暫時保留原路徑與正文，以避免歷史遺失及連結立即失效。

## 暫時閱讀路由

在22-2正式reading contract完成前：

```txt
確認版本或current capability
→ VERSION + README.md + docs/project_context.md最新段落

確認架構決策
→ docs/architecture_decisions.md相關Decision

執行特定Milestone
→ 該Milestone spec / plan / planning review / phase review

追查已完成工作的證據
→ docs/audits/相關final review與runtime evidence

查看歷史
→ docs/archive/或對應audit / plan artifact
```

不要依檔名或目錄名稱假設文件仍為current authority；尤其不要將`docs/adr/`與`docs/architecture/`的第一階段內容當成目前實作指令。

## 語言規範

文件與註解預設使用繁體中文；套件、架構、Layer、類別與API名稱保留英文。
