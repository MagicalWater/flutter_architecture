# Asset Runtime Ownership & Theme-aware Representation Integration — Requirement Decision

## Request

補齊 repository 目前尚未正式定義的 runtime asset access 與 theme-aware asset representation selection，並採用 FlutterGen 作為 typed asset accessor generator。

## Problem

Current repository 已有成熟的 Design System／Theme Identity、UI Design Ownership、Pencil representation/provenance contract，但 runtime visual asset access 尚缺一個 stable owner contract：

- `DsThemeDefinition` 只建立 Light／Dark `ThemeData`，沒有 theme-aware visual asset contract。
- App 尚未宣告 production visual assets，也沒有 typed generated accessor。
- 未來產品若直接以 `Image.asset('assets/...')` 分散 path，consumer 會同時知道 asset identity 與 bundle path。
- 若 Theme Identity／brightness 需要選擇不同 artwork，current architecture 沒有 resolver；consumer 只能自行 switch theme ID / brightness。
- 既有 representation/provenance authority 不應被 runtime constants class 或 FlutterGen 取代。

## Expected behavior

1. FlutterGen 只負責 package-local typed asset accessor 與 path safety，不成為 semantic ownership、Theme 或 provenance authority。
2. Asset runtime owner 依 responsibility 分為 Design System／App-Product／Feature／smallest component owner；不得建立 mega `AppAssets` 或 generic VisualSpec catch-all。
3. Consumer 優先引用 generated typed asset identity，不直接散落 raw bundle path；只有 tool/framework contract 明確要求 raw path 時才由 generated accessor `.path` 等 resolved API 提供。
4. Theme-aware asset selection 以 stable Theme Identity (`DsThemeId`) 與 resolved brightness / semantic state 作 selection input，不以 raw color value 判斷。
5. Theme-aware selection 不改變 asset ownership：App-owned artwork 留 App、Feature artwork 留 Feature、Design System reusable visual 才由 Design System 擁有。
6. Existing Pencil/source representation provenance 保持唯一 authority：source → transformation → destination → hash → consumer；runtime accessor不得複製 source/hash/provenance metadata。
7. Repository 必須提供一個最小、可驗證的 reference implementation，證明 default/ocean 與 light/dark 可選擇不同 typed image asset，但不建立產品特定大型 artwork portfolio。

## Value

- 消除 runtime raw asset path typo / rename coupling。
- 讓 theme-aware images 與目前多 Theme Identity 架構一致。
- 維持 reusable Design System 與 product/feature asset ownership邊界。
- 避免把 FlutterGen、Asset registry、Theme 與 provenance 混成第二套 visual authority。

## Classification

**Level 4 — Architecture / repository-wide governance**。

Evidence：工作新增 repository-wide runtime asset ownership 與 Theme-aware selection stable contract，涉及 Design System boundary、App Composition Root、Feature/local ownership與既有 representation/provenance authority 的交界。

## Decision

Proceed with formal Design → review → explicit user approval → Implementation Plan → review → explicit user approval → implementation。

User 已明確選定 FlutterGen 作為 generator，這不是 Design 的未決 package selection。

## Scope

- FlutterGen adoption contract與 workspace/package-local generation integration。
- Typed runtime asset access policy。
- Theme-aware asset resolver contract。
- App / Product / Feature / Component ownership rules。
- ADR-018 與必要 current docs/guide sync。
- 最小 reference assets / consumer，僅用來證明 contract。

## Non-goals

- 重做 Color/Theme System。
- 把所有 `Color(0x...)` token 化。
- 建立 global asset provenance registry。
- 把 source/hash/transformation metadata塞入 generated/runtime asset constants。
- 強迫每個 one-off component asset建立 wrapper class。
- 把所有 theme-aware assets 搬進 `packages/design_system`。
- 新增 Pencil visual source或重做 Write Precheck art direction。
- 建立 runtime remote-theme / downloadable asset framework。

## ADR / release disposition

- ADR：**required**。優先 amend ADR-018，因 stable boundary 是 Design System / Theme / local UI ownership 的延伸；只有 Design review 證明 ADR-018 無法清楚承擔時才新增 ADR。
- Release：implementation完成後依 validation planner與 repository release policy做 explicit disposition；本 Requirement 不預設強制發版。
