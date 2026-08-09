---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-35-post-release-validation
  - milestone-35-final-closure
last_reviewed_baseline: 1.16.0
---

# Milestone 35 — Template Baseline 1.16.0 Post-release Validation

## Release identity

```txt
Template Baseline: 1.16.0
Published main SHA: 016f33c47aa07701014c2da2573a3a819762d116
Main integration: fast-forward
Remote publication: origin/main
Force push: no
```

Publication後fresh fetch／identity reconciliation確認：

```txt
Windows local main = 016f33c47aa07701014c2da2573a3a819762d116
origin/main        = 016f33c47aa07701014c2da2573a3a819762d116
macOS local main   = 016f33c47aa07701014c2da2573a3a819762d116
VERSION            = 1.16.0
```

## Published-main routing verification

以pre-publication remote main `c4b687d3570708deb044016f0627d97065f5f20c`到published main `016f33c47aa07701014c2da2573a3a819762d116`執行canonical planner：

```txt
change_classes:
  docs_content
  governance
  tooling
  test_only
  validation_engine
  release

validation_level: release
full_regression: true
generated_check: true
android_build: true
ios_build: true
release_full: true
fail_safe: false
```

Result：PASS。Published range正確維持release-level fresh validation，不因已完成35-8而重用舊evidence。

## Fresh Windows published-main full regression

在`D:\Developer\flutter_architecture` published `main`執行：

```powershell
python -m unittest discover -s tools/ci -p "test_*.py"
python -m unittest tools.testing.test_test_inventory
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
```

結果：

```txt
CI contracts: 238 / 238 PASS
Inventory contracts: 11 / 11 PASS
Documentation check: PASS
Analyze: PASS / 5 workspaces
Flutter workspace regression: PASS
App suite: 493 cases PASS
```

## Fresh macOS / iOS published-main evidence

macOS checkout先由舊main fast-forward到published `origin/main`，確認：

```txt
HEAD = origin/main = 016f33c47aa07701014c2da2573a3a819762d116
VERSION = 1.16.0
working tree before build = clean
```

接著執行repository-owned production iOS verification route：

```bash
ARTIFACT_DIR=<temporary-dir> \
API_BASE_URL=https://api.acme.test \
GENERATE_DSYM_FOR_ACCEPTANCE=true \
bash tools/ci/build_ios_production.sh
```

結果：

```txt
xcodebuild: BUILD SUCCEEDED
environment: production
scheme: Production
configuration: Release-production
sdk: iphoneos
entrypoint: lib/main_production.dart
bundle_id: com.example.flutterarchitecture
signing: unsigned verification build
dSYM: present
artifact commit_sha: 016f33c47aa07701014c2da2573a3a819762d116
```

Build只作verification artifact，不宣稱可直接上架；這與既有iOS distribution boundary一致。

## Governance closure

- Requirement Decision：Accepted。
- Corrective Design：Accepted並完成雙層review。
- Implementation Plan：Accepted並完成雙層review。
- Tasks 35-1～35-7：逐Task雙層治理、finding修正、fresh re-review與獨立commit完成。
- Task 35-8：Holistic Final Review、local release identity、fresh release gates完成。
- Publication：使用者明確核准；main fast-forward整合並正常push，沒有force push。
- Task 35-9：published-main fresh routing、full regression與macOS/iOS production build evidence全部PASS。
- Open P0：0。
- Open P1 without disposition：0。
- Tests deleted for speed：0。
- Fail-safe downgrade：NO。
- Double-layer Task governance downgrade：NO。

## Final disposition

**Template Baseline 1.16.0已發布，Milestone 35正式Completed / Archived。**

Current work回到Roadmap／Requirement Decision入口；沒有自動建立下一個Milestone。
