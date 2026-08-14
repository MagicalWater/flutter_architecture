---
document_type: planning-review
status: accepted
authoritative_for:
  - public-repository-readiness-requirement
last_reviewed_baseline: 1.17.0
---

# Public Repository Readiness — Requirement Decision

## Requirement Decision

- Request（需求）：在不干擾目前其他平行需求的前提下，使用獨立 managed worktree，依公開 repository 前的建議清理事項完成必要 hardening，讓 `MagicalWater/flutter_architecture` 可在後續人工切換為 Public 前具備合理的 privacy、secret 與 CI 安全基線。
- Problem（問題）：目前沒有發現已提交的真實 credential，但 `.gitignore` 對常見 private configuration／signing material 的防呆不足；current reusable guides 仍可能含 operator-specific absolute path；repository 同時具有 GitHub Actions、Firebase repository secrets 與 self-hosted runner 路徑，因此 Public 後需要重新確認 fork／PR trust boundary。
- Current behavior（目前行為）：Git history 會公開 commit author email，使用者已明確接受 `crazydennies@gmail.com` 公開；historical audit evidence 含 `crazy`、`water` 與 local absolute paths；PR workflow目前可見設計為 GitHub-hosted／PR-safe，而 privileged Firebase secret jobs與 self-hosted routes主要受 `workflow_dispatch`／trusted push gate 控制。
- Expected behavior（預期行為）：保留具有 audit traceability 的歷史 evidence，不因美觀重寫 Git history；補強未來 secret／signing/provider config 的提交防呆；current reusable guides 不把個人 filesystem layout 當成通用操作契約；Public repository 的 fork／PR 不得取得 repository secrets、privileged environment 或執行不可信 PR code於 trusted self-hosted runner；以可重複 scanner／contract validation證明 readiness。
- Value（價值）：降低 Public 後 credential 誤提交與不可信 PR 取得高權限 execution boundary 的風險，同時避免無必要的大規模歷史清洗與 SHA rewrite。
- Classification（分類）：Level 5 — Critical / Security。Security boundary、GitHub Actions trust boundary 與 self-hosted runner exposure 皆屬最高適用風險；即使實際 source diff 最後很小，也不得以檔案數降級。
- Decision（決策）：Accept with reduced scope。
- Scope（範圍）：secret/history scanner；tracked sensitive filename／provider config review；`.gitignore` hardening；current reusable guide/operator path sanitation；GitHub Actions fork／PR／secrets／self-hosted runner trust-boundary review與必要的最小修正；相關 regression contract；public-readiness review evidence。
- Non-goals（非目標）：不切換 GitHub repository visibility；不修改或刪除 historical audit evidence 只為隱藏 `crazy`／`water`；不 rewrite Git history；不更換已接受公開的 commit author email；不旋轉目前未發現已洩漏的 secrets；不把本工作擴張成 Milestone 37 Template-to-Product bootstrap implementation；不修改產品功能。
- Behavioral requirements required（是否需要行為需求）：是，public fork／PR、secret exclusion與operator-neutral guide contract可觀察且可驗證。
- Design Spec required（是否需要 Design Spec）：是。
- Implementation Plan required（是否需要 Implementation Plan）：是。
- ADR required（是否需要 ADR）：Conditional；只有修改 stable CI/security ownership 或 trust model 才新增／更新 ADR。若只是 hardening 現有 contract，不新增平行 authority。
- Task governance mode（Task 治理模式）：Full-critical，Design／Plan／implementation units各自完整雙層 Task gate。
- Worktree／branch：`C:\Users\crazy\.devspace\worktrees\flutter_architecture-56ee2db1`，由 `main@d575a7ff9f8d2cd63dbb0844fc535c4f4dfaa5b7` 建立的 managed detached worktree；不得碰 source checkout 的平行修改。
- Regression level（Regression 等級）：由 `tools/ci/validation_planner.py` 對實際 changed range 選擇；security trust-boundary contract另要求 focused failure-path validation，final readiness review需 clean worktree evidence。不得把 full suite 當每個 Task 固定預設。
- Release required（是否需要發布）：否；本次只建立 Public readiness hardening，不變更 Template Baseline 或 GitHub visibility。
- Post-release validation（發布後驗證）：不適用 release；但在未來真正切換 Public 前，仍需 fresh GitHub repository settings／fork PR policy確認。
- Required Superpowers skills（必要 Superpowers Skills）：中央治理所要求的 Design／Plan／verification workflow；production code／CI implementation若發生，搭配 `karpathy-guidelines`。不觸發產品 identity 或 Pencil workflow。
- Required artifacts（必要 artifacts）：本 Requirement Decision、Design Spec、Implementation Plan、Design／Plan review evidence、implementation review evidence、final Public readiness review。

## Admission Evidence

- Source checkout 在建立 worktree 時為 dirty，故本工作已隔離至 managed worktree；不得直接修改 `D:\Developer\flutter_architecture`。
- Root `VERSION`：`1.17.0`。
- Current roadmap另有 Milestone 37 Planning 工作；本 corrective 不宣稱取代、完成或修改其 accepted Design／proposed Plan。
- Current repository scan 未發現 tracked `.env`、keystore、`.p12/.pfx/.pem`、`google-services.json`、`GoogleService-Info.plist` 或 service-account file。
- Token／private-key pattern命中目前確認為 security regression fixtures，不是已確認的真實 credential。
- 使用者已明確接受 Git history 中 `crazydennies@gmail.com` 公開。

