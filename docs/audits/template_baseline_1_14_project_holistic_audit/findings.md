---
document_type: phase-review
status: active
authoritative_for:
  - template-baseline-1-14-project-holistic-audit-findings
last_reviewed_baseline: 1.14.0
---

# Template Baseline 1.14.0 Project Holistic Audit Findings

本文件是本Audit完整finding正文的唯一authority。各A1～A9 evidence只引用Finding ID，不複製或分叉finding disposition。

本register保留A9原始finding內容，並由後續Requirement Decision更新status。`Open`表示問題仍待處理；`Resolved by R1`表示已由R1獨立Design／Plan、Task review、validation與commit evidence完成修復。

## Finding Register

### F-A1-01 — Completed Milestone 32位於Active routing

- Severity：P1。
- Status：Resolved by R1。
- Resolution evidence：R1-1 commit `621a1a0f59966f0837e75648707601233e34a8ab`；`docs/audits/r1_current_authority_contradiction_closure/r1_1_milestone_candidate_authority_review.md`；R1 holistic final review。
- Evidence：`docs/milestones/README.md`的Status rule以`docs/roadmap/active.md`為準；active authority為None，但`## Active routing`仍列Completed Milestone 32。
- Current contract：Milestone index只保存正確名稱、status與artifact route，不成為第二份Roadmap。
- Observed state：Completed item被放在Active section，closed table只到Milestone 31。
- Risk：Agent／maintainer可能誤判Milestone 32仍active，導致錯誤讀取與執行route。
- Recommendation：將Milestone 32移入Closed milestone routing，Active routing明確顯示None。
- Baseline blocking：No；1.14.0 release identity仍一致。
- Disposition：Bounded documentation hardening candidate。
- Target route：後續Level 2或Level 3 documentation authority remediation，由Requirement Decision確認。
- Verification required：docs checker、`docs_check`、Milestone／active semantic consistency review。

### F-A1-02 — Documentation Hub錯誤降級canonical ADR目錄

- Severity：P1。
- Status：Resolved by R1。
- Resolution evidence：R1-2 commit `0d3387a7b650e79d58eb84fbceba230bc24bcc71`；`docs/audits/r1_current_authority_contradiction_closure/r1_2_documentation_hub_adr_routing_review.md`；R1 holistic final review。
- Evidence：`docs/README.md`前段定義`docs/adr/README.md`與canonical records為正式Architecture Decision authority；Legacy段落把整個`docs/adr/`稱為placeholder與非正式ADR集合。
- Current contract：Milestone 23後canonical ADR files與ADR index是stable authority。
- Observed state：同一current documentation hub提供互斥routing。
- Risk：Architecture task可能跳過正確ADR，改讀superseded aggregate／legacy guidance。
- Recommendation：把Legacy wording限制到真正legacy file／subpath，保留`docs/adr/README.md`與canonical ADR authority。
- Baseline blocking：No；source與ADR files本身未因此改變。
- Disposition：Bounded documentation hardening candidate。
- Target route：後續documentation authority remediation。
- Verification required：ADR links、docs checker、task-based reading route semantic review。

### F-A1-03 — Completed Milestone 32保留在Candidate authority

- Severity：P2。
- Status：Resolved by R1。
- Resolution evidence：R1-1 commit `621a1a0f59966f0837e75648707601233e34a8ab`；`docs/audits/r1_current_authority_contradiction_closure/r1_1_milestone_candidate_authority_review.md`；R1 holistic final review。
- Evidence：`docs/roadmap/candidates.md`自述只保存尚未核准為active的candidate，卻含`Completed — Milestone 32`及完整closure routing。
- Current contract：Completed／Archived routing由Milestone index、final review、CHANGELOG與VERSION擁有。
- Observed state：Candidate authority同時保存completed item。
- Risk：Candidate list語意與navigation膨脹，形成重複closed routing。
- Recommendation：移除completed正文，只在Git history／audit handoff保留過去candidate脈絡。
- Baseline blocking：No。
- Disposition：Bounded documentation cleanup candidate。
- Target route：與F-A1-01／02同批處理。
- Verification required：Roadmap candidate count、links、`docs_check`與semantic review。

### F-A1-04 — 已合併Milestone 32 branch與worktree殘留

