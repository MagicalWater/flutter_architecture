# Changelog

本文件記錄 Flutter Enterprise Architecture Template 的版本變更。

版本號代表 **Template Baseline Version**，不是 App 上架版本，也不是任何單一 package 的發布版本。

## Versioning Policy

本專案使用 Semantic Versioning 的概念管理模板基線：

- `MAJOR`：模板架構或使用方式有不相容變更，例如更換 Router、DI、State Management，或大幅調整資料夾結構。
- `MINOR`：新增可選能力或模板能力，例如新增 CI/CD、Design System、Refresh Token、Pagination 範例。
- `PATCH`：修 bug、文件修正、相容性修正、小型 dependency update。

由於這是模板專案，不一定需要每次 commit 都調整版本。只有當模板達到可交付基線，或完成一個明確 Milestone 時，才記錄版本。

---

## [Unreleased]

---

## [1.21.0] - 2026-08-18

### Added

- 完成Milestone 41 Pencil-to-Flutter Constraint-based Layout Architecture Corrective，新增screen-root layout model machine contract；一般App screen必須解析為`constraint-relationship`，真正spatial surface才可使用`intentional-spatial-canvas`且必須具有accepted `approval_ref`。
- 新增PTF-27～PTF-29 behavioral pressure，直接覆蓋whole-screen canonical-coordinate shortcut、bounded local overlay與genuine spatial canvas例外邊界。
- 完成Milestone 42 Pencil Presentation Ownership & Visual Token Governance Corrective，新增initiative-local `ui_design_ownerships` machine contract；risk-selected UI design values必須解析至`visual-authority`、`design-system`、`feature-local`或`component-local`，不得用generic UI Spec逃避owner decision。
- 新增PTF-30～PTF-34與same-literal negative edge／shared-semantic positive control，覆蓋FeatureVisualSpec逃避Design System、single-screen exact value污染Design System、page responsibility dump、FeatureUiSpec catch-all與asset path/provenance ownership錯置。

### Changed

- 完成Milestone 40 GitHub Repository Landing Page & Documentation Authority Restructure：root README改為產品化GitHub landing page，直接預覽productized topology與C4 dependency contract，並移除Milestone journal與重複的deep technical procedure。
- Publication前補齊README標題第一視覺：以fresh discovered `chatgpt-web-generation`生成約3:1的`Flutter Enterprise Architecture Template`藝術字橫幅，經使用者visual acceptance後接入README並取代重複的純文字H1；先前architecture-Hero C01／C02均保留為rejected historical evidence。
- Root README責任收斂為產品定位、能力摘要、Template adoption、Quick Start、platform summary與documentation routes；current snapshot、ADR、Guide、Agent policy與history維持各自canonical owner。
- Template → Product README transition與既有docs checker保持相容；Milestone 40本身未升版，其變更隨下一個可交付baseline一併納入1.21.0。
- `WritePrecheckProjectedCanvas`移除whole-page `designHeight=1672`、major-section canonical page-top ownership與screen-root scaled `RenderStack`；screen major sections改由Flutter `Column`、constraints與sibling relationships擁有page flow，bounded local `Stack`／`Positioned`只保留component-local composition責任。
- ADR-028、`implementing-pencil-flutter-design` Skill references與human Guide同步明確禁止把canonical design-space `x/y`經global scale直接當成一般production screen runtime placement system；single renderer與true Flutter widgets不能作為absolute-coordinate shortcut的豁免。
- Presentation ownership再收斂為`pages/` Page/View orchestration、`layout/` projection/render mechanics與`widgets/` bounded visual composition；custom RenderObject/projection infrastructure與bounded sections不再由page file直接擁有。
- `PencilCompatibilityVisualSpec`正式退休，未建立等價mega-class replacement；unused canonical/token fields直接移除，current proof palette與typography只保留為窄責任feature-local owners。
- ADR-018／ADR-028、Pencil-to-Flutter Skill／Guide與Design System boundary同步UI Design Ownership Architecture：shared semantic/theme values在semantic identity與stable shared ownership成立時promotion；single-screen exact geometry／decoration留smallest correct owner；asset identity/path/provenance沿用既有representation authority，不能塞進VisualSpec／VisualTokens。

### Validation

- Accepted `.pen`、canonical Pencil preview與360×640 runtime reference SHA-256均fresh符合manifest；沒有修改golden、visual threshold、crop或ignore region。
- Milestone 42 affected Pencil compatibility suite 22 tests PASS；mapping/visual machine contract 50 tests PASS；PTF-30～34、negative edge與positive control fresh behavioral pressure全數PASS。
- Combined release/full planner判定`docs_content + governance + tooling + test_only + app_feature + package + release`，`full_regression=true`、`generated_check=true`、Android/iOS build required。
- Workspace `flutter analyze`全5 packages PASS；完整Flutter regression全5 packages PASS：App 499、Design System 43、Auth 156、API Client 59、Core 4。
- Repository Python discovery regression 11 tests PASS；visual/mapping/policy focused suite 50 tests PASS；`docs_check` PASS；Windows generated-consistency等價流程完成build_runner、Drift schema export/normalize、drift worker compile與zero-substantive-diff驗證PASS；`flutter build bundle` PASS。

### Governance

- Requirement Decision、Design、Implementation Plan與Tasks 41-1～41-8依Level 4雙層Task governance完成holistic final review；Open P0=0、Open P1 without disposition=0。
- Milestone 42 Revised Design與rebuilt Implementation Plan均經雙層review與使用者核准；Tasks 42-1～42-9依雙層Task governance完成，combined Milestone 41+42 holistic Open P0=0、Open P1 without disposition=0。
- Template Baseline `1.21.0`已由Milestone 41 + 42 combined candidate正式發布；Task 42-10在exact published runtime SHA完成fresh clean-checkout Windows full regression、GitHub-hosted iOS Simulator與unsigned Production `iphoneos` verification，以及PTF-30～34 published-main fresh behavioral acceptance，Milestone 41／42正式closure。

---

## [1.20.0] - 2026-08-15

### Added

- 完成Milestone 39 Pencil-to-Flutter Fidelity Enforcement & Recovery Governance Corrective，新增initiative-local `implementation_mapping.json` machine contract與critical mapping validator。
- 新增critical runtime geometry／local fidelity gate，讓actual `RenderBox` evidence成為constraint-sensitive geometry authority，並以AND semantics鎖定`whole-screen PASS + critical local FAIL = overall FAIL`。
- 新增PTF-19～PTF-26 behavioral pressure contract，涵蓋critical mapping omission、cross-library same-name icon、accepted static asset redraw、runtime geometry mismatch、critical local failure、wrong-representation tuning、unauthorized deviation與single-client local MCP shortcut。

### Changed

- `implementing-pencil-flutter-design`仍為唯一Pencil-to-Flutter domain Skill；representation classification、provenance、Flutter mapping、visual validation與wrong-representation recovery全部收斂於既有Skill／references，不建立第二個Pencil Skill或global asset registry。
- Repository-governed Pencil workflow唯一允許`executor-local-mcp → pencil-session-mcp` isolated session；每個conversation／client必須fresh `session_create`、持有自己的exact `sessionId`並以`session_get_app_state`驗證active target。Visible Pencil Desktop／`pencil-local-mcp`不得作為admission、fallback或single-client替代route。
- Wrong source／asset／icon／representation一旦被review判定，affected mapping立即invalid；不得以padding、scale、crop、offset、opacity或threshold tuning挽救candidate，必須回classification／provenance、resolve replacement、更新mapping evidence並fresh affected validation。

### Validation

- Fresh behavioral RED／DISCOVERY／EXPLICIT GREEN證明PTF-19～PTF-25全部符合accepted contract；後續Pencil session唯一route corrective新增PTF-26，focused policy 16/16、完整`tools/docs` 89/89與`docs_check`均PASS。
- Windows release/full matrix PASS：5-workspace analyze、generated consistency、完整Flutter regression與Android development／production verification全部通過；App full suite 494 cases PASS。
- macOS isolated worktree對exact candidate `d60ed443ed02c380ca74f9d4ebb4e0cff0879d52`完成iOS Development Simulator與Production iphoneos unsigned verification；兩者皆`BUILD SUCCEEDED`，bundle identity與dSYM contract PASS。

### Governance

- Requirement Decision、Design、Implementation Plan與Tasks 39-1～39-7依Level 4雙層Task governance完成release-candidate review；Open P0=0、Open P1 without disposition=0。
- Template Baseline `1.20.0`已發布至`main`。Published-main驗證期間發現Android Production verifier同SHA重跑可能因cached AOT造成Flutter symbols遺失；已以invocation-specific split-debug-info staging修正並以同SHA、同artifact directory連續兩次Production verification證明idempotency。
- Final published main `9b0612093248ebceced5444c53093363660830c0`通過Android repeated-run、macOS/iOS Development與Production verification，以及fresh ChatGPT published-main behavioral acceptance；Open P0=0、Open P1 without disposition=0，Milestone 39正式Completed / Archived。

---

## [1.19.0] - 2026-08-15

### Added

- 完成Milestone 38 Template-to-Product Repository Infrastructure & CI Adoption Governance Corrective，新增root `repository_infrastructure.json`與ADR-031，讓首次產品採用明確選擇`manual-local`、`self-hosted`或`github-hosted` profile。
- 新增repository live infrastructure read-back／受控`CI_EXECUTION_MODE` mutation工具，覆蓋Actions least-privilege、runner、Branch Protection／plan availability與Environment secret **names**，不讀取secret values。
- 新增product-scoped managed artifact identity、三profile isolated acceptance與fresh no-handoff negative corpus。

### Changed

- Template → Product atomic completion新增selected-profile live disposition／acceptance gate；required CI infrastructure未完成前不得finalize `repository_kind=product`。
- Validation classifier正式辨識`repository_infrastructure.json`為governance path，避免manifest-only產品採用變更錯誤升級unknown/full。
- GitHub private repository admission現在明確處理不適用的fork-approval endpoint與plan-unavailable Branch Protection，不把一般403／422誤認成configured。

### Validation

- Whole-milestone planner判定full matrix；CI 268、docs 85、testing 11、visual 9 tests PASS，5-workspace analyze與full Flutter regression PASS，App suite 493 cases PASS，generated consistency PASS。
- Android Production Release與GitHub-hosted iOS Production/Simulator在Task 38-6 exact runtime candidate `d55e4ff215ee6656e438bbfdefe6420b04ee5319`均PASS；之後runtime app/native/build workflow bytes未變。
- `manual-local`與`github-hosted`產品acceptance PASS；`self-hosted` product-scoped Mac runner runtime因外部Mac connector不可用保留Design-authorized `BLOCKED_EXTERNAL` disposition，未以mock冒充成功。

---

## [1.18.0] - 2026-08-14

### Added

- 完成 Milestone 37 Template-to-Product Repository Bootstrap & Adoption Governance，新增 machine-readable root `repository_identity.json`、repository identity verifier與 ADR-030。
- 新增薄型 `adopting-template-repository` Skill、fresh admission lifecycle routing與 GitHub `Use this template` 的正式新人流程。
- 新增 `docs/guides/template_repository_adoption.md`，定義獨立 Product Repository birth、template provenance、Product Repository Version 與 fresh no-handoff completion contract。
- 新增 isolated Template → Product acceptance fixture與 atomic lifecycle regression owner，驗證 `template → prospective product → product` transition。

### Changed

- `AGENTS.md` fixed minimum read set新增 `repository_identity.json`；fresh Agent在任何 domain routing前先取得 machine lifecycle state，missing／malformed／unknown一律 fail closed。
- Root `VERSION`語意依 lifecycle分離：template state代表 Template Baseline，product state代表 Product Repository Version；來源 template baseline只由 `repository_identity.json.template_origin.baseline`保存。
- 首次 repository bootstrap需要 Android／iOS product identity時，仍委派既有 `adopting-template-product-identity`與`environments.json`／ADR-014／ADR-025，不建立第二份 native identity authority。
- Documentation checker支援 prospective repository identity manifest與 Product Repository Version，讓 blocking docs validation可在 canonical lifecycle transition前完成。

### Fixed

- 修正 bootstrap中途若先把 canonical `repository_kind`切為`product`，失敗或中斷後可能讓 fresh Agent誤判首次採用已完成的 partial-state風險。
- 修正 routing test把 current repository永久寫死為`template`，導致真正 adopted product repository無法通過治理驗證的 portability缺陷。
- 修正 docs checker只理解 Template Baseline marker、無法驗證 adopted product current version與 prospective product docs的 portability缺陷。
- 修正 Milestone routing index仍宣告 active milestone為None、與 Milestone 37 current roadmap衝突的 stale authority。

### Verified

- Repository identity、bootstrap routing、atomic lifecycle、docs與environment focused contracts fresh PASS；isolated product fixture完成 prospective identity/docs/native validation後才切 canonical product state，final product validation PASS。
- 三個彼此獨立、無 handoff 的 fresh ChatGPT contexts分別驗證 template首次採用、已採用product拒絕重跑bootstrap、invalid lifecycle fail-closed，全部 PASS。
- Whole-milestone validation planner fresh輸出`full`且`fail_safe=false`；Windows full Python／5-workspace analyze／完整Flutter regression PASS，App suite 493 cases PASS。
- Generated consistency PASS；Windows Android Development Debug與Production Release verification builds PASS。
- macOS exact candidate `ed2efe68ca42bd90d2c6ad3f7852bc50d6c924be` iOS run `local-20260814t013613z-34383-8c27d221` result=success、evidence_status=complete、278 artifacts。
- Independent clean-checkout repository identity、41 focused governance tests、docs checker與diff check PASS。

### Governance

- Requirement Decision、Design、Implementation Plan與Tasks 37-1～37-8依Level 4雙層Task governance完成；Open P0=0、Open P1 without disposition=0。
- `1.18.0`目前是local release candidate；尚未推送`main`，publication與Task 37-9 published-main post-release validation等待使用者明確核准。

---

## [1.17.0] - 2026-08-12

### Added

- 完成Milestone 36 Test Authoring Cost & Risk-Based Testing Governance Corrective，新增Risk-Based Test Authoring治理能力與ADR-029。
- 新增`Required`、`Recommended`、`no-new-test justified`與`Should-not-add`四種authoring disposition，允許低風險mutation正當產生0個new tests。
- 新增固定Risk-Based Authoring acceptance corpus與provider-neutral fresh ChatGPT behavioral pressure evidence，驗證Task數量不會機械轉換成test數量。

### Changed

- `governing-template-development`明確分離Test Authoring Decision與Milestone 35 Validation Execution Decision；TDD不再被解讀為每Task／class／layer都必須新增test。
- Testing Governance與Feature／Agent Guides改由risk／invariant／failure mode決定新增tests，不再以Domain／Data／Presentation／Integration逐層coverage作最低配額。
- Auth／Catalog／Profile繼續作architecture／behavior reference，但明確不是一般Product Feature的test-density quota。
- Foundation tests與Product Feature tests分開描述；security、migration、persistence、concurrency等高風險仍要求direct regression owner。

### Fixed

