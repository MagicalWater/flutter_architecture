---
document_type: planning-review
status: accepted
authoritative_for:
  - r3-api-client-transport-neutral-error-boundary-design-review
last_reviewed_baseline: 1.14.0
---

# R3 — API Client Transport-neutral Error Boundary Design Review

## Focused Findings

### F-R3-D01 — 只移除Auth import不會封閉runtime boundary

- Severity：P1。
- Status：Resolved in Design。
- Fix：新增consumer endpoint interface與api_client-owned Real adapter，Dio在跨package前轉neutral envelope。
- Fresh re-review：Auth不接收Retrofit implementation或Dio exception。

### F-R3-D02 — 將OTP mapping移入api_client會造成business ownership反轉

- Severity：P1。
- Status：Resolved in Design。
- Fix：Envelope只提供backend code與generic metadata；`OtpFailureDetails`及validation仍由Auth擁有。
- Fresh re-review：api_client不依賴auth。

### F-R3-D03 — Generic raw response envelope可能洩漏敏感資料

- Severity：P1。
- Status：Resolved in Design。
- Fix：只複製string-keyed metadata map；不保存Dio Response／RequestOptions／headers；`toString()`不輸出metadata。
- Fresh re-review：sensitive output需focused test。

### F-R3-D04 — Public barrel仍可能間接export Dio mapper

- Severity：P1。
- Status：Resolved in Design。
- Fix：Dio-specific mapper與failure details移至internal files；public neutral helper的signature只接受Object／StackTrace。
- Fresh re-review：public barrel與Auth source有mechanical assertion。

### F-R3-D05 — 全面改造Profile／Catalog會擴張scope

- Severity：P2。
- Status：Resolved in Design。
- Fix：R3只為Auth／Refresh建立endpoint adapter；Profile／Catalog保留既有App-owned DataSource helper，後續只有confirmed finding才promotion。
- Fresh re-review：Task file allowlist排除Profile／Catalog source mutation。

## ADR Gate

ADR-013已定義Dio不得穿透package boundary。本Design不新增stable rule，只讓implementation恢復既有contract，因此不新增或修改ADR正文。

## Whole-Design Review

- Endpoint、adapter、envelope、Auth mapping與App composition responsibilities單一且可測。
- Mock／Real contract parity明確。
- Error identity、stack、OTP metadata與refresh semantics都有behavioral acceptance。
- Auth dependency removal與public API cleanup可mechanically驗證。
- Scope不含R4／R5、release或integration。

## Approval Evidence

使用者standing authorization覆蓋沒有新decision的R3。Design選擇由ADR-013與confirmed finding唯一導出，不需要額外產品決策。

## Disposition

```txt
Focused review: PASSED after F-R3-D01～D05 fixes
Whole-Design review: PASSED
Open P0: 0
Open P1 without disposition: 0
Design status: ACCEPTED
Implementation allowed: NO — accepted Plan required
```
