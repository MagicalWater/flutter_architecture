---
document_type: design-spec
status: proposed
authoritative_for:
  - adopting-template-product-identity-skill-design
last_reviewed_baseline: 1.13.0
---

# Adopting Template Product Identity Skill Design

## Requirement Decision

- Request：建立一個repository-local Agent Skill，協助採用者將Flutter Architecture Template安全轉換成實際產品。
- Problem：現有`native_environment_adoption.md`已完整說明操作程序，但Agent仍可能漏改manifest、Android／iOS projection、Kotlin package或verifier，也可能誤提交簽章憑證。
- Current behavior：採用者必須自行閱讀Guide並逐步操作；目前沒有專門的Agent入口。
- Expected behavior：使用者提供產品名稱、base identifier、environment display name與API domain後，Agent自動讀取current authority、盤點projection、依manifest-first流程執行並完成跨平台驗證。
- Value：降低模板採用時的identity drift、平台漏改、secret洩漏與驗證不完整。
- Classification：Level 3 — Cross-cutting。
- Classification evidence：會影響Android、iOS、Dart environment、verification scripts、tests與文件；但它是optional shortcut，不修改中央治理authority，因此不升為Level 4。
- Decision：Accept with restrictions，先以Pilot採用。
- Scope：一個薄型repository-local Skill、pressure scenarios、Skill registry與必要入口連結。
- Non-goals：不實作production signing；不處理Store distribution；不新增或改名environment；不保存API token、keystore、certificate或provisioning secret；不取代`governing-template-development`；不複製ADR或Guide正文。
- Behavioral requirements required：Yes。
- Design Spec required：Yes。
- Implementation Plan required：Yes。
- ADR required：No；不改變既有architecture ownership。
- Task governance mode：Full。
- Worktree／branch：Implementation時必須隔離；Design落檔本身使用獨立文件worktree，不代表implementation已開始。
- Regression level：Skill RED／GREEN、discovery、authority-conflict scenarios、docs checker與environment contract tests。
- Release required：No；不建立獨立版本發布。
- Post-implementation validation：需要clean-checkout Skill discovery與pressure validation。
- Required Superpowers skills：brainstorming、writing-skills、writing-plans、test-driven-development、using-git-worktrees、verification-before-completion與review skills。

## Adoption disposition

```txt
Candidate: adopting-template-product-identity
Status: Pilot／Approved with restrictions
Classification: Level 3 — Cross-cutting
New Milestone: No
AGENTS.md mandatory entry change: No
Central governance replacement: No
```

這是repository-original Skill，不依賴外部上游來源或commit pin。版本authority由Git commit、Skill registry與pressure validation evidence共同保存。

## Considered approaches

### A. Thin template-adoption Skill — Accepted

Skill只負責trigger、簡短輸入、required reading、中央治理委派、manifest-first順序、安全邊界與validation routing。完整程序仍由ADR、Guide、manifest、source與tests擁有。

### B. Operations-manual Skill — Rejected

將完整Android／iOS步驟與指令複製進Skill會與`native_environment_adoption.md`形成平行authority，並增加stale與維護風險。

### C. Full template-adoption automation — Deferred

自動改寫manifest、Kotlin package、Xcode project與API configuration需要額外CLI、dry-run、rollback與跨平台mutation設計。目前尚未證明既有verifier加薄型Skill不足，因此不納入本次scope。

## Architecture and responsibility

`adopting-template-product-identity`是optional user-facing shortcut；`governing-template-development`仍是唯一工作治理引擎。

```txt
short template-adoption brief
→ adopting-template-product-identity
→ governing-template-development
→ Requirement Decision
→ accepted Design／Plan and routed Superpowers
→ repository Task review／validation／closure gates
```

### Skill responsibilities

Skill只擁有：

1. 辨識完整模板產品化、template identity替換與跨Android／iOS environment identity同步需求。
2. 接收簡短產品名稱、base identifier、display names、target platforms、API domains與限制。
3. 保存使用者原始scope與discussion-only限制。
4. 強制委派`governing-template-development`並先產生Requirement Decision。
5. 指定current authority reading route，不複製authority正文。
6. 要求current-state inventory、manifest-first mutation與evidence classification。
7. 遇到secret、signing、Store distribution、environment contract變更或平台證據不足時停止或升級scope。

### Forbidden responsibilities

Skill不得擁有或改變：

- Level classification、Design／Plan approval、worktree／branch decision、Task acceptance、release或closure。
- Environment數量、名稱、順序、suffix convention或Dart entrypoint authority。
- Identity mapping正式authority。
- Signing credential custody、production signing或Store distribution。
- Supported platform claim。