- 修正普通Feature在TDD、雙層Task與reference imitation下可能形成Task-for-test、class-for-test、layer-for-layer與trivial called-once testing的制度性風險。
- 修正`no-new-test justified`缺席導致Agent為滿足流程而捏造低價值RED test的治理缺口。
- 修正`testing_governance.md` baseline更新後既有docs contract仍硬編碼1.15.2的stale assertion。

### Verified

- Test Authoring governance contracts fresh PASS：5/5；docs contracts fresh PASS：57/57。
- Provider-neutral fresh ChatGPT behavioral pressure全情境PASS；5個implementation Tasks scenario只產生2類Required regression owners。
- Milestone 35 planner對本Milestone implementation range輸出`affected`，只選Auth／Catalog／Profile tests與App analyze；affected Flutter regression 245 cases PASS。
- CI Python contracts 246/246、test inventory 11/11、5 workspaces analyze與完整Melos Flutter regression fresh PASS；App full suite 493 cases PASS。
- Existing Auth／Catalog／Profile tests刪除數：0；本Milestone不以test count下降作成功KPI。
- Published-main canonical planner維持`release` level；Windows fresh CI contracts 246/246、inventory 11/11、authoring contracts 5/5、5-workspace analyze與完整Flutter regression均PASS，App suite 493 cases PASS。
- macOS published-main iOS Development Simulator與Production iphoneos unsigned verification builds均`BUILD SUCCEEDED`，bundle identity與dSYM contract PASS。

### Governance

- Requirement Decision、Design、Implementation Plan與Tasks 36-1～36-9依Level 4雙層Task governance完成；Open P0=0、Open P1 without disposition=0。
- 1.17.0已發布至`origin/main`並完成Task 36-9 published-main post-release validation；Milestone 36正式Completed / Archived。

---

## [1.16.0] - 2026-08-09

### Added

- 完成Milestone 35 Test Execution Cost & Change-Aware Validation Governance Corrective，新增single deterministic Minimum Sufficient Validation planner。
- 新增canonical change classes與focused／affected／workspace／full／release validation levels，並由workspace metadata推導package reverse dependents。
- 新增plan-driven validation runner、routing benchmark、phase-specific evidence identity與same-Task evidence reuse contract。

### Changed

- GitHub CI、Android／iOS build routing與manual-local入口改為消費同一validation plan，不再各自維護binary full-CI path logic。
- Testing inventory execution tier重新對齊current governance；current inventory為Tier 1=22、Tier 2=124、Tier 3=11、Tier 4=7、Unclassified=0。
- ADR-023、Testing Governance、AGENTS與Feature／Agent／CI Guides統一為planner-selected Minimum Sufficient Validation；full workspace regression保留作holistic、manual fail-safe與release gate。
- 同一Task在plan identity與selected inputs未改變時可重用phase-specific evidence；selected source／test／dependency metadata、failure recovery、validation-engine、holistic、release與post-release仍強制fresh。

### Fixed

- 修正ordinary feature／package／tooling／test-only變更被binary classifier過度提升為full workspace regression的治理漂移。
- 修正ordinary App／package Dart change無條件要求Android＋iOS build的false platform escalation。
- 修正known mixed changes因docs path不屬於舊`full_ci` path而被誤判unknown的問題。
- 修正CI direct-script planner import與affected multi-workspace sequential execution成本問題。

### Verified

- `tools/ci` fresh contracts：238/238 PASS；test inventory contracts：11/11 PASS。
- `dart run melos run docs_check`、五個workspace `flutter analyze`與完整Melos Flutter tests均fresh PASS；App full suite完成493 cases。
- Generated source、Drift v1～v6/current schemas、Drift Web worker與schema governance fresh rebuild／verification PASS，semantic generated diff為0。
- Windows production Android release APK fresh build PASS（56.8MB）。iOS fresh runner evidence保留為published-main Task 35-9 gate。
- Task 35-7同輪wall-clock：single feature 15.835s、single test 5.836s、full workspace 44.887s；常見small change path明顯下降且未刪除tests。

### Governance

- Requirement Decision、Corrective Design、Implementation Plan、Tasks 35-1～35-7與35-8 Holistic Final Review皆依full double-layer Task governance完成；Open P0=0、Open P1 without disposition=0。
- Unknown／invalid range／dependency parse／planner failure仍fail-safe full；release與post-release仍fresh full，不把full regression降級為nightly-only。
- 1.16.0已完成main publication與Task 35-9 published-main fresh validation；Windows full regression與macOS/iOS production verification build均PASS，Milestone 35正式封存。

---

## [1.15.2] - 2026-08-09

### Added

- 完成Milestone 34 Pencil Asset / Vector / Typography Mapping & Provenance，在Pencil extraction與Flutter mapping之間加入representation classification與provenance gate。
- 新增`asset-and-typography-mapping.md`，正式區分Layout primitive、Typography、Approved package icon、Vector asset、Raster asset與Dynamic drawing六類representation。
- 新增provider-neutral Skill behavioral validation Guide；fresh independent context可由Codex CLI、獨立ChatGPT對話或其他approved isolated-agent harness提供，不把任何單一CLI變成模板runtime dependency。

### Changed

- `implementing-pencil-flutter-design`現在要求先完成representation／provenance resolution，才可進Flutter owner mapping與production UI TDD。
- Human Pencil-to-Flutter Guide與Skill registry同步asset／font provenance責任、revalidation trigger與fresh behavioral validation route。

### Fixed

- 禁止複雜固定ornament以大量Container／gradient／magic numbers進行candidate-driven pixel chasing。
- 禁止指定font缺失時silent fallback至Roboto／system font、近似package icon未取得accepted disposition時直接替換、derived raster/vector缺少source／transformation／hash provenance時進production implementation。
- 禁止為pixel diff採用raster-everything shortcut，以及以數百hard-coded points的static `CustomPainter`重畫固定美術。

### Verified

- `tools/docs/test_pencil_representation_mapping_policy.py`：7/7 PASS。
- `tools/docs/test_pencil_single_renderer_policy.py`：5/5 PASS。
- External fresh-chat behavioral validation：PTF-13～PTF-18 RED為6/6 already-safe baseline；DISCOVERY 6/6 PASS；EXPLICIT GREEN 6/6 PASS；無P0/P1 Skill wording loophole。
- `dart run melos run docs_check`與`git diff --check`均PASS。

### Governance

- Milestone 34 Design、Implementation Plan、Tasks 34-1～34-4與34-5 Holistic Final Review均依雙層Task治理完成；Open P0為0，Open P1 without disposition為0。
- 此release只改變可重用Pencil-to-Flutter workflow contract與治理文件，沒有修改Flutter production source、runtime architecture、`.pen`或ADR-028 stable authority。

---

## [1.15.1] - 2026-08-09

### Fixed

- 完成Milestone 33 Corrective Single-Renderer Responsive Fidelity Recovery，移除parallel whole-screen renderer與stale production widgets，統一由`WritePrecheckProjectedCanvas`提供唯一production visual tree。
- 修正mobile runtime不再依breakpoint切換第二套hierarchy；同一accepted `.pen` design geometry以design-space projection、component-local renderer calibration與scrollable presentation適配不同portrait viewport。
- 修正visual authority文件仍沿用pre-calibration runtime `0.08 / 8.0` hard gate的authority drift；current Gate B固定為`ratio <= 0.10`、`mean <= 4.0`，Gate C只保留cross-renderer diagnostic。

### Verified

- C3 fresh canonical Gate A：`0.07707811093766684 / 2.9247655642221195` PASS。
- C3/C5 fresh runtime Gate B：`0.09769965277777778 / 2.495971137152778` PASS；Gate C `0.1297222222222222 / 3.8164214409722224`僅記錄diagnostic。
- C4 fresh Android development APK安裝至`emulator-5554`成功，runtime為`360 × 640 logical / DPR 1.5 / textScale 1.0`；tracked runtime screenshot SHA-256為`344099a6fe1d21d9a00cd54322a4c6bc78cb4ddbe928acc61ae7832917882976`。
- 使用者完成Android人工visual acceptance並明確判定UI還原通過；C5 responsibility boundary、Clean Architecture、single-renderer anti-cheat、test architecture與documentation reconciliation review全部PASS。

### Governance

- Corrective C1／CP2／C2／C3／C4／C5均依既有雙層Task治理完成；C3 completion commit為`de4178c`，C4/C5 completion commit為`b46ea58`。
- `pencil_compatibility`維持presentation-only boundary，沒有為視覺還原引入Domain、Data、Repository、UseCase、Bloc、service或DI例外，也未污染共用Design System。

---

## [1.15.0] - 2026-08-07

### Added

- 完成Milestone 33 Repository-local Pencil-to-Flutter Workflow Foundation，建立repository-local `.pen` visual authority、manifest／SHA-256鎖定、Pencil MCP admission與structure extraction流程。
- 新增`implementing-pencil-flutter-design` orchestration Skill與Taste companion Skill provenance／integrity registry，將Pencil-to-Flutter工作納入既有Requirement Decision與雙層Task治理。
- 新增presentation-only `pencil_compatibility` proof、generated Localization、Phosphor icon mapping、responsive layout、Windows canonical golden與Android runtime screenshot evidence。
- 新增deterministic PNG visual diff utility、固定8% canonical acceptance gate與historical same-era relative comparison，不允許silent resize、raster authority embedding或`FittedBox` fixed-canvas scaling。
- 新增可重複的人類操作入口`docs/guides/pencil_to_flutter_workflow.md`，涵蓋source／manifest、Skill provenance、Pencil extraction、Flutter mapping、visual acceptance、rollback與stop conditions。

### Changed

- Design implementation workflow明確區分既有Design System／theme ownership與feature-local exact visual spec；只有具有第二個真實consumer證據的值才可提升為global token。
- Canonical `941 × 1672` proof改為依Pencil exact bounds／typography實作的Flutter renderer；窄螢幕維持正常responsive scroll，不使用整頁縮放。
- Android native environment target guard只對`integration_test/`保留受控例外，一般錯誤entrypoint仍維持fail-closed。
- Current documentation routing、Skill registry、visual authority index與Milestone routing同步到Pencil-to-Flutter reusable workflow。

### Verified

- Holistic Final Review完成full local regression：Skill／docs／visual authority tests、docs check、五個package analyze、全workspace Flutter tests、development bundle與Android development artifact build均通過；App package達`+484 All tests passed`。
- Fresh Windows canonical golden在不更新accepted golden的情況下通過；Pencil reference deterministic diff為`7.7818568%`，低於固定`8%`門檻，mean absolute channel delta為`2.9956`，低於`8.0`門檻。
- Android runtime proof在BlueStacks `emulator-5554`通過，runtime為`360 × 640 logical / DPR 1.5 / textScale 1.0`，tracked screenshot SHA-256為`358d7cbeea737ff8fefeb2629cfffca6ccf214c828c127c587149c2928b96919`。
- Cross-Task Final Review disposition為`A — Complete workflow capability; approve 1.15.0 release candidate`，Open P0為0、undispositioned P1為0。

### Governance

- Milestone 33 Design、Implementation Plan、逐Task focused／whole-Task review、corrective recovery與Holistic Final Review均依雙層Task治理完成；release identity、merge、push與post-release closure仍分離治理。
- Third-party Skill bytes、source commit、license、loaded path與rollback／upgrade gate均受ownership-aware lock治理；external design source不得取代repository-local accepted authority。

---

## [1.14.0] - 2026-07-31

### Added

- 完成Milestone 32 CI產物本機化與GitHub儲存空間切換，建立repository checkout外的managed local artifact store。
- 新增job／run manifest、SHA-256、multi-job aggregation、retention class、capacity、bounded pin、dry-run cleanup、trash／restore／purge與exact root安全契約。
- 新增GitHub Actions storage read-only inventory、exact-ID deletion manifest、review attestation、approval token、fresh inventory drift與partial deletion evidence gate。

### Changed

- `manual-local`與`self-hosted`的CI、Android、iOS、Observability及有界failure evidence改由本機managed store擁有；GitHub Actions保留control plane、checks與summary責任。
- Self-hosted workflows不再使用`actions/upload-artifact`或`actions/cache`保存日常evidence；`github-hosted`只保留人工明確選擇的有界例外transport。
- iOS build workspace改為暫存於job-local `.build`，finalize前安全移除；永久evidence只保留`.app`、dSYM、metadata、summary與checksums。
- GitHub cleanup drift fingerprint只綁定exact deletion scope；`expired`等不影響DELETE的provider metadata變動不再造成假漂移，任何ID、bytes或候選scope變動仍fail closed。

### Verified

- 202個repository CI contract tests、documentation checks、五個package analyze與全部Flutter tests通過；App suite 463 tests passed。
- Windows與Mac Android development／production代表build、Mac iOS development Simulator／production unsigned device build、symbols、mapping與dSYM均fresh通過。
- Self-hosted CI、Android與iOS runtime acceptance、offline no-fallback、Observability controlled event disabled、checksums、secret scan與bounded evidence均通過。
- 依reviewed manifest `7ad138bb845e42cbb133d07c`刪除110個GitHub Actions artifacts與3個caches；113次exact-ID attempt全部成功，fresh inventory與逐IDre-query均確認0個objects／0 bytes。

### Security

- GitHub不可逆刪除需要reviewed manifest、scope-derived manifest ID、out-of-band approval token、顯式execute gate與delete前fresh GET同時成立。
- Artifact／cache name與key、diagnostics及managed evidence會執行secret leakage scan；provider config、service account、signing material與完整process environment不進入manifest。
- Local cleanup拒絕repository／worktree／runner temp root、path traversal、symlink escape、active lock與store generation drift；不可使用直接recursive filesystem deletion繞過。

### Governance Recovery

- Template Baseline 1.13.0發布後發現Milestone 31雙層Task治理證據不足，已完成R0～R11 Governance Recovery。
- Design Spec、Implementation Plan、逐Taskreview／re-review、Codex RED／DISCOVERY／EXPLICIT GREEN／REFACTOR、checker歷史RED／current GREEN、holistic review、fresh full regression、push、clean-checkout與remote CI／Android／iOS validation均完成。
- Recovery修正治理證據與authority，不改寫1.13.0既有發布身份。

---

## [1.13.0] - 2026-07-24

### Added

- 完成Milestone 31 Template Development Workflow Governance，在`.agents/skills/governing-template-development/`建立repository-local executable workflow Skill。
- 新增Level 0～5工作分類、Requirement Decision、artifact／Superpowers routing、雙層Task模式、Skill adoption governance與pressure scenarios。
- 新增`docs/governance/development_workflow.md`作人類治理總覽。

### Changed

- `AGENTS.md`要求所有需求、Bug、Refactor、Migration、Architecture、Release與治理工作先經Workflow Governance Skill分類。
- 修正Milestone 30 closure的stale／duplicate routing與metadata baseline。
- Documentation checker支援Agent Skill標準frontmatter，並新增stale與duplicate Milestone routing gates。

### Verified

- 17個documentation checker tests、docs_check與workspace analyze通過。
- 全部Flutter package tests通過；App suite 463 tests passed。
- Skill structure、relative links、Level 0～5與pressure contract驗證通過。

---

## [1.12.0] - 2026-07-24

