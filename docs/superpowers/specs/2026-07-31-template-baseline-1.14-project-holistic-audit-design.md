---
document_type: design-spec
status: accepted
authoritative_for:
  - template-baseline-1-14-project-holistic-audit-design
last_reviewed_baseline: 1.14.0
---

# Template Baseline 1.14.0 — Project Holistic Audit & Future Direction Assessment Design

中文名稱：模板專案整體總審查與後續方向評估。

## Requirement Decision

- Request：對Template Baseline 1.14.0進行repository-wide整體總審查，判斷模板是否已達成熟完整狀態、應進入長期維護模式，或仍存在值得投入的正式下一階段。
- Problem：Milestone 18只審查Milestone 1～17；Milestone 19～32後續新增Secure Storage、OTP、Biometric Unlock、CI／iOS、Product Identity、Observability、Connectivity、Drift、Testing Governance、Development Workflow Governance與managed local artifact store，但尚未有新的跨領域成熟度判定。初步只讀盤點亦已發現current authority與historical routing可能存在漂移。
- Current behavior：Template Baseline 1.14.0已正式release與post-release closure，`main`與`origin/main`同步、工作樹乾淨、active milestone為None；各近期Milestone具獨立final review，但沒有任何單一artifact可代表整個repository現況與後續方向。
- Expected behavior：建立可重現的architecture、capability、runtime、security、platform、testing、CI、documentation與future-direction evidence matrix；所有finding具有severity、evidence與disposition；最終明確判斷維護、hardening或新Milestone方向。
- Value：防止模板因「還可以做」而持續擴張；避免stale claim、平行authority與過度文件增長；讓下一次投入由template-level reusable value與evidence決定。
- Classification：Level 4 — Architecture／Milestone／Repository-wide Governance Audit。
- Level 5 consideration：目前不採用。Audit階段不修改database、credential、安全機制、supported platform、production pipeline或release state；任何後續remediation必須重新分類。
- Decision：Accept with reduced scope。
- Scope：Requirement Decision、Audit contract、只讀evidence inventory、跨領域audit、candidate／backlog disposition與A／B／C／D最終判定。
- Non-goals：不修改production source、不修正finding、不建立Milestone 33、不提升VERSION、不新增套件或supported platform、不啟用signing／Store／provider／physical-device能力、不清理GitHub或local artifacts。
- Behavioral requirements required：Yes；適用於audit evidence、classification、finding與disposition contract，不是產品UI行為需求。
- Design Spec required：Yes；由本文件擁有。
- Implementation Plan required：Yes；只能在本Design完成Task gate並取得使用者核准後建立。
- ADR required：No；Audit本身不改變stable architecture decision。後續remediation若改變stable ownership、dependency direction、platform claim或release contract，另行進入ADR gate。
- Task governance mode：Full two-layer Task governance。
- Worktree／branch：使用`audit/template-baseline-1.14-project-holistic`隔離branch與managed worktree。
- Regression level：Audit初期採evidence-driven focused validation；Execution Plan核准後依Task逐步執行repository regression與platform evidence review。
- Release required：No。Audit不新增模板能力；後續remediation另行判定。
- Post-release validation：Audit本身不適用。

## Goals

1. 驗證目前architecture、runtime ownership與dependency direction仍符合canonical ADR及production evidence。
2. 建立Template Baseline 1.14.0完整能力清單，明確區分可直接採用、reference、產品接入、dependency-ready、deferred與not planned。
3. 驗證文件、README、ADR、Roadmap、Guides、Audits、VERSION與CHANGELOG沒有平行或矛盾authority。
4. 驗證testing ownership、CI classifier、platform evidence、artifact retention與post-release contract可長期維護。
5. 驗證security與platform claim沒有超過secure storage、OTP、biometric、Simulator、unsigned build或verification artifact實際證據。
6. 重新審查candidate與backlog，淘汰只有「可以實作」但不具template-level價值的方向。
7. 產生明確最終disposition與maintenance entry criteria，不預設一定建立下一個Milestone。

## Non-goals

