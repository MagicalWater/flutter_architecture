# Test Authoring & Retention Decision

## 核心原則

建立與永久保留tests都由risk／invariant／failure mode驅動，不由Task數、class數、architecture layer數、coverage percentage或既有coverage topology驅動。Test可以是一次性驗證工具；建立後不天然取得永久repository ownership。

固定順序：

```txt
changed observable behavior / risk
→ existing owner是否已直接覆蓋
→ authoring disposition
→ 若新增test，先視為temporary evidence並選最接近failure source的單一primary owner
→ implementation GREEN
→ retention disposition
→ 再由validation_planner決定本Task要執行哪些validation
```

## Dispositions

### Required

只要新增或改變下列高成本、難以人工穩定發現的可回歸風險，必須建立或明確指出direct regression owner：

- business invariant、金額／計價／權限等決策規則；
- security／authorization／credential lifecycle；
- persistence write、migration、destructive operation；
- concurrency、race、stale completion、ordering；
- retry、idempotency、deduplication；
- 會造成資料遺失、重複處理或錯序的pagination／cursor／state machine；
- 非平凡validation、protocol mapping或failure classification；
- deterministic bug fix只有在failure成本、再發機率與automation長期價值足以支持永久owner時才屬Required；普通UI／copy／style／wiring bug可以temporary RED後刪除。

### Recommended

有實質observable branch或maintenance value，但風險未達Required時，可以在change期間建立temporary test，例如：

- 多分支Bloc／state transition；
- feature-specific interaction、navigation branch或accessibility behavior；
- 非平凡mapper／cache policy／cross-feature coordination。

只有當預期驗證價值高於fixture／mock／maintenance成本時才新增；`Recommended`不代表永久保留。

### no-new-test justified

允許新增0個test，但Task evidence必須記錄reason，且至少符合一項：

- 沒有新增failure mode或business invariant；
- existing owner已直接覆蓋相同observable behavior；
- mutation只是presentation-only copy／style、trivial forwarding或framework-generated wiring，且既有boundary validation足以驗證。

此disposition不跳過必要validation，也不能套用到沒有direct owner的Required critical risk。

### Should-not-add

下列tests預設不應建立：

- getter／setter或語言本身行為；
- 只驗證passthrough UseCase「repository method called once」，且沒有policy／mapping／branch；
- framework已保證的behavior；
- 為了Domain／Data／Bloc／Widget每層都有test而重複同一invariant；
- 只因新增class就建立同名test file；
- 每個畫面機械式新增golden；
- 只為達到coverage percentage或case count quota而新增test；
- mock implementation detail而非observable contract。

## Foundation 與 Product Feature

Foundation沒有test-density豁免。Template foundation確實更可能包含security、migration、CI fail-safe、platform或shared infrastructure critical risk，但每個永久test仍必須逐一證明長期failure-protection價值。Auth／Catalog／Profile等reference feature只可用來理解architecture與owner boundary，不能作任何test-density保留理由。

普通產品Feature只依自己的risk／failure modes決定tests；不得用reference feature的test file／case數作最低門檻。

## Retention Dispositions

每個本次新增或修改的test在Task closure前必須有Retention Decision：

- `Retain permanently`：critical failure protection，且automation長期價值高於maintenance成本。
- `Merge into critical owner`：failure protection值得保留，但existing/new test矩陣過度細碎。
- `Convert to smoke`：只需要一個高價值boundary/runtime check，不保留細部matrix。
- `Delete temporary evidence`：RED／debug／acceptance價值已完成，永久repository ownership不成立。

永久保留通常需同時具備：failure成本高、人工難穩定發現、合理再發機率、deterministic、訊號可定位、沒有更便宜owner、maintenance成本合理。

以下預設`Delete temporary evidence`或`Should-not-add`：ordinary widget/page/dialog rendering、copy/style/theme/locale matrix、普通responsive/layout、framework behavior、getter/forwarding/passthrough、DI/source shape、class/file ownership、architecture/docs/Skill prose contract、mechanical golden、reference feature completeness、普通UI bug regression。

## Existing Test Deletion

Existing coverage不享有preservation priority：

```txt
critical protection still required
→ replacement / merged critical owner evidence required

low-value protection intentionally retired
→ replacement = NONE is valid
```

刪除低價值test不要求先補另一個test。合法reason包含temporary validation completed、cheaply observable、duplicate、framework-owned、prose/static-source contract、style/copy/visual-only、maintenance cost exceeds detection value與historical regression no longer valuable。
