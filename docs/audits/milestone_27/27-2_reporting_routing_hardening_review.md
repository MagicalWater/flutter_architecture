---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-27-task-27-2-reporting-routing-hardening-review
last_reviewed_baseline: 1.8.0
---

# Task 27-2 — Reporting Routing Hardening Review

## Scope

本Review涵蓋provider-neutral error routing、closed metadata、recursive failure guard、process-local degraded rate limiter、typed startup／navigation breadcrumbs及既有event-loop deduplication ownership。

## Findings and fixes

### P1 — Provider callback可能形成recursive reporting

以`ErrorReportingRouter`的同步re-entry guard隔離delegate callback；delegate自身失敗亦由router吸收，不改變原始App flow。

### P1 — Degraded burst可能放大重複operational failure

以`ErrorReportSource + ErrorReportOperation`作為process-local key限制burst；key不包含error message、payload、request或response內容。

### P1 — Provider metadata缺少封閉轉換authority

新增`ErrorReportMetadata.fromReport`，只轉換severity、source、operation與error runtime type，不接受任意Map或文字欄位。

### P2 — Breadcrumb API可能成為任意文字外洩通道

新增typed startup與navigation enums；breadcrumb只輸出category與event enum name，sink失敗不向外拋出。

## Regression review

- Fatal與unexpected不受degraded limiter影響。
- Expected operational failures仍只由明確local adapter以degraded上報，沒有新增global Failure捕捉。
- 既有`ErrorReportDeduplicator`未搬移，仍擁有同event-loop error＋stack identity deduplication。
- Sensitive fixtures未進metadata、breadcrumb或safe diagnostic。
- Firebase、Crashlytics、Sentry dependency仍為零。

## Disposition

```txt
ACCEPTED AFTER FIX
Open P0: 0
Open P1: 0
Open P2: 0
```

下一步為Task 27-3 — Firebase Crashlytics Reference Adapter。
