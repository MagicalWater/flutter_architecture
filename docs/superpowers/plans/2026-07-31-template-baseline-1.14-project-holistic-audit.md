---
document_type: implementation-plan
status: proposed
authoritative_for:
  - template-baseline-1-14-project-holistic-audit-plan
last_reviewed_baseline: 1.14.0
---

# Template Baseline 1.14.0 — Project Holistic Audit & Future Direction Assessment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 對Template Baseline 1.14.0完成可重現的repository-wide整體總審查，產出有evidence的architecture、capability、runtime、security／platform、testing／CI、documentation與future-direction結論，並在Audit Review Gate明確判定A／B／C／D disposition。

**Architecture:** Audit採matrix-before-remediation。A1先鎖定exact baseline與authority ledger，A2～A7分區建立只讀evidence與central findings，A8依template-level value評估future directions，A9執行cross-Task consistency、fresh validation與最終disposition。所有current authority、production source、tests、workflow與platform configuration在Audit Review Gate前保持不變。

**Tech Stack:** Git、Flutter／Dart、Melos、Python unittest、repository documentation checker、GitHub Actions static contracts、Drift schema／migration tests、Windows Git Bash、既有Android／iOS／managed artifact runtime evidence。

## Global Constraints

- Base authority：Template Baseline `1.14.0`，initial base commit `b3c71b6264227050180ffb5be62b14bbfb8e19aa`。
- Branch：`audit/template-baseline-1.14-project-holistic`；不得在`main`直接執行Audit mutations。
- Audit-only：A1～A9只建立audit evidence、findings與final review，不修改production source、tests、workflows、platform configuration、ADR、current capability claim、Roadmap disposition、Backlog disposition、VERSION或CHANGELOG。
- No remediation：看到finding不得順手修正；只記錄evidence、severity、risk與建議route。
- No release：本Audit不提升Template Baseline、不建立release commit、不執行post-release closure。
- No destructive action：不得刪除branch／worktree、GitHub artifacts／caches、managed local artifacts、tests、fixtures、goldens或historical evidence。
- No external activation：不得啟用Firebase collection、controlled event、production signing、Store workflow、physical-device flow或任何credential-backed provider操作。
- Historical boundary：Historical final reviews只作bounded evidence，不覆蓋current source／tests／workflows／current authority。
- Finding authority：`docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`是完整finding正文唯一owner；各Task evidence文件只引用Finding ID。
- Every formal Task：focused review → findings／fix evidence defects → fresh re-review → whole-Task review → authority check → required validation → independent commit。
- Commit discipline：每個Task commit前先執行`git status --short`，只stage該Task列出的artifact，執行`git diff --cached --check`後才使用Plan指定message；不得順帶stage其他Task或current authority變更。
- Stop only for：使用者scope／architecture decision、external／manual blocker、推翻accepted Design／Plan的P0／P1，或A9 Audit Review Gate。

---

## File and Artifact Map

### Planning artifacts

- Design：`docs/superpowers/specs/2026-07-31-template-baseline-1.14-project-holistic-audit-design.md`
- Design review：`docs/audits/template_baseline_1_14_project_holistic_audit_design_review.md`
- Plan：`docs/superpowers/plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md`
- Plan review：`docs/audits/template_baseline_1_14_project_holistic_audit_plan_review.md`

### Audit evidence directory

```txt
docs/audits/template_baseline_1_14_project_holistic_audit/
  a1_repository_baseline_authority_evidence.md
  a2_architecture_dependency_boundaries.md
  a3_template_capability_matrix.md
  a4_critical_runtime_data_flows.md
  a5_security_platform_claims.md
  a6_testing_ci_sustainability.md
  a7_documentation_authority.md
  findings.md
  a8_future_direction_disposition.md
  a9_holistic_final_review.md
```

不得預先建立空白placeholder。每份檔案在對應Task首次需要時建立。

### Temporary evidence

所有machine-generated inventory、classifier output與read-only GitHub storage inventory寫入checkout外temp路徑，例如：

```txt
%TEMP%\flutter_architecture_audit_1_14\
```

Temporary evidence不得提交。只有經semantic整理的matrix、counts、commands、result與hash可進audit文件。

---

## Task A0-P — Audit Execution Plan

**Files:**

