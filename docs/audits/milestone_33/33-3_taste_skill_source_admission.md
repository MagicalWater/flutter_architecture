---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-3-taste-skill-source-admission
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-3 Taste Skill Source Admission

## Scope

本review涵蓋：

- Taste Skill immutable upstream commit resolution。
- External local candidates、Git commit blobs與repository vendored bytes的identity關係。
- Exact MIT license bytes。
- Root`skills-lock.json`、path-specific LF checkout contract與machine validation。
- 三份Skill的Pilot／restricted registry disposition。
- Accepted Plan中Windows working-tree hash與canonical Git blob hash的有界執行修正。

Runtime discovery與same-name collision pressure另見[`33-3_taste_skill_discovery_pressure_evidence.md`](33-3_taste_skill_discovery_pressure_evidence.md)。

## Immutable Source

```txt
Repository: https://github.com/Leonxlnx/taste-skill.git
Resolved HEAD: e988add20dab0fa97d7a76781c48961c8184288e
Commit date: 2026-07-23T18:01:24+02:00
Author: Leon Lin <lexn.lin8@gmail.com>
Subject: Increase featured sponsor size
Checkout mode: detached exact commit
```

Source paths：

```txt
skills/brandkit/SKILL.md
skills/soft-skill/SKILL.md
skills/imagegen-frontend-mobile/SKILL.md
LICENSE
```

## Byte Identity Matrix

| Installed Skill | External Windows working-tree SHA-256 | Canonical Git blob／vendored LF SHA-256 | Lines | Normalized equality |
|---|---|---|---:|---|
| `brandkit` | `a250c7b41aecacc412260de2fb429d36ada5f668388aad1770289fa3e5c4f740` | `b0c4837e1bd140ca816ae54948754ddd2ac1e2a4d3619363777a80caf00b2ede` | 798 | CRLF→LF exact equality |
| `high-end-visual-design` | `2d11cdcefc8bf319429ee17d94d69a390802e2acf7163662d1eacbcf5be3ff79` | `e1e32f5e2d420872c6c7332b53d5ff7721946766b78c4822b424c2d512c8fdbc` | 98 | CRLF→LF exact equality |
| `imagegen-frontend-mobile` | `3cadf1bfbe836d377832d090e5db8479f98903453a4d1342be9636178755f9dd` | `8a33389979f3074fa0926678e266ad2eb9234624472254469fc1ad916b9caa24` | 1465 | CRLF→LF exact equality |

External candidates每行使用CRLF；immutable Git blobs與repository vendored files使用LF。`splitlines()`逐行比較與byte-level`CRLF → LF`轉換後比較均為True。Repository沒有把external candidate path當active source；candidate只作admission evidence。

License：

```txt
Identity: MIT License
Upstream source path: LICENSE
Vendored path: third_party/skills/taste-skill/LICENSE
Canonical Git blob／vendored LF SHA-256:
4575a543ab88dad12ccea7d97e563d0bce5b448b06072e65d3264497dad326df
```

## Focused Finding

### F-33-3-01 — Accepted Plan hashes混合Windows checkout bytes與immutable source bytes

- Severity：P1。
- Status：Resolved。
- Finding：Plan原先列出的三個「raw SHA-256」可由Windows checkout重現，但`core.autocrlf=true`已把Git LF blobs轉成CRLF；它們不是immutable commit blob hashes。若把CRLF hashes寫入lock，同時又要求`apply_patch`加入LF original content，lock會立即失敗；若不固定EOL，clean checkout也可能漂移。
- Root cause：Admission先hash working-tree files，未直接hash`git show <commit>:<path>`的immutable blob bytes。
- Authority resolution：Accepted Design與ADR-028已明確要求third-party unmodified、exact upstream bytes與LF content；因此不需要新架構決策，canonical lock必須使用Git blob bytes。External CRLF hashes保留為candidate evidence。
- Plan correction：Task 33-3現在同時列出external working-tree hashes與canonical blob hashes，並把`.gitattributes`加入Task files／steps。
- Checkout fix：只對三份Skill與vendored LICENSE設定`text eol=lf`，不改全域Markdown或repository EOL policy。
- Fresh evidence：三份vendored Skill與LICENSE逐byte匹配Git blobs；`git check-attr`四條均回報`text: set, eol: lf`。

## Lock Contract

Root`skills-lock.json`對每份Skill記錄：

- `ownership: third-party-unmodified`。
- `status: Pilot`。
- Exact source repository、40-character immutable commit與upstream path。
- MIT identity、source path、repository-local license path與license blob SHA。
- Exact repository-local install path。
- Exact single-file inventory與canonical LF blob SHA。

`inspect_skill_lock()`fresh result：

```txt
issues=0
exemptions=3
```

Exemptions全部解析至：

```txt
C:\Users\crazy\.devspace\worktrees\flutter_architecture-a6770dc8\.agents\skills\...
```

## Adoption Disposition

### `brandkit`

- Status：`Pilot／Loaded, non-triggered for accepted .pen proof`。
- Trigger：明確需要新brand identity／brand-kit image。
- Current Task：不觸發；既有`.pen`已accepted。
- Forbidden：不得重設`.pen`、操作Pencil、產生Flutter code或擁有approval／release。
- Permissions：無自動network、credential、MCP或repository mutation。
- Rollback：移除Skill directory、lock row與registry row。

### `high-end-visual-design`

- Status：`Pilot／Approved with restrictions`。
- Trigger：中央workflow在accepted authority下要求high-end visual critique。
- Allowed：Hierarchy、spacing、texture、surface與anti-generic critique。
- Forbidden：Web／React／Tailwind execution protocol、font／Material icon bans與motion absolutes不得覆蓋Flutter、`.pen`、Accessibility、Localization或Design System。
- Permissions：無自動tool permission；只作review companion。
- Rollback：移除Skill directory、lock row與registry row；visual authority不受影響。

### `imagegen-frontend-mobile`

- Status：`Pilot／Loaded, non-triggered for accepted .pen proof`。
- Trigger：缺少visual authority且明確要求mobile screen image generation。
- Current Task：不觸發；它明示image-only且不得code generation。
- Forbidden：不得image-to-code、操作Pencil、建立Flutter architecture或取代accepted `.pen`。
- Permissions：無自動image tool、network、credential或repository mutation。
- Rollback：移除Skill directory、lock row與registry row。

## Machine Validation

Fresh commands：

```txt
python -m unittest tools.docs.test_skill_lock tools.docs.test_check_docs
→ 35 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed

git check-attr text eol -- <four vendored paths>
→ all text=set, eol=lf
```

## Whole-Task Review

- 三份Skill與LICENSE保持upstream原文，沒有translation、wrapper或repository-authored additions。
- Root lock與registry責任分離：lock只擁有source／integrity；registry擁有trigger／restriction／rollback。
- External`D:\Developer\ui-agent\.agents\skills`未成為active runtime source。
- 未copy visual source、未操作Pencil、未修改Flutter source。
- Temporary upstream checkout只作read-only provenance evidence，Task完成後清理。

## Disposition

```txt
Source admission: PASSED
Immutable commit: VERIFIED
Vendored bytes: VERIFIED
License bytes: VERIFIED
Lock validation: PASSED
Plan execution correction: ACCEPTED as factual EOL/hash clarification
Open P0: 0
Open P1 without disposition: 0
Task 33-3 source gate: PASSED
```