- 不重新播放Milestone 1～32全部歷史Task。
- 不把既有final review直接視為current repository-wide結論。
- 不為降低文件或測試數量而批量刪除。
- 不因`last_reviewed_baseline`較舊而批量更新metadata。
- 不因dependency、conditional implementation或scaffold存在便提升platform support claim。
- 不將WebSocket、Notification、Payment、Analytics、Device Binding、Passkey、signing或Store distribution自動提升為candidate。
- 不建立Generic Feature、Generic Repository、Generic Cache、Generic Offline、Generic Platform或Generic Release framework。
- 不在Audit Review Gate前修正任何finding，即使只是stale metadata或routing。
- 不修改GitHub repository settings、runner service、remote artifacts／caches或managed local store。
- 不將本Audit命名為Milestone 33；只有最終disposition C成立時，才另外建立新Milestone Requirement Decision。

## Approaches Considered

### A — Repository-wide evidence matrix + gated disposition（採用）

以current authority與production evidence為主，按architecture、capability、runtime、security／platform、testing／CI、documentation與future direction分區審查。各區只建立evidence與finding，最後在單一Audit Review Gate統整remediation與未來方向。

優點：可以回答整個模板是否成熟，並避免看到第一個問題便局部修正。缺點：需要嚴格控制閱讀範圍與evidence duplication。

### B — 只整合Milestone 30～32 final reviews（不採用）

直接將近期testing、workflow與artifact closure視為整體成熟證據。

優點：成本最低。缺點：無法重新驗證Auth、Catalog、Drift、Design System、Localization、安全、平台與current authority；也無法回答candidate disposition。

### C — 直接建立下一個Milestone（Reject）

從backlog挑選Additional Platform Support、Analytics或Notification並直接進入Design。

優點：立即增加功能。缺點：將「可以做」誤當成「值得做」，可能擴大維護面並忽略模板已接近成熟的事實。

## Audit Principles

### Current evidence first

正式判定優先順序：

```txt
Production source／tests／workflows／platform configuration
  ↓
Canonical ADR／Project Context／Guides／local README
  ↓
Current runtime／artifact／clean-checkout evidence
  ↓
Historical final reviews、plans與Git history
```

Historical文件只能解釋當時決策，不得以current-tense文字覆蓋目前source或current authority。

### Matrix before remediation

同一audit area必須先完成inventory與open-ended scan，再整理finding。Audit Review Gate前不得因第一個stale文件、測試重複或import疑點開始修正。

### Claim requires layered evidence

每項template capability至少記錄適用的下列evidence：

```txt
Contract owner
Production path
Primary test owner
Static／build evidence
Runtime／remote evidence
Adopter action required
Known non-goals
```

不是每項能力都要求全部七層，但缺少必要層時不得標記為正式可用。

### No metadata-only conclusions

`last_reviewed_baseline`較舊只表示需要semantic review，不等於內容已stale。只有內容、owner、routing或claim與current evidence不一致，才建立finding。

### No automatic expansion

Future direction的判斷標準是：

- 是否是通用template concern，而非特定產品功能。
- 是否有明確confirmed gap與至少一個可重現failure mode。
- 是否具穩定boundary、可驗證acceptance與合理維護成本。
- 是否已有第二個consumer或足以支持抽象的adoption evidence。
- 是否會擴大supported platform、安全、privacy、credential或release承諾。

## Capability Classification

### 正式可用

具current contract、production implementation、primary tests及適用的build／runtime evidence，可在已揭露non-goals下作為模板能力採用。

### Reference implementation

具可執行完整範例與tests，但產品仍需替換backend、policy、copy、provider或domain data，不宣稱直接符合產品需求。

### 需要產品接入

Repository已提供contract、hook、manifest或guide；採用者仍須提供identity、endpoint、privacy policy、credential、provider config或業務決策後才會啟用。

### Dependency-ready

Dependency、conditional boundary或部分assets存在，但缺少tracked runner、artifact、runtime或維護承諾，不得宣稱Supported。

### Deferred

已有明確價值或關聯，但前置條件、成本或產品責任尚未成立；必須記錄重新評估條件。

### Explicitly not planned

與模板定位不符、缺少通用價值、已有更狹窄替代方案，或會導致不必要generic framework與維護承諾。

## Finding Contract

每個finding由單一findings register擁有完整正文，各Task文件只引用Finding ID。

```txt
ID
Area
Severity
Status
Evidence
Current contract
Observed state
Risk
Recommendation
Baseline blocking
Disposition
Disposition rationale
Target route
Verification required
```

Severity：

