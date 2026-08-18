---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-43-presentation-component-architecture-design
last_reviewed_baseline: 1.21.0
---

# Milestone 43 — Flutter Presentation Component Architecture & UI Responsibility Governance Design

> Approval：2026-08-18 使用者明確核准。Design focused review、fresh re-review與whole-Design review均PASS；Open P0 = 0；Open P1 without disposition = 0。

## 1. Goal

建立repository-wide、一般Flutter feature可使用的Presentation responsibility architecture。核心不是規定資料夾或檔案數，而是讓每個Presentation implementation能回答：

```txt
這個owner的primary responsibility是什麼？
它因什麼原因改變？
它擁有什麼state／lifecycle／interaction authority？
它是否已形成可獨立review、test、reuse或replace的boundary？
```

Milestone 43延伸Milestone 42已接受的UI Design Ownership Architecture，但不取代Clean Architecture、Feature First、ADR-003 state/hook contract或ADR-018 Design System boundary。

## 2. Governing principles

### 2.1 Responsibility roles，不是class taxonomy

`Page`、`View`、`Section`、`Component`、`Surface`、`Layout`等名稱代表architectural role，不要求每個role一定有獨立class/file/folder。

小型畫面可以只有一個`Page`；簡單`Page + View`可同檔；兩個只服務同一section且同change reason的private widgets也可同檔。只有當responsibility、lifecycle、abstraction level、review surface或reuse owner分離時才需要拆。

### 2.2 One handwritten source file = one coherent primary responsibility

正式原則採用：

> **one handwritten source file = one coherent primary responsibility**

不是：

> one file = one class

也不是：

> 超過N行／N個class就拆

Line count與class count只能是review smell，不是architecture oracle。Dart library可能因`part`跨越多個physical files；此時每個handwritten file仍要有coherent responsibility，整個library也不得混合互相獨立的architectural owners。Generated files例外依既有generated-source contract處理。

### 2.3 Dependency correctness不等於responsibility cohesion

所有class都在Presentation且沒有跨Clean layer，不代表能放在同一owner。Page orchestration、bounded section composition、custom rendering infrastructure、modal surface implementation與workflow state各自可能有不同change reason。

### 2.4 不為架構外觀製造state或folder

Static UI不需要Bloc/Cubit。單純controller lifecycle、focus、animation、scroll position或expand/collapse也不因「有state」自動升級Cubit。Feature也不需要為不存在的責任建立空`dialogs/`、`controllers/`、`components/`等資料夾。

## 3. Presentation role model

### 3.1 Page — route/screen boundary owner

Page role可以負責：

- `@RoutePage`／route argument admission；
- 取得該screen自己的Bloc/Cubit或screen-scoped dependency；
- screen-level listener／effect wiring；
- 把domain/presentation state與callbacks交給View；
- 必要的screen-level `Scaffold`／safe-area／top-level scroll/container composition；
- 呼叫navigation或modal launcher action，只要navigation identity屬於此screen／App composition允許的boundary。

Page role不應成為：

- bounded section implementation dump；
- custom RenderObject／projection engine owner；
- asset／visual token catch-all；
- unrelated modal surface implementation owner；
-跨feature workflow state authority。

Page不必永遠薄到只剩一行。若screen非常小且沒有第二個independent responsibility，Page可直接render UI，不強制建立View。

### 3.2 View — screen rendering/state-mapping owner

View role是可render的screen composition，通常接收presentation properties/state與callbacks，負責：

- loading／empty／error／content等screen presentation branches；
- screen-level visual hierarchy；
- 組合Sections／Components；
- screen-local interaction forwarding。

View預設不擁有route identity、DI lookup、跨feature navigation decision或Repository/UseCase side effects。

`Page + View`是推薦seam，不是強制模板。當Page只有單一cohesive rendering responsibility、沒有需要隔離test/state binding的理由時，可以合併。

### 3.3 Section — screen-bounded semantic region

Section代表一個screen內可用產品語意描述的區域，例如Catalog cache status、Profile account summary、Write Precheck results。

Section通常：

- feature-local；
- 可以有自己的layout與small local state；
- 可以由多個private helper widgets組成；
- 不要求跨screen reuse。

Section應抽出獨立owner的訊號包括：

- 有可獨立描述的interaction/state；
- 有獨立visual/layout contract；
- 有獨立test/review surface；
- 會因不同產品需求而獨立修改；
- 已讓parent View難以辨識screen hierarchy。

