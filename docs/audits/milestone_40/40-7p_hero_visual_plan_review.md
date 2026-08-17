---
document_type: planning-review
status: active
authoritative_for:
  - milestone-40-hero-visual-corrective-plan-review
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7R — Hero Visual Corrective Implementation Plan Review

## Review target

`docs/superpowers/plans/2026-08-17-milestone-40-hero-visual-corrective.md`

Accepted Design：`docs/superpowers/specs/2026-08-17-milestone-40-hero-visual-corrective-design.md`

## Focused review

### F-40-7R-P01 — Candidate不能在使用者驗收前進live README

- Severity：P1。
- Check：Plan把candidate review與README promotion拆成40-7R-3／40-7R-4，user visual acceptance是blocking precondition。
- Result：PASS。

### F-40-7R-P02 — Source family extraction必須先於generation

- Severity：P1。
- Check：40-7R-1先產生visual-family contract，40-7R-2才允許Executor generation。
- Result：PASS。

### F-40-7R-P03 — Prompt-only fallback必須fail closed

- Severity：P1。
- Check：source-image allowlist失敗時Task blocked；不得退回generic prompt-only generation。
- Result：PASS。

### F-40-7R-P04 — Visual acceptance不能再只看source/path

- Severity：P1。
- Check：40-7R-3要求candidate、兩張authority visuals與rejected comparison直接inline render。
- Result：PASS。

### F-40-7R-P05 — GitHub窄viewport與light/dark要有可重現evidence

- Severity：P1。
- Check：Plan要求deterministic 700px／360px downscale以及white／near-black surrounding canvas evidence。
- Result：PASS。

### F-40-7R-P06 — Rejected candidate不得作新generation source

- Severity：P1 anti-regression risk。
- Check：Plan只允許兩張accepted architecture visuals進`source_images`；rejected candidate只作comparison reference。
- Result：PASS。

### F-40-7R-P07 — Visual companion不得覆蓋Design

- Severity：P1 governance risk。
- Check：`brandkit`與`high-end-visual-design`都被限制為critique companion；不得重選Design direction或帶入Web execution rules。
- Result：PASS。

## Fresh Plan findings

### F-40-7R-P08 — Derived evidence不能成為新的「調圖」入口

- Severity：P1 evidence-integrity risk。
- Finding：若700／360／light-dark preview透過非deterministic filter、enhance或crop產生，可能讓review看到的不是master candidate真實縮放結果。
- Required fix：derived evidence只能resize／pad／place-on-background，不得sharpen、recolor、denoise、crop critical content或生成新pixels來改善candidate。
- Fix：Plan鎖定derived evidence只允許等比例resize、padding與放置於純色background；禁止sharpen／recolor／enhance／generative fill／critical crop。
- Fresh re-review：PASS。

### F-40-7R-P09 — Candidate保存位置與docs checker ownership需明確

- Severity：P1 authority risk。
- Finding：`docs/assets/readme/candidates/`若沒有明確temporary／non-authoritative semantics，可能被誤認為current landing asset。
- Required fix：Plan需在candidate review與index evidence中明確標記candidate lifecycle；只有promotion move到canonical live path後才是current Hero。
- Fix：Plan新增candidate lifecycle標記；`candidates/`永遠non-authoritative，只有user acceptance後move到canonical live path才取得current Hero資格。
- Fresh re-review：PASS。

### F-40-7R-P10 — User Reject後的regeneration上限／回Design條件不足

- Severity：P1 loop-control risk。
- Finding：Plan說reject後可regenerate，但沒有界定何時代表selected Design direction E本身失敗，可能再次進入無限generation loop。
- Required fix：同一Design direction最多允許一個fresh replacement candidate；若replacement仍因product identity／structural family critical gate被Reject，必須回Design而不是生成第三張。
- Fix：同一Design direction最多C01 + C02；C02若仍命中identity／family／source-copy critical FAIL，必須回Design，禁止C03。
- Fresh re-review：PASS。

### F-40-7R-P11 — Native generation result與repo candidate identity未鎖定

- Severity：P1 evidence-integrity risk。
- Finding：`call_executor_tool`讓host看到native image，但後續仍需把output保存進repository；若中間有轉碼、重壓或拿錯檔，review artifact可能不是host實際看過的generation result。
- Fix：Plan要求Image MCP output path與repo candidate copy的SHA-256完全一致，不允許轉碼／重壓後替換。
- Fresh re-review：PASS。

### F-40-7R-P12 — Candidate move可能讓historical review preview再次失效

- Severity：P1 acceptance-evidence risk。
- Finding：candidate在user reject／accept後會move到rejected或canonical live path；若review Markdown仍指向舊candidate path，視覺證據會再次變成broken image。
- Fix：任何move都必須同步更新review artifact inline relative path並fresh `docs_check`。
- Fresh re-review：PASS。

## Current state

```txt
Plan status: proposed
Focused review: PASS after P08-P10 fixes
Open P0: 0
Open P1 without disposition: 0
Whole-Plan review: pending
User approval: pending whole-Plan review
Implementation: forbidden
```

## Whole-Plan review

### Fresh focused re-review

逐項重新檢查P01～P12：

- P01 user acceptance before live README：PASS。
- P02 extraction before generation：PASS。
- P03 source-image fail-closed：PASS。
- P04 actual inline preview：PASS。
- P05 downscale／light-dark deterministic evidence：PASS。
- P06 rejected candidate excluded from source_images：PASS。
- P07 visual companion boundary：PASS。
- P08 derived evidence integrity：PASS。
- P09 candidate lifecycle authority：PASS。
- P10 C01／C02 loop control：PASS。
- P11 native output／repo candidate SHA-256 identity：PASS。
- P12 candidate move後review preview continuity：PASS。

Fresh focused re-review沒有新增P0／P1 finding。

### Whole-Plan holistic review

Plan完整覆蓋accepted Design的execution needs：visual-family extraction、source-image generation、zero text contamination、source-derived-not-copied、single-candidate discipline、native image delivery、candidate non-authority、deterministic downscale／theme evidence、13項critical review、user visual gate、promotion後README integration與corrective closure。

Ordering符合governance：

```txt
40-7R-1 extraction contract
→ 40-7R-2 one candidate generation
→ 40-7R-3 visual review + user gate
→ 40-7R-4 accepted-only README promotion
→ 40-7R-5 holistic closure
```

不會在Plan acceptance前生成；不會在user visual acceptance前更新README；不會因candidate失敗無限生成。

### Authority check

```txt
Design direction owner: accepted 40-7R Design
Generation source authority: two accepted architecture visuals
Candidate path: non-authoritative
Rejected path: historical evidence only
Live Hero path: only after explicit user visual acceptance
Architecture visual authority: unchanged
README: consumer only
```

### Test Authoring / validation disposition

本工作不新增runtime behavior，Test Authoring維持`Should-not-add`。Machine validation由`validation_planner.py`與`docs_check`擁有；視覺正確性由actual image evidence + user acceptance擁有，不建立虛假的pixel-threshold automated test。

## Final review state

```txt
Plan status: proposed
Focused review: PASS after P08-P12 fixes
Fresh focused re-review: PASS
Whole-Plan holistic review: PASS
Authority check: PASS
Open P0: 0
Open P1 without disposition: 0
User approval: pending
Implementation: forbidden until user approval
```
