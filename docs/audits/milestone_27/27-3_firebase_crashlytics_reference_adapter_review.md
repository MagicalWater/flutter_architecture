---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-27-task-27-3-review
last_reviewed_baseline: 1.8.0
---

# Task 27-3 — Firebase Crashlytics Reference Adapter Review

## Scope

本階段只在App integration boundary導入`firebase_core`與`firebase_crashlytics`，建立provider SDK gateway、initializer、collection policy映射、Crashlytics `ErrorReporter` adapter與provider unavailable local fallback。未導入Firebase Analytics、Sentry、native environment config或symbol upload。

## Findings and fixes

- P1：SDK Future失敗若只用同步`try/catch`會逸出。修正為async gateway contract，adapter以fire-and-forget呼叫內部受保護Future並吸收provider failure。
- P1：Firebase初始化失敗時若仍切換remote reporter，後續事件會持續打到不可用provider。修正為先經`ObservabilityProviderLifecycle`，只有available才選用Crashlytics adapter，否則保留local fallback。
- P1：Provider config存在時可能依SDK預設自動收集。修正為Firebase初始化後必定呼叫`setCrashlyticsCollectionEnabled`，值只來自App-owned policy。
- P2：Privacy contract要求anonymous-by-default。Adapter沒有呼叫`setUserIdentifier`，測試固定此行為。

## Contract review

- Fatal映射為`recordError(..., fatal: true)`；unexpected/degraded映射為non-fatal。
- Custom keys只來自Task 27-2 closed metadata conversion，不接受任意Map context。
- Error與stack identity原樣傳入provider；safe keys不包含error message、token或OTP fixture。
- Adapter、initializer與composition都位於App scope；reusable package沒有Firebase dependency。
- Google Analytics沒有加入dependency，typed breadcrumbs仍由App-owned contract持有。
- Native Firebase config、Gradle plugin、dSYM/mapping與remote backend verification仍屬Task 27-4～27-6。

## Disposition

ACCEPTED AFTER FIX。

Open P0：0。Open P1：0。Open P2：0。
