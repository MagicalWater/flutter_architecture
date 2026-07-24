---
document_type: current-snapshot
status: active
authoritative_for:
  - current-project-context
last_reviewed_baseline: 1.12.0
---

# Project Context

## Purpose and Authority

本文件是 Flutter Enterprise Architecture Template 的 **current-only snapshot**。

它只描述目前仍有效的：

- Template Baseline。
- Repository 定位。
- 架構與責任邊界。
- 已交付能力。
- 平台與安全限制。
- 目前 active work。
- 文件與驗證入口。

它不保存逐 Milestone journal、commit timeline、歷史測試數或過去的「下一步」。歷史規劃、review 與 runtime evidence 應依 `docs/README.md` 的任務式路由按需讀取。

## Current Baseline

```txt
Template Baseline: 1.12.0
Phase 1 / MVP: Completed
Current active milestone: None
Latest completed initiative: Milestone 30 Test Suite Audit, Rationalization & Governance
Architecture Decision authority: docs/adr/README.md
```

版本字串唯一來源為 `VERSION`；正式版本內容由 `CHANGELOG.md` 記錄。

Milestone 19 Secure Credential Storage、Milestone 20 OTP Step-Up Authentication 與 Milestone 21 Biometric-gated Local Session Unlock 均已完成 final review 並封存。

Milestone 22 只處理 Documentation Authority、Navigation、Current Snapshot、README Coverage 與 consistency foundation，不改變 production runtime behavior。

Milestone 23 已將 Decision 001–022擷取為canonical single-file ADR、建立可驗證supersession graph、切換正式authority並保留aggregate與legacy path相容路由。

Milestone 24 已建立GitHub Actions repository quality gates、exact toolchain authority、tracked root lockfile、generated consistency、main Android verification artifact與CI operations guide。此能力以Template Baseline 1.6.0封存，並於1.6.1完成GitHub-hosted CI／Android remote validation、跨平台golden authority與Node 24 Actions相容性修正。Milestone 27後續加入`manual-local`／`self-hosted`／`github-hosted`三種執行模式，以及只接受trusted `main`與manual dispatch的repository-scoped Mac runner；production signing、Store publishing與GitHub repository Branch Protection settings仍未納入。

Milestone 25已建立tracked iOS runner、原始iOS 13 native contract、CocoaPods resolution、Face ID／Keychain設定、Simulator runtime smoke、macOS golden authority與GitHub-hosted unsigned Simulator build gate，並以Template Baseline 1.7.0封存。Milestone 27因Firebase Apple SDK 12.x最低需求，已將current iOS deployment baseline提升為15.0。Physical-device biometric acceptance、production signing、IPA與App Store distribution仍為deferred scope。

Milestone 26已建立development／staging／production的cross-platform mapping manifest、Android product flavors、iOS shared schemes與九組build configurations、native／Dart mismatch fail-fast、environment-aware local artifact commands、GitHub-hosted development／production代表性build matrix與manifest-first adoption guide，並以Template Baseline 1.8.0封存。Repository artifacts仍只屬verification evidence，不包含production signing或Store distribution。

Milestone 27已建立provider-neutral production observability contract、Firebase Crashlytics reference adapter、release identity與severity routing、privacy／collection policy、Android symbols、iOS dSYM、controlled remote acceptance，以及`manual-local`／`self-hosted`／`github-hosted`三種CI execution mode。Android與iOS controlled events均已完成Firebase Console ingestion與symbolication驗證，並以Template Baseline 1.9.0封存。

Milestone 28已建立App-owned typed connectivity authority、provider-neutral adapter contract、`connectivity_plus` reference adapter、startup／resume recheck、offline banner與Catalog opt-in reconnect revalidation。Backend reachability仍由operation result表達，physical-device network toggle與production distribution維持deferred，並以Template Baseline 1.10.0封存。

Milestone 29已完成Drift Persistence Migration，Drift成為唯一production database authority，並保留v1～v6 historical migration與rollback compatibility。

Milestone 30已建立repository-wide test inventory、primary coverage owner、production／historical boundary、controlled deletion manifest與Tier 1～5 execution governance。Auth與Catalog current integration均使用production Drift path；historical sqflite只保留於migration、rollback與fixture oracle。Template Baseline提升為1.12.0。

