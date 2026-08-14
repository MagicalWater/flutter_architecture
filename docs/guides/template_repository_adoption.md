---
document_type: guide
status: active
authoritative_for:
  - template-repository-product-adoption-procedure
last_reviewed_baseline: 1.18.0
---

# Template Repository Adoption Guide

## Purpose

本指南只回答一件事：**如何從 `flutter_architecture` GitHub Template Repository 建立一個新的獨立產品 repository，並讓第一次與後續 fresh Agent 都能自行辨識它的 repository identity。**

本指南不規劃產品 MVP、Feature、UI／UX、backend或產品 roadmap。

Stable lifecycle decision 由 [ADR-030](../adr/adr-030-template-to-product-repository-identity-bootstrap-contract.md) 擁有；repository infrastructure adoption boundary由[ADR-031](../adr/adr-031-template-to-product-repository-infrastructure-adoption-contract.md)擁有。Machine state分別由root `repository_identity.json`與`repository_infrastructure.json`擁有。

## 1. 從 GitHub Template Repository 建立新 repository

在 `MagicalWater/flutter_architecture` repository 使用 GitHub `Use this template` 建立新的產品 repository。

正常產品起點使用 template 的 default branch 即可；不要以 Fork 作為一般產品 birth path，也不要把新產品 repository 當成需要長期 merge template `main` 的 fork。

建立完成後 clone **新的產品 repository** 到本機。Bootstrap mutation 必須在新 repository 內執行，不得回頭把產品資料寫進 `flutter_architecture` template 本體。

## 2. 第一次 Agent prompt 最少需要提供什麼

使用者不需要知道 repository-local Skill 名稱，也不需要在 prompt 重貼治理流程。

最小輸入：

```txt
@bridge-win 請開啟：
D:\Developer\pickup-basketball

這是剛從 flutter_architecture template 建立的新產品 repository。

產品名稱：找團體打籃球
Base identifier：com.mgwater.pickupbasketball
```

Fresh Agent 必須從 repository current authority 自行 admission，讀取 `repository_identity.json`，再由 `governing-template-development` 完成 Requirement Decision。只有 `repository_kind = template` 且需求確實是首次產品採用時，才路由 `adopting-template-repository`。

## 3. Mutation 前仍需明確確認的值

Bootstrap 不得猜測 base identifier。

若使用者只提供產品名稱與 base identifier，Agent 可以提出下列顯示名稱候選：

```txt
Development display name
Staging display name
Production display name
```

但在 native identity mutation 前必須取得使用者確認。

預設 product repository version 起點是：

```txt
0.1.0
```

若產品已有自己的 version policy，必須在首次 bootstrap Requirement Decision 明確指定 override。

首次bootstrap還必須明確選定一個CI profile，不能從template repository目前的GitHub settings、runner或workflow execution history猜測：

```txt
manual-local
self-hosted
github-hosted
```

這個profile是blocking bootstrap input。Optional observability等provider capability可以明確`deferred`，但selected CI profile本身不能defer。

## 4. Repository-level bootstrap 會改什麼

首次 bootstrap 會把「模板 repository 的 current authority」轉成「產品 repository 的 current authority」，至少包含：

```txt
repository_identity.json
repository_infrastructure.json
VERSION
README.md
docs/project_context.md
docs/roadmap.md
docs/roadmap/active.md
CHANGELOG.md
```

完成後：

- `repository_kind = product`；
- `product_name` 是已確認產品名稱；
- `template_origin` 永久保存來源 repository 與採用時 Template Baseline；
- root `VERSION` 只表示產品 repository current version；
- README／project context／roadmap 不再把 current repository 描述成 template 本體。
- `repository_infrastructure.json`保存selected CI profile、managed artifact product key與GitHub／optional capability的desired/disposition state。

這個 transition 不會替產品建立 MVP、Feature清單或產品 roadmap內容；product roadmap只建立最小 product-owned current state，後續由產品自己的需求決策處理。

## 5. Native Android／iOS identity 是 subordinate procedure

如果首次 bootstrap scope 包含 Android／iOS application／bundle identity 與 development／staging／production display names，repository bootstrap 會委派：

```txt
adopting-template-product-identity
```

Native mapping authority、manifest-first replacement order、exact build／verification commands與secret boundary全部以 [Native Environment and Product Identity Adoption Guide](native_environment_adoption.md) 為準。

`repository_identity.json` 不保存 bundle identifier、API domain或environment mapping。

## 6. `Use this template`只複製tracked bytes，不複製live GitHub state

GitHub Template Repository會把tracked repository bytes建立到新repository，但下列live state必須在**新產品repository**另外admit／configure／read-back：

