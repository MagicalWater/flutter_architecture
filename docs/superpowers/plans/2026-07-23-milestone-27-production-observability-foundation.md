---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-27-production-observability-foundation-implementation-plan
last_reviewed_baseline: 1.8.0
---

# Milestone 27 — Production Observability Foundation Implementation Plan

## Objective

在ADR-020與ADR-026之上，建立App-owned provider-neutral production observability contracts，並以Firebase Crashlytics作為唯一reference adapter，完成Android／iOS symbol pipeline、CI secret boundary、privacy adoption與remote acceptance evidence。

本Plan不直接代表implementation已完成。Milestone 27的每個編號Task視為一個「小階段」，小階段內的implementation steps／subtasks必須遵循：

```txt
執行該小階段 Step／Subtask 1
→ 立即 focused review
→ 有問題就修正並再次 review
→ 通過後直接進入下一個 Step／Subtask
→ 重複直到該小階段全部內容完成
→ 針對整個小階段做 implementation review
→ 修正 findings 並重新 review
→ Open P0／P1 = 0
→ 執行該小階段 validation
→ 整個小階段只提交一次
```

執行期間不因單一Step／Subtask停下等待使用者確認，也不逐Step回報；完成整個小階段、整體review、validation與commit後再統一回報。不得以focused test或機械checker取代整個小階段implementation review。

## Global constraints

- App仍是唯一Composition Root。
- Reusable package與Feature不得依賴或直接呼叫provider SDK。
- 不同時導入Sentry或第二個production provider。
- 不導入Firebase Analytics、business event tracking、APM或session replay。
- Expected operational Failure不得批量上報。
- Unknown error保留identity與stack，不得吞掉。
- Provider failure不得改變App behavior或造成recursive crash。
- 禁止password、OTP、token、Authorization、Cookie、raw payload、完整response body與直接PII。
- 不宣稱production signing、Store distribution或release promotion已完成。

## Task 27-0 — Planning Review and Activation

**Goal**：確認ADR-026、scope、risk、deferred boundaries與Milestone activation gate。

**Files**：

- `docs/audits/milestone_27/27-0_planning_review.md`
- `docs/roadmap/active.md`
- `docs/roadmap/candidates.md`
- `docs/milestones/README.md`

**Acceptance**：

- Open P0／P1 = 0。
- ADR-020與ADR-026 authority不重疊。
- Task order、remote acceptance與secret boundary明確。
- Milestone 27正式成為active。

**Commit**：

```txt
docs(plan): 啟動正式環境可觀測性里程碑
```

## Task 27-1 — Release Identity and Provider-neutral Contracts

**Goal**：先建立不依賴Firebase SDK的release、collection與provider lifecycle seam。

**Expected source scope**：

- `apps/flutter_architecture/lib/app/observability/`
- `apps/flutter_architecture/lib/app/config/`
- `apps/flutter_architecture/test/app/observability/`
- 必要的DI source與generated output。

**Implementation**：

- Immutable `ReleaseIdentity`。
- Environment、version、build number、platform、native configuration與optional commit SHA。
- 建立App-owned `ReleaseMetadataReader` seam；version／build number以安裝產物的native package metadata為runtime authority，若需plugin dependency只能加入App，不能進入reusable package。
- Commit SHA只由受控build-time define注入；local未提供時維持absent，不使用`local`等假SHA。
- `ObservabilityCollectionPolicy`與test-friendly provider lifecycle abstraction。
- Development／staging／production／test composition matrix；所有environment remote collection預設關閉，只有明確policy可啟用。
- 缺少optional identity時的降級與environment mismatch fail-fast分離。

**Tests**：

- Release identity來源與格式。
- Local／CI commit SHA behavior。
- Environment-specific collection policy。
- Provider unavailable不阻止composition。
- Provider config存在但collection policy未啟用時仍不得remote collect。

**Commit**：

```txt
feat(observability): 建立發行識別與提供者中立契約
```

## Task 27-2 — Reporting Routing Hardening

**Goal**：將既有`ErrorReporter`提升為production-ready routing boundary，但不引入provider SDK。

**Implementation**：

- Fatal／unexpected／degraded routing policy。
- Closed typed metadata conversion。
- Provider recursive failure guard。
- Degraded source＋operation process-local rate limiter。
- Minimal typed startup／navigation breadcrumbs；不提供任意文字API。
- 維持同event-loop identity deduplication ownership。

**Tests**：

- Severity與source routing。
- Sensitive fixture不進metadata／log。
- Reporter callback再次失敗不遞迴。
- Burst limit不使用error message或payload。
- Expected Failure不被全域上報。

**Commit**：

```txt
feat(observability): 強化錯誤路由與遞迴保護
```

## Task 27-3 — Firebase Crashlytics Reference Adapter

