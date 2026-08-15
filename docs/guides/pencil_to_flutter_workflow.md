---
document_type: guide
status: active
authoritative_for:
  - pencil-to-flutter-human-workflow-guide
last_reviewed_baseline: 1.19.0
---

# Repository-local Pencil-to-Flutter Workflow Guide

## Purpose and authority

本Guide是「已核准 `.pen` 如何進入此Flutter模板實作流程」的人類操作入口。它不擁有Requirement分類、Design／Plan核准、`.pen`結構語意、Flutter架構或release policy。

Authority順序：

```txt
AGENTS.md
→ governing-template-development
→ accepted Requirement／Design／Plan
→ ADR-028 + visual authority manifest
→ implementing-pencil-flutter-design
→ source／tests／runtime evidence
→ 本Guide的人類操作說明
```

詳細可執行Pencil admission、mapping與stop conditions由：

- [ADR-028](../adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md)
- [`.agents/skills/implementing-pencil-flutter-design/SKILL.md`](../../.agents/skills/implementing-pencil-flutter-design/SKILL.md)

擁有。本Guide只把這些authority串成可重複的日常流程。

## When to use

使用本流程的必要前提是：

- 工作已被Requirement Decision分類為repository-local Pencil-to-Flutter implementation。
- Design與Implementation Plan依Level要求完成review並已核准。
- 使用managed worktree執行。
- active `.pen`已進repository並由manifest鎖定。
- 需要從Pencil structure／visual authority映射成Flutter，而不是只把PNG目測抄成畫面。

典型輸入依工作型態分成兩種。

模板中的isolated proof／compatibility initiative可以使用：

```txt
docs/design_sources/<initiative>/source.pen
docs/visual_authority/<initiative>/manifest.md
```

模板採用為實際產品後，預設使用product-level canonical master：

```txt
docs/design_sources/app/app-master.pen
docs/visual_authority/app/manifest.md
```

此時Flutter feature只引用`app-master.pen`中的對應screen／frame／flow，不因Feature First code ownership自動拆成`auth.pen`、`profile.pen`、`settings.pen`。只有經Requirement Decision確認檔案規模、效能、多人設計ownership或其他明確理由時，才允許把product authority拆成多份`.pen`。這個拆分決策屬design authority governance，不由Flutter目錄結構自動決定。

### Non-triggers

以下情況不直接使用本流程：

- 一般Flutter feature沒有accepted `.pen`。
- Figma或image-only概念稿仍在需求／設計探索階段。
- 已完成UI只做bounded bug fix。
- 只要求產生概念圖或brand direction。
- `.pen`仍在external path、沒有repository manifest或hash admission。
- Design／Plan尚未取得必要核准。

這些工作先回到`governing-template-development`；新功能可由`starting-feature-work`快捷入口委派中央治理。

## Required accepted inputs

開始Pencil操作前至少確認：

```txt
accepted Requirement Decision
accepted Design（如分類要求）
accepted Implementation Plan（如分類要求）
managed worktree + expected branch／HEAD
repository-local source.pen
accepted visual authority manifest
skills-lock.json（如使用third-party Skills）
Pencil／Executor integration可用
```

聊天中的「這份已核准」或external absolute path不能替代repository evidence。找不到accepted artifact時保持blocked，不推定approval。

## Repository source and manifest layout

Repository支援兩種合法layout；兩者共享同一套visual authority、hash、Pencil MCP與validation規則。

### Template isolated proof / compatibility initiative

模板本身為單頁驗證、Skill acceptance或有界compatibility proof時，可以使用：

```txt
docs/design_sources/<initiative>/
  source.pen
  pencil-preview.png
  original-reference.png        # optional supplementary evidence
  historical-flutter-benchmark.png  # optional benchmark

docs/visual_authority/<initiative>/
  manifest.md
```

目前`pencil-compatibility-write-precheck`即屬此類；既有accepted authority不因product-level規則而搬移或改寫。

### Adopted product / App master

模板正式採用為實際App後，預設以一份canonical master `.pen`涵蓋完整產品畫面、states與flows：

```txt
docs/design_sources/app/
  app-master.pen
  pencil-preview.png              # derived evidence，若需要
  original-reference/             # optional supplementary sources
  assets/                         # optional governed source assets

docs/visual_authority/app/
  manifest.md
```