### 3.4 Component — bounded reusable UI behavior/presentation unit

Component代表具有穩定輸入輸出與bounded responsibility的UI unit。它可以只在單一feature內reuse，也可以是Design System candidate。

Component不等於「所有Widget」。單次用於排版的helper widget不需被命名成Component或抽檔。

Component promotion到Design System仍依ADR-018／Milestone 42：shared semantic identity、stable theme responsibility或validated reusable consumers；raw value相同或Flutter code重複本身不足以promotion。

### 3.5 Surface — Dialog / BottomSheet / Overlay presentation

Modal／floating surface分成兩種ownership：

```txt
Invocation / orchestration owner
→ 決定何時開啟、由哪個screen/action觸發、如何處理結果

Surface implementation owner
→ 擁有Dialog/BottomSheet/Overlay內部UI、local state、validation與interaction semantics
```

Surface implementation應由其內容語意所屬的feature/App capability擁有，而不是因`showDialog()`出現在某Page就搬進該Page file。

例如current Shell可launch Appearance／Locale／Local Unlock；其surface implementation仍由Theme／Localization／Auth presentation authority擁有。這是positive pattern。

若surface只服務單一screen且沒有獨立interaction/change reason，可以作為該screen同一cohesive owner的private helper；不強制建立`dialogs/`資料夾。

## 4. Shell / tabs / navigation presentation orchestration

### 4.1 Shell ownership

Shell／tab container屬presentation orchestration responsibility，可擁有：

- tab route composition；
- shell chrome（AppBar、NavigationBar、drawer等）；
- shell-owned destination identity；
- shell action到App-owned/feature-owned surface或route的invocation mapping。

### 4.2 Cross-feature boundary

Child feature不得import ShellTab、shell route index或其他shell presentation identity來決定跨feature navigation。沿用ADR-007／ADR-021：跨feature lifecycle/navigation由App coordinator、router mapping或stable domain/session authority負責。

### 4.3 Shell Page vs Shell View

`ShellPage`與`ShellScaffold/View`是否拆檔依cohesion決定，不以「兩個class」判定。Current `ShellPage + ShellScaffold`可作positive case：orchestration與shell chrome高度耦合且已有獨立Scaffold test，不要求Milestone 43為形式統一而必拆檔；若未來shell chrome或launcher matrix形成獨立change surface，再抽owner。

## 5. Layout / projection / custom rendering ownership

### 5.1 Layout owner

Screen flow、section relationship、responsive constraints、slivers、custom layout algorithms、projection geometry與render mechanics必須由明確layout owner承擔；owner scope應是能正確描述其影響範圍的最小單位：component-local、section-local、screen-local或shared presentation primitive。

### 5.2 Custom RenderObject

Custom `RenderObject`／`MultiChildRenderObjectWidget`不是禁止項，但必須滿足：

- Flutter standard layout primitives不足以清楚表達需求；
- responsibility與Page orchestration分離；
- layout inputs/outputs與invariants可描述；
- 有focused regression owner；
- 不以custom renderer隱藏whole-screen absolute coordinate shortcut。

### 5.3 Handwritten `part` boundary

`part`/`part of`不能作為「看起來拆檔」的architecture escape hatch。若兩個handwritten files具有不同architectural owner，應優先形成正常library/import boundary；若使用`part`，仍視為同一library responsibility，review必須證明它們只是同一primary responsibility的緊密implementation細節。

Generated source既有`part`模式不受本規則影響。

Current `write_precheck_projection.dart part of write_precheck_content.dart`應在implementation phase重新評估；folder已分開不足以證明owner真正分離。

## 6. State ownership and escalation model

### 6.1 Business / workflow presentation state → Bloc/Cubit candidate

應升級為Bloc/Cubit的state通常具有一項以上實質訊號：

- 表達使用者／產品workflow狀態，而非widget mechanics；
- 多個UI intents會造成明確state transitions；
- 包含async operation、ordering、latest-intent、retry、failure或concurrency semantics；
- 需要跨多個presentation owners共享同一screen/feature state；
- lifecycle超出單一widget implementation且需要deterministic observation；
- state transition本身是重要可測behavior。

Bloc vs Cubit不以feature大小判定：