**Goal**：只在App integration boundary導入Firebase Core與Crashlytics，實作單一reference adapter。

**Implementation**：

- Firebase initialization seam。
- Crashlytics adapter對fatal／non-fatal、keys、logs與collection switch的映射。
- Development預設remote off；staging／production依policy啟用。
- 不設定user identifier。
- 不加入Firebase Analytics dependency。
- Provider adapter failure只進local fallback，不回送自身。

**Tests**：

- SDK seam fake tests，不依賴真實backend。
- Environment composition。
- Collection enabled／disabled。
- Safe release／context mapping。
- Adapter failure isolation。

**Commit**：

```txt
feat(observability): 加入Crashlytics參考轉接器
```

## Task 27-4 — Android Native and Symbol Pipeline

**Goal**：建立Android environment config、Gradle plugin與mapping／Flutter symbol contract。

**Implementation**：

- Development／staging／production provider config projection。
- Android runner Gradle integration。
- R8／ProGuard mapping產物與upload task檢查。
- 明確拍板是否採`--obfuscate`／`--split-debug-info`；採用時建立Flutter symbol upload script與artifact metadata。
- Secret／config缺失時的PR-safe validation。

**Validation**：

- 三environment代表build。
- Mapping／symbol artifact存在。
- Config與application id mapping一致。
- Debug verification signing boundary維持清楚。

**Commit**：

```txt
feat(android): 建立Crashlytics符號處理管線
```

## Task 27-5 — iOS Native and dSYM Pipeline

**Goal**：建立iOS config、build phase與dSYM生成／upload contract。

**Implementation**：

- Shared scheme／build configuration對應provider config。
- Runner build phase或CI upload command。
- Unsigned generic device production build的dSYM existence verification。
- Missing dSYM與upload failure diagnostics。

**Validation**：

- Development Simulator與Production generic device代表build。
- dSYM UUID／artifact evidence。
- Provider config不混用environment。
- 不宣稱IPA／TestFlight／App Store已驗證。

**Commit**：

```txt
feat(ios): 建立Crashlytics dSYM處理管線
```

## Task 27-6 — CI Secrets and Remote Acceptance

**Goal**：建立安全的GitHub Actions wiring與真實provider evidence。

**Implementation**：

- Fork PR無secret時完成static／build validation並明確skip upload。
- Main push或manual workflow使用environment／repository secrets。
- Android與iOS symbol upload step。
- Staging handled non-fatal test event。
- Artifact、commit SHA、release與environment evidence保存。

**Acceptance**：

- Android與iOS各至少一個symbolicated test stack。
- Remote event能對應正確release與environment。
- Secret未提供時不洩漏、不失敗、不偽裝verified。
- Provider outage不影響一般quality／unit tests。

**Commit**：

```txt
ci(observability): 建立符號上傳與遠端驗收
```

## Task 27-7 — Privacy, Adoption and Holistic Closure

**Goal**：完成adopter-facing操作、privacy boundary、整體regression與Milestone closure。

**Documentation**：

- Provider project與App registration。
- Environment config與secret setup。
- Collection、consent、retention、deletion與opt-out責任。
- Debug／staging／production verification route。
- Sensitive-data denylist與safe context examples。
- Provider replacement seam與Sentry deferred disposition。

**Validation**：

- `dart pub get`。
- `dart run melos run build_runner`。
- `dart run melos run docs_check`。
- `dart run melos run analyze`。
- `dart run melos exec -- flutter test`。
- Android development／production代表build。
- iOS development／production代表build。
- Remote acceptance evidence review。
- Holistic final review，Open P0／P1 = 0。

**Closure updates**：

- Current snapshot、App README、ADR index／related links。
- Roadmap、Milestone index、Backlog disposition。
- CHANGELOG與VERSION是否升版，依實際runtime capability與release policy決定。

**Commit**：

```txt
docs(observability): 完成正式環境可觀測性終審
```

## Deferred to Connectivity and Offline State Foundation

- Reachability authority與online／offline／limited／unknown state。
- Request retry／backoff。
- Offline mutation queue與pending action。
- Reconnect orchestration與sync UI。
- Connectivity transition breadcrumbs。
- App主動pause／resume provider upload queue。

Milestone 27只依provider SDK自身offline buffering，並保留未來typed connectivity breadcrumb extension point。

## Final completion gate

Milestone 27只有在下列條件全部成立後才能closure：

- ADR-026與implementation一致。
- Provider dependency沒有進入reusable package或Feature。
- Fatal／unexpected／degraded routing與privacy contract有測試。
- Android mapping／symbols與iOS dSYM具可重現evidence。
- Staging remote event可確認release、environment與symbolication。
- Debug remote collection預設關閉。
- Provider failure不造成startup failure或recursive reporting。
- Analytics、APM、Store distribution與Connectivity未被scope creep納入。
- Open P0／P1 findings = 0。