- Create: `docs/superpowers/plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md`
- Create: `docs/audits/template_baseline_1_14_project_holistic_audit_plan_review.md`
- Modify: `docs/superpowers/README.md`
- Modify: `docs/audits/README.md`

**Consumes:**

- Accepted Design `template-baseline-1-14-project-holistic-audit-design`。
- Design review finding `F-A0-D01`與validation recovery evidence。

**Produces:**

- Exact A1～A9 file scope、commands、validation、stop conditions與commit boundaries。
- Proposed Plan artifact，等待使用者明確核准。

- [ ] 對照Design逐項確認Requirement Decision、Goals、Non-goals、Capability Classification、Finding Contract、A1～A9、Existing Evidence Reuse、Artifact Ownership與Final Disposition Model都有對應Plan Task。
- [ ] 檢查Plan沒有未完成標記、空白placeholder、模糊的「適當驗證」或未定義artifact path。
- [ ] 完成focused Plan review；任何P0／P1 planning finding必須修正並fresh re-review。
- [ ] 執行：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] 建立proposal commit：

```bash
git add docs/superpowers/plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md \
  docs/audits/template_baseline_1_14_project_holistic_audit_plan_review.md \
  docs/superpowers/README.md docs/audits/README.md
git commit -m "docs(audit): 建立模板專案總審查執行計畫"
```

- [ ] 停在使用者Plan approval gate。Plan維持`proposed`時不得開始A1。
- [ ] 使用者核准後，將Plan與Plan review狀態更新為`accepted`，記錄exact approval，fresh rerundocs validation並建立獨立approval commit：

```bash
git commit -m "docs(audit): 核准模板專案總審查執行計畫"
```

**Task acceptance:** Plan accepted、Open P0=0、Open P1 without disposition=0、工作樹乾淨。只有此時A1可開始。

---

## Task A1 — Repository Baseline, Authority and Evidence Ledger

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a1_repository_baseline_authority_evidence.md`
- Create on first confirmed finding: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md` only to add stable directory routing after evidence exists.

**Consumes:**

- `AGENTS.md`
- `VERSION`
- `docs/README.md`
- `docs/project_context.md`
- `docs/roadmap.md`
- `docs/roadmap/active.md`
- `docs/roadmap/candidates.md`
- `docs/backlog.md`
- `CHANGELOG.md`
- `docs/milestones/README.md`
- Milestone 30～32 final／post-release evidence。

**Produces:**

- Exact Git／release／worktree baseline。
- Authority owner map。
- Reusable／missing evidence ledger。
- Repository hygiene findings，例如已合併branch／worktree殘留，但不執行cleanup。

- [ ] 重新執行exact baseline commands並將完整結果摘要落檔：

```bat
git status --short --branch
git rev-parse HEAD
git log -5 --oneline
git ls-remote origin refs/heads/main
git branch --format="%(refname:short)"
git worktree list --porcelain
git for-each-ref --format="%(refname:short) %(objectname) %(upstream:short)" refs/heads refs/remotes/origin
```

- [ ] 對每個non-main local branch執行下列exact PowerShell loop：

```powershell
powershell -NoProfile -Command "$branches = git for-each-ref --format='%(refname:short)' refs/heads; foreach ($branch in $branches) { if ($branch -ne 'main') { Write-Host ('=== ' + $branch + ' ==='); git rev-list --left-right --count ('main...' + $branch); git log --oneline --decorate -5 $branch } }"
```

只記錄ancestry、dirty state與unpublished content；不得刪除、reset、rebase或fast-forward branch。

- [ ] 建立authority owner map，至少包含：Agent policy、Human entry、Current snapshot、ADR、Roadmap、Backlog、Design／Plan、Audit、Guides、VERSION、CHANGELOG、source／tests／CI／runtime evidence。
- [ ] 對Milestone 18、30、31、32標記「可重用範圍」與「不能替代本Audit的範圍」。
- [ ] 將已確認矛盾或repository hygiene寫入central findings register；初步疑點未經semantic確認前標記為candidate，不建立finding。
- [ ] Focused validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Whole-Task review確認A1沒有把historical review冒充current authority，也沒有修改current state。
- [ ] Commit：

```bash
git commit -m "docs(audit): 建立repository基線與authority evidence"
```

**Stop condition:** HEAD／origin main／release identity若與accepted Plan baseline不一致，先只讀分析差異；需要重定義scope時停止。一般branch殘留不停止。

