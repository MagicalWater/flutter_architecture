---
document_type: design-spec
status: accepted
authoritative_for:
  - template-product-adoption-backport-design
last_reviewed_baseline: 1.26.1
---

# Template → Product Adoption Backport Design

## Decision summary

本 Design 將 `wl-ai-badminton-app` 實際 Template → Product adoption 所形成的 TA-001～TA-009，重新歸納成四個 template-side corrective domains，而不是九個獨立 patch：

1. Repository lifecycle / product VERSION atomic transition。
2. Executable / workspace technical identity ownership 與 residual identity classification。
3. Native Product Identity 的 single machine authority 與 complete projection verification。
4. Repository-owned runtime tooling portability。

核心原則：**不新增第三份 catch-all adoption manifest，不把 native identity 塞進 `repository_identity.json`，也不讓 Guide / ADR / workflow / verifier 各自保存產品 concrete identity。**

## Requirement Decision

| Item | Decision |
|---|---|
| Request | 將真實產品採用過程暴露的 adoption defects 回補至 `flutter_architecture` |
| Problem | Current bootstrap / native adoption procedure 與 machine tooling 無法完整覆蓋真實 productization lifecycle |
| Expected behavior | 下一個由 template 建立的新產品可依 repository authority 完成產品化，不需重新踩 TA-001～TA-009 |
| Value | 降低人工 inventory、字串替換、tooling drift 與半完成 lifecycle 誤判 |
| Classification | Level 4 — repository-wide stable governance / machine authority |
| Design | Required |
| Plan | Required，Design accepted 後建立 |
| ADR | ADR-030 / ADR-025 amendment gate required；目前不新增平行 ADR |
| Release | Implementation 完成後 explicit disposition；本 Design 階段不 release |

## Confirmed evidence

Template baseline：`1.26.1`。

Product evidence source：`D:\Developer\wl-ai-badminton-app`，只讀使用：

- `4514be8` — Native Product Identity rehearsal closure。
- `fb87f65` — final Template → Product holistic review。
- `55350fa` — template adoption backport handoff。

目前 template 自身三個 machine verifier均 PASS；因此本次不是修復已損壞 baseline，而是修復 adoption path / authority model 無法充分描述與驗證合法 transition 的問題。

## Goals

- Repository productization 與 Native Product Identity 採用可合法分離。
- Template state 下可以機械驗證 prospective product candidate，而不要求 canonical template `VERSION` 暫時違反自身 invariant。
- Product-facing identity、technical/operational identity、native placeholder、compatibility identity、template provenance / history 不再以全文字 replace 處理。
- Native concrete identity 由單一 App-owned manifest authority擁有；build / Firebase / artifact / workflow / verifier只作 projection 或 consumption。
- Environment verifier 覆蓋 adoption Guide 宣稱必須同步的 native identity surface。
- Android / iOS native build entrypoint 與 local CI 使用一致的 working Python interpreter resolution semantics。
- 永久 tests 只保留 machine contract / regression 高價值案例；real artifact / fresh adoption acceptance 優先於大量 source-shape tests。

## Non-goals

- 不修改 `wl-ai-badminton-app`。
- 不要求正式 Bundle ID 才能完成 repository productization。
- 不把 production signing、Store distribution、Firebase credential provisioning 納入 bootstrap。
- 不建立 generic rename framework 或跨語言 AST migration engine。
- 不為 TA-001～TA-009 各建立獨立 ADR、Design、Plan 或 permanent test。
- 不把 compatibility-owned database / platform-channel / web-storage identity強制品牌化。
- 不改變 supported environment set `development / staging / production`。

## Target authority model

### 1. Repository lifecycle owner

`repository_identity.json` 仍只擁有：

```txt
repository_kind
product_name
template_origin.repository
template_origin.baseline
```

它**不新增** bundle identifier、app path、Dart package name、CI profile或API domain。

`VERSION` 語意保持：

```txt
repository_kind = template → Template Baseline
repository_kind = product  → Product Repository Version
```

### 2. Infrastructure owner

`repository_infrastructure.json` 維持現有 ADR-031 scope；本次不擴張成 identity manifest。

### 3. Native identity owner

`apps/<product-app>/config/environments.json` 保持 App-owned native environment / identity machine authority。

Schema 欄位名稱必須 lifecycle-neutral；`templateBaseIdentifier` 應遷移為 neutral base-identifier 語意。Exact final field name由 Implementation Plan 鎖定，但不得保留「product repo 的 product identity仍叫 template base identity」的語意。

### 4. Technical identity

Executable app directory、Dart package name、workspace member path / workspace name 屬於 repository technical identity，不加入 `repository_identity.json`。

Bootstrap procedure 必須對它們做明確 disposition：

