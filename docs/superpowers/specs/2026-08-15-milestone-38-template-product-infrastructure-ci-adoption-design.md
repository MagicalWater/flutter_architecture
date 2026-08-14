---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-38-template-product-infrastructure-ci-adoption-design
last_reviewed_baseline: 1.18.0
---

# Milestone 38 — Template-to-Product Repository Infrastructure & CI Adoption Governance Corrective Design

## 1. Goal

把 Milestone 37 已完成的「repository identity出生流程」延伸為真正可交付的新產品 repository bootstrap：除了知道自己是product、版本與native identity正確之外，也必須知道自己的CI怎麼跑、GitHub live settings處於什麼狀態、runner與artifact由誰擁有，以及哪些secret-backed能力已配置或被明確defer。

本Design不把所有產品強迫成同一CI拓樸；它建立的是**profile + disposition + verification** contract。

## 2. Problem Statement

`Use this template`只複製Git bytes，不複製GitHub Variables、Secrets、Environments、runner registrations、Actions settings或Branch Protection。Current Template Adoption completion contract只驗repository identity／docs／native identity，因此可能在以下狀態錯誤完成：

```txt
workflow files present
CI_EXECUTION_MODE missing
self-hosted runner missing
artifact root still template-named
GitHub live security settings unknown
↓
repository_kind = product
↓
fresh Agent sees "bootstrap completed"
```

這不是production runtime bug，而是repository birth contract缺失。

## 3. Design Principles

### 3.1 Repository bytes 與 live infrastructure 分離

Machine authority必須明確區分：

```txt
Tracked repository contract
→ workflows / tools / policy / expected settings

Live repository state
→ GitHub Variables / Actions settings / branch protection / runners / environments
```

Tracked files不能宣稱live settings已完成；live mutation完成後必須fresh read-back。

### 3.2 不把 GitHub infrastructure 塞進 repository_identity.json

`repository_identity.json`繼續只擁有：

```txt
template | product
product name
template provenance
```

CI profile、runner、Branch Protection與secret disposition屬repository operations authority，避免把lifecycle manifest擴張成萬用設定檔。

### 3.3 Profile不是「預設猜測」

首次產品bootstrap必須明確選擇一個CI profile：

```txt
manual-local
self-hosted
github-hosted
```

若使用者未指定，Agent可依現有template與使用情境提出建議，但在live mutation或final infrastructure completion前必須取得明確disposition。`CI_EXECUTION_MODE` missing不能被當成manual-local shorthand。

### 3.4 Secrets只治理presence與ownership，不搬運value

Bootstrap可以：

- 檢查secret／environment name是否存在；
- 建議建立protected Environment；
- 記錄`configured`／`deferred`；
- 驗證PR不會讀secret。

Bootstrap不得：

- 從template讀取secret values；
- 複製service account、keystore、certificate、private key；
- 把secret value寫入tracked file、artifact、log或handoff。

### 3.5 Completion是capability-specific，不要求所有optional能力都配置

新產品不必為了完成bootstrap就配置Firebase Observability或self-hosted runner。每個optional capability必須有顯式disposition：

```txt
configured
deferred
not-applicable
```

只有選定的required profile與required safety settings才是blocking。

## 4. Repository Infrastructure Adoption Manifest

### 4.1 Decision

新增一個極小、tracked、non-secret machine-readable manifest：

```txt
repository_infrastructure.json
```

它不保存live credential或GitHub object IDs，只保存產品repository對infrastructure的**desired/disposition state**。

### 4.2 Proposed schema

```json
{
  "schema_version": 1,
  "ci_execution_mode": "manual-local",
  "artifact_store": {
    "strategy": "managed-local",
    "product_key": "pickup-basketball"
  },
  "self_hosted_runner": {
    "disposition": "not-applicable"
  },
  "github": {
    "actions_policy": "managed",
    "branch_protection": "configured",
    "fork_pr_policy": "configured"
  },
  "observability_remote_acceptance": {
    "disposition": "deferred"
  }
}
```

Exact enum／field set由implementation RED tests收斂；Design只固定ownership與不含secret的原則。

### 4.3 Why a manifest

只靠Guide有三個問題：

