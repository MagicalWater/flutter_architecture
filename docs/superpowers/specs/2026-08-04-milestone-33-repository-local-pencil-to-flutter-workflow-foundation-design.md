---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Repository-local Pencil-to-Flutter Workflow Foundation Design

## Requirement Decision

- Request（需求）：在 Flutter Architecture Template 中建立正式、可重複使用、repository-local 的 Pencil-to-Flutter 設計實作流程，並以既有核准畫面驗證該流程能在樣板架構、文件治理與雙層 Task 治理下維持高視覺忠實度。
- Problem（問題）：目前 repository 沒有 `.pen` 視覺權威路徑、Pencil MCP 操作路由、第三方設計 Skill provenance／integrity contract、Pencil 到 Flutter architecture mapping、或可重複的 visual acceptance pipeline。既有 `agent-skill-language` checker 又把 repository 自建 Skill 與未修改的第三方 Skill 混為同一語言責任。
- Current behavior（目前行為）：Pencil 還原 proof 位於 repository 外部；三份 Taste Skills 也位於外部 workspace。樣板只能以一般 Feature First、Design System、Localization 與 testing 規則實作畫面，無法證明設計來源、Skill 載入來源與視覺差異的完整 evidence chain。
- Expected behavior（預期行為）：使用者提供已核准且已放入 managed worktree 的 `.pen` 後，repository workflow 能驗證 visual authority、載入鎖定的第三方 Skills、透過 Pencil MCP 讀取設計、映射 Flutter architecture、完成 TDD implementation、產生 visual diff evidence，並依雙層 Task 治理完成 review、release 與 post-release closure。
- Value（價值）：把一次性的 UI 還原成果提升為樣板可重複能力，同時防止外部 Skill 漂移、錯誤路徑載入、自由改版、架構繞過與只有主觀觀察而沒有可重現 evidence 的驗收。
- Classification（分類）：Level 4 — Architecture／Milestone。
- Decision（決策）：Accept。
- Scope（範圍）：第三方 Skill ownership／語言／provenance 治理、repository-local workflow Skill、`.pen` visual authority、Pencil MCP admission、Flutter architecture mapping、單頁 compatibility proof、automated visual validation、Guide／ADR／Roadmap／release authority 同步。
- Non-goals（非目標）：完整 NFC Lab、NFC domain／data、任意 `.pen` 自動產 production code、low-code framework、Figma workflow、Web runner adoption、Windows desktop runner、產品識別替換、批次多畫面還原、以第三方 Skill 取代 repository authority。
- Behavioral requirements required（是否需要行為需求）：是。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是。
- ADR required（是否需要 ADR）：是；[ADR-028 stable decision draft](2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md)與本 Design 同步審查，canonical ADR在Plan核准後的第一個TDD governance Task建立。
- Task governance mode（Task 治理模式）：Full two-layer governance。
- Worktree／branch：Design 與 Plan 核准後，從核准 ancestor 建立 managed worktree；implementation 不得直接在 `main` 執行。
- Regression level（Regression 等級）：full repository documentation／Skill checks、affected Flutter workspace regression、App build、visual acceptance 與 clean-checkout validation。
- Release required（是否需要發布）：是；若能力完整進入模板 current authority，預期為 minor baseline release，最終版本由 Final Review 決定。
- Post-release validation（發布後驗證）：是；release SHA 必須重新驗證 repository-local Skill discovery、docs checks、Flutter regression、Android build 與 visual evidence routing。
- Required Superpowers skills（必要 Superpowers Skills）：`brainstorming`、`writing-plans`、`using-git-worktrees`、`test-driven-development`、`systematic-debugging`、`requesting-code-review`、`receiving-code-review`、`verification-before-completion`、`finishing-a-development-branch`；production code 階段搭配 repository-local `karpathy-guidelines`。
- Required artifacts（必要 artifacts）：Design、ADR-028、Implementation Plan、逐 Task review、third-party Skill lock／adoption evidence、visual authority manifest、Pencil extraction evidence、Flutter tests／goldens／runtime screenshot／diff、holistic Final Review、release 與 post-release evidence。

## Decision Summary

Milestone 33 的主要交付物不是單一畫面，而是正式的 repository capability：

```txt
accepted repository-local .pen
→ locked third-party Skill admission
→ Pencil MCP structural extraction
→ Flutter Design System／Localization／Feature First mapping
→ TDD implementation
→ golden／runtime screenshot／visual diff
→ two-layer review and release closure
```