### Added

- 完成Milestone 30 Test Suite Audit, Rationalization & Governance，建立repository-wide machine-readable test inventory、coverage owner、production／historical boundary與Tier 1～5 execution matrix。
- 新增`docs/guides/testing_governance.md`，定義新增、搬移、合併、刪除、封存、large-file與shared fixture規則。
- 新增Catalog historical migration專屬owner，將current local boundary與sqflite historical oracle分離。

### Changed

- Auth與Catalog current integration tests改用production Drift adapters，不再以historical sqflite implementation作current fixture。
- 測試清理改採replacement manifest與primary-owner證據，不以測試數或LOC下降作為成功標準。
- CI、Platform、Documentation與Generated contracts完成ownership審查；維持現有change-aware與fail-safe routing，不新增無收益的sharding或generic YAML DSL。

### Verified

- Final inventory為136 files、22,943 LOC、769 static cases；Milestone起始與結束case總數相同，沒有coverage loss。
- 全部Flutter package tests、88個CI Python contracts、15個documentation checker tests、inventory tooling與workspace analyze通過。
- Generated consistency、Drift v1～v6/current schema export、Web worker／Wasm governance、historical migration／rollback及App bundle build通過。

---

## [1.11.0] - 2026-07-24

### Added

- 完成Milestone 29 Drift Persistence Migration，建立App-owned Drift schema、DAO、native／Web opener與v1～v6 historical migration contract。
- 新增tracked Drift schema snapshots、worker／Wasm asset治理、clean generation gate與database-critical change-aware CI分類。
- 新增Android／iOS精確同檔path bridge、macOS background opener smoke與Web experimental storage `explicit reset` disposition。

### Changed

- Drift成為唯一production database authority；AuthUser與Catalog Offline Cache均由同一個`AppDatabase` singleton管理。
- sqflite schema、initializer與production adapters移至或替換為test-only historical compatibility harness；移除`sqflite_common_ffi_web`與`sqflite_sw.js`。
- Flutter 3.44 iOS integration明確維持CocoaPods-compatible mode，避免auto-SPM與current runner contract衝突。

### Verified

- v1～v6 fixtures全部可升級至canonical v6，migration failure rollback、foreign keys、AuthUser single-row與Catalog chain invariants均通過。
- Workspace完整analyze、documentation、generated consistency與全部tests通過；App suite共467 tests。
- Android production verification APK、iOS Development Simulator unsigned app與dSYM、macOS production opener及App bundle build均通過。
- Web、Windows、macOS與Linux未因套件能力被提升為Supported；Web仍採明確reset且無false runtime claim。

---

## [1.10.0] - 2026-07-24

### Added

- 完成Milestone 28 Connectivity and Offline State Foundation，建立App-owned `unknown`／`offline`／`online` typed connectivity authority。
- 新增provider-neutral `ConnectivityAdapter`、`connectivity_plus` reference adapter、startup snapshot、stream coordination與resume recheck。
- 新增App-wide localized offline banner，以及Catalog頁面可見期間的opt-in reconnect revalidation。

### Changed

- Catalog reconnect使用獨立operation state與failure surface，不偽裝成manual refresh；manual refresh、append、query switching與reconnect具明確ordering、dedupe與generation protection。
- Backend reachability與單次operation failure仍由Repository／Result／Failure邊界表達，不由network interface狀態推導。

### Verified

- Connectivity、Catalog與Auth跨層focused suite共150 tests通過；Catalog presentation focused suite共57 tests通過。
- Workspace analyze、documentation checks與generated consistency通過。
- Android development APK與iOS Development Simulator app完成native plugin integration build；production signing、Store distribution與physical-device network toggle維持deferred。

---

## [1.9.0] - 2026-07-24

### Added

- 完成Milestone 27 Production Observability Foundation，建立provider-neutral reporting contract與Firebase Crashlytics reference adapter。
- 新增release identity、fatal／unexpected／degraded routing、privacy／collection policy與provider failure isolation。
- 新增Android mapping／Flutter symbols、iOS dSYM、controlled staging non-fatal與protected Environment remote acceptance。
- 新增`manual-local`／`self-hosted`／`github-hosted`三種CI execution mode、`repository-default`manual sentinel與repository-scoped Mac ARM64 self-hosted runner。

### Changed

- Self-hosted runner停用GitHub remote Flutter／Pub cache transport，避免大型cache storage與網路成本；GitHub-hosted模式仍可使用explicit Pub cache。
- Android Firebase Gradle task改為依各environment config啟用；缺少development config時不再阻擋development build。

### Verified

- Android與iOS controlled non-fatal均已在Firebase Console完成event ingestion與symbolication驗證。
- iOS stack已解析`ObservabilityAcceptanceEvent.emit`、bootstrap guard相關函式、source file與line。
- Self-hosted main／manual routing、PR denial、offline no-fallback、persistent workspace secret cleanup與完整Android／iOS代表build均通過。

### Security

- Pull Request不讀取provider secrets，也不進入`water`帳號self-hosted runner。
- Observability remote acceptance只允許manual explicit gate；普通main push不會建立受控事件或執行symbol upload。

---

## [1.8.0] - 2026-07-23

### Added

- 完成 Milestone 26 Native Flavor & Product Identity Foundation，建立 `development`／`staging`／`production` 的 App-owned cross-platform mapping manifest。
- Android 新增 `environment` product flavor dimension、三組 application ID／display name／Dart target projection，以及錯 target與multi-environment invocation fail-fast。
- iOS 新增 Development／Staging／Production shared schemes、九組 build configurations、environment xcconfig、bundle identity／display name projection與 CocoaPods custom configuration mapping。
- 新增 `NATIVE_ENVIRONMENT` bootstrap mismatch guard，在 DI graph 與 `runApp` 前驗證 native environment與Dart entrypoint一致。
- 新增 environment-aware Android／iOS local verification commands、artifact metadata與GitHub-hosted development／production representative build matrix。
- 新增產品採用指南，定義 manifest-first identifier／display name／API domain替換順序，以及 verification、production signing與Store distribution責任邊界。

### Changed

- Template Baseline由1.7.0升級至1.8.0；native flavor、product identity與cross-platform environment verification屬新增模板能力，因此採MINOR版本。
- `main.dart`只保留development compatibility用途；正式native build與CI必須使用environment-specific flavor／scheme與Dart entrypoint。
- Staging與production real API均要求HTTPS；production額外拒絕localhost、loopback、`.invalid`與template placeholder hosts。
- Repository Android production APK維持debug verification signing，iOS production `.app`維持unsigned verification build；兩者皆明確標示`distribution=not production-ready`。

### Security

- Repository與Git history未加入production keystore、certificate、Apple Team、provisioning profile、Store credential或workflow signing secret。
- Native sentinel只用於證明mapping一致性，不成為第二個environment authority；錯配與缺失在正式native entrypoint維持fail-closed。
- Production signing、AAB、IPA、TestFlight、Play Store與App Store publishing仍是deferred scope。

### Verification

- Environment verifier與47個repository Python contracts通過；documentation、workflow、shell portability與whitespace checks通過。
- Workspace五個packages analyze與全部Flutter tests通過；App suite 378 tests passed，generated consistency無tracked drift。
- Final gate重新建立Android development Debug、Android production Release、iOS Development Debug Simulator與iOS Production Release unsigned device四個代表artifact，identifier、entrypoint、API mode與distribution metadata均符合contract。
- Deliberate Android target mismatch與multi-environment invocation均以預期Gradle錯誤失敗；16個App configuration focused tests確認sentinel、HTTPS、mock與placeholder host限制維持fail-closed。
- GitHub Actions CI run `29970226490`、Android run `29970226525`與iOS run `29970226484`全部成功；iOS toolchain closure run `29971307542`於macOS 15.7.7、Xcode 16.4、Flutter 3.41.6與CocoaPods 1.17.0再次通過兩個iOS代表build。

---

## [1.7.0] - 2026-07-22

### Added

- Milestone 25建立tracked iOS runner、iOS 13 native contract、CocoaPods resolution、Face ID／Keychain設定、clean Simulator build與runtime smoke。
- 新增macOS Design System golden authority與GitHub-hosted `iOS / Simulator Build`workflow。

### Fixed

- 修正generated consistency script依賴Bash 4 `mapfile`而無法在預設macOS Bash執行。
- 修正Android artifact script在`pipefail`下以`head`讀取版本可能於build成功後錯誤失敗。

### Changed

- Template Baseline由1.6.1升級至1.7.0；Milestone 25完成final holistic review與remote validation後正式封存。
- iOS現在分類為Supported：具有tracked runner、local Simulator runtime evidence、macOS golden authority與GitHub-hosted unsigned Simulator build gate。
- Physical-device biometric acceptance與distribution仍有正式deferred disposition；Supported不代表device-verified、IPA、TestFlight或App Store-ready。

### Verification

- GitHub Actions CI run `29910826260`通過：Quality、Generated Consistency與Tests全部成功。
- GitHub Actions iOS run `29910826245`於`macos-15`成功完成CocoaPods resolution與unsigned Simulator Xcode build。
- GitHub Actions Android run `29910826210`成功建立並上傳verification APK artifact。
- iOS remote build產出`Flutter Architecture.app`，Bundle Identifier為`com.example.flutterarchitecture`、deployment target為13.0，且未使用Development Team或provisioning profile。

---

## [1.6.1] - 2026-07-22

### Fixed

- 修正Design System golden test依賴host字型與跨作業系統rasterization差異，改為載入Flutter SDK內固定Roboto／Material Icons並使用Windows、Linux各自經review的golden authority。
- 修正Linux大小寫敏感檔案系統無法解析Flutter SDK字型檔名的問題。
- Tests job失敗時會上傳golden差異圖片artifact，保留14天供remote review。
- 修正Melos `docs_check`將Python executable寫死為`python`而無法在預設macOS環境執行的問題，改由repository-owned Dart launcher解析Python 3。

### Changed

- `actions/checkout`、`actions/setup-java`、`actions/cache`與`actions/upload-artifact`升級至Node 24世代major，並維持完整commit SHA pinning。
- Template Baseline由1.6.0升級至1.6.1；本次為CI跨平台相容性與操作性修正，不新增新的模板能力。

### Verification

- GitHub Actions CI run `29887025664`通過：`CI / Quality`、`CI / Generated Consistency`、`CI / Tests`全部成功。
- GitHub Actions Android run `29887025645`通過，release APK build與artifact upload成功。
- Android artifact `flutter-architecture-android-release-2ea623c02b2f4957ef115ad17ea465a8235892ee`已建立，digest為`sha256:80453c4478b4c745d773f6c7aab3d16e1626c24e0875cb82a047c51d766f891e`，retention至2026-08-05。
- Windows本機五個packages analyze、全部Flutter tests、documentation checks與workflow static contracts通過。

---

## [1.6.0] - 2026-07-22

### Added

- 完成 Milestone 24 CI/CD Foundation，新增 Pull Request、`main` push與manual dispatch的GitHub Actions repository quality workflow。
- 新增穩定required checks：`CI / Quality`、`CI / Generated Consistency`與`CI / Tests`。
- 新增`main`與manual dispatch的Android release APK verification artifact workflow，包含commit SHA命名、metadata與14天retention。
- 新增repository-owned exact toolchain authority、tracked root `pubspec.lock`、generated consistency與Android artifact scripts。
- 新增ADR-023與CI／Branch Protection／failure／rollback操作指南。

### Changed

- Template Baseline由1.5.1升級至1.6.0；依Versioning Policy，CI/CD屬新增模板能力，因此採MINOR而非PATCH。
- Generated consistency gate現在拒絕實質generated drift，同時安全處理已驗證的Windows Freezed行尾空白差異。
- Milestone 24完成final holistic review並封存；Branch Protection仍為文件化建議，未宣稱已修改GitHub repository settings。

### Security

- Workflows使用最小`contents: read`權限、不讀取secrets、不使用`pull_request_target`，且所有Actions pin完整commit SHA。
- Android artifact明確分類為debug signing、verification-only與not production-ready；未加入production keystore、Store publishing或deployment credentials。

### Verification

- Documentation checker unit tests 14 passed，`docs_check`通過。
- Workspace五個packages analyze與全部Flutter tests通過；App suite 370 tests passed。
- Generated consistency由乾淨commit通過，沒有實質tracked drift或untracked output。
- Android release APK由repository script成功建立，約57.1 MB，SHA命名與metadata traceability通過。
- Workflow YAML、events、permissions、concurrency、cache contract與Action SHA pinning完成static review。

---

## [1.5.1] - 2026-07-21

### Added

- 完成 Milestone 22 Documentation Authority & Navigation Foundation，建立正式 Documentation Hub、task-based AI reading contract、Audits／Plans／Milestones indexes 與文件治理政策。
- 新增 App、Core、API Client、Auth 與所有 production Feature README，使 App／Package／Feature README coverage 達 10 / 10。
- 新增 Python standard-library documentation checker 與 Melos `docs_check` 指令，驗證 relative links、baseline、managed metadata、explicit IDs、active milestone status 與 README coverage。

### Changed

- 將 `docs/project_context.md` 重寫為 current-only snapshot，並以 migration manifest 保存原有歷史內容的 authority routing。
- 將 2,217 行 aggregate Roadmap 分離為精簡 index、唯一 active authority、candidates 與 closed milestone routing。
- Legacy `docs/adr/` 與 `docs/architecture/` 加入 Historical／Superseded warning，避免被誤認為目前架構 authority。
- 正規化 Auth、Catalog、Profile、Protected、Shell 與 Design System README，使其只描述 local current contract，不再保存 milestone implementation journal。
- Template Baseline 由 1.5.0 提升至 1.5.1；本次是相容的文件治理、navigation 與 local tooling 改進，未改變 production runtime behavior。

### Verification

- `dart pub get` 通過。
- `dart run melos run docs_check` 通過。
- Workspace 五個 packages `flutter analyze` 通過。
- Workspace 全部 Flutter tests 通過。
- `apps/flutter_architecture` 的 `flutter build bundle` 通過。

---

## [1.5.0] - 2026-07-21

### Added

- 完成Milestone 21-2：新增versioned local unlock preference、typed read taxonomy、serialized SharedPreferences store與authenticated-only enable / disable policy。
- Logout與unauthenticated restore已清理stale local unlock preference；enable race共用Auth lifecycle generation並提供typed storage failure。
- 完成Milestone 21-3：新增App-owned cold-start pre-restore gate、single-prompt與完整Auth lifecycle lease；navigation coordinator不再無條件觸發restore，`M21-PR01` P0正式關閉。
- 完成Milestone 21-4：新增localized locked route／surface、retry與server-login escape，以及App-owned 5分鐘resume grace period；逾時resume先清Session再要求unlock。
- 完成Milestone 21-5：加入production enable / disable設定入口、Android `FlutterFragmentActivity`、Biometric permission、AppCompat theme、release artifact與API 35 runtime evidence。

- 完成Milestone 21-1 Local User Presence foundation：新增純Dart verifier contract、typed capability / verification / operational failure，以及App-only `local_auth` adapter與lazy singleton DI。
- Local Auth adapter固定biometric-only、禁止device credential fallback與background自動重試；明確區分not verified、cancel、not enrolled、no hardware、temporary / permanent lockout與temporarily unavailable。