Repository CI已採change-aware execution：純文件變更只執行輕量治理與穩定check no-op；source、native、dependency、classifier或release變更依contract執行完整CI及相關平台代表build。Unknown path、無效Git range與classification failure會fail-safe到完整矩陣。詳細操作矩陣由`docs/guides/ci_cd_operations.md`擁有。

## Project Purpose

本 repository 是可直接作為中大型 Flutter 專案起點的 Enterprise Architecture Template。

核心目標：

- 以可讀、可測試且可延續的方式落實 Clean Architecture。
- 使用 Feature First 組織 App presentation 與 feature-local implementation。
- 使用 Monorepo 管理 App 與具明確 boundary 的 reusable packages。
- 由 App 擔任唯一 Composition Root。
- 以 production source、tests、artifact 與 runtime evidence 驗證架構 claim。
- 讓文件成為可治理的 authoritative system，而不是同步多份歷史副本。

本模板追求清楚邊界與長期維護，不以最少檔案、最少抽象或展示所有可能框架為目標。

## Repository Map

```txt
root/
  apps/
    flutter_architecture/
  packages/
    api_client/
    auth/
    core/
    design_system/
  docs/
  tools/
  AGENTS.md
  README.md
  CHANGELOG.md
  VERSION
```

### App

`apps/flutter_architecture` 是目前唯一 executable Flutter App，負責：

- Bootstrap 與 Dart environment entrypoints。
- App configuration。
- Router、Route Guard 與 authentication navigation orchestration。
- Dependency Injection composition。
- Flutter plugin adapters 與 platform integration。
- Connectivity lifecycle、reconnect signal與App-wide offline presentation。
- SQLite database lifecycle 與 migration。
- Theme、Locale 與 local unlock preference。
- Feature presentation composition。
- Android runner 與 release artifact verification。

### Packages

`packages/core`：

- `Result`、typed `Failure`、`AppException` 等跨 feature 基礎 contract。
- Reporting abstraction 與不吞 unknown error 的錯誤邊界。

`packages/api_client`：

- Dio／Retrofit network boundary。
- Auth header、refresh、safe replay 與 request metadata。
- Login、OTP Verify／Resend 等 wire contract。

`packages/auth`：

- Auth Domain、Data、UseCase、Repository 與 Session contract。
- Credential store abstractions、migration policy、refresh coordination。
- OTP domain state machine。
- Local user presence 與 local unlock policy abstractions。

`packages/design_system`：

- Design tokens、Theme identity、Theme registry 與 Material themes。
- Reusable presentation primitives 與 page-state surfaces。
- 不依賴 App、Feature、Bloc、DI framework 或 persistence implementation。

## Architecture Boundaries

### Clean Architecture and Feature First

主要依賴方向：

```txt
Presentation
  ↓
Domain
  ↓
Data
  ↓
Infrastructure / External Systems
```

App 內以 feature 為主要組織單位；只有真正跨 feature 且具穩定 contract 的能力才提升至 `packages/`。

### Composition Root

App 是唯一 Composition Root：

- Package class 使用 constructor injection 表達依賴。
- Reusable package 不直接依賴 `get_it` 或 `injectable`。
- DI lifecycle、interface binding、plugin adapter 與 environment selection 由 App 決定。

### Presentation and Cross-feature State

- Page 只依賴自身 presentation boundary。
- 不跨 feature 直接讀取其他 feature 的 Bloc。
- 跨 feature authority 透過 SessionManager、Repository Interface、UseCase 或 App coordinator 傳遞。
- Route Guard 不依賴 AuthBloc，只依賴穩定的 Session authority。
- UseCase 以單一業務行為為粒度。

### Generated Sources

以下 generated files 不可手動修改：

```txt
*.freezed.dart
*.g.dart
*.gr.dart
injection.config.dart
```

需要更新時，修改 source 後執行 build runner。

## Current Technology Map

### Architecture and Workspace

- Clean Architecture。
- Feature First。
- Monorepo。
- Melos 8 + Dart Pub Workspaces。

### Presentation

- `flutter_bloc`。
- `flutter_hooks`。
- `hooked_bloc`。

### Navigation and Composition

- `auto_route`。
- `get_it`。
- `injectable`。

### Models and Generation

- `freezed`。
- `json_serializable`。
- `build_runner`。
- Retrofit generation。

### Network

