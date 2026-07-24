---
document_type: design-spec
status: accepted
authoritative_for:
  - connectivity-offline-state-foundation-design
last_reviewed_baseline: 1.9.0
---

# Connectivity and Offline State Foundation Design

## Decision summary

建立下一個正式 Milestone：

```txt
Milestone 28 — Connectivity and Offline State Foundation
```

採用以下架構：

```txt
App-owned provider-neutral connectivity authority
  ↓
Platform connectivity adapter
  ↓
Feature explicit opt-in reconnect coordination
  ↓
Catalog first adoption
```

Connectivity只描述本機網路介面／route可用性，不保證DNS、TLS、gateway或backend成功。單次API結果仍由既有transport／Failure contract表達。

## Goals

- 建立`unknown`、`offline`、`online` typed connectivity state。
- 由App擁有platform adapter、startup snapshot、state stream、resume recheck與dispose lifecycle。
- 確保Feature不直接依賴或監聽connectivity plugin。
- 定義startup、resume、offline→online、重複native event與stream failure語意。
- 建立feature opt-in reconnect signal，不自動重送所有request。
- 讓Catalog在目前可見且已有內容時，於重連後執行non-blocking revalidation。
- 協調manual refresh、initial SWR、resume與reconnect，避免重複request與舊結果覆蓋。
- 提供deterministic unit／Bloc／widget／integration tests與Android／iOS runtime evidence。
- 建立ADR、adopter guidance與current documentation authority。

## Non-goals

- Generic Offline framework、generic repository或global cache interceptor。
- Global Dio retry interceptor、automatic exponential backoff或request queue。
- Offline command queue、transaction outbox、sync engine或conflict resolution。
- 自動重送Login、Refresh Token、OTP、付款、交易或其他command API。
- Backend health monitoring、continuous ping或availability SLA。
- 將`online`解讀為API保證成功。
- 將單次timeout、DNS、TLS、5xx或`FailureKind.network`解讀為裝置確定offline。
- Metered network、SSID、VPN、bandwidth或network quality分類。
- OS background fetch、background isolate或push-triggered sync。
- 一次替所有Feature加入offline UI或reconnect behavior。

## State semantics

### Stable state

```dart
enum ConnectivityState {
  unknown,
  offline,
  online,
}
```

語意：

- `unknown`：尚未完成第一個可靠snapshot、adapter查詢失敗、stream失效後尚未成功recheck，或目前平台無法提供可靠訊號。
- `offline`：platform adapter判定目前沒有可用網路介面／route。
- `online`：platform adapter判定至少存在一個可用網路介面／route。

`online`不代表backend reachable；`offline`也不應由任一Feature的API failure反向寫入。

### Transition rules

- Controller startup初始值固定為`unknown`。
- 初始化時先訂閱native change stream，再取得snapshot，避免subscription與snapshot之間遺失transition。
- 對外只發布distinct state。
- `unknown → online`是initial resolution，不視為reconnect。
- 只有已觀察到`offline → online`才產生reconnect transition。
- App resume必須要求adapter重新取得snapshot；相同state不產生新transition。
- Adapter查詢或stream發生錯誤時，authority進入`unknown`，但錯誤不得中止App或被誤標為offline。
- Dispose後不得再發布state或觸發Feature callback。

## Architecture boundaries

### Contract placement

Connectivity contract放在App boundary：

```txt
apps/flutter_architecture/lib/app/connectivity/
```

原因：

- plugin與`WidgetsBindingObserver`屬Flutter App integration。
- 目前只有一個App，尚無第二個consumer證明需要提升為reusable package。
- 避免`packages/core`或Feature取得platform dependency。

### Platform adapter

Adapter提供最小介面：

```txt
readCurrentState()
stateChanges
dispose()
```

Provider adapter負責把plugin-specific result映射為typed state。不得暴露Wi-Fi、mobile、ethernet等provider enum，也不得執行backend probe。

### Connectivity authority

App-owned controller負責：

- startup subscription與snapshot ordering。
- current state與distinct state stream。
- reconnect transition辨識。
- resume recheck single-flight／latest-result保護。
- adapter error降級為`unknown`。
- subscription與adapter dispose。

