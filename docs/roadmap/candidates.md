---
document_type: roadmap-candidates
status: active
authoritative_for:
  - concrete-roadmap-candidates
last_reviewed_baseline: 1.13.0
---

# Roadmap Candidates

本文件保存已有明確價值與邊界、但尚未核准為 active milestone 的候選方向。

Candidate 不代表 commitment。開始 implementation 前仍需 scope review、Architecture Decision 判斷、acceptance criteria 與正式 active promotion。

## Candidate — Additional Platform Support

候選範圍：Web、Windows、macOS、Linux runner、artifact 與 runtime verification。

目前狀態：Android與iOS均為Supported；Web、Windows、macOS與Linux仍只有Dependency-ready，不得因dependency或conditional implementation存在就宣稱Supported。

每個平台應獨立評估 scaffold、artifact、runtime smoke、plugin support 與維護成本，不建議一次綁成單一大 milestone。

## Candidate — Proposed Milestone 32：CI產物本機化與GitHub儲存空間切換

目前GitHub私有repository的Actions分鐘與儲存空間已達限制。Repository雖已提供`manual-local`、`self-hosted`與`github-hosted`三種execution mode，但`self-hosted`只避免GitHub-hosted runner分鐘；workflow中的`actions/upload-artifact`仍會把Android、iOS、Observability與failure evidence上傳到GitHub Actions storage。

2026-07-30的候選前盤點已確認repository variable為`self-hosted`，且GitHub artifacts與caches均已形成顯著storage壓力。精確數量、bytes、最大來源與可變性限制只由`docs/audits/ci_artifact_storage_cutover_candidate_handoff.md`保存；正式Design前必須重新查詢。

候選目標：

- 將一般CI、Android／iOS verification artifacts與診斷產物的主要ownership切換到本機或trusted self-hosted Mac。
- 保留GitHub Actions作為workflow控制面、manual dispatch、status與未來偶發GitHub-hosted驗證入口。
- 為本機artifact建立commit identity、metadata、retention、容量上限、cleanup與failure evidence規則。
- 在新本機路線取得runtime acceptance後，才依核准的cleanup manifest刪除既有GitHub artifacts與caches。

Design必須先拍板：

1. Repository預設使用`manual-local`或`self-hosted`。
2. 本機artifact root、worktree隔離與commit SHA目錄結構。
3. 成功、失敗、Observability與正式release evidence的retention差異。
4. Self-hosted模式是否完全禁止`upload-artifact`，以及GitHub job summary要保存哪些可追溯資訊。
5. `github-hosted`手動例外模式是否仍允許cache與artifact upload。
6. Branch Protection與required checks在manual-local／self-hosted下的可信語意。
7. GitHub artifacts／caches的封存、刪除manifest、rollback與清理後驗證。

非目標：

- 不移除`.github/workflows/`。
- 不把credential、keystore、Apple private key或Firebase service account寫入repository。
- 不在未確認本機方案不足前導入R2、S3、NAS或新的雲端artifact服務。
- 不處理production signing、Store distribution或Flutter產品功能。

目前狀態：Candidate only。`Milestone 32`編號與名稱仍是proposed；尚未建立active Milestone、Design Spec、Implementation Plan、branch或implementation。完整候選審查與跨對話handoff見`docs/audits/ci_artifact_storage_cutover_candidate_handoff.md`。

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
