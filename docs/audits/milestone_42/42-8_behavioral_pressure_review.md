---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-42-task-42-8-behavioral-pressure
last_reviewed_baseline: 1.21.0
---

# Milestone 42 — Task 42-8 Fresh Behavioral Pressure Review

## Method

依 `docs/guides/skill_behavioral_validation.md` 使用 fresh discovered production `chatgpt-web-generation` text route。每個 scenario 由獨立 ChatGPT Web context 回答；沒有把本對話記憶或 expected answer 直接餵給 fresh Agent。

Fresh Executor authority：

```txt
integration: chatgpt-web-generation
generate path: chatgpt-web-generation.org.default.generate_chatgpt_web_generation
result policy: image_or_text
surface: chat
```

本輪補齊 PTF-30～34、semantic negative edge 與 positive promotion control。Positive control 第一次 downstream call timeout，沒有產生 verdict；依 protocol 不計 PASS/FAIL，改以另一個 fresh context 重跑同一語意 pressure。

## PTF-30 — Shared semantic values hidden in FeatureVisualSpec

Scenario：Login、Home、Settings 三個 accepted screens 共享 app background、primary text、brand accent，但 implementation 各自建立 FeatureVisualSpec 並重複 literal。

Fresh actual behavior核心：

- 拒絕把跨 screen 同一 semantic identity 留在三個 feature-local owners；
- 要求以 shared semantic token / Design System owner治理；
- 同時保留真正 feature-specific visual values 的 local ownership。

Verdict：**PASS**。

## PTF-31 — Single-screen exact values pollute Design System

Scenario：只有單一 Hero 使用 `radius=17` 與 decorative gradient，沒有第二 consumer 或 shared semantic evidence，作者仍要建立 global `DsRadius.hero` / `DsGradient.hero`。

Fresh actual behavior核心：

- 明確拒絕 premature tokenization；
- 判定 current owner 應是 Hero/component-local scope；
- 只有真實跨 component shared semantics、accepted DS authority 或多 consumer change coupling 出現後才 promotion。

Verdict：**PASS**。

## PTF-32 — Same layer used to justify page responsibility dump

Scenario：`pages/screen_canvas.dart` 同時持有 Page、15 個 section widgets、custom RenderObject、projection/calibration helpers；作者以「全部都是 Presentation」要求通過。

Fresh actual behavior核心：

- Request Changes；
- 明確指出同一 Clean Architecture layer 不等於同一 responsibility；
- Page orchestration、bounded composition、rendering infrastructure、projection/geometry 應依 change reason 分 owner；
- 沒有以行數或「每 class 一檔」作 oracle。

Verdict：**PASS**。

## PTF-33 — Generic FeatureUiSpec dumping

Scenario：一個 `FeatureUiSpec` 同時集中 palette、font/fallback、spacing、radius、button dimensions、image/icon paths、decorative gradients、screen geometry offsets；作者以「避免 magic values」合理化。

Fresh actual behavior核心：

- Reject / request refactor；
- 判定為 responsibility-mixed God configuration；
- shared semantic values → Design System；component dimensions → component owner；assets → asset owner；screen coordinates → local layout owner；
- 不把「集中 constants」本身當成正確架構。

Verdict：**PASS**。

## PTF-34 — Asset paths inside VisualSpec

Scenario：`CheckoutVisualSpec` 直接擁有 `heroImagePath`、`warningIconPath`、`backgroundTexturePath`、`fontAssetPath`，repository 已另有 provenance records。

Fresh actual behavior核心：

- 判定 architecture 不合理，Request Changes；
- asset identity/path/provenance 必須由既有 asset/provenance authority 擁有；
- VisualSpec 不得成為第二 source of truth 或繞過 provenance 的 raw-path owner；
- widgets 應消費 resolved asset owner/reference，而不是讓 generic visual constants class 取得 asset authority。

Fresh response使用「asset registry」作一般化描述，但本 repository 的 accepted authority 明確是不建立第二套 registry；review採其 ownership 判斷，不採用新增 registry 的泛化措辭。

Verdict：**PASS**。

## Negative edge — Same hex does not prove shared semantics

Scenario：兩個無關 component 都暫時使用 `#5A7184`；一個是 informational border，一個是 disabled decorative ornament；改變其中一者不應自動改另一者。

Fresh actual behavior核心：

- 拒絕只因 literal equality 就 promotion 成同一 Design System token；
- ownership 依 semantic identity 與 intended change coupling，而不是 hex equality；
- 明確給出「Same value ≠ same token」的判斷。

Verdict：**PASS**。

## Positive control — Proven shared semantic identity should promote

Scenario：Login、Home、Settings 的 primary action color 被 accepted product design 明確定義成同一 Theme Identity semantic role；多個 production consumers 必須一起演進；Design System 已有 public semantic color API。

First call：downstream timeout；沒有 response，**不計 verdict**。

Fresh retry actual behavior核心：

- 明確判定 ownership 應 promotion/map 到 Design System；
- feature 不應各自保存 local color constant；
- 決定證據是 shared semantic identity + cross-feature change coupling + existing public DS owner；
- local ownership只留真正 feature-specific visual detail。

Verdict：**PASS**。

## Layer 1 — Focused review

- PTF-30～34 均得到 expected ownership decision。
- Negative edge 證明 governance 不會因 literal equality 過度 promotion。
- Positive control 證明 governance 也不會反向把所有值永遠留 feature-local。
- Asset case 沒有把 fresh Agent 的 generic「registry」措辭升格成 repository authority；repository 仍沿用既有 provenance/representation contract。
- 沒有以目前執行對話自答冒充 fresh behavior。

Open P0：0。

Open P1 without disposition：0。

Focused review：**PASS**。

## Layer 2 — Whole-task review

Task 42-8 同時驗證 accepted Design 的兩個對稱風險：

```txt
shared semantic value 不得躲進 FeatureVisualSpec
AND
single-screen exact value 不得污染 Design System
```

並補齊：

```txt
page responsibility ownership
generic UI Spec dumping
asset/provenance ownership
same-literal edge
proven shared-semantic positive control
```

結果不是單向「全部 promotion」或「全部 local」，而是依 semantic identity、stable ownership、consumer/change coupling、asset authority 與 smallest-correct-owner routing作 decision。

Whole-task review：**PASS**。

## Final disposition

```txt
PTF-30: PASS
PTF-31: PASS
PTF-32: PASS
PTF-33: PASS
PTF-34: PASS
negative edge: PASS
positive control: PASS
Open behavioral P0: 0
Open behavioral P1 without disposition: 0
Task 42-8: accepted
```
