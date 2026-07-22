---
document_type: implementation-plan
status: accepted
authoritative_for:
  - milestone-25-ios-platform-support-foundation-implementation-plan
last_reviewed_baseline: 1.6.1
---

# Milestone 25 — iOS Platform Support Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立可重現、可驗證且不包含production distribution責任的tracked iOS runner，完成Simulator、native plugin、macOS golden與GitHub-hosted build evidence。

**Architecture:** 使用Flutter 3.41.6在temporary location生成CocoaPods-compatible iOS scaffold，再逐檔引入App。iOS native integration維持App-owned；`packages/`保持plugin-neutral。每個Task完成後立即建立review artifact、修正所有P0／P1並re-review後commit。

**Tech Stack:** Flutter 3.41.6、Dart 3.11.4、Xcode 26.6 local evidence、Swift 5.5 plugin floor、CocoaPods 1.16.2、iOS 13、local_auth、flutter_secure_storage、shared_preferences、sqflite、GitHub Actions macOS runner。

## Global Constraints

- 不升級Flutter或Dart；Swift Package Manager只做readiness audit，不宣稱pure SPM。
- 不加入Apple Developer Team、certificate、provisioning、production signing、Store distribution或正式產品Bundle Identifier。
- Bundle Identifier固定為`com.example.flutterarchitecture`；Product Name固定為`Flutter Architecture`。
- Minimum deployment target固定為iOS 13.0。
- 每個Task必須先review、修正、re-review，Open P0／P1為0後才commit。
- 未經使用者明確要求不得push。

---

## Task 25-1 — Reproducible iOS Scaffold

**Files:** Create `apps/flutter_architecture/ios/**`、`docs/audits/milestone_25/25-1_scaffold_review.md`; modify `apps/flutter_architecture/.metadata` only if Flutter generation requires the iOS platform entry。

- [ ] Record pre-generation Git status、Flutter version與existing App platform manifest。
- [ ] Generate a same-name temporary Flutter 3.41.6 app with only iOS enabled; do not run unrestricted `flutter create .` in the repository。
- [ ] Compare generated root files against the existing App and import only the reviewed `ios/` scaffold plus required `.metadata` platform entry。
- [ ] Verify Android／Web files and existing Dart source remain unchanged。
- [ ] Run `flutter pub get`、`pod install` where scaffold permits、docs_check與`git diff --check`。
- [ ] Immediate review：generated manifest、unexpected files、personal signing data、platform overwrite與rollback boundary。
- [ ] Fix／re-review until Open P0／P1 is zero。
- [ ] Commit: `build(ios): 建立可重現 iOS runner`。

## Task 25-2 — Native Identity and Toolchain Contract

**Files:** Modify iOS project settings／Podfile; create `apps/flutter_architecture/test/app/platform/ios_scaffold_contract_test.dart`、`docs/audits/milestone_25/25-2_toolchain_review.md`。

- [ ] Add failing static tests for iOS 13、Bundle Identifier、Product Name、unset Development Team與absence of provisioning identifiers。
- [ ] Align Podfile and Xcode build settings with iOS 13 and Flutter-generated Swift defaults。
- [ ] Track `Podfile.lock` as CocoaPods resolution authority without dependency upgrade。
- [ ] Record current plugin `Package.swift` readiness and `path_provider_foundation` fallback disposition。
- [ ] Run focused tests、`pod install`、Xcode build-setting inspection、docs_check and diff check。
- [ ] Review／fix／re-review; commit `build(ios): 固定原生識別與工具鏈契約`。

## Task 25-3 — Native Plugin Configuration

**Files:** Modify `Info.plist`、entitlements and Xcode references; create iOS local-auth／secure-storage contract tests and `25-3_plugin_configuration_review.md`。

- [ ] Add failing tests for non-placeholder `NSFaceIDUsageDescription` and minimal Keychain entitlement。
- [ ] Configure Face ID usage text and DebugProfile／Release entitlements without App Groups or unrelated permissions。
- [ ] Verify plugin registrant includes local_auth、secure storage、preferences、sqflite and path provider through generated integration。
- [ ] Run focused tests、`pod install` and unsigned simulator build。
- [ ] Review sensitive-data claims、fallback behavior、entitlement scope and plugin ownership。
- [ ] Fix／re-review; commit `feat(ios): 配置 Face ID 與 Keychain 邊界`。

## Task 25-4 — Simulator Build Verification

**Files:** Create `tools/ci/build_ios_simulator.sh`、`docs/audits/milestone_25/25-4_simulator_build_review.md`; modify CI version authority only if required。

- [ ] Add a repository-owned clean unsigned simulator build script using `lib/main.dart`。
- [ ] Build after `flutter clean` and dependency restoration; verify no signing identity is required。
- [ ] Inspect app bundle, deployment target, linked plugins and generated settings。
- [ ] Repeat build to prove reproducibility and record exact evidence。
- [ ] Review／fix／re-review; commit `build(ios): 建立 Simulator build 驗證`。

