---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-39-pencil-flutter-fidelity-enforcement-recovery-design
last_reviewed_baseline: 1.19.0
---

# Milestone 39 — Pencil-to-Flutter Fidelity Enforcement & Recovery Governance Corrective Design

## 1. Design status

```txt
Requirement: accepted
Design: accepted
Plan: not created
Implementation: forbidden until Design and Plan are accepted
```

本Design補強既有Milestone 33／34 Pencil-to-Flutter route，不建立第二個Pencil domain Skill，也不改變accepted `.pen`的最高visual authority。

## 2. Confirmed failure model

Current route已能阻止多數宏觀shortcut，但fresh audit與實際較早產品migration corrective證明仍有五種residual failure mode：

1. **Critical-node omission**：mapping prose存在，但重要icon／image／geometry node可能沒有被完整列入implementation decision。
2. **Identity drift hidden by semantic equivalence**：current Skill已禁止approximate icon，但缺少每個critical mapping的統一machine disposition。
3. **Runtime geometry drift**：source constants符合Pencil，不代表parent constraint後的`RenderBox` geometry符合。
4. **Micro-fidelity dilution**：whole-screen metric可被大面積背景／layout稀釋，critical icon／asset／1–2dp drift可能不影響global threshold。
5. **Invalid candidate persistence**：wrong source／wrong representation被review判定後，Agent仍可能在同一錯誤candidate上持續調padding／scale／offset。

這些failure不是要求重做Pencil workflow，而是要求把既有representation與visual acceptance規則轉成更強的implementation-specific evidence。

## 3. Architecture decision

### 3.1 Keep one domain Skill

唯一domain orchestration仍為：

```txt
governing-template-development
→ implementing-pencil-flutter-design
```

`implementing-pencil-flutter-design`繼續只負責workflow ordering、fail-closed routing與stop/recovery semantics。Detailed schema、checker、test helpers與visual comparison implementation不得塞進主`SKILL.md`。

不新增`pencil-flutter-fidelity-enforcement`或其他同trigger Skill，避免Skill collision、authority overlap與未來wording drift。

### 3.2 Add initiative-local implementation mapping evidence

每個需要Milestone 39強化契約的Pencil-to-Flutter implementation initiative，新增**initiative-local machine-readable mapping artifact**，預設位置：

```txt
docs/visual_authority/<initiative>/implementation_mapping.json
```

此檔案不是第二份design authority，也不是global asset registry。它只回答：

> accepted Pencil authority中的critical implementation inputs，最終由Flutter以什麼representation承擔，是否已resolved，以及由什麼evidence驗證。

Primary `.pen`與`manifest.md`仍擁有visual authority；`implementation_mapping.json`只擁有implementation mapping evidence。

### 3.3 Critical-only, risk-based inventory

Inventory不要求列出所有Pencil node。只有符合至少一項risk signal的node／region才標為`critical`：

- custom或cross-library icon identity容易drift；
- existing raster／vector image asset；
- complex fixed ornament／texture／background；
- primary CTA／sticky action／major navigation；
- AppBar／hero／major card等geometry失真會改變hierarchy；
- 小尺寸micro-asset不容易被whole-screen metric捕捉；
- historical failure已證明該類元素容易被approximation；
- accepted Design／Plan顯式標記為critical fidelity owner。

普通spacing、divider、低風險Text或一般surface不因存在就進inventory。這避免把mapping evidence膨脹成每node checklist。

## 4. Mapping schema contract

Machine-readable artifact至少包含：

```json
{
  "schema_version": 1,
  "initiative": "example",
  "pencil_authority_sha256": "...",
  "critical_nodes": []
}
```

每個`critical_nodes` entry至少具有：

```txt
node_id
role
representation_class
disposition
flutter_owner
consumer
```

並依representation提供必要欄位，例如：

### Icon

```txt
library
glyph
weight
bounds
fill
resolved representation identity
```

### Raster／Vector asset

```txt
source identity
source hash when repository-local bytes exist
derived transformation, if any
destination
content hash
fit / clip / opacity when fidelity-relevant
```

### Critical geometry

```txt
accepted bounds / relationship
runtime geometry evidence owner
tolerance or exactness contract
```

Schema只保存可機械判斷的必要fields；長篇review reasoning留在Task audit，不把JSON變成第二份Design Spec。

## 5. Mapping disposition state machine

所有critical mapping只能使用下列狀態：

### `exact`

Flutter直接使用accepted source identity或經可追溯、identity-preserving representation。

Examples：

- exact Pencil-exported SVG／PNG；
- exact repository-owned asset bytes；
- 已知同一verified glyph source。

### `verified-equivalent`

Flutter representation不是同一bytes/source form，但已有事前證據證明visual identity足夠等價。

此狀態必須提供`evidence_ref`。只因icon名稱相同、語意相同或肉眼「差不多」不可使用。

### `intentional-deviation`

Accepted Design／Plan／review明確允許偏離visual authority，例如platform-native requirement或runtime behavior使exact representation不適用。

