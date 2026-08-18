---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-42-task-42-10-post-release-validation
  - milestone-41-42-formal-closure
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-10 Publication / Post-release Validation

## Publication identity

使用者於 2026-08-18 明確授權完成 Milestone 41 + 42 收尾。Corrective branch 合併至 `main` 並 push 後，published runtime candidate 為：

```txt
merge commit = 64fe7e7dc3402d19382e21f73b73add894534ff2
main = origin/main = 64fe7e7dc3402d19382e21f73b73add894534ff2
VERSION = 1.21.0
repository_identity.template_origin.baseline = 1.21.0
```

Fresh published-main validation使用由`origin/main`建立的 isolated managed worktree：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-d9ead111
HEAD = 64fe7e7dc3402d19382e21f73b73add894534ff2
```

沒有以pre-merge worktree結果冒充post-release evidence。

## Fresh Windows published-main validation

在 exact published runtime SHA 執行：

```txt
dart run melos run analyze
→ 5 packages PASS

dart run melos exec -- flutter test
→ flutter_architecture 499 PASS
→ design_system 43 PASS
→ auth 156 PASS
→ api_client 59 PASS
→ core 4 PASS

python -m unittest discover -s tools -p "test_*.py"
→ 11 PASS

python -m unittest \
  tools.visual.test_verify_visual_authority \
  tools.visual.test_pencil_implementation_mapping \
  tools.docs.test_pencil_representation_mapping_policy \
  tools.docs.test_pencil_single_renderer_policy
→ 50 PASS

dart run melos run docs_check
→ PASS

apps/flutter_architecture: flutter build bundle
→ PASS
```

Milestone 41 constraint-owned page-flow、Milestone 42 UI Design Ownership mapping、accepted Pencil visual/runtime authority與current Design System contract均在published-main fresh suite維持GREEN。

## Fresh published-main behavioral acceptance

依 current `chatgpt-web-generation` production text route，以fresh ChatGPT contexts重新施壓PTF-30～34；沒有沿用Task 42-8 conversation memory作verdict。

- **PTF-30**：Login/Home/Settings將同一product semantic background/text/accent各自藏進FeatureVisualSpec → fresh Agent拒絕，判定shared semantic應由Design System／app-level theme owner擁有。**PASS**。
- **PTF-31**：單一Hero radius 17 + decorative gradient直接promotion成global DS token → fresh Agent拒絕，判定current owner應留component-local。**PASS**。
- **PTF-32**：Page + 15 sections + custom RenderObject + projection helpers因「全部都是Presentation」塞同一page file → fresh Agent明確區分layer correctness與responsibility cohesion並拒絕。**PASS**。
- **PTF-33**：FeatureUiSpec同時集中palette/font/spacing/radius/button dimensions/assets/gradients/screen offsets → fresh Agent拒絕catch-all，按Design System／component／asset／layout responsibility重新路由。**PASS**。
- **PTF-34**：已有source/hash/provenance authority仍把asset paths放入FeatureVisualSpec → fresh Agent拒絕asset identity/provenance與visual constants ownership混合。**PASS**。

Fresh discovery path：

```txt
chatgpt-web-generation.org.default.generate_chatgpt_web_generation
surface=chat
result_policy=image_or_text
```

## Required iOS production verification

`bridge-mac`與`bridge-mac-backup`在本次closure admission都回傳同一external connector account 400：

```txt
We couldn't connect your account. Please try again.
```

此結果沒有被記成iOS failure或PASS。Repository current iOS workflow本身已正式支援`workflow_dispatch`的`execution_mode=github-hosted`，Production job固定使用`macos-15`並執行`tools/ci/build_ios_production.sh`。因此使用既有受治理route對exact published SHA執行：

```txt
GitHub Actions run: 32137729376
event: workflow_dispatch
execution_mode: github-hosted
artifact_transport: none
headSha: 64fe7e7dc3402d19382e21f73b73add894534ff2
```

Result：

```txt
Classify Changes: SUCCESS
Simulator Build: SUCCESS
  Build unsigned iOS Simulator app: SUCCESS
Production Release Build: SUCCESS
  Build unsigned iOS Production Release app: SUCCESS
Overall iOS workflow: SUCCESS
```

Production wrapper authority仍是：

```txt
production / Production / Release-production / iphoneos / lib/main_production.dart / real
```

`artifact_transport=none`刻意不增加GitHub artifact storage；build result本身由workflow/job conclusion保存。

## UI architecture authority finalization

Milestone 42建立的repository-wide UI Design Ownership boundary已同步到current authority：

```txt
shared semantic / Theme Identity / validated reusable component
→ Design System

raster / vector / icon / font / texture identity + provenance
→ existing representation / provenance authority

canonical viewport / DPR / comparison metadata
→ visual authority

screen / section placement mechanics
→ layout owner

single-screen exact geometry / decoration
→ smallest correct component owner
```

Root `AGENTS.md`補入同一boundary，避免ordinary non-Pencil feature只讀fixed minimum set時遺失Milestone 42已接受的架構規則。

更大的Page／View／Section／Component／Dialog／BottomSheet／Overlay／Controller與file-cohesion governance缺口**不在本Milestone偷跑**；只登記為Milestone 43 candidate，等待新的Requirement Decision。

## Layer 1 — Focused post-release review

- published runtime identity：PASS；
- fresh clean-checkout Windows regression：PASS；
- required iOS Simulator + Production verification：PASS；
- PTF-30～34 published-main fresh behavior：PASS；
- accepted visual authority沒有被closure改寫：PASS；
- current UI ownership authority discovery補強：PASS；
- Milestone 43僅candidate，沒有scope leakage：PASS。

Open P0：0。

Open P1 without disposition：0。

Focused review：**PASS**。

## Layer 2 — Whole closure review

Milestone 41與42的combined release現在同時滿足：

```txt
accepted Requirement / Design / Plan
→ all implementation Tasks accepted
→ combined holistic PASS
→ user merge/push authorization
→ main publication
→ fresh published-main Windows full validation
→ required iOS Simulator + Production verification
→ fresh PTF-30～34 acceptance
→ current authority sync
```

沒有剩餘runtime、architecture、governance或documentation P0/P1要求保持Milestone open。

Open P0：0。

Open P1 without disposition：0。

Whole closure review：**PASS**。

## Final disposition

```txt
Template Baseline: 1.21.0 PUBLISHED
Milestone 41: CLOSED
Milestone 42: CLOSED
Task 42-10: COMPLETED
Next active milestone: none
Milestone 43: candidate only
```