- Dio。
- Retrofit。
- Deterministic Mock API implementations。
- Main Dio 與 Refresh Dio 分離。
- Concurrent 401 single-flight refresh。
- Session-aware safe request replay。

### Persistence and Platform

- Flutter Secure Storage：Auth credential authority。
- Drift／SQLite：AuthUser、Catalog Cache、schema與App database唯一production authority。
- SharedPreferences：Theme、Locale、local unlock preference，以及 legacy credential migration／cleanup。
- sqflite／`sqflite_common_ffi`：只保留historical fixture與rollback test harness。
- `local_auth`：App-owned Android biometric user-presence adapter。

### Design and Localization

- Reusable Design System package。
- Default／Ocean Theme identities。
- Light／Dark／System mode。
- Flutter official `gen_l10n`。
- English 與繁體中文 `zh_TW`。
- Locale-aware formatting through `intl`。

## Current Capabilities

### Environment and API Composition

- Development、staging、production 使用獨立 Dart entrypoints。
- Development 可選 Mock 或 Real API。
- Staging／production 只允許 Real API。
- Production 強制 HTTPS 並拒絕 placeholder、localhost、loopback 與 invalid URL。
- Mock 與 Retrofit implementation 共用 API abstraction，由 App Composition Root 選擇。

### Authentication and Session

- Login、Logout、Restore Session 與 Session expiration synchronization。
- Access／Refresh Token Pair 與 identity-aware Session generation。
- Refresh token rotation 採 persistence-first。
- 多個同 Session 的並行 401 共用 single-flight refresh。
- 只有符合 Session identity 且可安全重送的 request 才 replay 一次。
- Logout、relogin、account switch 與 stale completion 受 latest-intent／generation contract 保護。

### Credential Persistence and Migration

Current authority：

```txt
Credential Token Pair
  → FlutterSecureStorage

Public AuthUser identity
  → Drift / SQLite

Legacy SharedPreferences credential
  → migration / cleanup only
```

Restore、Login、Refresh、Logout 與 passive invalidation 共用明確 lifecycle contract；credential absence、corruption 與 operational unavailable 不混為同一結果。

### OTP Step-Up Authentication

- Login wire／domain result 明確區分 authenticated 與 OTP challenge。
- OTP pending 時不保存 credential、不建立 Session、不通過 Protected Route。
- Verify 成功是 credential 與 Session commit boundary。
- Resend 會替換 challenge 並使 predecessor 失效。
- Expiration、cooldown、attempts 與 invalid code 使用 typed contract。
- OTP navigation 由 App-owned coordinator 管理。

### Biometric-gated Local Session Unlock

- Biometric 只驗證本機 user presence，不取代 server authentication。
- Local unlock preference 預設 disabled。
- Enabled cold start 必須先通過 biometric-only prompt，之後才可讀取 credential 並 Restore Session。
- Locked 階段 SessionManager 維持 unauthenticated。
- Cancel、not enrolled、unavailable 與 lockout 不允許 fallback 自動 restore。
- Resume 使用五分鐘 grace period 與 single-prompt ordering。
- Android 提供 production settings entry、Native configuration、release artifact 與 runtime smoke evidence。

### Catalog

- Cursor-based pagination。
- Search debounce 與 query generation protection。
- Refresh、Append 與 stale response ordering。
- Feature-level Offline Cache。
- Cache-first + Stale-While-Revalidate initial flow。
- Cursor page storage、chain revision、cycle protection 與 lazy cleanup。
- Public Catalog Cache 不因 Logout 清除。

### Design System and Appearance

- Primitive tokens 與 semantic color roles。
- Default／Ocean Light／Dark themes。
- Theme identity 與 Theme mode 分離。
- Persistent appearance preference。
- Shared blocking page-state surfaces 與 non-blocking status primitives。
- Narrow viewport、large text、theme matrix 與 stable gallery regression。

### Localization

- English／`zh_TW` ARB 與 generated localization。
- System／English／Traditional Chinese preference。
- Runtime locale switching 與 persistence。
- Chinese locale-list resolution。
- Feature-local user-facing Failure mapping。
- Server content 不被錯誤納入 App ARB。

### Exception and Failure Architecture

