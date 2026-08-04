---
document_type: planning-review
status: accepted
authoritative_for:
  - milestone-33-implementation-plan-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Implementation Plan Review

## Scope

本review涵蓋：

- [Accepted Design](../../superpowers/specs/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation-design.md)。
- [Accepted ADR-028 stable decision draft](../../superpowers/specs/2026-08-04-adr-028-repository-local-pencil-to-flutter-design-implementation-workflow-draft.md)。
- [Accepted Implementation Plan](../../superpowers/plans/2026-08-04-milestone-33-repository-local-pencil-to-flutter-workflow-foundation.md)。
- Execution Admission Gate與managed worktree boundary。
- Tasks 33-1至33-13的exact files、interfaces、TDD、validation、review與commit boundaries。
- Third-party Skill immutable source admission、visual authority、Pencil MCP、Flutter proof、visual diff、Guide、Final Review、release與post-release closure。

本review不建立managed worktree、不copy外部source、不安裝Skills、不操作Pencil canvas、不修改Flutter production source，也不核准merge、release或push。

## Baseline

```txt
Template Baseline: 1.14.0
Accepted Design closure commit: db73068f0334e9ac27134026d37ed1cbb7833f60
Planning checkout: main
Plan creation base: db73068f0334e9ac27134026d37ed1cbb7833f60
Implementation worktree: not created
Implementation: not started
```

## Design Coverage Matrix

| Design requirement | Plan owner |
|---|---|
| ADR-028 canonicalization與checker hard gate | Task 33-1 |
| Third-party Skill ownership／language／integrity | Task 33-2 |
| Taste Skill source pin、registry、collision／discovery | Task 33-3 |
| Repository-local `.pen`與visual manifest | Task 33-4 |
| Repository orchestration Skill與pressure scenarios | Task 33-5 |
| Pencil MCP admission／extraction／mapping | Task 33-6 |
| Feature First／Router／Localization／Phosphor foundation | Task 33-7 |
| Responsive presentation-only implementation | Task 33-8 |
| Architecture／semantics／golden validation | Task 33-9 |
| Deterministic diff／Android runtime／semantic visual review | Task 33-10 |
| Guide／Quick Start／registry／current authority | Task 33-11 |
| Holistic Final Review與release disposition | Task 33-12 |
| 1.15.0 integration／push／clean-checkout post-release closure | Task 33-13 |

## Focused Findings

### F-33-P01 — Upstream Skill lock無immutable commit時不能直接採用local installer metadata

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：外部`skills-lock.json`只有source repository與installer computed hashes，沒有commit／tag；若Plan直接使用local files與computedHash，無法重建來源或證明unmodified。
- Fix：Task 33-3先以`git ls-remote`取得immutable commit，從exact commit重建三個source paths並比對raw SHA-256；無matching commit時Task blocked，禁止fabricate identity。Installer computedHash只保留為historical evidence。
- Fresh re-review：Root lock的commit、license、install path與逐檔raw hash均有明確owner與fail-closed path。

### F-33-P02 — Canonical viewport可能再次退化成全畫面fixed-canvas implementation

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：先前proof以`FittedBox`縮放`941 × 1672`固定畫布；若Plan只要求golden，implementation可重複相同捷徑。
- Fix：Task 33-8同時建立`941 × 1672`、`390 × 844`、`226 × 400` tests，要求Scrollable、end-flow可達與無top-level full-screen `FittedBox`；Task 33-9 architecture guard掃描full-screen image／fixed-canvas cheat。
- Fresh re-review：Canonical fidelity與responsive production behavior具有獨立自動化owner。

### F-33-P03 — Pixel threshold若在看到candidate後決定會形成驗收偏誤

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：Design要求Plan固定threshold，但單一任意比例可能過嚴或過鬆。
- Fix：Task 33-10在candidate comparison前固定per-channel tolerance 8、無ignore region，並要求candidate同時不差於已核准historical benchmark與absolute ceilings`0.08`／`8.0`。Threshold變更只能回到Design decision。
- Fresh re-review：Plan沒有為implementation結果保留事後放寬入口；semantic review仍可否決pixel pass。

### F-33-P04 — Final implementation review與release／push closure必須分離

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：若Task 33-12同時修改VERSION、merge與push，使用者無法在看到完整local review後再決定release。
- Fix：Task 33-12只執行local holistic review並停止於使用者authorization gate；只有Disposition A與明確授權才能執行Task 33-13的1.15.0、integration、push、clean-checkout與cleanup。
- Fresh re-review：最後一個implementation Task、local Final Review、release identity、remote publication與formal closure為不同狀態。

### F-33-P05 — Worktree base不能在Plan內留下未解析placeholder

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：Plan撰寫時尚不存在Plan acceptance closure SHA，若寫`<PLAN_SHA>`會造成不可執行placeholder。
- Fix：Execution Admission Gate要求在Plan acceptance closure commit後執行`git rev-parse HEAD`，將實際40-character SHA直接傳給worktree`baseRef`並記錄於execution admission evidence；固定Design ancestor`db73068...`另行驗證。
- Fresh re-review：Plan提供 deterministic resolution procedure，沒有虛構SHA或可變文字placeholder。

### F-33-P06 — Build validation引用不存在的environment JSON

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：Plan初稿使用`--dart-define-from-file=config/development.json`，但repository current authority只有`apps/flutter_architecture/config/environments.json` mapping，沒有該define file；執行時會在Flutter build前直接失敗。
- Fix：Bundle validation改用development entrypoint加`--dart-define=NATIVE_ENVIRONMENT=development`；Android artifact改走repository-owned`tools/ci/build_android_development.sh`，不自行重建flavor／define contract。
- Fresh re-review：Task 33-9、33-10、33-12與33-13所有build commands均指向existing entrypoint／script，沒有stale config path。

