---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-38-template-product-infrastructure-ci-requirement
last_reviewed_baseline: 1.18.0
---

# Milestone 38 — Template-to-Product Repository Infrastructure & CI Adoption Governance Corrective Requirement Decision

## Request

補齊目前 Template → Product 首次採用流程的 repository infrastructure／CI 缺口，讓由 GitHub `Use this template` 建立的新產品 repository，不只完成 repository identity 與 Android／iOS product identity，也能對 CI execution mode、GitHub Actions live settings、self-hosted runner、artifact store、Branch Protection、Environment／Secrets 與 fresh CI runtime acceptance 形成可重複、可驗證、fail-closed 的正式採用流程。

## Problem

Milestone 37 已完整建立 repository lifecycle／template provenance／product version 與 native identity delegation，但其 scope 明確不承擔 GitHub repository 外部 infrastructure bootstrap。`Use this template` 會複製 `.github/workflows/**` 與 `tools/ci/**`，卻不會複製 GitHub Variables、Secrets、runner registration、Branch Protection、Actions policy 或 Environment settings。

因此新產品 repository 可能出現「CI bytes 已存在，但 repository live CI contract 尚未完成」的半採用狀態。

## Current Behavior

- `.github/workflows/ci.yml`、`android.yml`、`ios.yml`、`observability-acceptance.yml` 會隨 template bytes 複製到新產品 repository。
- Main push／trusted execution routing依 `CI_EXECUTION_MODE` 決定 `manual-local`、`self-hosted` 或 `github-hosted`；GitHub Template Repository不會複製此 repository variable。
- Self-hosted route依賴 repository-scoped runner registration與 labels；GitHub Template Repository不會複製 runner registration。
- Manual-local／self-hosted artifact ownership依 `CI_ARTIFACT_ROOT`／managed local store；預設路徑仍含 `flutter_architecture` template identity。
- `docs/guides/ci_cd_operations.md` 有 CI execution、runner、artifact、Branch Protection、Observability secrets 與 failure procedure，但 `docs/guides/template_repository_adoption.md` 未把這些列入首次 product bootstrap completion contract。
- GitHub live Actions policy、fork PR approval、Branch Protection、Environment、Secrets與repository Variables是 live settings；source bytes與docs不能宣稱它們已被新產品 repository套用。
- Public Repository Readiness 已證明 template source repository 本身需要另外做 live GitHub settings hardening；這些設定不會透過 `Use this template` 自動繼承。

## Expected Behavior

1. 新產品首次 bootstrap 必須明確產生 repository infrastructure disposition，而不是只因 workflow files存在就宣稱 CI ready。
2. Bootstrap 必須選定且驗證產品自己的 CI execution profile；未知或未決定狀態不得被解讀為已完成。
3. Self-hosted profile 必須驗證 product repository可用的runner registration、required labels、external artifact root與trusted event boundary；runner不存在時不得假裝已完成。
4. Manual-local profile 必須有產品自己的 managed artifact identity／root disposition，不得默默沿用 template-named default作為正式產品 authority。
5. GitHub-hosted profile 必須驗證 required workflows能在 product repository建立預期checks，且不需要不應存在的production signing secrets。
6. GitHub Actions policy、token permission、fork PR approval、Branch Protection／ruleset與Environment／Secrets都必須有明確 `configured`／`deferred`／`not-applicable` disposition；live mutation需權限與明確scope，完成後必須read-back。
7. Secret values、signing keys與provider config不得由template複製或寫入repository；bootstrap只治理secret names／ownership／presence與protected scope。
8. Template → Product completion 必須加入 fresh product CI/infrastructure acceptance，能證明 product repository不是只有CI檔案，而是選定profile的最小runtime route實際可用。
9. 不破壞 Milestone 37 的 repository lifecycle authority，也不建立第二份CI execution engine或native identity authority。

## Value