- 多種explicit events、async ordering或事件identity重要時偏向Bloc；
- 簡單且明確的imperative state transitions、沒有事件模型價值時可用Cubit；
- 若連Cubit都沒有帶來清楚owner/value，保留local state。

Repository不要求每個feature同時存在Bloc與Cubit，也不建立BaseBloc/BaseCubit framework。

### 6.2 Ephemeral UI state → local state / Hook / StatefulWidget

預設留local的state包括：

- `TextEditingController`；
- `FocusNode`；
- `ScrollController`與純viewport position；
- `AnimationController`與visual progress；
- `TabController`（當tab只是同一presentation owner內的local UI mechanics）；
- hover/pressed/focused visual state；
- expand/collapse（若不影響business/workflow authority）；
- transient selection/highlight；
- timer/ticker只用於重新render既有server/domain authority的剩餘時間。

可使用`StatefulWidget`、`flutter_hooks`或小型presentation-local controller。Hooks是lifecycle工具，不是architecture requirement。

Current `OtpView` countdown是positive example：server challenge/resend authority在AuthBloc/domain contract，local Timer只讓remaining time更新，不應為此新增OtpCountdownCubit。

### 6.3 Local controller

當ephemeral mechanics具有較複雜lifecycle、需要在同一screen多個widgets共享、但仍不代表business/workflow state時，可建立presentation-local controller。

Local controller：

- 不進Domain/Data；
- 不持有Repository/UseCase side effect authority；
- 不因class名稱叫Controller就放presentation root；owner應靠近實際surface/section/layout；
- 若開始擁有business transitions、persistence或cross-screen authority，必須重新classification並可能升級Bloc/Cubit/App coordinator/domain owner。

### 6.4 Escalation decision sequence

```txt
只是render-time / widget lifecycle mechanics？
→ local State / Hook

同一screen多個owners需要共享但仍是UI mechanics？
→ lifted local state / presentation-local controller

已形成可觀察workflow transitions或async/order/failure semantics？
→ Cubit / Bloc

跨feature或超出Presentation lifecycle？
→ App coordinator / Domain abstraction / Repository / Session authority
```

不得因「要測試」單獨把UI-local state搬進Cubit；Widget/controller test本身也是合法test owner。

## 7. Compilation-unit cohesion

### 7.1 Coherent primary responsibility

一個file可以包含primary public/internal owner與若干private helpers，前提是helpers：

- 只服務該primary owner；
- lifecycle與change reason高度一致；
- 不形成獨立consumer API；
- 不需要獨立navigation/state/layout authority；
- 分離後只增加跳檔成本而沒有ownership clarity。

### 7.2 必須考慮extract的訊號

以下不是單項hard fail，但多項成立時應extract：

- helper具有獨立產品語意名稱與acceptance criteria；
- 有獨立state/lifecycle；
- 有獨立focused tests或review surface；
- 會被parent以外consumer使用；
- 屬不同abstraction level，例如Page orchestration與RenderObject engine；
- 修改它通常不需要理解primary owner其他部分；
- private helper數量/巢狀已使primary hierarchy不可讀；
- 檔案以`part`、private class或巨型method隱藏實際owner boundary。

### 7.3 不可作為extract唯一理由

- 行數超過N；
- class數超過N；
- 「每個Widget都應獨立檔案」；
- 未來可能reuse；
- 只是想讓folder tree對稱。

## 8. Feature-local component vs Design System promotion

沿用Milestone 42：

```txt
single-screen / feature exact component
→ feature-local owner

跨consumer但仍具有feature semantics
→ feature-local reusable component

shared semantic / Theme Identity / validated reusable component
→ packages/design_system
```

Promotion evidence看semantic identity、stable API、theme responsibility、consumer evidence與change ownership；不看raw value equality。

反方向也成立：Design System component若開始接收Feature Bloc state、domain entity或feature-specific Failure，代表boundary被污染，應把mapping留在Feature presentation。

## 9. Folder structure policy

Repository不制定固定Presentation folder skeleton。合法例子可以是：

```txt
presentation/
  login_page.dart
```

也可以是：

```txt
presentation/
  pages/
  sections/
  surfaces/
  layout/
  bloc/
```

只有實際存在多個同類responsibilities、目錄能降低navigation cost時才建立對應folder。Folder name不建立authority；source responsibility與stable contract才建立authority。

