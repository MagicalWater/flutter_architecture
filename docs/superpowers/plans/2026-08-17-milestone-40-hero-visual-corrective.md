---
document_type: implementation-plan
status: proposed
authoritative_for:
  - milestone-40-hero-visual-corrective-implementation-plan
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7R — Repository Hero Visual Corrective Implementation Plan

## 1. Plan status

```txt
Requirement: accepted
Design: accepted / user approved 2026-08-17
Plan: proposed
Implementation: forbidden until Plan review and user approval
```

本Plan只執行accepted Hero Design，不重新決定Hero概念、README資訊架構或兩張existing architecture visuals的authority。

## 2. Execution principles

- 第一個新candidate生成前，先抽取兩張accepted architecture visuals的visual-family contract。
- `chatgpt-web-image`必須fresh Executor admission／discovery，並使用兩張accepted visuals作`source_images`；prompt-only不是fallback。
- 第一輪只生成一張master candidate，不一次大量生成再挑「最不差的」。
- Candidate先進入review/evidence path，不直接成為live README asset。
- User visual acceptance是candidate promotion的blocking gate；Agent不得self-PASS後直接寫入README。
- Rejected candidate只能保留為historical evidence，不得留在live asset naming或README consumer。
- `brandkit`只提供brand strategy／metaphor／premium restraint critique；`high-end-visual-design`只提供hierarchy／surface／anti-generic critique。兩者都不能覆蓋accepted Design或套用不相關Web execution rules。
- 不新增production tests；Test Authoring disposition為`Should-not-add`。Validation仍依planner與docs safety gates執行。

## 3. Task 40-7R-1 — Visual-family extraction & generation brief

### Goal

在生成前，把兩張accepted architecture visuals的repository-specific visual language轉成可review的generation contract，避免再次只生成「dark + blue」generic tech art。

### Inputs

- `docs/assets/architecture/productized-topology.png`
- `docs/assets/architecture/c4-dependency-contract.png`
- accepted Design：`docs/superpowers/specs/2026-08-17-milestone-40-hero-visual-corrective-design.md`
- rejected evidence：`docs/assets/readme/rejected/flutter-enterprise-architecture-hero-40-7.png`

### Files

- Create: `docs/audits/milestone_40/40-7r_1_visual_family_extraction.md`
- Create: `docs/audits/milestone_40/40-7r_1_visual_family_review.md`
- Modify: `docs/audits/README.md`

### Required extraction

至少明確記錄：

```txt
primary geometry language
module / container shapes
layer hierarchy signal
connector / dependency signal
blue / cyan accent behavior
surface / depth treatment
density / negative-space pattern
repository-specific cues
generic dark-tech cues that must NOT be copied
source text / labels that must NOT leak into candidate
```

### Required generation brief

把Design核心metaphor鎖定成：

```txt
modular reusable foundations
→ ordered architecture layers
→ composed mobile application shell
```

並明確禁止：

- random 3D blocks／motherboard／server-chip aesthetic；
- generic smartphone mockup作主角；
- Flutter logo仿製；
- source diagram拼貼或近似重製；
- source文字、字母、數字、偽字、label fragment；
- 依靠微小connector／微型module才能理解核心metaphor。

### Gate

- Focused review → findings → fixes → fresh re-review → whole-Task review。
- Open P0=0；Open P1 without disposition=0。
- 不呼叫image generation。

## 4. Task 40-7R-2 — Executor admission & single master candidate generation

### Goal

透過repository-approved `chatgpt-web-image` route生成**一張**master candidate，但不接入README。

### Required tools / Skills

- `executor-local-mcp`
- `chatgpt-web-image-mcp`
- `brandkit`：restricted strategy／metaphor critique only
- `high-end-visual-design`：restricted hierarchy／surface／anti-generic critique only

### Admission

依current Skill執行：

```powershell
pwsh -NoProfile -File scripts/verify-executor-scope.ps1
pwsh -NoProfile -File scripts/invoke-executor-scoped.ps1 tools integrations
pwsh -NoProfile -File scripts/invoke-executor-scoped.ps1 tools search "ChatGPT web image generate" --limit 20
pwsh -NoProfile -File scripts/invoke-executor-scoped.ps1 tools describe <fresh full path>
```

