---
document_type: architecture-decision
status: accepted
authoritative_for:
  - adr-023-repository-ci-quality-gates-android-verification-artifact
last_reviewed_baseline: 1.15.2
id: ADR-023
title: Repository CI Quality Gates and Platform Verification Artifacts
supersedes: []
superseded_by: []
related:
  - ADR-002
  - ADR-009
  - ADR-011
  - ADR-014
  - ADR-024
---

# ADR-023 — Repository CI Quality Gates and Platform Verification Artifacts

## Status

Accepted。

## Authoritative Scope

本Decision定義repository CI host、execution mode、required quality gates、toolchain reproducibility、generated source consistency、Android／iOS verification artifact、artifact ownership／transport／retention／cleanup，以及CI security boundary。

## Context

Repository已具備workspace commands、documentation checker、tests、tracked generated source與platform runner，但品質契約若只靠人工挑選命令，容易產生漏驗、重驗與昂貴平台驗證失控。Current direction因此採repository-owned planner＋explicit orchestration，由machine authority決定candidate需要哪些evidence，而不是把每個Pull Request或branch push直接綁定完整CI矩陣。

CI本身也會引入runner drift、floating Action、secret exposure、cache dependency與production artifact誤解，因此需要durable boundary，而不是只新增一份workflow YAML。

## Decision

GitHub Actions是repository CI control plane。Repository正式支援三種互斥的CI execution mode：

```txt
manual-local
self-hosted
github-hosted
```

`manual-local`表示GitHub不派送任何hosted或self-hosted execution job，由操作者明確執行repository-owned本機腳本；`self-hosted`表示GitHub只把explicit `workflow_dispatch`工作派送至repository-scoped Mac runner；`github-hosted`表示沿用GitHub提供的Ubuntu／macOS runner。`main` publication push本身不建立execution jobs。

Manual dispatch可以使用`repository-default`作為sentinel，表示沿用repository variable的execution mode。`repository-default`不是第四種execution mode，不得保存為current mode。

Self-hosted runner使用`water`帳號下的獨立runner workspace與完整專用labels。Pull Request、fork Pull Request、Dependabot Pull Request與未合併branch不得進入此runner。Unknown、空白或legacy mode必須fail closed，不得猜測執行端，也不得自動fallback到GitHub-hosted runner產生非預期費用。

三種execution mode必須共用repository-owned scripts作為build、test與symbol handling實作來源。Workflow只負責event policy、runner routing、secret materialization與artifact transport，不得維護平行build contract。

GitHub Actions是CI control plane，不是`manual-local`或`self-hosted`的主要artifact owner。`manual-local`與`self-hosted`產生的verification artifact、bounded diagnostics、checksums與Observability evidence必須寫入repository checkout外的managed local artifact store；self-hosted不得使用`actions/upload-artifact`或`actions/cache`把日常成功／失敗證據重新送回GitHub storage。

`github-hosted`保留為人工、偶發的clean-run驗證入口。其repository default artifact transport為`none`，cache亦預設停用；只有`workflow_dispatch`明確要求的有界diagnostics或短期full transport可以例外使用GitHub artifact storage。Push、Pull Request與`repository-default`不得隱式啟用remote artifact transport。

Managed artifact root必須由受控環境解析並驗證，且不得位於repository root、任何Git worktree、runner `_work`、runner temp、filesystem root或home root本身。Self-hosted缺少明確external root時必須fail closed；manual-local可以使用platform-specific user-state default，但不得回退到repository checkout。

每個execution job必須先在同一filesystem的in-progress staging建立allowlist metadata、artifact entries與SHA-256，完成後以atomic publish形成job-level manifest。Multi-job workflow另由run-level manifest聚合已finalize job records；最後完成的job不得覆蓋其他job evidence。Manifest不得序列化完整process environment、credential、token、service account或provider config。

Artifact retention必須同時受到age、per-class count、global capacity與minimum-free-space治理。Pin必須具owner、reason與有限`expires_at`；不得形成永久容量豁免。Local cleanup預設dry-run，apply必須依完整manifest與store generation執行，先移入有界trash窗口再purge，並拒絕path traversal、symlink escape、active lock與in-progress run。

既有GitHub Actions artifacts與caches只有在replacement local runtime evidence成立後，才能依exact GitHub object IDs產生deletion manifest。GitHub deletion屬不可逆操作，必須完成focused review、whole-cleanup review並再次取得使用者明確核准；Milestone或Implementation Plan核准本身不構成delete approval。

