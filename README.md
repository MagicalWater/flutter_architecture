# Flutter Enterprise Architecture Template

![Flutter Enterprise Architecture Template hero](docs/assets/readme/flutter-enterprise-architecture-hero.png)

一份可直接作為中大型 Flutter 產品起點的企業級架構模板：Clean Architecture、Feature First、Monorepo、可重用 packages、跨平台基礎能力、文件治理與可驗證的開發流程都已整合在同一個 repository。

**Template Baseline Version：1.20.0**

Android：Supported · iOS：Supported · Web / Windows / macOS / Linux：Dependency-ready

> 想直接開始新產品？使用 GitHub 的 **Use this template** 建立獨立 repository，再依 [Template Repository Adoption Guide](docs/guides/template_repository_adoption.md) 完成一次性的 Template → Product bootstrap。

---

## Architecture Overview

這張圖先從產品化角度呈現 App Composition Root、Features、reusable packages、platform adapters、external systems 與 governance route：

![Flutter Enterprise Architecture Template productized topology](docs/assets/architecture/productized-topology.png)

圖是 current architecture 的視覺摘要；完整 current state 以 [Project Context](docs/project_context.md)、canonical ADR 與 production source 為準。

## Dependency Contract

更細的 component ownership 與依賴契約：

![Flutter Enterprise Architecture Template C4 dependency contract](docs/assets/architecture/c4-dependency-contract.png)

核心依賴方向維持：

```txt
Presentation
  ↓
Domain
  ↓
Data
  ↓
Infrastructure / External Systems
```

App 是 Composition Root；可重用 package 透過 constructor injection 表達依賴，不把 App-level DI lifecycle 反向帶進 package。

---

## Why this template

這個 repository 的目標不是把所有 Flutter 專案都做成同一種樣子，而是先把最容易在中大型專案失控的邊界固定下來：

- **清楚的 ownership**：App、Feature、Domain、Data、Infrastructure 與 reusable package 有明確責任。
- **可演進的依賴方向**：Presentation → Domain → Data → Infrastructure，不用靠跨 Feature Bloc 或全域 service 解決耦合。
- **產品化而不是 Demo 化**：環境、身份、Auth、Storage、Localization、Design System、CI、Observability 等都有正式邊界。
- **模板採用流程完整**：從 GitHub Template Repository 建立產品 repo 後，可保留 provenance 並轉成產品自己的 version / identity / infrastructure authority。
- **文件是專案的一部分**：Architecture Decision、current snapshot、Guide、Roadmap、Review evidence 各自有唯一 owner，避免資訊只存在聊天紀錄。
- **驗證成本受治理**：日常變更依 change-aware validation planner 決定 minimum sufficient validation，不把 full workspace test 當每次修改的固定成本。

---

## What is included

| Area | Included baseline |
|---|---|
| Architecture | Clean Architecture、Feature First、Monorepo、Melos / Dart Pub Workspaces |
| Presentation | `flutter_bloc`、`flutter_hooks`、`hooked_bloc` |
| Navigation | `auto_route`、typed routes、Route Guard、nested navigation |
| Dependency Injection | `get_it` + `injectable`，由 App Composition Root 統一組裝 |
| Models / Codegen | `freezed`、`json_serializable`、`build_runner` |
| Network | Dio / Retrofit、Authorization header、refresh token rotation、concurrent 401 single-flight、safe replay |
| Persistence | FlutterSecureStorage、SharedPreferences、Drift / SQLite、Web dependency-ready Wasm path |
| Authentication | Session restore、secure credential storage、OTP step-up、Android biometric-gated local unlock |
| Design System | Reusable theme package、Light / Dark / System、semantic colors、responsive / large-text coverage |
| Localization | English + Traditional Chinese (`zh_TW`)、runtime locale switching、persisted preference |
| Connectivity / Offline | Connectivity state、offline-aware flow、Catalog cache / stale-while-revalidate reference |
| Observability | Production observability foundation與provider boundary |
| CI / Governance | change-aware validation、risk-based test authoring、self-hosted / GitHub-hosted / manual-local profiles |
| Design implementation | Repository-local Pencil → Flutter workflow、representation / provenance / fidelity gates |

完整能力與限制請讀 [Project Context](docs/project_context.md)；stable decisions 請從 [ADR Index](docs/adr/README.md) 進入。

---

## Start a Product

### 1. 建立自己的 repository

在 GitHub repository 頁面使用 **Use this template**，建立新的產品 repository。一般產品採用不使用 Fork 保存 template parent history。