`Write Pre-check` 畫面是第一個 executable acceptance fixture。它必須證明流程可用，但不得反過來把一次性的固定尺寸技巧誤認為通用 framework。

## Goals

1. 建立 `.pen`、derived preview、原始參考圖與 visual validation evidence 的明確 ownership。
2. 正確區分 repository-authored Skill、unmodified third-party Skill 與 repository-maintained fork。
3. 保留第三方 Skill 上游原文與 bytes，以 immutable source、file manifest 與 SHA-256 驗證完整性。
4. 建立 repository-authored Pencil-to-Flutter orchestration Skill，統一 admission、routing、mapping、validation 與停止條件。
5. 在不破壞 Feature First、App-only Composition Root、Design System 與 Localization authority 的前提下還原核准畫面。
6. 以 automated visual comparison 與人工語意 review 共同驗證忠實度，而不是只依主觀「看起來接近」。
7. 將日常操作方式同步到 Guide 與中央治理 routing，讓模板後續採用者可以重複執行。

## Non-goals

- 不建立 deterministic `.pen` parser 或 generator package。
- 不允許直接以 JSON、文字或 native script 解析／修改 `.pen`；`.pen` 的結構讀取與修改只透過 Pencil MCP。
- 不把核准設計圖貼成單張 raster image 冒充 Flutter UI。
- 不把整個畫面包進固定尺寸 `FittedBox` 作為通用實作策略。
- 不建立第二套 navigation、localization、theme、DI 或 testing authority。
- 不因單一 proof 把所有顏色、間距、glow、字級與組件提升成全域 Design System token。
- 不要求三份 Taste Skills 在每次 implementation 同時啟動。
- 不把 Web release 作為本次必要條件；目前 repository 沒有 tracked Web runner。

## Current Baseline and Admission Evidence

目前 read-only admission 已確認：

- Branch：`main`。
- Base／remote HEAD：`de8d95a584d32e7a63d509527d24ef0d0a5544d8`。
- Working tree：clean。
- Template Baseline：`1.14.0`。
- Current active milestone：在本 Design 啟動前為 `None`。
- Repository 目前沒有 `docs/design_sources/`、`docs/visual_authority/`、root `skills-lock.json` 或三份 Taste Skills。
- App 是唯一 Composition Root；Feature 採 Feature First；Design System 與 Localization 已有 canonical authority。

第一個 proof 的外部 admission inputs：

| Input | Current external path | Role | SHA-256 |
|---|---|---|---|
| Pencil source | `D:\Developer\ui-agent\test-reconstruction.pen` | 預定 structure／layout authority | `bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc` |
| Pencil preview | `D:\Developer\ui-agent\test-reconstruction-preview.png` | Pencil renderer derived reference | `6d1a6553a1b066d0d07ce565aee7f895cddcdc0344e9f9797bab4ca1cfac5be5` |
| Original image | `D:\Developer\ui-agent\test.png` | Historical visual reference | `c7469bcdd8842ad7a0e2f57715756615e07990d0fec33d6016105c5e45e398fc` |
| Previous Flutter preview | `D:\Developer\ui-agent\flutter_preview\flutter-preview.png` | Blank-project benchmark only | `69edbc35da44288e80b448231de50f9a51d95ba84c9042ea16797267b607731d` |

這些外部路徑只用於 implementation admission。Task 將先 copy 到 managed worktree、重新計算 destination hash 並建立 manifest；完成後不得再以外部路徑作 runtime authority。

## Authority Model

### Repository policy and workflow

- `AGENTS.md`：不可繞過的 repository policy 與中央 workflow 入口。
- `.agents/skills/governing-template-development/`：Requirement Decision、Level、artifact、approval、Task、release 與 closure routing。
- `.agents/skills/implementing-pencil-flutter-design/`：Pencil-to-Flutter domain orchestration；只在中央治理已接受需求並完成必要核准後啟動。
- `docs/governance/development_workflow.md`：人類可讀的 workflow／Skill registry 總覽。
- `docs/guides/`：可重複的操作方法，不擁有 architecture decision。

### Architecture and visual source

