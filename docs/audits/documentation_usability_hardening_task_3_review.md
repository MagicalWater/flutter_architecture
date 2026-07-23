---
document_type: phase-review
status: accepted
authoritative_for:
  - documentation-usability-hardening-task-3-review
last_reviewed_baseline: 1.8.0
---

# Documentation Usability Hardening Task 3 Review

## Review Scope

本 review 審查 Task 3 — API Endpoint and External Client Route：

- `packages/api_client/README.md` 新增的 endpoint checklist。
- Same-backend endpoint 與 new external system 的責任區分。
- Retrofit／Dio、DTO／Domain、Mock／Real、Auth metadata、error mapping與App DI boundary。
- Generated source、tests與repository verification route。

## Review Method

1. 對照 ADR-012、ADR-013、ADR-015、ADR-020與ADR-022。
2. 對照 API Client package 的實際 `lib/src/api/`、`models/`、`mocks/`、errors、interceptors與public barrel。
3. 對照 App `ApiImplementationSelector`、`RegisterModule`與既有 tests。
4. 檢查 README 是否只保存 package-local operation route，沒有建立新的 architecture authority。
5. 檢查 sensitive data、safe replay與Refresh Dio boundary是否完整。

## Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| DUH-T3-R01 | P2 | 初版 endpoint route 若只寫「authentication metadata」，仍可能讓實作者忽略 replay safety、non-replayable request與Refresh Dio recursion boundary | 已補充 public／authenticated判斷、stream／multipart／upload限制、retry marker與獨立Refresh Dio檢查 |
| DUH-T3-R02 | P2 | 初版 checklist 未充分區分 package transport mapping與Feature DataSource／Repository mapping，可能讓DTO或Dio detail穿透Domain | 已明確加入TransportExceptionMapper、Feature DataSource wire mapping與Repository Domain result／Failure邊界 |
| DUH-T3-R03 | P2 | External client route若只列拆包條件，可能被誤讀為README自行擁有package splitting authority | 已明確標示只提供decision entry，正式決策必須進入architecture review並服從canonical authority |

## Fix Evidence

- Endpoint route現在涵蓋Retrofit declaration、wire DTO、generated source、Mock／Real parity、public export、auth／replay policy、transport mapping、Feature mapping、App DI、tests與validation。
- Sensitive credential與raw payload禁止事項已保留。
- External client section明確禁止先建立generic multi-client framework，且不宣稱新的package splitting rule。
- README只保存API Client package-local operational route。

## Re-review

修正後重新確認：

- Retrofit與Dio責任未漂移。
- DTO與Domain分離清楚。
- Mock／Real implementation仍由App選擇。
- Auth metadata、safe replay與Refresh Dio boundary完整。
- Transport exception mapping與Feature DataSource／Repository邊界清楚。
- External system拆包仍需architecture review。
- Generated source不可手動修改，tests與validation route完整。

## Final Gate

```txt
Open P0: 0
Open P1: 0
Open P2: 0
Task 3 re-review: Passed
Documentation implementation scope: Passed
Architecture authority duplication: None
```

