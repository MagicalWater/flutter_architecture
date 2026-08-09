---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-35-implementation-plan-review
last_reviewed_baseline: 1.15.2
---

# Milestone 35 — Implementation Plan Review

## Reviewed artifact

- `docs/superpowers/plans/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance.md`

Accepted Design：

- `docs/superpowers/specs/2026-08-09-milestone-35-test-execution-cost-change-aware-validation-governance-design.md`

## Focused findings

### F-35-P-01 — Planner與workflow若同Task切換，RED／rollback boundary不足

Severity：P1。

Risk：若新planner與CI workflow一次完成，workflow失敗時難以判定是planner core還是consumer wiring問題。

Disposition：Resolved。Plan拆為35-1 RED、35-2 planner GREEN、35-4 CI/local cutover；planner先以pure contracts成立，再切consumer。

### F-35-P-02 — Inventory correction不能覆寫Milestone 30 historical CSV

Severity：P1。

Disposition：Resolved。35-3要求產生Milestone 35-owned current inventory evidence，Milestone 30 CSV保持historical immutable。

### F-35-P-03 — Evidence reuse若被做成persistent cache會過度設計

Severity：P1。

Disposition：Resolved。35-6先以plan identity＋audit evidence contract為目標；只有machine enforcement確有必要才新增narrow helper，禁止daemon／database／global cache。

### F-35-P-04 — Cost acceptance不能只量最快scenario

Severity：P2。

Disposition：Resolved。35-7固定完整scenario corpus，另選single feature／single test／leaf package／full做wall-clock代表量測；高風險scenario可不變快但必須正確升級。

### F-35-P-05 — Release與post-release必須拆開

Severity：P1。

Disposition：Resolved。35-8只處理holistic＋release candidate／publication gate；35-9只在published main／release SHA執行fresh post-release routing＋full regression後formal closure。

## Fresh focused re-review

Re-review確認：

- Task ordering符合RED→GREEN→consumer cutover→authority sync→reuse semantics→measurement→holistic release→post-release。
- 每個Task有明確file scope、interfaces、validation與independent commit boundary。
- Worktree只在Plan accepted後建立。
- Unknown／invalid／engine failure fail-safe沒有任何縮減Task。
- Full regression沒有被nightly-only或sampling取代。
- No duplicate full-run rule只作用於同Task未invalidated evidence；holistic／release／post-release仍fresh。
- 沒有test deletion task，也沒有Clean Architecture rollback。

## Whole-Plan Design coverage

| Design requirement | Planned coverage |
|---|---|
| single validation authority | 35-2, 35-4, 35-5 |
| validation levels | 35-1, 35-2 |
| fine-grained change classes | 35-1, 35-2 |
| feature/package/test/tool/docs/generated/database/native routing | 35-1, 35-2, 35-4 |
| inventory tier alignment | 35-3 |
| AGENTS/Guide/CI consistency | 35-4, 35-5 |
| evidence reuse/fresh invalidation | 35-6 |
| duplicate full-suite prevention | 35-6 |
| fail-safe | 35-1, 35-2, 35-4, 35-7 |
| holistic/release/post-release full | 35-8, 35-9 |
| before/after cost measurement | 35-7 |
| no coverage hole proof | 35-7, 35-8, 35-9 |
| ADR-023 stable authority | 35-5 |

Whole-Plan：PASS。

## Documentation authority check

- Requirement authority：35-r。
- Design authority：accepted Milestone 35 Design。
- Plan只擁有execution ordering、file scope、validation、commit boundaries。
- ADR-023 amendment只在35-5 implementation Task發生，Plan不提前改stable architecture decision。
- Testing Governance current baseline只在35-5依35-3 evidence更新；historical M30 evidence不改寫。
- Roadmap在Plan approval前只能標記`proposed / awaiting user approval`。

## Required validation

Plan Task本身只需要documentation-focused validation：

```txt
python tools/docs/check_docs.py .
git diff --check
```

不得因Level 4 classification在Plan-only Task重跑full Flutter suite。

Fresh validation：

```txt
python tools/docs/check_docs.py . → PASS
git diff --check → PASS
```

## Review disposition

```txt
Plan status: ACCEPTED
Focused review: PASS after findings disposition
Fresh focused re-review: PASS
Whole-Plan review: PASS
Documentation authority: PASS
Open P0: 0
Open P1 without disposition: 0
Implementation allowed: YES, AFTER managed worktree / execution admission
Next gate: MANAGED WORKTREE / EXECUTION ADMISSION
```

