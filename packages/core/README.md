---
document_type: package-readme
status: accepted
authoritative_for:
  - core-package-local-contract
last_reviewed_baseline: 1.27.0
---

# Core Package

`core` 提供跨 package 共用、與 Flutter UI 及外部 transport 無關的基礎 contract。

## Responsibilities

- `Result` success／failure composition。
- `Failure` typed application failure。
- `AppException` infrastructure／application exception contract。
- `AppExceptionMapper` boundary mapping helper。

## Non-responsibilities

- 不定義 Feature entity、Bloc、Router 或 Widget。
- 不持有 Dio、SQLite、SharedPreferences 或 Flutter plugin implementation。
- 不決定 user-facing localized message。
- 不擁有 App error reporter adapter；App Composition Root 決定 reporting implementation。

## Error Boundary

```txt
Infrastructure / Transport exception
  ↓
AppException
  ↓
Repository boundary
  ↓
Failure
  ↓
Presentation maps to localized UI
```

Expected error 轉為 typed failure；unknown error 必須保留 caught error identity 與 stack，交由既有 unexpected reporting flow 處理，不應被轉成模糊成功或吞掉。

`Failure.message` 是 diagnostic context，不是直接顯示給使用者的 localization authority。

Error code 使用明確欄位表達來源語意：backend code、HTTP status 與 diagnostic code 不合併成單一 generic `code`。

## Public API

唯一 public barrel：

```dart
import 'package:core/core.dart';
```

目前 export：

- `AppException`
- `AppExceptionMapper`
- `Failure`
- `Result`

Consumer 不應 deep import `lib/src/`。

## Dependency Rule

此 package 使用 constructor injection 與純 Dart contracts，不依賴 GetIt／Injectable，也不提供 App lifecycle registration。

`AppException → Failure` mapping 不接受 transport cancellation；cancellation 是 control flow，必須保留原始 exception identity 與 stack，交由擁有 operation 語意的 boundary 處理。

## Tests

只保留高風險 contract test；目前固定 cancellation 不得被 generic mapper 降級成普通 `Failure`。

## Related Decisions

架構 authority 位於 `docs/adr/README.md` 中的 ADR-001、012與020。
