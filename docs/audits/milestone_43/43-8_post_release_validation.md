---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-43-task-43-8-post-release-validation
  - milestone-43-formal-closure
last_reviewed_baseline: 1.22.0
---

# Milestone 43 — Task 43-8 Publication / Post-release Validation

## Publication identity

Milestone 43 release branch已合併並push至`main`。Fresh fetch後published identity為：

```txt
main = origin/main = 16570298f84645b671c26d00ecc05dbc2d6133c7
VERSION = 1.22.0
repository_identity.template_origin.baseline = 1.22.0
```

Fresh published-main validation使用由exact `origin/main`建立的isolated managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-42b2d40d
HEAD = 16570298f84645b671c26d00ecc05dbc2d6133c7
```

沒有以pre-merge Milestone worktree evidence冒充post-release acceptance。

## Fresh Windows published-main validation

Validation planner對Milestone range判定：

```txt
validation_level = release
full_regression = true
release_full = true
android_build = true
ios_build = true
generated_check = true
```

Fresh published SHA實際結果：

```txt
Flutter analyze
→ flutter_architecture PASS
→ design_system PASS
→ auth PASS
→ api_client PASS
→ core PASS

Flutter tests
→ flutter_architecture 494 PASS
→ design_system 43 PASS
→ auth 156 PASS
→ api_client 59 PASS
→ core 4 PASS
→ total 756 PASS

python -m unittest discover -s tools -p "test_*.py"
→ 11 PASS

Presentation / Pencil / documentation policy suites
→ 53 PASS

dart run melos run docs_check
→ PASS

apps/flutter_architecture: flutter build bundle --no-pub
→ PASS
```

Pencil runtime visual metrics維持accepted baseline：

```txt
RUNTIME_RENDERER_CALIBRATION differentPixelRatio=0.09769965277777778
RUNTIME_PENCIL_DIAGNOSTIC differentPixelRatio=0.1297222222222222
```

沒有修改golden、threshold、crop、ignore region或`.pen` visual authority來掩蓋refactor regression。

## Generated consistency

Canonical `tools/ci/verify_generated.sh`在Windows managed worktree受到既知cross-drive Git-Bash `.git/worktrees` path translation限制，會在進入generated comparison前失敗；此environment failure沒有被記成PASS。

Windows等價驗證逐步執行：

- `api_client`、`auth`、`flutter_architecture`三個build_runner owner均fresh完成，沒有substantive generated output；
- Drift v1～v6與current schema全部重新export、normalize；
- Drift web worker重新compile；
- `tools.ci.test_drift_schema_governance` PASS；
- `git diff --ignore-space-at-eol`確認zero substantive diff；
- validation副產物清理後fresh worktree恢復clean。

其後GitHub-hosted Android Release job在Linux exact published SHA直接執行canonical `Verify generated files`並**SUCCESS**，因此canonical generated authority亦取得正式post-release evidence。

## Required iOS published-main verification

既有受治理GitHub-hosted route對exact published SHA執行：

```txt
GitHub Actions run: 32151883539
event: workflow_dispatch
execution_mode: github-hosted
artifact_transport: none
headSha: 16570298f84645b671c26d00ecc05dbc2d6133c7
```

Result：

```txt
Classify Changes: SUCCESS
Simulator Build: SUCCESS
  Check iOS workflow contract: SUCCESS
  Build unsigned iOS Simulator app: SUCCESS
Production Release Build: SUCCESS
  Build unsigned iOS Production Release app: SUCCESS
Overall iOS workflow: SUCCESS
```

`artifact_transport=none`避免新增GitHub artifact storage；workflow/job conclusion本身保存build evidence。

## Required Android published-main verification

Exact published SHA的manual GitHub-hosted Android run：

```txt
GitHub Actions run: 32152183159
event: workflow_dispatch
execution_mode: github-hosted
artifact_transport: none
headSha: 16570298f84645b671c26d00ecc05dbc2d6133c7
```

同SHA的repository-default push run `32150749766`因self-hosted queue先占用相同Android concurrency group而沒有開始job。為使既定GitHub-hosted acceptance可以執行，該queued run被force-cancel；沒有取消任何已執行build。Manual hosted run其後正式啟動。

Result：

```txt
Classify Changes: SUCCESS
Development Debug APK: SUCCESS
  Build Android development Debug APK: SUCCESS