核心CI／Android／iOS validation workflow一律由explicit `workflow_dispatch`建立，不因Pull Request或branch push自動執行。`main`是publication branch；publication必須先在candidate SHA完成explicit release validation，因此push到`main`本身不再自動重跑CI／Android／iOS。Repository-owned classifier／planner依changed paths輸出最低充分validation與platform flags；unknown path、無效Git range與planner execution failure fail-safe到**logical full**，但不因ambiguity自動啟動Android＋iOS昂貴platform builds。

`tools/ci/change_classifier.py`只擁有canonical change-class classification；`tools/ci/validation_planner.py`是validation selection唯一machine authority。Current contract以focused／affected-critical／explicit-full／release為主，輸出exact Flutter／Python／analyze scopes、generated、aggregate platform flags與platform build-kind flags。Android build-kind包含development／production，iOS build-kind包含simulator／production；aggregate flag只供相容與summary，不得再作為variant job的唯一啟動條件。Workflow YAML、local shell與Agent prompt不得建立平行path-selection engine。

Package affected scope由tracked workspace dependency graph推導reverse dependents。Ordinary App feature／leaf package／database source change不自動要求Android＋iOS build；只有Android native、iOS native、explicit manual platform intent，或release candidate changed risk實際命中對應platform boundary時，才建立platform verification。

Platform evidence採最低充分build-kind。Development／simulator-specific build script或configuration只選對應secondary variant；production-specific只選production variant；shared native、root dependency／toolchain、platform-shared、對應platform workflow本體與invalid release range仍選該平台both variants。Validation-engine-only release以Android Production＋iOS Production作端到端sentinel；若candidate同時命中native／workflow／dependency risk，再依實際risk升級additional variants。

Unknown path、dependency graph parse failure或一般classification ambiguity fail-safe到logical full source validation，但不因ambiguity自動啟動雙平台。Explicit release若missing／invalid candidate range，因changed platform impact完全不可判定，才fail-safe到logical full＋generated＋Android＋iOS。Planner process failure先由canonical classifier保存可判定的platform impact；classifier／range也不可用時才雙平台fail-safe。Milestone holistic本身不要求full；`workflow_dispatch`預設focused，explicit `full`／`android`／`ios`只升級指定validation intent，`release`則要求fresh planner-selected candidate evidence。

同一exact SHA、validation plan identity與selected inputs相同時，GREEN evidence可以跨holistic與post-release reuse。Selected source／test／dependency mutation、failure後fix或validation engine變更會使reuse失效；explicit release candidate仍要求一次fresh planner-selected evidence，但freshness不得把scope無條件擴張成logical full或雙平台。Publish同一SHA後只驗published SHA／artifact／workflow identity，不重跑相同source suite。

Exact candidate release validation只有一個repository-owned入口：`tools/ci/run_release_validation.py`。它先驗證clean local／remote candidate identity，再由canonical planner產生唯一plan，最後只依`execution_mode`替換execution backend。`github-hosted`會fan-out selected CI／Android／iOS workflows並驗證fresh run-id、exact SHA與conclusion；`manual-local`則以相同plan呼叫managed local validation runner與planner-selected platform build variants，將evidence保存至checkout外managed artifact store。兩種backend都不得重新分類changed paths、修改release identity、merge、push `main`或publication。

在`self-hosted`模式下，execution jobs由explicit `workflow_dispatch`建立；核心CI／Android／iOS不建立Pull Request checks。`main` publication push不建立第二輪execution jobs。Branch Protection不得把這三條dispatch-only workflow設成每個PR都必須自動出現的required checks；若需要merge前證據，應由明確的validation orchestration先建立對應run。

在`github-hosted`模式下，核心CI／Android／iOS仍只接受explicit `workflow_dispatch`，不因PR或push隱式消耗GitHub-hosted runner。`VERSION`只是release identity metadata，不再自動觸發full CI或Android／iOS build；`workflow_dispatch`依explicit validation mode決定focused／full／platform／release。

需要iOS驗證時才使用GitHub-hosted `macos-15`執行Development Debug Simulator clean build；ordinary source／documentation change不得只為維持check歷史形狀而啟動macOS runner。Production另使用`tools/ci/build_ios_production.sh`建立generic-device unsigned Release verification。兩者都不使用Apple Team、certificate、provisioning profile或signing secret。

CI使用固定runner OS major version、exact Flutter version與Java 17。Executable workspace追蹤root `pubspec.lock`，使乾淨runner驗證已知dependency graph。