使用fresh discovery回傳的exact full path；不得hard-code remembered path。

### Source-image admission

- `source_images`只使用兩張accepted architecture visuals。
- 若Image MCP allowlist拒絕repository paths，Task維持blocked並修正合法routing；不得降級成prompt-only生成。
- Rejected 40-7 candidate**不得**作generation source，只能作anti-regression review reference。

### Candidate path

首次candidate保存為review-only naming，例如：

```txt
docs/assets/readme/candidates/flutter-enterprise-architecture-hero-40-7r-c01.png
```

此path不代表current Hero authority，且README不得引用。

Candidate lifecycle必須在`40-7r_3_hero_candidate_review.md`明確標記：

```txt
candidate / non-authoritative / not approved for README
```

只有使用者accept後，透過explicit move到`docs/assets/readme/flutter-enterprise-architecture-hero.png`才取得current Hero consumer資格。`candidates/`內任何檔案永遠不得被Documentation Hub、Project Context或README描述成current asset。

### Generation constraints

- 約3:1 wide band。
- 只生成一張master candidate。
- 不含任何文字／字母／數字／logo／偽字。
- central safe area保留app shell + ordered layers + modular composition三個主訊號。
- outer edges self-contained，light／dark GitHub surrounding background都可成立。

### Gate

- Native `type:image`必須由`call_executor_tool`回傳給host model；filesystem path不能代替visual acceptance。
- Image MCP回傳output path後，copy到repository candidate path前後必須記錄SHA-256並完全一致，證明host看到的generation result與repository review candidate是同一份bytes；不得另存、轉碼或重新壓縮後再送review。
- Candidate生成後只做candidate admission，不得直接宣稱PASS或更新README。

## 5. Task 40-7R-3 — Candidate visual evidence & dual-layer review

### Goal

對candidate做真正可視的focused + holistic review，產生user可直接驗收的artifact。

### Files

- Create: `docs/audits/milestone_40/40-7r_3_hero_candidate_review.md`
- Create derived evidence under: `docs/audits/milestone_40/assets/`

### Actual inline preview contract

Review artifact必須直接inline render：

1. candidate master；
2. `productized-topology.png`；
3. `c4-dependency-contract.png`；
4. rejected 40-7 candidate（只作anti-regression comparison，清楚標記rejected）。

不得再以Markdown source、path存在或檔案大小替代visual preview。

### Deterministic derived evidence

由candidate master deterministic產生review-only preview，不對master做「美化」：

- 約700px寬 downscale；
- 約360px寬 downscale；
- white surrounding canvas；
- near-black surrounding canvas。

可使用Pillow／等價local deterministic image operation；這些derived images只屬review evidence，不是landing authority。

Derived evidence只允許以下操作：

```txt
resize with aspect ratio preserved
pad without changing candidate pixels
place unchanged resized candidate on solid white / near-black background
```

禁止sharpen、denoise、recolor、contrast enhancement、content-aware fill、generative expand、critical-content crop或任何會讓review preview比master candidate更好看的處理。若master本身在360px下不可讀，必須判candidate FAIL，不能修derived preview。

### Focused critical gates

逐項明確PASS／FAIL accepted Design 13項candidate contract：

1. Product recognition。
2. Mobile application foundation signal。
3. Architecture recognition。
4. Repository-family consistency。
5. Non-duplication。
6. First-screen balance。
7. Actual preview。
8. Structural family match。
9. Downscale readability。
10. Crop safety。
11. Cross-theme framing。
12. Zero generated text contamination。
13. Source-derived, not source-copied。

任何critical FAIL => candidate rejected，禁止README consumer。

### Whole-candidate holistic review

除了逐項gate，還必須回答：

```txt
如果拿掉README標題，這張圖是否仍像本repository的architecture-template metaphor，
而不是可替換成AI／cloud／DevOps／security產品的generic banner？
```

答案若是否定或高度模糊，candidate FAIL。

### User visual acceptance gate

Agent完成focused／fresh re-review／holistic review後，**必須停下讓使用者實際看review artifact**。

- 使用者Reject：candidate移至`docs/assets/readme/rejected/`，record finding，再依Design的candidate workflow決定regenerate或回Design；不得偷偷promotion。
- 使用者Accept：才允許進Task 40-7R-4。