- 使用者從 template 建立新產品後，不需要另靠記憶補 GitHub Variables、runner、artifact root與repository settings。
- 避免 workflow存在但main CI實際未啟用、self-hosted永遠queued、artifact寫回template-named store等隱性缺陷。
- 讓 public／private product repository都能在自身安全需求下有明確fork PR、Secrets、Actions與Branch Protection disposition。
- 保留 CI profile彈性，同時讓「未設定」與「刻意選擇manual-local」不再混為同一狀態。

## Classification

**Level 5 — Critical。**

### Evidence

- 改變所有未來 product repository 的首次 bootstrap completion contract。
- 涉及 GitHub live settings、self-hosted runner trust boundary、fork PR execution與secret-consuming workflow。
- 涉及 CI execution routing、artifact ownership與repository security settings。
- 需要 compatibility／failure injection／remote read-back／platform CI evidence與release/post-release closure。

### Lower-Level Rejection

不能只把問題當成Guide缺字或Level 4一般治理，因為若只更新文件而沒有machine/runtime acceptance，仍無法防止新產品在live GitHub settings缺失時被錯誤宣告完成。

## Decision

**Accept — 建立 Milestone 38。**

## Scope

- Template → Product首次 adoption中的 repository infrastructure admission／completion contract。
- CI profile selection與machine-readable disposition。
- `CI_EXECUTION_MODE` product bootstrap／verification contract。
- Product-specific managed artifact root／identity contract。
- Self-hosted runner registration／label／trust／offline behavior disposition。
- GitHub-hosted CI readiness disposition。
- Actions policy、token permission、fork PR approval、Branch Protection／ruleset disposition。
- GitHub Environment／Secrets presence與ownership disposition；不讀取／不複製secret values。
- Bootstrap fresh remote/live read-back與minimum CI runtime acceptance。
- Milestone 37／ADR-030與ADR-023 boundary整合。
- Required machine regression owners、Guides、Skills與current authority同步。

## Non-goals

- 不建立 production signing pipeline、Play Store／App Store distribution或release credential custody。
- 不自動建立或複製 Firebase／Apple／Google／GitHub secret values。
- 不要求所有產品使用同一種 CI execution mode。
- 不要求所有產品使用 self-hosted runner。
- 不替產品決定團隊 approval人數或商業 release policy。
- 不建立 template upstream auto-sync／remote updater。
- 不改變 Flutter runtime feature architecture。

## Behavioral requirements required

Required。

## Design Spec required

Required。

## Implementation Plan required

Required。

## ADR required

Required。Design必須決定新增ADR-031或調整ADR-023／ADR-030的stable ownership；不得把live procedure塞回既有ADR造成責任混淆。

## Task governance mode

Full-critical two-layer Task governance。

## Worktree／branch

Required。Planning與後續implementation使用managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-d0e38710
branch: milestone-38-template-product-infrastructure-ci
base: origin/main@c5f76cea592e81c0c4df6218ea080a23c1f1b372
```

## Regression level

Full＋compatibility／remote GitHub settings／CI runtime／platform evidence。

## Release required

Required。Milestone completion需新的Template Baseline release；exact version由accepted Plan／release gate決定，不在Requirement Decision先猜測。

## Post-release validation

Required。至少包含published-main clean checkout、template identity、fresh isolated product bootstrap與remote CI/settings acceptance。

## Required Superpowers skills

- `brainstorming`：Design。
- `writing-plans`：Design accepted後。
- `test-driven-development`：依每個observable contract的Test Authoring Decision使用。
- `systematic-debugging`：unexpected CI/settings behavior。
- `verification-before-completion`：Task／Milestone gate。
- `finishing-a-development-branch`：release／integration；不得提前宣稱closure。

目前DevSpace診斷顯示既有Superpowers plugin path缺失；這是執行環境的Skill discovery warning，不改變repository routing contract。Design artifact可先建立為`proposed`，但在未滿足所需workflow方法與完整Design gate前不得轉為`accepted`或開始Plan／implementation。

## Required artifacts

- 本 Requirement Decision。
- Formal Design Spec。
- Design Task review evidence。
- 使用者Design核准。
- Formal Implementation Plan與Plan review。
- ADR gate artifact。
- Per-Task review／validation evidence。
- Holistic final review、release與post-release evidence。