```txt
P0 — 確定的安全、資料、release integrity或核心流程失效。
P1 — 會使Template Baseline 1.14.0的主要claim不成立，必須修正、降級或明確接受風險。
P2 — 應進行有界hardening，但不一定阻擋maintenance disposition。
P3 — 文件、導航、可讀性、repository hygiene或後續改善建議。
```

Status：

```txt
Open
Confirmed
Accepted risk
Deferred
Resolved
Not an issue
```

Audit完成前所有P0／P1必須有明確disposition；Audit階段不要求直接Resolved，但不得留在未分類Open狀態。

## Audit Tasks

### A0 — Audit Contract and Governance Gate

輸入：Requirement Decision、Level 4 routing、Baseline 1.14.0 current authority。

輸出：本Design、focused review、whole-Design review、使用者核准與後續Execution Plan gate。

Validation：scope／non-goals、classification、finding schema、Task boundaries、authority與stop conditions review。

停止條件：本Design未accepted前不得建立Execution Plan或開始audit evidence Tasks。

本Design accepted只允許進入Execution Plan Task。Execution Plan仍必須完成focused review、fresh re-review、whole-Plan review、documentation validation與使用者明確核准；Plan維持`proposed`期間不得開始A1或建立任何正式audit evidence。

### A1 — Repository Baseline, Authority and Evidence Ledger

輸入：Git refs、branches、worktrees、VERSION、CHANGELOG、Roadmap、Milestone routing與release closure evidence。

輸出：exact baseline manifest、authority owner map、available／missing evidence ledger與repository hygiene findings。

Validation：HEAD／remote、branch ancestry、clean state、release／closure identity、worktree與unpublished content交叉驗證。

停止條件：發現非預期divergent history、未提交／未推送closure或release identity不一致時，只讀分析並停止baseline acceptance。

### A2 — Architecture and Dependency Boundary Audit

輸入：Canonical ADR、pubspec、App／Package／Feature README、imports、DI、public barrels、production source與architecture tests。

輸出：dependency graph、Composition Root matrix、responsibility matrix、public API與boundary findings。

Validation：import／dependency scan、代表性call chain、DI registration、Route Guard、Bloc、Repository／UseCase／DataSource、API／platform adapter ownership檢查。

停止條件：需要改變stable architecture boundary的P0／P1只記錄finding，送到Audit Review Gate。

### A3 — Template Capability Inventory and Classification

輸入：Project Context、README、source、tests、final reviews與runtime evidence。

輸出：Authentication、Refresh、OTP、Biometric、Secure Storage、Networking、Pagination／Search、Offline／Connectivity、Drift、Localization、Design System、Failure、Observability、platform、CI、testing、workflow與product identity能力矩陣。

Validation：每項claim交叉核對contract、production path、test與適用runtime evidence；記錄adopter action與non-goals。

停止條件：evidence不足時降低分類或標記unknown，不以推測補足。

### A4 — Critical Runtime, Data and Integration Flow Audit

輸入：Auth、Refresh、OTP、Biometric、Catalog、Connectivity、Drift、API、Failure／Observability source與tests。

輸出：critical-flow matrix、primary test owner、failure mode、coverage gap與integration findings。

Validation：Login／Restore／Refresh／Replay／Logout／OTP／Local Unlock／SWR／Reconnect／migration等production path及integration tests交叉核對。

停止條件：發現runtime defect或migration risk時不修正，維持Audit-only gate。

### A5 — Security and Platform Claim Audit

輸入：ADR-022～026、Android／iOS／Web configuration、build scripts、platform source與runtime evidence。

輸出：security capability matrix、platform support matrix、overclaim／underclaim findings。

Validation：plugin ownership、native configuration、artifact classification、Simulator／device／signing／Store、root／jailbreak、Device Binding／Passkey及provider完成度分層檢查。

停止條件：需要physical device、Store account、provider activation或production credential時記錄external evidence gap，不自行啟用或索取secret。

### A6 — Testing and CI Sustainability Audit

輸入：Milestone 30 inventory、testing governance、current tests、classifier、workflows、managed artifact contract與Milestone 32 evidence。

輸出：current／historical owner matrix、重複／脆弱／implementation-detail候選、CI path coverage、artifact sustainability findings。

Validation：inventory tooling、focused ownership checks、CI contracts、classifier path matrix、manifest／checksum／retention與GitHub no-growth contract。

停止條件：test deletion、remote workflow dispatch、runner變更、GitHub cleanup或local purge都需要獨立Requirement Decision與approval。

