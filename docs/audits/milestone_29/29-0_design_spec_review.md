---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-29-design-spec-review-evidence
last_reviewed_baseline: 1.10.0
---

# Milestone 29 Design Spec Review

## Scope

Review target：

- `docs/superpowers/specs/2026-07-24-milestone-29-drift-persistence-migration-design.md`

Review依據：

- Template Baseline 1.10.0 current source、schema、tests與platform initializer。
- 已接受的`docs/audits/drift_adoption_feasibility_audit.md`。
- Drift官方 migration guide、package metadata與Web/native opener文件。
- `兩層 Task 治理模型.md`的單一Task審查循環。

## Focused review findings

### F-29-0-01 — Package版本不可在Spec永久寫死

Severity：P1

Disposition：Resolved。

Spec改為版本策略：以Plan建立時的exact toolchain解析相容stable版本，並記錄目前調查的2.34.x／0.3.x作為起始參考，不把快速變動patch版當永久architecture contract。

### F-29-0-02 — `drift_sqflite`最終責任需明確

Severity：P1

Disposition：Resolved。

Spec明定`drift_sqflite`只作fixture／compatibility bridge，不作final production executor，避免sqflite framework透過bridge永久留在baseline。

### F-29-0-03 — Drift預設native filename與現有filename不同

Severity：P1

Disposition：Resolved。

Spec禁止直接採`drift_flutter`預設`<name>.sqlite`路徑；Android／iOS必須明確開啟既有sqflite folder中的`flutter_architecture.db`。

### F-29-0-04 — Web storage不能沿用native file相容推論

Severity：P1

Disposition：Resolved。

Spec建立Web獨立調查與三層disposition：in-place import、explicit reset、unsupported upgrade。沒有runtime evidence時不得宣稱自動保留。

### F-29-0-05 — rollback需要區分schema未變與schema升版

Severity：P1

Disposition：Resolved。

Spec固定初始cutover維持schema version 6，要求sqflite rollback fixture；若必須升v7或改data format，需先修訂Spec，不能在implementation中隱性改變。

### F-29-0-06 — generated consistency必須納入change-aware classifier

Severity：P1

Disposition：Resolved。

Spec列出`.drift`、table／DAO source、schema snapshots、Wasm／worker、build config與pubspec為database／source critical path，並要求clean generation diff gate。

## Re-review

逐項finding已在Spec內完成修正。重新檢查結果：

- Option D single-owner cutover明確。
- compatibility fixture是production cutover前置gate。
- AuthUser、Catalog、Web、Desktop、CI、generated consistency、authority removal與rollback均有明確scope。
- 未建立reactive-first或generic persistence framework。
- 未改變credential、Catalog SWR或platform support authority。

## Whole-task holistic review

### Architecture

- App仍為唯一Composition Root。
- reusable package不依賴Drift。
- final baseline只有一個database／schema version owner。
- DAO與business invariant責任分離。

### Migration safety

- v1～v6fixtures由舊contract生成，避免與Drift current schema同源驗證。
- schema、PRAGMA、constraints、data與rollback均有acceptance。
- Web有獨立storage disposition。

### Scope completeness

Design涵蓋使用者要求的25項內容，並保留10個implementation Task的清楚切分。

## Documentation governance and authority

- feasibility audit維持historical planning evidence。
- 本Spec是Milestone 29 design authority。
- `docs/roadmap/active.md`只路由active scope與next action，不複製完整design。
- `docs/roadmap.md`只更新active routing。
- 未提前更新current production persistence或ADR authority。

## Validation

本Task只修改managed documentation，執行：

```txt
dart run melos run docs_check
```

Validation結果記錄於commit前命令輸出。

## Final disposition

```txt
Design Spec: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
Production persistence modified: NO
Next Task: Milestone 29 Implementation Plan
```

