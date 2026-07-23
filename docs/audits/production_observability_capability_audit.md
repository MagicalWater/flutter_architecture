---
document_type: planning-review
status: accepted
authoritative_for:
  - production-observability-capability-audit
last_reviewed_baseline: 1.8.0
---

# Production Observability Capability Audit

## Audit purpose

本文件盤點 Template Baseline 1.8.0 的 production observability 起點、缺口與可驗證證據，作為是否提升正式 Milestone、是否新增 ADR 與後續 architecture design 的依據。

本次只做 repository inspection、capability audit 與 gap analysis；不加入 Firebase Crashlytics、Sentry 或其他 provider dependency，也不修改 production runtime source。

## Repository state inspected

```txt
Baseline: 1.8.0
Branch: main
Working tree at audit start: clean
Local divergence: origin/main ahead 9 commits
Active milestone: None
```

主要 authority 與 evidence：

- `docs/project_context.md`。
- ADR-020 Exception, Failure and Error Reporting。
- ADR-023 Repository CI quality gates。
- ADR-025 Native environment mapping。
- App error-reporting source、DI、bootstrap 與 tests。
- Android／iOS environment-aware build scripts與 GitHub Actions workflows。
- Sensitive model、OTP、credential、cache與preference regression tests。

## Existing capability inventory

### 1. App-owned reporting boundary

目前已有狹窄 `ErrorReporter` abstraction與 immutable `ErrorReport` input。Reusable package不依賴 Crashlytics／Sentry SDK，App仍是唯一 Composition Root。

現有 adapter：

- `DebugErrorReporter`：只輸出 error runtime type與封閉 safe context，不呼叫 `error.toString()`。
- `NoopErrorReporter`：可作為無 reporting environment或測試替身。
- Test-local recording／throwing fake：可驗證 identity、stack與best-effort semantics。

缺少真正 production remote adapter；`bootstrap()`目前所有 environment都建立`DebugErrorReporter`。

### 2. Capture boundaries and routing

目前已有分離入口：

| Boundary | Current severity | Behavior |
|---|---|---|
| Bootstrap failure | `fatal` | report後保留原error與stack rethrow |
| Flutter framework error | `unexpected` | report並委派既有Flutter handler |
| Platform/root isolate uncaught async error | `fatal` | report並維持handler chain |
| Bloc unhandled error | `unexpected` | report後維持Bloc原始propagation |
| Catalog cache degraded operation | `degraded` | 不阻止remote success或fallback |
| Preference／migration cleanup | `degraded`或`unexpected` | 依已分類結果best effort上報 |

Expected operational Failure通常不重複 report；unknown programming／system error不得被包成普通 Failure或吞掉。這個分流符合 ADR-020。

### 3. Duplicate suppression and ownership

`ErrorReportDeduplicator`在同一 event-loop turn內，以 error object identity加 stack object identity協調 Bloc／bootstrap rethrow與Platform hook。

已具備：

- generation token避免舊 cleanup刪除新 mark。
- cleanup scheduler由deduplicator持有。
- consume後移除entry。
- 不以字串、runtime type或stack內容做模糊去重。

這是入口間的短期重複抑制，不是 production provider的event grouping、sampling或rate limiting。

### 4. Sensitive-data and safe-context contract

`ErrorReportContext`只接受封閉的 source／operation enum，不接受任意Map、request body、query、Bloc state或event。

ADR-020與security contracts已禁止上報：

- password、OTP、PIN與recovery code。
- access／refresh token、Authorization、Cookie。
- raw credential storage payload。
- 完整 request／response body。
- 非必要PII、敏感query與cursor值。

Sensitive model `toString()`、OTP contract與auth diagnostic已有 regression tests。現況安全方向正確，但production adapter仍需要明確的allowlist conversion與provider API禁用規則。

### 5. Environment and release information

Milestone 26已提供development／staging／production的Dart與native一致映射、Android flavors、iOS schemes／build configurations與mismatch fail-fast。

現有可用來源：

- App environment。
- root `VERSION` baseline。
- Android application id suffix／flavor。
- iOS bundle identifier／scheme／configuration。
- Git commit SHA與artifact metadata（CI build scripts）。

目前這些資訊尚未組成runtime `ReleaseIdentity` contract，也沒有自動傳給reporting provider。Version、build number與commit SHA的runtime來源及缺失策略尚未拍板。

### 6. Adapter resilience

所有現有 reporting entrypoint與Debug adapter都以best effort吸收 reporter自身錯誤，避免reporting取代原始error flow。

已驗證：

- reporter failure不改變bootstrap原錯誤。
- reporter failure不從Bloc observer或uncaught handler逃出。
- debug sink failure不造成recursive error。

尚未覆蓋 remote provider初始化超時、SDK queue failure、provider outage、recursive provider callback與shutdown flush。

### 7. Tests, CI and runtime evidence

現有 focused tests至少覆蓋：

