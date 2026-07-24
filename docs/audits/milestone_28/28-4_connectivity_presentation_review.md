---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-28-task-28-4-review
last_reviewed_baseline: 1.9.0
---

# Task 28-4 — App-wide Connectivity Presentation Review

## Scope

- ConnectivityScope。
- App-wide non-blocking offline banner。
- English／zh_TW localization與responsive widget tests。

## Findings and disposition

### F1 — unknown可能被誤顯示為offline

Disposition：banner只在typed state等於`offline`時出現；unknown與online都有回歸測試。

### F2 — Banner可能遮蔽或取代route content

Disposition：banner使用Column＋Expanded保留完整route child，不建立modal或blocking interaction。

### F3 — 大字與窄畫面可能overflow

Disposition：copy放在Expanded Text，320px與2x text scale widget test確認無例外。

### F4 — Controller dispose等待presentation listener可能卡住

Disposition：native subscription與adapter仍await完整釋放；對外broadcast stream採non-blocking close，避免widget teardown ordering讓App dispose永久等待。

## Holistic result

- UI只依App-owned typed state，不讀Failure或plugin type。
- Offline context不宣稱backend狀態。
- Theme與locale仍由原App composition持有。

## Validation

```txt
Banner widget tests: pass
Localization generation/tests: pass
Analyze: pass
Open P0: 0
Open P1 without disposition: 0
```

Task 28-4 accepted，可進入Task 28-5。
