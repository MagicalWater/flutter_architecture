# Flutter Mapping

## Admission

本reference只接收已由[Asset / Vector / Typography Mapping & Provenance](asset-and-typography-mapping.md)完成representation classification與provenance resolution的items。

這裡不重新決定font fallback、approximate icon visual equivalence、vector vs raster、static vs dynamic drawing或derived asset provenance。任何required representation仍unresolved時，不得進入Flutter owner mapping。

若accepted Design／Plan將item標為critical，還必須先通過initiative-local`implementation_mapping.json` machine validation。`verified-equivalent`沒有evidence、`intentional-deviation`沒有approval或任何critical mapping仍`unresolved`時，不得以手寫Flutter owner mapping繞過validator。

## Mapping order

每個Pencil item只能映射到一個明確owner：

```txt
existing ColorScheme／DsSemanticColors
existing DsSpace／DsRadius
feature-local visual specification
generated localization key
approved icon package
feature-local widget
decorative Flutter primitive
```

沒有第二consumer evidence，不得把單畫面數值提升為global Design System token。

## Architecture boundary

- App保持唯一Composition Root。
- 使用Feature First；presentation-only proof只建立feature README、page、view、visual spec、copy與widgets。
- Visible strings進既有ARB／generated localization。
- Base theme與semantic colors優先使用既有Design System。
- Route遵守accepted Plan的guard、initial與Shell boundary。
- Icon identity以accepted mapping為準；Taste Skill的Web-specific icon bans不具權威。

## Screen layout model gate

每個 accepted Pencil screen root 在 production mapping 前，必須於 initiative-local `implementation_mapping.json` 的 `screen_layouts` 提供 resolved layout model。

允許值只有：

```txt
constraint-relationship
intentional-spatial-canvas
unresolved
```

一般 App screen 預設使用 `constraint-relationship`；canonical page coordinates 只可作 design evidence，不能成為 runtime page coordinate system。`intentional-spatial-canvas` 只限 map／game board／diagram editor 等真正 spatial surface，且必須有 accepted `approval_ref`。`unresolved` fail closed。

Local component 可以使用 bounded overlay，但 bounded overlay 不取得 whole-screen page-flow ownership，也不構成 screen-root layout model。

## Presentation-only判定

若畫面沒有business state、network、database、persistence或跨畫面domain behavior，就不得為了「展示Clean Architecture」虛構：

- Domain entity
- Repository interface／implementation
- Use Case
- Data source／DTO／mapper
- Bloc／Cubit
- DI registration

只有真實behavior需要時才由中央Requirement／Design增加layer。

Mapping matrix只決定owner，不等於production implementation admission。完成mapping後必須先依accepted Plan建立widget／route／localization failing tests並觀察正確RED；在此之前`CODE_STARTED`必須視為`NO`。Test fixture／test source不算Flutter production source。

## Fidelity與responsiveness

Canonical viewport是**design/comparison space**，不是**Flutter logical breakpoint**。一個accepted screen只能有一套whole-screen visual component tree；canonical、runtime與narrow mode都必須由同一組screen components建立。禁止以breakpoint切換到**parallel whole-screen visual renderer**。

正常portrait runtime先由accepted design width導出shared `visualScale`，把visible width、height、offset、padding、gap、radius、stroke、shadow、icon與feature-local typography投影到真Flutter widgets。Owner mapping仍遵守Design System／feature-local boundary；projection不授權另造顏色、container hierarchy或runtime-only visual identity。

這不是blind canvas scaling。禁止full-screen raster、**top-level `FittedBox`、`Transform.scale`**、隱藏內容或只為golden成立的layout。Interactive hit region與accessibility content可以大於visible projected geometry；text scale、localization、orientation或極窄width真的需要時，只能在同一component內做content-aware adaptation。

Narrow viewport與text scaling仍必須維持可達、無overflow與合理touch targets，但這些只屬**layout health**。Supported runtime的**runtime fidelity**必須由visual evidence另外驗證，不能用no-overflow冒充設計還原。