## Task 25-5 — Simulator Core Runtime Smoke

**Files:** Create `docs/audits/milestone_25/25-5_simulator_runtime_review.md`; modify source/tests only for verified iOS defects。

- [ ] Boot a clean iOS Simulator and install the built app。
- [ ] Verify bootstrap、Mock Login、Profile、Catalog、search and Protected Route。
- [ ] Verify Theme／Locale／local-unlock preference persistence across restart。
- [ ] Verify SQLite creation、foreign keys、Catalog persistence and Logout preservation contract。
- [ ] Record screenshots／commands／database evidence without sensitive values。
- [ ] Fix defects with focused tests, re-run smoke and re-review。
- [ ] Commit: `test(ios): 完成 Simulator 核心流程驗證`。

## Task 25-6 — Security Plugin and Lifecycle Smoke

**Files:** Create `docs/audits/milestone_25/25-6_security_lifecycle_review.md`; modify adapters/coordinators/tests only for verified defects。

- [ ] Verify Secure Storage write → terminate → restart → read → Logout delete。
- [ ] Configure Simulator biometric enrollment and verify success、nonmatch、cancel and unavailable dispositions where simulator supports them。
- [ ] Verify enabled cold start reads no credential before user presence succeeds。
- [ ] Verify biometric prompt `inactive → resumed` does not cause duplicate prompt。
- [ ] Verify grace-period resume and fail-closed exits。
- [ ] Add focused regression tests for every defect; fix／re-review。
- [ ] Commit: `test(ios): 驗證 Keychain 與本機解鎖生命週期`。

## Task 25-7 — macOS Golden Authority

**Files:** Modify golden resolver/tests; create macOS golden image and `25-7_macos_golden_review.md`。

- [ ] Run existing gallery golden test on macOS and confirm expected host rasterization difference。
- [ ] Generate a macOS candidate with fixed Flutter SDK fonts。
- [ ] Review semantic equivalence against Windows／Linux; do not loosen tolerance。
- [ ] Add macOS platform authority selection and run full macOS tests twice。
- [ ] Fix／re-review; commit `test(golden): 建立 macOS 視覺基準`。

## Task 25-8 — GitHub-hosted iOS Build Gate

**Files:** Create or modify `.github/workflows/ios.yml` and CI scripts; update ADR-023／CI guide; create `25-8_ci_review.md`。

- [ ] Add stable `iOS / Simulator Build` job on an explicit macOS runner image。
- [ ] Use exact Flutter authority, minimal `contents: read`, full-SHA pinned actions and safe concurrency。
- [ ] Resolve CocoaPods dependencies and invoke repository iOS build script without signing secrets。
- [ ] Add failure diagnostics with bounded retention; do not upload a distributable artifact as production output。
- [ ] Validate workflow locally/static, run remote workflow, record actual runner/Xcode evidence。
- [ ] Review security、cache correctness、required-check naming and ADR-023 extension。
- [ ] Fix／re-review; commit `ci(ios): 建立 Simulator build gate`。

## Task 25-9 — Physical Device Validation Disposition

**Files:** Create `docs/audits/milestone_25/25-9_device_validation.md`; modify repository files only if a device-discovered defect requires a reviewed fix。

- [ ] Attempt local physical-device validation only with non-repository signing state。
- [ ] Verify real Face ID／Touch ID、Keychain restart persistence、background/resume and Logout where possible。
- [ ] Ensure Team ID、certificate and provisioning data are absent from Git diff。
- [ ] If unavailable, record formal deferred disposition and exact unverified claims。
- [ ] Review／fix／re-review; commit `docs(ios): 記錄實體裝置驗證範圍`。

## Task 25-10 — Final Holistic Review and Release

**Files:** Create final review; update ADR index／ADR-024、roadmap、project context、README、milestone index、CI guide、CHANGELOG and VERSION according to evidence。

- [ ] Close M25-PR01–PR14; Open P0／P1 is zero。
- [ ] Run docs_check、analyze、all tests、generated consistency、Android release build and clean iOS simulator build。
- [ ] Confirm macOS golden and GitHub-hosted iOS job pass。
- [ ] Classify build、simulator、device、Supported and distribution evidence precisely。
- [ ] Confirm no production signing／Store／Flutter upgrade／pure-SPM scope entered the milestone。
- [ ] Release `1.7.0` only if critical runtime/plugin evidence is complete; otherwise do not claim iOS Supported。
- [ ] Archive and commit `docs(release): 封存 Milestone 25 iOS 平台基礎`。

## Self-Review

本plan覆蓋全部M25 planning findings、scaffold isolation、iOS 13、template identity、CocoaPods／SPM transition、Face ID、Keychain、preferences、SQLite、lifecycle、Simulator build/runtime、macOS golden、GitHub-hosted gate、device disposition、Android regression與1.7.0 release gate。每個Task都具有獨立review、修正、re-review與commit boundary。