---

## Task A2 — Architecture and Dependency Boundary Audit

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a2_architecture_dependency_boundaries.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- `docs/adr/README.md`
- ADR-001、004、005、006、007、008、010、012、013、015、017、020、021、022、023、024、025、026、027。
- App／Package／Feature README。
- Root／App／Package `pubspec.yaml`。
- App DI、Router、Guard、navigation coordinator、database opener、reporting與connectivity composition source。
- Package public barrels、DataSource、Repository、UseCase與Session source。

**Produces:**

- Repository dependency graph。
- App／Feature／Package responsibility matrix。
- Composition Root、DI、Bloc、Route Guard、API client、Drift、platform adapter、Failure／Observability ownership conclusion。
- Confirmed architecture findings與Not-an-issue dispositions。

- [ ] 建立tracked production file與package dependency inventory：

```bat
git ls-files "apps/flutter_architecture/lib/**/*.dart" "packages/*/lib/**/*.dart"
git grep -n -E "package:(get_it|injectable)/" -- packages/*/lib
git grep -n "package:flutter_architecture/features/" -- apps/flutter_architecture/lib/features
git grep -n -E "package:[a-z_]+/src/" -- apps/flutter_architecture/lib packages/*/lib
git grep -n "package:dio/dio.dart" -- apps/flutter_architecture/lib packages/*/lib
git grep -n -E "package:(firebase_|connectivity_plus|flutter_secure_storage|local_auth)" -- apps/flutter_architecture/lib packages/*/lib
git grep -n -E "package:(sqflite|sqflite_common_ffi)" -- apps/flutter_architecture/lib packages/*/lib
```

Command無match時以exit 1／empty output記錄為expected no-match，不把它誤判為tool failure。

- [ ] 讀取並追蹤代表性production call chains：

```txt
Bootstrap → AppConfig → DI → App
AuthGuard → SessionManager
Login／OTP／Restore／Logout → UseCase → Repository → DataSource／Store
401 → AuthRefreshInterceptor → AuthSessionRefresher → persistence-first rotation
Catalog Bloc → UseCase → Repository → Remote／Local → Drift DAO
Connectivity adapter → Controller → Scope → Catalog opt-in revalidation
Error boundary → ErrorReporter → Firebase reference adapter
```

- [ ] 專門判斷`packages/auth`直接依賴Dio是否為受控third-party exception seam或API ownership leak；必須同時查看API abstraction、exception mapping、public exports、tests與ADR-013／020，不得只靠grep定案。
- [ ] 執行focused architecture／DI tests：

```bat
dart run melos exec --scope=auth -- flutter test
dart run melos exec --scope=api_client -- flutter test
cd apps\flutter_architecture
flutter test test\app\di test\app\router test\app\navigation
cd ..\..
```

