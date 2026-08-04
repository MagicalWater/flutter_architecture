---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-2-skill-lock-governance-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-2 Skill Lock Governance Review

## Scope

本review涵蓋：

- `inspect_skill_lock(root: Path) -> SkillLockInspection` contract。
- Third-party unmodified Skill的immutable source、install path、exact inventory、raw SHA-256與license bytes驗證。
- Ownership-aware Markdown語言豁免與docs checker integration。
- Repository-authored／fork永不由lock取得語言豁免。
- Skill adoption reference與人類治理總覽同步。

本Task不安裝任何Taste Skill，也不建立production `skills-lock.json`；真正source pin與admission由Task 33-3擁有。

## TDD Evidence

### RED

新增`tools/docs/test_skill_lock.py`，初始執行：

```txt
python -m unittest tools.docs.test_skill_lock
→ ModuleNotFoundError: No module named 'tools.docs.skill_lock'
```

RED由缺少production contract造成，不是fixture或syntax error。

Fixture matrix涵蓋：

1. Locked unmodified English Skill取得豁免。
2. Unlocked English Skill仍觸發語言issue。
3. Missing locked file。
4. Unknown actual file。
5. Raw hash drift。
6. Install path escape。
7. Duplicate install path。
8. Non-immutable commit。
9. Repository-maintained fork不得偽裝成unmodified。
10. Missing locked license。
11. License hash drift。
12. Invalid JSON。
13. Locked file path escape。

### GREEN

Implementation建立：

- `SkillLockIssue`。
- `SkillLockInspection`。
- `inspect_skill_lock()`。
- Repository／install-root path confinement。
- Raw-byte SHA-256。
- Exact locked／actual file set comparison。
- Exact repository-local license verification。
- Docs checker issue conversion與exact Markdown exemption injection。

初始GREEN：

```txt
python -m unittest tools.docs.test_skill_lock
→ 13 tests passed
```

## Focused Findings

### F-33-2-01 — Invalid lock仍可能保留先前Skill的部分語言豁免

- Severity：P1。
- Status：Resolved。
- Finding：第一版parser以per-Skill issue count決定exemption；當第一個Skill有效、第二個Skill發生duplicate install path時，inspection雖有issue，第一個Skill的Markdown仍留在exemption集合。
- Risk：Docs checker最後仍會因lock issue失敗，但partial exemption state違反「整份lock零issues才豁免」的fail-closed contract，也可能被其他caller誤用。
- RED control：`test_duplicate_install_path_fails`新增`exempt_markdown_paths == frozenset()`，第一輪正確FAIL並顯示殘留`SKILL.md`。
- Fix：Return前先freeze sorted issues；只要存在任何issue，整份inspection回傳空exemption集合。
- Fresh GREEN：targeted test通過；combined 34 tests通過。

### F-33-2-02 — `docs_check` direct script execution無法解析package import

- Severity：P1。
- Status：Resolved。
- Finding：Unittest以module mode執行時repository root位於`sys.path`，但`tools/docs/run_check.dart`直接啟動`tools/docs/check_docs.py`；此時`sys.path[0]`為`tools/docs`，新增的`from tools.docs.skill_lock`因此在真實`docs_check`路徑失敗。
- Root cause evidence：34個Python tests通過後，`dart run melos run docs_check`穩定重現`ModuleNotFoundError: No module named 'tools'`。
- Pattern comparison：Repository既有`tools/ci/artifact_cleanup.py`、`artifact_store.py`與其他direct scripts在`__package__ in (None, "")`時加入repository root。
- RED control：新增`test_check_docs_script_supports_direct_execution`，以`sys.executable check_docs.py <fixture-root>`直接執行，修正前正確FAIL。
- Fix：在`check_docs.py`套用既有`__package__` guard，將`Path(__file__).resolve().parents[2]`加入`sys.path`後再import sibling package。
- Fresh GREEN：direct-execution test通過；combined 35 tests、repository`docs_check`與`git diff --check`全部通過。

## Parser and Integrity Review

### Source identity

- `commit`只接受40-character lowercase hex。
- `repository`與upstream `path`必須為non-empty strings。
- Source identity只驗證machine contract；Task 33-3仍須以network／Git evidence證明commit與bytes相符。

### Path confinement

- Absolute path一律拒絕。
- `installPath`resolve後必須位於repository root。
- 每個locked file resolve後必須位於install root。
- License `localPath`resolve後必須位於repository root。

### Inventory and hashing

- Locked file list與install root實際file inventory採exact set equality。
- Missing locked file、unknown actual file與duplicate locked path均fail。
- SHA-256直接使用`read_bytes()`，不做newline normalization。
- License exact bytes獨立驗證，不依source URL或人工license label。

### Ownership and language

- 只有`ownership == third-party-unmodified`可形成候選exemption。
- Repository-authored與repository-maintained fork永不由lock取得語言豁免。
- 任一global issue撤銷全部exemptions。
- Lock absent時維持既有repository-authored中文contract。

## Whole-Task Review

### Boundary

變更只位於Plan列出的`tools/docs`、Skill adoption reference、governance overview與Task review。沒有建立root lock、沒有vendor third-party bytes、沒有操作Pencil或Flutter source。

### Authority

- Machine lock只擁有provenance與integrity。
- Registry繼續擁有status、trigger、responsibility、permissions、behavioral evidence與rollback。
- Central governing Skill繼續擁有Requirement、approval、Task、release與closure。
- ADR-028繼續擁有stable ownership／MCP／mapping／visual acceptance decision。

### Compatibility

Repository目前沒有root `skills-lock.json`，因此current repository-authored Skills仍走既有中文檢查，不受新增parser影響。

## Validation

Fresh final validation commands：

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
```

Fresh結果：

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
→ 35 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed
```

## Disposition

```txt
Focused review: PASSED after F-33-2-01 and F-33-2-02 fixes
Fresh focused re-review: PASSED
Whole-Task review: PASSED
Open P0: 0
Open P1 without disposition: 0
Task 33-2: ACCEPTED
Next Task: 33-3 Pin and Admit the Three Taste Skills
```
