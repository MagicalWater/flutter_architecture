---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-4-batch-c-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-4 — Batch C Auth Refresh and Navigation Review

## Scope

本 Task 擷取 ADR-015與 ADR-021，更新 migration-aware index與 manifest。Aggregate `docs/architecture_decisions.md`正文保持不變，正式 authority尚未 cutover。

## ADR-015 Section Disposition

| Aggregate section | Disposition | Canonical result |
|---|---|---|
| Implementation status | route evidence | 不進 ADR body |
| Background risks | retain/normalize | 保留 dependency cycle、duplicate refresh、stale Session與 unsafe replay風險 |
| AuthHeaderInterceptor | retain | header與 request identity metadata only |
| AuthRefreshInterceptor | retain | authenticated 401 eligibility、refresh/replay only |
| API/transport split | retain | Main Dio／Refresh Dio與 AuthApi／AuthRefreshApi separation |
| api_client/auth abstraction ownership | retain | narrow transport abstraction、Auth implementation、App binding |
| single-flight | retain | generation/userId/failed token identity與 cleanup guard |
| failed/current token comparison | retain | same Session replay；cross-Session rejection |
| Token Pair storage shape | partially retain | atomic credential snapshot invariant retained；SharedPreferences provider removed from current contract |
| SessionManager | retain | runtime-only、generation authority、refresh token not exposed |
| persistence-first refresh commit | retain | credential commit before runtime Session and replay |
| compensating consistency | retain/normalize | cross-store cleanup and no partial runtime Session retained without obsolete provider claim |
| failure classification | retain | typed refresh result and temporary failure no-clear rule |
| invalidation vs logout | retain | passive invalidation does not call LogoutUseCase |
| logout/relogin race | retain | stale response cannot commit |
| replay once/special request | retain | one replay and explicit unsafe-body policy |
| reactive 401 | retain | remains final protection |
| Test requirements | route evidence | 不進 ADR body |
| Milestone non-goals and implementation impact | route plan/evidence | durable replay/idempotency boundary retained；journal removed |

## ADR-021 Disposition

- App coordinator觸發 Auth startup、Router-first-frame ordering與 root replacement contract完整保留。
- Auth／Profile presentation不依賴 Shell navigation identity完整保留。
- 相同 authentication identity不重複導航；loading/failure field不構成 navigation intent完整保留。
- Milestone 18-7D Reviewed／Closed屬 implementation evidence，未保留於 ADR body。

## Semantic Preservation Review

### ADR-015

Accepted。Canonical ADR保留 transport、Auth application、runtime Session、credential commit與 replay的 durable boundary，沒有保留 SharedPreferences為 current credential provider，也沒有提前擴張 OTP、biometric或 Device Binding scope。

### ADR-021

Accepted。Canonical ADR保留 App-owned startup/navigation authority，不建立 Generic Navigation Coordinator，也不讓 AuthBloc／Domain／package依賴 Router。

## Relation Review

- ADR-005、006、007、012、013已存在 canonical targets，relation語意一致。
- ADR-020與 ADR-022尚未 extraction，先列為 related；不建立不存在 target的 supersession edge。
- ADR-015 credential storage scope由 ADR-022取代的正式 reciprocal metadata延後至 Task 23-7，避免 checker出現 missing target。
- ADR-021沒有 supersession relation。

## Link and Compatibility Review

- Canonical related evidence使用有效 relative links。
- Current README／Documentation Hub仍可繼續指向 aggregate，符合 Batch G前 compatibility contract。
- Published CHANGELOG、historical plans與 audits不重寫。
- Aggregate Decision 015／021正文未刪除、未縮減、未轉 stub。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

git diff --quiet -- docs/architecture_decisions.md
→ Passed；aggregate未修改

ADR index
→ 16 extracted / 6 aggregate

Canonical journal scan
→ 無實作狀態、測試要求、release baseline或 Reviewed / Closed journal
```

## Rollback

若 Batch C需要 rollback，revert本 batch commit即可移除兩個 canonical ADR、index／manifest更新與本 review；aggregate authority仍完整存在。

## Review Decision

Batch C semantic、relation、link與 checker gate通過。Open P0／P1：0。