### Documentation

Milestone 19至21 Authentication Security initiative均已完成final review並封存；Current Template Baseline為1.5.0。

- 完成Milestone 21-0 Planning Review與跨文件一致性review；固定pre-restore local user-presence gate、default-disabled preference、locked Session null、typed capability / failure、latest-intent與5分鐘resume grace period。
- 建立21-1至21-5詳細implementation plan與12項planning findings；本階段不加入`local_auth`、不修改Android Native或VERSION。
- 21-1 implementation review修正plugin `false` result不得錯標cancelled；workspace analyze與596項tests通過，Android Native、startup restore與VERSION維持不變。

### Changed

- Template Baseline由1.4.0提升至1.5.0；理由是Milestone 21形成可啟用、可關閉、可在cold start與resume gate Session restore的Android本機生物辨識解鎖能力。

### Security

- Biometric只驗證本機user presence，不取代Server authentication，不保存biometric資料，也不構成cryptographic Device Binding。
- Locked與prompting期間`SessionManager`維持null；Guard、token provider、Refresh、Profile與navigation均無authenticated authority。

### Verification

- Workspace五個packages analyze與626項Flutter tests通過。
- Android release APK build通過，size 59,850,883 bytes，SHA-256為`6fb6d3a82073a77e001a0b1d9749fcf755308f1476e8f8c2406cac4ace0a6ba6`。
- Release merged manifest為minSdk 24、targetSdk 36、`allowBackup=false`，MainActivity使用`FlutterFragmentActivity`，包含Biometric與Android compatibility Fingerprint permission。
- API 35 emulator完成release APK install與startup smoke；not-enrolled / unavailable路徑可重現，生物辨識success則由adapter、policy、startup與widget deterministic tests覆蓋，未誤宣稱未觀察到的實機指紋成功旅程。

---

## [1.4.0] - 2026-07-21

### Added

- 完成Milestone 20 OTP Step-Up Authentication：Login使用`authenticated | otpChallenge` typed union，新增Verify / Resend contract、validated challenge、typed OTP failure metadata與Stateful deterministic Mock。
- 新增authenticated-only Secure credential → AuthUser → Session commit boundary；OTP pending與Resend replacement不保存credential、不建立Session。
- 新增AuthBloc explicit OTP presentation state machine、latest-intent generation、active challenge identity ordering與Session null → null authoritative clear。
- 新增可存取的OTP route與頁面、one-time-code輸入、Verify / Resend loading、authoritative cooldown、English與zh_TW copy，以及App-owned Login → OTP → Profile navigation。

### Changed

- Protected Route仍只依`SessionManager`；OTP pending不被視為authenticated，也不建立第二套route authority。
- Template Baseline由1.3.0提升至1.4.0；理由是新增完整且可重用的server-issued OTP step-up authentication能力。

### Security

- Password、OTP code、Token與raw challenge identity不透過transport／domain／event `toString()`或production logging暴露。
- Repository generation是credential、User與Session side-effect的唯一stale-response authority；Bloc generation與challenge identity只保護presentation metadata。
- 本能力不宣稱防止SIM swap、SMS interception、rooted device、provider compromise或server compromise；Real API只提供contract，不保證SMS delivery。

### Verification

- Workspace五個packages analyze全部通過。
- 完整Flutter tests共585項通過：Core 4、Design System 43、API Client 55、Auth 144、App 339。
- Android release APK建立成功，size 59,042,017 bytes，SHA-256為`4ce541f5553979549ccd5a940cfd1c93da4abb7e6f7dca4c5a1fbbe8b395bc4e`。
- Release APK已安裝並在Android 15 / API 35 emulator成功啟動；完整OTP journey由mounted router、Bloc、Repository、Mock與widget regression覆蓋。裝置層自動文字輸入未作為安全或delivery證據。
- 11項Milestone 20 planning findings均已由implementation evidence關閉；無Open P0／P1。

---

## [1.3.0] - 2026-07-21

### Added

- 新增App-owned `flutter_secure_storage` credential adapter，以單一logical payload保存Access Token、Refresh Token、userId與expiration metadata。
- 新增Auth-specific credential、legacy與user store boundaries、sealed credential read taxonomy、唯一`AuthCredentialMigrationCoordinator`與共用lifecycle cleanup policy。
- 新增SharedPreferences Legacy Token Pair migration、完整read-back validation、identity-aware authority matrix、rollback與cleanup retry contract。
- 新增repo-owned Android smoke tooling與deterministic HTTPS Auth fixture，驗證Login、401 Refresh rotation、request replay、restart persistence、Legacy upgrade migration與Logout cleanup。

### Changed

- Production credential authority由SharedPreferences原子切換為default `FlutterSecureAuthCredentialStore` singleton；Repository、Refresher與Migration Coordinator共用同一Secure store。
- SQLite繼續只保存公開`AuthUser` identity；Legacy SharedPreferences只保留migration與cleanup責任。
- Android維持唯一Supported target，Secure Storage最低contract為`maxOf(flutter.minSdkVersion, 23)`，App-wide `allowBackup=false`。
- Template Baseline由1.2.0提升至1.3.0；理由是Milestone 19新增可交付的Secure credential storage與migration能力，不是單純文件補強。

### Fixed

- 修正Refresh request DTO未被Retrofit序列化為JSON，導致real API refresh body為空的production P1 regression。
- 關閉Milestone 19 planning findings `M19-PR01`至`M19-PR06`；無Open P0／P1。

### Verification

- Workspace五個package analyze全部通過。
- 完整Flutter tests共542項通過；Python fixture tests 7項通過。
- Android development release APK建立成功，SHA-256為`43bc34d2ead9424e862ba8e11d060520fd9d8bb4a6d5394dc59b7c2322935112`，size 58,927,329 bytes。
- Release merged manifest實際minSdk 24、targetSdk 36、`allowBackup=false`；permissions只有INTERNET與既有dynamic receiver保護權限。
- Android API 35 root-capable emulator完成Login、Restore、Refresh rotation、restart persistence、predecessor upgrade migration與Logout runtime smoke。
- App／host evidence未保存raw credential；temporary CA已移除，system CA集合恢復。

### Security Scope

- 本baseline只提供credential-at-rest hardening，不宣稱防止rooted device、runtime memory擷取或server compromise。
- OTP、Biometric Prompt、Device Binding與Passkey仍屬後續獨立Milestone。

### Milestone 19 detailed changes

### Added

- 規劃 Authentication Security & Step-Up Verification initiative，正式拆分為 Milestone 19 Secure Credential Storage & Migration、Milestone 20 OTP Step-Up Authentication 與 Milestone 21 Biometric-gated Local Session Unlock。
- 新增 Architecture Decision 022，定義三個 Milestone 的依賴順序、package / App boundary、review gate、非目標與版本規則。
- 完成Milestone 19-0 Planning Review與最終文件一致性review，新增Threat Model、Secure × Legacy × User decision matrix、migration owner、typed credential read taxonomy、cleanup / reporting contract與六項planning findings；P1 findings已取得approved disposition，但仍待implementation與tests正式關閉。
- 建立並review Milestone 19-1 Auth Persistence Seam詳細implementation plan，明確拆分typed store contract、App-owned SharedPreferences / SQLite adapter、Repository / Refresher rewiring、DI與regression gate。
- 建立並review Milestone 19-2 Secure Credential Store Adapter implementation plan，明確定義App-only `flutter_secure_storage: ^10.3.1`、single logical payload、typed read / failure mapping、named Secure DI binding、Android minimum SDK 23、App-wide backup disable與artifact gate。
- 建立並review Milestone 19-3 SharedPreferences Legacy Migration implementation plan，拆分migration public contract、destructive matrix、Secure authority cleanup、write/read-back validation、named DI與concurrency regression gate。
- 建立Milestone 19-4 Auth Lifecycle Integration implementation plan，拆分diagnostic / cleanup boundary、Restore migration、Login Secure persistence、Refresh與passive invalidation、Logout、原子DI authority switch與regression gate。
- 完成Milestone 19-4 implementation plan review，固定Auth lifecycle diagnostic taxonomy、reporting移出mutation lock、Task 6前不得啟用Secure lifecycle production path、operation-owned Login compensation與passive invalidation先清Session契約。
- 完成Milestone 19-1 Auth Persistence Seam：新增Auth-specific credential、legacy與user store contracts及sealed read taxonomy；將SharedPreferences / SQLite adapters與plugin ownership移至App layer；Repository與Refresher改用三個明確store boundaries；移除舊`AuthLocalDataSource`、聚合local-store介面與`packages/auth`的plugin dependencies。
- 完成Milestone 19-2 Secure Credential Store Adapter：App加入`flutter_secure_storage: ^10.3.1`、App-owned Secure adapter、single logical Token Pair payload、typed corruption / operational failure mapping、named Secure DI binding與Android artifact contract。
- 完成Milestone 19-3 SharedPreferences Legacy Migration：新增唯一`AuthCredentialMigrationCoordinator`、sealed resolution與immutable diagnostics，實作Secure × Legacy × User decision matrix、Secure authority、Legacy→Secure write / read-back validation、rollback與cleanup pending policy。
- 新增App-owned Auth migration diagnostic reporter adapter與fixed safe reporting context；DI以named Secure store、Legacy store與User store組裝migration coordinator。
- 完成Milestone 19-4 Auth Lifecycle Integration：新增Auth lifecycle diagnostic與共用cleanup policy，將Restore migration、Login Secure persistence、Refresh rotation、passive invalidation與Logout destructive cleanup整合至既有mutation ownership。

### Changed

- 下一個正式方向改為先完成 Secure Credential Storage 與 SharedPreferences legacy migration；OTP 與 Android Biometric runtime 分別延後至後續獨立 Milestone。
- Decision 022由Proposed升為Accepted；Milestone 19不採persistent migration marker，並明確禁止nested Auth mutation lock與Secure unavailable時fallback Legacy。
- Auth persistence DI由App唯一Composition Root顯式綁定三個lazy singleton stores；SharedPreferences仍維持19-1 production credential authority，未提前加入Secure Storage或migration policy。
- 19-2 plan review固定Secure adapter只以named binding存在；default SharedPreferences authority不變，plugin operational exception與unknown programming error分流處理。
- Android Secure Storage minimum SDK contract改為`maxOf(flutter.minSdkVersion, 23)`，避免Flutter build upgrader覆寫literal設定，同時允許Flutter未來提高最低版本；App-wide backup維持停用。
- 19-3 plan review固定resolution使用immutable diagnostics list；destructive cleanup未完整成功時不得回成功unauthenticated；read-back validation比較完整Token Pair與metadata，validation state failure、plugin operational failure及rollback cleanup error採明確typed priority。
- Migration Coordinator固定使用`resolveUnlocked()`，不自行取得Auth mutation lock；guard與re-entry regression證明不使用nested lock、persistent marker或跨呼叫mutable authority state。
- Android scaffold contract test同步19-2核准設定，驗證`minSdk = maxOf(flutter.minSdkVersion, 23)`而非過期literal contract。
- Auth production credential authority已原子切換為default `FlutterSecureAuthCredentialStore` singleton；Repository、Refresher與Migration Coordinator共用同一Secure store，named Secure binding與所有transitional constructor / subclass已移除。SharedPreferences只保留Legacy migration與cleanup責任。
- Restore reporting固定移出mutation lock；Login與Refresh維持persistence-first，destructive／passive cleanup依Secure、Legacy、User順序全部嘗試，unknown error保留identity與caught stack。

### Notes

- Milestone 19-1 implementation review已通過；workspace analyze、437項完整tests與App bundle build全數通過。未修改Native設定或VERSION，下一步為Milestone 19-2 Secure Credential Store Adapter。
- Milestone 19-2 implementation review已通過；workspace analyze、465項完整tests與release APK build全數通過。Release manifest實際minSdk 24、targetSdk 36、backup disabled，且沒有Biometric / Fingerprint permission；default SharedPreferences authority未切換，VERSION維持1.2.0，下一步為Milestone 19-3 SharedPreferences Legacy Migration。
- Milestone 19-3 implementation review已通過；Auth migration targeted 39項、App adapter / DI targeted 3項、workspace analyze、506項完整tests與App bundle build全數通過。Repository與Refresher仍使用default SharedPreferences authority，VERSION維持1.2.0，下一步為Milestone 19-4 Auth Lifecycle Integration。
- Milestone 19-4 implementation review gate已通過；workspace五個packages共536項完整tests與analyze全數通過，App bundle build成功。M19-PR01、M19-PR02與M19-PR06正式關閉；M19-PR05保留至19-5 Android runtime evidence。VERSION維持1.2.0，下一步為Milestone 19-5 Security Review、Android Smoke與封存。

---

## [1.2.0] - 2026-07-20

### Added

- 新增tracked Android runner與Flutter `.metadata`，固定template application ID / namespace、Java 17、AndroidX、Internet permission、V2 embedding與Android artifact build baseline。
- 新增App-owned Auth navigation coordinator、Android scaffold contract與mounted AppRouter regression。

### Changed

- Auth lifecycle採latest-intent ordering；Auth persistence收斂為single-active-user；Catalog SQLite正式啟用foreign-key enforcement。
- Shell、Auth與Profile跨Feature navigation ownership提升至App composition layer。
- README新增platform capability matrix；Android標記Supported，iOS、Web、Windows、macOS與Linux標記Dependency-ready。
- Decision 014補充Web evidence terminology；Backlog整理為future、deferred與explicitly not planned scope。

### Fixed

- 關閉Milestone 18全部9項findings：`M18-A01`、`M18-A02`、`M18-R01`、`M18-P01`、`M18-P02`、`M18-C01`、`M18-D01`、`M18-D02`與`M18-D03`。
- Android 35 emulator完成release APK runtime smoke；SharedPreferences、SQLite、Mock Login、Catalog、Protected Route、Theme / Locale、restart restore與Logout均通過。

### Verification

- Workspace analyze全部通過。
- Workspace tests共410項全部通過。
- Android release APK建立成功，約55.9 MB。
- Android runtime smoke通過。

---

### Milestone 15–18 detailed changes

### Added