### Authority precedence

```txt
User instruction
→ AGENTS.md
→ governing-template-development
→ accepted Design／Plan／ADR
→ environments.json and current source
→ native_environment_adoption.md
→ adopting-template-product-identity
→ verifier／tests／runtime evidence
```

Skill與較高authority衝突時，必須服從較高authority並記錄finding，不得自行改寫既有contract。

## Trigger contract

### Positive triggers

- 將此模板採用成實際產品。
- 替換`com.example.flutterarchitecture`等template identity。
- 同步Android applicationId與iOS bundle identifier。
- 設定development／staging／production產品display name與identifier。
- 進行包含native identity的完整App rebrand。

### Non-triggers

- 只修改畫面標題、Logo、Theme或App icon。
- 只修改API URL。
- 新增第四個environment、改名environment或改變suffix convention。
- Production signing、Play Store／App Store distribution。
- 一般Feature implementation。
- 單一平台局部identifier修復；此類需求先由中央治理判斷是否為bounded bug。

Skill不得只因訊息出現`applicationId`或`bundle identifier`就認定為完整模板採用。

## Input contract

### Non-inferable required input

`base identifier`不得由Agent自行猜測。缺少時可以完成只讀盤點、命名規則說明與Requirement Decision，但不得開始identity mutation。

Skill只能驗證reverse-DNS格式，不能替使用者宣稱其擁有某個domain或organization namespace。

完整產品identity mutation開始前，還必須取得使用者明確確認的development／staging／production display names。產品名稱只能用來產生候選值，不能替代確認。

若本次acceptance包含staging／production real API build或runtime evidence，還必須先取得有效的staging／production API domains。缺少domain時可以完成identity projection與static verification，但對應build／runtime evidence只能標記為`Pending`，不得使用template placeholder冒充完成。

### Inferable but explicit inputs

- 產品名稱。
- Development／staging／production display name。
- Target platforms。
- Staging／production API domain。
- 特殊限制。

Display name可提出以下建議，但必須在Design或Plan中明示，不能靜默套用：

```txt
Development → <產品名稱> Dev
Staging     → <產品名稱> Staging
Production  → <產品名稱>
```

API domain不屬`environments.json`，只能進入runtime／CI configuration boundary。

### Forbidden tracked inputs

- Keystore password或private key。
- Apple certificate或provisioning credential。
- Service account secret。
- Production API token、refresh token或其他credential。

若使用者提供上述資料，Skill不得將其寫入repository，只能路由至protected secret custody。

## Required reading route

Skill啟動後先委派中央治理，再依scope讀取：

```txt
AGENTS.md
VERSION
docs/project_context.md
docs/adr/adr-014-app-configuration-environment-entrypoints.md
docs/adr/adr-025-native-environment-mapping-product-identity-contract.md
docs/guides/native_environment_adoption.md
apps/flutter_architecture/config/environments.json
```

進入Design或implementation前，再檢查：

```txt
apps/flutter_architecture/android/app/build.gradle.kts
apps/flutter_architecture/android/app/src/main/AndroidManifest.xml
apps/flutter_architecture/android/app/src/main/kotlin/
apps/flutter_architecture/ios/Flutter/
apps/flutter_architecture/ios/Runner/Info.plist
apps/flutter_architecture/ios/Runner.xcodeproj/project.pbxproj
tools/ci/verify_environment_contract.py
tools/ci/test_environment_contract.py
related build scripts and tests
```

Skill不保存上述檔案中的固定mapping值，只保存讀取路由。

## Decision and execution flow

```txt
Receive template-adoption request
→ preserve original scope
→ delegate governing-template-development
→ produce Requirement Decision
→ classify full adoption／bounded repair／architecture change
→ inventory manifest and projections
→ validate required inputs
→ Design approval
→ Implementation Plan approval
→ isolated worktree
→ manifest-first mutation
→ Android projection
→ iOS projection
→ verifier／tests
→ platform evidence
→ holistic review and closure
```

Discussion-only request只能完成Requirement Decision、盤點與建議，不得建立Plan或進行mutation。

## Manifest-first and pre-mutation gates

所有identity變更必須先更新：

```txt
apps/flutter_architecture/config/environments.json
```

再同步Dart、Android、iOS與verification projection。禁止先改單一平台再反推manifest。

任何mutation前必須盤點：

