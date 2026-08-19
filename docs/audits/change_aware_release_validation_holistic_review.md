---
document_type: final-review
status: accepted
authoritative_for:
  - change-aware-release-validation-holistic-implementation-review
last_reviewed_baseline: 1.25.0
---

# Change-aware Release Validation — Holistic Implementation Review

## Scope

本 review 覆蓋 accepted Design / Plan 的 local implementation：release range planning、release freshness semantics、platform impact escalation、CI／Android／iOS workflow routing、planner-failure fallback、ADR／Guide／Skill authority同步，以及 Test Retention Decision。

本 review **不宣稱 release 已授權或已發布**。`VERSION`、`CHANGELOG` release section、repository identity、remote push與GitHub-hosted iOS exact-candidate evidence均保留給正式 release gate。

## Implementation result

**PASS — local implementation complete.**

Current branch：`corrective/change-aware-release-validation`。

Implementation checkpoint：`4da03d35cd0e06c7a7a8975df7f833901e3ca8c4`。

Retention checkpoint：`9866d5b`。

## Core behavior review

### Release scope

PASS。`workflow_dispatch --mode release` 已從 empty-path fixed matrix改為使用 `release_base`＋exact candidate SHA做range planning，再疊加freshness。Release intent不再無條件設定full/generated/Android/iOS。

### Risk families

PASS。

- docs／governance／release metadata：focused，不自動generated／platform。
- database／generated：保留generated，不自動platform。
- Android native：Android only。
- iOS native：iOS only。
- root dependency/toolchain：full＋generated＋雙平台。
- planner/classifier selection authority：full＋generated＋雙平台。
- Android／iOS workflow routing：只升級對應platform；CI workflow本身不因名稱升級platform。
- invalid release range：full＋generated＋雙平台fail-safe。

### Workflow fallback

PASS。Planner process failure不再由YAML直接固定雙平台；先使用canonical `change_classifier.py`保存可判定的platform impact。Classifier／range也不可判定時才雙平台fail-safe。Workflow沒有新增第二套path matrix。

### Evidence freshness

PASS。`gate="release"`仍拒絕reuse ordinary GREEN；same-SHA post-release仍只允許identity／artifact semantics，不恢復source regression循環。

## Validation evidence

### Critical tooling / governance owners

- `tools/ci` permanent owners：51/51 PASS（Retention前whole run）。
- `tools/docs` permanent owners：6/6 PASS。
- Retention後 `tools.ci.test_validation_planner`：18/18 PASS。
- Documentation checker：PASS。
- YAML parse：CI／Android／iOS三份workflow PASS。
- `git diff --check`：PASS。

### Logical full

在implementation source不再變更後執行：

- 5-package Flutter analyze：PASS。
- retained Flutter suites：`flutter_architecture`、`auth`、`api_client` PASS。

Retention checkpoint只合併test permutations，沒有修改planner／workflow implementation，因此不重跑相同Flutter source regression。

### Generated consistency

Clean implementation checkpoint `4da03d3`：PASS。Generator產生的Windows LF／CRLF working-tree noise已還原，沒有tracked semantic generated diff。

### Planner self-selection

修正後 planner 對 `1.25.0 main 9b0754b → implementation checkpoint` 的 explicit release planning輸出：

```txt
change_classes = docs_content, governance, validation_engine
validation_level = release
full_regression = true
generated_check = true
android_build = true
ios_build = true
release_full = true
```

本 corrective仍要求雙平台，是因為它實際修改planner與跨平台workflow routing，不是因為release名稱本身。

### Android pre-release primary evidence

Implementation checkpoint `4da03d3`：

- Development Debug APK：PASS；package id `com.example.flutterarchitecture.development`。
- Production Release APK：PASS；package id `com.example.flutterarchitecture`。
- Production Flutter symbols：3。
- Production mapping：present。

第一次Git Bash invocation命中WindowsApps無效`python3` shim而exit 49；repository script已有`PYTHON_BIN`受控override，改用`PYTHON_BIN=python`後兩個build均PASS。這是local shell environment finding，不是repository implementation defect。

此Android evidence只支援local implementation review；不得冒充尚未建立的final release candidate exact-SHA evidence。

## Test Retention Decision

PASS。沒有新增永久test file。新增release permutations已合併成代表risk-family matrix，planner critical owner由中途20 cases收斂為18 cases；保留invalid-range、workflow wiring、freshness reuse等不同failure modes。

## Findings

- Open P0：0。
- Open P1：0。
- External/manual blocker：無 implementation blocker。
- Release gate仍需使用者明確授權，之後才可建立final release metadata candidate、執行exact candidate fresh planner-selected Android／iOS evidence並push/publication。

## Release disposition

本 corrective 改變stable repository release-governance capability與ADR-023 contract，建議 **PATCH release 1.25.1**。

目前只完成local implementation與holistic review；尚未修改`VERSION`／release `CHANGELOG`／repository identity，尚未push，也尚未建立final release candidate。

## Final disposition

Local implementation review：**PASS**。

下一合法 gate：使用者 explicit release authorization → 同步 `1.25.1` release metadata → 建立exact candidate → 只執行一次修正後planner-selected fresh release evidence → publication → same-SHA identity/read-back closure。