- ADR-028 stable decision draft：Pencil-to-Flutter stable ownership、第三方 Skill identity、MCP boundary 與 visual acceptance contract；canonical ADR須先修正目前硬編碼至ADR-027的coverage checker。
- `docs/design_sources/<initiative>/`：repository-owned design source files。
- `docs/visual_authority/<initiative>/manifest.md`：該 initiative 哪個 source 是 authority、其他 artifacts 的 derived／benchmark status、hash 與 approval state。
- `.pen`：layout、component structure、visible text placement、design variables 與 visual hierarchy 的第一順位 source。
- Preview PNG：Pencil renderer 的 derived evidence，不可在與 `.pen` 衝突時覆蓋 `.pen`。
- Original PNG：歷史參考；只有 manifest 明確指定的視覺資訊可作補充。
- Previous Flutter preview：benchmark，不是 authority。

### Runtime and evidence

- Flutter source：實際 implementation truth。
- Widget／localization／route tests：行為與 architecture regression truth。
- Golden／runtime screenshot／diff：visual runtime evidence。
- `docs/audits/milestone_33/`：findings、re-review、runtime evidence 與 final disposition。
- `VERSION`／`CHANGELOG.md`：release identity 與 release history。

## Third-party Skill Ownership and Language Governance

### Ownership classes

#### Repository-authored

Repository 建立或維護的 `SKILL.md`、references、examples 與 pressure scenarios 遵守繁體中文政策。技術識別、Skill name、path、class／method／package 名稱與 status values 可保留英文。

#### Third-party unmodified

未修改的第三方 Skill 必須保留上游目錄結構、原始語言與原始 bytes。Repository 不翻譯 trigger、gate、safety wording 或 examples，也不以中文 wrapper 冒充上游本體。

只有同時滿足以下條件才能豁免 repository Skill 語言檢查：

1. Skill 位於 root `skills-lock.json` 宣告的 exact install path。
2. Lock 使用 immutable upstream commit 或 release identity。
3. 每個 vendored file 都有 relative path 與 raw SHA-256。
4. Repository 實際 bytes 與 lock 完全一致。
5. Source repository、source path、license identity 與 adoption status 可追溯。

只以 path、name 或「third-party」文字標記不足以取得豁免。

#### Repository-maintained fork

只要修改第三方 Skill 的任何受管理 bytes，就必須轉為 fork：

- 使用新的 repository identity 或明確 fork 名稱。
- 記錄 upstream base commit、差異與 license obligations。
- 遵守 repository-authored 語言治理。
- 重新執行 focused adoption review 與 pressure validation。

### Lock and registry separation

- `skills-lock.json`：machine-readable provenance、immutable source identity、install path、file inventory 與 hash。
- `docs/governance/development_workflow.md` registry：status、trigger、responsibility、forbidden responsibility、companions、permissions、rollback 與 upgrade policy。
- Adoption review：來源核實、overlap、collision、behavioral pressure evidence 與 disposition。

Checker 必須 fail closed：missing lock、unknown file、hash mismatch、path escape、duplicate install path、同名 collision 或標示 unmodified 但 bytes 改變，都不得以語言豁免方式通過。

## Taste Skill Disposition

三份 Taste Skills 以 unmodified third-party 方式進入 managed worktree，正式 adoption status 在 implementation admission review 中決定：

| Skill | Expected role | Normal trigger in this workflow | Forbidden responsibility |
|---|---|---|---|
| `brandkit` | 品牌語言與一致性 companion | 只有 Design 明確要求品牌系統判讀時 | 改寫 accepted `.pen`、決定 Flutter architecture、建立 implementation plan |
| `high-end-visual-design` | hierarchy、spacing、generic degradation critique | visual mapping／review 階段，且只採用與 Flutter、ADR 及 `.pen` 相容的原則 | 套用 Web／React／Tailwind 專屬規則、禁止 Material／Flutter contract、覆蓋 accessibility／localization |
| `imagegen-frontend-mobile` | image concept generation companion | 只有 visual authority 尚未形成、Design 明確要求生成候選時 | 在已有 accepted `.pen` 時重新設計、產 code、取代 Pencil source |

本 proof 已有 accepted `.pen`，因此 `imagegen-frontend-mobile` 與 `brandkit` 預期為 loaded but non-triggered；`high-end-visual-design` 只作受限 critique companion。

## Skill Discovery and Collision Contract

DevSpace machine discovery 的有效順序目前是 user-global Skill path 先於 project `.agents/skills`，且同名 collision 採 first-loaded wins。因而「檔案已 copy 到 worktree」不等於「實際載入 repository copy」。

每個 repository-local Skill admission 必須提供：