```txt
productize
preserve-for-compatibility
not-applicable
```

Current template 的 executable app / workspace technical naming預設應在首次產品採用時產品化；但 persistence / compatibility identity 不因同字串出現就跟著 rename。

## Design A — Atomic repository lifecycle transition

### Problem

ADR-030 / Skill / Guide 要求 final transition 前 canonical `repository_kind` 保持 `template`，但 `verify_repository_identity.py` 對 template state 強制：

```txt
VERSION == template_origin.baseline
```

因此 canonical `VERSION` 無法先改成 product version再做 prospective candidate-product validation。

### Decision

保留 canonical template invariant，不引入 persistent `bootstrapping` state。

Prospective product validation 必須同時接受 **candidate identity manifest + candidate product VERSION**，而不是要求先 mutation canonical root `VERSION`。

Target transition：

```txt
canonical template state + template VERSION
→ product docs / technical naming / native / infrastructure candidate mutations
→ validate candidate product identity against candidate product VERSION
→ selected infrastructure acceptance
→ atomic final write: product VERSION + repository_kind=product
→ canonical fresh identity/infrastructure validation
```

Verifier design requirement：

- canonical invocation維持現有 template/product invariant。
- prospective invocation能明確傳入 candidate manifest 與 candidate VERSION來源。
- prospective validation不得從聊天內容或未追蹤變數猜 product version。
- final write若任一 blocking validation未通過，不得留下 canonical half-product state。

這解決 TA-002，並使 ADR-030 的 atomic boundary真正可被 machine tooling實現。

## Design B — Productization identity ownership

### Problem

真實產品 adoption 證明 `flutter_architecture` 同時出現在 product-facing copy、app path、Dart package、tooling path、database filename、channel、web storage、provenance與historical fixtures。這些不能同一處置。

### Decision

Bootstrap 在任何 broad rename前先產生 bounded residual identity inventory，並按 ownership 分類：

| Class | Default disposition |
|---|---|
| Product-facing | 必須產品化 |
| Executable / workspace technical | 首次 adoption scope內產品化 |
| Native placeholder | Native Identity accepted時產品化；否則合法 Pending |
| Compatibility-owned | 預設保留，除非另有 migration decision |
| Template provenance | 永久保留 |
| Historical / fixture | 保留或依其owner處理，不視為 current stale identity |

不建立永久 residual-identity database。Procedure / tooling只需要能在 adoption 時產生 actionable inventory，最終 machine authority仍回到各 owning source。

### Technical naming requirement

首次 adoption 必須完整處置至少：

```txt
root workspace name / members
executable app directory
executable app Dart package name
tracked .run paths
repository-owned CI / validation / database tooling app paths
package imports / generated references affected by Dart package rename
```

禁止把 `apps/flutter_architecture` 當作永遠不變的 product repository locator。

Lowest-sufficient tooling direction：優先讓 repository tools從 workspace / app manifest discover current executable app，而不是新增另一份 app-path config；只有無法可靠 discover 的位置才在 Plan中提出 explicit machine owner。

這合併處理 TA-001 + TA-003。

## Design C — Native identity single authority / projections

### Problem

目前雖宣稱 `environments.json` manifest-first，但 concrete identity仍重複存在於 Gradle、xcconfig、Firebase verifier、build scripts、observability workflow、ADR與Guide。

### Decision

`environments.json` 是唯一 current concrete native identity owner。

下列元件不得自行保存另一份 expected identity table：

- `build_android_environment.sh`
- `build_ios_environment.sh`
- `verify_android_firebase_config.py`
- `verify_ios_firebase_config.py`
- observability acceptance workflow artifact assumptions
- adoption Guide / ADR 的 product-current concrete mapping

它們必須改成：

```txt
read / receive manifest-derived identity
→ compare actual projection / artifact
→ fail closed on mismatch
```

Template ADR / Guide 可以保留 template example mapping，但必須明確是 **template default/example**，不是 adopted product 的 second current authority。

### Required verifier coverage

Manifest-driven environment verification至少覆蓋：

Android：

- flavor / applicationId / display name / entrypoint / sentinel；
- `namespace`；
- `MainActivity` Kotlin package declaration；
- Kotlin source path與package的一致性。

iOS：

- schemes / configurations / bundle identifier / display name / entrypoint / sentinel；
- environment xcconfig `PRODUCT_NAME`；
- RunnerTests bundle identifier與product base identity的一致性。

Artifact verification：

- Android actual APK package identity必須與manifest environment identity一致。
- iOS actual `.app` bundle identity在可執行Xcode build的host上與manifest一致。
- Windows上的iOS evidence只能標為 static projection，不得描述成Xcode build evidence。

### Native Pending state

Repository可合法為：

