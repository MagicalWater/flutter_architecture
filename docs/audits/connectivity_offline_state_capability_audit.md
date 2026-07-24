---
document_type: planning-review
status: accepted
authoritative_for:
  - connectivity-offline-state-capability-audit
last_reviewed_baseline: 1.9.0
---

# Connectivity and Offline State Foundation Capability Audit

## Audit purpose

本文件盤點 Template Baseline 1.9.0 的 Connectivity、network availability、offline state、Catalog Offline Cache、App lifecycle、repository refresh、retry 與 error presentation 現況，作為是否提升正式 Milestone 28、是否新增 ADR 與後續 Design Spec 的依據。

本次只做 repository inspection、capability inventory、gap／risk／責任邊界分析與 candidate evaluation；不加入 connectivity plugin，不修改 production runtime source，也不預先建立通用 offline command queue、sync engine 或 conflict resolution framework。

## Repository state inspected

```txt
Baseline: 1.9.0
Branch: main
Working tree at audit start: clean
Local branch: synchronized with origin/main
Active milestone: None
Latest completed milestone: Milestone 27
```

主要 authority 與 evidence：

- `docs/project_context.md`。
- `docs/roadmap.md`、`docs/roadmap/active.md`、`docs/roadmap/candidates.md`與`docs/backlog.md`。
- ADR-015 Refresh Token、ADR-016 Catalog Pagination、ADR-017 Catalog Offline Cache、ADR-018 Catalog presentation與ADR-020 Failure architecture。
- Catalog Feature README、Repository、Bloc、tests與 SQLite cache source。
- App lifecycle、local unlock coordinator、DI與bootstrap source。
- Dio transport exception mapping、Auth refresh interceptor與相關 tests。

## Existing capability inventory

### 1. Transport failure classification exists

`packages/api_client`已把 Dio 的 connection timeout、send timeout、receive timeout、connection error、bad certificate、cancel、bad response與unknown transport failure保存為typed transport details；`packages/core`再將可預期的連線類 failure映射為`FailureKind.network`。

這個能力回答的是「某次 request 如何失敗」，不是「裝置目前是否有可用網路介面」或「後端現在是否可達」。目前沒有任何全域 connectivity authority，也沒有持久化或串流化的 online／offline state。

### 2. Catalog already supports feature-level offline read behavior

Catalog已具備：

- Feature-local SQLite page cache。
- Cache-first與Stale-While-Revalidate initial flow。
- `fresh`／`stale`資料狀態與`lastUpdatedAt`。
- Remote failure時保留可顯示 Cache並產生non-blocking revalidation failure。
- User refresh與background revalidation分離。
- Append cache hit、retention、cursor chain與revision CAS。

ADR-017明確禁止因timeout、DNS或5xx就宣稱裝置確定Offline，也明確拒絕global HTTP cache、generic offline repository與所有feature共用的cache framework。

現有 Catalog 因此是本候選的主要整合對象與驗證場景，但不是整個 App connectivity authority 的擁有者。

### 3. App owns lifecycle observation, but only for local unlock

`ArchitectureApp`已實作`WidgetsBindingObserver`，目前只把background／resume事件交給`LocalUnlockLifecycleCoordinator`。這證明 App composition layer已是 lifecycle owner，但尚未有可讓其他App-level coordinator共享的明確 lifecycle orchestration boundary。

若 Connectivity Foundation加入resume recheck、reconnect refresh或foreground reconciliation，應由 App-owned coordinator接收 lifecycle signal，而不是讓Catalog Page、Bloc或各feature自行註冊`WidgetsBindingObserver`。

### 4. Repository refresh semantics are feature-specific

Catalog的`initial`、`refresh`與`append` load policy已明確：

- Initial可讀Cache並在stale時背景revalidate。
- Refresh強制Remote replacement。
- Append使用retained page或Remote fallback。

目前沒有「重連後自動refresh」規則，也沒有區分以下觸發來源：

- App resume。
- Connectivity由offline轉為online。
- 使用者pull-to-refresh／retry。
- Background revalidation。
- Feature首次進入。

這些觸發若未集中協調，容易產生重複request、舊結果覆蓋、loading UI互相干擾與event storm。

### 5. Auth refresh retry is session-specific, not connectivity retry

Auth refresh interceptor已有concurrent 401 single-flight、安全replay與session generation保護。這是authentication recovery contract，不是一般網路重試策略。

目前沒有通用 exponential backoff、automatic request retry或offline queue。這是合理現況：command API、非冪等request、付款／交易與session mutation不能因Connectivity Foundation而自動重送。

### 6. Error presentation can express network failure but not connectivity state

