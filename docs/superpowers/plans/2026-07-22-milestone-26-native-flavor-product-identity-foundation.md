---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-26-native-flavor-product-identity-foundation-implementation-plan
last_reviewed_baseline: 1.7.0
---

# Milestone 26 — Native Flavor & Product Identity Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 建立development／staging／production的Android flavor、iOS scheme、native identity、entrypoint fail-fast mapping與最小CI代表矩陣。

**Architecture:** 以App-owned JSON manifest保存cross-platform mapping，Gradle與Xcode維持平台原生projection；repository verifier、native target binding與Dart sentinel提供三層一致性保護。Signing與Store distribution維持獨立後續責任。

**Tech Stack:** Flutter 3.41.6、Dart 3.11.4、Android Gradle Kotlin DSL、Xcode shared schemes／xcconfig、CocoaPods、Python unittest、Bash、GitHub Actions。

## Global Constraints

- 不修改reusable package以感知native flavor。
- 不加入production keystore、Apple Team、provisioning、IPA、AAB或Store upload。
- 不建立generic flavor generator。
- 每個Task完成implement → self-review → findings → fix → re-review → Open P0／P1=0 → validation → commit。
- Commit使用Conventional Commits與繁體中文；未經明確要求不得push。

---

## Task 26-1 — Environment Mapping Contract

**Files:** Create `apps/flutter_architecture/config/environments.json`, `tools/ci/verify_environment_contract.py`, `tools/ci/test_environment_contract.py`, `docs/audits/milestone_26/26-1_environment_contract_review.md`, canonical `docs/adr/adr-025-native-environment-mapping-product-identity-contract.md`; modify `docs/adr/README.md`; remove planning draft after canonical acceptance。

- [x] Write failing Python tests asserting exactly three environments, uniqueflavor／scheme／identifier, explicitentrypoint and production no-suffix identity。
- [x] Add JSON manifest with the approved mapping and no signing／secret fields。
- [x] Implement verifier helpers that load the manifest and report path-specific contract errors。
- [x] Add static checks for all four Dart entrypoints and `AppEnvironment` members。
- [x] Run `python3 -m unittest tools.ci.test_environment_contract`; expected PASS。
- [x] Run docs_check and diff check。
- [x] Review schema minimality、authority duplication、template placeholder and rollback boundary；fix and re-review。
- [x] Accept ADR-025 only after verifier evidence passes。
- [ ] Commit `feat(config): 建立原生環境映射契約`。

## Task 26-2 — Android Product Flavors

**Files:** Modify `apps/flutter_architecture/android/app/build.gradle.kts`, Android manifest/resources as required, environment verifier/tests; create `docs/audits/milestone_26/26-2_android_flavor_review.md`。

- [x] Extend failing verifier tests for `environment` dimension, three flavors, approved application IDs, labels and target mapping。
- [x] Add `development`、`staging`、`production` product flavors with manifest placeholders and suffix rules。
- [x] Add variant-aware target selection／validation: omitted target resolves from flavor; explicit mismatched target fails build。
- [x] Inject native environment sentinel for each variant without placing API endpoint in Gradle。
- [x] Build `developmentDebug` with mock and inspect package name／label／target evidence。
- [x] Build `productionRelease` with safe real example URL and inspect package name／label／target evidence；confirm debug verification signing classification。
- [x] Attempt a deliberate flavor／target mismatch and record expected failure。
- [x] Run Android focused tests、analyze、docs_check and diff check。
- [x] Review Flutter Gradle plugin compatibility、identity coexistence、signing and rollback；fix/re-review。
- [x] Commit `feat(android): 建立環境產品風味與識別契約`。

## Task 26-3 — iOS Schemes and Build Configurations

**Files:** Create environment xcconfig files and `Development.xcscheme`, `Staging.xcscheme`, `Production.xcscheme`; modify `Runner.xcodeproj/project.pbxproj`, `Podfile`, `Info.plist`, verifier/tests; remove shared `Runner.xcscheme`; create `26-3_ios_scheme_review.md`。

- [x] Extend failing verifier tests for three shared schemes, nine configurations, approvedbundle IDs, display names, target and sentinel values。
- [x] Add environment xcconfig files that inherit Flutter／Pods settings and defineidentifier、display name、`FLUTTER_TARGET` and sentinel。
- [x] Duplicate Debug／Profile／Release configurations per environment without duplicatingtargets。
- [x] Map Development／Staging／Production scheme actions to approvedconfigurations。
- [x] UpdatePodfile project mapping for all custom configuration names and run clean `pod install`。
- [x] MakeInfo.plist read display name／bundle name from build settings。
- [x] Remove sharedRunner scheme after all three schemes are discoverable。
- [x] Run `xcodebuild -list` and `-showBuildSettings` for all schemes; inspectidentifier、target and deployment target。
- [x] Build Development Debug Simulator and Production Release generic iOS device verification with no codesign；Flutter不支援Release Simulator AOT。
- [x] Run iOS static tests、docs_check and diff check。
- [x] Review scheme case sensitivity、Pods mapping、personal signing scan and rollback；fix/re-review。
- [ ] Commit `feat(ios): 建立環境 Scheme 與產品識別契約`。

