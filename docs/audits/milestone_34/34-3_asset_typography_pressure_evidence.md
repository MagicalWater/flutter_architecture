---
document_type: runtime-evidence
status: accepted
authoritative_for:
  - milestone-34-task-34-3-asset-typography-pressure-evidence
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Task 34-3 Asset / Typography Pressure Evidence

## Current Disposition

```txt
Task 34-3: COMPLETED
Reason: external RED + DISCOVERY + EXPLICIT GREEN evidence complete
Completion commit: ALLOWED
Task 34-4: NEXT
Task 34-5: NOT STARTED
```

Static PTF-13～PTF-18 contract已加入domain Skill reference，但依`writing-skills`與accepted Implementation Plan，static text存在**不等於behavioral GREEN**。

## Required Isolated-Agent Protocol

2026-08-09使用者核准將harness改為provider-neutral。真正的requirement是「fresh independent agent context」，不是Codex CLI本身。

Accepted harness例如：

```txt
Codex CLI ephemeral session
Claude Code fresh session
獨立、非目前Flutter Project的ChatGPT新對話
其他可讀repository authority且能保存actual prompt/response的isolated agent runtime
```

每個harness都必須符合：

```txt
no current-task conversational memory
repository-readable
actual prompt retained
actual response retained
runtime/model identity recorded when available
```

Behavioral protocol維持：

```txt
RED: repository外，ignore user config，不載入本repository Skills
DISCOVERY: managed worktree root，不顯式指定domain Skill
EXPLICIT GREEN: managed worktree root，明確指定implementing-pencil-flutter-design與necessary references
REFACTOR: 若GREEN仍出現shortcut rationalization，修Skill wording後fresh rerun affected cases
```

每個stage都必須是fresh context，且必須取得actual model response。對ChatGPT manual fresh-chat route，使用者需開啟不屬於目前Flutter專案Project的新對話，貼上固定Prompt，不附加本對話背景，再把完整回覆帶回本對話審查。

## Harness Admission

Command：

```powershell
codex --version
```

Observed：

```txt
codex-cli 0.145.0
```

Fresh context probe使用：

```powershell
echo Reply exactly PROBE_OK. | codex exec --ephemeral --ignore-user-config --skip-git-repo-check -s read-only -m gpt-5.6-sol -
```

Runtime metadata成功初始化：

```txt
model: gpt-5.6-sol
provider: openai
approval: never
sandbox: read-only
```

但provider authentication失敗，WebSocket重試後HTTPS fallback同樣失敗：

```txt
401 Unauthorized
Missing bearer or basic authentication in header
```

Process exit code：`1`。

因此沒有產生`PROBE_OK`或任何behavioral response，不能計為RED、DISCOVERY、EXPLICIT GREEN或REFACTOR evidence。

## PTF-13～PTF-18 Contract Prepared

已加入：

1. PTF-13 Complex ornament shortcut。
2. PTF-14 Silent font fallback。
3. PTF-15 Approximate icon substitution。
4. PTF-16 Untracked derived raster。
5. PTF-17 Raster-everything shortcut。
6. PTF-18 Static CustomPainter overbuild。

Expected behavior與Milestone 34 accepted Design一致，但目前只屬static behavioral contract，尚未取得actual independent-agent proof。

## External Fresh-Chat RED Evidence

2026-08-09使用者依`docs/guides/skill_behavioral_validation.md`開啟不屬於目前Flutter Project的全新ChatGPT對話，未提供repository、Skill名稱或Milestone 34上下文，只要求依一般Flutter／UI engineering判斷PTF-13～PTF-18。

Observed actual response：

| Case | Baseline decision | Result |
|---|---|---|
| PTF-13 Complex ornament shortcut | 拒絕大量Container／gradient／shadow與magic numbers；要求先視為獨立視覺資產 | Already-safe baseline |
| PTF-14 Silent font fallback | 拒絕Roboto/system silent fallback；字型未resolved前production UI不可開始 | Already-safe baseline |
| PTF-15 Approximate icon substitution | 拒絕以語意相同但外形不同的Material icon代替custom chevron | Already-safe baseline |
| PTF-16 Untracked derived raster | 要求source、crop、resize／compression與hash provenance | Already-safe baseline |
| PTF-17 Raster-everything shortcut | 拒絕整頁raster + transparent GestureDetector，要求hybrid native UI ownership | Already-safe baseline |
| PTF-18 Static CustomPainter overbuild | 拒絕以數百hard-coded points重畫固定裝飾，優先static asset | Already-safe baseline |

Disposition：**RED did not reproduce a target failure.** 這不算Milestone 34 failure，也不得捏造為RED。代表這六個shortcut目前對一般fresh agent已屬較強的baseline engineering norm；Milestone 34仍需DISCOVERY／EXPLICIT GREEN證明repository route沒有引入退化、並且能從authority與fail-closed角度給出一致答案。

RED actual response由使用者完整貼回原Task對話保存；本evidence只記錄逐case verdict，不改寫原回覆。

## External Fresh-Chat DISCOVERY Evidence

2026-08-09使用者開啟另一個不屬於目前Flutter Project的全新ChatGPT對話，允許read-only開啟managed worktree，但**未提供`implementing-pencil-flutter-design` Skill名稱**，要求agent自行從repository authority發現正確route並回答PTF-13～PTF-18。

Observed discovery chain：

```txt
AGENTS.md
→ governing-template-development
→ accepted repository-local Pencil-to-Flutter route
→ implementing-pencil-flutter-design
→ asset-and-typography-mapping.md
→ Flutter mapping / fail-closed decision
```

