---
document_type: migration-manifest
status: active
authoritative_for:
  - milestone-23-adr-extraction-migration
last_reviewed_baseline: 1.5.1
---

# Milestone 23 — ADR Extraction Migration Manifest

本 manifest 逐 Decision 追蹤 current validity、分類、canonical target、durable scope、非 ADR disposition、relation review與 batch。它不是 Architecture Decision authority；Batch G前 authority仍是 `docs/architecture_decisions.md`。

## Decision Migration Matrix

| ID | Canonical target | Current validity | Classification | Durable ADR scope | Non-ADR disposition | Relations review | Batch |
|---|---|---|---|---|---|---|---|
| ADR-001 | `docs/adr/adr-001-clean-architecture-feature-first.md` | current | current architecture contract | dependency direction、feature organization、package promotion | wording normalization only | ADR-002、005、007、012 | A |
| ADR-002 | `docs/adr/adr-002-monorepo-melos.md` | current | current architecture contract | workspace shape、Pub Workspaces、Melos ownership | command detail may route AGENTS while retaining ordering invariant | ADR-001、012 | A |
| ADR-003 | `docs/adr/adr-003-presentation-state-and-hooks.md` | current | current architecture contract | Bloc business state、Hooks UI-local state | sample is illustrative | ADR-007、018 | A |
| ADR-004 | `docs/adr/adr-004-app-dependency-injection.md` | partially superseded | partially superseded | App may use get_it/injectable | package lifecycle interpretation superseded | reciprocal scope relation with ADR-012 | B |
| ADR-005 | `docs/adr/adr-005-auth-package-boundary.md` | current | current architecture contract | Auth package vs App presentation boundary | future tense and completion evidence normalize/route | ADR-001、006、007、012、015、022 | B |
| ADR-006 | `docs/adr/adr-006-auth-guard-session-authority.md` | current | current architecture contract | Guard depends on Session authority | none | ADR-005、007、021 | A |
| ADR-007 | `docs/adr/adr-007-cross-feature-state-boundaries.md` | current | current architecture contract | no cross-feature Bloc dependency | example normalize-current | ADR-001、003、006、021 | A |
| ADR-008 | `docs/adr/adr-008-use-case-granularity.md` | current | current architecture contract | one business behavior per UseCase | none | ADR-001、005 | A |
| ADR-009 | `docs/adr/adr-009-project-language-policy.md` | current with governance overlap | release/version policy / governance contract | durable language choice | enforcement route AGENTS | ADR-011 | B |
| ADR-010 | `docs/adr/adr-010-cross-platform-sqlite-initialization.md` | current with support caveat | current architecture contract | conditional initialization and no dart:io leakage | setup route guide; support route snapshot | ADR-014、017 | B |
| ADR-011 | `docs/adr/adr-011-documentation-single-authority.md` | principle current, routing partially superseded | mixed architecture + milestone journal | one authority per fact; docs over chat memory | stale path list/update flow route governance | review against M22 policy | B |
| ADR-012 | `docs/adr/adr-012-reusable-package-di-boundary.md` | current | current architecture contract | App-only lifecycle; constructor injection in packages | completion evidence route audit | partially supersedes ADR-004 package interpretation | A |
| ADR-013 | `docs/adr/adr-013-retrofit-http-api-boundary.md` | current | current architecture contract | Retrofit/Dio/DTO/mapper/data-source boundaries | volatile directory evidence route README/source | ADR-005、012、015、016 | B |
| ADR-014 | `docs/adr/adr-014-app-configuration-environment-entrypoints.md` | current | mixed architecture + milestone journal | environment/API mode separation、entrypoint authority、validation | M9/M18 history route evidence | ADR-010、012、013 | B |
| ADR-015 | `docs/adr/adr-015-refresh-token-concurrent-401.md` | current except storage implementation | mixed architecture + implementation evidence | interceptor split、single-flight、safe replay、Session/failure contract | status/test list/non-goals route evidence/plan | storage scope superseded by ADR-022 | C |
| ADR-016 | `docs/adr/adr-016-catalog-pagination-search.md` | current | mixed architecture + implementation evidence | cursor、debounce、generation、merge、operation states | status/tests route evidence | ADR-013、017、018、020 | D |
| ADR-017 | `docs/adr/adr-017-catalog-offline-cache-swr.md` | current | mixed architecture + implementation evidence | opt-in cache、SWR、identity、chain、repository、logout | exact DDL/migration/tests route source/evidence | ADR-010、012、016、020 | D |
| ADR-018 | `docs/adr/adr-018-design-system-theme-boundaries.md` | current | mixed architecture + milestone journal | DS owner、identity/mode、tokens、preference、accessibility | page sequence/tests/status route plan/evidence | ADR-003、012、019、020 | E |
| ADR-019 | `docs/adr/adr-019-localization-locale-failure-mapping.md` | current | mixed architecture + implementation evidence | App localization owner、locale preference、feature failure mapping | completion statements route evidence | ADR-018、020 | E |
| ADR-020 | `docs/adr/adr-020-exception-failure-reporting.md` | current | mixed architecture + implementation evidence | typed taxonomy、mapping、unknown error、reporting、sensitive data | audit history/test count/provider phase result route evidence/release | ADR-015–019、022 | E |
| ADR-021 | `docs/adr/adr-021-auth-startup-navigation-coordination.md` | current | current architecture contract | App startup/navigation ownership | closure status route evidence | ADR-005–007、015、022 | C |
| ADR-022 | `docs/adr/adr-022-authentication-security-capability-boundaries.md` | current umbrella, heavily mixed | mixed architecture + release/version policy | secure credential/OTP/local unlock split、plugin ownership、security claims | M19–21 supplements/gates/tests/releases route plan/evidence/CHANGELOG | supersedes ADR-015 storage scope only | F |