## Task 26-4 — Dart Bootstrap Mismatch Guard

**Files:** Modify `app_config.dart`, bootstrap/config tests and environment verifier; create `26-4_bootstrap_guard_review.md`。

- [x] Write failing Dart tests for matching sentinel, missing sentinel on compatibility entrypoint, wrong sentinel, staging HTTP, production mock and placeholder host。
- [x] Parse `NATIVE_ENVIRONMENT` centrally inAppConfigFactory and compare with entrypoint environment before DI creation。
- [x] Keep `main.dart` development compatibility explicit; native flavor/scheme builds must always inject sentinel。
- [x] Require staging realHTTPS and harden production placeholder host rejection without blocking adopter-configured real domains。
- [x] Run focusedconfig/bootstrap tests, all Flutter tests and analyze。
- [x] Review fail-fast timing、error clarity and ADR-014 compatibility；fix/re-review。
- [x] Commit `fix(config): 阻擋原生環境與 Dart 入口錯配`。

## Task 26-5 — Local Build and Artifact Commands

**Files:** Replace or extend `tools/ci/build_android_release.sh`, `build_ios_simulator.sh`; create focused scripts/tests and `26-5_local_build_review.md`; update artifact metadata contract。

- [ ] Add explicit development and production wrapper commands; no wrapper may target `lib/main.dart` for production verification。
- [ ] Keep Android production APKdebug-signed for verification and label metadata `distribution=not production-ready`。
- [ ] Verify built Android package IDs with platform tooling and iOS bundle IDs with`plutil`。
- [ ] Record environment、flavor/scheme、entrypoint、API mode classification and signing disposition in metadata/log output。
- [ ] Add shell/Python contract tests for exact commands and expected artifact paths。
- [ ] Run all four local representative builds from clean dependencies where host supports them。
- [ ] Review stale artifact risk、path assumptions and shell portability；fix/re-review。
- [ ] Commit `build(flavor): 建立環境化本機驗證命令`。

## Task 26-6 — CI Representative Matrix

**Files:** Modify `.github/workflows/ci.yml`, `android.yml`, `ios.yml`, CI tests and guide; create `26-6_ci_review.md` and remote evidence artifact。

- [ ] Add environment contract unittest to stableQuality gate。
- [ ] Configure Android workflow to build developmentDebug and productionRelease representative artifacts withoutStore secrets。
- [ ] Configure iOS workflow to build Development Debug and Production Release Simulator with no codesign。
- [ ] Keep stablecheck names or document any intentional Branch Protection impact before renaming。
- [ ] Upload onlybounded verification artifacts／diagnostics with explicit environment and SHA metadata。
- [ ] Validate YAML/static contracts locally and trigger remote CI。
- [ ] Record actual run IDs、runner/Xcode versions、artifact identity and all failure dispositions。
- [ ] Review permissions、cache correctness、secret absence、matrix cost and production claim boundary；fix/re-review。
- [ ] Commit `ci(flavor): 驗證開發與正式環境代表建置`。

## Task 26-7 — Adoption and Operations Documentation

**Files:** Modify app/rootREADME as owned, `docs/guides/ci_cd_operations.md`, project context and ADR links; create an adoption guide if existing README cannot own replacement procedure; create `26-7_documentation_review.md`。

- [ ] Document exact local commands for all three environments onAndroid and iOS。
- [ ] Document manifest-first replacement order for base identifier、display name and API domain。
- [ ] Document what remains template placeholder and what must never be committed。
- [ ] SeparateCI verification、production signing and Store distribution responsibilities。
- [ ] Update current snapshot only with durable current capabilities; do not copyTask journal。
- [ ] Runlink checker、docs_check and search for stale `lib/main.dart` release commands／single identity claims。
- [ ] Review authority duplication and newcomer usability；fix/re-review。
- [ ] Commit `docs(flavor): 說明產品識別與採用流程`。

## Task 26-8 — Final Holistic Review and Release

**Files:** Create final review and remote validation; update roadmap、milestone index、CHANGELOG、VERSION、ADR-025 and current snapshot according to evidence。

- [ ] CloseM26-PR01–PR14 and all implementation findings; Open P0／P1=0。
- [ ] Run docs_check、analyze、all Flutter tests、generated consistency、environment verifier and shell/workflow contracts。
- [ ] Rebuild four representative artifacts and verifyidentity／entrypoint／sentinel metadata。
- [ ] Confirm deliberate mismatch tests fail and production security restrictions remain fail-closed。
- [ ] Confirm noTeam、keystore、certificate、provisioning orStore secret enteredGit history。
- [ ] RecordGitHub-hostedCI／Android／iOS run evidence。
- [ ] Decideversion from final evidence; native flavor/product identity capability is aMINOR candidate。
- [ ] Archive and commit using approvedConventional Commit；do notpush without explicit instruction。

## Self-Review

本plan覆蓋M26-PR01–PR14、三環境mapping、Android flavor、iOS scheme/configuration、entrypoint/sentinel fail-fast、template replacement、production safety、minimalCI matrix、signing/distribution boundary、documentation governance與rollback。每個implementation Task都有獨立review、validation與commit boundary。