此狀態必須提供`approval_ref`；implementation Agent不得自行建立此狀態。

### `unresolved`

Representation／source／equivalence／provenance尚未解決。

```txt
unresolved
→ Flutter production mapping blocked
→ visual acceptance blocked
```

Machine checker只接受已知enum，且任何critical node為`unresolved`即fail closed。

## 6. Representation compatibility

Milestone 34既有六類representation不改變：

```txt
Layout primitive
Typography
Approved package icon
Vector asset
Raster asset
Dynamic drawing
```

Milestone 39只在critical items上增加identity／disposition／evidence completeness。

因此不得導出：

- 所有icon都必須PNG；
- 所有existing image都只能raster；
- package icon永遠不可用；
- `CustomPainter`永遠不可用。

合法representation仍由source nature、runtime-driven geometry、scaling、theme／accessibility與accepted Design決定；approximation不能成為silent default。

## 7. Critical runtime geometry gate

### 7.1 Principle

對risk-selected geometry，驗收的是runtime結果，不是source constants。

例如：

```txt
Pencil button: 161 × 27
source: height: 27
runtime RenderBox: 160.4 × 25.8
```

此情況必須FAIL對應critical geometry contract。

### 7.2 Primary owner

當deterministic widget test可直接取得geometry時，優先使用Flutter test runtime evidence，例如：

```txt
tester.getSize
tester.getTopLeft
tester.getBottomRight
```

不要求每個node新增test。Test Authoring Decision由failure risk決定：已知constraint-sensitive primary CTA／sticky area／major hierarchy geometry屬高regression value時，geometry owner為Recommended或Required；普通低風險geometry可`no-new-test justified`。

### 7.3 Relationship over raw coordinates

Responsive screen不應把所有canonical x/y直接當runtime absolute coordinate。Design可指定：

- exact size；
- proportional size；
- edge inset；
- center alignment；
- sibling gap；
- container relationship。

Machine evidence只驗accepted relationship，不以canonical desktop/mobile design-space數值錯誤限制所有runtime viewport。

## 8. Local visual fidelity gates

### 8.1 Whole-screen remains broad regression owner

既有canonical／runtime whole-screen golden與diff繼續捕捉：

- major layout drift；
- missing sections；
- large palette drift；
- clipping／density regression。

不取消、不以section tests取代。

### 8.2 Critical region owner

對whole-screen容易稀釋的critical items，Plan必須選擇最小充分local fidelity evidence，例如：

- deterministic component golden；
- predeclared section/ROI crop comparison；
- exact asset identity/hash check；
- icon source/equivalence evidence；
- runtime geometry assertion。

不是每個critical node都必須同時擁有全部類型證據。Primary owner應選最接近failure source的一個或最小組合。

### 8.3 Predeclare before candidate

若使用section／ROI visual diff，必須在candidate comparison前固定：

```txt
region identity
source bounds / derivation
target dimensions
crop / projection
tolerance / threshold
```

Candidate失敗後不得移動crop、縮小ROI或放寬threshold。

### 8.4 Local failure overrides global PASS

```txt
whole-screen PASS
+ critical local gate FAIL
= overall visual acceptance FAIL
```

Pixel global metrics不得覆蓋critical-node identity、critical geometry或semantic P1。

## 9. Wrong-representation recovery contract

新增正式recovery state：

```txt
review identifies wrong source / wrong asset / wrong icon / wrong representation
→ mark current mapping invalid
→ stop candidate-specific geometry tuning for that mapping
→ return to representation classification / provenance resolution
→ resolve replacement representation
→ update mapping evidence
→ fresh focused validation
→ restart affected visual acceptance
```

### Invalid mapping rules

- Invalid mapping不得透過padding、scale、crop、opacity、offset或threshold tuning恢復為accepted。
- 若新的evidence證明原mapping其實`verified-equivalent`，必須先補equivalence evidence，再重新進candidate；不能只靠修改後看起來較像。
- 若source authority本身需要改變，回中央Requirement／Design gate；implementation recovery不得修改accepted `.pen`迎合Flutter。

這個recovery只撤銷受影響mapping／visual gates；不要求無關Task或whole Milestone全部重做。

## 10. Machine enforcement

新增repository-owned checker，預期責任：

```txt
implementation_mapping.json exists when initiative opts into Milestone 39 contract
schema version supported
authority hash matches current manifest authority
critical node IDs unique
representation class known
disposition known
unresolved count = 0 before production acceptance
verified-equivalent has evidence_ref
intentional-deviation has approval_ref
asset-derived bytes have transformation / destination / content hash
required owner / consumer fields present
```

Checker不解析`.pen`；它只驗證Pencil MCP extraction後產生的mapping evidence。不得藉此建立native `.pen` parser。

是否能機械驗證「critical inventory completeness」必須透過Pencil MCP extraction evidence與Plan選定的critical-node manifest handoff完成；checker不得自己繞過Pencil MCP掃`.pen`。

