---
document_type: final-review
status: accepted
authoritative_for:
  - milestone-45-local-implementation-result
last_reviewed_baseline: 1.23.1
---

# Milestone 45 — Test-by-Exception Portfolio Reset & Development Governance Simplification — Holistic Final Review

## Result

Milestone 45 local implementation **PASS**。本階段把repository testing從coverage-preservation模型反轉為test-by-exception，並完成current portfolio radical reduction、Task governance簡化、validation／CI release semantics修正與current authority同步。

Open P0 = 0。Open P1 without disposition = 0。

## Portfolio before / after

| Metric | Before | After | Reduction |
|---|---:|---:|---:|
| Test files | 179 | 20 | 88.8% |
| Test LOC | 30,749 | 5,873 | 80.9% |
| Static cases | 1,127 | 186 | 83.5% |
| Test + non-test tools + workflows unique LOC | ~43,718 | 18,168 | ~58.4% |

Minimum success criterion（files與LOC均>=80% reduction）已通過。90% LOC stretch沒有以刪除真正critical security／migration／concurrency protection硬湊數字；後續若剩餘owner的maintenance value下降，仍可依test-by-exception直接再退休，不存在最低保留數量。

## Retired buckets

以下coverage以`replacement = NONE`正式退休，因其永久maintenance cost高於failure detection value：

- ordinary Widget／Page／Dialog rendering；
- copy／style／theme／localization／普通responsive matrices；
- Design System mechanical rendering／golden matrix；
- DI registration、source-shape、class／file ownership與architecture prose scanners；
- documentation／Skill wording contracts；
- Pencil architecture／copy／golden／visual-diff／semantics重複layers；
- reference Feature completeness tests（Catalog／Profile等）；
- framework／forwarding／adapter trivia；
- workflow YAML prose／string-presence contracts；
- duplicate Auth repository／presentation／transport matrices；
- obsolete inventory self-tests與large-portfolio governance tests。

Deletion不建立逐case manifest；本review的bucket disposition、critical keep matrix與before／after metrics是current portfolio reset evidence。

## Remaining critical owners

Current permanent suite只保留下列高價值failure families：

- credential migration、destructive cleanup／rollback與credential redaction；
- refresh single-flight、token rotation、stale-session／identity race與safe replay；
- secure credential store corruption／failure boundary；
- OTP stale completion／latest-intent ordering；
- AuthGuard authorization boundary與local-unlock lifecycle cleanup；
- database historical migration、rollback compatibility、foreign-key／cascade；
- destructive CI artifact cleanup與GitHub storage cleanup safety；
- secret leakage／public repository security；
- validation planner fail-safe與explicit manual intent；
- third-party Skill lock integrity；
- minimal core/security runtime integration smokes。

這些owner仍須遵守Retention Decision；檔名或「Foundation」身分不形成永久豁免。

## Governance reset

Current governance已完成以下反轉：

1. 新test先視為temporary evidence；GREEN後必須做Retention Decision。
2. Permanent test只有critical failure protection可保留。
3. Low-value existing coverage可用`replacement = NONE`退休。
4. Foundation沒有test-density exemption。
5. Classification改為lowest sufficient level by evidence；ambiguity不再自動升級。
6. Level 2不再per-subtask formal audit；Level 3使用one holistic implementation review；Level 4／5以risk boundary而非subtask數量產生formal evidence。
7. Same exact SHA的holistic／post-release可reuse相同GREEN evidence；publish不重跑相同full source regression。

## Validation / CI reset

- `VERSION`現在是`release_metadata`，不再自動等於full release matrix。
- `workflow_dispatch`預設`focused`；只有explicit `full`／`android`／`ios`／`release`升級。
- ordinary feature／package／database source change不自動要求Android＋iOS builds。
- unknown／invalid classification fail-safe到logical full，但不自動啟動昂貴platform builds。
- `observability-acceptance.yml`改為explicit manual acceptance，不再每個PR／main push自動執行。
- iOS workflow不再執行已退休的workflow/source-shape contract test matrix；真正native build是primary evidence。
- Full Flutter workspace command只執行目前真正擁有permanent tests的`flutter_architecture`、`auth`、`api_client`，0-test package合法。

## Fresh validation evidence

- `dart run melos run docs_check`：PASS。
- `git diff --check`：PASS。
- `dart run melos run analyze`：5 packages PASS，0 issues。
- `python -m unittest discover -s tools/ci -p test_*.py`：52 PASS。
- `python -m unittest discover -s tools/docs -p test_*.py`：13 PASS。
- `dart run melos exec --scope=flutter_architecture --scope=auth --scope=api_client -- flutter test`：PASS。
- New logical full Flutter wall-clock：9.37s；read-only admission baseline約53.38s，約82% reduction。
- `python tools/testing/inventory.py`：`files=20 loc=5873 cases=186 output=none`；default不再覆寫historical CSV。

## Findings disposition

- Old planner tests因仍要求`VERSION=release`、ordinary source=platform matrix、post-release always fresh而RED：**intentional stale governance contract**；舊matrix已退休，改由11個critical planner semantics tests保護新contract。
- Full Flutter最初對`core`／`design_system` 0-test packages執行而失敗：**execution plumbing stale after portfolio reset**；runner與canonical commands已改為只執行permanent-test packages，fresh rerun PASS。
- Observability／iOS workflow曾引用已退休test modules：**stale CI consumer**；已改為explicit acceptance／retained secret-leakage guard與real build evidence。

## Release disposition

Local implementation與holistic verification已完成。這是template governance／CI behavior的重大變更，適合作為下一個minor template baseline候選；publication／merge到`main`不在本local review自動執行，避免在未完成branch integration decision前觸發production CI。