```txt
manifest
↔ Dart entrypoints
↔ Android flavors／applicationId／labels／Kotlin package
↔ iOS schemes／configurations／bundle identifiers／display name
↔ verifier expectations
```

如果repository在採用前已存在drift，先記錄finding並修復或明確納入Design scope；不得把existing drift與新identity變更混在一起。

## Stop and escalation conditions

### Identity uncertainty

- Base identifier缺失或格式不合法。
- Organization namespace ownership無法確認。

### Contract conflict

- Environment identifiers重複。
- Production帶environment suffix。
- Development／staging不使用current approved suffix。
- Android與iOS identifier不一致。
- 要求改變三環境固定順序、數量、名稱或entrypoint authority。

使用者明確要求改變contract時，建立finding並重新分類為architecture change，不直接偷渡進採用工作。

### Secret and signing boundary

- 要求commit keystore、password、private key、provisioning profile或service account。
- 要求Skill代管production credential或直接建立production signing／Store publishing。

### Platform evidence gap

- Android toolchain或macOS／Xcode不可用。
- Native build因環境問題無法執行。

可完成的static contract evidence仍須保存，但不得宣稱完整跨平台採用通過。

## Evidence states

結果按證據分級：

```txt
Verified            completed verifier／tests／build／runtime evidence
Statically verified projection and contract tests passed; native build pending
Pending             requires platform or external input
Blocked             unresolved contract／safety／toolchain issue
Not in scope        explicitly excluded from accepted scope
```

例如Windows-only執行可記錄：

```txt
Manifest contract        Verified
Dart projection          Verified
Android static contract  Verified
Android build            Verified
iOS static projection    Verified
iOS Xcode build           Pending
Production signing       Not in scope
Store distribution       Not in scope
```

不得把iOS static projection描述成完整iOS build evidence。

## Validation matrix

### Contract and documentation

```bash
python3 tools/ci/verify_environment_contract.py
python3 -m unittest tools.ci.test_environment_contract
python3 -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

上述是本Skill adoption與文件治理的最低驗證，不是實際產品identity mutation的完整contract suite。真正執行模板採用時，必須以`docs/guides/native_environment_adoption.md`的「Exact Local Verification Commands」與「執行完整 contract verification」為current command authority，包括environment workflow matrix、local build commands、iOS workflow與shell portability tests；Skill與本Spec不得複製或縮減該清單。

### Repository regression

```bash
dart run melos run analyze
dart run melos exec -- flutter test
```

實際範圍由中央分類與Plan決定；Skill不得自行跳過必要regression。

### Android evidence

- Development Debug representative build。
- Production Release verification build。
- Staging至少由static verifier覆蓋；是否需要build由Plan明定。

### iOS evidence

在macOS／Xcode可用時：

- Development Debug Simulator build。
- Production Release generic-device verification build。

Production verification仍是unsigned artifact，不得描述成App Store artifact。

### Holistic review

- 核准identity scope內沒有template placeholder殘留。
- 沒有tracked secret。
- Manifest與所有projection一致。
- Native／generated diff合理。
- Guide與current state一致。
- 沒有擴大supported platform claim。
- 沒有把verification artifact稱為production distribution artifact。

## Failure handling

Verifier失敗時，先判斷manifest、projection或test expectation何者違反accepted contract，修正root cause後fresh rerun。不得削弱verifier來配合錯誤projection；只有accepted Design明確改變contract時才可修改verifier規則。

Native build失敗時，分類identity／configuration defect、toolchain defect、dependency transient或expected signing limitation。不得靜默改回template identifier、關閉fail-fast sentinel、移除environment validation或讓production使用development entrypoint。

Implementation worktree發現無關dirty files時，停止相關mutation並交由中央治理處理；不得覆蓋或刪除未知變更。

## Skill artifacts and wiring

Implementation預計新增：

```txt
.agents/skills/adopting-template-product-identity/
├── SKILL.md
└── references/
    └── pressure-scenarios.md
