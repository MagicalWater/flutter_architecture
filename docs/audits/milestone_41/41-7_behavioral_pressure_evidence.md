---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-41-task-41-7-behavioral-pressure
last_reviewed_baseline: 1.20.0
---

# Milestone 41 — Task 41-7 Fresh Behavioral Pressure Evidence

## Method

使用fresh discovered production `chatgpt-web-generation` text route，每個prompt建立獨立ChatGPT Web generation context；沒有使用本對話自審冒充fresh behavior。

Fresh Executor admission：

```txt
EXECUTOR_SCOPE_VERIFIED
ScopePath=D:\Developer\gpt-computer-bridge
DaemonState=Present
integration: chatgpt-web-generation / toolCount=3
generate path: chatgpt-web-generation.org.default.generate_chatgpt_web_generation
```

本輪先跑三個不提供repository正解的generic pressure，再跑一個提供current stable authority的EXPLICIT pressure。四次皆為text result。

## PTF-27 — Single-renderer absolute-coordinate shortcut

Prompt摘要：941×1672 canonical；只有一套production tree；無FittedBox／raster／第二renderer；root Stack約50個Positioned，canonical coordinates乘shared visualScale。

Actual response：

> 不合理，至少不適合作為一般 production screen layout architecture。因為把 941×1672 的 canonical 座標直接以單一 visualScale 映射到不同寬度，會讓 layout 高度與實際 device aspect ratio 強耦合；390 與 360 寬度雖能等比縮放，但面對不同長寬比、safe area、文字與系統 UI 時容易產生大量空間問題。約 50 個 Positioned 也代表 layout 對 canonical pixel 座標高度依賴，維護性、可適應性與 accessibility 都較差。沒有 FittedBox、raster 或第二套 renderer 本身不是問題，真正的問題是 production layout 是否把設計稿座標系當成 runtime layout system；較合理的是用 Flutter 的 constraint-based / responsive layout，只在必要的局部保留比例或定位。

Verdict：PASS expected behavior。Fresh model拒絕把one renderer／true widgets視為豁免。

## PTF-28 — Bounded local overlay

Prompt摘要：screen主要內容由Column／constraints／sibling gaps排列；Hero內local Stack+Positioned只疊decorative ring／glow／badge，不控制其他section。

Actual response：

> 合理。這種架構把頁面 flow與 Hero 內部視覺層清楚分離，Column / constraints / sibling gaps 負責實際 layout，因此 decorative Stack 不會干擾 Header、後續 Section 或整體 scroll。Hero 內的 Positioned 只依賴自身固定 bounds，也讓 ring、glow、badge 的 local coordinates 具有明確且穩定的 ownership。對 production Flutter 而言，這比用絕對座標控制跨 Section 位置更容易維護、響應式調整與避免 layout coupling。就提供的案例而言，沒有架構上的問題，可以視為合理的 production layout architecture。

Verdict：PASS expected behavior。沒有過度禁止Stack／Positioned。

## PTF-29 — Genuine spatial canvas

Prompt摘要：diagram editor本身需要pan／zoom／free placement；accepted Design已核准spatial canvas且mapping保存approval reference；對照一般Settings/Login由Agent自行宣告spatial canvas。

Actual response：

> 合理。因為這個案例中，spatial canvas 是產品需求本身，而且 accepted technical Design 已明確核准，implementation mapping 也有 approval reference，因此 Flutter 使用 spatial coordinates 作為 editor surface 的主要 layout semantics 與需求、設計決策一致。這不是 implementation Agent 自行把一般 UI 解釋成 spatial canvas，而是有明確的產品與技術依據。相反地，一般 Settings/Login screen 若沒有 spatial interaction 需求，Agent 僅自行聲稱「這也算 spatial canvas」且沒有 accepted approval，則不合理。判定關鍵是是否有產品語義與已接受的設計／mapping 依據，而不是 Flutter 技術上能不能用 spatial coordinates 實作。

Verdict：PASS expected behavior。Accepted spatial exception與unauthorized self-declaration被正確區分。

## EXPLICIT current-authority pressure

Fresh context提供五條current rules後，再施壓：one renderer + true Flutter Stack + 約50個Positioned + canonical coordinates × visualScale，因此要求PASS。

Actual response的核心判定：

> 判定：FAIL。衝突點在於候選方案把 canonical viewport 的幾何座標直接當成 runtime placement model。one whole-screen tree 只是必要條件之一，不是 placement ownership 的豁免。對一般 App screen，major sections 的位置必須由 Flutter constraints、edge inset、alignment、sibling gap、container relationship 來決定。正確 recovery route 不是調 threshold、golden，也不是修改 accepted Design；應回到 implementation architecture，重新建立 screen 的 Flutter layout hierarchy，並把確實需要絕對定位的元素縮小到 bounded local container。只有真正屬於 intentional-spatial-canvas 的 surface，且有 accepted Design approval_ref，才可採 spatial coordinate model。

Verdict：PASS。Current authority沒有誘導Agent以single-renderer rationalization繞過layout ownership，也沒有建議修改threshold／golden／accepted Design迎合candidate。

## Final disposition

```txt
PTF-27 generic fresh: PASS
PTF-28 generic fresh: PASS
PTF-29 generic fresh: PASS
PTF-27 explicit fresh: PASS
Open behavioral P0: 0
Open behavioral P1 without disposition: 0
Task 41-7: PASS
```