1. Fresh Agent無法分辨「忘了設定」與「刻意defer」。
2. Machine verifier無法阻止`CI_EXECUTION_MODE`與產品意圖漂移。
3. Product artifact store identity無穩定input，只能硬編template名稱或依folder猜測。

### 4.4 Non-goals

Manifest不保存：

- runner token／registration token；
- secret value；
- service account JSON；
- Apple／Android signing material；
- GitHub API token；
- exact external absolute path；
- GitHub numeric repository／environment／runner IDs；
- release signing／Store distribution state。

## 5. CI Profile Contract

### 5.1 manual-local

Required：

- `CI_EXECUTION_MODE=manual-local` live repository variable或等價明確repository default disposition；
- product-owned managed artifact root可解析；
- `run_local_ci.sh plan-range`與至少quality representative route可執行；
- GitHub PR-safe behavior依public/private repository policy明確驗證，不因manual-local而意外進trusted runner。

### 5.2 self-hosted

Required：

- `CI_EXECUTION_MODE=self-hosted`；
- 至少一個product repository可用runner符合required trusted labels；
- external `CI_ARTIFACT_ROOT`存在且不在checkout／runner temp／home root；
- PR不能選到trusted self-hosted runner；
- main／manual trusted run有fresh runtime acceptance；
- offline runner行為明確為queued／blocked，不fallback到付費runner。

### 5.3 github-hosted

Required：

- `CI_EXECUTION_MODE=github-hosted`；
- PR／main representative workflow能建立預期jobs；
- required direct Actions refs符合repository security contract；
-不依賴production signing secrets完成repository verification build；
- artifact transport default仍為`none`，除非manual run明確選擇有界transport。

## 6. Product-owned Artifact Identity

Current code以`flutter_architecture`形成manual-local default path。Milestone 38應把default root identity改成由tracked product infrastructure authority取得stable `product_key`，而不是folder name或Git remote猜測。

概念：

```txt
template repository
→ product_key = flutter_architecture

adopted product repository
→ product_key = pickup-basketball

Windows
→ %LOCALAPPDATA%/<product_key>/ci-artifacts

POSIX
→ ${XDG_STATE_HOME:-$HOME/.local/state}/<product_key>/ci-artifacts
```

Explicit `CI_ARTIFACT_ROOT`仍優先；self-hosted仍要求explicit external absolute root並fail closed。

## 7. GitHub Live Settings Contract

### 7.1 Admission first

Bootstrap對GitHub live settings的順序：

```txt
detect remote/repository
→ verify authenticated management capability
→ read current settings
→ compare with selected profile + security baseline
→ propose/apply only authorized mutations
→ fresh read-back
→ record evidence
```

沒有權限或repository尚未建立remote時，不得猜測或宣稱configured；該Task維持blocked／deferred，repository identity可否finalize由accepted Plan定義atomic boundary。

### 7.2 Actions security baseline

Tracked repository contract至少要求：

- default `GITHUB_TOKEN` read-only；
- `can_approve_pull_request_reviews=false`；
- repository-owned direct third-party `uses:` immutable full SHA；
-不使用`pull_request_target`處理untrusted code；
- public PR不得進trusted self-hosted runner；
- selected-actions／allowlist policy依repository visibility與current compatibility採profile disposition，不把template source repo的live setting盲目複製。

### 7.3 Branch protection profile

Design不強迫單一policy，但至少提供：

```txt
minimum-safety
team-protected-main
explicit-deferred
```

`minimum-safety`至少禁止force push與branch deletion。

`team-protected-main`可再要求PR、approvals、conversation resolution與required checks，但required check names必須先用fresh product workflow evidence確認會在對應event建立run。

## 8. Environment / Secret Disposition

`staging-observability`等secret-backed capability以capability disposition管理。

Configured時驗證：

- Environment存在；
- required secret **names**存在；
- workflow只在explicit trusted manual path讀取；
- PR-safe path不讀secret；
- cleanup contract仍存在。

Deferred時：

- secret names可以不存在；
- remote acceptance job必須安全skip；
- docs/current authority明確說明尚未配置，而不是「應該有」。

## 9. Bootstrap Orchestration Integration