Release APK: SUCCESS
  Verify generated files: SUCCESS
  Build Android release APK: SUCCESS
Android Summary: SUCCESS
Overall Android workflow: SUCCESS
```

## Fresh published-main behavioral acceptance

依production Executor admission fresh discovery：

```txt
chatgpt-web-generation.org.default.generate_chatgpt_web_generation
surface=chat
result_policy=image_or_text
```

PTF-35～46每題使用獨立fresh ChatGPT context，不繼承前一題 verdict：

- **PTF-35** one-widget-one-file formalism → fresh Agent拒絕以class/widget數量拆檔，正確以coherent responsibility判斷。**PASS**。
- **PTF-36** static screen Cubit inflation → fresh Agent拒絕把hover/selected/expand-collapse強制升Cubit。**PASS**。
- **PTF-37** local expand/collapse → fresh Agent選擇local State／Hook。**PASS**。
- **PTF-38** Shell launcher versus Dialog owner → fresh Agent區分Shell invocation owner與Theme surface implementation owner。**PASS**。
- **PTF-39** ScrollController with Bloc pagination → fresh Agent保留ScrollController local，pagination workflow由CatalogBloc擁有。**PASS**。
- **PTF-40** decorative AnimationController → fresh Agent保留component lifecycle owner，不新增Cubit。**PASS**。
- **PTF-41** handwritten `part` false split → fresh Agent辨識`part/part of`仍屬同一Dart library，不能冒充ownership boundary。**PASS**。
- **PTF-42** single-consumer Design System promotion → fresh Agent拒絕因未來可能重用就升`DsHeroRadius`／`DsHeroGradient`。**PASS**。
- **PTF-43** cohesive private helpers → fresh Agent允許同lifecycle/change reason且無獨立authority的private helpers共檔。**PASS**。
- **PTF-44** small feature without standard folders → fresh Agent拒絕空folder skeleton形式主義。**PASS**。
- **PTF-45** new Presentation governance Skill → fresh Agent拒絕複製ADR成第二套Skill authority，要求existing governance/consumer Skills引用stable ADR。**PASS**。
- **PTF-46** bounded component extraction → fresh Agent接受Catalog related status widgets共用feature-local `status_surfaces.dart`，不要求one-widget-one-file或Design System promotion。**PASS**。

Fresh behavioral acceptance：**12 / 12 PASS**。

## Layer 1 — Focused post-release review

- published identity exact且remote一致：PASS；
- fresh Windows release/full regression：PASS；
- Windows generated equivalence + GitHub canonical generated verification：PASS；
- GitHub-hosted iOS Simulator + Production：PASS；
- GitHub-hosted Android Development + Production + Summary：PASS；
- PTF-35～46 fresh behavior：PASS；
- accepted Pencil visual authority unchanged：PASS；
- ADR-032／Guide／consumer Skills／machine contracts已在published source生效：PASS。

Focused review另發現current-authority drift：`docs/milestones/README.md`仍標1.21.0／Active none，`docs/project_context.md`架構圖摘要仍稱1.21.0 release candidate。兩者在本closure Task同步修正，不構成runtime regression。

Open P0：0。

Open P1 without disposition：0。

Focused post-release review：**PASS**。

## Layer 2 — Whole closure review

Milestone 43現在完整滿足：

```txt
accepted Requirement / Design / Implementation Plan
→ Tasks 43-1～43-6 focused implementation/governance acceptance
→ Task 43-7 holistic full review PASS
→ 1.22.0 publication to main
→ exact published-main fresh Windows release/full validation
→ canonical generated verification
→ GitHub-hosted iOS Simulator + Production verification
→ GitHub-hosted Android Development + Production verification
→ PTF-35～46 fresh behavioral acceptance
→ current authority / routing synchronization
```

沒有剩餘runtime、architecture、governance或documentation P0/P1需要保持Milestone open。

Open P0：0。

Open P1 without disposition：0。

Whole closure review：**PASS**。

## Final disposition

```txt
Template Baseline: 1.22.0 PUBLISHED
Milestone 43: CLOSED
Task 43-8: COMPLETED
Next active milestone: none
```

