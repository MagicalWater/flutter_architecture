---
document_type: phase-review
status: accepted
authoritative_for:
  - template-baseline-1-14-audit-future-direction-disposition-evidence
last_reviewed_baseline: 1.14.0
---

# A8 — Future Direction and Candidate Disposition

## Decision Rule

方向只有在同時具備以下條件時，才建議提升為下一個正式Milestone：

```txt
confirmed gap
stable boundary
reproducible failure or adoption blocker
template-level reusable value
testable acceptance criteria
reasonable implementation and maintenance cost
```

「生態系可做到」、「已有dependency」或「未來可能用到」均不足以promotion。每個方向使用：Promote candidate、Keep candidate、Keep deferred、Return backlog、Reject。

## Additional Platform Support

### Web

- Problem evidence：目前只有3個tracked Web files、Drift Wasm／worker與explicit reset static tests；沒有tracked Web build gate、deployment runtime或plugin acceptance。
- Template-level value：高。Web可擴大同一Clean Architecture／Feature模板的採用範圍。
- Product-specific risk：Storage、auth plugin、URL routing、browser lifecycle、observability與deployment policy會受產品影響。
- Existing foundation：Conditional database opener、tracked assets、dependency-ready classification。
- Missing prerequisite：正式runner／build、plugin matrix、browser runtime smoke、storage upgrade／reset acceptance、artifact與deployment boundary。
- Maintenance cost：中高；需持續跟進Flutter Web、Wasm、browser與plugin compatibility。
- Security／privacy／platform impact：Secure storage、biometric不可直接沿用mobile claim；browser threat與storage policy需重定義。
- Recommended disposition：**Keep candidate**，但不得與Desktop綁成單一Milestone。
- Re-evaluation trigger：出現第一個明確Web採用產品、tracked Web build failure或使用者核准Web Supported目標。

### Windows

- Problem evidence：Windows是主要manual-local host，但App沒有tracked Windows runner、artifact或runtime evidence。
- Template-level value：中高；對Flutter企業桌面產品具有可重用價值。
- Product-specific risk：Credential storage、biometric替代、window lifecycle、installer與enterprise distribution差異大。
- Existing foundation：Dart／package architecture與部分conditional dependencies可重用。
- Missing prerequisite：Runner scaffold、plugin support matrix、database path、native identity、build artifact、runtime smoke與distribution disposition。
- Maintenance cost：中高；需維護Windows runner與native plugins。
- Security／privacy／platform impact：不能把mobile secure storage／biometric claim直接投影到Windows。
- Recommended disposition：**Keep candidate**。
- Re-evaluation trigger：出現具體Windows產品需求或需要Windows App作為template正式驗收面。

### macOS

- Problem evidence：Mac是CI host與iOS golden authority，但沒有tracked macOS App runner；host能力常被誤認為App support。
- Template-level value：中，但與iOS共享Darwin foundation。
- Product-specific risk：Sandbox、Keychain、window lifecycle、notarization與Mac App Store責任不同於iOS。
- Existing foundation：Mac toolchain、Darwin dependencies、iOS native knowledge。
- Missing prerequisite：macOS runner、sandbox／entitlement contract、build／runtime、artifact、signing／notarization disposition。
- Maintenance cost：中高。
- Security／privacy／platform impact：Keychain與biometric／user-presence需獨立runtime evidence。
- Recommended disposition：**Return backlog**；不維持與Web／Windows同等candidate優先度。
- Re-evaluation trigger：第一個macOS產品需求或可重用Darwin App blocker出現。

### Linux

- Problem evidence：沒有runner、artifact、runtime或明確產品需求。
- Template-level value：中低；對目前mobile-first模板的直接採用價值尚未證實。
- Product-specific risk：Secret storage、desktop integration、packaging與distribution高度環境化。
- Existing foundation：Pure Dart packages與Clean Architecture可重用。
- Missing prerequisite：完整runner、plugin／native dependency、packaging、runtime與support owner。
- Maintenance cost：高，相對目前價值不足。
- Security／privacy／platform impact：Credential storage與distribution需全新boundary。
- Recommended disposition：**Return backlog**。
- Re-evaluation trigger：有具體Linux產品、kiosk或enterprise desktop需求。

## Application and Integration Directions

### WebSocket example

- Problem evidence：Current API use cases沒有realtime requirement或可重現HTTP boundary failure。
- Template-level value：中；connection lifecycle、reconnect與message ordering具重用價值。
- Product-specific risk：Protocol、auth、backpressure、offline queue與delivery semantics高度業務化。
- Existing foundation：Dio／Auth session、Connectivity authority、Failure／Reporting。
- Missing prerequisite：具體realtime scenario、message contract、foreground／background policy與acceptance server。
- Maintenance cost：中高。
- Security／privacy／platform impact：Token rotation、message redaction與replay semantics需新Decision。
- Recommended disposition：**Keep deferred**。
- Re-evaluation trigger：產品確認chat、market data、live tracking等具體realtime flow。

### Notification

- Problem evidence：沒有產品notification use case、provider或permission UX blocker。
- Template-level value：中，但remote push、local notification、deep link與background execution需拆分。
- Product-specific risk：Provider、payload、consent、channel、quiet hours與routing高度產品化。
- Existing foundation：Environment identity、router、observability與platform runners。
- Missing prerequisite：具體notification type、permission／privacy policy、provider、routing與test strategy。
- Maintenance cost：高，跨Android／iOS native lifecycle。
- Security／privacy／platform impact：Push token、payload PII、deep-link authorization與provider retention。
- Recommended disposition：**Keep deferred**。
- Re-evaluation trigger：正式產品需求及provider／payload contract確定。