- [ ] 對每個初始疑點給出Confirmed、Not an issue或Needs A4／A5 evidence，並更新findings register。
- [ ] Whole-Task review確認沒有把style preference或同package內`src` import誤判為consumer deep import。
- [ ] Validation：focused tests、docs checker、`docs_check`、`git diff --check`。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成架構與dependency boundary審查"
```

**Stop condition:** 若current implementation確定推翻stable ADR且形成P0／P1，記錄完整evidence並停止於使用者architecture gate；不得直接修改ADR或source。

---

## Task A3 — Template Capability Inventory and Classification

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a3_template_capability_matrix.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- `README.md`
- `docs/project_context.md`
- App／Package／Feature README。
- Relevant canonical ADR、source、tests與final reviews。
- A1 evidence ledger與A2 architecture matrix。

**Produces:**

- 一列一能力的current capability matrix。
- 每項能力的classification、owner、production path、test owner、runtime evidence、adopter action與non-goals。

- [ ] Matrix至少包含：Authentication、Refresh Token、OTP、Biometric Unlock、Secure Storage、Networking、Pagination、Search、Offline Cache、Connectivity、Drift persistence、Localization、Design System、Exception／Failure、Observability、Android、iOS、Web、Windows、macOS、Linux、CI/CD、Testing Governance、Development Workflow Governance、Template Product Identity Adoption。
- [ ] 每列固定欄位：

```txt
Capability
Classification
Contract owner
Production／reference path
Primary test owner
Build／runtime evidence
Adopter action required
Known limitations／non-goals
Finding IDs
```

- [ ] 只能使用Design定義的六種classification；不得新增模糊的`mostly ready`、`partial supported`或`production-ish`。
- [ ] 對外部provider與產品接入能力，明確區分repository implementation與adopter activation。
- [ ] 對平台，區分dependency-ready、tracked runner、static build、runtime smoke、physical-device、signing與distribution。
- [ ] 將claim矛盾更新central findings；只有metadata較舊但semantic正確時記為review evidence，不建立finding。
- [ ] Focused review逐列抽查至少一個contract owner與一個primary test owner；高風險Auth、Drift、Observability、CI與iOS需檢查全部evidence欄位。
- [ ] Validation：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Commit：

```bash
git commit -m "docs(audit): 建立Template 1.14能力分類矩陣"
```

**Stop condition:** Evidence不足時降低classification或標記finding，不要求外部credential補證明。

---

## Task A4 — Critical Runtime, Data and Integration Flow Audit

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a4_critical_runtime_data_flows.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- Auth、API client、Catalog、Connectivity、Drift、Failure／Observability production source。
- Relevant package／App tests。
- Milestone 19～21、27～30 bounded review evidence。
- A2／A3 matrices。

**Produces:**

- Runtime scenario matrix：expected contract、production path、existing test evidence、coverage gap、finding。
- Current／historical persistence boundary conclusion。

- [ ] Auth matrix至少涵蓋：Login authenticated、OTP challenge、Verify、Resend replacement、Restore、Logout、invalid refresh cleanup、temporary refresh、concurrent 401、safe replay、relogin／account switch stale completion、secure credential migration、corruption、local unlock cold start與resume grace。
- [ ] Catalog matrix至少涵蓋：initial cache hit／miss、stale SWR、refresh replacement、append retained cache／remote fallback、revision CAS、cursor cycle、query generation、reconnect dedupe、non-blocking failure、logout cache preservation。
- [ ] Persistence matrix至少涵蓋：fresh schema、v1～v6 migration、rollback、foreign key、single AppDatabase、AuthUser single-row、Catalog chain invariants、Web explicit reset與historical sqflite boundary。
- [ ] Failure／Observability matrix至少涵蓋：expected Failure、unknown error identity／stack、cancellation、protocol violation、degraded reporting、sensitive data redaction、provider failure isolation。
- [ ] 執行focused tests：

```bat
dart run melos exec --scope=auth -- flutter test
dart run melos exec --scope=api_client -- flutter test
cd apps\flutter_architecture
flutter test test\features\auth test\app\auth test\app\navigation
flutter test test\features\catalog test\app\connectivity
flutter test test\app\database
cd ..\..
```

- [ ] 執行historical／schema commands，使用repository current owners，不修改fixtures：

```bat
python -m unittest tools.testing.test_test_inventory
bash tools/ci/verify_generated.sh
```

Windows必須使用`C:\Program Files\Git\bin\bash.exe`，不得使用WSL bash跨讀Windows Git worktree。

- [ ] 每個coverage gap需判斷是P1／P2、intentional non-goal、historical-only或Not an issue。
- [ ] Whole-Task review確認沒有因test count高就宣稱coverage完整，也沒有因單一focused test失敗就直接修改source。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成關鍵runtime與資料流程審查"
```

**Stop condition:** Fresh test若揭露確定runtime P0／P1，保持Task open、記錄完整failure output與reproduction；不得修正production。

---

## Task A5 — Security and Platform Claim Audit

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a5_security_platform_claims.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- ADR-022～026。
- Android／iOS／Web tracked configuration。
- Product identity manifest與adoption guide。
- Observability policy、build／symbol scripts與runtime evidence。
- A1 evidence ledger、A3 capability matrix、A4 runtime matrix。

**Produces:**

- Security capability／threat boundary matrix。
- Android、iOS、Web、Windows、macOS、Linux platform claim matrix。
- Overclaim／underclaim findings。

- [ ] Security matrix至少分開：credential-at-rest、server OTP、local biometric user presence、Device Binding、Passkey、root／jailbreak、runtime memory、server compromise、SIM-swap／phishing、provider privacy／retention。
- [ ] Platform matrix固定欄位：tracked scaffold、dependency support、static contract、host build、runtime smoke、physical device、signing、distribution、current classification、finding IDs。
- [ ] 驗證tracked scaffold：

