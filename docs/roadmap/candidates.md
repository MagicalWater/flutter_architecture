---
document_type: roadmap-candidates
status: active
authoritative_for:
  - concrete-roadmap-candidates
last_reviewed_baseline: 1.21.0
---

# Roadmap Candidates

本文件保存已有明確價值與邊界、但尚未核准為 active milestone 的候選方向。

Candidate 不代表 commitment。開始 implementation 前仍需 scope review、Architecture Decision 判斷、acceptance criteria 與正式 active promotion。

## Candidate — Milestone 43 / Flutter Presentation Component Architecture & UI Responsibility Governance

候選問題：目前 repository 已有 Feature First、Clean Architecture、Bloc cross-feature boundary，以及 Milestone 42 建立的 UI Design Ownership Architecture；但通用 Presentation layer 對 `Page`、`View`、screen section、feature component、Dialog／BottomSheet／Overlay、layout/controller、ephemeral UI state 與 compilation-unit cohesion 尚未形成完整 repository-wide contract。

候選目標：建立 responsibility-based Presentation Component Architecture，使「同屬 Presentation layer」不再成為把大量獨立 UI responsibility 塞進同一 page/file 的理由，同時避免反方向採用 one-class-one-file、line-count hard limit 或為 static UI 強造 Bloc 的形式主義。

至少需要評估：

- Page／View／Section／Component／Dialog／BottomSheet／Overlay／Layout／Controller 的責任與 dependency boundary；
- business／screen workflow state 與 ephemeral UI state 的 Bloc／Cubit／Hook／local controller ownership；
- `one file = one coherent primary responsibility`，允許同 responsibility 的 private helper classes，但拒絕多個 independently reviewable change reasons 的 monolith；
- feature-local component → Design System promotion 與 Milestone 42 UI Design Ownership Architecture 的銜接；
- repository-wide review／behavioral pressure，不能只靠 Pencil-specific detector。

Non-goals：不預設每個 feature 必須建立所有資料夾；不要求每 widget 一檔；不以行數／class 數作 architecture oracle；不在 candidate 階段修改 production source。

## Candidate — Additional Platform Support

候選範圍：Web、Windows、macOS、Linux runner、artifact 與 runtime verification。

目前狀態：Android與iOS均為Supported；Web、Windows、macOS與Linux仍只有Dependency-ready，不得因dependency或conditional implementation存在就宣稱Supported。

每個平台應獨立評估 scaffold、artifact、runtime smoke、plugin support 與維護成本，不建議一次綁成單一大 milestone。

## Disposition — Documentation Knowledge Expansion

此大型文件擴張方向不再列為 candidate。

已接受的 Documentation Usability & Coverage Audit 確認，當時缺口集中在少量 navigation、task route 與 stale placeholder，不足以支持大型 Milestone、通用 Troubleshooting Guide 或 Architecture Evolution handbook。

已確認的缺口已由有界的 Documentation Usability Hardening design 與 implementation plan 處理，不形成開放式 knowledge expansion commitment。

未來若要重新提出大型文件擴張，必須先提供新的可驗證 evidence、明確 scope／non-goals 與獨立 candidate review，不得只因文件數量增加或既有 metadata baseline 較舊而重新啟動。

Evidence：

- `docs/audits/documentation_usability_coverage_audit.md`
- `docs/audits/documentation_usability_coverage_audit_review.md`
- `docs/superpowers/specs/2026-07-23-documentation-usability-hardening-design.md`
- `docs/superpowers/plans/2026-07-23-documentation-usability-hardening.md`

## Promotion Rule

Candidate 提升為 active 前必須：

1. 確認問題與價值。
2. 定義 scope 與 non-goals。
3. 檢查是否需要 Architecture Decision。
4. 建立 planning review 與 findings disposition。
5. 更新 `docs/roadmap.md` 與 `docs/roadmap/active.md`。

其他尚未具體化 ideas 與 explicit non-goals 繼續由 `docs/backlog.md` 保存。