### Payment

- Problem evidence：沒有交易、商品、receipt、backend ledger或Store purchase requirement。
- Template-level value：低；generic payment feature容易形成錯誤抽象。
- Product-specific risk：支付供應商、地區、退款、稅務、風控、PCI、Store IAP與server verification完全不同。
- Existing foundation：Result／Failure、Auth、API client不足以定義payment domain。
- Missing prerequisite：幾乎全部產品／法規／backend contract。
- Maintenance cost：極高且風險高。
- Security／privacy／platform impact：Financial data、compliance、receipt verification與fraud handling。
- Recommended disposition：**Reject**作為generic template方向；具體產品需要時由product feature重新Requirement Decision。
- Re-evaluation trigger：不以template roadmap重新提出；只在具名產品與支付模型確定後另案。

### Analytics／Event Governance

- Problem evidence：Observability已明確排除business analytics；目前沒有event taxonomy、consumer或產品KPI blocker。
- Template-level value：中；typed event governance可重用，但事件內容本質產品化。
- Product-specific risk：Taxonomy、PII、consent、retention、sampling、provider與data warehouse ownership。
- Existing foundation：Provider-neutral observability、environment identity、privacy allowlist思維。
- Missing prerequisite：具體business questions、event owner、schema evolution與privacy policy。
- Maintenance cost：中高；若無consumer容易形成無用事件框架。
- Security／privacy／platform impact：高，且不得與Crash reporting混用。
- Recommended disposition：**Keep deferred**。
- Re-evaluation trigger：有具體產品KPI、event consumers與privacy owner。

## Release and Security Directions

### Production signing／Store distribution

- Problem evidence：Current Android／iOS artifacts只屬verification，沒有產品credential、Store account或promotion requirement。
- Template-level value：中高；安全流程可提供範本，但credential與account owner不能由template提供。
- Product-specific risk：Keystore、Apple Team、provisioning、Play Console、App Store Connect、release channels與rollback。
- Existing foundation：Environment identity、verification builds、CI execution modes、managed artifacts與secret boundary。
- Missing prerequisite：已採用產品identity、account owner、protected environment、signing material lifecycle與distribution target。
- Maintenance cost：高；受Store與platform政策影響。
- Security／privacy／platform impact：Critical secret handling與不可逆release責任。
- Recommended disposition：**Keep deferred**，作為產品採用後的獨立release initiative，不是空白template下一Milestone。
- Re-evaluation trigger：某個具體產品完成identity adoption並要求TestFlight／Play internal testing或正式發布。

### Cryptographic Device Binding

- Problem evidence：Current local biometric只做user presence；沒有server要求device-bound session。
- Template-level value：中低至中，取決於高風險產品。
- Product-specific risk：Key attestation、device replacement、recovery、server registry與fraud policy高度產品化。
- Existing foundation：Secure credential、Auth lifecycle、local presence與API client。
- Missing prerequisite：Threat model、server challenge／registry、platform key／attestation strategy與recovery UX。
- Maintenance cost：高。
- Security／privacy／platform impact：高；錯誤設計可能鎖死帳號或建立虛假安全感。
- Recommended disposition：**Keep deferred**。
- Re-evaluation trigger：金融／高風險產品具體要求device-bound credential及server support。

### Passkey

- Problem evidence：沒有relying party、WebAuthn backend或passwordless產品需求。
- Template-level value：中，但必須有server與account recovery共同設計。
- Product-specific risk：Credential registration、cross-device sync、fallback、account recovery與platform availability。
- Existing foundation：Auth package boundary與OTP／Session lifecycle可提供部分模式。
- Missing prerequisite：Relying-party contract、server challenge、credential lifecycle、recovery與platform acceptance。
- Maintenance cost：中高。
- Security／privacy／platform impact：高；不能由local_auth或Keychain presence替代。
- Recommended disposition：**Keep deferred**。
- Re-evaluation trigger：具體產品與backend採用FIDO／WebAuthn並完成recovery決策。

## Candidate Portfolio Proposal

```txt
Keep candidate:
  - Web
  - Windows

Return backlog:
  - macOS
  - Linux

Keep deferred:
  - WebSocket example
  - Notification
  - Analytics／Event Governance
  - Production signing／Store distribution
  - Device Binding
  - Passkey

Reject as generic template direction:
  - Payment
```

Additional Platform Support不應再以四平台單一candidate維護；未來current authority修復時，可將Web／Windows保留為獨立candidate，macOS／Linux退回backlog。

## Provisional Next-Milestone Conclusion

沒有任何方向同時滿足promotion六條件：

- Web／Windows有模板價值，但沒有confirmed adoption blocker或runtime failure。
- macOS／Linux缺具體價值證據。
- WebSocket／Notification／Analytics缺產品contract。
- Payment不適合作為generic template foundation。
- Signing／Store、Device Binding與Passkey需要具體產品、account／backend與security owner。

因此：

```txt
C — Promote a new formal Milestone: NOT SUPPORTED
D — Reject／defer／return selected candidates: SUPPORTED
```

## Validation and Review

- 每個平台獨立評估，未綁成四平台Milestone。
- Analytics與Observability保持分離。
- Notification、Payment、Device Binding與Passkey沒有因現有foundation自動promotion。
- Signing流程與產品credential責任分離。
- 沒有修改Roadmap／Backlog current authority。
- New audit findings：0；本Task產生direction proposal，不建立缺陷finding。

## Task Disposition

```txt
Directions reviewed: 11
Promote candidate: 0
Keep candidate: 2
Return backlog: 2
Keep deferred: 6
Reject: 1
Open P0: 0
Open P1 without disposition: 0
Task A8: ACCEPTED
```