1. 從 managed worktree 重新 open／reload workspace。
2. Skill discovery 結果包含 absolute worktree-local path。
3. 同名 user-global、DevSpace-local 或 configured agent Skill 不得先行遮蔽。
4. Collision diagnostic 為零；發現 collision 時 fail closed，不得靜默繼續。
5. Loaded file hash 與 `skills-lock.json` 或 repository-authored source hash 一致。
6. 後續工作不得再讀 `D:\Developer\ui-agent\.agents\skills` 作 active source。

## Repository-local Pencil-to-Flutter Skill

新增 `.agents/skills/implementing-pencil-flutter-design/`，其內容使用繁體中文並保持薄型 orchestration：

```txt
SKILL.md
references/
  pencil-admission.md
  visual-authority-contract.md
  flutter-mapping.md
  visual-validation.md
  pressure-scenarios.md
```

### Responsibilities

1. 先委派 `governing-template-development`，確認 Requirement Decision、Design、Plan、worktree 與 Task gate。
2. 確認 `.pen` 已在 worktree、manifest 已接受且 hash 一致。
3. 透過 `executor-local-mcp` 路由 `pencil-local-mcp`，完成版本、integration、app state 與 guideline admission。
4. 只透過 Pencil MCP 讀取／操作 `.pen`。
5. 提取 frame、component、variables、typography、spacing、color、icons、states 與 content hierarchy。
6. 將 extracted design 映射到 Design System、feature-local visual specification、Localization 與 Flutter widgets。
7. 路由 TDD、golden、runtime screenshot、diff 與 review evidence。
8. 發現 authority conflict、source drift、collision、Pencil state mismatch 或需要自由改版時停止並回到 Design decision。

### Forbidden responsibilities

- 不自行分類 Level、核准 Design／Plan 或宣稱 Task／Milestone 完成。
- 不修改 `.pen` 以迎合較容易的 Flutter implementation，除非 accepted Design 明確授權設計修訂。
- 不以 Taste Skill、preview PNG 或 previous Flutter screenshot 覆蓋 `.pen` authority。
- 不建立不必要的 Domain、Data、Repository、Use Case、Bloc 或 DI。
- 不為單一畫面建立通用 code-generation framework。

## Pencil MCP Admission and Extraction

每個 substantive Pencil Task 必須：

1. 驗證 Executor scope、integrations 與 `pencil-local-mcp` 可用性。
2. 驗證 exact Executor／Pencil integration version，並在 evidence 中記錄。
3. 以 native Pencil App 開啟 worktree-local `.pen`，再取得 fresh app state。
4. 第一個 app-state request 包含 schema／canvas，需要時再查 scripts／browser；禁止一次載入無關大型資料。
5. 無參數取得 guidelines，只載入與 `Code`、`Design System`、當前 Task 直接相關的內容。
6. 在 extraction evidence 中記錄 source hash、open document identity、selected frame、variables、component inventory 與任何 unsupported construct。

Pencil MCP unavailable、錯誤文件被開啟、canvas state 不一致或 `.pen` hash drift 時，Task 維持 blocked；不得改用 native JSON parser 或目測猜測取代。

## Visual Authority Structure

永久 routing：

```txt
docs/design_sources/
  <initiative>/
    source.pen
    pencil-preview.png
    original-reference.png
    historical-benchmark.png

docs/visual_authority/
  README.md
  <initiative>/
    manifest.md

docs/audits/<initiative-or-milestone>/
  visual_validation/
    canonical-render.png
    runtime-screenshot.png
    diff.png
    review.md
```

Manifest 至少記錄：initiative、authority file、derived files、benchmark files、raw hash、canonical viewport、approval state、source provenance、allowed interpretation、forbidden substitution 與 supersession rule。

本 proof 的 canonical viewport 為 `941 × 1672`、device pixel ratio `1.0`。它只定義可重現的 primary comparison，不代表 App 只能支援該尺寸。

## Flutter Architecture Integration

第一個 proof 建立 presentation-only feature：

```txt
apps/flutter_architecture/lib/features/pencil_compatibility/
  README.md
  presentation/
    pages/
    widgets/
    visual_spec/
```

### Boundaries