Feature／flow是master document內的logical selection boundary，例如Login、OTP、Profile或Checkout frames；它不是新的`.pen` file boundary。當該工作依中央分類需要Implementation Plan時，Plan應指出本次工作對應master中的哪些screens／frames／flows；Level 0／1等不需要Plan的工作不得為此虛構Plan。

只有經中央Requirement Decision確認下列任一真實理由時才拆分product `.pen`：文件規模或Pencil效能已成為問題、設計團隊需要明確ownership隔離、不同產品surface具有獨立生命周期，或其他已記錄的架構理由。不得因Flutter `features/`目錄存在就自動一feature一pen。

不論採isolated proof或App master，authority ranking固定為：

```txt
accepted repository-local .pen
→ Pencil MCP fresh derived preview
→ supplementary reference
→ historical Flutter benchmark
```

`.pen`是opaque design authority。即使檔案內容看起來像JSON，也不得用Python、PowerShell、Dart、text editor、regex或native parser讀取／修改其結構。

### Blank document／seed rule

Pencil MCP可建立／修改已存在有效document中的內容，但目前integration不把「任意filesystem路徑建立全新合法`.pen`」視為通用document API。若initiative需要從空白開始，使用repository-governed且已驗證的blank seed，再透過native Pencil與Pencil MCP操作。

已有有效`source.pen`或governed seed時，不應反覆要求使用者手動建立空白`.pen`。`.runtime`中的舊驗證`.pen`或temporary payload不能成為新的design authority。

## Third-party Skill pin, update and removal

目前Taste companions以`third-party-unmodified`方式鎖定在root`skills-lock.json`。Current pin：

```txt
repository: https://github.com/Leonxlnx/taste-skill.git
commit: e988add20dab0fa97d7a76781c48961c8184288e
license: MIT

brandkit
  upstream: skills/brandkit
  install: .agents/skills/brandkit

high-end-visual-design
  upstream: skills/soft-skill
  install: .agents/skills/high-end-visual-design

imagegen-frontend-mobile
  upstream: skills/imagegen-frontend-mobile
  install: .agents/skills/imagegen-frontend-mobile
```

Pin／update流程：

1. Requirement Decision確認confirmed gap與stage-specific用途。
2. 固定immutable upstream commit與exact upstream path。
3. copy exact upstream bytes；不翻譯、不順手改trigger。
4. 鎖定逐檔SHA-256與exact license bytes／hash。
5. 執行Skill lock、same-name collision、loaded absolute path與focused adoption review。
6. 任一managed byte或trigger改動後，若不再是exact upstream bytes，改按repository-maintained fork治理。

Removal流程：移除install path、lock row、registry row與route dependency，fresh執行docs／lock／discovery驗證；不得因此刪除已accepted `.pen`、Flutter source或historical evidence。

Taste Skills不自動取得network、filesystem mutation、credential、Pencil或image generation permission；實際tool permission仍由中央workflow與對應integration gate擁有。

## Worktree-local discovery proof

在Pencil admission前，證明實際runtime載入的是managed worktree版本，而不是user-global或其他workspace的same-name Skill：

```txt
expected worktree root
expected orchestration Skill absolute path
expected Taste Skill absolute paths（只限本stage需要的companions）
same-name collisions = 0
loaded paths outside worktree = 0
skills-lock validation = 0 issues
```

Path collision、global Skill先載入或hash drift都要先修復；不得以「檔案內容看起來相同」接受錯誤loaded identity。

## Pencil MCP admission

實際procedure以domain Skill的[Pencil admission reference](../../.agents/skills/implementing-pencil-flutter-design/references/pencil-admission.md)為準。人類流程只要求下列順序：

```txt
verify Executor scope／version
→ verify pencil-local-mcp discovery
→ native Pencil開啟worktree-local source.pen
→ fresh app state確認active document identity
→ load必要guidelines
→ Pencil MCP inventory／extraction
→ 如需export或mutation，只透過Pencil MCP
→ fresh hash／dimensions／manifest verification
```

Pencil MCP unavailable、document identity錯誤、source hash drift或unsupported construct沒有accepted disposition時，保持blocked。不得切換成PNG猜測、OCR、native parser或直接Flutter implementation。

## Extraction, representation classification and Flutter mapping

Extraction至少盤點：