- 完成Milestone 18-7D App / Feature boundary remediation實作：新增App-owned `AuthNavigationCoordinator`與Decision 021，由`ArchitectureApp`先訂閱Auth state再觸發restore；Shell不再直接依賴或dispatch AuthBloc。
- Login與Profile Presentation不再import `ShellTab`或直接設定tab index；App composition layer將unauthenticated → authenticated映射到Profile，authenticated → unauthenticated映射到Login，相同authentication state不重複導航。新增4項targeted tests，architecture import scan、workspace analyze、406 tests與App bundle通過，`M18-A01/A02`尚待18-7D review。
- 完成Milestone 18-7C review修訂並關閉`M18-P02`：v5 upgrade regression同時驗證合法parent-child保留、existing orphan清除、upgrade後cascade與新orphan rejection，並維持`foreign_key_check`為空；DI evidence收斂為Composition Root提供的Database已啟用foreign keys。Workspace analyze與402 tests全數通過，下一步為18-7D App / Feature boundary remediation。
- 完成Milestone 18-7C Catalog foreign-key enforcement實作：App-owned SQLite connection新增`onConfigure`並啟用`PRAGMA foreign_keys = ON`，schema升至version 6；upgrade會清除existing Catalog orphan item rows。
- 新增fresh / upgrade production-style connection regression，驗證pragma=1、parent delete cascade、orphan insert rejection、existing orphan cleanup與`foreign_key_check`；Mock / Real DI graph亦驗證實際Database connection。Workspace五個package analyze與402 tests全數通過，18-7C尚待review。
- 完成Milestone 18-7B Auth single-active-user persistence實作：SQLite schema升至version 5，`auth_user`改為固定`slot = 1`的single-record contract；v4單列upgrade保留資料，multi-row因無法證明identity而安全清除。
- 完成Milestone 18-7B review修訂：Refresh在呼叫remote前驗證stored token `userId`與runtime Session一致，legacy / mismatch token會直接清除Auth state且不送出refresh request；正常fixtures全面補齊identity。
- 新增Sequential Login A → B → restart只restore B、v4 multi-row + existing token upgrade後restore cleanup，以及schema非法slot / second active row rejection regression。Workspace五個package analyze與400 tests全數通過，`M18-P01`正式Resolved，下一步為18-7C Catalog foreign-key enforcement。
- 完成Milestone 18-7A正式review revision並關閉`M18-R01`：補齊Double Login、Login + Logout、Restore + Login UI ordering與external Session clear的Bloc-level regression；外部權威Session clear現在會invalidate舊lifecycle operation。
- Logout cleanup語意正式收斂：進入exclusive cleanup前可被取代，一旦開始會完整執行user與token cleanup，但只有current Logout可清runtime Session；新增與較新Login交錯regression。Workspace五個package analyze與389 tests全數通過，下一步為18-7B Auth single-active-user persistence。
- 完成Milestone 18-7A Auth lifecycle latest-intent ordering實作：`AuthStateMutationCoordinator`新增generation lease，restore / login / logout開始時取得operation；較新意圖會使舊operation在persistence與Session commit前失效，`AuthLifecycleOperationSuperseded`維持control flow，AuthBloc不將其轉為Failure或覆蓋較新UI。
- 新增Double Login反向完成與Login + Logout反向完成regression，驗證舊Login不會覆蓋最新tokens、user或runtime Session；workspace五個package analyze與384 tests全數通過。18-7A尚待review。
- 完成Milestone 18 Audit Review Gate：9項findings均完成disposition，無Accepted risk。核准Auth lifecycle ordering、single-active-user persistence、Catalog foreign-key、跨Feature boundary、Android scaffold與README定位修正；Web terminology與Backlog整理延後至18-8。
- 平台scope採最小可交付策略：Android為唯一Supported target候選，iOS、Web、Windows、macOS與Linux維持Dependency-ready。現在不發布baseline，VERSION維持1.1.0，`1.2.0`只保留為provisional candidate；下一步進入18-7A Auth lifecycle latest-intent ordering。
- 完成Milestone 18-6正式review revision：`M18-C01`與`M18-D01`必須共用同一platform disposition，README Quick Start / `flutter run`需依最終平台決策同步；`M18-D02`改以current authoritative文件與ADR clarification為主，不全面重寫歷史紀錄，`M18-D02/D03`主要target phase收斂為18-8。
- 新baseline release條件改為全部tracked workspace regression與新增targeted tests通過，本次audit既有382 tests不得無理由遺失；`1.2.0`維持provisional candidate而非承諾版本。18-6正式Reviewed / Closed，下一步進入Audit Review Gate。
- 完成Milestone 18-6 Documentation & Provisional Baseline Assessment：確認VERSION、README與CHANGELOG current baseline一致為1.1.0，但1.1.0只封存至Milestone 14，Milestone 15至17仍屬Unreleased；Phase A不修改VERSION。
- 新增`M18-D01`（P1）README企業模板定位與無可執行platform project落差、`M18-D02`（P2）早期Web scaffold / runtime evidence terminology不精確、`M18-D03`（P3）Backlog混列completed與future scope。Provisional decision為現在不發布；若Gate與approved remediation完成且沒有breaking scope，傾向1.2.0 MINOR，下一步為18-6 review。
- 完成Milestone 18-5正式review revision：將Complete限定為declared component contract，明確區分Dio / SQLite / Widget host integration與application integration，並精確拆分`M18-A01` Shell startup ownership及`M18-A02` navigation transition coverage。
- Bootstrap orchestration與Catalog offline full journey改列為尚無observed production defect的application matrix gaps；平台artifact / runtime tests依Audit Review Gate正式承諾的平台集合展開。18-5正式Reviewed / Closed，未新增test-only finding，下一步為18-6 Documentation & Provisional Baseline Assessment。
- 完成Milestone 18-5 Test Capability Matrix盤點：彙總53個tracked test files，Windows host完整執行5個workspace packages共382 tests全數通過，並將能力映射至unit、repository、SQLite、Bloc、Widget、Golden、integration與platform build evidence。
- Refresh / Replay、Catalog concurrency / persistence、Failure reporting與Design System component contract具強coverage；跨feature navigation、Auth ordering / persisted identity、foreign key connection與platform application journey缺口均由既有findings承載，未新增test-only finding。CI/CD依Milestone 11維持Deferred，下一步為18-5 review。
- 完成Milestone 18-4正式review revision：明確區分component evidence、application artifact evidence與application runtime evidence；Windows FFI tests及`flutter build bundle`不得被視為platform App支援。
- `M18-C01`維持P1；Audit Review Gate必須逐平台拍板Supported target、Verification pending target、維持Dependency-ready或Not supported。單純執行`flutter create`最多只到Scaffold only，每個承諾平台仍需獨立release artifact、native configuration與runtime smoke；18-4正式Reviewed / Closed，下一步為18-5 Test Capability Matrix。
- 完成Milestone 18-4 Platform Capability & Build Audit：盤點Android、iOS、Web、Windows、macOS與Linux的tracked scaffold、dependencies、static compatibility、host build及runtime evidence；六平台目前均分類為Dependency-ready。
- 新增正式finding`M18-C01`（P1）：App沒有任何完整Flutter platform runner，Web只保存SQLite assets；Windows host的bundle compilation成功，但Web與Windows artifact build因project未配置而失敗。Phase A不執行`flutter create`，等待18-4 review與Audit Review Gate拍板正式平台承諾。
- 完成Milestone 18-3正式review revision：`M18-P01`維持P1，補強既有multi-row auth資料、restore identity validation與排除僅加`ORDER BY`的無效修正；`M18-P02`維持P2，補強啟用foreign key後的existing orphan cleanup / rejection、fresh install與upgrade connection verification。
- 18-3正式標記Reviewed / Closed；fresh schema snapshot需驗證tables、columns、indexes、schema version、foreign key pragma與single-active-user contract，後續納入18-5 test matrix。下一步進入18-4 Platform Capability & Build Audit。
- 完成Milestone 18-3 Persistence & Database Audit：盤點SharedPreferences keys、SQLite schema version 4、v1 / v2 / v3 migrations、Auth split-store persistence、Catalog transaction / chain revision / corruption recovery與platform database factory。
- 新增正式finding`M18-P01`（P1）：`auth_user`可保存多個不同user，但restore使用無排序`limit: 1`，不同帳號登入後可能把目前token與舊user配對；新增`M18-P02`（P2）：Catalog DDL宣告foreign key cascade，但production connection未啟用`PRAGMA foreign_keys`。Phase A只落檔，等待18-3 review與Audit Review Gate。
- 完成Milestone 18-2正式review revision：`M18-R01`維持P1並收斂為Auth lifecycle command缺少跨operation latest-intent ordering；confirmed scenarios為Double Login反向完成及Login + Logout反向完成，Restore + Login改列UI ordering coverage gap。
- 補入Theme / Locale runtime preference flow，確認runtime-first、serialized write、latest snapshot、expected / unexpected reporting與reporter failure均有production contract及test evidence；18-2正式Reviewed / Closed，下一步為18-3 Persistence & Database Audit。
- 完成Milestone 18-2 Runtime Critical Flow Audit盤點：建立Bootstrap、Auth restore / login / logout、Concurrent 401 / Refresh / Replay、Profile / Guard、Catalog Search / SWR / Refresh / Append / Cache與Failure ownership矩陣，逐項記錄production path、existing test evidence與coverage gap。
- 新增`docs/audits/milestone_18/18-2_runtime_flows.md`與正式finding`M18-R01`（P1）：AuthBloc restore、login與logout事件使用預設並行處理且缺少operation identity，較舊operation可能覆蓋較新使用者意圖；Phase A只落檔，等待18-2 review與18-6C Gate決定remediation。
- 完成Milestone 18-1正式review revision：修正App非generated Dart source count為85，將source dependency direction與runtime call flow分開描述，並補記`packages/auth`直接使用Dio、SharedPreferences與SQLite屬Decision 020既有accepted infrastructure boundary。
- 18-1 review重查相對路徑cross-feature import、package cycle、package→App依賴與DI framework洩漏，未發現額外P0 / P1 finding；`M18-A01`維持P1、`M18-A02`維持P2，18-1正式Reviewed / Closed。
- 完成Milestone 18-1 Architecture & Dependency Audit：建立repository / package / feature inventory、workspace dependency graph、cross-feature import、DI ownership、package export surface、mapper / abstraction與test evidence盤點；確認App仍是唯一Composition Root、package graph無cycle且packages未綁定DI framework。
- 新增`docs/audits/milestone_18/18-1_architecture_inventory.md`與finding SSOT `findings.md`；正式記錄`M18-A01` ShellPage跨Feature直接依賴AuthBloc（P1）及`M18-A02` Auth / Profile Presentation反向依賴ShellTab（P2），Phase A只落檔，等待Audit Review Gate決定remediation。
- 完成Milestone 18-0 Planning Review封閉：最終review無未處理P0 / P1規劃finding，P2 / P3均已完成disposition；`findings.md`正式成為所有finding的唯一SSOT，各子階段文件只保存inventory、matrix、evidence與Finding ID引用。
- 將18-8收斂為Final Validation, Documentation & Baseline Decision；最終可決定發布新baseline或維持現有版本並記錄理由，只有決定發布時才更新VERSION與建立release封存。Roadmap與Project Context已切換至18-1 Architecture & Dependency Audit。
- 完成Milestone 18規劃第一輪review revision：將完整Milestone收斂為Phase A Audit、Audit Review Gate與Phase B approved work，新增18-0 Planning Review及18-8 Final Validation / Baseline Release；Gate通過前禁止production code修改與版本升級。
- 補強Milestone 18 capability taxonomy與finding disposition：新增Verification pending，平台evidence分為repository、dependency、scaffold、static、host build、runtime與external-host verification；P0必須Resolved，P1需Resolved、capability降級或經Gate記錄Accepted risk。
- 定義`docs/audits/milestone_18/`固定輸出結構，18-1至18-4同步收集test evidence，18-5只彙總test strategy；18-6拆為文件一致性、provisional baseline assessment與正式Audit Review Gate。
- 規劃 Milestone 18 Template Baseline Holistic Audit：以目前 `main` 最終程式碼為準，橫向審查 Architecture與dependency boundary、runtime critical flows、`sqflite` / SQLite persistence、六平台capability、test strategy、文件與Template Baseline版本；audit期間只盤點、驗證與提出findings，未經review與拍板前不修改production code。
- 新增 `docs/audits/milestone_18_holistic_audit.md`，定義Supported / Scaffold only / Dependency-ready / Not supported capability taxonomy、P0至P3 severity、finding格式與18-1至18-7正式子階段；不預設改用Drift，也不將`flutter build bundle`視為Android `appbundle`驗證。
- 完成 Milestone 17-7 Sensitive Data Audit、Regression與完整驗證：關閉Refresh request、Login / Refresh response、AuthResult與AuthEvent.loginRequested的Freezed欄位型`toString()`，避免account、password、access token與refresh token進入一般log；新增secret sentinel tests。Workspace五個package analyze與382項完整tests、App / api_client / auth generation及development / staging / production bundle builds全部通過，Milestone 17正式完成。
- 補強Milestone 17最終review revision：關閉`AuthEvent.loginRequested`的Freezed欄位型`toString()`，避免account與password進入Bloc tooling、debug log或測試輸出；新增App secret sentinel regression，並將credential-bearing Freezed model預設禁用欄位型`toString()`寫入Decision 020。
- 完成 Milestone 17-6C Serialized Write Queue與Non-fatal Reporting：Theme / Locale expected write failure以degraded上報並允許latest snapshot續寫，unknown error以unexpected上報且不再被吞掉；Catalog Cache fallback透過feature-local sink與App adapter送入ErrorReporter；Composition Root註冊Debug reporter，未加入Firebase。
- 完成 Milestone 17-6D BlocObserver：新增App-owned `AppBlocObserver`，未處理Bloc錯誤以unexpected與固定safe context送入ErrorReporter；bootstrap在任何App Bloc建立前安裝全域observer，Reporter失敗不改變原有Bloc error flow。
- 完成 Milestone 17-6E Flutter / Platform uncaught hooks：新增App-owned uncaught handler與global installer，Flutter framework error以unexpected / flutterFramework context上報，root isolate async error以fatal / platform context上報；保留既有handler語意、隔離Reporter失敗，Flutter缺少stack時使用`StackTrace.empty`，duplicate policy留待17-6F。
- 完成 Milestone 17-6F Composition Root、Bootstrap Error與Duplicate Policy：Reporter在DI前建立並以同一instance注入GetIt，bootstrap初始化失敗以fatal與原stack上報後重拋；Bloc／bootstrap到Platform的duplicate採同event-loop turn的error object identity＋stack object identity消費，cleanup使用generation ownership，不使用字串或時間毫秒窗。Milestone 17-6不加入Firebase／Crashlytics dependency。
- 補強17-6F正式review revision：duplicate key改為error＋stack object identity並加入generation cleanup ownership；Widgets binding、global hooks與BlocObserver安裝納入最外層bootstrap guard，真實hook install failure也會以fatal bootstrap context上報。
- 補強17-6E正式review revision：Flutter framework severity改為unexpected、null stack改用`StackTrace.empty`；global hooks禁止重複install，dispose採wrapper identity保護，不覆蓋較新的外部handler。
- 補強17-6C正式review revision：reporting dependency改為顯式required，Preference restore與Catalog reporter failure採best-effort隔離；Catalog operation由Feature直接typed傳遞，不再從cause猜測或默認write。Targeted 81 tests、App analyze與diff check通過。
- 完成Milestone 17-6B正式review revision：Preference restore驗證kind / operation identity，wrong kind與write failure不再降級；新增typed diagnostic保存error與catch stack trace，Storage exception以read / write named constructors封閉。
- 完成 Milestone 17-6B Theme / Locale Preference Error Boundary：新增typed corruption / storage exception，移除codec與store的broad Object catch；invalid persisted payload與expected SharedPreferences failure可fallback，unknown error原樣拋出。
- 完成 Milestone 17-6A正式review revision：封閉`ErrorReportContext`、將operation改為`ErrorReportOperation` enum，並讓Debug adapter固定格式化safe欄位，避免任意字串或context `toString()`洩漏敏感內容。
- 完成 Milestone 17-6A Error Reporting Contract：新增App-owned `ErrorReporter`、immutable `ErrorReport`、severity與typed safe context；Debug adapter不展開error / stack內容且不向外拋出，Recording adapter由test提供。
- 完成 Milestone 17-5正式review revision：補齊cursor-chain persisted corruption parsing與repair；第一頁revision損壞可重建，linked revision / Append traversal損壞會清除相同query / limit chain並安全拒絕寫入；新增四組regression。
- 完成 Milestone 17-5E完整Regression：Catalog targeted 107 tests、workspace五個package analyze與五個package / app完整333 tests全部通過；cursor chain、chain revision、SWR、Refresh、Append、revalidation、UI與Logout persistence無回歸，Milestone 17-5正式完成。
- 完成 Milestone 17-5D Reporting-ready Diagnostic Preparation：新增安全的 Catalog Cache operation details，涵蓋read/write/append/chain revision/delete/corruption與expired cleanup；不保存query、cursor token、item、SQL或raw row，實際Reporter wiring留待17-6。
- 完成 Milestone 17-5C Protocol / Invariant Contract：Remote malformed item與non-advancing cursor改用 typed protocol diagnostic並保存stack trace；Bloc cursor cycle改為 `FailureKind.protocol`；Local API misuse維持programming error channel。
- 完成 Milestone 17-5B Repository Cache Fallback Boundary：Catalog Cache read、linked chain revision與write只吸收 typed localStorage failure；protocol、dataCorruption與unknown error不再被降級或被Remote success掩蓋，Remote failure mapping與Cache side-effect正式分離。
- 完成 Milestone 17-5A Catalog Local Error Boundary：SQLite `DatabaseException` 映射為 typed localStorage；persisted row corruption採狹窄repair path；unknown TypeError / programming error不再降級；Local API misuse改為 ArgumentError / StateError fail fast。
- 完成 Milestone 17-4正式review revision：Logout多重cleanup failure改為unexpected / non-localStorage error優先於expected localStorage failure，仍保證所有cleanup與runtime Session清除；新增unknown與protocol雙重失敗regression。
- 完成 Milestone 17-4D 與整體 Auth lifecycle regression：AuthRepository Restore / Logout 只消化 typed local storage failure，unexpected typed identity原樣拋出；Logout cleanup失敗仍完成其餘cleanup並清runtime Session。Workspace analyze與五個 package / app完整 tests全數通過，Milestone 17-4正式完成。
- 完成 Milestone 17-4C Interceptor Error Preservation：expected refresh lifecycle result仍保留原始 401；unexpected refresher / replay error改以 `DioExceptionType.unknown` 保留原始 error與 stack trace，不再退回第一次 401。
- 完成 Milestone 17-4B Remote Refresh Classification：Auth Refresh 改用 typed Dio mapper，401 / 403 映射 invalid credential；400 / 408 / 429 / 5xx與 timeout / connection / certificate failure保留 Session並回傳 temporary unavailable；malformed response標記 protocol diagnostic，TypeError不再降級。
- 完成 Milestone 17-4A Auth Local State Boundary：`localStateFailure` 只由 typed local storage exception產生；read storage failure保留 Session，save storage failure清除 Session，unknown read / save error原樣拋出且不登出。
- 完成 Milestone 17-3 Typed AppException / Transport Boundary：新增 `AppExceptionKind`、`TransportExceptionKind`、`FailureKind`，分離 HTTP status、backend code、diagnostic code並保存 stack trace。
- api_client 現在將 Dio type 映射為 Core-owned transport identity、只保存 URI path不保存 query；AppException / Failure 的 `toString()` 不再展開 cause，Auth / Profile / Catalog HTTP localization policy 改讀 typed `httpStatus`。
- 完成 Milestone 17-2 Typed Result Failure Channel：`FailureResult<T>` 與 `Result.when` failure callback 已收斂為 typed `Failure`，Auth / Profile Bloc 移除 `Object → Failure` / `error.toString()` fallback。
- 新增 Core typed failure channel 與 Auth / Profile unknown error regression；Catalog Bloc 移除已不可能成立的 runtime Failure type checks，Workspace analyze 與五個 package / app 完整 tests 全部通過。
- 完成 Milestone 17-1 Exception / Failure 現況 Audit 與 Architecture Contract；新增 Architecture Decision 020，正式區分 expected operational failure、unexpected error、cancellation、external protocol violation、internal invariant 與 session lifecycle result。
- Milestone 17 規劃將 `FailureResult.error: Object` 收斂為 typed Failure channel，並於後續建立最小 AppException / Failure taxonomy；Feature Presentation 繼續負責 localized user-facing copy。
- 完成 Milestone 17-2 實作前 review：17-2 只封閉 `Result` failure channel 與移除 Bloc 的 `Object → Failure` fallback；Failure taxonomy 延後至 17-3，與 typed AppException identity 一起設計。
- Audit 確認 Auth / Profile Bloc 的 `error.toString()` fallback、Refresh subsystem 的廣泛 `catch (_)`、缺少 uncaught reporting entrypoint與 `toString()` 展開 cause 是主要風險；本階段只落檔，不修改 production code。
- Audit 同時記錄一般 transport mapper 位於 `packages/api_client`，但 Auth Refresh data source 目前直接依賴 Dio 做 status 分類；此 boundary 留待 Milestone 17-3 / 17-4 收斂。
- 第三輪完整 review 補入 Theme / Locale preference error boundary：Codec、Store 與 serialized write queue 的廣泛 `Object` catch 需區分 recoverable corruption、expected persistence failure 與 unexpected programming error。
- Review 同時確認既有 Auth Refresh tests 正在鎖定 unknown error 降級行為；Milestone 17-4 需明確更新舊 expectation，不能只在現有 contract 上追加測試。
- 拍板 App 作為唯一 ErrorReporter / Crashlytics-compatible adapter Composition Root；不建立 Global Error Handler、Generic Exception Mapper、每個 HTTP status class或全域 backend code enum。
- 拍板 retryability、session clearing、Catalog Cache / Theme / Locale degraded-mode reporting與 sensitive diagnostic context contract；password、token、Authorization、raw body與 raw storage payload不得進 exception、failure、cause、log或 `toString()`。
- 完成 Milestone 16-7：production text、Tooltip、Semantics、Dialog、Navigation、page-state surface、failure path 與 dependency boundary audit；README、Catalog feature 文件、Project Context、Architecture Decision、Roadmap 與 Backlog 已同步。
- Localization regression 採 Theme render matrix、English / `zh_TW` runtime switching、feature-local mapping 與既有 Auth / Profile / Catalog business flow 的分層驗證，避免建立完整 Theme × Locale 笛卡兒積。
- 修正 Design System localization boundary：`DsButtonContent` 不再拼接固定英文 `in progress` semantics；未提供專用 progress label 時重用呼叫方已 localized 的 label。
- 完成 Milestone 16-6：Catalog Search、Loading、Empty、Initial / Append / Refresh failure、Cache、Stale、Revalidation、actions 與 Semantics 已加入 English / `zh_TW` ARB。
- Catalog Presentation 新增 surface-specific failure localization；`408 / 429` 映射 timeout / rate-limit copy，其他 code 使用 initial / refresh / append / revalidation fallback，diagnostic `Failure.message` 不直接顯示。
- App 新增直接 `intl` dependency；Catalog `lastUpdatedAt` 在 Presentation 轉為 local time 後依目前 locale 的日期與時間慣例格式化，Data / Domain / Cache UTC 與 Pagination / SWR / Offline Cache contract 不變。
- Milestone 16-6 review 修正 time formatter：改用 locale-sensitive time skeleton，不再以 `Hm` 強制所有語系使用 24 小時制。
- 完成 Milestone 16-5：Login、Profile、Logout 與 Protected user-facing text 已加入 English / `zh_TW` ARB，Profile current user 使用 generated placeholder。
- Auth / Profile state 改為保存 `Failure + operation`，Presentation 使用 feature-local localized mapping；目前只有 `401` 進行帳密錯誤或 Session 失效的特定映射，`403` 與其他 code 使用操作專屬 generic fallback。
- 修正 `Failure.message`、AppException mapper 與 Repository fallback contract，使 diagnostic message 不再被視為可直接顯示的 localized UI copy；未擴張為全域 error taxonomy 或 generic mapper。
- 完成 Milestone 16-4：Shell title、Navigation labels、Language / Appearance / Protected tooltips、Appearance dialog 與 Theme mode labels 已移入 App ARB。
- 內建 Default / Ocean Theme 由 App 依 stable Theme ID 映射 localized display name；未知 Theme 使用 Design System metadata fallback display name，Theme persistence identity 不變。
- 新增 English / `zh_TW` Shell runtime switching、Appearance localized labels 與 unknown Theme fallback tests；App 完整 183 tests、analyze 與 bundle build 通過。
- 完成 Milestone 16-3：新增 App-local Locale preference、Version 1 JSON persistence、runtime-first `LocaleController`、serialized write queue、bootstrap restore、`MaterialApp.locale` wiring 與語言 selector。
- Locale preference storage key 為 `app.locale.preference`；System 維持 `locale = null`，English / `zh_TW` 使用 explicit Locale，且不保存 resolved system locale。
- Locale read / write failure 採 non-blocking policy；寫入失敗不回滾 runtime，也不阻止後續較新 preference 保存。
- 語言 selector 支援 System、English、繁體中文，dialog labels 與 Shell tooltip 會隨 runtime locale 即時更新。
- 完成 Milestone 16-2：加入 Flutter 官方 `gen_l10n`、English / `zh_TW` ARB、generator base `zh` fallback、App delegates、`en / zh_TW` supported locales、明確 locale list resolution 與 localized `onGenerateTitle`。
- 新增 locale resolution tests，驗證 `zh_TW` / `zh_Hant` / `zh_HK` / `zh_MO` 對應繁中，`zh_CN` / `zh_SG` / `zh_Hans` 與 unsupported locale fallback 至英文；Workspace analyze 與 App 完整 167 tests 通過。
- 規劃 Milestone 16 Localization Foundation，採用 Flutter 官方 `gen_l10n`，第一版支援 English 與繁體中文 `zh_TW`。
- 新增 Architecture Decision 019，定義 App、Feature Presentation、Design System、Domain、Data、Repository、Theme metadata、locale preference、formatting 與 user-facing failure mapping 的責任邊界。
- Locale preference 支援 `system / en / zh_TW`；`system` 使用 `MaterialApp.locale = null` 搭配 `localeListResolutionCallback`，explicit preference 才提供具體 Locale。
- 明確限制 Milestone 16 不全面重構 Failure / Exception hierarchy；只針對目前實際顯示到 UI 的 Login、Logout、Profile 與 Catalog failure path 建立 feature-local localized mapping。
- Catalog Bloc 已保留 `Failure`；Auth / Profile Bloc 後續只做最小 state contract 調整，以保留 stable failure identity，不擴張為全域 error framework。
- System locale resolution 採 `zh_TW` / `zh_Hant` / `zh_HK` / `zh_MO` → `zh_TW`；`zh_CN` / `zh_SG` / `zh_Hans` 與其他 unsupported locale → English。