Presentation已有localized Failure mapping、blocking／non-blocking page state、Catalog cached／stale／revalidation surface。它能呈現「操作失敗」與「目前顯示Cache」，但不能可靠呈現：

- 裝置沒有可用網路介面。
- 有網路介面但尚未確認後端可達。
- Connectivity state仍unknown。
- 已重連但背景refresh尚未完成。

目前若直接從`FailureKind.network`推導全域offline banner，會把TLS、timeout、DNS、server routing與暫時性後端問題誤標為裝置Offline。

### 7. No connectivity dependency or platform adapter exists

Repository dependency scan未發現`connectivity_plus`、`internet_connection_checker`、`network_info_plus`或同類plugin。也沒有App-owned adapter、fake、stream contract、startup snapshot、dispose ownership或platform runtime evidence。

這代表本候選不是既有能力的小修補，而是新增一個穩定的runtime boundary。

## Gap and risk analysis

### P0 gaps

無。Template Baseline 1.9.0沒有宣稱具備全域Connectivity／Offline State Foundation，因此不存在違反current public claim的阻斷缺陷。

### P1 gaps

#### P1-1 No typed connectivity state authority

缺少可供App與Feature依賴的typed state，至少需要區分：

```txt
unknown
offline
online
```

第一版不應增加過多狀態；介面類型、metered、VPN、Wi-Fi名稱或頻寬資訊不屬於必要contract。

#### P1-2 Interface availability and backend reachability are not separated

Connectivity plugin通常只能回答介面可用性，不能保證DNS、TLS、gateway、captive portal或目標backend成功。若把plugin的`online`直接等同API可成功，會形成錯誤的product與retry行為。

第一版需要明確定義：

- Connectivity state是本機網路介面／route訊號。
- Backend reachability只能由實際backend operation或未來獨立health probe判斷。
- 單次API failure不得反向覆蓋全域interface state。

#### P1-3 Lifecycle and reconnect coordination are absent

目前沒有startup snapshot、stream subscription ownership、resume recheck、duplicate event suppression、offline→online transition generation或dispose contract。

如果feature各自監聽plugin，會造成：

- 多重native subscription。
- feature間state不一致。
- resume與reconnect重複refresh。
- navigation離開後仍執行舊feature operation。
- 測試難以控制平台event順序。

#### P1-4 Catalog reconnect behavior is unspecified

Catalog已有SWR與manual refresh，但沒有重連策略。必須拍板：

- 只有目前可見且已載入的Catalog才可在offline→online後revalidate。
- 重連revalidate不得顯示blocking loader。
- fresh data是否跳過重連refresh，或以最小節流／dedupe處理。
- manual refresh優先級是否高於自動revalidate。
- query／generation切換後，舊重連結果不得覆蓋新狀態。

#### P1-5 Retry ownership is unspecified

Connectivity變化可以作為「允許重新嘗試」的signal，但不應自動替所有request重試。第一版需限制為feature明確opt-in的read revalidation，並保留既有Auth refresh與request semantics。

### P2 gaps

- 沒有App-wide offline／reconnecting presentation policy。
- 沒有fake connectivity source與deterministic transition tests。
- 沒有Android／iOS plugin configuration與runtime acceptance evidence。
- 沒有event debounce／distinct／resume race contract。
- 沒有observer failure或stream termination的recovery policy。
- 沒有說明`unknown`在startup、plugin exception與unsupported platform時的處理。
- 沒有跨Feature adoption rule，容易過早抽象成Generic Offline framework。

## Responsibility boundary analysis

### App composition layer

應擁有：

- Connectivity plugin adapter的建立與lifecycle。
- Startup snapshot與native stream subscription。
- Typed connectivity authority／controller。
- App lifecycle resume recheck。
- Offline→online transition coordination。
- Feature opt-in coordinator的組裝。

不應擁有每個feature的cache identity、TTL、query、cursor或refresh replacement語意。

### Connectivity abstraction

應只表達穩定且最小的interface availability contract：

- Current typed state。
- Distinct state changes。
- Refresh／recheck能力。
- Dispose ownership。

不得：

- 宣稱backend一定可達。
- 自動攔截或重送所有Dio request。
- 依賴Catalog、Auth Bloc或UI。
- 保存任意feature command。

### Feature／Repository

Feature應明確opt-in並保留自己的資料策略。Catalog Repository仍擁有Cache、freshness、Remote／Local coordination；Catalog presentation／coordinator只使用connectivity transition決定是否觸發既有revalidation intent。

Feature不得直接監聽platform plugin，也不得從connectivity state推導某次request一定成功。

### API client

維持transport mapping、timeout、auth header與refresh replay責任。第一版不新增global retry interceptor或network-state-aware request queue。

## Candidate approaches

