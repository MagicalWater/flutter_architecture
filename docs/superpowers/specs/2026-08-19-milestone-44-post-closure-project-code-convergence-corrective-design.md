---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-44-post-closure-project-code-convergence-corrective-design
last_reviewed_baseline: 1.25.2
---

# Milestone 44 Post-closure — Project Code Convergence Corrective Design

## Status

**Accepted — 2026-08-19 使用者明確核准。**

## 1. Goal

在不reopen M44、不建立固定folder taxonomy、不全面token化Pencil exact values、也不恢復大量architecture tests的前提下，讓current Write Precheck production ownership、exact-value rationale與implementation mapping重新收斂到ADR-018／028／032 current authority。

## 2. Design principles

### D1 — Responsibility before folder shape

Presentation ownership以change reason／product semantics／layout authority為判斷基礎。`widgets/`可繼續存在；只有source已同時承擔可獨立review／replace的不同responsibilities時才拆分。

Current confirmed target至少包含`write_precheck_content_components.dart`：Progress Step、Data Row、Record Tile、Secondary Action應形成各自coherent owner，或有fresh evidence證明其中某些可共享同一primary responsibility。禁止以一檔一class作成功條件。

### D2 — Page/View current split remains valid

`WritePrecheckPage`持有route admission與`AppLocalizations -> WritePrecheckCopy` mapping；`WritePrecheckView`持有Scaffold、LayoutBuilder、scroll與whole-screen composition。此split維持，不因Page薄而合併，也不建立額外Controller／Flow formalism。

### D3 — Exact literal classification, not literal elimination

Risk-selected UI literal只需落到下列其中一類：

1. shared semantic / Design System owner；
2. feature-local stable semantic owner；
3. component-local exact measurement / decoration；
4. derived relationship measurement；
5. bounded optical adjustment。

第3～5類可以保留literal，但必須靠近smallest correct owner；若公式或數值無法由名稱、局部常數、函式語意或mapping rationale解釋，視為unexplained magic code並需收斂。

不建立`WritePrecheckDimensions`／`VisualSpec`／`MagicNumbers`等catch-all owner。只有同一bounded owner內重複且具有單一語意的measurement才可提升成narrow local constant。

### D4 — Relationship geometry stays relationship-owned

M44已建立的relationship layout不回退。普通Text／row／button content不得因本次整理常數而重新導入canonical `left/top` contract。Remaining spatial coordinate只保留已有bounded artwork／overlay rationale的區域。

### D5 — Mapping must describe current production identity

`implementation_mapping.json`的critical node `flutter_owner`／consumer必須對應current production owner identity；owner rename／split後必須同步mapping。Mapping不是歷史snapshot。

若一個historical critical node現在由多個bounded owners共同實作，Design允許mapping schema在不建立第二套authority的前提下使用最小可表達形式，例如明確owner list或更精準的single current owner；實際schema變更只能在現有schema不足以表達current truth時發生。

### D6 — Evidence reference must be live and typed enough to trust

Resolved `screen_layouts` / risk-selected mapping evidence不得只驗證「字串非空」。至少需要：

- repository-relative evidence path存在；
- path不得escape repository；
- 若evidence指向已退休test或不存在artifact，validator fail closed；
- validator不要求evidence一定是test，允許current source、audit、manifest或其他由mapping contract接受的authority類型。

本corrective優先採最小path-existence／repository-boundary validation；不建立通用文件引用圖或全repository backlink checker。

### D7 — Test-by-exception remains authoritative

這次machine validator本身是shared production/governance contract，若新增failure mode具有高重複風險，可保留極小critical test owner；Presentation file split、magic-code cleanup與mapping內容同步本身不要求建立永久widget/source-shape tests。

Implementation後所有新增test都必須做Retention Decision。

## 3. Proposed source ownership direction

Target不是固定folder tree，而是最小coherent owners。預期可採：

```text
presentation/
  pages/
    write_precheck_page.dart
    write_precheck_view.dart
  layout/
    write_precheck_projection.dart
  widgets/write_precheck/
    write_precheck_content.dart
    write_precheck_step.dart
    write_precheck_data_row.dart
    write_precheck_record_tile.dart
    write_precheck_secondary_action.dart
    write_precheck_top_area.dart
    write_precheck_hero_section.dart
    write_precheck_information_cards.dart
    write_precheck_guidance_section.dart
    write_precheck_actions_section.dart
    write_precheck_visual_primitives.dart
    write_precheck_palette.dart
    write_precheck_typography.dart
    write_precheck_text_style.dart
```

此樹只是current likely decomposition，不是stable mandatory architecture。Implementation review必須以responsibility證明每個實際split，而不是照圖搬檔。

`write_precheck_actions_section.dart`與`write_precheck_information_cards.dart`仍需在implementation前做focused cohesion review；若其中class共享同一section/frame responsibility，可以保持共檔。

## 4. Magic-code reconciliation strategy

不做全檔數字清零。Implementation只挑下列risk signals：

- arithmetic layout formulas沒有名稱或relationship語意；
- state-specific ternary measurement散落且重複；
- optical scale/offset沒有bounded owner名稱或rationale；
- 同一component內數值彼此具有derived relationship但以獨立magic literals表達；
- shared semantic value繞過已有owner。

可接受修正形式包括：

- narrow private/local constants；
- semantic local record/config只服務單一component責任；
- helper把derived formula命名，例如content inset或icon-to-label gap；
- mapping／comment只在formula無法靠code self-explain時補最小rationale。

禁止建立repository-wide magic-number lint，因為Flutter visual code存在大量合法exact measurements，heuristic會產生高false positive。

## 5. Mapping / validator convergence

### Mapping content

更新Write Precheck critical node owner names，移除已不存在的owner identity，並把screen layout evidence改成current live authority。

### Validator

`tools/visual/pencil_implementation_mapping.py`對resolved evidence增加repository-bound live-reference check。Validation contract：

```text
non-empty evidence_ref
+ safe repository-relative path
+ path exists
=> evidence reference structurally live
```

這只證明reference可解析，不宣稱artifact語意內容一定正確；semantic correctness仍由review／accepted authority負責。

## 6. Compatibility / migration

- Existing valid mappings若使用current repository-relative evidence path，無行為變更。
- Missing/stale evidence原本可能PASS，corrective後FAIL closed；這是intentional tightening。
- 不改`.pen` schema、visual manifest schema或release validation contract。
- 不要求所有historical/archive mapping回填；只治理current production acceptance mapping。

## 7. Validation design

最低充分validation：

- mapping validator對current Write Precheck mapping PASS；
- synthetic missing/stale/escape evidence reference FAIL；
- current owner names與source truth一致的focused review；
- affected Dart analyze；
- affected existing visual/runtime acceptance只在source layout/visual output被實際改動時執行planner-selected/focused evidence，不因「M44」名稱自動跑full regression；
- `git diff --check`與documentation authority consistency。

不因本corrective自動執行release validation、Android+iOS matrix或全workspace full tests。

## 8. ADR disposition

目前不修改ADR-018／028／032。Design是在現有stable rules下收斂current implementation與machine enforcement。

只有implementation發現current mapping schema無法表達current owner truth，且需要新增stable mapping semantics時，才回到ADR gate；不能在Plan中靜默擴張。

## 9. Release disposition

本corrective完成後仍保持unpublished。Generated / Platform Owner Alignment與manual-local release backend不重做；兩者與本corrective一起等待後續explicit release candidate decision。