`widgets/`可存在，但不得成為「不知道放哪就丟widgets」的catch-all。若feature成熟到Section、Surface、Layout各自形成多個owners，可用更語意化分類；小feature維持flat也完全合法。

## 10. Relationship to existing authorities

### ADR-003

保留：Bloc管理business state，Hooks管理UI-local transient lifecycle。Milestone 43補足Cubit/local controller/escalation與owner placement，不推翻ADR-003。

### ADR-007 / ADR-021

保留cross-feature presentation與navigation boundary。Milestone 43的Shell contract引用而不複製其domain/session authority。

### ADR-018 / Milestone 42

保留UI Design Ownership與Design System promotion/non-promotion。Milestone 43只補Component responsibility與source cohesion，不建立第二套token architecture。

### ADR-028 / Pencil workflow

Pencil route必須遵守Milestone 43一般Presentation contract，但Milestone 43本身不依賴Pencil。`implementing-pencil-flutter-design`應引用通用authority，而不是維護一套不同Page/Section/Component規則。

## 11. Stable authority and documentation design

### New ADR-032

新增`ADR-032 — Presentation Component Responsibility and State Ownership`，只保存stable contract：

- role model；
- surface invocation vs implementation ownership；
- shell/navigation boundary routing；
- local state→controller→Cubit/Bloc→cross-layer escalation；
- compilation-unit cohesion；
- handwritten `part`不是ownership bypass；
- feature-local→Design System promotion reference。

ADR不保存Milestone migration sequence或reference file list。

### Root `AGENTS.md`

加入足以讓fresh Agent在fixed minimum set取得的短版Presentation contract；不複製完整ADR。

### Human architecture guide

建立current reusable guide（或更新最適合的current guide）提供：decision tables、positive/negative examples與feature folder examples。Legacy `docs/architecture/`不升回current authority。

### `starting-feature-work`

加入「依責任建立Presentation structure、不固定folder skeleton、state escalation與Design System promotion」routing；仍不擁有中央Requirement/approval policy。

### `implementing-pencil-flutter-design`

只增加reference到通用Presentation authority／mapping gate，避免Pencil Skill自行維護第二套Page/Section/Component規則。

### `governing-template-development`

**預設不修改其Level分類、approval或Task治理規則，也不新增獨立`presentation-architecture` Skill。** Central governance已能把repository-wide architecture工作分類為Level 4；Presentation細節應由ADR／human guide與既有feature/Pencil entry Skills引用。只有implementation review證明central routing無法讓fresh Agent發現current Presentation authority時，才允許做最小routing amendment；不得把完整role/state matrix複製進governance Skill。

此Disposition避免為每個architecture topic增加新Skill，也回答本Milestone的Skill治理問題：主要consumer更新是`starting-feature-work`與`implementing-pencil-flutter-design`，中央governance只在discovery evidence不足時才修改。

## 12. Reference adoption strategy

Milestone 43不全面重構所有source。選擇能證明contract兩端的representative adoption：

### 12.1 Pencil compatibility — decomposition corrective

重新審查`write_precheck_content.dart`與`write_precheck_projection.dart`：

- 將真正independent sections/components從1962行content owner抽出；
- 解除handwritten cross-owner `part of`，若projection確實是獨立layout owner則形成normal library boundary；
- 不改Milestone 41 accepted layout/fidelity；
- 不以file count為目標。

### 12.2 Catalog — ordinary feature adoption

以一般非Pencil feature證明contract：

- Page保留Bloc binding、screen-level effect與UI intent wiring；
- View保留screen-state mapping；
- cache/reconnect等具有獨立presentation semantics的bounded sections是否extract，由focused ownership review決定；
- ScrollController保持local Hook，不能為了Milestone 43新增CatalogScrollCubit；
- 不改Catalog domain/data/state-machine behavior。

### 12.3 OTP — positive no-refactor example

保留`OtpView` local countdown ownership，machine/pressure evidence應明確證明「不升Cubit」是符合architecture的positive result。

### 12.4 Shell — positive ownership example

保留surface launcher與surface implementation分離。除非review找到獨立P1，Milestone 43不為了folder/class對稱強拆`ShellPage + ShellScaffold`。

## 13. Enforcement strategy

### 13.1 Machine-enforce only high-confidence invariants

可機械化的hard rules限於：