```bat
if exist apps\flutter_architecture\android echo android=present
if exist apps\flutter_architecture\ios echo ios=present
if exist apps\flutter_architecture\web echo web=present
if exist apps\flutter_architecture\windows echo windows=present
if exist apps\flutter_architecture\macos echo macos=present
if exist apps\flutter_architecture\linux echo linux=present
git ls-files apps/flutter_architecture/android apps/flutter_architecture/ios apps/flutter_architecture/web
```

- [ ] 執行platform／security static contracts：

```bat
python -m unittest discover -s tools/ci -p "test_*.py"
python -m unittest tools.docs.test_check_docs
```

- [ ] Android／iOS runtime claim優先使用exact current-main remote runs與Milestone 32 managed evidence；只有evidence SHA、configuration或current source不再對應時，才提出fresh platform validation blocker。
- [ ] Read-only檢查GitHub Actions storage，可使用：

```bat
mkdir "%TEMP%\flutter_architecture_audit_1_14" 2>nul
gh auth status
python tools/ci/github_storage_cleanup.py inventory --repository MagicalWater/flutter_architecture --output "%TEMP%\flutter_architecture_audit_1_14\github-storage.json"
```

只允許`inventory`；不得執行`manifest`或`delete`。若`gh auth status`失敗，記錄external evidence blocker並保留既有Milestone 32／current-main evidence，不要求、生成或保存新token。

- [ ] Whole-Task review確認Supported不等於physical-device、signed、Store-ready；Firebase reference adapter不等於adopter production privacy完成。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成安全與平台claim審查"
```

**Stop condition:** 需要Apple／Google account、keystore、provider secret、physical device或controlled event時記錄external evidence gap，不要求或使用credential。

---

## Task A6 — Testing and CI Sustainability Audit

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a6_testing_ci_sustainability.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- `docs/guides/testing_governance.md`
- `docs/guides/ci_cd_operations.md`
- Milestone 30 inventory／deletion／final evidence。
- Current tests、tools／CI contracts、classifier、workflows與artifact store source。
- A1、A3、A4、A5 matrices。

**Produces:**

- Current／historical test ownership matrix。
- Duplicate／fragile／implementation-detail candidate register。
- CI classifier path coverage與execution sustainability conclusion。
- Managed artifact retention、capacity、pin、cleanup與GitHub no-growth conclusion。

- [ ] 生成fresh inventory到temp，避免覆寫tracked Milestone 30 baseline：

```bat
mkdir "%TEMP%\flutter_architecture_audit_1_14" 2>nul
python tools/testing/inventory.py --root . --output "%TEMP%\flutter_architecture_audit_1_14\test-inventory.csv"
python -m unittest tools.testing.test_test_inventory
```

- [ ] 比較tracked test files、LOC、static cases與primary categories；數量差異只作導航，不作刪除理由。
- [ ] 依testing governance抽查Auth、Catalog、Database、CI、Docs、Platform、Golden與Historical owner，確認current behavior不依賴historical implementation。
- [ ] 執行完整Python CI contracts：

```bat
python -m unittest discover -s tools/ci -p "test_*.py"
```

- [ ] 以temp output驗證classifier scenarios，不修改workflow：

```bat
python tools/ci/change_classifier.py --event push --base b3c71b6264227050180ffb5be62b14bbfb8e19aa --head HEAD --output "%TEMP%\flutter_architecture_audit_1_14\classifier.txt"
```

另外以existing unit tests確認docs-only、Dart source、Android、iOS、database、workflow、unknown path與invalid range fail-safe。

- [ ] Review四份workflow是否仍遵守execution mode、trusted PR denial、stable check、documentation no-op、artifact transport與cache prohibition contract。
- [ ] Reviewmanaged artifact store source與Task 32 evidence，確認retention、capacity、pin、trash／restore／purge與secret scanner沒有平行authority。
- [ ] 對疑似重複或implementation-detail tests只能提出candidate finding；不得修改、合併或刪除。
- [ ] Whole-Task review確認self-hosted可維護性、runner offline no-fallback、GitHub storage重新成長風險與operator burden均有disposition。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成測試與CI可持續性審查"
```

**Stop condition:** Test failure或classifier defect保持Task open並記錄；不修改test／CI source。任何cleanup需新Requirement Decision。

---