### F-33-P07 — Android runtime capture路徑不能保留兩種實作選項

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：Plan初稿允許「debug navigation entry或direct router test harness」，可能導致新增production debug入口，或不同執行者採用不可重現的手動導航。
- Fix：Task 33-10固定新增integration test與integration driver；test透過既有`AppRouter` push `WritePrecheckRoute`，先設定dark theme與Traditional Chinese locale，再由`takeScreenshot`輸出固定檔名。明文禁止production debug menu、initial route change與hidden runtime flag。
- Fresh re-review：Android capture現在具有唯一source path、route mechanism、theme／locale state、driver output與command owner。

### F-33-P08 — License identity沒有repository-local bytes與integrity evidence

- Severity：P1。
- Status：Resolved in proposed Plan。
- Finding：Plan只要求記錄upstream license identity／source path；若上游變更或不可用，repository無法證明admitted Skill當時對應的exact license內容。
- Fix：Task 33-2 lock schema加入license `localPath`與raw SHA-256驗證，以及missing／hash-drift RED tests；Task 33-3把exact upstream license保存於`third_party/skills/taste-skill/LICENSE`並納入commit。
- Fresh re-review：Source commit、Skill bytes與license bytes現在都能由repository-local lock獨立驗證與rollback。

## Focused Re-review

- Task順序先治理與authority，再Pencil extraction，再Flutter implementation與visual validation。
- ADR checker在所有後續implementation前canonicalize ADR-028。
- Skill language exception只來自strict root lock，不依path-only或name-only宣告。
- Taste Skills source admission、loaded absolute path與collision evidence具有獨立Task owner。
- Third-party license exact bytes與hash納入同一source admission chain。
- Visual source import先hash再接受；外部path在Task 33-4後不再是active authority。
- Orchestration Skill不取得Requirement、approval、Task、release或closure authority。
- Pencil extraction只透過MCP，unsupported construct有blocked disposition。
- Flutter proof只建立presentation，所有visible strings由ARB提供。
- Canonical、narrow、architecture、semantics、golden、diff與Android runtime validations均有exact file與command owner。
- Visual diff contract在candidate前固定，禁止resize、mask與事後threshold widening。
- Android runtime capture只透過integration test／driver，不修改production navigation。
- Documentation與current authority在Task 33-11同步，不以Plan保存runtime current state。
- Task 33-12與33-13分離local review、release authorization與post-release closure。

## Whole-Plan Review

### Task boundaries

每個Task都有可獨立拒絕或接受的deliverable：ADR、Skill checker、Skill admission、visual authority、orchestration、Pencil evidence、Flutter foundation、UI、validation、visual acceptance、Guide、Final Review、post-release closure。Setup被收進其deliverable需要的Task，沒有獨立無價值scaffold Task。

### Interface consistency

- `inspect_skill_lock(root: Path) -> SkillLockInspection`由Task 33-2產生，Task 33-3與docs checker消費。
- `verify_visual_authority(root: Path, manifest: Path)`由Task 33-4產生，後續docs check與release validation消費。
- `WritePrecheckCopy.from(AppLocalizations)`與`PencilCompatibilityVisualSpec`由Task 33-7產生，Task 33-8至33-10消費。
- `VisualDiffResult`與`comparePngs()`只由Task 33-10建立及使用，signature在Plan內一致。
- Canonical route名稱固定為`WritePrecheckRoute`，沒有Task間命名漂移。

### Governance consistency

Plan核准前implementation為零。Plan核准後，每個Task遵守完整focused review／fix／fresh re-review／whole-Task review／authority／validation／commit。一般finding不停止；scope／architecture decision、external blocker、推翻accepted artifact的P0／P1或明確user gate才停止。

### Scope control

Plan不包含完整NFC Lab、NFC behavior、Figma、Web runner、Windows desktop runner、任意`.pen` generator、global Design System expansion或產品識別。Android runtime只作supported-platform evidence，不新增production navigation入口。

## Self-review

```txt
Spec coverage: all BR-33-01 through BR-33-15 mapped
Task identifiers: 33-1 through 33-13 unique
Unresolved placeholder markers: zero
Type/signature consistency: passed
Exact route name: WritePrecheckRoute
Canonical viewport: 941x1672 DPR1
Narrow viewports: 390x844 and 226x400
Visual threshold contract: fixed before candidate comparison
Plan-before-worktree gate: present
Final-review-before-release gate: present
Build command authority: existing entrypoint and repository CI script
```

## Validation

Fresh Plan validation結果：

```txt
Documentation checker unit tests: 19 passed
Repository docs_check: passed
Relative links and managed metadata: passed through docs_check
git diff --check: passed
Task sequence: 33-1 through 33-13, contiguous and unique
Unresolved placeholder markers: zero
Stale config/development.json references: zero
Focused findings: 8 P1, all resolved in proposed Plan
Modify path review: 46 paths checked; two paths are intentionally created by Task 33-7 before Task 33-8 modifies them
Managed worktree branch: not created
```

## User Approval Gate

Design、ADR stable decision draft與Implementation Plan均已accepted。使用者於2026-08-04明確核准書面Plan；現在可依Execution Admission Gate建立managed worktree並執行Task 33-1。

## Current Disposition

```txt
Plan focused review: PASSED after eight P1 dispositions
Whole-Plan review: PASSED
Open P0: 0
Open P1 without disposition: 0
Plan status: ACCEPTED
Plan user approval: APPROVED — 2026-08-04
Managed worktree: NOT CREATED
Implementation: NOT STARTED
Next gate: Plan approval closure commit, managed worktree creation, Task 33-1 execution admission
```