- Severity：P3。
- Status：Open／Operator hygiene proposed。
- Evidence：`milestone-32-ci-artifact-storage-cutover` local branch HEAD `bc5bc17`完全為main ancestor；managed worktree仍存在且先前確認clean。
- Current contract：Completed worktree沒有必須永久保留的runtime authority；cleanup必須由明確operator action執行。
- Observed state：沒有遺失commit或dirty content，但branch／worktree仍出現在日常列表。
- Risk：誤入舊worktree、錯誤branch操作與維護噪音。
- Recommendation：在本Audit review後由使用者獨立核准安全cleanup；先重新確認clean與ancestry。
- Baseline blocking：No。
- Disposition：Maintenance hygiene；不得在Audit-only階段執行。
- Target route：Level 1 operator cleanup或Audit closure後獨立指令。
- Verification required：`git status`、`git rev-list main...branch`、worktree removal與branch deletion後列表確認。

### F-A2-01 — Dio type穿出`api_client`進入`auth` package

- Severity：P2。
- Status：Open／Architecture hardening proposed。
- Evidence：`packages/auth/pubspec.yaml`直接依賴Dio；`AuthRemoteDataSource`與`AuthRefreshRemoteDataSource`捕捉`DioException`並讀取response；`api_client` public barrel exportDio-specific mapper。
- Current contract：ADR-013要求一般Feature／Repository／DataSource透過API abstraction隔離transport exception，Dio不得穿透`packages/api_client` boundary。
- Observed state：Endpoint invocation仍透過Retrofit API abstraction，但transport exception type與raw response interpretation進入Auth package。
- Risk：Auth package與Dio／response shape耦合，替換transport、重用package或演進error envelope時需要跨package同步修改。
- Recommendation：在`api_client`建立transport-neutral typed endpoint exception／error envelope，或在API implementation boundary先完成Dio mapping；Auth只依賴Auth-owned backend failure metadata與core `AppException`。
- Baseline blocking：No；154 Auth、55 API client、22 App DI／Router／Navigation focused testsfresh通過，未見runtime failure。
- Disposition：Bounded architecture hardening candidate，不足以單獨建立Milestone。
- Target route：後續Level 3 architecture refactor Requirement Decision；若與其他boundary findings合併才重新評估Level 4。
- Verification required：先新增transport-neutral contract tests，再移除Auth Dio dependency，跑Auth／API client／App DI全量與analyze。

### F-A6-01 — Test inventory CLI無法輸出至repository外absolute path

- Severity：P2。
- Status：Open／Tooling hardening proposed。
- Evidence：`python tools/testing/inventory.py --root . --output <system-temp>/test-inventory.csv`先寫出CSV，之後在`output.relative_to(root)`拋出`ValueError`並exit 1；輸出位於repository內ignored path時成功。
- Current contract：Testing Governance把inventory視為可重現盤點工具；本Audit accepted Plan明確要求temp output以避免覆寫tracked Milestone 30 baseline。
- Observed state：CLI實際限制output必須位於root下，但argument help／implementation沒有宣告此限制，且錯誤發生在成功寫檔後。
- Risk：Audit、CI或維護腳本使用absolute temp path時收到false failure；也可能留下已寫出但被誤認為無效的CSV。
- Recommendation：不要限制output必須在root下；summary對root內路徑顯示relative path，root外顯示resolved absolute path，並新增outside-root output unit test。
- Baseline blocking：No；ignored in-repository temp route成功產生144 files／25,732 LOC／887 cases，current tests與CI不依賴external output。
- Disposition：Bounded Level 2 tooling bugfix candidate，可與documentation authority hardening分開處理。
- Target route：後續Requirement Decision後以TDD修正`tools/testing/inventory.py`與`test_test_inventory.py`。
- Verification required：RED outside-root test、existing inventory tests、tracked baseline不變、system-temp command exit 0、docs check。

### F-A7-01 — Root README保留Milestone 5 future-tense MVP流程