- Expected operational failure 走 typed `AppException → Failure → Result`。
- Unknown programming／system error 不被轉成一般 Failure 或空 catch 吞掉。
- Cancellation、protocol violation、invariant、cache degradation 與 session lifecycle 有明確分類。
- App 是 reporting Composition Root；packages 不直接依賴 Crashlytics 或 App localization。
- Sensitive credential、OTP code 與 raw payload 不得進 exception、failure、diagnostic、log 或 `toString()`。

## Platform Capability

| Platform | Current classification |
|---|---|
| Android | Supported；tracked runner、release artifact 與 runtime smoke evidence |
| iOS | Supported；tracked runner、local Simulator runtime、macOS golden與GitHub-hosted unsigned build evidence |
| Web | Dependency-ready；有Drift Wasm／worker assets，但沒有tracked Web runner；舊experimental storage採explicit reset |
| Windows | Dependency-ready；沒有 tracked runner 與 release runtime evidence |
| macOS | Dependency-ready；沒有 tracked runner 與 release runtime evidence |
| Linux | Dependency-ready；沒有 tracked runner 與 release runtime evidence |

Android與iOS可以被描述為目前Supported platform。iOS Supported claim不包含physical-device acceptance、production signing、IPA、TestFlight或App Store distribution；這些範圍仍有明確deferred disposition。

## Security and Support Boundaries

- Secure credential storage 是 credential-at-rest hardening，不防 rooted device、runtime memory extraction 或 server compromise。
- OTP flow 不宣稱防止 SIM-swap、phishing 或保證 SMS provider delivery。
- Biometric unlock 不保存 biometric data，不實作 cryptographic Device Binding。
- Device Binding 與 Passkey 不屬於目前 Template Baseline 1.12.0。
- Repository Android production APK 使用debug verification signing，iOS production `.app`為unsigned verification build；兩者都不可直接作為Store artifact。
- Default base identifier `com.example.flutterarchitecture`、display name與example API domain仍是template placeholder。Adopter必須依`docs/guides/native_environment_adoption.md`從manifest開始同步替換Android、iOS與verification projection。

## Active Work

Milestone 30已完成implementation、holistic review與Template Baseline 1.12.0 local release；目前只等待explicit push與post-release validation。完成remote closure後，下一個正式方向必須先從candidate／backlog完成scope review與planning promotion。

Milestone 26已完成final holistic review、Template Baseline 1.8.0 release與封存；change-aware CI已完成classifier、三份workflow wiring、本地regression、documentation-only acceptance、manual full-matrix acceptance與獨立holistic final review。Final review發現的App pubspec、assets與localization config兩平台build漏判已完成修正、57個CI contracts與GitHub-hosted完整矩陣revalidation，initiative已正式closure。

Production signing、physical-device acceptance、App Store distribution與GitHub repository settings仍未納入；Branch Protection目前只有文件化建議。

## Documentation Routing

每次進入 repository 的最小讀取集：

```txt
AGENTS.md
VERSION
docs/README.md
docs/project_context.md
docs/roadmap.md
```

其餘依任務讀取：

- Architecture：`docs/adr/README.md` 與相關 canonical ADR。
- Feature：對應 Feature README、Decision、source 與 tests。
- Package：對應 Package README、Decision、public API、source 與 tests。
- Milestone：Spec、Plan、Planning Review 與目前 Phase Review。
- Review／Runtime Evidence：`docs/audits/` 對應文件。
- Release：`VERSION`、`CHANGELOG.md`、final review 與 Root README capability。
- History：`docs/milestones/README.md`、`docs/archive/`、Audits、Plans 與 Git history。

完整 taxonomy 與 metadata policy：

- `docs/README.md`
- `docs/governance/documentation_policy.md`

## Standard Verification Commands

在 workspace root：

```bash
dart pub get
dart run melos run build_runner
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
```

App bundle verification：

```bash
cd apps/flutter_architecture
flutter build bundle
```

涉及 Android release capability、Native configuration 或 runtime claim 時，還需要對應 release artifact、manifest 與 runtime smoke evidence；不能只用 `flutter build bundle` 取代。

## Update Rule

本文件只在下列 current facts 改變時更新：

- Template Baseline。
- Supported platform classification。
- Repository purpose 或 architecture map。
- App、Feature、Package responsibility。
- Current capability 或 security claim boundary。
- Active milestone。
- Documentation routing。
- Standard verification contract。

不得把逐 Task progress、commit hash、歷史測試數或完成 Milestone 的詳細 journal 追加回本文件。