Generated source維持tracked。`CI / Generated Consistency`是repository-level generated source consistency的唯一workflow owner；CI重跑generator後必須檢查Git tree，任何changed、deleted或untracked generated file都使gate失敗，CI不得自動commit。Android／iOS platform verification workflow只消費同一exact SHA中的tracked generated source並負責各自platform build evidence，不得再內嵌第二份`verify_generated.sh`形成重複authority。若某個較高層validation intent需要「generated + platform」的self-contained evidence，必須由planner／orchestrator組合families，而不是把repository-level invariant藏進platform workflow。

Android artifact使用default development／Mock entrypoint與repository既有verification signing。Artifact必須帶commit traceability與明確的非production classification。`flutter build bundle`不能替代Android APK artifact驗證。

Cache不得成為correctness或artifact authority。Self-hosted與repository-default github-hosted route不使用GitHub Actions cache；任何未來人工例外cache都必須另行review，且`.dart_tool`、workspace build output、generated source與platform artifact永遠不得成為shared cache authority。

Workflow permissions採最小權限，不讀取secrets，不使用`pull_request_target`。所有external Actions pin immutable full commit SHA。

iOS failure evidence預設由job log、summary與managed local store保存；只有人工明確選擇的`github-hosted` bounded diagnostics例外才可短期上傳。`.app`、dSYM、symbols與mapping不得因failure-only transport進入GitHub artifact storage。Simulator build只能證明native integration與unsigned build contract，不能宣稱App Store readiness或實體裝置驗證完成。

Production signing、Store publishing、GitHub Release、environment promotion與deployment credentials必須由未來獨立release workflow與protected Environment決定，不屬本Decision第一版實作。

## Consequences

- Merge contract由人工checklist提升為repository-enforced checks。
- Toolchain與dependency graph變更必須透過reviewable repository change發生。
- Generated source omission由explicit planner-selected validation阻擋，不依賴PR自動run。
- 只有change classification與explicit validation intent要求Android驗證時，才建立可追溯的Android verification APK；documentation-only不建立平台artifact。
- iOS Simulator／Production evidence由explicit validation intent建立，且不需要repository signing secrets。
- Documentation-only不執行analyze、generated consistency、全部Flutter tests或Android／iOS代表build，避免evidence-only commit形成無限驗證循環。
- CI workflow與pinned Actions需要後續maintenance；Dependabot不因本Decision自動加入。
- Self-hosted runner不消耗GitHub-hosted execution minutes，但會引入本機可用性、持久workspace、cache與secret清理責任。
- Self-hosted與manual-local的artifact traceability由external managed store、job／run manifest與checksums承擔；GitHub job summary只能提供local-only定位與摘要，不代表遠端可下載。
- Artifact容量由retention class、count、capacity、minimum-free-space與bounded pin共同治理；cleanup具本機短期restore，但GitHub object deletion不可restore。
- Runner離線時job維持queued；不得自動切換至GitHub-hosted runner。操作人員必須恢復runner或明確切換mode。
- GitHub Branch Protection settings仍需repository管理者依文件人工設定，code不能宣稱已完成settings變更。

## Supersession

本Decision未取代既有ADR。

## Related Decisions

- ADR-002：Monorepo與Melos workspace contract。
- ADR-009：版本與變更紀錄治理。
- ADR-011：文件Single Authority原則。
- ADR-014：App environment entrypoint與production validation boundary。
- ADR-024：iOS Runner、native dependency與verification layering contract。

## Related Evidence

- [Milestone 24 planning review](../audits/milestone_24/24-0_planning_review.md)
- [Milestone 24 implementation plan](../superpowers/plans/2026-07-22-milestone-24-ci-cd-foundation.md)
- [Change-aware CI design](../superpowers/specs/2026-07-23-change-aware-ci-execution-design.md)
- [Change-aware CI planning review](../audits/change_aware_ci_plan_review.md)
- [Task 27-7 self-hosted CI design](../superpowers/specs/2026-07-24-self-hosted-ci-execution-mode-design.md)
- [Task 27-7 self-hosted CI plan](../superpowers/plans/2026-07-24-self-hosted-ci-execution-mode.md)
- [Milestone 32 accepted Design](../superpowers/specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md)
- [Milestone 32 accepted Implementation Plan](../superpowers/plans/2026-07-30-milestone-32-ci-artifact-local-storage-cutover.md)

## Last Reviewed Baseline

1.14.0。
