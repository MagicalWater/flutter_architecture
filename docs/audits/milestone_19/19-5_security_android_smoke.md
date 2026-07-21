# Milestone 19-5 Security Review與Android Smoke Evidence

## Task 1 — Security surface inventory與secret regression

### Scope

本階段只審查credential-bearing output surface，不修改Auth runtime authority、migration、refresh或cleanup語意。

盤點範圍：

- `StoredAuthTokens`與`AuthCredentialReadResult`。
- `AuthCredentialMigrationResult`與`AuthLifecycleDiagnostic`。
- `AuthLifecycleCleanupResult`。
- Secure Storage adapter mapped `AppException`。
- `AuthMigrationErrorReporterAdapter`建立的`ErrorReport`與safe context。
- Production `print`、`debugPrint`、`developer.log`、Dio logger與Bloc observer使用點。

### Unified sentinels

Task 1使用以下固定synthetic sentinels建立一致回歸證據：

```txt
M19_ACCESS_SECRET_7f4a
M19_REFRESH_SECRET_2c91
M19_PASSWORD_SECRET_11de
M19_PLUGIN_SECRET_a63b
```

測試只驗證一般字串輸出不包含sentinel；原始error identity與caught stack仍依Decision 020保留於typed欄位，不將unknown error降級。

### Initial source inventory

- Production Auth model與migration／lifecycle result已有自訂或Object預設的secret-safe `toString()`。
- `ErrorReport.toString()`只輸出error runtime type、severity與typed context，不展開error或stack。
- `DebugErrorReporter`不呼叫`error.toString()`。
- 未發現production `LogInterceptor`、Authorization header、Token Pair或password被直接輸出。
- 既有測試已有分散的secret regressions；Task 1新增統一sentinel覆蓋19-1至19-4新增surface。

### Verification

執行結果：

- Auth targeted：51項通過。
- App Secure adapter／reporter targeted：31項通過。
- 五個workspace package analyze全數通過。
- `dart format`無額外修改。

新增統一sentinel regressions全部直接通過，表示既有production `toString()`、mapped `AppException`與`ErrorReport`已符合secret-safe契約，不需要修改production code。

Task 1 implementation review：通過。

- `StoredAuthTokens`、credential read result、migration result、lifecycle diagnostic、cleanup result、Secure adapter mapped error與App report context均不展開sentinel。
- 原始error identity與caught stack仍保留於typed欄位；沒有將unknown error降級。
- 沒有新增平行redaction framework或跨package dependency。
- Production source scan未發現Token Pair、Authorization、password或raw payload直接輸出。