### A7 — Documentation and Current Authority Audit

輸入：README、Project Context、ADR、Roadmap、Backlog、Guides、Milestone／Audit indexes、CHANGELOG、VERSION與documentation policy。

輸出：authority graph、parallel／duplicate authority、stale current-tense內容、navigation gap與document-growth findings。

Validation：docs checker、relative links、metadata contract、current-owner semantic comparison與historical overwrite scan。

停止條件：所有stale metadata、routing或wording只建立finding，不在整體disposition前修正。

### A8 — Future Direction and Candidate Disposition

輸入：A1～A7 matrices、findings、maintenance cost、candidates、backlog與template positioning。

輸出：Additional Platform Support、WebSocket、Notification、Payment、Analytics／Event Governance、Production signing／Store distribution、Device Binding／Passkey的正式disposition與重新評估條件。

Validation：template-level value、second-consumer evidence、平台／安全／privacy成本、產品特定性與既有能力重複度。

停止條件：Candidate promotion、formal Reject或新Milestone屬使用者決策；Audit不自動提升。

### A9 — Holistic Synthesis and Audit Review Gate

輸入：A1～A8全部evidence、matrices與findings。

輸出：A／B／C／D最終disposition、maintenance criteria、approved remediation、accepted risk、deferred、rejected與new-milestone recommendation。

Validation：cross-Task consistency、authority review、finding completeness、Open P0／P1 disposition與whole-Audit holistic review。

停止條件：停在使用者Audit Review Gate；不得直接進入remediation。

## Final Disposition Model

Audit最終至少選擇一個主要結論，並可附帶D類項目處置：

```txt
A. 模板已成熟完成，進入維護模式
B. 只有少量有界hardening，不需要新Milestone
C. 存在足夠價值與範圍，可提出下一個正式Milestone
D. 現有candidates／backlog部分不再符合模板定位，應Reject或維持Deferred
```

判定原則：

- A要求沒有阻擋主要claim的P0／P1，且P2不足以形成正式remediation initiative。
- B要求finding可由有界Level 0～3工作處理，不新增template capability或supported claim。
- C要求confirmed template-level gap、清楚scope／non-goals、可驗證failure mode與足夠跨領域價值。
- D可與A、B或C同時成立，用於逐項處理既有future directions。

## Existing Evidence Reuse

- Milestone 18可重用audit schema、capability分級與Audit／Remediation gate，但不能代表Milestone 19～32。
- Milestone 30可重用test ownership、current／historical boundary與inventory evidence，但不取代current repository test audit。
- Milestone 31 R10／R11可重用workflow governance、fresh regression與clean-checkout closure，但不審查template capability全貌。
- Milestone 32 final review／post-release可重用managed artifact、Windows／Mac、GitHub storage與release closure evidence，但不審查Auth、Catalog、Drift、Design System、Localization或future direction。
- Milestone 19～29各domain final review可作專項evidence，不得以多份歷史review拼接成current holistic conclusion。

## Artifact Ownership

- 本Design擁有Audit scope、non-goals、method、classification、Task boundaries與final disposition model。
- Execution Plan擁有exact files、commands、Task order、validation、commit boundary與execution stop conditions。
- Audit Task evidence擁有inventory、matrix與分析過程。
- Findings register擁有每項finding完整正文與disposition。
- Final audit report擁有cross-Task synthesis與A／B／C／D結論。
- Current Project Context、ADR、Guides、Roadmap、VERSION與CHANGELOG仍各自擁有current truth；Audit不得成為平行current authority。

## Governance and Commit Model

Design、Plan與A1～A9均為formal Task：

```txt
create／audit
→ focused review
→ findings
→ fix evidence／classification defects
→ fresh re-review
→ whole-Task holistic review
→ authority check
→ required validation
→ Open P0 = 0
→ Open P1 without disposition = 0
→ independent commit
→ next Task
```

一般finding、test failure、evidence gap或stale document不構成中途詢問理由。只有使用者擁有的scope／architecture decision、external／manual blocker、推翻accepted artifacts的P0／P1，或完整Audit Review Gate才停止。

## Design Acceptance

本Design已於2026-07-31由使用者明確核准。完成focused review、whole-Design review、documentation validation與independent commit後，才可使用`writing-plans`建立正式Audit Execution Plan。Execution Plan未完成完整Task gate與使用者明確核准前，A1～A9全部維持未開始。

