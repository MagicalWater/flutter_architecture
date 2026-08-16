---
document_type: migration-manifest
status: accepted
authoritative_for:
  - milestone-40-root-readme-section-preservation
last_reviewed_baseline: 1.20.0
---

# Milestone 40 — Root README Preservation / Migration Matrix

## Purpose

本矩陣在root `README.md`重寫前固定每個既有section的處置、canonical owner與landing-page保留責任。它是migration evidence，不成為current architecture、procedure或project snapshot authority。

Disposition vocabulary：

```txt
retain-summary  → README保留人類可掃讀摘要，detail由canonical owner承擔
route-detail    → README只保留route／CTA，不保留detail contract
remove-history  → 從landing page移除歷史journal，history仍由既有authority保存
merge-summary   → 與其他landing section合併成較短摘要
```

## Section-level matrix

| Source heading | Current responsibility | Disposition | Destination / canonical owner | Landing-page summary required? | Bootstrap-sensitive? | Checker-sensitive? | Semantic preservation assertion |
|---|---|---|---|---|---|---|---|
| `# Flutter Enterprise Architecture Template` | Template名稱與一句話定位 | retain-summary | root README human entry；repository lifecycle由`repository_identity.json` | Yes | Yes | No | Template名稱與企業級可演進Flutter架構起點定位保留；不得把README升格為technical authority。 |
| `## 專案狀態` — Template Baseline | Baseline版本 | retain-summary | `VERSION` + `CHANGELOG.md`；README只呈現baseline | Yes | Yes | **Yes** | 必須保留machine-readable `Template Baseline Version：1.20.0`；product bootstrap需可轉為product version phrase。 |
| `## 專案狀態` — Milestone 1～39 journal | 歷史完成列表 | remove-history | `CHANGELOG.md`、`docs/milestones/README.md`、對應audits | No | No | No | Landing page不再複製完整Milestone chronology；history仍完整可追溯。 |
| `## 專案狀態` — platform table | 平台能力摘要 | retain-summary | `docs/project_context.md`為current snapshot | Yes | Yes | No | Android/iOS Supported與其餘Dependency-ready的高階狀態保留；細部verification/deferred evidence移出首頁。 |
| `## 從此 Template 開始一個新產品` | Newcomer template→product CTA與bootstrap概念 | retain-summary | `docs/guides/template_repository_adoption.md`；native identity detail由`docs/guides/native_environment_adoption.md` | **Yes** | **Yes** | Indirect | `Use this template`保持首要CTA；README只描述最短採用路徑與guide links，不複製Agent/internal Skill procedure。 |
| `## 專案定位` | Target audience、痛點與價值取向 | merge-summary | root README human entry | **Yes** | Yes | No | 轉成`Why this template`，保留邊界清楚、可讀、可維護、企業專案起點等價值，不保留問答式長列表。 |
| `### 架構視覺總覽` | 兩張current architecture視覺摘要的入口 | retain-summary | image bytes=`docs/assets/architecture/*`；technical truth=`docs/project_context.md`+ADR+source | **Yes** | Yes | No | 兩張圖改成inline preview；明示visual summary不取代canonical authority。 |
| `## 技術選型 / Architecture` | Clean Architecture、Feature First、Monorepo、Melos摘要 | merge-summary | root README capability summary；detail由ADR/feature/package docs | Yes | Yes | No | 保留技術方向，不在首頁重新定義dependency contract。 |
| `### Presentation Layer` | UI stack package清單 | merge-summary | app/package manifests + relevant docs | Yes, compact | Yes | No | 納入`What is included`精簡technology stack；不需獨立section。 |
| `### Navigation` | Navigation技術與能力清單 | merge-summary | source + ADR/current snapshot | Yes, compact | Yes | No | 保留typed navigation/guards capability摘要，不複製route contract。 |
| `### Dependency Injection` | DI套件清單 | merge-summary | ADR/current source | Yes, compact | Yes | No | 僅保留Composition Root/DI capability摘要。 |
| `### Model / Code Generation` | codegen工具清單 | merge-summary | package manifests + build guide/commands | Yes, compact | Yes | No | 保留主要工具名稱；generated-file policy不在README重述。 |
| `### Network` — package/capability list | Dio/Retrofit/auth refresh等能力 | merge-summary | `docs/project_context.md` + ADR + package source/docs | Yes, compact | Yes | No | `What is included`保留typed API/auth refresh等高階能力；完整401/session replay contract移出README。 |
| `### Network` — environment build commands / URL rules / signing notes | Native environment與verification procedure | route-detail | `docs/guides/native_environment_adoption.md`、CI guides、machine manifests | No | **Yes** | No | 首頁不保存development/staging/production命令、API URL限制、signing細節；提供採用／operations route即可。 |
| `### Storage` | SharedPreferences/Drift/platform storage摘要 | merge-summary | `docs/project_context.md` + ADR/source | Yes, compact | Yes | No | 保留secure/local persistence能力摘要；opener/platform實作detail不進landing。 |
| `### Reactive` | RxDart技術清單 | merge-summary | dependency manifests/source | Optional compact | Yes | No | 併入technology summary，不需要獨立責任。 |
| `### Design System` | Theme/design-system capability長清單 | merge-summary | `packages/design_system` source/docs + `docs/project_context.md` | Yes, compact | Yes | No | 保留reusable design system、themes、responsive/accessibility regression摘要；細項移出首頁。 |
| `### Localization` | Locale/localization capability長清單 | merge-summary | app source + current snapshot | Yes, compact | Yes | No | 保留English/zh_TW與runtime locale switching摘要；解析規則/ownership detail不複製。 |
| `## 專案結構` root tree | Repository layout | retain-summary | filesystem itself + package/app READMEs | Yes | Yes | No | 保留短版tree，只呈現`apps/`、`packages/`、`docs/`與主要packages。 |
| `### apps/flutter_architecture` | App responsibility與Catalog cache detail | route-detail | app source、Feature docs、`docs/project_context.md` | Yes, one-line | Yes | No | README只說App是Composition Root與reference application；Catalog cache細節移出。 |
| `### packages/core` | core responsibility examples | merge-summary | package source/README | Yes, one-line | Yes | No | Repository Structure用一句話表示shared primitives。 |
| `### packages/api_client` | API client responsibility examples | merge-summary | package source/README | Yes, one-line | Yes | No | 用一句話表示transport/network boundary。 |
| `### packages/auth` | Auth ownership contract | route-detail | package source/README + ADR/current snapshot | Yes, one-line | Yes | No | landing僅摘要reusable auth/session package；presentation/domain/data細分不在首頁重述。 |
| `### packages/design_system` | Design-system ownership與能力清單 | route-detail | package source/README + current snapshot | Yes, one-line | Yes | No | landing只摘要reusable design-system package。 |
| `## Demo Flow` | Reference application頁面與行為示例 | merge-summary | app source/current snapshot | Optional | Yes | No | 不再以四頁需求journal呈現；需要時在`What is included`用一句reference app描述。 |
| `## Runtime Flow` | Clean Architecture dependency chain | retain-summary | ADR/current architecture authority | Yes | Yes | No | 保留簡短`Presentation → Domain → Data → Infrastructure`概念或由圖表承擔；不得把ASCII flow當新authority。 |
| `## 快速開始` — workspace prerequisite/config detail | SDK/workspace結構與resolution說明 | route-detail | root `pubspec.yaml`、Melos config、developer guides | No | Yes | No | Landing Quick Start不複製workspace schema；只保留最短可執行命令與必要版本前提。 |
| `### 1. 安裝 dependencies` | `dart pub get` | retain-summary | executable command | Yes | Yes | No | Quick Start保留。 |
| `### 2. 清理 workspace 狀態` | troubleshooting clean commands | route-detail | developer/operations docs | No | Yes | No | 從first-run path移除；需要時由Guide提供。 |
| `### 3. 產生程式碼` | build_runner command | retain-summary | workspace script | Yes | Yes | No | Quick Start保留核心codegen命令。 |
| `### 4. 分析與測試` | analyze/full-test commands | merge-summary | AGENTS/testing governance + scripts | Yes, corrected | Yes | No | README可提供基本verification入口，但不得暗示每次change固定跑full tests；應route testing governance/planner。 |
| `### 5. Build 驗證` | bundle命令 + 大量runtime/security evidence | merge-summary | CI/build guides + project_context/audits | Yes, command only | Yes | No | Quick Start可保留基本build；runtime smoke、OTP/biometric/security caveats移至current snapshot/evidence owner。 |
| `## Flutter Web 注意事項` | Web worker regeneration、runner建立、opener detail | route-detail | Web/platform guide/current snapshot/source | Yes, limitation only | Yes | No | Landing只保留Web=`Dependency-ready`與non-goal；完整procedure不留首頁。 |
| `## 文件導覽` | Documentation routes與authority說明 | retain-summary | `docs/README.md` | **Yes** | Yes | No | Landing保留精簡documentation links；taxonomy、AI最小讀取集、完整task routes由`docs/README.md`/`AGENTS.md`承擔。 |
| `## 開發原則` | Architecture/語言/validation規則摘要 | route-detail | `AGENTS.md`、ADR、governance Guides | No, except value language | Yes | No | 可讀性/邊界作為產品價值保留；具約束性的Bloc/Guard/UseCase/validation規則從README移除。 |
| `## 開新對話（給 ChatGPT）` | AI最小讀取集與工作入口 | route-detail | `AGENTS.md` + `docs/README.md` + Agent quick-start Guide | No | No | No | 完整移出GitHub human landing body，只在Documentation區提供AI contributor/agent route link即可。 |

## Cross-cutting preservation assertions

### P-40-1-A — No ownerless deletion

任何從README移除的current detail都必須已有canonical owner。Task 40-2若發現某段detail無owner，不得直接刪除；先回本矩陣補owner/disposition並review。

### P-40-1-B — Baseline machine compatibility

`Template Baseline Version：1.20.0`為checker-sensitive文字，Task 40-2不得改寫成checker無法辨識的badge-only或自然語言版本。

### P-40-1-C — Template bootstrap compatibility

下列README內容屬bootstrap-sensitive：repository kind／template positioning、baseline version、platform summary、`Use this template` CTA、architecture/capability summary。Task 40-4必須驗證產品化後不留下template current-state矛盾。

### P-40-1-D — Human / Agent route split

Root README服務GitHub訪客與採用者；AI強制入口由`AGENTS.md`與`docs/README.md`擁有。README可連結Agent Guide，但不複製mandatory reading contract。