## 11. Behavioral pressure scenarios

Current PTF-01～PTF-18保留，至少新增：

### Critical mapping omission

Pencil extraction有三個critical icons，mapping artifact只列兩個。Agent不得開始production；先補complete mapping evidence。

### Cross-library same-name icon

Pencil為Material Symbols Rounded，Flutter bundled Material Icons有同名glyph。不得因名稱相同標`exact`；必須verified equivalence或使用authority-backed representation。

### Existing asset redraw

Pencil已引用accepted raster/vector asset，Agent想用CustomPainter／gradient重畫。若不是runtime-driven且無accepted deviation，mapping不得通過。

### Source constant vs runtime geometry

Source寫`height: 27`但test取得25.8。Critical geometry gate FAIL，不能宣稱source已符合。

### Global PASS / local FAIL

Whole-screen diff PASS但critical 12px icon identity FAIL。Overall visual acceptance仍FAIL。

### Invalid representation tuning

Reviewer判定asset source錯誤後，Agent想先調scale／padding改善。必須拒絕並回representation/provenance gate。

### Unauthorized deviation

Agent想把approximate package icon標`intentional-deviation`以繼續。沒有accepted approval reference即FAIL。

Behavioral validation仍使用fresh independent context的RED／DISCOVERY／EXPLICIT GREEN／REFACTOR protocol。

## 12. Test Authoring Decision

Milestone 39不以「新增了幾個contract」推導大量tests。

### Required

- Machine mapping checker的schema／fail-closed behavior regression owner。
- deterministic bugs／failure modes：unresolved accepted、missing evidence refs、invalid asset provenance、wrong recovery acceptance等。

### Recommended

- Critical runtime geometry fixture，用於證明source constant與RenderBox可能不同並驗證helper／contract。
- Local visual gate fixture，若需要證明whole-screen PASS不能覆蓋local FAIL。

### Should-not-add

- 每個Pencil node一個test。
- 每個icon一個golden。
- 每個section機械式建立visual test。
- 只為coverage或對稱目錄增加tests。

## 13. ADR gate

ADR-028 stable authority已擁有Pencil visual authority、Flutter mapping、single-renderer與visual acceptance。

本Design建議：

**Amend ADR-028，而不新增第二個ADR。**

原因：Milestone 39沒有建立新的architecture owner；只是把同一Pencil-to-Flutter stable boundary補上critical mapping evidence、local fidelity與recovery semantics。新增平行ADR反而容易讓visual acceptance ownership分裂。

ADR amendment只保存stable principles，不複製JSON schema完整fields、checker commands或Task sequencing。

## 14. Documentation ownership

- `ADR-028`：stable mapping／fidelity／recovery principles。
- `implementing-pencil-flutter-design/SKILL.md`：ordering、hard stops、recovery route。
- Skill references：詳細mapping／visual validation decision rules。
- `docs/guides/pencil_to_flutter_workflow.md`：human operation摘要與routing。
- `implementation_mapping.json`：initiative-specific machine mapping evidence。
- `tools/visual/**`：machine validation truth。
- Task audits：findings、review、actual evidence。

不得在多份文件複製完整schema與state machine。

## 15. Acceptance criteria

Milestone 39至少必須證明：

1. Existing Skill仍是唯一Pencil-to-Flutter domain route；same-name新增Skill為0。
2. Machine-readable critical mapping可以fail closed於missing／unresolved／unauthorized deviation／missing provenance。
3. Cross-library icon同名不會自動取得`exact`。
4. Existing static asset不能無理由被CustomPainter／approximation取代。
5. Critical runtime geometry可用actual RenderBox evidence攔截source-constant false confidence。
6. Critical local fidelity failure可以覆蓋whole-screen PASS。
7. Wrong representation被判定後，fresh Agent會回mapping/provenance而不是繼續pixel tuning。
8. No every-node test／global asset registry／raster-all-icons expansion。
9. Existing single-renderer、visual authority與Minimum Sufficient Validation contracts沒有退化。
10. Fresh isolated-agent DISCOVERY與EXPLICIT GREEN對新增pressure scenarios無P0／undisposed P1。

## 16. Rollback / compatibility

- Existing initiatives不因Milestone 39自動失效；只有新Task或明確adopted initiative才需要新的mapping artifact。
- Existing accepted Milestone 33 proof保持historical/current evidence，不為導入schema強制大量backfill。
- 若checker或schema證明成本過高，可rollback Milestone 39新增machine layer，但不得刪除Milestone 34既有approximate-icon／provenance／static-Painter fail-closed protections。

## 17. Open Design decisions

本Design沒有需要使用者額外選擇的產品scope分歧。Implementation Plan仍需決定：

- exact JSON schema file／validator module切分；
- 是否建立最小fixture initiative驗證critical geometry／local visual behavior，或重用既有Pencil compatibility fixture；
- pressure scenario IDs與Task sequencing。

這些屬Plan sequencing／implementation detail，不改變本Design stable contract。