```txt
repository_kind = product
native projection = template placeholder / Pending
```

前提是 current product authority明確表示 Native Product Identity 尚未採用，而且任何 Store/Firebase/production-native readiness claim保持 Pending。

不需要在 `repository_identity.json` 新增 native lifecycle field；由 native adoption procedure + manifest placeholder detection / verifier semantics判定 native adoption readiness。

這合併處理 TA-004 + TA-005 + TA-006 + TA-008 + TA-009。

## Design D — Runtime tooling portability

### Problem

`run_local_ci.sh` 已有 working Python resolver，但 native build scripts再次各自 default `python3`，在 Windows Git Bash產生真實失敗。

### Decision

Repository只有一套 Python interpreter resolution semantics：

```txt
explicit PYTHON_BIN if executable and Python 3 capable
→ probe python3
→ probe python
→ fail with clear exit / message
```

Native build scripts不得用未驗證的 `${PYTHON_BIN:-python3}` 作為獨立policy。

Implementation可採 shared shell helper或由 caller保證 export；選 lowest-sufficient、跨Windows Git Bash/macOS可用且不增加 path-specific tracked config 的方案。

這處理 TA-007。

## Documentation design

Current stable rule只回寫 canonical owners：

- ADR-030：repository lifecycle / prospective product validation / technical adoption boundary。
- ADR-025：native identity authority / projection semantics / neutral base identity terminology。
- Template Repository Adoption Guide：end-to-end reusable procedure。
- Native Environment Adoption Guide：native-specific exact procedure與evidence statuses。
- 兩個 adoption Skills：只保留 routing / stop conditions，不複製完整 mapping與commands。

本 Design與後續 Plan在 closure後做 retention decision；預設由 accepted ADR / Guide / source吸收後刪除或archive，不永久佔 current navigation。

## Test / validation design

### Permanent test candidates

只保留能保護 stable machine contract的少量測試：

1. Repository identity prospective candidate version validation。
2. Environment verifier對新增 native projections的正反例。
3. Python resolver behavior（若抽成repository-owned shared resolver且值得永久保護）。

不為每個TA建立一個test。

### Primary acceptance evidence

Implementation closure必須以 fresh/disposable adoption scenario驗證，而不是只跑 template自身PASS：

Scenario A：

```txt
Template
→ productize repository/workspace/app identity
→ repository_kind=product
→ Native Product Identity保留Pending
→ fresh admission仍能正確辨識合法product state
```

Scenario B：

```txt
Template
→ rehearsal base identifier
→ manifest-first native projection
→ environment verifier
→ Android development artifact identity inspection
```

有macOS runtime時再取得iOS Xcode artifact identity evidence；沒有時只接受static projection並標示platform evidence pending/not-in-scope，不虛構build通過。

## Proposed implementation stages

### Stage 1 — Atomic lifecycle contract

TA-002 + TA-005 lifecycle部分。

Expected owners：ADR-030、repository identity verifier、repository adoption Skill/Guide。

### Stage 2 — Technical identity ownership / adoption inventory

TA-001 + TA-003。

Expected owners：repository adoption procedure、tooling discovery / rename surface、相關 path-based CI owners。

### Stage 3 — Native identity authority / verifier closure

TA-004 + TA-005 native部分 + TA-006 + TA-008 + TA-009。

Expected owners：ADR-025、environment manifest、native verifier、build/Firebase/workflow consumers、Native Adoption Guide/Skill。

### Stage 4 — Tool runtime portability

TA-007。

Expected owners：repository-owned CI/native script runtime helper。

### Stage 5 — Fresh adoption acceptance / closure

不新增另一套architecture；只驗證 Stage 1～4 改動真的讓下一個產品不再重踩已知缺口。

## Rejected directions

### 新增 `repository_adoption.json` catch-all manifest

拒絕。會與 repository identity / infrastructure / environment manifest形成第四份 authority，增加同步成本。

### `repository_kind = bootstrapping`

拒絕。ADR-030原本避免第三個persistent lifecycle state是正確方向；真正缺的是 prospective candidate validation能力。

### 將 Bundle ID 存入 `repository_identity.json`

拒絕。Repository lifecycle 與 native identity已由真實產品證明可獨立演進。

### 全 repository 直接 replace `flutter_architecture`

拒絕。會破壞 compatibility / provenance / historical ownership。

### 為每個 finding 建立 verifier / permanent test

拒絕。以root contract和machine owner為單位保護即可。

## Approval gate

本文件目前狀態為 `proposed`。

Design review通過並取得使用者明確核准前：

- 不建立 Implementation Plan；
- 不修改 ADR / Guide / Skill / source / tooling / tests；
- 不修改 `wl-ai-badminton-app`；
- 不 commit / push。