任何candidate move之後都必須同步更新review artifact的inline image relative path並fresh `docs_check`，確保accepted／rejected歷史review都仍能直接render實際圖片；不得保留broken preview再用文字說明替代。

### Regeneration budget / loop control

同一accepted Design direction E最多允許：

```txt
master candidate C01
+ one fresh replacement C02
```

若C01因local composition／execution defect被Reject，可依finding生成C02；但若C01已被判定**identity direction wrong**，應先確認finding是否仍符合accepted Design E，不能把同一錯誤prompt微調當replacement。

若C02仍因以下任一critical identity gate被Reject：

- Product recognition；
- Architecture recognition；
- Repository-family consistency／Structural family match；
- Source-derived, not source-copied；

則視為accepted Design direction E或其source strategy需要重新決策，必須回Design gate；禁止生成C03。

## 6. Task 40-7R-4 — Promote accepted Hero & README first-screen integration

### Preconditions

- Task 40-7R-3 candidate所有critical gates PASS。
- 使用者已明確 visual acceptance。

### Files

- Move accepted candidate to: `docs/assets/readme/flutter-enterprise-architecture-hero.png`
- Modify: `README.md`
- Modify: `docs/audits/milestone_40/40-7r_3_hero_candidate_review.md`
- Create: `docs/audits/milestone_40/40-7r_4_readme_first_screen_review.md`

### README order

```txt
H1
→ accepted Hero
→ positioning
→ baseline / platform / Use this template CTA
→ Architecture Overview image
→ Dependency Contract image
→ remaining text sections
```

不得刪除／降級／改成link兩張accepted architecture visuals。

### First-screen review

重新確認：

- Hero高度不把architecture visuals推到不合理深度；
- 三張圖有清楚責任層級，而不是互相競爭；
- H1／CTA可讀性不被Hero吞噬；
- light／dark surrounding context仍成立；
- README相對圖片路徑有效。

## 7. Task 40-7R-5 — Corrective holistic closure

### Files

- Create: `docs/audits/milestone_40/40-7r_5_holistic_final_review.md`
- Modify: `docs/audits/README.md`
- Modify: `docs/milestones/README.md`
- Modify: `docs/project_context.md`
- Modify: `docs/roadmap/active.md`
- Modify: `docs/superpowers/README.md`
- Modify: `CHANGELOG.md` only if current Unreleased narrative needs corrected closure wording

### Holistic assertions

- 原generic 40-7 candidate只存在rejected evidence path。
- Current README只引用user-accepted Hero。
- 兩張architecture visuals仍完整inline且authority不變。
- Candidate review artifact真的可看到candidate／source／rejected comparison。
- Level 2 Requirement → Design → Plan → implementation governance evidence完整。
- Open P0=0；Open P1 without disposition=0。

## 8. Validation strategy

Documentation／image-only Task固定至少執行：

```txt
git diff --check
dart run melos run docs_check
```

每個commit boundary再依：

```bash
python tools/ci/validation_planner.py --event push --base <task-base> --head <task-head> --stdout-json
```

執行planner-selected validations。不得因Level 2視覺工作無條件跑full Flutter suite。

## 9. Commit boundaries

建議：

```txt
docs(review): 鎖定 Hero visual family contract
docs(readme): 生成 Hero master candidate
docs(review): 完成 Hero candidate 視覺驗收
docs(readme): 接入核准 Hero 視覺
docs(milestone): 完成 Hero corrective closure
```

Rejected candidate不得用completion semantics commit成live Hero；應以review／rejection evidence語意保存。

## 10. Release disposition

預期仍是documentation／presentation-only，不提升Template Baseline。若implementation意外需要改stable documentation authority、bootstrap machine contract或checker behavior，停止並重新classification。

## 11. Stop conditions

只有以下情況停止：

1. Plan review完成等待使用者Plan核准。
2. Source-image allowlist／Executor出現真正external blocker。
3. Candidate完成雙層review後等待使用者visual acceptance。
4. Candidate rejection證明accepted Design direction E本身不成立，需要回Design。
5. Corrective完整closure。

一般prompt wording finding、derived preview bug、relative link error或docs validation failure直接修正並fresh re-verify。