Controller不依賴Catalog、Auth、Dio、Router或UI。

### App lifecycle

`ArchitectureApp`仍是`WidgetsBindingObserver` owner。Lifecycle signal分派給獨立coordinator：

- Local unlock coordinator維持既有責任。
- Connectivity controller只在`resumed`時recheck。

不得讓Catalog Page、Bloc或Repository自行註冊App lifecycle observer。

### Feature adoption

Feature必須明確opt-in。第一版不建立任意generic callback registry；App composition只針對Catalog建立窄coordinator，把reconnect transition轉成Catalog presentation event。

未來第二個Feature出現相同需求後，才能重新評估共用adoption abstraction。

## Catalog integration

### Visibility and ownership

只有目前存在且尚未dispose的Catalog Bloc可接收重連事件。App-level coordinator不得直接呼叫Repository，也不得保存query、cursor或Catalog cache policy。

Catalog Bloc新增明確event，例如：

```txt
CatalogReconnectObserved
```

其處理條件：

- 已完成initial load。
- 目前有可顯示items。
- 不在initial loading、manual refresh或reconnect revalidation中。
- 目前query／generation仍有效。

### Reconnect revalidation behavior

- 使用第一頁remote replacement語意，但呈現為non-blocking background operation。
- 不清空目前items、不顯示blocking loader。
- 成功後替換第一頁、重設append cursor chain並更新freshness／lastUpdatedAt。
- 失敗保留目前items，使用獨立reconnect／revalidation failure surface。
- 舊query、舊generation或已dispose結果不得覆蓋current state。

### Ordering

優先級：

```txt
user manual refresh
  > reconnect revalidation
  > passive initial stale revalidation
```

具體規則：

- Manual refresh開始時取消或使既有reconnect result失效。
- Manual refresh進行中收到reconnect時忽略，不排隊第二次refresh。
- Reconnect revalidation進行中再次收到online event不啟動第二次operation。
- Query change／new initial search取消reconnect operation。
- App resume與plugin stream若產生相同online state，只能形成一次reconnect intent。

### Fresh data policy

第一版不根據Catalog cache age跳過reconnect。理由是Bloc目前只有presentation snapshot，沒有完整`freshFor` policy authority；把TTL複製到Bloc會破壞Repository ownership。

重複request由transition distinct、operation dedupe與visibility gate限制，而不是在Presentation重建cache freshness policy。

## Presentation

### App-wide connectivity context

第一版提供App-wide、non-blocking connectivity status surface：

- `offline`可顯示明確offline banner／status。
- `unknown`不顯示「離線」，避免誤導；可在需要時保持中性或不顯示。
- `online`移除offline surface，但不顯示「後端已恢復」。

Connectivity banner不得取代Feature operation failure。即使state為`online`，Feature仍可顯示timeout、service或protocol failure。

### Catalog status

Catalog保留既有cached、stale、last updated與background revalidation surfaces。Reconnect revalidation沿用non-blocking語意，但可有獨立state欄位以避免與initial SWR completion混淆。

所有user-facing copy必須加入English與`zh_TW` ARB；不得直接顯示diagnostic message。

## Error handling

- Plugin adapter exception不得逃出bootstrap、resume或stream callback。
- Adapter failure轉為`unknown`並透過既有App reporting boundarybest effort上報安全operation context。
- Connectivity adapter failure不轉成Catalog Failure，也不觸發Session清除。
- Catalog reconnect remote failure沿用typed`Failure`與localized presentation。
- Unknown programming error保留stack與既有global error boundary，不包成普通offline state。
- Stream正常結束視為provider unavailable，authority轉`unknown`；resume時允許重新建立／recheck的策略由implementation plan明確化。

## Dependency and provider strategy

使用單一Flutter connectivity plugin作reference adapter。選擇標準：

- Android／iOS支援成熟。
- 同時提供current snapshot與change stream。
- 不宣稱internet/backend reachability。
- 可由fake adapter完整測試，不讓Feature依賴provider type。

Provider dependency只加入App package。Reusable packages與Catalog domain/data不得依賴plugin。

## DI and lifecycle