- 完成 Milestone 15-10：清查 production UI hard-coded style、移除未有穩定 consumer 的 Design System tokens、加入單一 stable gallery golden fixture，同步主要文件並完成完整 regression 與 development / staging / production bundle 驗證。
- 完成 Milestone 15-8：ProtectedPage 導入 `DsMessageState`；ProfilePage 導入 unauthenticated／loading／blocking error／content surfaces；LoginPage 導入 constrained scrollable form、Theme InputDecoration 與 `DsButtonContent`，並補上窄畫面、鍵盤、2.0 text scaling、Dark mode 與 Ocean Theme widget tests。
- 完成 Milestone 15-9：Catalog 導入 initial loading／empty／blocking error page-state surfaces，append、refresh、cache、stale 與 revalidation 保持 feature-local non-blocking presentation；Shell chrome 抽為可測 `ShellScaffold`。
- Milestone 15-9 review 修正：Catalog empty surface 改為單一 scroll owner，補上 pull-to-refresh、窄畫面大型文字、四組 Theme render matrix，並鎖定 Shell selected destination mapping。
- 移除 Catalog empty state 固定高度 spacer，改為依 viewport 配置的可捲動 empty surface；保留 Pagination、SWR、Refresh、Append、cursor chain、cache metadata、AutoTabsRouter 與 Appearance／Protected routing contract。