## Cross-Reference Inventory

每批搜尋：`Decision NNN`、`ADR-NNN`、`docs/architecture_decisions.md`及 fragments、`docs/adr/*.md`、`docs/architecture/*.md`。

- Current docs在 cutover後改 canonical ADR/index。
- Historical audit/plan可保留 aggregate link，只要 final stub仍可達。
- Published CHANGELOG不重寫。
- Source comments只在有維護價值時改 stable ADR ID。

## Batch Completion Contract

每批 review記錄 source baseline、target、semantic result、link result、checker result、rollback commit boundary與 aggregate authority state。Batch G前 manifest維持 `active`。

## Batch Progress

### Batch A — Foundation Contracts

| ID | Migration state | Semantic preservation | Non-ADR routing | Relation result |
|---|---|---|---|---|
| ADR-001 | extracted | accepted | wording normalized; no journal removed | ADR-002、005、007、012 retained |
| ADR-002 | extracted | accepted | volatile command detail routed to `AGENTS.md`; ordering invariant retained | ADR-001、012 retained |
| ADR-003 | extracted | accepted | illustrative code sample omitted; tool responsibility retained | ADR-007、018 retained |
| ADR-006 | extracted | accepted | historical future tense normalized to current contract | ADR-005、007、021 retained |
| ADR-007 | extracted | accepted | Profile example normalized to general cross-feature rule | ADR-001、003、006、021 retained |
| ADR-008 | extracted | accepted | examples retained as contract illustration | ADR-001、005 retained |
| ADR-012 | extracted | accepted | completion statement routed to current package/App README | ADR-004 scope note deferred to Batch B |

Batch A aggregate source sections remain unchanged. Canonical files are migration targets that passed semantic review；formal authority cutover仍延後至 Batch G。

### Batch B — Tooling, Governance and Platform Contracts

| ID | Migration state | Semantic preservation | Non-ADR routing | Relation result |
|---|---|---|---|---|
| ADR-004 | extracted | App `get_it + injectable` selection retained | package lifecycle scope routed to ADR-012 | reciprocal partial supersession established |
| ADR-005 | extracted | Auth package/App presentation boundary normalized to current tense | migration completion omitted | ADR-001、006–008、012 retained |
| ADR-009 | extracted | Traditional Chinese maintenance language retained | operational enforcement routed to AGENTS | ADR-011 retained |
| ADR-010 | extracted | conditional SQLite initializer retained without support inflation | setup command routed to guide/current source | ADR-014、017 retained |
| ADR-011 | extracted | one-authority-per-fact principle retained | stale file list/update workflow routed to M22 governance | governance policy linked |
| ADR-013 | extracted | Retrofit/Dio/DTO/mapper/data-source boundaries retained | volatile directory evidence routed to README/source | ADR-005、012、014–016 retained |
| ADR-014 | extracted | environment/ApiMode separation、entrypoint authority and validation retained | M9/M18 journal and support evidence routed to audits/current snapshot | ADR-010、012、013 retained |

Batch B aggregate source sections remain unchanged. Current repository routes continue to point at aggregate authority until Batch G cutover。

### Batch C — Auth Refresh and Navigation

| ID | Migration state | Semantic preservation | Non-ADR routing | Relation result |
|---|---|---|---|---|
| ADR-015 | extracted | interceptor split、single-flight、Session identity、safe replay、failure classification、commit ordering retained | implementation status、test matrix、Milestone 12 journal routed to README/audit/Git history | ADR-005、006、012、013、020、021、022 reviewed; storage supersession deferred to ADR-022 extraction |
| ADR-021 | extracted | App-owned startup and auth-navigation mapping retained | Milestone 18-7D closure status routed to audit | ADR-005–007、015、022 retained |

Batch C aggregate source sections remain unchanged. ADR-015 does not yet declare a `superseded_by` edge because ADR-022 canonical target does not exist until Batch F；the scope disposition is recorded in prose and this manifest。

### Batch B — Tooling, Governance and Platform Contracts

| ID | Migration state | Semantic preservation | Non-ADR routing | Relation result |
|---|---|---|---|---|
| ADR-004 | extracted | accepted | App DI tool choice retained；package interpretation narrowed | reciprocal partial scope edge with ADR-012 |
| ADR-005 | extracted | accepted | historical future tense normalized to current package boundary | ADR-001、006–008、012、013 retained |
| ADR-009 | extracted | accepted | durable language choice retained | agent enforcement routed to `AGENTS.md` |
| ADR-010 | extracted | accepted | conditional initialization retained | setup routed to README/guide；support claim routed to current snapshot |
| ADR-011 | extracted | accepted | docs-over-chat and single-authority principle retained | stale path list/update flow routed to M22 governance |
| ADR-013 | extracted | accepted | Retrofit/Dio/DTO/Mapper/DataSource/Repository boundary retained | volatile source layout routed to README/source |
| ADR-014 | extracted | accepted | environment、ApiMode、entrypoint、typed config and validation retained | M9/M18 history routed to evidence/current snapshot |

Batch B aggregate source sections remain unchanged. 14 rows are now `extracted` and 8 rows remain `aggregate`; formal authority cutover仍延後至 Batch G。
