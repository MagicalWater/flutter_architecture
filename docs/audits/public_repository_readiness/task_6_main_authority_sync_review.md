---
document_type: final-review
status: accepted
authoritative_for:
  - public-repository-readiness-main-authority-sync
last_reviewed_baseline: 1.18.0
---

# Task 6 — Main Authority Sync & Fresh Public-readiness Revalidation

## Admission

Milestone 37完成Template Baseline 1.18.0發布與post-release closure後，Public Repository Readiness branch在任何integration前重新fetch並同步current `origin/main`。

- Current main authority：`26b7fda9845b1ec42e298e0135fa64ee157cc609`。
- Milestone 37 release：`3bca6541785b82dec182752e85392c3cc21ee848`。
- Public-readiness pre-sync HEAD：`003d44d8aedb3d944eb4402efc8a7d1439c2f68b`。
- Public-readiness sync commit：`6e9e24f297aa2f9dd5c2740949156e99dd4794db`。
- Managed Windows worktree在sync前clean；user-owned `apps/flutter_architecture/test/pratice.dart`不在本managed worktree，未修改、stage或提交。

Fresh ancestry確認`origin/main`與pre-sync Public-readiness HEAD已分岔，故以`git merge --no-commit --no-ff origin/main`顯性化conflict後逐份處置。

## Conflict disposition

Conflict只存在於以下Milestone 37 current-authority文件：

- `docs/project_context.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`
- `docs/superpowers/plans/2026-08-14-milestone-37-template-to-product-repository-bootstrap.md`

四份conflict均為舊Public-readiness branch保存的Milestone 37 planning狀態，對上`origin/main`已發布／已封存的1.18.0 authority；沒有Public-readiness專屬內容需要保留。因此resolution完整採用`origin/main` current authority，而不是保留舊planning文字或依conflict marker機械選擇。

同步後fresh authority確認：

- `VERSION = 1.18.0`。
- `repository_identity.json.repository_kind = template`。
- `repository_identity.json.product_name = null`。
- `template_origin.repository = MagicalWater/flutter_architecture`。
- `template_origin.baseline = 1.18.0`。
- Active Milestone：None。
- Milestone 37：Completed / Archived。

## Fresh validation planner

對`origin/main@26b7fda9845b1ec42e298e0135fa64ee157cc609` → synced branch `6e9e24f297aa2f9dd5c2740949156e99dd4794db`重新執行`tools/ci/validation_planner.py`。

Planner因Public-readiness新增security-test path採fail-safe full matrix：

- Python tools tests：required；
- docs check：required；
- repository analyze：required；
- full Flutter tests：required；
- generated consistency：required；
- Android build：required；
- iOS build：required。

未人工縮減planner要求。

## Fresh security / authority validation

- Public repository security contract + secret leakage + change classifier：41 tests PASS。
- `dart run melos run docs_check`：PASS。
- `python tools/docs/verify_repository_identity.py`：PASS。
- Python tools discovery suite：11 tests PASS。
- Full workspace analyze：所有package與app均No issues found。
- Full Flutter regression：所有package suites PASS；App suite 493 cases PASS。

## Generated consistency

- Fresh `dart run melos run build_runner`：PASS。
- Drift v1～v6與current schema fresh dump：PASS。
- Drift schema normalization：PASS。
- Drift worker fresh compile：PASS。
- `tools.ci.test_drift_schema_governance`：2 tests PASS。
- Windows只出現EOL-only generated differences；`git diff --ignore-space-at-eol`確認semantic diff為0，依既有repository Windows policy恢復後clean。

## Android production verification

- Exact synced HEAD：`6e9e24f297aa2f9dd5c2740949156e99dd4794db`。
- Production Firebase config不存在：依contract明確skip provider wiring。
- Production release APK：PASS。
- Obfuscation / split-debug-info：PASS；arm、arm64、x64 symbols均存在。
- `apkanalyzer` application id：`com.example.flutterarchitecture`，PASS。

第一次人工驗證命令使用Windows反斜線target `lib\\main_production.dart`，被repository flavor contract正確拒絕；改用canonical `lib/main_production.dart`後fresh build PASS。此為驗證命令錯誤，不是source finding。

## iOS production verification

- macOS fresh managed worktree exact base：`origin/public-repository-readiness@6e9e24f297aa2f9dd5c2740949156e99dd4794db`。
- Starting worktree：clean。
- Production Firebase config不存在：依contract明確skip provider wiring。
- `Production` / `Release-production` / `iphoneos` / `CODE_SIGNING_ALLOWED=NO`：`BUILD SUCCEEDED`。
- Bundle identifier：`com.example.flutterarchitecture`，PASS。
- Unsigned verification `.app`：PASS。
- dSYM：present；build script完整UUID contract PASS。

## Fresh secret / history readiness scan

Current tracked tree與full Git history重新掃描：

- `.env`、keystore、Apple signing/private material、Firebase Android/iOS provider config、service-account file：0 tracked filename findings。
- Token/private-key/provider content patterns的current matches只存在repository-owned CI regression/test fixture files。
- History pattern commits逐一檢視後，實際matches仍只屬CI scanner／fixture contract；兩個歷史commit只是regex／pipeline變更而沒有實際secret tree match。
- Real credential requiring rotation：0。
- History rewrite required：No。
- `crazydennies@gmail.com`仍依使用者既有明確決策接受公開。

## Findings & disposition

- Open P0：0。
- Undisposed P1：0。
- Milestone 37 current-authority regression：0。
- Public fork / trusted self-hosted / privileged secret regression：0。
- Remaining repository-content security blocker：0。

Task 6：**ACCEPTED**。

Public-readiness branch已重新建立在Template Baseline 1.18.0 current authority之上，可進入main integration；GitHub visibility change仍屬獨立user-owned gate。
