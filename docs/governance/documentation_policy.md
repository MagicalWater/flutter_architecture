---
document_type: governance-policy
status: accepted
authoritative_for:
  - documentation-governance-and-metadata
last_reviewed_baseline: 1.27.0
---

# Documentation Governance Policy

本文件定義 repository 文件的 authority、metadata、生命週期與可控增長規則。

## 1. Single Authority

每一項事實只能有一個 authoritative owner。

其他文件可以：

- 提供短摘要。
- 連結 authority。
- 保存當時的 plan、review 或 evidence。

其他文件不得：

- 複製完整 contract 並獨立維護。
- 將 historical state 寫成 current instruction。
- 以 plan 或 audit 覆蓋 current snapshot 或 Architecture Decision。

## 2. Document Types

受治理的新文件使用下列 `document_type`：

```txt
agent-policy
project-entry
documentation-hub
current-snapshot
app-readme
feature-readme
package-readme
architecture-decision-index
architecture-decision
roadmap-index
active-milestone
roadmap-candidates
backlog
design-spec
implementation-plan
planning-review
phase-review
runtime-evidence
final-review
audit-index
design-plan-index
milestone-index
milestone-archive
guide
knowledge
governance-policy
migration-manifest
```

新增類型前，必須證明現有類型無法表達責任；不得只因內容不同就建立新類型。

## 3. Minimal Metadata

新增或正式採納的 managed document，使用 YAML front matter：

```yaml
---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-22-phase-2-review-evidence
last_reviewed_baseline: 1.5.0
---
```

### Required fields

#### `document_type`

文件的責任類型，值必須來自本政策 whitelist。

#### `status`

允許值：

```txt
draft
proposed
accepted
active
completed
archived
superseded
legacy
```

語意：

- `draft`：尚未完成內部 review。
- `proposed`：可 review，但尚未拍板。
- `accepted`：設計、決策、政策或 review 已核准。
- `active`：目前正在執行或代表 current state。
- `completed`：工作已完成，但尚未完成 archive transition。
- `archived`：只供歷史與追溯。
- `superseded`：已有新的 authority 取代。
- `legacy`：舊格式或占位文件，禁止視為 current authority。

#### `authoritative_for`

列出此文件唯一擁有的 scope key。Scope key 使用小寫 kebab-case，應描述責任，不描述檔名。

同一 scope key 不得同時出現在兩份 `active` 或 `accepted` authority 文件中。Index、summary 或 evidence 不得宣稱其未擁有的 scope。

#### `last_reviewed_baseline`

最近一次完整確認內容仍適用的 Template Baseline。值必須與某個已正式發布版本一致。

Historical evidence 可以保留當時 baseline，不需要每次 release 都改寫。

## 4. Optional Metadata

有需要時可加入：

```yaml
id: ADR-022
title: Authentication Security Capability Boundaries
owners:
  - app-architecture
related:
  - docs/audits/milestone_21/21-5_android_security_runtime_review.md
supersedes:
  - ADR-015
superseded_by:
  - ADR-023
```

禁止建立無使用者、無 checker 或無 routing 價值的 metadata。

## 5. Lifecycle

### Current / policy document

```txt
Draft
→ Review
→ Active / Accepted
→ Superseded
→ Archived historical record
```

### Milestone artifact

```txt
Design spec
→ Planning review
→ Implementation plan
→ Phase reviews / runtime evidence
→ Final review
→ Milestone archive routing
```

Plan、review 與 evidence 完成後不持續改寫為新的 current state；current claim 必須更新其唯一 authority。

## 6. Archive Triggers

符合下列任一條件時，文件應進入 retention decision：

- Milestone 已通過 final review 並發布或正式封存。
- Current policy 或 Decision 已被 supersede。
- Implementation plan 已完成且不再執行。
- Review evidence 已完成 closure。
- 文件只剩歷史解釋價值。

Retention disposition只有三種：

- **Keep**：仍是 current navigation / authority 必要入口。
- **Archive**：重大 migration、incident、platform/runtime acceptance、architecture transition 或 consolidated closure，且具有獨立長期追溯價值。
- **Delete**：只剩 implementation process 價值，已被 ADR、source、guide、final authority 或 later closure 吸收；由 Git history 保存即可。

