---
document_type: roadmap-candidates
status: active
authoritative_for:
  - concrete-roadmap-candidates
last_reviewed_baseline: 1.8.0
---

# Roadmap Candidates

本文件保存已有明確價值與邊界、但尚未核准為 active milestone 的候選方向。

Candidate 不代表 commitment。開始 implementation 前仍需 scope review、Architecture Decision 判斷、acceptance criteria 與正式 active promotion。

Architecture Decision Record Extraction & Normalization 已提升為 Milestone 23；current status由 `docs/roadmap/active.md` 擁有，不再列為 candidate。

CI/CD Foundation已由 Milestone 24完成並封存；current capability由`docs/project_context.md`、ADR-023與final review保存，不再列為 candidate。

## Candidate — Additional Platform Support

候選範圍：Web、Windows、macOS、Linux runner、artifact 與 runtime verification。

目前狀態：Android與iOS均為Supported；Web、Windows、macOS與Linux仍只有Dependency-ready，不得因dependency或conditional implementation存在就宣稱Supported。

每個平台應獨立評估 scaffold、artifact、runtime smoke、plugin support 與維護成本，不建議一次綁成單一大 milestone。

## Candidate — Production Error Reporting Adapter

候選範圍：在既有 App-owned reporting boundary 上加入 production adapter，例如 Firebase Crashlytics。

前置條件：明確拍板 provider、privacy、sampling、release environment、symbol upload 與 sensitive-data policy。

目前 baseline 不包含 Firebase dependency。

Native Flavor and Product Identity已提升為Milestone 26；current scope與next action由`docs/roadmap/active.md`擁有，不再列為candidate。

## Disposition — Documentation Knowledge Expansion

大型 Documentation Knowledge Expansion 不再列為 candidate。

已接受的 Documentation Usability & Coverage Audit 確認，目前缺口集中在少量 navigation、task route 與 stale placeholder，不足以支持大型 Milestone、通用 Troubleshooting Guide 或 Architecture Evolution handbook。

已確認的缺口由有界的 Documentation Usability Hardening design 與 implementation plan 處理，不建立 Milestone 27，也不形成開放式 knowledge expansion commitment。

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
