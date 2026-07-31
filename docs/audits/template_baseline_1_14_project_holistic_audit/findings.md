---
document_type: phase-review
status: active
authoritative_for:
  - template-baseline-1-14-project-holistic-audit-findings
last_reviewed_baseline: 1.14.0
---

# Template Baseline 1.14.0 Project Holistic Audit Findings

本文件是本Audit完整finding正文的唯一authority。各A1～A9 evidence只引用Finding ID，不複製或分叉finding disposition。

Audit-only階段不執行remediation。`Open`表示問題已確認但尚未由後續Requirement Decision處理，不表示缺少disposition。

## Finding Register

### F-A1-01 — Completed Milestone 32位於Active routing

- Severity：P1。
- Status：Open／Remediation proposed。
- Evidence：`docs/milestones/README.md`的Status rule以`docs/roadmap/active.md`為準；active authority為None，但`## Active routing`仍列Completed Milestone 32。
- Current contract：Milestone index只保存正確名稱、status與artifact route，不成為第二份Roadmap。
- Observed state：Completed item被放在Active section，closed table只到Milestone 31。
- Risk：Agent／maintainer可能誤判Milestone 32仍active，導致錯誤讀取與執行route。
- Recommendation：將Milestone 32移入Closed milestone routing，Active routing明確顯示None。
- Baseline blocking：No；1.14.0 release identity仍一致。
- Disposition：Bounded documentation hardening candidate。
- Target route：後續Level 2或Level 3 documentation authority remediation，由Requirement Decision確認。
- Verification required：docs checker、`docs_check`、Milestone／active semantic consistency review。

### F-A1-02 — Documentation Hub錯誤降級canonical ADR目錄

- Severity：P1。
- Status：Open／Remediation proposed。
- Evidence：`docs/README.md`前段定義`docs/adr/README.md`與canonical records為正式Architecture Decision authority；Legacy段落把整個`docs/adr/`稱為placeholder與非正式ADR集合。
- Current contract：Milestone 23後canonical ADR files與ADR index是stable authority。
- Observed state：同一current documentation hub提供互斥routing。
- Risk：Architecture task可能跳過正確ADR，改讀superseded aggregate／legacy guidance。
- Recommendation：把Legacy wording限制到真正legacy file／subpath，保留`docs/adr/README.md`與canonical ADR authority。
- Baseline blocking：No；source與ADR files本身未因此改變。
- Disposition：Bounded documentation hardening candidate。
- Target route：後續documentation authority remediation。
- Verification required：ADR links、docs checker、task-based reading route semantic review。

### F-A1-03 — Completed Milestone 32保留在Candidate authority

- Severity：P2。
- Status：Open／Remediation proposed。
- Evidence：`docs/roadmap/candidates.md`自述只保存尚未核准為active的candidate，卻含`Completed — Milestone 32`及完整closure routing。
- Current contract：Completed／Archived routing由Milestone index、final review、CHANGELOG與VERSION擁有。
- Observed state：Candidate authority同時保存completed item。
- Risk：Candidate list語意與navigation膨脹，形成重複closed routing。
- Recommendation：移除completed正文，只在Git history／audit handoff保留過去candidate脈絡。
- Baseline blocking：No。
- Disposition：Bounded documentation cleanup candidate。
- Target route：與F-A1-01／02同批處理。
- Verification required：Roadmap candidate count、links、`docs_check`與semantic review。

### F-A1-04 — 已合併Milestone 32 branch與worktree殘留

- Severity：P3。
- Status：Open／Operator hygiene proposed。
- Evidence：`milestone-32-ci-artifact-storage-cutover` local branch HEAD `bc5bc17`完全為main ancestor；managed worktree仍存在且先前確認clean。
- Current contract：Completed worktree沒有必須永久保留的runtime authority；cleanup必須由明確operator action執行。
- Observed state：沒有遺失commit或dirty content，但branch／worktree仍出現在日常列表。
- Risk：誤入舊worktree、錯誤branch操作與維護噪音。
- Recommendation：在本Audit review後由使用者獨立核准安全cleanup；先重新確認clean與ancestry。
- Baseline blocking：No。
- Disposition：Maintenance hygiene；不得在Audit-only階段執行。
- Target route：Level 1 operator cleanup或Audit closure後獨立指令。
- Verification required：`git status`、`git rev-list main...branch`、worktree removal與branch deletion後列表確認。

## Current Summary

```txt
Confirmed findings: 4
P0: 0
P1: 2, both with bounded remediation disposition
P2: 1, with bounded remediation disposition
P3: 1, with operator hygiene disposition
Open P1 without disposition: 0
```