- 規劃 Milestone 15 Design System Foundation，正式採用 `packages/design_system` 作為不依賴 App、Feature、DI framework 或 persistence implementation 的純 Flutter UI package。
- 新增 Architecture Decision 018，明確區分 Theme Identity 與 Theme Mode；每一套 Theme 必須提供 Light / Dark variants，System mode 只決定目前 variant，不改變 Theme Identity。
- Milestone 15 第一版將提供 Default Theme 與第二套示範 Theme，用來驗證多主題 registry、semantic token、Light / Dark 交叉組合與 persistence contract。
- Theme preference 將分別保存 `themeId` 與 `mode`；App 負責 restore、controller lifecycle、persistence 與 `MaterialApp.themeMode` wiring，Design System package 不直接依賴 SharedPreferences。
- Theme preference 已拍板使用單一 versioned JSON `app.theme.preference`；損壞或未知 version 整體 fallback，未知 themeId / mode 採欄位級 fallback。
- Theme 切換採 runtime-first、persistence-second；寫入失敗不回滾目前 Theme，只回報 non-blocking persistence failure。
- Theme preference persistence 採完整 snapshot 的單一序列化 write queue，保證快速連續切換時 latest preference wins，且較舊寫入不得覆蓋較新選擇。
- Theme preference storage read exception 時以 Default Theme + System mode 繼續啟動，保留 non-blocking diagnostic，不阻止 `runApp`，也不自動寫回 fallback。
- Appearance selector 定位為 App-level theme presentation，Shell 只提供入口，不承擔 settings workflow。
- 規劃 primitive tokens、semantic colors、Typography、Radius、Elevation、Material component themes、`ThemeExtension`、primitive components、page state surfaces、Accessibility 與 text scaling tests。
- 將 Milestone 15 拆分為 Architecture Contract、Package / Tokens、Default Theme、示範 Theme、Primitive Components、Page State Surfaces、Theme Persistence / Selector、現有頁面導入與 Final Verification。
- 完成 Milestone 15-2 Package Skeleton、Design Tokens 與 Theme Registry。
- 新增 `packages/design_system` workspace package、public entrypoint 與 package README；package 不依賴 App、Feature、DI framework 或 persistence implementation。
- 新增 spacing、radius、elevation、icon size primitive tokens，以及 success、warning、info semantic color role contract。
- 新增穩定 `DsThemeId`、`DsThemeMetadata`、`DsThemeDefinition` 與 `DsThemeRegistry`；Registry 支援 default validation、duplicate rejection 與 unknown ID fallback。
- Raw palette 保持 package internal，Fake Theme definitions 已驗證 Light / Dark ThemeData factory contract；production Default Theme 留在 Milestone 15-3。
- Theme ID 採 lowercase canonical contract，只允許小寫英文字母、數字、底線與連字號；Theme metadata 會拒絕空白 display name。
- 補強 Theme Registry definition / metadata ID mismatch 與 available themes 不可修改的 boundary tests。
- 完成 Milestone 15-3 Default Theme Light / Dark。
- 新增 production `DefaultThemeDefinition`，提供 Material 3 Light / Dark `ThemeData`、Typography hierarchy、surface hierarchy 與核心 Material component themes。
- 新增 `DsSemanticColors` ThemeExtension，提供 success、warning、info foreground / container semantic roles，並完成 `copyWith` / `lerp` contract tests。
- 補強 Default Theme contract tests，鎖定 Typography exact hierarchy、Material component theme 精確值、touch target、radius、elevation 與 semantic foreground / container contrast。
- 完成 Milestone 15-4 第二套示範 Theme Light / Dark。
- 新增 production `OceanThemeDefinition`，提供獨立 Light / Dark ColorScheme、semantic colors、Typography weight 與 radius 差異。
- 抽取 package-internal `DsMaterialThemeFactory`，只共用 Default / Ocean 已證明重複的 Material Theme 組裝，不建立 generic skin engine。
- 新增 Registry 四組 ThemeData、Ocean semantic contrast 與非單純 seed replacement contract tests。
- 補強 Ocean Theme tests：同 brightness 比較 Default / Ocean semantic identity、驗證六組 semantic contrast，並鎖定 Registry 回傳正確 definition 與四組 ThemeData identity。
- 完成 Milestone 15-5 Primitive Components。
- 新增 `DsStatusBanner`，提供 neutral、info、success、warning、error semantic tone、optional action 與 Semantics。
- 新增 `DsConstrainedContent`，統一內容 max width、置中與 page padding。
- 新增 `DsButtonContent`，供 Material Button variants 使用 idle / loading presentation，不建立 generic button。
- 新增兩套 Theme × Light / Dark、action callback、disabled/loading、長文字與窄 viewport widget tests；沒有穩定第二 consumer 的 compact progress / search abstraction 不予建立。
- 完成 Milestone 15-7 Theme Preference、Persistence 與 Selector UI。
- 新增 App-local `ThemePreference`、`AppThemeMode`、Version 1 JSON codec 與 `app.theme.preference` SharedPreferences storage。
- 新增 runtime-first `ThemeController` 與 serialized complete-snapshot write queue；寫入失敗不回滾 runtime，且不阻止後續較新 preference。
- Bootstrap 在 `runApp` 前 restore preference；storage read exception 使用 Default + System 啟動、保留 diagnostic 且不自動寫回。
- `MaterialApp.router` 已接上選中 Theme identity 的 Light / Dark ThemeData 與 ThemeMode；Shell 新增 Appearance selector 入口。
- 完成 Milestone 15-6 Page State Surfaces。
- Milestone 15-8 review 修正：Profile 在既存內容下的登出 loading / failure 改為 non-blocking presentation，並補上 Login / Profile callback wiring tests。
- 新增 `DsLoadingState`、`DsEmptyState`、`DsBlockingErrorState`、`DsMessageState` 與 typed `DsPageStateAction`。
- Page-state surfaces 支援 Widget icon slot、primary / secondary actions、viewport-aware scrolling 與 Wrap action layout，不使用固定高度 empty-state hack。
- 新增 Default / Ocean × Light / Dark、Loading / Error / Retry Semantics、custom icon slot，以及 text scale 1.0 / 1.3 / 2.0 的 320px widget tests。

---

## [1.1.0] - 2026-07-17

### Added

- 規劃 Milestone 14 Offline Cache，正式採用 Catalog feature-level、明確 opt-in 的 Cache-first + Stale-While-Revalidate。
- 新增 Architecture Decision 017，拍板 freshness / retention、query + cursor + limit cache identity、cursor page storage、所有 Remote 第一頁成功時的 chain invalidation、Remote + Local coordination 與 UI metadata。
- Catalog Cache 不使用 generic HTTP interceptor，不自動快取 Login、Refresh Token、交易、付款或其他 command API。
- Initial / Query Switching 使用 Fresh Cache 或 Stale Cache + background revalidation；Pull-to-refresh 強制 Remote，Append 第一版使用單次 cursor page cache，不做背景 revalidation。
- SQLite Cache 採 page metadata + ordered page items，DTO、Local Entity 與 Domain Entity 維持分離。
- Domain snapshot 將表達 page source、freshness 與 `lastUpdatedAt`；Bloc state 表達 `isUsingCachedData`、`isStale`、`isRevalidating` 與 revalidation failure，不以單次 transport failure 推測全域 Offline。
- 明確定義 Initial SWR 的 Repository Stream emissions、預期 failure 使用 `Result`、未知程式錯誤才走 Stream error channel。
- 明確定義 `CatalogLoadPolicy.initial / refresh / append` contract、合法 cursor 組合，以及三種 policy 各自的 Stream emission 語意。
- 畫面級 freshness metadata 只代表第一頁 snapshot；Append page freshness 不提升為整體清單最後更新時間。
- Cache read / write failure 維持非阻斷 local diagnostic，不加入一般 Catalog UI contract；expired cleanup 採讀取指定 page 時的 page-level lazy cleanup。
- 將 Milestone 14 拆分為 Architecture Contract、SQLite / Migration、Repository Coordination、Initial SWR、Refresh / Append、UI / DI 與 Final Verification 七個階段。
- 明確定義 public Catalog Cache 不因 Logout 清除，App 仍是唯一 Composition Root，且不建立 Generic Cache / Generic Pagination framework。
- 完成 Milestone 14-2 SQLite Schema、Migration 與 Local Models。
- App database version 最終升級為 3：v1 → v2 建立 Catalog Cache tables，v2 → v3 將 item position index 升級為 unique，並保留既有 `auth_user`。
- 新增 `catalog_cache_page`、`catalog_cache_page_item` 與 page item order index；Local item row 保存 id、name、description 與 position。
- 新增 Catalog Local Entity、Local Mapper 與 `CatalogLocalDataSource`，支援 page read、transaction replacement、第一頁 chain reset、cursor sentinel 與 expired page lazy cleanup。
- 新增 16 項 in-memory SQLite tests，涵蓋完整欄位與順序 round-trip、identity isolation、cursor sentinel 防護、empty page、replacement、chain reset、expiration、delete isolation、corrupted cache recovery、failure mapping、transaction rollback 與 migration。
- 依 Milestone 14-2 implementation review 補強 Local Entity validation、position unique constraint 與損壞 page 自我清除。
- 完成 Milestone 14-3 Repository Cache Coordination。
- 新增 `CatalogCachePolicy`、可注入 `CatalogClock`、`CatalogPageSnapshot`、source / freshness metadata 與 `CatalogLoadPolicy`。
- 新增 `CatalogStreamingRepository.watchCatalog()` 與 `SearchCatalogUseCase.watch()`，支援 Initial SWR 多次 emission、Refresh Remote-only 與 Append 單次 Cache/Remote fallback。
- Cache read / write failure 維持非阻斷，Remote cursor 驗證通過後才寫入 Cache，未知程式錯誤保留 Stream error channel。
- App Composition Root 明確註冊 Catalog LocalDataSource、CachePolicy、Clock 與 Repository；舊單次 API 暫時保留至 Milestone 14-4 Bloc 遷移。
- 新增 10 項 Repository Cache tests，涵蓋 fresh/stale/expired、三種 policy、Local failure、cursor validation 與未知錯誤。
- 依 Milestone 14-3 implementation review，將 Catalog Repository 的 Remote、Local、CachePolicy 與 Clock dependencies 全部改為 required，避免 silent misconfiguration。
- 補強 policy / cursor validation，Append 的空字串與空白 cursor 現在會在 Cache read 或 Remote request 前 fail fast。
- 未來 `updatedAt` 不再被判定為 Fresh-only，而是視為 Stale 並執行 revalidation；Repository Cache tests 增至 16 項，補齊 freshFor / retainFor 精確邊界與 read/write failure 分離。
- 完成 Milestone 14-4 Initial Search、Query Switching 與 SWR Bloc Flow。
- CatalogBloc 改為直接消費 `CatalogRepository.watchCatalog()` Stream，支援 Cache → Remote 多次 emission，並移除舊單次 Repository / UseCase contract。
- CatalogState 新增 cached/stale/lastUpdatedAt/revalidating/revalidationFailure metadata；Stale Cache revalidation failure 會保留現有資料並以 non-blocking failure 表達。
- Query switching 會取消舊 SWR subscription，並保留 generation、query identity 與 stale-response guard；Refresh / Append 暫以單次 Stream emission 維持既有 workflow。
- CatalogBloc tests 增至 21 項，新增 Cache → Remote、revalidation failure、query switch cancellation 與 Stream error cleanup coverage。
- 依 Milestone 14-4 implementation review，第一頁 Initial / Query / Retry / Refresh 現在共用可取消的 SWR subscription boundary，不再只靠 generation guard 忽略舊結果。
- Refresh 會取消 stale revalidation，並完整更新 `isUsingCachedData`、`isStale`、`lastUpdatedAt`、`isRevalidating` 與 `revalidationFailure` metadata。
- Stale Cache 後 Stream 若未產生 Remote success / failure 就關閉，現在視為 protocol violation，不再靜默結束 revalidation。
- CatalogBloc tests 增至 24 項，補齊 Initial → Query、Initial retry、Stale → Refresh cancellation 與 stale-only Stream close coverage。
- 完成 Milestone 14-5 Refresh、Append 與 Cursor Chain。
- Refresh 使用目前 query 與 null cursor 強制 Remote；Remote 第一頁成功會 transaction replacement 第一頁，並失效同 query + limit 的舊後續 cursor chain。
- Refresh failure 會保留既有 items、cursor 與 cached / stale / lastUpdatedAt metadata。
- Append 以 requested cursor page identity 讀寫 Cache，支援 retained Cache hit、Cache miss Remote fallback 與 expired page replacement；第一版不做背景 revalidation。
- Append Cache snapshot 只影響 appended items 與 nextCursor，不覆蓋第一頁 freshness metadata；既有 generation、query、requested cursor race protection 維持不變。
- Refresh / Append 現在透過明確 single-result Stream protocol helper 驗證零筆與多筆 emission，違規時會清除 loading 並保留原始錯誤。
- Repository Cache tests 增至 19 項、CatalogBloc tests 增至 28 項，涵蓋第一頁 chain reset、append identity、expired fallback、metadata preservation 與 Stream protocol violation。
- 依 Milestone 14-5 implementation review 補強 cursor chain consistency 與跨操作 cancellation。
- Append Cache write 改為 conditional transaction：只有 requested cursor 仍由目前 chain 指向時才寫入，避免 Refresh chain reset 後較晚完成的舊 Append 重新污染 SQLite。
- CatalogBloc 追蹤已消耗 cursor，阻止多節點 cursor cycle；Local boundary 也拒絕 self-loop Cache page。
- Refresh 採 exhaust transformer 防止重複請求；Initial、Query、Refresh 與 Bloc close 會實際取消執行中的 Refresh / Append Stream。
- 補齊 stale Append late-write、cursor cycle、連續 Refresh、Query → Refresh cancellation、Refresh → Append cancellation 與 Local self-loop tests。
- 完成 Milestone 14-6 UI、DI 與 Offline Cache Flow。
- Catalog UI 新增 cached / stale status banner，顯示 UTC `lastUpdatedAt`、background revalidation indicator 與 non-blocking revalidation failure，且保留現有 items 可操作。
- Fresh Remote data 不顯示 Cache notice；Fresh Cache 與 Stale Cache 使用不同文案與視覺狀態。
- Mock / Real Composition Root tests 現在明確驗證 CatalogApi、LocalDataSource、RemoteDataSource、CachePolicy、Clock、Repository、UseCase 與 Bloc graph。
- Catalog Widget tests 補齊 cached、stale、lastUpdatedAt、revalidation loading、non-blocking failure 與 Fresh Remote 隱藏 notice coverage。
- 完成 Milestone 14-7 Cleanup、Regression、文件與完整驗證，Milestone 14 Offline Cache 全階段完成。
- 依 Milestone 14 最終整體 review 新增 SQLite v4 `chain_revision` migration；Append Remote request 會捕捉 revision 並於 transaction write 時 compare-and-set，防止 Refresh 重用相同 cursor 的 stale late-write。
- Cursor cycle persistence validation 改為 ancestor path + revision，允許 expired predecessor 在 retained successor 尚存在時合法 replacement。
- 新增 Auth / Catalog 共用 SQLite database 的 Logout integration test，確認 Logout 清除 token、user 與 runtime Session，但保留 public Catalog Cache。
- retention-based expired page lazy cleanup、retainFor boundary、migration、Repository、Bloc、Widget、Refresh lifecycle 與 DI scope regression 已完整驗證。
- 同步 README、Architecture Decision 017、Roadmap、Project Context 與 Catalog feature 文件，並完成 development / staging / production bundle builds。
- 依 Milestone 14-6 implementation review 修正 Refresh lifecycle 等待與 empty failure 呈現。
- `requestCatalogRefresh` 在 Refresh 已進行中時會等待目前 lifecycle 結束，不再等待不存在的新一輪 `isRefreshing = true`。
- Empty result 的 Refresh failure 現在與 empty content 同時可見，且保留 pull-to-refresh。
- Revalidation Widget tests 改為正式狀態機中的互斥案例：更新中只顯示 spinner，更新失敗只顯示 non-blocking failure。
- DI graph tests 補上 LocalDataSource / CachePolicy / Clock / Repository singleton identity，以及 UseCase / CatalogBloc factory identity；測試建立的 Bloc 會明確 close。

