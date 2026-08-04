---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-5-orchestration-skill-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-5 Orchestration Skill Review

## Scope

本review涵蓋：

- Repository-authored`implementing-pencil-flutter-design`Skill與五份references。
- Central`governing-template-development`domain routing與pressure scenarios。
- Human governance registry、trigger、responsibility、permissions與rollback。
- RED／DISCOVERY／EXPLICIT／REFACTOR behavioral evidence。

本Task不操作Pencil、不解析`.pen`、不export canonical preview，也不修改Flutter source。

## Responsibility Boundary

### Owned

- 驗證accepted Design／Plan、managed worktree、visual manifest與loaded Skill provenance。
- 路由Pencil MCP admission與structure extraction。
- 把Pencil items映射到既有Design System、Localization、feature-local visual spec、icons與widgets。
- 路由TDD、golden、runtime、pixel diff、semantic review與anti-cheat review。

### Explicitly not owned

- Requirement classification。
- Design／Plan acceptance。
- `.pen`native parsing或direct mutation。
- Brand／layout free redesign。
- Release、push、worktree cleanup或Milestone closure。
- Taste Skill source integrity；該責任由root lock與Task 33-3 evidence擁有。

中央Skill仍是唯一入口；新Skill只在所有Pencil-to-Flutter admission gates通過後載入。

## Trigger Review

Trigger同時要求：

- Accepted repository-local Pencil-to-Flutter Requirement。
- Accepted Design與Implementation Plan。
- Approved managed worktree。
- Repository-local visual manifest與primary `.pen`。

以下不觸發：Figma-only、image-only concept、普通Flutter feature、already-coded UI bugfix、external-only `.pen`、proposed Plan。

Accepted `.pen`存在時，`imagegen-frontend-mobile`不因「找靈感」自動觸發。

## Reference Review

### `visual-authority-contract.md`

固定`.pen`primary、derived preview、supplementary PNG、historical benchmark與runtime evidence ranking；禁止external active authority、path/hash drift與自行解決Design conflict。

### `pencil-admission.md`

固定worktree／manifest／collision／integration gates、fresh app state、document identity、guidelines loading與MCP-only structure access。明確指出read-only native parser同樣禁止。

### `flutter-mapping.md`

固定Feature First、App-only Composition Root、Localization、Design System與feature-local exact values。Presentation-only畫面不得建立fake layers；mapping後先做RED tests。

### `visual-validation.md`

固定RED→GREEN→golden→diff→runtime→semantic→anti-cheat→regression順序；禁止threshold widening、thumbnail upscale、dynamic masks、raster embedding與top-level fixed canvas scaling。

### `pressure-scenarios.md`

涵蓋normal route與九種shortcut／conflict pressures；明確定義case independence與production-code semantics。

## Focused Findings

### F-33-5-01 — Tests-first boundary在DISCOVERY route中不夠顯著

- Severity：P1。
- Status：Resolved。
- Evidence與fix：見[`33-5_orchestration_pressure_evidence.md`](33-5_orchestration_pressure_evidence.md)。
- Fresh re-review：受影響DISCOVERY與EXPLICIT contexts均先進RED，production code為NO。

## Permissions and External Dependencies

- Skill本身不取得credential、network、filesystem mutation或MCP permission。
- Pencil操作仍由`executor-local-mcp`／`pencil-local-mcp` integration gate擁有。
- Flutter source mutation仍受accepted Plan、TDD與repository worktree權限控制。
- Taste Skills不取得自動image generation或redesign authority。

## Rollback and Upgrade

Rollback：

1. 移除`.agents/skills/implementing-pencil-flutter-design/`。
2. 移除中央Skill的Pencil domain route與pressure rows。
3. 移除human registry row與Guide routing。
4. 驗證ADR-028、visual source與historical audits仍可獨立保存，不會變成平行runtime route。

重新驗證trigger：任何trigger wording、reference、workflow ordering、managed files、permissions、supported runtimes、Pencil integration contract或auto-loading變化。

## Whole-Task Review

- 新Skill沒有複製Level、Requirement Decision、approval或release contract。
- 所有normal／stop routes可追溯至中央governance與accepted artifacts。
- Taste Skills保持stage-specific companions。
- `.pen`MCP-only boundary明確且有behavioral RED evidence。
- Presentation-only與tests-first contract不建立fake architecture。
- 文件預設繁體中文，technical identifiers保留英文。
- Current source／Pencil／Flutter runtime未被本Task修改。

## Validation

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
Codex RED baseline cases
Codex DISCOVERY full PTF-01..PTF-10
Codex EXPLICIT full PTF-01..PTF-10
Codex REFACTOR DISCOVERY PTF-01／PTF-07
Codex REFACTOR EXPLICIT PTF-01／PTF-07
```

Fresh final result：

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
→ 36 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed

Codex behavioral protocol
→ RED baseline reproduced 3 shortcut families
→ DISCOVERY full matrix passed after refactor
→ EXPLICIT full matrix passed
→ affected DISCOVERY／EXPLICIT fresh reruns passed
```

## Disposition

```txt
Focused review: PASSED after F-33-5-01 fix
Fresh focused re-review: PASSED
Whole-Task review: PASSED
Behavioral validation: PASSED
Open P0: 0
Open P1 without disposition: 0
Task 33-5: ACCEPTED
Next Task: 33-6 Pencil MCP Admission and Design Extraction
```
