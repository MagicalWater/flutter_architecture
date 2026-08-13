---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-37-template-to-product-repository-bootstrap-requirement
last_reviewed_baseline: 1.17.0
---

# Milestone 37 — Template-to-Product Repository Bootstrap & Adoption Governance Requirement Decision

## Request

建立一條正式、可重複、可由 fresh Agent admission 辨識的 Template → Product repository bootstrap 流程，讓 `flutter_architecture` 作為 GitHub Template Repository 建立出的新產品 repository，不需要依賴聊天記憶或使用者每次重新說明，就能正確知道自己已從模板衍生、目前是否尚未完成首次產品採用，以及完成採用後的產品 repository identity。

## Current Behavior

- GitHub repository 已由 repository owner 啟用 Template Repository，可透過 `Use this template` 建立獨立 repository。
- 現有 `adopting-template-product-identity` 只處理 Android／iOS product identity、development／staging／production display-name mapping 與 environment projection。
- `docs/guides/native_environment_adoption.md` 已有 manifest-first native adoption procedure，但假設 adopter 已知道自己正在做完整模板產品採用。
- 新 repository 從 template 建立後，`README.md`、`docs/project_context.md`、`VERSION`、roadmap 與其他 current authority 仍會描述 Flutter Enterprise Architecture Template；fresh Agent admission 因此會合理把 repository 視為模板本體，而不是尚待 bootstrap 的產品 repository。
- Repository 尚未定義 Template repository、fresh product repository、adopted product repository 三種 lifecycle state 的 canonical辨識方式。
- Repository 尚未定義 template provenance、product version 起點、template baseline 與 product version 的分離語意。
- Repository 尚未定義 first-agent admission 的最小使用者輸入與完成後 fresh-conversation acceptance contract。

## Expected Behavior

1. `flutter_architecture` 可作為 GitHub Template Repository 建立全新、無共享 commit history 的產品 repository。
2. 新產品 repository 第一次由 Agent 開啟時，可依 repository current authority 與最小使用者產品資訊正確進入 Template → Product bootstrap，而不是繼續執行模板 maintenance。
3. Bootstrap 能明確處理 repository identity 與 native product identity 的責任邊界，並重用既有 `adopting-template-product-identity`，不建立第二份 Android／iOS identity authority。
4. Bootstrap 完成後，後續全新對話只需 fresh admission，就能知道：
   - repository 是具體產品，不是 template 本體；
   - 產品名稱；
   - template origin 與 adopted baseline；
   - current product version；
   - 不應再次執行首次 Template → Product bootstrap。
5. Template baseline 與 Product version 必須有清楚且不混淆的語意。
6. 流程不得要求使用者知道 Gradle、Xcode、environment manifest、ADR、Skill 名稱或其他 repository internals。

## User Value

- 使用者可以穩定地把模板變成新產品，而不需要記住一次性的人工操作清單。
- 跨 ChatGPT conversation 不依賴模型記憶或口頭交接。
- 新產品從出生開始即有正確的 repository identity 與 provenance，避免把 Template Baseline 誤當 Product release version。
- 既有 native product identity、治理、驗證與安全 boundary 可以被重用，而不是建立平行流程。

## Classification

**Level 4 — Architecture／Milestone。**

### Evidence

- 改變 repository-wide governance 與 repository lifecycle。
- 改變 fresh Agent admission 與 current authority 的解讀方式。
- 需要定義 repository identity、template provenance、version semantics 與 Skill routing 的 stable boundary。
- 會影響未來所有由此 template 建立的產品 repository。

### Higher-Risk Signals Considered

- 不涉及 irreversible data migration、credential migration、production release pipeline 或 security-critical runtime mutation，因此不升級 Level 5。

## Scope

- GitHub Template Repository 的正式使用契約與 newcomer entry。
- Template → Product repository bootstrap lifecycle。
- First-agent admission 的最小輸入與 routing。
- Repository lifecycle state 的 authority 設計。
- Repository identity transition：template purpose → concrete product purpose。
- Template provenance 與 adopted baseline 保存方式。
- Template baseline 與 Product version 語意分離。
- 與現有 `adopting-template-product-identity` 的 delegation boundary。
- Completion／fresh-conversation acceptance contract。
- 必要的 current Guide、Skill、machine check 與 governance同步。

## Non-Goals

- 不規劃產品需求、MVP、Feature、UI／UX、Backend 或產品 roadmap。
- 不規定新產品後續功能開發順序。
- 不處理 Store distribution、production signing、keystore、Apple certificate 或 release credential custody。
- 不設計 template upstream 自動 merge／sync 機制。
- 不要求產品 repository 長期維持 Git fork 關係。
- 不為此工作重構既有 Clean Architecture、Auth、Catalog、Persistence 或 CI runtime behavior。

## Existing Authority to Reuse

- `AGENTS.md`
- `.agents/skills/governing-template-development/SKILL.md`
- `.agents/skills/adopting-template-product-identity/SKILL.md`
- `docs/governance/development_workflow.md`
- `docs/guides/agent_assisted_development_quick_start.md`
- `docs/guides/native_environment_adoption.md`
- `docs/project_context.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`
- ADR-014 / ADR-025
- `apps/flutter_architecture/config/environments.json`
- `tools/ci/verify_environment_contract.py`

## Artifact Routing

- Formal Design Spec：Required。
- Implementation Plan：Required。
- ADR gate：Required；repository lifecycle／identity／provenance 為 stable boundary，Design 必須決定新增 ADR 或更新既有 ADR 的 canonical ownership。
- Full two-layer Task governance：Required。
- Worktree／branch：Implementation 前 Required；Requirement／Design／Plan 階段依 current governance 保持 artifact-only 流程。
- Validation：Design／Plan 使用 focused docs／governance validation；implementation 後由 `validation_planner.py` 決定 Minimum Sufficient Validation，final holistic gate 依 Level 4 執行 full validation。

## Test Authoring Decision

Requirement／Design 階段不新增 production behavior test。

Implementation 階段預期會對 machine-readable lifecycle／routing／documentation contracts做 Required 或 Recommended owner 判定；不得因新增 Skill、Guide 或 metadata file 本身就機械地一檔一 test。正式 disposition 由各 implementation Task 的 Test Authoring Decision 決定。

## Decision

**Accepted — 建立 Milestone 37。**

下一步進入正式 Design，Design 必須先比較 repository lifecycle authority 的可行方案，特別是：

1. 只依既有 human-readable current authority；
2. 擴充既有 machine authority；
3. 新增極小的 repository identity／provenance manifest。

不得在 Design accepted 前開始 implementation。
