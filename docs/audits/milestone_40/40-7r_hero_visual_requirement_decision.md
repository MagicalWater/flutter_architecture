---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-40-hero-visual-corrective-requirement-decision
last_reviewed_baseline: 1.20.0
---

# Milestone 40-7R — Repository Hero Visual Corrective Requirement Decision

## Decision

```txt
Decision: Accept
Classification: Level 2 — Standard Feature / bounded presentation capability
Behavioral requirements: required
Brainstorming: required
Design Spec: required
Implementation Plan: required
ADR gate: conditional / not triggered unless stable documentation authority changes
Task governance: standard
Release: conditional; expected no version bump
```

## Problem

Milestone 40 已完成 root README 資訊架構，但 publication 前追加的 Hero visual 嘗試存在兩個 confirmed defects：

1. **Governance defect**：錯誤將 Level 2 視覺工作視為不需要 Design／Plan，直接 implementation 後 self-PASS。
2. **Product identity defect**：生成候選只是 generic dark-tech 3D banner，無法一眼辨識此 repository 的 Flutter、Enterprise Architecture、Template、Composition Root、modular packages 或 dependency structure。

因此原 `40-7_repository_hero_visual_review.md` 已 rejected，原 Hero consumer 從 root README 撤除。Rejected candidate 不得被 scale／crop／opacity 或位置調整挽救。

## Expected behavior

新的 Hero 必須是 repository-specific product visual，而不是 generic technology decoration。最低可觀察要求：

- 第一眼能聯想到 **Flutter / mobile application foundation**。
- 視覺中可感知 **layered architecture / modular packages / composition**，但不重做完整 C4 圖。
- 與既有 `productized-topology.png`、`c4-dependency-contract.png` 具有同一 visual family，不能像第三方 stock banner。
- Hero 不取代兩張正式 architecture visuals；三者 responsibility 必須清楚。
- Root README H1、baseline、CTA 仍使用可存取的 Markdown text，不依賴 generated text。
- Candidate 必須在 review artifact 中實際 inline render，使用者能直接看到，不得以 Markdown source 或檔案存在代替視覺驗收。

## Scope

In scope：Hero visual direction、generation source strategy、candidate selection、README first-screen composition、actual visual acceptance evidence。

Out of scope：重新設計兩張 accepted architecture visuals、改 documentation authority、改 Flutter production code、改 Template → Product bootstrap contract。

## Higher-level risk considered

此工作會影響 public GitHub 第一視覺，但不改 stable architecture／repository-wide governance，因此不升 Level 3／4。若 Design 需要改 documentation ownership 或既有 architecture visual authority，必須重新 classification。