App Composition Root建立：

- Platform connectivity adapter。
- Connectivity controller／authority。
- App-wide presentation binding。
- Catalog reconnect coordinator。

Controller是App lifecycle singleton，必須在App dispose或測試teardown明確dispose。Generated DI如需更新，只修改source registration後執行build runner。

## Validation strategy

### Contract tests

- Initial `unknown`。
- Subscribe-before-snapshot race。
- Snapshot mapping與distinct states。
- `unknown → online`不產生reconnect。
- `offline → online`只產生一次reconnect。
- Resume recheck single-flight與latest-result protection。
- Adapter error／stream error／stream done轉`unknown`。
- Dispose後無state emission或callback。

### Catalog tests

- Offline狀態不自動清空cache data。
- Reconnect只在loaded＋visible context觸發。
- Reconnect為non-blocking replacement。
- Manual refresh優先並抑制reconnect duplicate。
- Query switch取消舊reconnect result。
- Success replacement與failure retention。
- Append／cursor generation不被舊reconnect結果破壞。

### Widget and localization tests

- Offline banner English／`zh_TW`。
- `unknown`與`online`不誤顯示offline。
- Cached／stale／reconnect failure surfaces可共存且不互相覆蓋。
- Narrow viewport與large text不overflow。

### Runtime evidence

Android與iOS至少驗證：

1. App online啟動。
2. 載入Catalog內容。
3. 關閉可用網路介面後顯示offline context並保留Cache。
4. 恢復網路後offline surface消失。
5. Catalog執行一次non-blocking revalidation。
6. App background／resume不產生重複refresh storm。

Simulator／emulator無法可靠模擬的部分必須明確記錄限制，不得以unit test冒充runtime evidence。

## Documentation and authority

- 新增ADR擁有typed connectivity、App lifecycle、provider boundary與feature opt-in contract。
- ADR-017繼續擁有Catalog cache／SWR policy。
- ADR-015繼續擁有Auth refresh／safe replay。
- ADR-020繼續擁有Failure分類與error reporting。
- Catalog README只保存feature-local adoption contract。
- App README與project context保存current capability摘要。
- Runtime steps進入adopter／operations guide，不複製到Roadmap。

## Milestone task decomposition

### Task 28-1 — Connectivity Contract and ADR

建立typed contract、ADR、public semantics與contract tests，不接platform plugin。

### Task 28-2 — Platform Adapter and App Composition

加入App-only provider dependency、adapter mapping、DI、startup／dispose與fake seam。

### Task 28-3 — Lifecycle and Transition Coordination

完成subscribe／snapshot ordering、resume recheck、distinct、reconnect generation與error semantics。

### Task 28-4 — App-wide Connectivity Presentation

加入localized offline status surface、App binding與widget regression。

### Task 28-5 — Catalog Reconnect Integration

加入Catalog opt-in coordinator、Bloc event、non-blocking replacement與operation ordering。

### Task 28-6 — Cross-layer Regression and Resilience

補齊race、dispose、stream failure、manual priority、query switch、cache與Auth non-regression。

### Task 28-7 — Platform Runtime Acceptance

完成Android／iOS build、runtime smoke與可重現evidence；處理必要native configuration。

### Task 28-8 — Documentation and Release Readiness

同步README、current snapshot、guide、roadmap、CHANGELOG候選內容與release前evidence，但不提前宣稱Milestone完成。

## Acceptance gates

- Feature與reusable package沒有connectivity plugin dependency。
- App只有單一native connectivity subscription owner。
- Interface availability、backend reachability與operation failure在code、tests與文件中明確分離。
- Catalog reconnect不產生blocking loader、duplicate request storm或stale overwrite。
- Auth refresh／safe replay行為與tests保持不變。
- Open P0 = 0。
- Open P1 without disposition = 0。
- `docs_check`、analyze、full tests與platform representative builds通過。
- Android／iOS runtime evidence有明確結果或有disposition的外部阻塞。

## Promotion decision

Capability audit、scope、non-goals、ADR需求與task decomposition已明確。Design Spec通過完整Task審查循環後，可建立Implementation Plan；Plan通過前不得修改production source。