## Task A7 — Documentation and Current Authority Audit

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a7_documentation_authority.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- `docs/governance/documentation_policy.md`
- `docs/README.md`
- Root／App／Package／Feature README。
- `docs/project_context.md`
- ADR index與relevant canonical ADR。
- Roadmap、active、candidates、backlog。
- Milestone／Audit／Superpowers indexes。
- Guides、VERSION、CHANGELOG與docs checker source／tests。

**Produces:**

- Current authority graph。
- Stale current-tense、parallel／duplicate authority、routing、metadata與navigation findings。
- Document growth／maintenance assessment。

- [ ] 建立managed document inventory：path、document_type、status、authoritative_for、last_reviewed_baseline、current／historical role。
- [ ] Semantic review已知initial candidates：

```txt
docs/README.md canonical ADR authority與legacy placeholder wording
docs/milestones/README.md Active routing仍列Completed Milestone 32
README.md Milestone 5 future-tense MVP closure
docs/roadmap/candidates.md Completed Milestone 32段落
docs/project_context.md current-only與歷史Milestone敘事比例
local README／ADR metadata較舊但內容是否仍current
```

- [ ] 對每項candidate必須給出Confirmed、Not an issue、Historical context acceptable或Needs remediation；不得只依baseline number定案。
- [ ] 執行：

```bat
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

- [ ] Review docs checker是否能捕捉已確認的current authority defect；缺少checker不自動等於需要新增checker，先評估failure recurrence與false positive成本。
- [ ] 評估文件量是合理history preservation、索引過度膨脹或current snapshot重新累積journal；提出有界navigation／archive／rewrite建議，不執行。
- [ ] Whole-Task review確認Audit本身沒有成為第二份Project Context或Roadmap。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成文件與current authority審查"
```

**Stop condition:** 即使確認P1 stale authority，也只記錄finding並進A8／A9，不直接修改current文件。

---