- App router 新增非 initial、非 authenticated Shell bottom-navigation 的 standalone route。
- 不新增 Domain／Data／Repository／Use Case／Bloc／DI；畫面使用 immutable fixture data。
- 所有 visible strings 進入既有 ARB／generated localization，不保留硬編碼中文作 production source。
- Icon 使用與 visual authority 一致的 library；若需要 `phosphoricons_flutter`，以正常 dependency adoption 加入，不以 Material Icons 近似替代。
- Base background、surface、outline、text 與 semantic status 優先映射既有 `ColorScheme`／`DsSemanticColors`。
- 只有能準確對應的 spacing／radius 使用 `DsSpace`／`DsRadius`；Pencil-specific cyan、gold、glow、gradient、exact typography 與尺寸保留 feature-local immutable visual specification。
- 只有第二個真實 consumer 證明穩定共用 contract 後，才考慮提升 Design System primitive。

### Responsive behavior

- Canonical viewport 必須忠實比對 `.pen`。
- 較窄 viewport 必須可讀、可 scroll、無 overflow，且保留主要 hierarchy。
- 不得把整個畫面 rasterize，也不得依賴全畫面固定尺寸 `FittedBox` 掩蓋 layout 問題。
- `FittedBox` 只允許用於獨立 illustration／decorative asset，且需在 review 中說明。

## Behavioral Requirements

- BR-33-01：未接受的 Design／Plan 或未建立 managed worktree 時，不得 copy visual source、安裝 Skills、操作 Pencil canvas 或修改 Flutter source。
- BR-33-02：所有 active design source 與 third-party Skills 必須先進 repository 並通過 hash／provenance admission；外部路徑不能作 implementation authority。
- BR-33-03：未修改第三方 Skill 保留上游原語言與 bytes；語言豁免只能由 immutable lock 與 exact file hashes取得。
- BR-33-04：Repository-authored Skill 與 fork 仍遵守繁體中文、focused adoption review 與 pressure validation。
- BR-33-05：同名 Skill collision 或載入路徑不是 managed worktree 時，Task fail closed。
- BR-33-06：`.pen` 只透過 Pencil MCP 讀取／操作；禁止 native parsing fallback。
- BR-33-07：`.pen` 是 structure／layout primary authority；derived preview、original image 與 historical benchmark 的順位由 manifest 明確定義。
- BR-33-08：Taste Skills 是 stage-specific companions，不擁有 visual authority、architecture、approval、Task 或 closure。
- BR-33-09：Flutter implementation 必須遵守 Feature First、Localization、router、Design System 與 App-only Composition Root。
- BR-33-10：Presentation-only fixture 不得建立虛假的 Domain／Data／DI abstraction。
- BR-33-11：Canonical 941 × 1672 render 必須產生可重現 golden／screenshot／diff；narrow viewport 必須無 overflow。
- BR-33-12：不得以 embedded full-screen image、全畫面 fixed-canvas scaling 或任意 tolerance widening取得視覺通過。
- BR-33-13：Automated pixel evidence 必須搭配人工語意 review，檢查 hierarchy、typography、spacing、icons、states、content 與 accessibility。
- BR-33-14：任何必要 validation 失敗時，Task 維持 open；修正並 fresh re-review 後才能 completion commit。
- BR-33-15：Workflow Guide 必須能由未參與本次 proof 的後續 agent 依 repository-local files 重複執行，不依賴口頭上下文或 `D:\Developer\ui-agent`。

## Validation Strategy

### Governance and Skills

- TDD 更新 `tools/docs/check_docs.py` 與 `tools/docs/test_check_docs.py`。
- 驗證 repository-authored English-only Skill fail、繁體中文 Skill pass。
- 驗證 locked unmodified English third-party Skill pass。
- 驗證 missing lock、unknown file、hash drift、path escape、duplicate install path、fork masquerading as unmodified 全部 fail。
- fresh managed-worktree discovery 驗證三份 Taste Skills 與 repository orchestration Skill 的 absolute loaded path。
- pressure scenarios 驗證 trigger、non-trigger、authority conflict、collision、skip-governance、native parser fallback 與自由改版拒絕。

### Flutter

- Route test：standalone route 可達且不改變 initial／Shell contract。
- Localization test：英文與繁體中文 visible strings 由 generated localization 提供。
- Widget／semantics test：主要 section、steps、data rows、records、actions 與 status 可辨識。
- Narrow viewport test：無 overflow，內容可 scroll，hierarchy 保留。
- Golden test：Windows host canonical viewport `941 × 1672`、DPR `1.0`。
- Android runtime screenshot：以 repository 支援平台驗證實際 font／icon／renderer 差異。
- Full affected regression：docs checks、generated checks、analyze、Flutter tests、App bundle、Android debug build。