- Severity：P2。
- Status：Resolved by R1。
- Resolution evidence：R1-3 commit `a4752c958fd752add492b98e4ac351428a43d0b0`；`docs/audits/r1_current_authority_contradiction_closure/r1_3_human_entry_design_plan_index_review.md`；R1 holistic final review。
- Evidence：Root README頂部宣告Phase 1／MVP Completed與Baseline 1.14.0；後段仍寫「第一階段MVP完成前，Milestone 5會以Release Candidate方式收尾」及5-1～5-3 future flow。
- Current contract：Root README是human current entry，應提供current positioning與快速開始，不把已完成初期流程寫成現在即將執行的instruction。
- Observed state：同一文件同時宣告MVP完成與M5尚待收尾。
- Risk：新採用者誤以為template仍在第一階段release candidate，而非1.14.0 maintenance baseline。
- Recommendation：移除過期future section，或壓縮為明確historical note並連到archive／CHANGELOG。
- Baseline blocking：No；頂部version、platform與current capability正確。
- Disposition：與current authority documentation hardening同批處理。
- Target route：Level 2／3 documentation remediation。
- Verification required：README semantic review、docs checker、VERSION／CHANGELOG一致性與quick-start navigation。

### F-A7-02 — Project Context current-only snapshot重新累積Milestone journal

- Severity：P2。
- Status：Open／Current snapshot rationalization proposed。
- Evidence：`docs/project_context.md`宣稱不保存逐Milestone journal，但421行內容含15次Milestone reference及13個以Milestone編號開頭的chronological paragraphs。
- Current contract：Current snapshot只描述仍有效baseline、architecture、capability、limitations、active work與routing；歷史演進由Milestone／Audit／CHANGELOG擁有。
- Observed state：Milestone 19～30完成、封存、當時baseline與後續演進被逐段保留在current snapshot。
- Risk：固定最小讀取集持續膨脹、current fact與historical narrative混合、每個新Milestone都需追加journal。
- Recommendation：保留current capability／limitation，將Milestone chronology移出current snapshot；latest completed initiative只保留一行與authority link。
- Baseline blocking：No；現有敘述大多仍正確，但責任與增長模式偏離policy。
- Disposition：Bounded documentation architecture hardening。
- Target route：Level 3 semantic rewrite，需section-by-section preservation review，不做機械刪除。
- Verification required：Current capability matrix對照、link review、docs check、固定讀取集可用性review。

### F-A7-03 — Superpowers index把已完成Milestone 31寫成proposed待recovery

- Severity：P1。
- Status：Resolved by R1。
- Resolution evidence：R1-3 commit `a4752c958fd752add492b98e4ac351428a43d0b0`；`docs/audits/r1_current_authority_contradiction_closure/r1_3_human_entry_design_plan_index_review.md`；R1 holistic final review。
- Evidence：`docs/superpowers/README.md`仍稱M31 Design／Plan降回`proposed`並等待recovery；實際Spec／Plan metadata為accepted，31-r11明確記錄user-approved及Completed／Archived。
- Current contract：`docs/superpowers/README.md`是Design／Plan routing index，摘要必須與linked artifact lifecycle及closure evidence一致。
- Observed state：Current index與current artifact metadata／post-release authority互相矛盾。
- Risk：Agent可能錯誤重做M31 Design／Plan、拒絕使用已核准governance，或把completed recovery當作未核准implementation。
- Recommendation：將M31 Spec／Plan摘要更新為accepted historical artifact，連到31-r10／r11 closure；移除pending wording。
- Baseline blocking：No；actual governance artifacts與repository Skills已完成並驗證。
- Disposition：Priority documentation authority remediation，與F-A1-01／02同批處理。
- Target route：Level 2或Level 3 documentation authority fix。
- Verification required：Spec／Plan metadata、R11 closure、Superpowers index semantic consistency與docs check。

## Current Summary

```txt
Confirmed findings: 9
Resolved by R1: 5
Open P0: 0
Open P1: 0
Open P2: 3
Open P3: 1
Open P1 without disposition: 0
```

## A9 Frozen Disposition

```txt
Frozen at: 2026-07-31
Finding count: 9
Unique finding IDs: 9
Required finding fields: complete for all findings
Baseline-blocking findings: 0
Primary final disposition: B — bounded hardening before maintenance
Supplemental disposition: D — candidate／backlog disposition
User final review gate: approved on 2026-07-31
```

本register的Finding ID、Severity、原始Evidence與A9 disposition在A9 closure後凍結。R1已依獨立Requirement Decision，只將allowlisted五項更新為`Resolved by R1`；`F-A1-04`、`F-A2-01`、`F-A6-01`與`F-A7-02`維持Open。R1核准不授權R2～R5、merge、push或cleanup。