- ErrorReport identity、stack與safe `toString()`。
- Debug adapter安全輸出與sink failure。
- Flutter／Platform／Bloc／Bootstrap routing。
- global hook install、delegate、dispose與ownership。
- duplicate suppression identity、generation與cleanup。
- cache、theme、locale non-fatal／unexpected routing。

Repository CI已有change-aware full CI、Android development／production verification build與iOS development／production unsigned verification build。尚無provider SDK configuration、secret validation、mapping／dSYM upload或release-event verification。

## Gap analysis

### P0 gaps

無。現有baseline沒有宣稱已具備production remote observability，因此目前不存在違反既有公開claim的阻斷缺陷。

### P1 gaps

#### P1-1 No production adapter composition

所有environment目前都使用`DebugErrorReporter`。production build雖有environment boundary，仍沒有remote crash／handled exception destination。

#### P1-2 No durable production reporting contract

缺少以下正式 contract：

- Fatal／non-fatal／degraded如何映射provider API。
- Crash、handled exception、Flutter error與platform error routing。
- Provider initialization ordering與failure behavior。
- Release identity、environment tag與build metadata。
- Provider adapter不得使App crash或阻塞startup的timeout／best-effort規則。

#### P1-3 Privacy, consent and retention are unspecified

已有敏感資料禁止規則，但尚未拍板：

- 預設是否收集anonymous crash data。
- adopter如何提供privacy notice與consent policy。
- user／session context是否允許、可用哪些不可逆或低風險identifier。
- provider retention、region與data deletion責任。

#### P1-4 Native symbol pipeline is absent

Android mapping／native symbols與iOS dSYM upload沒有workflow、secret或release validation。Flutter Dart symbol strategy也未定義。沒有symbols時，production stack可讀性與修復價值不足。

#### P1-5 Provider lifecycle and outage behavior are unverified

缺少offline buffering ownership、slow reporting、SDK outage、recursive failure protection、startup disabled state與shutdown flush contract。

### P2 gaps

- Breadcrumb／diagnostic context尚未定義封閉taxonomy。
- Sampling、rate limiting與event storm protection尚未定義。
- Debug／staging／production behavior matrix尚未形成單一authority。
- CI secrets、native configuration、verification command與adopter guide尚未設計。
- 沒有provider contract test suite或reference adapter fake SDK seam。
- App README提到Debug／production composition，但實際production adapter仍缺失，後續Milestone需同步收斂措辭。

## Provider strategy comparison

### Firebase Crashlytics

優點：

- Flutter、Android、iOS整合路徑成熟。
- Crash／non-fatal reporting與native symbol workflow相對直接。
- 適合作為template的單一reference adapter。

成本與限制：

- 引入Firebase project、platform config files與CI credentials。
- Provider API與automatic collection預設行為需明確隔離。
- Breadcrumb、tracing與跨backend observability彈性不如Sentry完整。

### Sentry

優點：

- Error、breadcrumb、release、environment與event filtering能力完整。
- Provider-side grouping、sampling與release health較容易延伸。
- Self-hosted／SaaS選擇較多。

成本與限制：

- SDK options較廣，template初期更容易把performance tracing、session replay或PII功能一併帶入。
- Native symbol與release tooling仍需額外CI契約。
- 對只需要crash／handled exception reference implementation的第一階段較重。

### Provider-neutral only

優點：保持零vendor dependency與高替換性。

限制：無法驗證真正SDK初始化、native config、symbol upload、provider outage與release事件；只建立更多抽象但沒有production evidence，不能完成本階段目的。

## Audit conclusion

Production Observability是目前最合理的下一個正式Milestone，理由如下：

1. Exception／Failure、uncaught boundaries、environment與CI前置能力已到位。
2. 缺口集中且可形成有界Milestone，不需要先擴張Analytics、APM或完整SRE平台。
3. 現有production build claim已足以驗證environment與native wiring，但尚缺真正remote production reporting，是能力鏈最明顯的下一段。
4. Connectivity／Offline foundation可獨立處理network reachability、retry與offline state，不應先承擔error provider lifecycle。

建議採「provider-neutral stable contract + 單一 Firebase Crashlytics reference adapter」。不建議同時導入Sentry；也不建議只新增抽象而沒有reference adapter evidence。

## Scope disposition

建議正式名稱：

```txt
Milestone 27 — Production Observability Foundation
```

需要新增ADR，原因是本階段會新增穩定的provider boundary、release identity、privacy、severity routing、adapter resilience與native symbol ownership。ADR-020應保留error／failure分類authority；新ADR只擁有production observability provider與release integration contract，並把ADR-020列為related，不直接改寫其核心分類。

Analytics、Feature Flags、performance APM、business event tracking、remote logging backend、session replay與完整SRE平台維持non-goals。

## Validation performed for this audit

- Repository Git status與recent commits inspection。
- Source／test／ADR／README／CI／native build route静態審查。
- Provider dependency scan：目前沒有`firebase_core`、`firebase_crashlytics`或`sentry_flutter` dependency。
- Reporting focused test inventory review。

本文件不宣稱執行了runtime provider validation，因為provider尚未導入。
