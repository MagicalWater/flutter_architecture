---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-33-task-33-4-visual-authority-review
last_reviewed_baseline: 1.14.0
---

# Milestone 33 — Task 33-4 Visual Authority Review

## Scope

本review涵蓋：

- Repository-local design source hierarchy。
- Visual authority manifest schema、path confinement、raw hashes與source ranking。
- External admission files到managed worktree的byte identity。
- Canonical viewport與existing preview／benchmark dimension disposition。
- Repository`docs_check` integration。

本Task不解析或修改`.pen`結構、不操作Pencil canvas、不建立Flutter implementation。Canonical Pencil renderer export仍由Task 33-6擁有。

## TDD Evidence

### RED

新增`tools/visual/test_verify_visual_authority.py`後首次執行：

```txt
python -m unittest tools.visual.test_verify_visual_authority
→ ModuleNotFoundError: No module named 'tools.visual.verify_visual_authority'
```

RED由production verifier不存在造成，不是fixture／syntax error。

Required matrix：

1. Valid manifest。
2. Missing primary authority。
3. Authority hash drift。
4. Repository path escape。
5. Missing derived file。
6. Duplicate role。
7. Invalid canonical viewport。
8. Historical benchmark incorrectly marked primary。

### GREEN

新增：

- `VisualAuthorityIssue`。
- `verify_visual_authority(root, manifest)`。
- Frontmatter與fixed Markdown table parser。
- Repository path confinement。
- Raw SHA-256 validation。
- Required／unique roles與role-to-status contract。
- Primary file／hash cross-check。
- Positive finite canonical viewport contract。
- `check_docs.py` manifest discovery integration。

Initial GREEN：

```txt
python -m unittest tools.visual.test_verify_visual_authority
→ 8 tests passed
```

Repository integration regression test確認`check_repository()`會掃描nested`docs/visual_authority/**/manifest.md`並回傳visual hash drift issue。

## Artifact Admission

### Source and destination matrix

| Role | External input | Repository destination | SHA-256 | Bytes | Dimensions |
|---|---|---|---|---:|---|
| Primary source | `D:\Developer\ui-agent\test-reconstruction.pen` | `docs/design_sources/pencil-compatibility-write-precheck/source.pen` | `bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc` | 55,147 | `.pen` opaque source |
| Derived admission preview | `D:\Developer\ui-agent\test-reconstruction-preview.png` | `.../pencil-preview.png` | `6d1a6553a1b066d0d07ce565aee7f895cddcdc0344e9f9797bab4ca1cfac5be5` | 64,729 | 226 × 400 |
| Supplementary original reference | `D:\Developer\ui-agent\test.png` | `.../original-reference.png` | `c7469bcdd8842ad7a0e2f57715756615e07990d0fec33d6016105c5e45e398fc` | 1,758,269 | 941 × 1672 |
| Historical Flutter benchmark | `D:\Developer\ui-agent\flutter_preview\flutter-preview.png` | `.../historical-flutter-benchmark.png` | `69edbc35da44288e80b448231de50f9a51d95ba84c9042ea16797267b607731d` | 32,841 | 226 × 400 |

Binary／design artifacts使用byte-preserving`copy /b`匯入，因line-based`apply_patch`不能安全表達PNG bytes；所有source、tests、manifest、review與routing文字仍使用repository`apply_patch`。Copy前後分別hash，四項全部exact equality；沒有以OCR、轉碼、重新編碼或resize處理。

Destination hashes通過後，external absolute paths不再是active authority。

## Focused Findings

### F-33-4-01 — Canonical viewport與admitted preview dimensions不一致

- Severity：P1。
- Status：Resolved with staged gate。
- Finding：Accepted Design／Plan固定canonical comparison為`941 × 1672`、DPR1，但existing Pencil preview與historical Flutter benchmark實際都是`226 × 400`。Task 33-10又禁止resize，若直接把Task 33-4 preview當pixel master會必然dimension mismatch。
- Authority resolution：Design的canonical viewport保持不變；`.pen`仍是primary。Existing Pencil preview只作derived admission evidence，不提升為canonical master。
- Plan correction：Task 33-6新增Pencil MCP fresh export gate，必須直接從accepted root frame輸出`941 × 1672`、DPR1 preview、替換檔案並更新manifest hash；不得upscale thumbnail。未完成即阻擋Flutter implementation。
- Manifest evidence：明確記錄current preview尺寸、blocked comparison readiness與required Task 33-6 action。

### F-33-4-02 — 不同roles可共享同一physical file

