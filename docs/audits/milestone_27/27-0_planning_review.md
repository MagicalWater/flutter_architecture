---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-27-production-observability-planning-review
last_reviewed_baseline: 1.8.0
---

# Milestone 27 — Production Observability Foundation Planning Review

## Review scope

本Review檢查Production Observability Capability Audit、Foundation Design、ADR-026、implementation plan，以及ADR-020、023、024、025的authority boundary。

本Review不代表production adapter、native configuration、CI secret或remote provider evidence已完成。

## Decision

```txt
Disposition: ACCEPTED
Milestone: 27 — Production Observability Foundation
Open P0: 0
Open P1: 0
```

Production Observability是目前最合理的下一個Milestone。既有ErrorReporter、failure architecture、native environment與CI foundation已足以支撐此工作；production adapter、release identity、privacy、mapping／dSYM與remote acceptance則形成清楚且相互依賴的下一段缺口。

## Architecture review

核准：

```txt
Provider-neutral App-owned contracts
  ↓
Firebase Crashlytics single reference adapter
```

不核准同時導入Sentry。未來替換provider時，只應更換provider initializer／adapter、native config、symbol upload、remote acceptance workflow與adopter guide。若implementation要求修改Feature、Package、Exception／Failure mapping或Bloc capture semantics，視為boundary regression。

- ADR-020繼續擁有error classification與sensitive diagnostic contract。
- ADR-026擁有production provider、release identity、collection、privacy adoption、symbol與CI integration。
- ADR-026不supersede ADR-020、023、024或025。

## Scope review

Goals：provider-neutral contracts、release identity、fatal／unexpected／degraded routing、recursive protection、Crashlytics reference adapter、Android symbols、iOS dSYM、CI secrets、remote acceptance及privacy adoption。

Non-goals：Sentry second adapter、Firebase Analytics、business events、APM、session replay、production signing、Store distribution、generic remote logger與Connectivity／Offline foundation。

## Findings and disposition

| Finding | Severity | Disposition |
|---|---|---|
| ADR coverage checker原本固定到ADR-025 | P1 | 已新增ADR-026 regression並更新checker，14個checker tests與docs check通過 |
| Crashlytics breadcrumb建議可能把Analytics帶入scope | P1 | ADR-026明確禁止因breadcrumb自動導入Firebase Analytics |
| Provider-neutral abstraction若無reference adapter無法形成production evidence | P1 | 核准Crashlytics作唯一reference adapter |
| Provider替換成本可能擴散至Feature／Package | P1 | ADR-026建立App／native／CI integration seam與blocking boundary rule |
| Plan未明確保存固定的小階段執行／review／commit規則 | P1 | Plan已明定每個編號Task是一個小階段，內部逐步review，整體implementation review通過後只commit一次 |
| Production collection是否依provider預設啟用存在privacy歧義 | P1 | ADR、Design與Plan統一為所有environment remote collection預設關閉，僅由明確policy啟用 |
| Release version／build authority留待實作選擇，可能形成雙重來源 | P1 | Task 27-1固定native package metadata為runtime authority，commit SHA僅由受控build-time define提供 |
| Connectivity breadcrumb缺少typed authority | P2 | Defer至Connectivity and Offline State Foundation |

所有P1均已有design／ADR／plan disposition，沒有阻擋activation的open finding。

完整planning artifacts holistic re-review由`27-0_planning_artifacts_holistic_review.md`保存；本文件不以原始activation判定取代補充終審。

## Validation evidence

```txt
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Production source與dependencies尚未修改，因此此階段不要求Flutter全量test或platform build。

## Activation gate

Milestone 27可正式成為active milestone。下一步固定為：

```txt
Task 27-1 — Release Identity and Provider-neutral Contracts
```

Task 27-1不得加入Firebase dependency；provider dependency只能在Task 27-3依已驗證contract導入。
