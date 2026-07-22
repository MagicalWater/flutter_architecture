---
document_type: roadmap-candidates
status: active
authoritative_for:
  - concrete-roadmap-candidates
last_reviewed_baseline: 1.6.0
---

# Roadmap Candidates

本文件保存已有明確價值與邊界、但尚未核准為 active milestone 的候選方向。

Candidate 不代表 commitment。開始 implementation 前仍需 scope review、Architecture Decision 判斷、acceptance criteria 與正式 active promotion。

Architecture Decision Record Extraction & Normalization 已提升為 Milestone 23；current status由 `docs/roadmap/active.md` 擁有，不再列為 candidate。

CI/CD Foundation已由 Milestone 24完成並封存；current capability由`docs/project_context.md`、ADR-023與final review保存，不再列為 candidate。

## Candidate — Additional Platform Support

候選範圍：iOS、Web、Windows、macOS、Linux runner、artifact 與 runtime verification。

目前狀態：這些平台只有 Dependency-ready，不得因 dependency 或 conditional implementation 存在就宣稱 Supported。

每個平台應獨立評估 scaffold、artifact、runtime smoke、plugin support 與維護成本，不建議一次綁成單一大 milestone。

## Candidate — Production Error Reporting Adapter

候選範圍：在既有 App-owned reporting boundary 上加入 production adapter，例如 Firebase Crashlytics。

前置條件：明確拍板 provider、privacy、sampling、release environment、symbol upload 與 sensitive-data policy。

目前 baseline 不包含 Firebase dependency。

## Candidate — Native Flavor and Product Identity

候選範圍：

- Android productFlavors。
- iOS Schemes。
- application ID／bundle identifier。
- 原生 App 名稱與 signing configuration。

此候選不應與 Dart environment entrypoint 混為同一 authority。

## Candidate — Documentation Knowledge Expansion

在 Milestone 22 governance foundation 穩定後，可分別評估：

- 完整 Feature 新增指南。
- 常見錯誤與除錯指南。
- Architecture evolution／migration guides。

這些屬於 guide／knowledge artifacts，不應回寫到 Current Project Context 或 Roadmap journal。

## Promotion Rule

Candidate 提升為 active 前必須：

1. 確認問題與價值。
2. 定義 scope 與 non-goals。
3. 檢查是否需要 Architecture Decision。
4. 建立 planning review 與 findings disposition。
5. 更新 `docs/roadmap.md` 與 `docs/roadmap/active.md`。

其他尚未具體化 ideas 與 explicit non-goals 繼續由 `docs/backlog.md` 保存。