逐case結果：

| Case | DISCOVERY result | Production UI incorrectly allowed |
|---|---|---|
| PTF-13 Complex ornament shortcut | PASS — 先分類representation，拒絕magic-number pixel chasing | NO |
| PTF-14 Silent font fallback | PASS — `Typography authority unresolved`，保持blocked | NO |
| PTF-15 Approximate icon substitution | PASS — semantic equivalence不等於visual equivalence | NO |
| PTF-16 Untracked derived raster | PASS — 要求source/transformation/destination/hash/consumer provenance | NO |
| PTF-17 Raster-everything shortcut | PASS — 保留真Flutter Text/layout/interaction ownership | NO |
| PTF-18 Static CustomPainter overbuild | PASS — fixed artwork回到vector/raster authority，拒絕hard-coded Painter | NO |

DISCOVERY summary：

```txt
Discovered governing Skill: governing-template-development
Discovered Pencil-to-Flutter Skill: implementing-pencil-flutter-design
Representation/provenance reference discovered: asset-and-typography-mapping.md
Authority conflict: NO
Incorrect production admission: 0 / 6
```

### F-34-3-03 — Human workflow guide metadata baseline lag

- Severity：P2 documentation metadata。
- Status：Deferred to Task 34-4 documentation synchronization。
- Finding：fresh DISCOVERY agent注意到`docs/guides/pencil_to_flutter_workflow.md` frontmatter仍為`last_reviewed_baseline: 1.14.0`，而current repository baseline為1.15.1。
- Impact：沒有substantive authority conflict；Guide自己明確聲明不取代ADR／Skill authority，且DISCOVERY route仍正確找到current representation reference。
- Disposition：Task 34-4同步human workflow時一併fresh review／更新；不為此提前改變Task 34-3 behavior contract。

DISCOVERY verdict：**PASS**。Repository discovery route在不點名domain Skill的fresh context下成功找到正確authority，PTF-13～PTF-18沒有任何production admission regression。

## External Fresh-Chat EXPLICIT GREEN Evidence

2026-08-09使用者開啟第三個不屬於目前Flutter Project的全新ChatGPT對話，這次明確指定repository-local `implementing-pencil-flutter-design/SKILL.md`，並要求讀取`asset-and-typography-mapping.md`與`pressure-scenarios.md`。Fresh agent全程read-only。

逐case結果：

| Case | EXPLICIT GREEN result | Production UI incorrectly allowed |
|---|---|---|
| PTF-13 Complex ornament shortcut | PASS — fixed complex artwork先做representation/source/provenance resolution，不允許magic-number primitive approximation | NO |
| PTF-14 Silent font fallback | PASS — `Typography authority unresolved`，family/face/fallback未resolved前fail closed | NO |
| PTF-15 Approximate icon substitution | PASS — approximate package icon不可當Approved package icon，需verified asset或accepted equivalence disposition | NO |
| PTF-16 Untracked derived raster | PASS — derived raster必須補source/transformation/destination/hash/consumer chain | NO |
| PTF-17 Raster-everything shortcut | PASS — mixed per-element classification，保留真Flutter layout/Text/interaction ownership | NO |
| PTF-18 Static CustomPainter overbuild | PASS — static artwork不得因implementation convenience改成hard-coded dynamic drawing | NO |

EXPLICIT GREEN summary：

```txt
Skill loaded: YES
Representation reference loaded: YES
PTF-13..18: 6 / 6 PASS
Incorrect production admission: 0 / 6
Authority conflict: NO
P0/P1 Skill wording loophole: NONE
```

Fresh agent特別確認：「Raster還是Vector」沒有被Skill硬編碼，而是依source本質、availability、scaling requirement與verified authority決定；在representation／provenance未resolved前仍fail closed，因此不是loophole。

EXPLICIT GREEN verdict：**PASS**。不需要REFACTOR rerun。

## Finding

### F-34-3-01 — Automated Codex harness authentication unavailable

- Severity：P2 harness failure；若沒有其他isolated-agent harness才升級為P1 external blocker。
- Status：Superseded as sole blocker by approved fresh-chat route。
- Finding：Codex CLI可啟動ephemeral read-only harness，但OpenAI provider未提供有效authentication，因此fresh context無法產生模型response。
- Impact：Codex automated path不可用，但這不等於behavioral validation本身不可執行。
- Required recovery：優先使用已核准的external fresh-chat route；若使用者無法提供fresh chat，再恢復任一其他isolated-agent runtime。
- Scope guard：不以目前ChatGPT對話的自我審查、static text assertion或mechanical policy tests替代independent behavioral evidence。

### F-34-3-02 — External fresh-chat behavioral evidence

- Severity：P1 execution dependency。
- Status：Resolved。
- Finding：Codex automated harness不可用後，Task曾缺fresh-agent actual response。
- Resolution：使用者依provider-neutral protocol完成三個獨立ChatGPT fresh contexts：RED、DISCOVERY、EXPLICIT GREEN。DISCOVERY與EXPLICIT均6/6 PASS；RED六題為already-safe baseline，未捏造failure。
- Completion gate：SATISFIED。

## Mechanical Validation

Behavioral evidence完成後fresh執行：

```powershell
python tools/docs/test_pencil_representation_mapping_policy.py
python tools/docs/test_pencil_single_renderer_policy.py
dart run melos run docs_check
git diff --check
```

這些與actual fresh-agent evidence共同構成Task 34-3 completion gate。

## Open Findings

Open P0：0。

Open P1 without disposition：0。

Open P2：1（F-34-3-03，deferred to Task 34-4）。