### Visual acceptance

```txt
Pencil preview master
→ Flutter canonical golden
→ Android runtime screenshot
→ deterministic diff
→ semantic visual review
→ findings／fix／fresh rerender
```

Diff 工具、threshold 與 ignore region 必須在 Plan 中固定；不允許為了讓結果通過而事後擴大 tolerance。動態內容原則上不存在；若 runtime system chrome 造成差異，必須使用明確 crop contract，而不是任意遮罩。

## Planned Task Families

Implementation Plan 應拆成一對一 review／commit 的正式 Tasks：

1. `33-1` ADR coverage checker generalization、canonical ADR-028、third-party Skill language／provenance governance and checker TDD。
2. `33-2` Skill lock、registry、collision／discovery pressure evidence。
3. `33-3` Visual authority／design source documentation contract。
4. `33-4` Repository-local Pencil-to-Flutter orchestration Skill。
5. `33-5` Managed worktree source copy、hash admission and Pencil MCP readiness。
6. `33-6` Pencil structural extraction and Flutter mapping evidence。
7. `33-7` Flutter presentation-only proof implementation。
8. `33-8` Route／localization／widget／architecture validation。
9. `33-9` Golden／Android screenshot／visual diff acceptance。
10. `33-10` Workflow Guide、Quick Start、authority and registry synchronization。
11. `33-11` Holistic Final Review、release decision and baseline synchronization。
12. `33-12` Post-release clean-checkout Skill discovery、Flutter and visual routing validation。

Plan 可以調整 exact Task boundaries，但不得合併到失去獨立 review、validation 或 commit evidence，也不得在 user Plan approval前建立 implementation worktree。

## Rollback and Failure Handling

- Third-party Skill rollback：移除 lock entry、vendored files、registry／routing，並驗證沒有 active workflow 依賴。
- Workflow Skill rollback：移除中央 domain route、Skill、Guide entry與registry；保留歷史 Design／Plan／Audit。
- Visual authority rollback：保留已提交 historical evidence，但將 manifest status 改為 superseded／rejected，不刪除已被 release 引用的 evidence。
- Flutter proof rollback：移除 standalone route、feature、dependency、ARB keys、tests／goldens，並完成 full regression。
- 若 proof 無法達到 accepted visual fidelity，Milestone 不得宣稱 workflow capability completed；可以保留治理修正並由 Final Review決定 partial release、defer 或 rollback。

## Release and Closure

Milestone 33 完成時才決定是否將 Template Baseline 從 `1.14.0` 提升為 minor release。Release gate 至少要求：

- Design／ADR／Plan accepted。
- Tasks 33-1 至 33-10 全部通過或有明確 approved disposition。
- Open P0 = 0；Open P1 without disposition = 0。
- Full repository regression、Android build、canonical golden、runtime screenshot 與 visual review通過。
- Current authority、Skill registry、Guides、Roadmap、VERSION／CHANGELOG一致。
- Push 後以 release SHA 建立 fresh clean-checkout／workspace discovery evidence。

最後一個 implementation Task 通過不等於 Milestone closure。

## Success Criteria

- Repository 能分辨並機械驗證自建 Skill、原樣第三方 Skill 與 fork，不再以「全部 Markdown 必須中文」誤傷第三方來源。
- 三份 Taste Skills 可從 managed worktree 以固定來源與 hash 載入，且無同名 collision。
- 後續 agent 能只讀 repository authority 完成 `.pen` admission、Pencil MCP extraction、Flutter mapping 與 visual validation。
- Proof screen 在 canonical viewport 忠實對齊 `.pen`，並在窄 viewport 無 overflow、非 raster screenshot、非全畫面 fixed-canvas cheat。
- Flutter implementation 符合 Feature First、router、Localization、Design System 與 App-only Composition Root。
- Golden、Android screenshot、diff 與人工語意 review形成可追溯 evidence chain。
- Workflow、Guide、ADR、Skill registry、current roadmap與release state沒有平行 authority或互相矛盾。

## Approval Gate

本文件與 ADR-028 stable decision draft 已完成 Design focused review、findings修正、fresh re-review、whole-Design review與documentation validation，並於2026-08-04取得使用者對書面 artifacts 的明確核准，狀態為 `accepted`。Implementation Plan必須另行完成完整雙層治理並取得使用者核准；Canonical ADR-028與checker修正仍屬核准Plan的第一個implementation governance Task，不得在Plan前提前實作。
