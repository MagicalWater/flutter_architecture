---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-37-post-release-validation
  - milestone-37-final-closure
last_reviewed_baseline: 1.18.0
---

# Milestone 37 — Template Baseline 1.18.0 Post-release Validation

## Release identity

```txt
Template Baseline: 1.18.0
Published main SHA: 3bca6541785b82dec182752e85392c3cc21ee848
Remote publication: origin/main
Force push: no
GitHub Template Repository: true
```

使用者已明確核准Template Baseline 1.18.0 publication、main fast-forward push與發布後治理closure。Publication前的final release SHA已完成release-level full regression、generated consistency、Android development/production與macOS iOS development/production verification；本文件只記錄published-main之後fresh重驗與formal closure。

來源checkout既有未追蹤檔案`apps/flutter_architecture/test/pratice.dart`未被加入、刪除、修改或提交。

## Published-main fresh admission

Windows以`origin/main@3bca6541785b82dec182752e85392c3cc21ee848`建立fresh managed worktree。Repository-local discovery可直接看見：

```txt
governing-template-development
adopting-template-repository
adopting-template-product-identity
```

Root `repository_identity.json`仍為canonical template state，且GitHub repository external setting fresh確認`is_template=true`。因此published source repository仍是Template Repository，不會因Milestone 37完成而誤切成product。

## Fresh Windows published-main regression

Published SHA fresh執行：

```txt
repository identity verifier: PASS
repository identity tests: 11 / 11 PASS
documentation check: PASS
analyze: PASS / 5 workspaces
Flutter workspace regression: PASS
App suite: 493 cases PASS
generated consistency: PASS
```

Generated check在Windows造成的純EOL working-tree side effect已在disposable worktree以`git reset --hard HEAD`還原；沒有形成source change。

## Fresh Android published-main evidence

Repository-owned managed route：

```txt
tools/ci/run_local_ci.sh android
run_key: local-20260814t021611z-2013-6bc6d058
commit_sha: 3bca6541785b82dec182752e85392c3cc21ee848
```

Result：

```txt
development debug: PASS
package: com.example.flutterarchitecture.development
production release verification: PASS
package: com.example.flutterarchitecture
flutter symbols: present
mapping file: present
managed aggregation: success
```

上述identifier是source template的verification placeholder，符合Template Baseline；不得誤解為product adoption完成後的identifier。

## Fresh macOS / iOS published-main evidence

macOS本機remote-tracking ref起初仍停在舊baseline；先`git fetch origin main`後再detach到published `origin/main`，確認exact SHA為`3bca6541785b82dec182752e85392c3cc21ee848`，才執行repository-owned iOS managed route。

```txt
tools/ci/run_local_ci.sh ios
run_key: local-20260814t021936z-77745-a6fee571
commit_sha: 3bca6541785b82dec182752e85392c3cc21ee848
```

Development：

```txt
BUILD SUCCEEDED
scheme: Development
configuration: Debug-development
sdk: iphonesimulator
entrypoint: lib/main_development.dart
api_mode: mock
bundle_id: com.example.flutterarchitecture.development
dSYM: present
```

Production：

```txt
BUILD SUCCEEDED
scheme: Production
configuration: Release-production
sdk: iphoneos
entrypoint: lib/main_production.dart
api_mode: real
bundle_id: com.example.flutterarchitecture
signing: unsigned verification build
dSYM: present
managed aggregation: success
```

兩個產物都只是verification artifact，不宣稱Store distribution readiness。

## Published Template → Product isolated acceptance

另由published `origin/main@3bca654...`建立disposable managed product fixture，使用：

```txt
Product name: Pickup Basketball Acceptance
Base identifier: com.magicalwater.pickupbasketballacceptance
Development display name: Pickup Basketball Acceptance Dev
Staging display name: Pickup Basketball Acceptance Staging
Production display name: Pickup Basketball Acceptance
Initial product VERSION: 0.1.0
Template origin: MagicalWater/flutter_architecture @ 1.18.0
```

Atomic lifecycle evidence：

1. 初始canonical state為`repository_kind=template`、`VERSION=1.18.0`。
2. 產品VERSION／current docs／native projections完成後，canonical manifest仍保持template。
3. 此中間狀態canonical verifier以`template-origin-baseline-mismatch`正常fail closed。
4. Temporary candidate product manifest在不覆蓋canonical manifest的前提下，prospective identity、docs與environment validation全部PASS。
5. 只有blocking prospective checks通過後，才把同一candidate內容寫成canonical product identity並移除temporary candidate。

Final fresh product admission：

```txt
repository_kind = product
product_name = Pickup Basketball Acceptance
template_origin.repository = MagicalWater/flutter_architecture
template_origin.baseline = 1.18.0
VERSION = 0.1.0
repository identity verifier = PASS
documentation checker = PASS
environment mapping contract = PASS
focused bootstrap/native contracts = 97 / 97 PASS
git diff --check = PASS
```

Fixture在final transition後重新以fresh workspace開啟，不需前一個workspace handoff即可由repository authority直接讀出product name、template provenance與product VERSION；因此首次bootstrap不應再次執行。

## Governance closure

- Requirement Decision：Accepted / Level 4。
- Design：Accepted，focused review與whole-Design review PASS，使用者已核准。
- Implementation Plan：Accepted，focused review與whole-Plan review PASS，使用者已核准。
- Tasks 37-1～37-7：逐Task review、finding disposition、fresh re-review與acceptance完成。
- Task 37-8：Holistic Final Review與Template Baseline 1.18.0 release disposition PASS。
- Publication：使用者明確核准；`origin/main`正常fast-forward至`3bca654...`，沒有force push。
- Task 37-9：published-main identity/docs/full regression/generated/Android/iOS與published Template → Product isolated acceptance全部PASS。
- GitHub Template Repository external setting：仍為`true`。
- Open P0：0。
- Open P1 without disposition：0。
- Product MVP／Feature／roadmap被Milestone 37自動規劃：NO。
- Existing products被自動同步／改寫：NO。

## Final disposition

**Template Baseline 1.18.0已發布，Milestone 37正式Completed / Archived。**

Current work回到Roadmap／Requirement Decision入口；不自動建立下一個Milestone。
