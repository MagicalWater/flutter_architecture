---
document_type: planning-review
status: accepted
authoritative_for:
  - r3-api-client-transport-neutral-error-boundary-plan-review
last_reviewed_baseline: 1.14.0
---

# R3 — API Client Transport-neutral Error Boundary Plan Review

## Focused Findings

### F-R3-P01 — Auth migration若先於adapter會造成大範圍compile break

- Severity：P1。
- Status：Resolved in Plan。
- Fix：R3-1先建立並commitendpoint boundary，R3-2再遷移Auth。

### F-R3-P02 — Mock仍拋Dio會讓development mode繞過neutral contract

- Severity：P1。
- Status：Resolved in Plan。
- Fix：MockAuthApi與MockAuthRefreshApi在R3-1同步實作endpoint interface；OTP backend failure直接建neutral envelope。

### F-R3-P03 — Generated DI若手改會破壞source authority

- Severity：P1。
- Status：Resolved in Plan。
- Fix：R3-3先RED selector／DI tests，再改source並執行build_runner；generated file只作regenerated output。

### F-R3-P04 — Auth tests移除Dio時可能降低transport matrix coverage

- Severity：P1。
- Status：Resolved in Plan。
- Fix：以`TransportExceptionKind`與httpStatus建立neutral fake envelope，保留timeout／connection／certificate／401／403／5xx cases。

### F-R3-P05 — Public barrel cleanup可能破壞Profile／Catalog helper

- Severity：P1。
- Status：Resolved in Plan。
- Fix：保留public neutral-signature `rethrowMappedTransportException`，只移除Dio-specific mapping symbols與failure details export。

### F-R3-P06 — Source change不可只跑documentation regression

- Severity：P1。
- Status：Resolved in Plan。
- Fix：R3-4要求full workspace analyze／tests、generated consistency與App bundle。

## Whole-Plan Review

- TDD RED／GREEN與commit boundaries清楚。
- 每個Task可獨立review並不回寫前一Task狀態。
- Error behavior、dependency boundary、composition與documentation都有owner。
- No Profile／Catalog refactor、no new generic framework、no release／integration。

## Approval Evidence

使用者standing authorization適用；Plan沒有引入Design外的新architecture decision。

## Disposition

```txt
Focused review: PASSED after F-R3-P01～P06 fixes
Whole-Plan review: PASSED
Open P0: 0
Open P1 without disposition: 0
Plan status: ACCEPTED
Implementation allowed: YES after independent Plan commit
```