- Severity：P1。
- Status：Resolved。
- Finding：Initial verifier限制duplicate role，但未限制不同roles指向同一路徑。Benchmark可暗中重用primary source且在hash一致時通過，破壞source ranking。
- RED control：`test_different_roles_cannot_share_the_same_file`把historical benchmark指向`source.pen`並使用相符hash；修正前verifier回傳零issues，test正確FAIL。
- Fix：Verifier以resolved path建立`path_roles`，任何第二role重用同一file回報`visual-authority-duplicate-file`。
- Fresh GREEN：targeted test通過；combined visual／docs tests共32項通過。

### F-33-4-03 — `.pen`未宣告Git binary，Windows clean checkout可能改變authority bytes

- Severity：P1。
- Status：Resolved。
- Finding：Task commit時Git警告`source.pen`的LF將在下次touch轉為CRLF。Current working tree與commit blob雖都維持accepted SHA，但repository`core.autocrlf=true`且path沒有attribute，clean checkout可能改變opaque `.pen`bytes並使manifest drift。
- Root cause：Task 33-3只固定third-party text files的LF；Task 33-4沒有為新design-source extension建立Git byte-preservation contract。
- Fix：`.gitattributes`新增`docs/design_sources/**/*.pen binary`，使Git對`.pen`套用`-text -diff -merge`並禁止EOL normalization。
- Fresh evidence：`git check-attr`回報`binary: set, text: unset, diff: unset, merge: unset`；以`core.autocrlf=true`建立fresh checkout後，`source.pen`SHA-256仍為accepted`bd892671...`且manifest verifier零issues。

## Manifest Review

### Primary authority

```txt
Role: primary-source
Path: ../../design_sources/pencil-compatibility-write-precheck/source.pen
SHA-256: bd8926711ea28e7f9ae5a83128ed8fbc8d506cb5342c76eb35360c4c13544fdc
Status: primary
```

`.pen`只作opaque file hashing；本Task沒有native parse或direct mutation。

### Source ranking

1. `.pen` primary structural／visual authority。
2. Pencil preview derived evidence；目前是admission thumbnail。
3. Original PNG supplementary only。
4. Previous Flutter screenshot historical benchmark only。

No duplicate role、duplicate resolved file、path escape、missing file、hash drift或benchmark-primary promotion。

### Canonical viewport

```txt
941 × 1672
DPR 1.0
```

這是後續golden／runtime／diff contract，不表示App只能支援該尺寸。Task 33-6完成fresh Pencil export前，canonical pixel comparison維持blocked。

## Whole-Task Review

### Boundary

- 只建立visual verifier、tests、source／authority docs、四個admitted artifacts與review evidence。
- 沒有安裝額外Skill、沒有操作Pencil、沒有修改Flutter source。
- External paths已降級為historical admission inputs。

### Documentation ownership

- `docs/design_sources/`擁有repository-local source files與direct derived files。
- `docs/visual_authority/`擁有ranking、hash、viewport與supersession。
- ADR-028擁有stable workflow boundary。
- Accepted Plan擁有Task sequencing與Task 33-6 canonical export gate。
- Audits只保存admission／review evidence。

### Verifier behavior

- Manifest與all artifact paths必須位於repository root。
- Table header固定為`Role | Path | SHA-256 | Authority status`。
- Required roles各自唯一且physical file不能重複。
- Primary frontmatter path／hash必須與primary table row一致。
- Width、height、DPR必須為positive finite values。
- Repository`docs_check`自動掃描所有nested manifests。

## Validation

Fresh final commands：

```txt
python -m unittest tools.visual.test_verify_visual_authority tools.docs.test_check_docs
dart run melos run docs_check
git diff --check
python direct verifier against repository manifest
source/destination raw SHA-256 comparison
PNG IHDR dimension inspection
```

Fresh結果：

```txt
python -m unittest tools.visual.test_verify_visual_authority tools.docs.test_check_docs
→ 32 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ passed

verify_visual_authority(repository manifest)
→ visual_authority_issues=0

Source／destination raw SHA-256
→ 4／4 exact matches

PNG IHDR dimensions
→ Pencil admission preview 226 × 400
→ Original reference 941 × 1672
→ Historical Flutter benchmark 226 × 400
```

## Disposition

```txt
TDD RED: VERIFIED
Initial GREEN: PASSED
Focused review: PASSED after F-33-4-01, F-33-4-02 and F-33-4-03 disposition
Fresh focused re-review: PASSED
Whole-Task review: PASSED
Visual source ranking: ACCEPTED
Canonical Pencil comparison readiness: BLOCKED until Task 33-6 by design
Open P0: 0
Open P1 without disposition: 0
Task 33-4: ACCEPTED
Next Task: 33-5 Repository Pencil-to-Flutter Orchestration Skill
```
