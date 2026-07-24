---
document_type: planning-review
status: accepted
authoritative_for:
  - connectivity-offline-state-design-review
last_reviewed_baseline: 1.9.0
---

# Connectivity and Offline State Foundation Design Review

## Review target

- `docs/superpowers/specs/2026-07-24-connectivity-offline-state-foundation-design.md`
- `docs/audits/connectivity_offline_state_capability_audit.md`
- ADR-015、ADR-017、ADR-020與current App／Catalog boundaries。

## Focused review findings

### F1 — Interface與backend語意可能被混用

Disposition：已在state semantics、presentation、non-goals與acceptance gate重複明確化。`online`只代表interface／route signal；API結果不得反向改寫authority。

### F2 — Reconnect可能複製Catalog cache freshness policy

Disposition：Spec明確禁止Bloc依cache TTL跳過reconnect；Repository繼續擁有freshness。Request storm由transition distinct與operation ordering控制。

### F3 — Startup snapshot與stream race未定義

Disposition：Spec要求先訂閱change stream再讀snapshot，並以distinct state及latest-result保護處理ordering。

### F4 — Manual refresh與reconnect競爭

Disposition：已定義manual refresh最高優先、開始時使reconnect失效、進行中忽略新reconnect、不排隊第二次操作。

### F5 — Generic feature callback registry會過早抽象

Disposition：第一版只建立Catalog窄coordinator；第二個實際adoption出現前不得提升成generic registry。

### F6 — `unknown`可能被UI誤顯示offline

Disposition：App-wide presentation只在`offline`顯示offline surface；`unknown`保持中性。

## Re-review result

上述findings均已在Spec正文中有明確disposition，未發現矛盾、placeholder、未定義核心語意或會阻止Plan建立的問題。

## Whole-task holistic review

- Goals與non-goals有界。
- App-only Composition Root與Feature First邊界維持。
- ADR-017 cache authority、ADR-015 Auth retry authority及ADR-020 Failure authority未被重寫。
- Task 28-1～28-8具可獨立review與commit的交付邊界。
- Runtime evidence不以unit test替代。

## Documentation governance and authority

- Capability audit擁有現況盤點與candidate evidence。
- Design Spec擁有Milestone 28已核准設計。
- 後續ADR擁有穩定architecture contract。
- Implementation Plan只擁有執行順序，不取代Spec。

## Validation

- Placeholder scan：0。
- Open P0：0。
- Open P1 without disposition：0。
- Design status：Accepted。

## Conclusion

Design Spec通過完整Task審查循環，可以進入Implementation Plan；此結論不代表production implementation已開始或Milestone 28已完成。