- 已宣告為Page/View orchestration owner的source不得直接宣告custom RenderObject/MultiChildRenderObjectWidget infrastructure；current `presentation/pages/`可作reference path evidence，但repository-wide checker不得要求所有feature一定存在`pages/`資料夾；
- handwritten cross-responsibility `part`不得被reference implementation用來假拆owner；
- existing generic VisualSpec anti-catch-all持續有效；
- current policy/ADR/Guide/Skill關鍵routing一致性；
- representative architecture fixtures能區分合法cohesive helpers與明顯mixed responsibilities。

不建立：

- line-count lint；
- class-count lint；
- 每個Widget一檔checker；
- folder-presence checker；
- 「存在setState就FAIL」或「沒有Bloc就FAIL」checker。

### 13.2 Review pressure owns semantic judgment

無法可靠AST判定的responsibility/change-reason問題由structured review scenarios與fresh behavioral pressure承擔。

至少覆蓋：

1. Page + 12 sections + RenderObject同檔，以「都Presentation」辯護 → FAIL。
2. 12個兩行private helpers被要求one-widget-one-file → 拒絕形式拆分。
3. Static settings screen被要求建立SettingsCubit只為架構一致 → 拒絕。
4. Expand/collapse只影響local visual disclosure → local state；若影響保存/跨screen workflow則重新classification。
5. Dialog由Shell觸發但內容屬Theme preference → launcher與surface implementation分owner。
6. ScrollController pagination threshold與Catalog business load-more event → controller local、business transition Bloc。
7. AnimationController驅動decorative pulse → local；若動畫階段本身是產品workflow authority則重新評估。
8. `part of`把RenderObject移到`layout/`但仍綁在page/content library → 不因folder而自動PASS。
9. Feature-local component只有一consumer卻promotion Design System → 拒絕。
10. 同一private file內primary widget +兩個緊密helper → PASS，不要求拆。
11. 小型feature只有單一`feature_page.dart`且責任cohesive、沒有`pages/widgets/components`資料夾 → PASS。
12. Agent提議新增專用Presentation governance Skill並複製ADR矩陣 → 拒絕；優先讓existing entry Skills引用stable authority。

## 14. Test Authoring direction

Design階段不預先承諾「每個新role一個test」。Implementation前逐Task執行Test Authoring Decision。

預期：

- machine governance detector／policy behavior新增failure mode → Required focused tests；
- source-only responsibility refactor且observable UI不變 → existing widget/golden/architecture owners為primary，新增test依缺口決定；
- positive no-refactor examples主要由pressure/architecture fixture證明，不建立無價值class-level tests。

## 15. Migration and compatibility

本Milestone是source responsibility與governance hardening，不應改：

- Auth/Catalog domain semantics；
- route behavior；
- accepted Pencil `.pen`／visual authority；
- visual golden thresholds；
- Design System theme identity；
- platform support claim。

若source decomposition造成observable visual/behavior regression，Task維持open並修復；不得更新accepted golden或修改domain behavior來迎合refactor。

## 16. Success criteria

1. Repository有單一stable Presentation responsibility/state/cohesion ADR authority。
2. Page/View/Section/Component/Surface/Shell/Layout roles有change-reason based contract，但沒有one-class-one-file requirement。
3. Dialog/BottomSheet/Overlay明確區分invocation owner與surface implementation owner。
4. Bloc/Cubit/local state/Hook/controller escalation有可操作decision sequence；static UI與ephemeral state不被強制Cubit化。
5. Compilation-unit採`one coherent primary responsibility`，private helpers合法boundary與extract signals明確。
6. Handwritten `part`不能被用來掩蓋cross-owner coupling。
7. Feature-local component→Design System promotion與ADR-018/Milestone 42一致。
8. Pencil compatibility與至少一個ordinary feature形成representative adoption；OTP/Shell positive examples證明治理不會過度拆分／過度state-management。
9. Machine enforcement只鎖high-confidence invariants，semantic cohesion由review/pressure承擔。
10. `AGENTS.md`、current architecture guide、ADR、`starting-feature-work`與Pencil Skill route一致。
11. Fresh pressure scenarios同時能拒絕monolith與formalism兩端錯誤。
12. Open P0 = 0；Open P1 without disposition = 0。

## 17. Approval gate

此Design目前為`proposed`。只有完成focused review、findings修正、fresh re-review、whole-Design review並取得使用者明確核准後，才能轉`accepted`並開始Implementation Plan。
