# Milestone 18-3 — Persistence & Database Audit

## 狀態

Reviewed / Closed；尚未進入 remediation。

本文件保存schema、migration、persistence ownership、transaction、corruption recovery與test evidence。所有正式finding的唯一Single Source of Truth為`docs/audits/milestone_18/findings.md`。

---

## 1. Persistence inventory

### SharedPreferences

| Key | Owner | Contract |
|---|---|---|
| `auth.tokens` | `packages/auth` | 單一JSON token pair，包含access / refresh token與expiry |
| `auth.accessToken` | `packages/auth` | legacy key，只在read / clear時清理 |
| `app.theme.preference` | App Theme | Version 1完整snapshot |
| `app.locale.preference` | App Localization | Version 1完整snapshot |

### SQLite

Database：`flutter_architecture.db`

Current schema version：`4`

Tables：

```txt
auth_user
catalog_cache_page
catalog_cache_page_item
```

Ownership：

- App擁有database factory、path、schema version與migration入口。
- `packages/auth`擁有`auth_user`讀寫語意。
- Catalog feature擁有cache page / item讀寫、chain revision與corruption recovery。

---

## 2. Schema與migration

Version history：

```txt
v1  auth_user
v2  catalog cache tables
v3  item_position unique index
v4  chain_revision
```

`onUpgrade`可由v1、v2、v3逐步升至v4。Migration tests已覆蓋v1 → current、v2 → v3與v3 → v4。模板目前未宣告database downgrade支援，判定合理。

Catalog page以`query + request_cursor + request_limit`為identity；item另以`item_id`及unique `item_position`約束同一page。

Item table宣告composite foreign key及`ON DELETE CASCADE`，但production `openDatabase()`沒有`onConfigure`執行`PRAGMA foreign_keys = ON`。正式記錄為`M18-P02`。

目前Catalog production code在已知delete / replacement path先明確刪除item，再刪除page，未發現現行流程已產生orphan row的證據；問題是schema宣告與runtime enforcement不一致。

Review補充：之後啟用`PRAGMA foreign_keys = ON`只會約束後續操作，不會自動修復既有orphan rows。若Gate核准啟用constraint，remediation還必須決定upgrade時的orphan cleanup / rejection策略，並驗證fresh install與upgrade connection都使用相同configuration。

---

## 3. Auth persistence consistency

Auth state分為：

```txt
SharedPreferences auth.tokens
SQLite auth_user
runtime SessionManager
```

Login在remote成功後，透過`AuthStateMutationCoordinator`依序保存token、保存user，再建立runtime Session。User save失敗會best-effort清除token與user，並清除Session。

Restore讀取token與user；任一缺少時清理兩者並視為未登入。Logout會嘗試清除user與token，無論local cleanup是否失敗都清除runtime Session。

### Multi-row auth_user risk

`auth_user`以user ID為primary key，因此可保存多個不同user。`saveUser()`的replace只會替換相同ID；不同帳號登入會新增另一列。

`readUser()`對整張table執行無排序`limit: 1`，沒有與token payload的identity關聯。一次合法的sequential account switch即可留下多列，restart後可能把目前token pair與任意舊user建立Session。

正式記錄為`M18-P01`。這個問題不依賴18-2的並行Login finding。

Review確認修正不能只約束未來`saveUser()`。既有安裝可能已保存多個`auth_user` rows，因此Phase B remediation必須同時處理future writes、existing persisted rows與restore-time identity validation。只加入`ORDER BY`無法證明選出的row與token pair屬於同一user，不構成有效修正。

### Split-store atomicity

SharedPreferences與SQLite無法共享transaction。現有Repository以ordered commit、compensation cleanup與runtime Session最後建立降低partial state風險。

Tests已覆蓋user save failure、cleanup failure、corrupted token與logout partial failure。除了`M18-P01`的identity問題外，不另建立generic atomicity finding。

---

## 4. Catalog transaction與chain integrity

Catalog第一頁replacement、append conditional write、page deletion與chain cleanup均使用SQLite transaction。

主要guard：

- 第一頁replacement增加chain revision並失效後續pages。
- Append只在requested cursor仍由目前chain指向時寫入。
- Expected revision不一致時拒絕late append。
- Persisted cursor self-loop、cycle、invalid position或invalid type觸發page / chain cleanup。
- Replacement transaction失敗時保留原page。
- Cache localStorage failure可降級為remote success，但先送typed diagnostic。

Tests已覆蓋transaction rollback、late append、same cursor reuse、revision corruption、position uniqueness、expired / corrupted cleanup與query / cursor / limit identity隔離。

結論：Catalog persistence correctness具備強constraint、transaction與test evidence；除foreign key runtime enforcement外不建立新finding。

---

## 5. Database factory與platform boundary

Conditional initializer：

- Android / iOS使用sqflite native factory。
- Windows / Linux / macOS使用`sqflite_common_ffi`。
- Web使用`sqflite_common_ffi_web`。

App在DI建立Database前呼叫`initializeDatabaseFactory()`。目前Windows host的FFI database tests可作host runtime evidence；其他platform build與runtime capability留到18-4。

Database connection集中於App Composition Root，沒有feature自行open第二個database。

---

## 6. Test evidence與coverage gaps

Existing evidence：

- v1 / v2 / v3 migration到current。
- Catalog page / item round-trip、identity、transaction rollback與corruption cleanup。
- Auth login compensation、restore corruption、logout partial cleanup。
- Logout保留public Catalog cache。
- DI graph建立SharedPreferences與Database dependency。

Coverage gaps：

- 沒有不同user依序Login後restore的persistence test；對應`M18-P01`。
- 沒有production database connection的foreign key enablement test；對應`M18-P02`。
- 沒有既有DB包含多個`auth_user` rows時的upgrade / restore test；對應`M18-P01`。
- 沒有既有orphan Catalog rows在foreign key remediation後的upgrade behavior test；對應`M18-P02`。
- 沒有fresh install schema snapshot test一次驗證所有table、必要columns、indexes、schema version、pragma與single-active-user contract；18-5應納入baseline matrix。

---

## 7. Review conclusion

18-3 review確認：

- `M18-P01`成立並維持P1；remediation必須涵蓋future writes、existing rows與restore identity validation。
- `M18-P02`成立並維持P2；啟用foreign key時必須處理existing orphan rows，不能只加入pragma。
- Split-store best-effort consistency與Catalog transaction / chain guard不新增finding。
- Fresh install schema snapshot與production-style connection verification交由18-5 test matrix彙總。

---

## 8. 18-3 conclusion

Persistence foundation整體具備明確ownership、migration與Catalog transaction guard，但有兩項正式finding：

```txt
M18-P01 — auth_user允許多列且restore讀取任意一列，可能造成token-user identity mismatch
M18-P02 — Catalog foreign key宣告未在production connection啟用
```

本階段只完成audit與落檔，不修改production code。Findings需等18-6C Audit Review Gate統一決定remediation。