- root／frame dimensions與hierarchy。
- reusable components。
- variables／colors／gradients／typography。
- spacing／radii／borders／shadows。
- text與visible content。
- icons與states。
- unsupported／ambiguous constructs。

Extraction完成後，**不得直接跳到Flutter owner mapping**。先依domain Skill的[`asset-and-typography-mapping.md`](../../.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md)完成representation classification與provenance resolution：

```txt
extraction inventory
→ representation classification
→ source / availability verification
→ provenance resolution
→ unresolved gap check
→ resolved Flutter owner mapping
```

Human-facing六類摘要：

- Layout primitive：一般fill、radius、border、shadow與可維護layout geometry。
- Typography：family、face／weight、fallback contract都必須resolved。
- Approved package icon：只有visual identity exact-enough才可直接使用。
- Vector asset：static geometry且有verified vector authority時使用。
- Raster asset：固定複雜artwork／texture或只有raster authority時使用。
- Dynamic drawing：只有runtime state／value真正驅動geometry時才使用。

以下任一成立時fail closed，不進production UI：字型authority unresolved、approximate icon未有accepted disposition、derived asset缺source／transformation／hash provenance、raster-everything mapping、static `CustomPainter` overbuild。完整decision matrix只由domain reference擁有，本Guide不複製其細節。

對risk-selected critical nodes，另外建立initiative-local：

```txt
docs/visual_authority/<initiative>/implementation_mapping.json
```

它只保存implementation mapping evidence，不取代`.pen`或`manifest.md`。Critical mapping只能是`exact`、`verified-equivalent`、`intentional-deviation`、`unresolved`；後三者分別需要equivalence evidence、accepted deviation approval或維持fail-closed。Machine validator與完整field contract由`tools/visual/pencil_implementation_mapping.py`擁有，本Guide不複製schema。

Critical geometry與micro-fidelity依risk選最小充分owner；不要求every-node geometry test、every-icon golden或every-section visual test。Whole-screen PASS不能覆蓋critical local FAIL，source constant也不能覆蓋runtime`RenderBox` evidence。

若review已判定wrong source／asset／icon／representation，立即停止對該candidate繼續scale／padding／crop／offset／opacity微調，回representation classification／provenance取得replacement mapping並fresh驗證。這是recovery gate，不是事後review建議。

每個extracted item只指定一個Flutter owner。Owner候選：

```txt
existing ColorScheme / DsSemanticColors
existing DsSpace / DsRadius
feature-local visual spec
generated localization key
approved icon package identity
feature-local widget
decorative Flutter primitive
```

只有真正存在第二個consumer時才提升為global Design System token。Pencil-specific exact cyan、gold、glow、gradient或單頁尺寸不因「看起來可共用」就提升。

## Feature First and localization rules

Pencil只擁有visual／structural authority，不建立第二套App architecture。

**Flutter Feature First是code ownership；Pencil document boundary是design authority ownership，兩者不得互相推導。** 真實產品通常由一份App master `.pen`同時涵蓋多個Flutter features。

- 新UI仍放入`apps/flutter_architecture/lib/features/<feature>/presentation/`。
- 只有實際business behavior才引入Domain／Data；presentation-only proof不得建立假的Repository／UseCase／Bloc。
- App仍是Composition Root。
- Visible copy進generated ARB localization；不要把accepted中文直接散落在widgets。
- icons沿accepted mapping使用既有package；不因第三方Web design Skill的icon規則改寫Flutter authority。
- responsive implementation使用正常Flutter layout；不得以整張raster、`FittedBox`全屏縮放或hidden overlay假裝還原。
- 一個accepted screen只允許一套whole-screen visual component tree。Canonical與runtime不能用breakpoint切換到parallel whole-screen visual renderer。
- Canonical Pencil viewport是**design/comparison space**，不是**Flutter logical breakpoint**。例如`.pen`寬度941不代表Flutter寬度低於900就能改走另一套mobile UI。
- 正常portrait尺寸以同一design-space scale投影真Flutter widget geometry；必要的Row→Column、文字換行或touch-target放大只能發生在同一component tree內。
- Design System／Theme／asset owner保持相同：canonical與runtime不能因「比較適合手機」而各自使用不同顏色、card hierarchy、icons或feature-local token。

## Golden, diff and runtime acceptance