```

### SKILL.md

保存frontmatter trigger、core rule、中央治理委派、input contract、required reading、required behavior、stop／escalation rules與forbidden responsibilities。不得複製Guide的完整平台程序、mapping表格或所有verification commands。

### Pressure scenarios

保存discovery、explicit、discussion-only、missing-input、secret、contract conflict、scope escalation、existing drift與platform evidence案例。它是validation fixture，不是產品identity authority。

### Central routing

在`governing-template-development`的合適位置加入narrow route：accepted request確實採用repository template成為具體產品，並修改cross-platform product identity或environment display-name mapping時，才載入此Skill。

不得寫成所有native、configuration或包含`applicationId`字樣的工作都觸發。

### Registry and Guide

- 在`docs/governance/development_workflow.md`加入Pilot registry row。
- 在`docs/guides/native_environment_adoption.md`加入簡短Agent-assisted entry，並重申Guide仍是完整procedure authority。

### Explicit non-mutations

- 不修改`AGENTS.md`。
- 不修改root `README.md`或預設新增`docs/README.md` Skill清單。
- 不建立Milestone、roadmap active entry、VERSION bump或CHANGELOG release entry。
- 不新增automation script。
- 不為單一Skill寫死docs checker特例。

Checker只有在RED證據顯示通用Skill contract缺口時才修改，而且規則必須適用所有repository-local Skills。

## Pressure scenarios

正式Skill至少覆蓋：

1. Discovery：未指定Skill名稱，但要求把Flutter模板改成具體產品並同步Android／iOS identity。
2. Explicit shortcut pressure：明確指定Skill但要求跳過Requirement Decision或Design。
3. Discussion-only：只討論identity，不允許mutation。
4. Missing base identifier：允許盤點與建議，阻止mutation。
5. Secret safety：要求將keystore password寫入tracked Gradle config。
6. Contract conflict：三個environment使用相同identifier或錯誤suffix。
7. Scope escalation：順便增加`qa` environment或production signing。
8. Existing drift：採用前manifest與native projection已不一致。
9. Platform evidence：Windows-only環境要求宣稱Android與iOS全部完成。
10. Authority conflict：Guide摘要與ADR、manifest、source或tests不一致。

每個scenario都要保存prompt、runtime mode、expected behavior、observed result、deviation與disposition。Static scenario presence不等於behavioral validation。

## Implementation Task boundaries

Implementation Plan預期拆分：

```txt
Task 1 — RED and Discovery Baseline
Task 2 — Skill Core
Task 3 — Pressure Scenarios
Task 4 — Central Routing and Registry
Task 5 — Guide Entry and Authority Review
Task 6 — Clean-checkout Discovery and Holistic Final Review
```

每個Task遵守執行、focused review、修正、fresh review與通過後再進下一Task的雙層Task治理。

Task 1若證明沒有新Skill仍能穩定符合全部代表情境，必須重新檢查adoption必要性，不得忽略RED結果。

## Pilot upgrade and rollback

### Upgrade to Approved

升級前需證明：

1. Primary workflow clean checkout能discover Skill。
2. 未指定Skill名稱時，模板產品化需求能正確觸發。
3. Discussion-only不會產生mutation。
4. 不會跳過中央Requirement Decision。
5. Secret與signing壓力案例通過。
6. Contract conflict能正確停止或升級。
7. Windows-only情境不會虛報iOS build完成。
8. 沒有形成Guide／Skill雙重authority。

若runtime無法建立真正獨立、無對話記憶的behavioral context，可以接受restricted Pilot，但必須保留未完成evidence，不得冒充完整GREEN。

### Rollback

```txt
remove .agents/skills/adopting-template-product-identity/
→ remove central routing
→ remove registry row and Guide entry
→ rerun docs checker and discovery validation
```

Rollback不影響ADR、Guide完整程序、environment manifest或中央治理。

## Acceptance criteria

1. Skill維持薄型，不複製Guide或建立第二份identity mapping。
2. `governing-template-development`仍是唯一classification、approval與Task owner。
3. Trigger與non-trigger能區分完整模板採用、bounded repair與architecture change。
4. Base identifier不被猜測；secret不被寫入repository。
5. 所有mutation遵守pre-inventory與manifest-first。
6. 缺少平台時以evidence state誠實記錄，不製造虛假完成聲明。
7. Verifier失敗不以削弱verifier解決。
8. 不修改`AGENTS.md`、不建立新Milestone、不新增automation script。
9. Pressure scenarios覆蓋discovery、scope、安全、contract、drift與platform evidence。
10. Rollback可移除Skill與wiring，而不影響existing repository authority。

## Approval

使用者於2026-07-29依序核准Design Section 1至4，包括薄型Skill architecture、trigger／input／reading route、safety／validation／pressure scenarios，以及artifact／routing／registry／Pilot boundary。Section approval允許本Spec進入書面Task review，但不等於落檔版本已完成完整Task gate。Current Spec維持`proposed`，必須完成focused review、findings修正、fresh re-review、whole-Task review與使用者對書面Spec的明確核准後，才能轉為`accepted`並進入Implementation Plan。


