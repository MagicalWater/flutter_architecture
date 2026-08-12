# Test Authoring Decision

## 核心原則

新增tests由risk／invariant／failure mode驅動，不由Task數、class數、architecture layer數或coverage percentage驅動。

固定順序：

```txt
changed observable behavior / risk
→ existing owner是否已直接覆蓋
→ authoring disposition
→ 若新增test，選最接近failure source的單一primary owner
→ 再由validation_planner決定本Task要執行哪些validation
```

## Dispositions

### Required

只要新增或改變下列可回歸風險，必須建立或明確指出direct regression owner：

- business invariant、金額／計價／權限等決策規則；
- security／authorization／credential lifecycle；
- persistence write、migration、destructive operation；
- concurrency、race、stale completion、ordering；
- retry、idempotency、deduplication；
- pagination／cursor／state machine；
- 非平凡validation、protocol mapping或failure classification；
- deterministic bug fix，且可建立可靠regression test。

### Recommended

有實質observable branch或maintenance value，但風險未達Required，例如：

- 多分支Bloc／state transition；
- feature-specific interaction、navigation branch或accessibility behavior；
- 非平凡mapper／cache policy／cross-feature coordination。

只有當預期regression detection value高於fixture／mock／maintenance成本時才新增。

### no-new-test justified

允許新增0個test，但Task evidence必須記錄reason，且至少符合一項：

- 沒有新增failure mode或business invariant；
- existing owner已直接覆蓋相同observable behavior；
- mutation只是presentation-only copy／style、trivial forwarding或framework-generated wiring，且既有boundary validation足以驗證。

此disposition不跳過`validation_planner.py`，也不能套用到沒有direct owner的Required風險。

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

Template foundation tests常承擔security、migration、CI fail-safe、platform、architecture與shared infrastructure contract，因此test density可以很高。Auth／Catalog／Profile等reference feature可用來理解architecture與owner boundary，但**不是產品Feature的test-density quota**。

普通產品Feature只依自己的risk／failure modes決定tests；不得用reference feature的test file／case數作最低門檻。
