# Design System Package

`design_system` 是 Flutter Enterprise Architecture Template 的可重用 UI 基礎 package。

Milestone 15 完成後，此 package 提供：

- Spacing、Radius、Elevation、Icon Size primitive tokens。
- success、warning、info semantic color role contract。
- 穩定的 `DsThemeId` value object。
- `DsThemeMetadata`。
- `DsThemeDefinition` Light / Dark ThemeData contract。
- `DsThemeRegistry` default、duplicate 與 fallback validation。

Milestone 15-3、15-4 另提供：

- Production `DefaultThemeDefinition`。
- Production `OceanThemeDefinition`。
- Material 3 Light / Dark `ThemeData`。
- 明確 Typography hierarchy。
- AppBar、NavigationBar、Input、Button、Card、Divider、ProgressIndicator 與 SnackBar themes。
- `DsSemanticColors` success、warning、info foreground / container semantic roles。
- `DsSemanticColors.copyWith` / `lerp` contract。
- Package-internal `DsMaterialThemeFactory`，只共用兩套 production Theme 已證明重複的 Material 組裝。

Ocean Theme 使用獨立 palette 與 semantic colors，並有限度調整 Typography weight 與 radius，證明 Theme Identity 不只是替換單一 seed color。

Milestone 15-5、15-6 提供：

- `DsStatusBanner`：以 neutral、info、success、warning、error tone 顯示非阻塞提示，支援 icon、message 與 optional action。
- `DsConstrainedContent`：統一內容最大寬度、置中與 page padding。
- `DsButtonContent`：供既有 Material Button variants 使用的 idle / loading content，不封裝 callback 或建立 generic button。
- `DsLoadingState`：全頁 loading surface 與 progress Semantics。
- `DsEmptyState`：空資料 surface，支援 Widget icon slot、primary / secondary actions，以及由父層持有捲動時的 `scrollable: false` composition contract。
- `DsBlockingErrorState`：阻斷式錯誤 surface，提供 error Semantics 與 retry actions。
- `DsMessageState`：一般訊息 surface，支援 Widget icon slot 與 actions。

上述 primitives 與 page-state surfaces 只接受純 presentation properties，不依賴 Bloc、Failure、Catalog state 或 Feature entity。Refresh、Append、Revalidation 等 non-blocking failure 不應使用 `DsBlockingErrorState`，而應保留原內容並使用 Status Banner 或 feature-local operation UI。

## Package 邊界

此 package 不依賴：

- App。
- Feature。
- Bloc。
- GetIt / Injectable。
- SharedPreferences 或其他 persistence implementation。

App 仍是唯一 Composition Root。

Feature 只能透過：

```dart
import 'package:design_system/design_system.dart';
```

使用 public API，不應 deep import `lib/src/`。

Raw palette 位於 package internal path，且不由 `design_system.dart` export。Feature 應使用 Material `ColorScheme` 或後續 Milestone 提供的 semantic theme extensions，不得直接依賴 raw palette。

## Milestone 邊界

Milestone 15-2 建立 tokens、Theme identity contract 與 registry；Milestone 15-3、15-4 已加入兩套 production Theme：

```txt
Default Theme  Light / Dark
Ocean Theme    Light / Dark
```

Theme persistence、controller 與 Appearance selector 留在 App，並於 Milestone 15-7 實作。

## Page-state scroll ownership

`DsEmptyState` 預設自行處理 viewport-aware scrolling。當它被放入既有 `ListView`、`CustomScrollView` 或其他由 feature 擁有的 scroll container 時，使用：

```dart
const DsEmptyState(
  title: 'No results',
  scrollable: false,
)
```

這可避免同方向巢狀 scrollable。外層 feature 必須負責捲動、pull-to-refresh 與大型文字內容可到達性。

## 最終 public contract

Milestone 15 完成後，package 保留已由 production consumer 證明的最小 token 與 component 集合；不為理論完整性保留沒有使用者的 spacing、radius、elevation、icon-size token，也不建立 generic form、pagination、search 或 responsive framework。

Blocking Loading／Empty／Error／Message 使用共用 page-state surfaces；Refresh、Append、Revalidation、Logout 等 operation failure 應保留原內容，並使用 `DsStatusBanner` 或 feature-local non-blocking presentation。

Theme preference、persistence、controller 與 Appearance selector 仍屬 App responsibility，並不由本 package提供。Golden 策略只保留少量穩定 Design System gallery fixture；真正的 loading animation、Semantics、callbacks、text scaling 與 Theme matrix由 widget tests保護。

Protected、Profile、Login、Catalog 與 Shell 已於 Milestone 15-8、15-9 導入這些 public contracts；Catalog-specific cache、stale、append、refresh 與 revalidation 語意仍保留在 Catalog feature。

Milestone 15-10 完成 production code hard-coded UI audit、未使用 token 清理、少量 stable gallery golden fixture，以及完整 regression / multi-environment build validation。

## Theme ID Contract

`DsThemeId` 是 persistence 與 registry 共用的穩定識別值，格式為：

```txt
^[a-z][a-z0-9_-]*$
```

合法範例：`default`、`ocean`、`brand_v2`、`brand-v2`。

前後空白、大寫字母與其他符號會直接被拒絕，不會隱式 trim 或轉小寫。`DsThemeMetadata.displayName` 也不可為空或只有空白。
