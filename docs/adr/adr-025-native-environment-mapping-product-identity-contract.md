---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-025-native-environment-mapping-product-identity-contract
last_reviewed_baseline: 1.8.0
id: ADR-025
title: Native Environment Mapping and Product Identity Contract
supersedes: []
superseded_by: []
related:
  - ADR-014
  - ADR-023
  - ADR-024
---

# ADR-025 — Native Environment Mapping and Product Identity Contract

## Status

Accepted。

## Authoritative Scope

本Decision定義Dart deployment environment到Android product flavor、iOS shared scheme、Dart entrypoint、native identity、display name與repository verification的cross-platform mapping contract。

## Context

ADR-014已將Dart entrypoint定義為`AppEnvironment`唯一來源；ADR-023與ADR-024建立repository CI與iOS runner contract。但本Decision採納前，native runner仍只有單一identity與預設compatibility entrypoint，因此release-mode build可實際使用development environment，且Android flavor或iOS scheme可能與entrypoint錯配。

## Decision

Repository使用一份App-owned environment mapping manifest保存三個environment的native projection。Manifest中的`baseIdentifier`與各environment identifier/display name是concrete native identity唯一machine owner；Manifest不是generic framework，也不取代Dart entrypoint semantics。

Template default mapping（產品採用後不再是該product repository的current concrete authority；current values一律讀manifest）：

| Environment | Android flavor | iOS scheme | Entrypoint | Display name | Identifier |
|---|---|---|---|---|---|
| development | `development` | `Development` | `lib/main_development.dart` | `Flutter Architecture Dev` | `com.example.flutterarchitecture.development` |
| staging | `staging` | `Staging` | `lib/main_staging.dart` | `Flutter Architecture Staging` | `com.example.flutterarchitecture.staging` |
| production | `production` | `Production` | `lib/main_production.dart` | `Flutter Architecture` | `com.example.flutterarchitecture` |

Android使用單一`environment`flavor dimension。iOS使用三個shared scheme與每個environment的Debug／Profile／Release build configuration。

Android variant與iOS configuration必須固定正確Dart target。Dart runtime environment唯一由entrypoint決定；native environment值可以作為platform-only build metadata／provider wiring selector存在，但不得再以`NATIVE_ENVIRONMENT` dart-define注入Dart runtime形成第二份environment authority。Native flavor／scheme與entrypoint的一致性由Gradle／Xcode projection及repository static verifier負責fail fast。

Android FlutterTask驗證一般target時，必須先以Flutter app root為基準canonicalize成app-relative path，再與manifest entrypoint比較。因此`lib/main_development.dart`與同一app內的absolute path語意相同，Windows／POSIX separator差異不得造成合法target被拒絕。`lib/main.dart` compatibility與app-owned `integration_test/`例外也必須在canonicalization後判定。

App root外target預設fail closed。唯一例外是Flutter tool自行建立、位於system temp root下且精確符合`flutter_tools.<id>/flutter_test_listener.<id>/listener.dart` hierarchy的managed test listener；不得只靠basename或suffix放行，空白、parent traversal、額外層級、錯誤prefix或其他任意external `listener.dart`都必須拒絕。Canonical Android Development validation route必須執行此target-path regression contract，且static environment verifier必須監管這個route ownership，避免未來只保留Gradle task卻失去實際gate。

`main.dart`只保留development compatibility用途；正式native build與CI不得用它代表production。

Production維持ADR-014的real API、HTTPS與blocked host限制，並新增template placeholder host拒絕。Staging只允許real API且預設HTTPS。Development可使用mock或real API。

Template repository擁有example base identity、suffix convention、display name、mapping與verification；採用模板的產品必須替換base identity、display name、API endpoint與production signing／Store資料。

Repository lifecycle與Native Product Identity分離。Product repository可以在正式native base identifier尚未確認時保留template placeholder並將Native Product Identity標記為`Pending`；只有manifest-first projection與必要驗證完成後才能標記`Adopted`。此disposition不是新的repository lifecycle state。

Repository CI以static verifier覆蓋三個environment，只建立development與production的Android／iOS代表build。Production代表artifact仍是verification-only，不代表signed、archive或Store distribution。

Production signing、keystore、Apple Team、provisioning、AAB、IPA與Store publishing由未來獨立Decision治理。

## Consequences

- Native environment、entrypoint與product identity可機械驗證且不可靜默錯配。
- Development、staging與production可同時安裝。
- Platform project仍使用原生Gradle／Xcode primitives，不引入跨專案flavor framework。
- Mapping值存在於manifest與native projection，但repository verifier使projection drift成為blocking defect。
- CI成本受代表矩陣控制，staging由static contract覆蓋。
- Template adopter必須以manifest為替換入口，而不是在單一platform手動改identifier。

## Supersession

本Decision不取代ADR-014、ADR-023或ADR-024。

## Related Evidence

- [Native Environment and Product Identity Adoption Guide](../guides/native_environment_adoption.md)
- [Milestone 26 final review](../audits/milestone_26/26-8_final_review.md)

## Last Reviewed Baseline

1.8.0。
