---
document_type: governance-policy
status: accepted
authoritative_for:
  - template-development-workflow-governance-overview
last_reviewed_baseline: 1.25.0
---

# Template Development Workflow Governance

本文件是給人類閱讀的短總覽，不是 executable workflow authority。

Executable classification / routing 由：

```txt
.agents/skills/governing-template-development/SKILL.md
```

machine validation selection 由：

```txt
tools/ci/validation_planner.py
```

## Responsibility model

```txt
AGENTS.md
→ fresh admission hard policy

governing-template-development
→ Requirement Decision / lowest-sufficient Level / conditional routing

Canonical ADR / local README / domain Skill
→ stable architecture / local responsibility / domain procedure

Source / tests / runtime / machine manifests
→ executable truth

Spec / Plan / Audit / Archive
→ accepted design, execution intent, review evidence, history
```

同一 current rule 只能有一個 authoritative owner；Guide 或 overview 只提供短摘要與 route。

## Governance levels

- Level 0：trivial / metadata / non-semantic change；minimal check。
- Level 1：bounded fix / narrow refactor；focused validation + review。
- Level 2：standard feature；brief decision + implementation + one final review。
- Level 3：cross-cutting；Design / Plan + one holistic implementation review。
- Level 4～5：真正 repository-wide architecture / security / migration / platform / release-critical scope 才使用 formal evidence。

完整分類與 artifact matrix 按需讀 central Skill references；本文件不複製矩陣。

## Testing / validation

Test lifecycle 採 test-by-exception。是否新增 automation、是否永久保留、這次執行哪些 validation 是三個不同決策。

Human testing semantics：`docs/guides/testing_governance.md`。

Validation scope：`tools/ci/validation_planner.py`。

普通 Task 不因 Milestone 名稱、manual intent、Foundation 標籤或不存在 permanent tests 而自動 full regression。

## Adopted repository Skills

| Skill | Current role |
|---|---|
| `governing-template-development` | 中央 Requirement Decision / classification / routing |
| `starting-feature-work` | 新 feature/user-flow 快捷入口；委派中央治理 |
| `karpathy-guidelines` | accepted implementation/refactor/review 的 simplicity companion |
| `adopting-template-repository` | 首次 Template → Product repository bootstrap orchestration |
| `adopting-template-product-identity` | 跨 Android/iOS product identity adoption |
| `implementing-pencil-flutter-design` | accepted repository-local `.pen` → Flutter domain orchestration |
| `brandkit` / `high-end-visual-design` / `imagegen-frontend-mobile` | restricted visual companions；不取得 workflow authority |

Exact third-party provenance、hash、license 與 immutable source 只由 root `skills-lock.json` 擁有。Historical adoption review、dated revalidation、pressure evidence 由 `docs/audits/` 與 Git history 查詢，不在 current overview 重複保存。

## Approval / closure

Design / Plan 只有 routed review 完成且取得使用者明確核准後才能 accepted。最後一個 implementation unit 通過不等於 Milestone closure；若分類要求 release，仍需完成 relevant release / post-release identity or artifact evidence。

## Change policy

修改 repository workflow governance 時，至少確認：

1. `AGENTS.md` fresh admission / hard policy 沒有產生平行 authority。
2. central Skill 與必要 references routing 一致。
3. machine planner / checker 的真正 safety semantics 沒被 human prose 覆蓋。
4. human Guide 只保留 procedure / examples。

不要為治理變更機械建立 per-subtask audit、per-file manifest 或永久 test。