- 規劃 Milestone 13 Pagination + Search Debounce，正式採用 Catalog feature 與 cursor-based pagination。
- 新增 Architecture Decision 016，拍板 query / cursor / limit contract、300 ms debounce、search generation、stale-response guard、Load More 防重與 logical cancellation。
- Catalog 定義為 public demo endpoint；`nextCursor` 為唯一分頁 source of truth，Repository 負責驗證 cursor chain，不額外引入 `bloc_concurrency`。
- 將 Milestone 13 拆分為 Architecture Contract、API / DTO、Domain / Repository、Initial Search、Load More / Refresh、UI / DI 與 Final Verification 七個階段。
- 明確將 page-based strategy、Generic Pagination framework、Dio CancelToken 跨層傳遞與 Offline Cache 排除於 Milestone 13。
- 完成 Milestone 13-2 Catalog API、DTO、Mock 與 Retrofit Contract。
- 新增 public Retrofit `CatalogApi`、`CatalogItemDto`、`CatalogPageResponseDto` 與 `MockCatalogApi`。
- `MockCatalogApi` 支援 query、opaque cursor、limit、多頁資料與最後一頁 null cursor。
- App API selector 已支援 Mock / Real Catalog implementation，並補上 Retrofit query、public metadata、DTO round-trip 與 selector tests。
- 修正 Mock Catalog cursor identity：cursor 現在綁定 normalized query，避免舊 query cursor 被新 query 接受並回傳錯頁。
- 完成 Milestone 13-3 Catalog Domain、Mapper、RemoteDataSource、Repository 與 Search UseCase。
- 新增 `CatalogItem`、`CatalogPage`、`CatalogRepository`、`SearchCatalogUseCase` 與 Catalog data layer implementation。
- Catalog Mapper 會正規化空 cursor 並驗證必要欄位；Repository 會拒絕無法前進的 cursor chain。
- 補上 Catalog mapper、transport mapping、repository success/failure/cursor validation、unknown error 與 use case parameter tests。
- 修正 Catalog Mapper 不應改寫 opaque cursor 與穩定 Domain ID；trim 僅用於空值驗證。
- 完成 Milestone 13-4 Catalog Initial Search、Debounce 與 Query Switching。
- 修正 Catalog 初始 state 不應被視為 empty result，並加入 page size validation 與測試等待 timeout。
- 新增 `CatalogBloc`、Event、State 與 generated Freezed code；query pipeline 使用預設 300ms、可注入的 debounce + trim distinct。
- 新增 search generation 與 query identity guard，避免舊 query 或同 query 舊 generation response 覆蓋目前 state。
- 補上 initial loading/failure/empty、快速輸入、normalized distinct 與 stale response regression tests。
- 完成 Milestone 13-5 Catalog Load More、Refresh 與 Failure Recovery。
- 修正 Initial、Append、Refresh 遇到未知錯誤時 loading state 可能永久卡住；錯誤仍保留原樣向外傳遞，Append / Refresh 可再次重試。
- Load More 使用 state guard 與 RxDart exhaust transformer，驗證 generation、query 與 requested cursor，避免重複 append 與 stale response。
- Append 依穩定 Domain ID 去重並保留既有順序；failure 保留 items/cursor 並允許 retry，end reached 停止請求。
- Refresh 使用目前 query 與 cursor = null，遞增 generation，成功整批替換、失敗保留資料，並防止舊 Append response 污染 state。
- Catalog Bloc 目標測試增加至 18 項，涵蓋 append 防重、cursor、去重、retry、end reached、refresh success/failure、race protection 與未知錯誤 loading cleanup。
- 完成 Milestone 13-6 Catalog Page、Route、DI 與 UI Flow。
- 新增 Catalog Shell tab、AutoRoute route、搜尋欄位、清單、empty、initial/refresh/append loading 與 failure surfaces、scroll load more 與 pull-to-refresh。
- 完成 Catalog API、RemoteDataSource、Repository、UseCase、Bloc 的 Composition Root registration，並補上 Mock / Real DI graph 與 route tests；完整 Page widget coverage 留在 Milestone 13-7。
- 修正新增 Catalog tab 後登入成功誤導向 Catalog 的回歸，Shell tab index 改由 `ShellTab` 統一定義。
- 修正 pull-to-refresh 快速完成時可能遺失完成 state、導致 RefreshIndicator 永久等待的 stream subscription race。
- 完成 Milestone 13-7 Regression、文件與完整驗證。
- 將 Catalog list body 抽為可獨立測試的 `CatalogView`，補上 initial loading/failure/empty、item、append loading/failure 與 retry widget tests。
- Decision 016、Project Context 與 Roadmap 已同步標記 Milestone 13 完成；下一階段為 Milestone 14 Offline Cache。
- Milestone 13 最終驗證通過 dependency resolution、workspace code generation、analyze、全部 Flutter tests，以及 development / staging / production bundle build。

- 完成 Milestone 12-3 至 12-6：Concurrent 401 Interceptor、Safe Request Replay、Session Expiration UI Flow，以及 concurrency / failure / regression coverage。
- Main Dio 新增 `AuthRefreshInterceptor`；同 Session 的並行 401 共用 auth-side single-flight refresh，refresh 成功後使用最新 access token 安全 replay。
- Authenticated request 保存 generation / userId / failed token identity，禁止舊帳號 request 使用新帳號 token replay，並阻止 logout / relogin 後舊 request 復活。
- Replay 使用 `authRetryCount` 防止無限 retry；Stream、Multipart、upload、progress callback 與特殊 download request 不自動重送。
- Session expiration 透過 `SessionManager` stream 自然同步 AuthBloc、ProfileBloc 與 AuthGuard；interceptor 不直接操作 Router、Bloc 或 LogoutUseCase。
- 新增 10-request concurrent 401、logout/relogin race、invalid refresh cleanup failure、network failure、AuthBloc login/logout regression，以及 Mock / Real Composition Root graph 測試。

- 完成 Milestone 12-2 Refresh API 與 Auth Refresh Flow。
- 新增獨立 `AuthRefreshApi`、`MockAuthRefreshApi`、Refresh DTO、Refresh Dio 與 `AuthRefresher` 五種結果語意。
- 新增 auth-side identity-aware single-flight refresher，支援 refresh token rotation、persistence-first runtime update 與跨 Session race protection。
- 新增 `AuthStateMutationCoordinator`，序列化 Login、Restore、Logout、Refresh commit 與 passive invalidation 的 Auth state 複合修改。
- Passive invalidation 會在 lock 內再次驗證 generation / userId，舊 refresh operation 不得清除新 Session。
- Refresh failure classification 調整為只有 401 / 403 使 Session 失效；400、5xx、timeout 與 malformed success response 保留 Session。
- 新增 refresh concurrency、token rotation、persistence failure、跨帳號 in-flight、Token Pair overwrite race 與 invalidation race 測試。

- 完成 Milestone 12-1 Token Model 與 Persistence：Login / Mock / DTO / Domain 支援 refresh token，新增完整 Token Pair storage、runtime Session snapshot 與 generation。
- 新增 Auth persistence 補償式一致性：Login partial write、Restore incomplete/corrupted state、Logout dual cleanup 與 unknown error cleanup 均保持 runtime/persistence 一致。
- 新增 `StoredAuthTokens`、`AuthTokenStorage`、package-internal `AuthLocalStore` 與 `CorruptedAuthTokensException`。
- 新增 Repository persistence tests，覆蓋 User save failure、corrupted Token Pair、cleanup failure 與 unknown error stack-preserving behavior。
- 新增 Architecture Decision 015，拍板 Refresh Token、concurrent 401、single-flight refresh、request replay、session invalidation 與 Main Dio / Refresh Dio 的責任邊界。
- 將 Milestone 12 拆分為 Token Model、Refresh Flow、Concurrent 401 Interceptor、Safe Replay、Session Expiration、Concurrency Tests 與 Final Verification 七個階段。
- 補充 Decision 015：Refresh endpoint 使用獨立 `AuthRefreshApi` 與 Refresh Dio；Session identity 由 SessionManager generation 管理；Token Pair persistence failure 會清除 runtime Session 並回傳 `localStateFailure`。
- 補充 Decision 015：HTTP request 的 current access token 以 SessionManager runtime state 為唯一來源，並統一 Refresh result 的五種語意。
- 補充 Decision 015：authenticated request 需保存 Session generation / userId，禁止跨 Session 或跨帳號 replay；Token Pair 與 User 跨 storage 採補償式一致性與完整 cleanup policy。
- 完成 Milestone 10 App Configuration 與 Dart Environment Entrypoint。
- 新增 `AppEnvironment`、typed `AppConfig` / `ApiConfig` 與集中式 validation。
- 新增共用 `bootstrap` 與 development / staging / production Dart entrypoints。
- 新增 staging / production 禁止 Mock、production 強制 HTTPS 與 URL scheme validation 測試。
- 新增 Composition Root integration test，驗證 AppConfig、ApiConfig、Dio 與 Mock API graph 的實際註冊結果。
- production URL validation 擴充拒絕 mock.local、localhost、loopback 與 `.invalid` host。
- 規劃 Milestone 10：App Configuration 與 Dart Environment Entrypoint，範圍限定為 typed config、共用 bootstrap、Dart-level entrypoint 與 environment validation。
- 新增 Architecture Decision 014，明確將 Dart entrypoint 定義為 AppEnvironment 唯一來源，並將 Native Flavor 排除於 Milestone 10。
- 固定後續 Roadmap：Milestone 12 Refresh Token + Concurrent 401 Handling、Milestone 13 Pagination + Search Debounce、Milestone 14 Offline Cache。
- 新增 `AGENTS.md`，作為 AI coding agent / assistant 進入專案後的基本工作守則。
- 新增 Architecture Decision 012，明確規範可重用 package 不直接綁定 DI framework。
- 新增 Architecture Decision 013，規範所有真實 HTTP API 統一使用 Retrofit，Mock API 則透過相同 abstraction 提供替代實作。
- 新增 Milestone 9，規劃 Auth / Profile API 的 Retrofit 遷移、DTO / Mapper 邊界、DI 切換與驗證流程。
- 在 `packages/api_client` 加入 `retrofit` 與 `retrofit_generator`，作為後續宣告式 Dio API client code generation 基底。
- 新增 Retrofit `AuthApi`、`MockAuthApi`、`LoginRequestDto` 與 `LoginResponseDto`。
- 新增 Retrofit `ProfileApi`、`MockProfileApi` 與 `ProfileResponseDto`。
- 新增 Login response DTO 到 Auth domain result 的 Mapper。
- 新增 Profile response DTO 到 Profile domain entity 的 Mapper。
- 新增 transport exception mapper，將 DioException 隔離在 `api_client` package 內。
- 新增 App layer `ApiConfig`、`ApiMode` 與 `ApiImplementationSelector`，支援 Mock / Retrofit environment selection。
- 新增共用 `mapAppExceptionToFailure` 與 ProfileRemoteDataSource。
- 新增 Auth Retrofit request test，驗證 POST path、JSON body 與 response DTO parsing。
- 新增 Mock Profile、DTO JSON serialization、Auth / Profile mapper、transport exception 與 Profile Repository regression tests。
- 完成 Retrofit 架構審查，簡化 API abstraction、明確 Mock 目錄、RemoteDataSource 錯誤映射與 Dio 特殊例外規則。

### Changed

- 修正 Roadmap 的 Milestone 13 狀態，正式標記 Milestone 13-1 至 13-7 全部完成。

- `configureDependencies` 改為明確接收已驗證的 `AppConfig`，DI module 不再自行讀取 dart-define。
- `ApiConfig.baseUrl` 改為已驗證的 `Uri baseUri`。
- 將 Milestone 11 CI/CD 標記為 Deferred，目前不實作 GitHub Actions、build matrix 或 deployment pipeline。
- 修正 Roadmap 中 Milestone 9 開頭仍標記為 In Progress 的狀態不一致。
- 將 Android productFlavors、iOS Schemes 與其他 Native Flavor 工作移回 Backlog，等待平台 scaffold 與發布需求明確後再規劃。
- 移除 `packages/auth` 對 `injectable` 的依賴。
- 移除 `packages/auth` 內 data source、repository、use case 的 DI annotations。
- Auth package 物件改由 app 的 `RegisterModule` 統一註冊與組裝，維持 app 作為唯一 Composition Root。
- Auth RemoteDataSource 改為依賴 `AuthApi` abstraction，並由 App Composition Root 預設注入 `MockAuthApi`。
- Auth Repository 改用 DTO mapper 建立 Domain Model，持久化與 Session 更新責任維持在 Repository。
- Auth / Profile API implementation 改由 `API_MODE` 決定，Dio base URL 改由 `API_BASE_URL` 注入。
- Auth / Profile Repository 改為只映射 `AppException`，未知程式錯誤不再轉成一般 Failure。
- AuthLocalDataSource 將 SharedPreferences / SQLite 例外統一轉為 `AppException`。
- SessionManager 改為純 runtime state holder，token / user persistence 統一由 AuthRepositoryImpl 負責，移除重複 token 寫入。
- LoginRequestDto 關閉欄位型 `toString()`，並以安全 transport 摘要取代完整 DioException cause，避免敏感資料進入一般 log。
- `API_MODE=real` 時強制要求合法 `API_BASE_URL`，並補上可直接測試的 config parsing。
- 預設 API mode 維持 Mock，真實 API 可透過 `--dart-define` 啟用。
- Profile Repository 改為依賴 `ProfileRemoteDataSource`，再由其呼叫 `ProfileApi` abstraction；App Composition Root 預設注入 `MockProfileApi`。
- Authenticated Profile endpoint 改由 Retrofit `@Extra` metadata 標記，不再保留手寫 Dio request 示範方法。
- Login request DTO 明確宣告 `toJson()` contract，修正 Retrofit request body 被轉成字串而非 JSON 的問題。
- Failure 顯示訊息統一使用 Repository 提供的 domain fallback，技術 exception message 保留在 cause chain。
- 同步更新 Root README、Auth feature README、Clean Architecture 文件與 docs 導覽中的 Auth API 流程。

### Verified

- Milestone 12-7：`dart pub get`、build_runner、analyze、全部 flutter test，以及 development / staging / production bundle build 全部通過。
- Milestone 12-6：10 個 authenticated request 同時 401 只呼叫一次 refresh，並全部使用新 token replay。
- Login / Restore / Logout / AuthGuard / Profile regression、refresh token rotation、persistence compensation、Session identity race 與 invalidation cleanup failure tests。

- Milestone 10：`dart run melos run build_runner`、`dart run melos run analyze`、`dart run melos exec -- flutter test`、`flutter build bundle`。
- staging / production Dart entrypoint 已分別完成 `flutter build bundle` 驗證。
- `dart pub get`
- `dart run melos run build_runner`
- `dart run melos run analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`
- Retrofit `POST /auth/login` request body serialization test。
- Retrofit `GET /profile` authenticated metadata test。
- Mock Auth / Profile tests、DTO JSON serialization tests、Mapper tests。
- Transport exception mapping 與 Profile Repository known / unknown error regression tests。

---

## [1.0.0] - 2026-06-27

### Added

- 建立 Flutter Enterprise Architecture Template 第一個穩定基線。
- 完成 Clean Architecture + Feature First 專案結構。
- 完成 Login Flow、Profile Flow、Route Guard、Session Restore。
- 完成 Repository Pattern、UseCase、Bloc、API Client、SQLite、SharedPreferences 整合。
- 完成 GetIt + Injectable dependency injection。
- 完成 AutoRoute shell route、nested routes 與 guarded route。
- 完成 Melos 8 + Dart Pub Workspaces migration。
- 新增 `CHANGELOG.md` 作為後續模板版本紀錄。

### Changed

- 升級 workspace SDK constraint 至 `>=3.8.0 <4.0.0`。
- 升級核心 dependency / generator / DI / router / lint stack。
- `build_runner` script 改為使用 `dart run build_runner build`。
- Freezed 3 相容性調整：`@freezed` class 改為 `abstract class`。
- Bloc Event union type 改為 `sealed class`。
- AutoRoute 測試相容新版 `children` API。
- 移除 package entrypoint 中不必要的 `library xxx;`。
- 移除 `core` package 未使用的 dependencies。

### Verified

- `dart pub get`
- `dart run melos run build_runner`
- `dart run melos exec -- flutter analyze`
- `dart run melos exec -- flutter test`
- `flutter build bundle`
