---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-36-post-release-validation
  - milestone-36-final-closure
last_reviewed_baseline: 1.17.0
---

# Milestone 36 — Template Baseline 1.17.0 Post-release Validation

## Release identity

```txt
Template Baseline: 1.17.0
Published main SHA: b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
Remote publication: origin/main
Force push: no
```

Publication前發現Windows main已有一個已核准planning commit，而Milestone worktree包含等價但不同history的accepted authority；merge conflict僅出現在Milestone 36 planning/current-state文件。Resolution採用worktree中的latest accepted/release state，production source沒有conflict。

使用者既有未追蹤檔案`apps/flutter_architecture/test/pratice.dart`未被加入、刪除、修改或提交。

Publication後fresh identity reconciliation：

```txt
Windows main = b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
origin/main  = b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
macOS main   = b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
VERSION      = 1.17.0
```

## Published-main routing verification

以Milestone 36前published baseline `e935c0b8dc174b91bc20bd0f9c247123ff55bd2b`到published `b04a845a1f9dd65a8c1e0438d43a6e3e7001747e`執行canonical validation planner：

```txt
change_classes:
  docs_content
  governance
  test_only
  app_feature
  release

validation_level: release
full_regression: true
generated_check: true
android_build: true
ios_build: true
release_full: true
fail_safe: false
```

Result：PASS。Published range維持release-level validation，沒有重用Task 36-8 local-release結果取代post-release evidence。

## Fresh representative authoring pressure

在published Windows main fresh執行Milestone 36 canonical authoring contract：

```powershell
python -m unittest tools.docs.test_test_authoring_governance
```

Result：`5 / 5 PASS`。

代表性contract持續鎖定：

- Risk／invariant／failure mode先於Task／class／layer數量。
- `Required`／`Recommended`／`no-new-test justified`／`Should-not-add`仍為canonical dispositions。
- trivial passthrough與presentation-only mutation不被機械要求新增test。
- security／migration／persistence／concurrency等Required risks不能以`no-new-test justified`逃避direct owner。
- `0 new tests`仍必須通過Milestone 35 planner-selected validation。

Task 36-5的fresh ChatGPT behavioral evidence仍是human/agent behavioral proof；post-release不重新製造另一份聊天答案，而以published canonical contract確認已發布authority沒有漂移。

## Fresh Windows published-main regression

在`D:\Developer\flutter_architecture` published `main`執行：

```powershell
python -m unittest discover -s tools/ci -p "test_*.py"
python -m unittest tools.testing.test_test_inventory
python -m unittest tools.docs.test_test_authoring_governance
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
```

結果：

```txt
CI contracts: 246 / 246 PASS
Inventory contracts: 11 / 11 PASS
Test Authoring governance contracts: 5 / 5 PASS
Documentation check: PASS
Analyze: PASS / 5 workspaces
Flutter workspace regression: PASS
App suite: 493 cases PASS
```

Task 36-8已另完成release-candidate generated consistency與Android development/production verification builds；published range planner仍正確要求這些release gates，且沒有降低fail-safe。

## Fresh macOS / iOS published-main evidence

macOS checkout由舊main clean fast-forward到published `origin/main`，確認`HEAD = b04a845a1f9dd65a8c1e0438d43a6e3e7001747e`與`VERSION = 1.17.0`後，執行repository-owned iOS verification routes。

Development：

```bash
ARTIFACT_DIR=/tmp/flutter-architecture-1.17.0-ios-development \
bash tools/ci/build_ios_development.sh
```

Result：

```txt
xcodebuild: BUILD SUCCEEDED
environment: development
scheme: Development
configuration: Debug-development
sdk: iphonesimulator
entrypoint: lib/main_development.dart
api_mode: mock
bundle_id: com.example.flutterarchitecture.development
signing: unsigned verification build
dSYM: present
artifact commit_sha: b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
```

Production：

```bash
ARTIFACT_DIR=/tmp/flutter-architecture-1.17.0-ios-production \
API_BASE_URL=https://api.your-domain.example \
bash tools/ci/build_ios_production.sh
```

Result：

```txt
xcodebuild: BUILD SUCCEEDED
environment: production
scheme: Production
configuration: Release-production
sdk: iphoneos
entrypoint: lib/main_production.dart
api_mode: real
bundle_id: com.example.flutterarchitecture
signing: unsigned verification build
dSYM: present
artifact commit_sha: b04a845a1f9dd65a8c1e0438d43a6e3e7001747e
```

兩個iOS產物都只作verification artifact，不宣稱可直接上架；physical-device與distribution boundary維持既有deferred disposition。

## Governance closure

- Requirement Decision：Accepted / Level 4。
- Design：Accepted並完成雙層review與使用者approval。
- Implementation Plan：Accepted並完成雙層review與使用者approval。
- Tasks 36-1～36-7：逐Task review、finding處置、fresh re-review、authority check與獨立commit完成。
- Task 36-5：provider-neutral fresh ChatGPT behavioral pressure PASS；後續執行明確不使用Codex。
- Task 36-6：Auth／Catalog／Profile reference density audit完成；existing tests deleted = 0。
- Task 36-8：Holistic Final Review與Template Baseline 1.17.0 local release gate完成。
- Publication：使用者明確核准；main正常merge/push，沒有force push。
- Task 36-9：published-main release routing、representative authoring contracts、Windows full regression與macOS/iOS verification全部PASS。
- Open P0：0。
- Open P1 without disposition：0。
- Tests deleted for count reduction：0。
- Test count／coverage percentage作success KPI：NO。
- Milestone 35 validation planner responsibility changed：NO。
- Double-layer Task governance downgraded：NO。

## Final disposition

**Template Baseline 1.17.0已發布，Milestone 36正式Completed / Archived。**

Current work回到Roadmap／Requirement Decision入口；不自動建立下一個Milestone。