Milestone 37流程調整為：

```txt
template identity admission
→ confirm product identity inputs
→ repository docs/version/native candidate mutations
→ infrastructure manifest/profile selection
→ tracked docs/native/CI contract validation
→ live GitHub/settings/runner disposition
→ selected profile runtime acceptance
→ prospective product identity validation
→ final repository_kind = product
→ canonical docs + infrastructure + identity re-validation
→ fresh no-handoff Agent acceptance
```

是否允許「GitHub live settings explicit-deferred但仍finalize product」由capability required/optional classification決定；selected CI execution profile本身不得defer。

## 10. Machine Verification

新增或擴充machine owners：

```txt
tools/docs/verify_repository_infrastructure.py
tools/docs/test_repository_infrastructure.py
tools/docs/test_template_repository_bootstrap_*.py
tools/ci/test_*profile/security/artifact contracts
```

Verifier至少檢查：

- manifest schema／enum fail closed；
- selected CI mode與tracked workflow contract一致；
- product key安全且不由folder／remote推導；
- product state不能保留未處置的selected-profile placeholder；
- self-hosted selected時runner disposition不能是not-applicable；
- secret-backed capabilities不含secret values；
- template state仍有合法template infrastructure defaults。

## 11. Test Authoring Strategy

### Required direct owners

- missing／unknown infrastructure manifest fail-closed；
- CI mode／manifest mismatch；
- product artifact key projection；
- self-hosted selected但runner disposition缺失；
- public PR不能選trusted self-hosted；
- GitHub settings read-back mismatch；
- bootstrap不能在selected profile未達required acceptance時finalize product；
- secret fields／secret-looking payload不得進manifest/evidence。

### Should-not-add

- 每個JSON field一個getter test；
- 每個Guide bullet snapshot test；
- 重複既有Android／iOS native mapping tests；
- 為每個GitHub setting寫無語意的存在性test。

## 12. ADR Ownership

建議新增：

```txt
ADR-031 — Template-to-Product Repository Infrastructure Adoption Contract
```

ADR-031擁有：

- tracked desired/disposition infrastructure authority；
- CI profile selection語意；
- live state read-back原則；
- artifact product identity；
- optional capability disposition；
- template bootstrap completion與infrastructure acceptance的stable boundary。

ADR-023繼續擁有CI runtime quality gates／execution／artifact security contract；ADR-030繼續擁有repository lifecycle／provenance／product version。三者互相關聯但不互相取代。

## 13. Rollback / Recovery

- 在final product transition前任何infrastructure failure：canonical `repository_kind`保持`template`。
- Live GitHub settings mutation必須保存before／after read-back；可逆設定提供explicit recovery procedure。
- Runner registration失敗不得刪除其他repository runner或更改全域runner設定。
- Secret／Environment mutation不得刪除或旋轉既有secret values；本Milestone不擁有credential rotation。
- 已完成product bootstrap後發現Milestone 38 defect，不自動遠端更新既有products；template發布corrective baseline，由各product依自己的Requirement Decision採用。

## 14. Acceptance Matrix

至少驗證三種isolated product bootstrap：

| Scenario | CI profile | Expected |
|---|---|---|
| Windows solo/local | manual-local | product artifact identity + local quality route PASS |
| Trusted Mac runner product | self-hosted | runner labels/root/main route PASS；PR denial PASS |
| Clean remote product | github-hosted | GitHub-hosted PR/main representative checks PASS |

另有negative corpus：

- missing variable；
- unknown CI mode；
- self-hosted without runner；
- artifact root inside checkout；
- branch protection required check不存在；
- secret-shaped manifest content；
- GitHub permission不足／read-back mismatch；
- public PR attempted trusted-runner routing。

## 15. Completion Criteria

Design只有在以下條件成立後才可被接受：

- repository lifecycle、CI runtime與live GitHub settings ownership沒有重疊；
- selected CI profile有blocking acceptance；
- optional secrets／observability能力可安全defer；
- product artifact identity不再硬編template name；
- self-hosted/public PR trust boundary明確；
- live mutation需要authorization＋read-back；
- rollback／failure injection／platform compatibility已被納入；
- 不引入production signing／Store distribution scope。

