---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-25-ios-simulator-core-runtime-smoke
last_reviewed_baseline: 1.6.1
---

# Milestone 25-5 — Simulator Core Runtime Smoke Review

## Scope

本Task在實際iOS Simulator上驗證App bootstrap、Route Guard、Mock Login、Profile、Catalog、search、SQLite cache、Logout preservation與Theme／Locale／local-unlock preference persistence。

Security plugin、biometric challenge、Keychain lifecycle與background／resume prompt ownership不在本Task宣稱範圍，留待Task 25-6。

## Runtime Harness

新增Flutter官方`integration_test` SDK dependency與：

```txt
apps/flutter_architecture/integration_test/core_runtime_smoke_test.dart
```

測試直接在iPhone 17 Pro Simulator執行development／Mock composition root，不使用mock platform channel替代iOS runtime。

## TDD Evidence

初次device execution依序正確暴露：

1. Simulator尚未boot，Flutter找不到指定UDID。
2. Simulator boot後，repository缺少`integration_test` SDK dependency。
3. Dependency補齊後，integration test檔案尚未正式落入repository。

上述harness缺口補正後，測試進入App runtime。第一次完整flow在返回ProtectedPage時失敗，根因是`WidgetTester.pageBack()`只尋找Cupertino back button，而頁面使用Material Navigator；改由ProtectedPage context呼叫`Navigator.pop()`後，同一完整flow轉為GREEN。

## Verified Flow

Simulator device：

```txt
iPhone 17 Pro
UDID: 0747B0FD-BE11-40D3-8C24-6003160C3FEB
Runtime: iOS 26.5
```

實際驗證順序：

```txt
bootstrap
→ unauthenticated LoginPage
→ Protected action被Route Guard阻擋並維持LoginPage
→ Mock Login
→ authenticated ProfilePage
→ Catalog initial load
→ catalog-001存在
→ search SQLite
→ catalog-011存在且catalog-001被過濾
→ Profile
→ ProtectedPage通過Route Guard
→ 返回Profile
→ Logout
→ LoginPage
```

## SQLite Evidence

測試直接讀取iOS runtime註冊的`sqflite` Database：

```txt
PRAGMA foreign_keys = 1
catalog_cache_page count > 0
catalog_cache_page_item count > 0
```

上述count在Logout完成後檢查，證明Catalog cache依既有contract保留，而非被Auth cleanup誤刪。

## Preference Persistence Evidence

在runtime中寫入：

```txt
theme: ocean
theme mode: dark
locale: zh_TW
local unlock preference: enabled
```

之後對native SharedPreferences執行`reload()`，並以新的ThemeController、LocaleController與LocalUnlockPreferenceStore read重新建構狀態。結果全部還原為上述值，證明不是僅存在於原controller memory。

## Main App Relaunch Evidence

使用repository-ownedbuild script重新建立正式verification app：

```bash
bash tools/ci/build_ios_simulator.sh
```

接著執行：

```txt
simctl install
simctl launch → PID 41817
simctl terminate
simctl launch → PID 41830
```

兩次launch皆成功。App identity：

```txt
CFBundleDisplayName: Flutter Architecture
CFBundleIdentifier: com.example.flutterarchitecture
```

第一次launch與relaunch均擷取Simulator screenshot到temporary evidence path；screenshots不納入repository，也不包含credential或token內容。

## Review Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M25-5-R01 Repository沒有可在實際device執行的integration harness | P1 | 加入Flutter官方`integration_test` dependency與core runtime smoke |
| M25-5-R02 Simulator初次未boot | P2 | 明確`simctl boot`並等待`bootstatus -b` |
| M25-5-R03 `pageBack()`錯誤假設Cupertino back button | P2 | 使用ProtectedPage Navigator context返回，不修改產品route |
| M25-5-R04 `flutter test`完成後test app會卸載，無法由外部simctl保留其container | P2 | persistence在device test內透過native storage reload／controller reconstruction驗證；main app另做install／terminate／relaunch |
| M25-5-R05 Keychain與biometric仍未做runtime lifecycle驗證 | P1 planned | 明確保留給Task 25-6，不在本Task宣稱通過 |

Open P0／P1 without disposition：0。

## Verification

- iOS Simulator integration test：通過。
- Core runtime flow、Route Guard、Mock Login、Profile、Catalog與search：通過。
- SQLite foreign keys、cache rows與Logout preservation：通過。
- Theme／Locale／local-unlock native preference reload：通過。
- Main verification app install／launch／terminate／relaunch：通過。
- Repository iOS clean build script：通過。

## Review Decision

Task 25-5通過。下一步是Task 25-6 Security Plugin and Lifecycle Smoke。