## Task A8 — Future Direction and Candidate Disposition

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a8_future_direction_disposition.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`

**Consumes:**

- A1～A7 evidence與findings。
- `docs/roadmap/candidates.md`
- `docs/backlog.md`
- Current template positioning與maintenance cost。

**Produces:**

- 每個future direction的正式建議：Promote candidate、Keep candidate、Keep deferred、Return backlog、Reject。
- 重新評估trigger與必要前置證據。
- 是否存在C類下一Milestone候選的provisional conclusion。

- [ ] 對下列每項建立同一格式decision record：

```txt
Additional Platform Support（Web／Windows／macOS／Linux分開評估）
WebSocket example
Notification
Payment
Analytics／Event Governance
Production signing／Store distribution
Device Binding／Passkey
```

- [ ] 每項固定欄位：problem evidence、template-level value、product-specific risk、existing foundation、missing prerequisite、maintenance cost、security／privacy／platform impact、recommended disposition、re-evaluation trigger。
- [ ] Additional Platform Support不得一次綁成四平台Milestone；每個平台獨立計算runner、plugin、artifact、runtime與maintenance成本。
- [ ] Analytics與Observability保持分離；Notification、Payment、Device Binding與Passkey不得因現有Auth／Firebase foundation就自動提升。
- [ ] Production signing／Store distribution需區分「模板可提供安全流程」與「產品credential／account owner責任」。
- [ ] 判斷是否有任何direction同時滿足：confirmed gap、stable boundary、reproducible failure、template-level reusable value、acceptance criteria與合理成本。
- [ ] 將方向性finding與P2／P3 disposition更新central register；不要修改Roadmap／Backlog current authority。
- [ ] Validation：docs checker、`docs_check`、`git diff --check`。
- [ ] Commit：

```bash
git commit -m "docs(audit): 完成後續方向與candidate disposition"
```

**Stop condition:** Candidate promotion或formal Reject只形成A9提案；使用者未核准前不修改current Roadmap／Backlog。

---

## Task A9 — Holistic Synthesis, Fresh Validation and Audit Review Gate

**Files:**

- Create: `docs/audits/template_baseline_1_14_project_holistic_audit/a9_holistic_final_review.md`
- Modify: `docs/audits/template_baseline_1_14_project_holistic_audit/findings.md`
- Modify: `docs/audits/README.md` only to finalize stable routing and status summary.
- Do not modify: `README.md`, `docs/project_context.md`, `docs/roadmap*.md`, `docs/backlog.md`, ADR, source, tests, workflows, platform configuration, `VERSION`, `CHANGELOG.md`。

**Consumes:**

- A1～A8全部evidence與findings。
- Exact current branch／base SHA與current main remote evidence。
- Existing release／clean-checkout／platform runtime evidence。

**Produces:**

- Cross-Task consistency review。
- Fresh repository validation result。
- All finding disposition table。
- A／B／C主要結論與可附帶D類方向處置。
- Approved remediation proposal、accepted risk、deferred、rejected與maintenance criteria。
- 使用者Audit Review Gate。

- [ ] Freeze finding set：每個finding必須有ID、severity、status、evidence、current contract、observed state、risk、recommendation、baseline blocking、disposition、target route與verification required。
- [ ] 確認Open P0=0；每個P1都有Resolved proposal、capability downgrade proposal或Accepted-risk proposal。Audit-only階段可尚未修正，但不得無disposition。
- [ ] 執行fresh Windows repository validation：

```bat
dart pub get
python -m unittest tools.testing.test_test_inventory
python -m unittest discover -s tools/ci -p "test_*.py"
python -m unittest tools.docs.test_check_docs
dart run melos run docs_check
dart run melos run analyze
dart run melos exec -- flutter test
"C:\Program Files\Git\bin\bash.exe" tools/ci/verify_generated.sh
```

- [ ] 只有在A5／A6確認Android current evidence不足時，才執行fresh representative build；否則記錄exact reused evidence與理由。需要時使用：

```bat
"C:\Program Files\Git\bin\bash.exe" tools/ci/build_android_development.sh
set API_BASE_URL=https://api.example.com
"C:\Program Files\Git\bin\bash.exe" tools/ci/build_android_production.sh
```

`API_BASE_URL`只使用非credential、非localhost、HTTPS example domain；artifact仍是verification-only。

- [ ] iOS使用current-main exact remote／managed evidence；只有SHA、configuration、toolchain或source contract不對應時，才建立Mac fresh-validation blocker，不自行宣稱通過。
- [ ] Cross-check A2 architecture、A3 capability、A4 runtime、A5 security／platform、A6 testing／CI、A7 documentation與A8 future direction是否互相矛盾。
- [ ] 根據Design criteria選擇：

```txt
A. 成熟完成／maintenance
B. 有界hardening／無新Milestone
C. 足夠價值／提出新Milestone
D. 部分candidate／backlog Reject或Deferred
```

- [ ] 列出remediation proposal，但不執行。每項remediation必須預估重新分類Level、artifact、regression與是否需要release。
- [ ] Whole-Audit review與fresh docs validation通過後建立commit：

```bash
git commit -m "docs(audit): 完成Template 1.14整體總審查"
```

- [ ] 停在使用者Audit Review Gate。不得自動開始remediation、Roadmap修改、Milestone promotion、merge、push或worktree cleanup。

**Task acceptance:** All areas reviewed；Open P0=0；Open P1 without disposition=0；fresh required validation有exact result；A／B／C／D結論明確；working tree clean。

---

## Execution and Review Model

### Recommended execution

在目前ChatGPT＋bridge workflow中使用`executing-plans`逐Task執行，因A1～A9共享同一central findings register與逐步收斂的evidence ledger。每個Task仍使用fresh focused review與independent commit，不以大批次一次完成。

若執行環境具備真正隔離的subagent能力，可使用`subagent-driven-development`，但subagent只處理當前Task；central findings、accepted Design／Plan、authority與stop conditions不得分散到平行subagent。

### Commit boundaries

```txt
Design commit（已完成）
Plan proposal commit
Plan approval commit
A1 baseline／authority
A2 architecture
A3 capability
A4 runtime／data
A5 security／platform
A6 testing／CI
A7 documentation
A8 future direction
A9 holistic final audit
```

不得將多個Audit Task壓成單一commit，也不得在A9回寫早期Task當時未通過的validation。

## Plan Acceptance Gate

本Plan目前狀態為`proposed`。只有在：

1. Plan focused review與whole-Plan review通過。
2. Documentation checker、`docs_check`與`git diff --check`fresh通過。
3. Open P0=0、Open P1 without disposition=0。
4. 使用者明確核准本Plan。
5. Plan與Plan review更新為`accepted`並建立approval commit。

之後，才可開始Task A1。
