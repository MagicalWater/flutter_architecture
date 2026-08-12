# Artifact 與 Superpowers 路由

| 需求 | L0 | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|---|
| Requirement Decision | brief | required | required | required | formal | formal |
| Behavioral requirements | no | optional | required | required | required | required |
| Brainstorming | no | optional | required | required | required | required |
| Design Spec | no | usually no | required | required | required | required |
| Implementation Plan | no | inline | required | required | required | required |
| ADR gate | no | no | conditional | stable boundary 改變時 required | required | architecture 改變時 required |
| 雙層 Task 模式 | minimal | simplified | standard | full | full | full-critical |
| Worktree／branch | no | optional | recommended | required | required | required |
| Regression | focused | affected | feature／integration | affected workspace | full | full＋compatibility／platform |
| Release | no | conditional | conditional | usually | 依 Milestone disposition required | required |
| Post-release | no | no | conditional | conditional | required | required |

## Artifact ownership

- Behavioral requirements 與 technical design 由已核准的 Design Spec 保存。
- ADR 擁有 stable architecture decisions，不擁有 Task sequencing。
- Implementation Plan 擁有 ordered steps、file scope、validation 與 commit boundaries。
- Audits 擁有 findings、re-review 與 evidence。
- Source、tests 與 CI 擁有 runtime truth。
- Project Context 與 Guides 擁有 current state 與 reusable policy。
- VERSION 與 CHANGELOG 擁有 release identity 與 release history。

## Superpowers 順序

```txt
Classification
→ 依路由使用 brainstorming
→ Design Spec
→ Design Task governance 與使用者核准
→ writing-plans
→ Plan Task governance 與使用者核准
→ 依路由建立 worktree
→ Test Authoring Decision（Required／Recommended／no-new-test justified／Should-not-add）
→ 依authoring disposition使用TDD／systematic debugging；TDD不代表每Task新增test
→ implementation／refactor／production code review 搭配 karpathy-guidelines
→ executing-plans 或 subagent-driven-development
→ requesting／receiving code review
→ verification-before-completion
→ finishing-development-branch
→ repository release 與 post-release closure
```

Repository gate 的優先順序高於 Superpowers shortcut。尤其 Design Spec 尚未 accepted 前，不得開始 writing-plans；Plan 尚未 accepted 前，不得開始 implementation。

`karpathy-guidelines` 絕不是 workflow 入口。它只在分類與必要核准完成後載入；純討論、approval gate、Level 0 documentation-only work、roadmap disposition 與 release closure 不使用它，除非同時正在審查 production code。

## 接受狀態轉換

```txt
Design proposed → 完整 Design Task gate → 使用者核准 → Design accepted
Plan proposed → 完整 Plan Task gate → 使用者核准 → Plan accepted
Accepted Plan → implementation Tasks
Local final review → push／clean-checkout／remote validation → Milestone closure
```

Gate 失敗時，artifact 必須維持 proposed、active、blocked 或 rejected。不得只因檔案或 commit 已存在，就把它標記為 accepted。