### 2. 完成一次性的 Template → Product bootstrap

Bootstrap 會把 template repository authority 轉成產品 repository authority，包括：

- repository lifecycle / provenance
- product version semantics
- product name
- CI profile / infrastructure disposition
- Android / iOS identity（若納入本次 scope）

正式流程：

- [Template Repository Adoption Guide](docs/guides/template_repository_adoption.md)
- [Native Environment and Product Identity Adoption Guide](docs/guides/native_environment_adoption.md)

Bootstrap 只負責「產品 repository 如何出生」，不替產品決定 MVP、Feature、UI/UX 或產品 roadmap。

---

## Quick Start

在 repository root：

```bash
dart pub get
dart run melos run build_runner
dart run melos run analyze
```

基本 Flutter build 驗證：

```bash
cd apps/flutter_architecture
flutter build bundle
```

日常 change validation 不固定要求 full workspace test。請先依 repository change-aware planner 取得 minimum sufficient validation：

```bash
python tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

再執行 planner 選出的 focused / affected / workspace / platform validation。完整 testing policy 見 [Testing Governance](docs/guides/testing_governance.md)。

---

## Repository Structure

```txt
root/
├─ apps/
│  └─ flutter_architecture/   # reference app / Composition Root
├─ packages/
│  ├─ core/                   # shared primitives / failure / storage abstractions
│  ├─ api_client/             # transport / network boundary
│  ├─ auth/                   # reusable auth / session / token behavior
│  └─ design_system/          # reusable visual foundation
├─ docs/                      # current authority / ADR / Guides / plans / reviews
├─ repository_identity.json
├─ repository_infrastructure.json
├─ VERSION
└─ README.md
```

更細的責任可以直接從各 module README 進入：

- [Reference App](apps/flutter_architecture/README.md)
- [Core Package](packages/core/README.md)
- [API Client Package](packages/api_client/README.md)
- [Auth Package](packages/auth/README.md)
- [Design System Package](packages/design_system/README.md)

---

## Platform Support

| Platform | Status | Notes |
|---|---|---|
| Android | Supported | Native runtime / storage / security / environment verification covered |
| iOS | Supported | Simulator與build verification covered；physical-device biometric acceptance / signing / Store distribution仍為明確deferred scope |
| Web | Dependency-ready | Drift Wasm / worker dependency path存在；repository不把Web runner視為目前正式supported target |
| Windows | Dependency-ready | Architecture / package boundaries已保持可延伸 |
| macOS | Dependency-ready | Architecture / package boundaries已保持可延伸 |
| Linux | Dependency-ready | Architecture / package boundaries已保持可延伸 |

平台current evidence與deferred boundaries以 [Project Context](docs/project_context.md) 為準。

---

## Documentation

文件系統正式入口：**[docs/README.md](docs/README.md)**。

常用 routes：

- [Project Context](docs/project_context.md) — current project snapshot
- [Architecture Decisions](docs/adr/README.md) — stable architecture authority
- [Roadmap](docs/roadmap.md) — active / candidate / closed routing
- [Milestone Routing](docs/milestones/README.md) — milestone artifact index
- [Audits & Reviews](docs/audits/README.md) — review / runtime evidence
- [Design Specs & Plans](docs/superpowers/README.md) — approved design / execution artifacts
- [AI-assisted Development Quick Start](docs/guides/agent_assisted_development_quick_start.md) — 常見開發情境與Agent入口
- [CI/CD Operations](docs/guides/ci_cd_operations.md) — CI、artifact、failure / rollback operations
- [CHANGELOG](CHANGELOG.md) — released version history

AI / coding agent 的強制工作規則由 [AGENTS.md](AGENTS.md) 擁有；root README 不複製 mandatory reading contract 或完整治理流程。

---

## Limitations / Non-goals

這份 Template **不是**：

- 所有產品都必須原樣照搬的唯一 Flutter architecture。
- 已完成 App Store / Play Store signing、distribution 與商店發布的成品 App。
- 所有平台都已具有正式 runner 與 runtime acceptance 的 cross-platform starter。
- Device Binding / Passkey / rooted-device defense / server compromise defense 的安全保證。
- 自動替新產品決定 Feature、MVP、UI/UX 或產品 roadmap 的生成器。
- 要求每個小修改都執行 full repository regression 的流程模板。

它提供的是一個已具備清楚 boundary、產品化採用流程、current documentation authority 與可驗證治理機制的 Flutter 起點；實際產品仍應依自己的 Requirement Decision 演進。
