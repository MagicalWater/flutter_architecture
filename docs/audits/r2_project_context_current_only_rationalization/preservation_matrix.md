---
document_type: migration-manifest
status: accepted
authoritative_for:
  - r2-project-context-current-only-preservation-matrix
last_reviewed_baseline: 1.14.0
---

# R2 — Project Context Current-only Preservation Matrix

## Baseline

```txt
Source file: docs/project_context.md
Pre-change blob: 1df9bf60cf0e91a539a7465f1c2b0addee8815dc
Milestone-prefixed paragraphs: 13
Release chronology matches: 8
Exact evidence terms: 12
Project Context modified in R2-1: No
```

本matrix在Project Context正文修改前建立。R2-2只能依本matrix執行；若發現未列出的current fact，不得直接刪除，必須先補充matrix disposition與review evidence。

## Classification

- **Preserve**：原位置仍是正確current owner，只做必要wording收斂。
- **Re-home**：current fact保留，但移到對應current section。
- **Replace**：原section contract改為current-only等價內容。
- **Remove**：只含歷史演進、完成過程、release identity或runtime evidence；current snapshot不保留正文。

## Paragraph Matrix

| ID | Source section | Source fact | Classification | Current owner after R2 | Historical route | Verification |
|---|---|---|---|---|---|---|
| P01 | Current Baseline | M19 Secure Credential、M20 OTP、M21 Biometric均已完成 | Remove | `Current Capabilities`各自的Auth／OTP／Biometric sections | `docs/milestones/README.md`、`CHANGELOG.md`、對應audits | Auth／OTP／Biometric headings與current claims仍存在 |
| P02 | Current Baseline | M22只處理documentation authority與navigation | Remove | 無current runtime fact需保留；Documentation Routing已擁有current route | `docs/milestones/README.md`、M22 audit／migration records | Documentation Routing與Hub links仍存在 |
| P03 | Current Baseline | M23 canonical ADR extraction與supersession graph | Re-home | `Current Baseline`保留`Architecture Decision authority: docs/adr/README.md`；Documentation Routing保留canonical ADR route | `docs/milestones/README.md`、M23 audits、Git history | ADR authority與canonical route assertions |
| P04 | Current Baseline | M24 GitHub Actions quality gates；M27加入manual-local／self-hosted／github-hosted；Branch Protection deferred | Re-home | `Current Capabilities > Delivery and Verification`與Security boundary | M24／M27 audits、`docs/guides/ci_cd_operations.md` | 三種execution modes、change-aware CI、Branch Protection deferred可定位 |
| P05 | Current Baseline | M25 iOS runner／Simulator／unsigned build；M27提升iOS baseline到15.0；physical device／signing deferred | Re-home | `Platform Capability`與Security boundary | M25／M27 audits、CHANGELOG | iOS Supported、15.0 baseline、physical-device／signing deferred可定位 |
| P06 | Current Baseline | M26 environment／flavor／identity mapping與adoption guide | Re-home | `Current Capabilities > Environment and API Composition`與Security boundary adoption route | M26 audits、`docs/guides/native_environment_adoption.md` | development／staging／production與placeholder adoption rules可定位 |
| P07 | Current Baseline | M27 observability contract、Crashlytics、symbols／dSYM、CI modes | Re-home | `Exception and Failure Architecture`、Security boundary、Delivery and Verification | M27 audits、CI guide | reporting Composition Root、privacy boundary、execution modes可定位 |
| P08 | Current Baseline | M28 typed connectivity、adapter、lifecycle recheck、offline banner、Catalog reconnect | Re-home | 新增`Current Capabilities > Connectivity and Offline State` | M28 audits、ADR-027 | connectivity authority、recheck、banner、Catalog revalidation、reachability boundary可定位 |
| P09 | Current Baseline | M29 Drift成為唯一production database authority並保留historical migration／rollback | Re-home | `Current Technology Map > Persistence and Platform`及Credential Persistence | M29 audits、ADR-010 | Drift唯一production authority與historical sqflite boundary可定位 |
| P10 | Current Baseline | M30 test inventory、coverage owner、historical boundary、Tier governance | Re-home | `Standard Verification Commands`與testing governance guide route；production／historical DB boundary留在Persistence | M30 audits、`docs/guides/testing_governance.md` | testing guide route、Drift current／sqflite historical boundary可定位 |
| P11 | Current Baseline | Repository change-aware CI、fail-safe classification、managed local artifact store與GitHub exception | Re-home | 新增`Current Capabilities > Delivery and Verification` | M32 audits、`docs/guides/ci_cd_operations.md` | change-aware、unknown fail-safe、三模式、managed store、GitHub exception可定位 |
| P12 | Active Work | M32完成內容、exact manifest、110 artifacts／3 caches、10,247,881,699 bytes、Mac root、release SHA與remote validation | Replace | `Current Work and Maintenance State`只保留Latest completed initiative一行route；current CI contract由Delivery and Verification擁有 | `docs/milestones/README.md`、`docs/audits/milestone_32/`、CHANGELOG、Git history | exact counts／manifest／SHA消失；latest initiative與CI current contract仍存在 |
| P13 | Active Work | M30與M31完成、release、push、clean-checkout與post-release chronology | Remove | 無；governance current route由AGENTS／governance guide擁有 | `docs/milestones/README.md`、M30／M31 audits、CHANGELOG | Project Context無M30／M31 completion journal；governance route仍存在 |
| P14 | Active Work | M26完成、1.8.0封存、change-aware classifier修正與57個CI contracts | Remove | Current delivery contract由Delivery and Verification擁有 | M26 audits、CI history、CHANGELOG | 不保留57 tests等歷史數字；change-aware current contract仍存在 |
| P15 | Active Work | Production signing、physical-device、Store distribution與Branch Protection仍未納入 | Re-home | `Security and Support Boundaries`與`Current Work and Maintenance State`不得重複 | CI guide、Roadmap／Backlog deferred routes | production signing／Store／Branch Protection deferred可定位一次 |

## Current Fact Checklist

### Must remain directly readable

- Template Baseline 1.14.0、Phase 1／MVP Completed、Active milestone None。
- Latest completed initiative為Milestone 32，且可路由至Milestone index。
- Canonical ADR authority。
- App／Package responsibility與Clean Architecture／Composition Root boundaries。
- Development／staging／production environment contract。
- Auth、credential persistence、OTP、Biometric、Catalog、Design System、Localization、Failure architecture。
- Drift唯一production authority；sqflite只作historical fixture／rollback。
- Android／iOS Supported；Web／Windows／macOS／Linux Dependency-ready。
- iOS current deployment baseline 15.0。
- Typed connectivity authority與offline／reconnect behavior。
- Change-aware CI、unknown fail-safe、三種execution modes與managed local artifact store。
- Production signing、physical-device／Store distribution、Branch Protection、Device Binding與Passkey limitations。

### Must leave current snapshot

- Milestone 19～32的完成順序與版本歷史。
- `Template Baseline 1.x`封存／提升／發布敘述。
- Test count、artifact／cache count、byte count、attempt count、manifest ID、release SHA。
- Push、clean-checkout、remote validation完成過程。

## Historical Owners

```txt
Milestone route: docs/milestones/README.md
Review／runtime evidence: docs/audits/README.md
Release identity／history: VERSION + CHANGELOG.md
Archived summaries: docs/archive/
Exact commits: Git history
```

## R2-1 Acceptance

```txt
Every chronology／Active Work paragraph classified: Yes
Current facts without owner: 0
Remove rows containing unowned current fact: 0
Project Context blob unchanged: Required
R2-2 allowed: Yes after R2-1 independent commit
```