### Approach A — App-owned typed connectivity authority with Catalog opt-in

建立最小provider-neutral contract與單一platform adapter，由App composition與lifecycle owner管理；Catalog作為第一個明確opt-in feature，利用offline→online transition觸發非阻塞revalidation。

優點：責任邊界清楚、可測試、能驗證真實價值，又不把Catalog策略泛化。缺點：需要新增穩定contract、App coordinator、plugin wiring與跨層測試。

### Approach B — Catalog直接監聽connectivity plugin

優點：檔案較少、短期實作快。

缺點：違反App composition ownership，未來每個feature會重複native subscription與transition規則；難以共享resume、dispose與dedupe。不得採用。

### Approach C — Global Dio offline interceptor and automatic retry

優點：表面上所有request立即「支援offline」。

缺點：會誤處理command／非冪等request，把介面狀態等同backend reachability，並與Auth refresh replay衝突。不得採用。

## Recommended scope

建議正式名稱：

```txt
Milestone 28 — Connectivity and Offline State Foundation
```

建議scope：

1. Provider-neutral typed connectivity contract：`unknown`、`offline`、`online`。
2. App-owned platform adapter、startup snapshot、state stream與dispose lifecycle。
3. Interface availability與backend reachability的明確分離。
4. App lifecycle resume recheck與duplicate transition suppression。
5. Feature opt-in reconnect coordination contract。
6. Catalog integration：offline presentation context與offline→online non-blocking revalidation。
7. Manual refresh、background revalidation、resume與reconnect的ordering／dedupe。
8. Fakes、unit／Bloc／widget／integration tests及Android／iOS runtime acceptance。
9. 文件、ADR、README、roadmap與adopter guidance同步。

## Non-goals

- Generic Offline framework、generic repository或global cache interceptor。
- 所有feature自動採用connectivity state。
- Backend health monitoring、continuous ping或可用性SLA。
- Global automatic retry、exponential backoff framework或Dio retry interceptor。
- Offline command queue、transaction outbox、sync engine或conflict resolution。
- 自動重送Login、Refresh Token、OTP、付款、交易或其他command API。
- Metered network、Wi-Fi SSID、VPN、bandwidth或network quality分類。
- Background isolate、OS background fetch或push-triggered sync。
- 將`online`宣稱為API保證成功，或將單次`FailureKind.network`宣稱為裝置確定Offline。

## ADR determination

需要新增ADR。

原因是本候選會新增穩定的cross-feature runtime authority、App lifecycle ownership、platform adapter boundary、interface／backend語意分離，以及feature opt-in reconnect contract。這些規則將影響dependency direction、Composition Root、Feature責任與未來offline adoption，不能只留在implementation plan。

新ADR應：

- 擁有typed connectivity、lifecycle與feature adoption contract。
- 將ADR-017列為Catalog cache／SWR authority，不重寫其cache policy。
- 將ADR-015列為Auth refresh／safe replay authority，不把Connectivity Foundation變成Auth retry owner。
- 將ADR-020列為Failure與error presentation authority。

## Candidate promotion recommendation

建議將Connectivity and Offline State Foundation提升為正式Milestone 28候選並進入Design Spec，但promotion應遵守以下gate：

1. Design Spec先定義state semantics、App ownership、transition ordering、Catalog opt-in與runtime evidence。
2. Spec完成完整Task審查循環並正式通過。
3. Spec通過後才建立Implementation Plan。
4. Plan完成完整Task審查循環並正式通過。
5. Plan通過後才允許修改production source。

本audit本身不等同Milestone 28已核准，也不代表可以直接開始Task 28-1。

## Audit conclusion

Connectivity and Offline State Foundation是合理且有界的下一個正式方向。

成立理由：

1. Catalog已具備成熟feature-local cache／SWR，可作為真實adoption場景。
2. App已有lifecycle ownership先例，但缺少共享connectivity authority。
3. Transport failure分類已存在，可清楚證明「request failure」與「interface state」必須分離。
4. 缺口集中於typed state、App lifecycle、transition coordination與單一feature adoption，不需要先建立大型sync平台。
5. Scope可在不碰command queue、global retry與generic offline framework的前提下完成。

建議採Approach A：App-owned typed connectivity authority，加上Catalog明確opt-in integration。

## Validation performed for this audit

- Git branch、working tree、recent commits與baseline inspection。
- Connectivity dependency scan。
- App lifecycle／composition／DI source inspection。
- Catalog Repository、Bloc、README、ADR與tests inventory inspection。
- Dio transport mapping與Auth refresh retry boundary inspection。
- Roadmap、backlog、current snapshot與Milestone 27 closure routing inspection。

本文件不宣稱已完成platform runtime validation，因為connectivity adapter尚未導入。