Visual acceptance至少需要：

```txt
Pencil MCP fresh canonical preview
Flutter deterministic canonical golden
deterministic PNG diff
supported runtime screenshot
human semantic visual review
```

Canonical與supported runtime必須由同一production whole-screen tree產生。`scrollable`、`no overflow`、semantics與touch target只屬**layout health**，不是**runtime fidelity**。

Supported runtime需要獨立的**visual fidelity evidence**。當accepted `.pen`只有單一手機frame時，可以在candidate前由canonical Pencil preview依manifest固定的target、projection algorithm與crop／scroll contract建立runtime-sized derived reference；它不是第二份`.pen`，也不能在candidate失敗後改resize方式。

Manifest先固定canonical viewport、DPR、tolerance、ignore／crop policy與threshold，之後才比較。失敗時修implementation或取得新Design decision；不得在同一Task臨時放寬threshold。

Dimension mismatch必須fail closed，不得自動resize。若historical benchmark與current canonical authority來自不同時期／尺寸，使用其immutable contemporaneous native-size reference計算normalized historical metrics，再與current metrics比較；不得upscale historical raster冒充current master。

Runtime screenshot必須保留exact driver bytes與SHA-256，記錄device id、platform version、physical／logical size、DPR、font scale與exact command。System chrome／debug marker不得動態mask；只有Design事前固定的rectangular crop才可使用。

Pixel threshold通過也不能覆蓋semantic P1。人工review至少檢查hierarchy、typography、spacing、icons、states、content completeness、contrast、touch target、narrow layout與platform renderer differences。

使用者或reviewer若對實際supported runtime提出semantic P1，對應runtime PASS立即撤銷並回implementation修正；canonical pixel PASS不能作為例外。

## Double-layer Task review

本流程仍服從中央雙層Task治理：

```txt
Task implementation／evidence
→ focused review
→ finding修正
→ fresh focused re-review
→ Task whole review
→ Task commit
→ 下一Task

全部Tasks完成
→ cross-Task holistic final review
→ fresh full regression
→ release／merge／push authorization gate（依分類）
```

一般implementation failure、stale doc或test failure直接修正並fresh re-review；只有scope／architecture決策、external manual dependency、accepted Design／Plan被P0／P1推翻，或正式release gate才需要停下來等使用者。

## Failure, rollback and stop conditions

立即fail closed：

- accepted Requirement／Design／Plan缺失或互相衝突。
- worktree／branch／HEAD admission不符。
- `.pen`不在repository或manifest hash drift。
- Skill lock／loaded path／collision失敗。
- Pencil MCP不可用或active document identity錯誤。
- 需要native `.pen` parse、OCR或PNG猜測才能繼續。
- unsupported construct沒有accepted mapping／defer decision。
- visual threshold或semantic P1未通過。

Rollback以Task commit／accepted source與manifest為單位；不要用external `.pen`、舊runtime file或historical screenshot覆蓋current authority。

## Copyable short prompt

已經有accepted repository-local `.pen`時，日常Prompt只需要：

```txt
@bridge-win 請開啟：

`D:\Developer\flutter_architecture`

請使用repository-local `governing-template-development`。

我要依目前repository中已接受的`.pen`實作／繼續實作對應Flutter畫面。

請先依repository authority確認Requirement Decision、Design、Plan、managed worktree、visual manifest與Skill provenance；只有全部admission通過後才路由`implementing-pencil-flutter-design`。

`.pen`只能透過Pencil MCP讀取／操作，不得使用native parser、PNG／OCR fallback或external path作implementation authority。

請依雙層Task治理持續執行，直到需要真正的使用者決策、external manual action或正式release／merge授權才停止。
```

若工作尚未完成Requirement／Design／Plan，不要宣稱「已接受`.pen`」；改用一般feature／governance入口先完成分類與核准。

## Related authority

- [Template Development Workflow Governance](../governance/development_workflow.md)
- [Documentation Governance Policy](../governance/documentation_policy.md)
- [ADR-028](../adr/adr-028-repository-local-pencil-to-flutter-design-implementation-workflow.md)
- [Design Source Hub](../design_sources/README.md)
- [Visual Authority Hub](../visual_authority/README.md)
- [AI Agent協作開發快速使用指南](agent_assisted_development_quick_start.md)