```txt
CI_EXECUTION_MODE repository variable
Actions policy / default token permissions
fork PR approval policy（適用時）
main Branch Protection
self-hosted runner registration / labels / online state
GitHub Environments
Environment / repository secret names presence
```

Workflow YAML存在不代表這些live settings已存在；template repository目前有runner或secret也不代表new product repository繼承它們。Agent不得從tracked bytes推測live state為`configured`。

Secret value永遠不屬於bootstrap copy範圍：

- 不把template repository的secret value讀出、複製、寫進文件、manifest或log；
- machine/read-back evidence只允許保存required secret **name是否存在**與disposition；
- runner registration token、Apple/Android signing material、service account credential等都不得落入tracked evidence。

## 7. 三種CI profile decision checklist

### `manual-local`

選擇條件：希望GitHub execution jobs預設skip，由operator在可信任本機執行repository-owned CI入口。

完成前至少確認：

- `repository_infrastructure.json`的`ci_execution_mode = manual-local`；
- 新repository live `CI_EXECUTION_MODE` fresh read-back為`manual-local`；若permission／external blocker使required read-back無法完成，只能記錄blocked evidence並保持`repository_kind=template`，不得以blocker取代selected-profile acceptance；
- managed artifact `product_key`已從template identity產品化；
- local `plan-range`與代表性quality route可執行；
- 不把「GitHub jobs skipped」解讀為遠端CI PASS。

### `self-hosted`

選擇條件：可信任main/manual工作要由repository-scoped Mac runner執行，而且團隊願意維護runner lifecycle。

完成前至少確認：

- live `CI_EXECUTION_MODE = self-hosted`；
- repository-scoped runner存在、online且labels符合current workflow contract；
- `CI_ARTIFACT_ROOT`是checkout外安全absolute path；
- untrusted/public PR不能派送到trusted self-hosted runner；
- runner offline時應queued/blocked，不允許隱式fallback `github-hosted`。

### `github-hosted`

選擇條件：希望PR/main verification使用GitHub提供的runner並接受對應Actions quota/cost。

完成前至少確認：

- live `CI_EXECUTION_MODE = github-hosted`；
- representative PR/main workflow fresh evidence會建立預期GitHub-hosted jobs；
- default token permissions維持current read-only安全contract；
- artifact transport預設仍是`none`；
- verification不需要production signing secret即可完成。

## 8. GitHub live disposition與read-back規則

首次adoption必須對live state保存明確disposition，而不是只記「預計要設定」。

Branch Protection使用：

```txt
minimum-safety
team-protected-main
explicit-deferred
```

Environment／secret-backed optional capability使用：

```txt
configured
deferred
not-applicable
```

任何live mutation都必須：

```txt
read before state
→ 執行已核准且可逆／安全的mutation
→ fresh read-back
→ compare expected
```

Permission不足、HTTP 403、runner offline、read-back mismatch都不能被標成`configured`。Required checks也不得只因workflow檔中「看得到job name」就先寫進Branch Protection；必須先取得該new product repository/ref的fresh workflow evidence，確認check name確實建立。

## 9. Atomic completion contract

Bootstrap 完成順序固定為：

```txt
read template repository identity + VERSION
→ collect / confirm product inputs
→ repository docs/version/native mutations
   （canonical repository_kind仍是template）
→ infrastructure manifest + CI profile selection
→ required native/docs/component/tracked infrastructure validation
→ live infrastructure disposition / selected profile acceptance
→ prospective candidate-product identity validation
→ final repository_identity transition to product
→ canonical identity/docs validation
→ fresh no-handoff Agent acceptance
```

如果任何 blocking validation 失敗，canonical lifecycle 不得先切成 `product`。沒有持久的 `bootstrapping` 第三狀態。

## 10. Completion 如何判定

不能以「檔案改完」或「目前 conversation 記得產品名稱」當 completion。

至少要能在一個 fresh conversation 中，只開啟已採用的 product repository，而不提供前一個 conversation handoff，Agent仍可從 repository authority自行得知：

```txt
這是 product repository
產品名稱
來源 template repository
採用的 template baseline
目前 product VERSION
首次 bootstrap 已完成，不應再次執行
```

Machine verifier、required native/docs validation與 fresh-agent acceptance都通過後，首次 Template → Product bootstrap 才算完成。

另外selected CI profile的live disposition／acceptance必須在final `repository_kind=product`前完成；不能先finalize product再補runner、GitHub variable或Branch Protection evidence。

## 11. 之後怎麼用

Bootstrap 完成後，這個 repository 就是獨立產品 repository。之後的新功能、Bug、Refactor、Migration或Architecture工作依自己的 repository current authority正常進入 `governing-template-development`；不需要每次提醒 Agent「這以前是模板」。

也不要把一般產品工作重新路由到 `adopting-template-repository`。
