---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-33-task-33-3-taste-skill-discovery-pressure-evidence
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-3 Taste Skill Discovery Pressure Evidence

## Purpose

證明「repository存在Skill檔案」不等於「runtime實際載入repository-local Skill」，並驗證DevSpace precedence遇到same-name user-global Skill時可被偵測、清除後可fresh恢復managed-worktree authority。

## Preconditions

```txt
Managed worktree: C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8
Branch: milestone-33-pencil-to-flutter-workflow
User-global collision path before control: ABSENT
Repository lock issues: 0
Repository lock exemptions: 3
```

## RED Collision Control

在確認`C:\Users\crazy\.agents\skills\brandkit`原先不存在後，建立單一temporary fixture：

```txt
C:\Users\crazy\.agents\skills\brandkit\SKILL.md
name: brandkit
description: Temporary same-name collision control.
```

Fresh DevSpace reload結果：

```txt
Loaded brandkit path:
C:\Users\crazy\.agents\skills\brandkit\SKILL.md

Collision diagnostic:
name "brandkit" collision
winnerPath: C:\Users\crazy\.agents\skills\brandkit\SKILL.md
loserPath: C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8\.agents\skills\brandkit\SKILL.md
```

RED disposition：**Admission rejected／fail closed**。此結果證明user-global precedence確實能遮蔽repository-local同名Skill，不能只檢查檔案存在或lock hash。

## Cleanup

Temporary fixture directory由本Task建立且建立前已證明不存在。RED evidence取得後立即執行精確刪除：

```txt
rmdir /s /q C:\Users\crazy\.agents\skills\brandkit
Postcondition: CLEANUP_PASSED
```

沒有刪除或修改其他user-global Skills。

## Fresh GREEN Reload

Fixture移除後重新載入同一managed worktree，三份Skill paths：

```txt
brandkit
C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8\.agents\skills\brandkit\SKILL.md

high-end-visual-design
C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8\.agents\skills\high-end-visual-design\SKILL.md

imagegen-frontend-mobile
C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8\.agents\skills\imagegen-frontend-mobile\SKILL.md
```

Fresh diagnostics：

```txt
Taste Skill collision diagnostics: 0
Loaded Taste Skill paths outside managed worktree: 0
Loaded Taste Skill paths under D:\Developer\ui-agent: 0
```

DevSpace仍回報一項既有Superpowers cache path warning：

```txt
C:\Users\crazy\.codex\plugins\cache\openai-curated-remote\superpowers\6.1.1\skills
skill path does not exist
```

該warning在Taste Skill安裝前已存在，不涉及name collision、lock、worktree path或本Task source admission，因此記錄為unrelated environment warning，不阻擋Task 33-3。

## Hash Reconciliation

Fresh loaded files與root lock：

| Skill | Loaded file SHA-256 | Lock SHA-256 | Result |
|---|---|---|---|
| `brandkit` | `b0c4837e1bd140ca816ae54948754ddd2ac1e2a4d3619363777a80caf00b2ede` | same | PASS |
| `high-end-visual-design` | `e1e32f5e2d420872c6c7332b53d5ff7721946766b78c4822b424c2d512c8fdbc` | same | PASS |
| `imagegen-frontend-mobile` | `8a33389979f3074fa0926678e266ad2eb9234624472254469fc1ad916b9caa24` | same | PASS |

## Disposition

```txt
Collision RED: PASSED
Temporary fixture cleanup: PASSED
Fresh repository-local GREEN: PASSED
Taste Skill collisions after cleanup: 0
Wrong-root loaded paths: 0
External ui-agent active sources: 0
Runtime discovery gate: ACCEPTED
```