Archive trigger 不代表 mandatory permanent retention。Intermediate Design review、Plan review、per-task review、checkpoint、handoff、temporary admission 與已被 final review 吸收的過程證據，預設不永久保留。Archive 也不要求立即物理搬檔；只要 routing 清楚且不污染 current navigation，可以留在 historical tree。

## 7. Legacy Adoption Rule

既有 historical／legacy 文件不要求為了格式一致性一次性補齊 metadata。

Legacy 文件只有在下列情況才正式採納新 metadata：

- 被重寫為 current authority。
- 被拆分或搬移。
- 成為新的 managed index。
- 因實際需求進行重大修改。

採納時必須先確認：

- 文件類型正確。
- Authoritative scope 沒有與其他 current 文件重疊。
- Status 與實際 lifecycle 一致。
- Historical current-tense 內容已標示或移出 current path。

不得為了追求 metadata coverage，在未做 semantic review 時批量標記舊文件為 `accepted`。

## 8. Controlled Growth

新增文件前必須回答：

1. 這是 current、decision、plan、evidence、release、guide 還是 history？
2. 它唯一擁有什麼 scope？
3. 現有文件是否已擁有該 scope？
4. AI 何時需要讀它？
5. 工作完成後如何封存？
6. 哪個 index 負責導向它？

無法回答時，不新增文件。

Current 與 index 文件禁止追加逐 Task journal、測試數成長紀錄、commit timeline 或重複完整 Decision contract。

## 9. Summary Rule

非 authority 文件引用某項資訊時，使用：

```txt
一句至一小段摘要
+ authority link
+ 必要 status
```

當摘要與 authority 衝突時，以 authority 為準，並修正摘要。

## 10. AI Reading Rule

固定 fresh admission 由 `AGENTS.md` 擁有；`docs/README.md` 只擁有 documentation taxonomy 與按需文件路由。本政策只定義文件治理，不再複製完整 reading route。

## 11. Migration Safety

大型拆分或搬移必須：

- 建立逐 section migration manifest。
- 保留 Decision、Milestone、Finding 與 Release stable ID。
- 執行 semantic preservation review。
- 檢查 relative links。
- 必要時保留 transitional stub。
- 經 review 後才移除舊正文。

禁止直接以「已搬到新文件」取代未驗證的歷史內容。

## 12. Automated Documentation Check

Repository 提供固定本地指令：

```bash
dart run melos run docs_check
```

實作位於：

```txt
tools/docs/check_docs.py
```

目前 checker 僅使用 Python standard library，檢查：

- Relative Markdown link target，並忽略 fenced code example。
- `VERSION`、Root README 與 CHANGELOG 最新正式版本一致性。
- Managed document required metadata、type、status、scope 與 baseline format。
- Explicit metadata `id` uniqueness。
- 同時存在多份 active milestone document 的 status contradiction。
- App、Package 與 production Feature README coverage。

Checker 是 governance safety net，不取代 semantic review。它不得推斷 prose 是否正確，也不得因歷史 artifact 沒有採用 managed metadata 就直接失敗。

新增 checker rule 時依風險建立最低充分驗證；需要 fixture 驗證時可使用 temporary test 確認 RED / GREEN，完成後依 test retention governance 決定是否保留，不要求為每條規則永久新增測試檔。

## 13. Repository Skill Ownership and Language

`.agents/skills/`中的Markdown依ownership區分責任：

```txt
repository-authored
→ repository自己擁有內容；適用繁體中文、identity、review與pressure governance

repository-maintained fork
→ 曾修改third-party managed bytes；視同repository-authored重新治理

third-party-unmodified
→ 保留upstream raw bytes／語言／結構；只有完整lock驗證通過才可取得語言checker豁免
```

`third-party-unmodified`豁免必須由root`skills-lock.json`證明immutable commit、exact source／install path、逐檔SHA-256、exact license bytes與license hash。缺檔、unknown file、hash drift、path escape、duplicate install path、mutable revision或license drift任一發生時，整份lock fail closed，不能只豁免「看起來沒改」的檔案。

文件政策只擁有ownership／language classification；Skill的trigger、permissions、workflow、approval、rollback與upgrade disposition仍由`docs/governance/development_workflow.md`、中央治理Skill與accepted adoption evidence擁有。
