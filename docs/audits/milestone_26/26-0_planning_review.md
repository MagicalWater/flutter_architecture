---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-26-native-flavor-product-identity-planning-review
last_reviewed_baseline: 1.7.0
---

# Milestone 26-0 — Native Flavor & Product Identity Planning Review

## Scope

本review審查Dart environment、Android identity、iOS identity、entrypoint與CI的現況，建立Milestone 26設計、findings disposition、ADR gate、acceptance criteria與implementation task breakdown。

本Task不修改Gradle flavor、Xcode project、scheme或CI workflow implementation。

正式設計：

- `../../superpowers/specs/2026-07-22-milestone-26-native-flavor-product-identity-foundation-design.md`

## Current Repository State

```txt
Template Baseline: 1.7.0
Branch: main
HEAD: d1dfe78 docs(release): 封存 Milestone 25 iOS 平台基礎
Remote relation: main synchronized with origin/main
Working tree before planning files: clean
Supported platforms: Android, iOS
Current active milestone: None
```

## Architecture Disposition

採用repository mapping contract與platform projections：

```txt
environment mapping manifest
  ├─ Android productFlavors / manifest placeholders / target gate
  ├─ iOS schemes / build configurations / xcconfig
  ├─ Dart native-environment sentinel validation
  └─ repository static verifier / representative CI builds
```

不採用只靠CLI convention，也不允許Android、iOS與Dart各自成為互不驗證的authority。

## Findings and Disposition

| Finding | Severity | Disposition |
|---|---:|---|
| M26-PR01 release-mode Android／iOS scripts仍使用development `lib/main.dart` | P0 | Task 26-5／26-6改為明確Development與Production代表build |
| M26-PR02 native identity無environment區分，development與production不可同時安裝 | P1 | Task 26-2／26-3建立suffix identity |
| M26-PR03 Android flavor與Dart target可被任意錯配 | P0 | Task 26-2加入variant target gate與sentinel |
| M26-PR04 iOS scheme、configuration與`FLUTTER_TARGET`沒有mapping | P0 | Task 26-3以xcconfig固定target與sentinel |
| M26-PR05 App display name在Android Manifest與Info.plist獨立hard-code | P1 | mapping manifest與platform projection統一驗證 |
| M26-PR06 staging可能只存在Dart層而沒有native artifact identity | P1 | 三環境完整static contract；staging不要求CI build |
| M26-PR07 production只靠Dart API validation，沒有native environment一致性證明 | P0 | bootstrap前比較`NATIVE_ENVIRONMENT` sentinel |
| M26-PR08 template identifier與產品替換責任未形成正式契約 | P1 | ADR-025與Task 26-1／26-7定義adoption boundary |
| M26-PR09 production representative build可能被誤認為signed／Store-ready | P1 | artifact metadata與CI guide維持verification-only分類 |
| M26-PR10 建置所有environment×platform×mode會浪費CI | P2 | 只建development／production代表組合，staging static verify |
| M26-PR11 iOS configuration增加後Podfile mapping可能漏掉非標準名稱 | P1 | Task 26-3更新Pod project mapping並clean `pod install`驗證 |
| M26-PR12 舊Runner scheme或default command可能成為第四個未治理入口 | P1 | migration完成後移除Runner shared scheme，`main.dart`僅保留Dart compatibility |
| M26-PR13 candidates／backlog仍保存Milestone 25前baseline描述 | P1 | Task 26-0依ownership修正，不複製current snapshot journal |
| M26-PR14 signing與Store distribution容易被native identity工作順帶帶入 | P1 | ADR與plan明確non-goals，static scan維持Team／secret禁入 |

Open P0／P1 without disposition：0。

## Naming Decision

| Environment | Android | iOS | Entrypoint | Identifier suffix |
|---|---|---|---|---|
| development | `development` | `Development` | `main_development.dart` | `.development` |
| staging | `staging` | `Staging` | `main_staging.dart` | `.staging` |
| production | `production` | `Production` | `main_production.dart` | none |

Base template identity維持`com.example.flutterarchitecture`。Development display name為`Flutter Architecture Dev`；Staging為`Flutter Architecture Staging`；Production為`Flutter Architecture`。

## CI Decision

Static verifier覆蓋三個environment。Build matrix只包含：

- Android development Debug APK。
- Android production Release APK，debug verification signing。
- iOS Development Debug Simulator。
- iOS Production Release Simulator，no codesign。

Staging不建立artifact，避免無意義的全矩陣；任何staging-specific native差異必須先有evidence再擴張CI。

## Architecture Decision Gate

需要新增：

```txt
ADR-025 — Native Environment Mapping and Product Identity Contract
```

ADR-025 related至ADR-014、ADR-023與ADR-024，不supersede其Dart environment、CI general boundary或iOS runner contract。

Planning draft：`adr-025_draft.md`。Task 26-1驗證通過後才建立canonical `docs/adr/adr-025-native-environment-mapping-product-identity-contract.md`並加入ADR index。

## Task Breakdown

1. **26-0 — Planning Review and Architecture Design**：design、planning findings、ADR草案、roadmap promotion與治理修正。
2. **26-1 — Environment Mapping Contract**：manifest schema、static verifier、Dart sentinel failing tests與ADR-025 acceptance。
3. **26-2 — Android Product Flavors**：flavor dimension、identity、display name、target binding與Android contract tests。
4. **26-3 — iOS Schemes and Build Configurations**：xcconfig、schemes、configuration、Pods mapping、identity與target binding。
5. **26-4 — Dart Bootstrap Mismatch Guard**：native sentinel compare、production placeholder hardening與focused tests。
6. **26-5 — Local Build and Artifact Commands**：repository wrapper scripts、metadata與development／production local evidence。
7. **26-6 — CI Representative Matrix**：static gate與四個representative builds、remote evidence。
8. **26-7 — Adoption and Operations Documentation**：template replacement guide、CI/signing/distribution boundary與command reference。
9. **26-8 — Final Holistic Review and Release**：findings closure、regression、remote validation、version與archive disposition。

## Acceptance / Non-goals / Rollback Review

Acceptance criteria、non-goals與rollback策略已由design spec完整定義。Scope可由單一Milestone管理；Android與iOS改動有獨立Task rollback boundary，不需要拆成兩個Milestone。

## Planning Review Status

- Placeholder scan：通過。
- Internal consistency：通過。
- Authority ownership：通過；mapping manifest不取代Dart environment semantics。
- Security boundary：通過；production signing與Store distribution排除。
- CI scope：通過；沒有建立全組合matrix。
- Findings disposition：Open P0／P1為0。

Milestone 26可提升為active；下一步只能依implementation plan執行Task 26-1，不得跳過review gate直接大量改動原生project。
