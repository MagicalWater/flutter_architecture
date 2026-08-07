---
document_type: design-spec
status: proposed
authoritative_for:
  - adr-028-single-renderer-responsive-fidelity-amendment-draft
last_reviewed_baseline: 1.15.0
---

# ADR-028 Amendment Draft — Single-Renderer Responsive Fidelity

## Status

Proposed design companion。Canonical ADR-028只有在Corrective Design與Plan均accepted後才修改。

## Context

Template Baseline 1.15.0 proof顯示：canonical `941 × 1672` renderer可達固定pixel threshold，但supported Android `360 × 640` runtime因走另一套whole-screen widget tree而被使用者判定visual fidelity不通過。既有ADR-028要求canonical／runtime evidence，卻沒有禁止parallel visual renderer，也沒有定義Pencil export尺寸與Flutter logical viewport之間的design-space關係。

## Proposed Amendment

### One accepted screen, one visual component model

一個accepted `.pen` screen只能映射到一套Flutter visual component tree。Canonical、phone與narrow layouts可以使用不同component-level layout policy，但不得以whole-screen breakpoint替換為另一套visual renderer。

### Canonical viewport is design/comparison space

Manifest的canonical Pencil viewport定義design／comparison space，不是Flutter logical breakpoint。Runtime geometry由accepted design-space projection與responsive contract導出。

### Projection is not fixed-canvas scaling

允許以shared design scale計算Flutter widget geometry；禁止top-level `FittedBox`、`Transform.scale`、raster embedding或其他把整張UI當成不可理解畫布的方式。Accessibility hit target與content-aware layout可以超出visible design geometry，但不得改變visual identity。

### Runtime fidelity is mandatory

Supported runtime screenshot必須有visual fidelity disposition。Scrollability、no-overflow、semantics與touch target只證明layout health，不足以宣稱design fidelity。

### Derived runtime reference

當`.pen`只有單一accepted手機frame時，可以由canonical Pencil preview依manifest／Plan事先固定的projection產生runtime-sized derived reference。Projection algorithm、target size、crop／scroll contract與hash必須在candidate comparison前固定；derived reference不取得`.pen` authority。

### Semantic P1 supersedes automated PASS

使用者或reviewer對supported runtime提出的visual semantic P1會撤銷對應PASS，直到implementation修正並fresh rerender／review。Canonical pixel PASS不得覆蓋runtime semantic failure。

## Consequences

- Workflow不能再以「canonical很準、mobile只是能用」宣稱完整fidelity。
- Single component model使canonical與runtime regression互相約束。
- Runtime visual validation成本增加，但避免測試專用renderer。
- Design-space projection需要明確處理text scale、touch target與極窄layout，而不是全畫面盲縮。

## Non-goals

- 不新增第二份mobile `.pen`。
- 不改寫accepted source以符合現有Flutter implementation。
- 不允許top-level full-canvas scaling作弊。
- 不建立general-purpose design renderer framework。

## Canonicalization Gate

本draft隨Corrective Design一起review。使用者核准Corrective Design後，仍須先建立並核准Corrective Implementation Plan；canonical ADR-028 amendment屬Plan中的獨立TDD／documentation governance Task。
