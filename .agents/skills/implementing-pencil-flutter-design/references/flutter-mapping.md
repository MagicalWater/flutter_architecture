# Flutter Mapping

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

Canonical viewport可使用feature-local exact values，但implementation必須是可scroll／可layout的Flutter UI。禁止full-screen raster、整頁`FittedBox`固定畫布縮放、隱藏內容或只為golden成立的layout。Narrow viewport與text scaling必須維持可達、無overflow與合理touch targets。
