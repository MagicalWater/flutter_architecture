---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-34-task-34-2-asset-typography-mapping-review
last_reviewed_baseline: 1.15.1
---

# Milestone 34 — Task 34-2 Asset / Typography Mapping Review

## Scope

Task 34-2把34-1的7-failure RED收斂為單一Pencil-to-Flutter domain Skill內的representation classification與provenance gate。

Modified／created authority：

- `.agents/skills/implementing-pencil-flutter-design/SKILL.md`
- `.agents/skills/implementing-pencil-flutter-design/references/asset-and-typography-mapping.md`
- `.agents/skills/implementing-pencil-flutter-design/references/flutter-mapping.md`

沒有修改human Guide、ADR-028、`.pen`或Flutter production source。

## Focused Review

### Workflow ordering

Current route現在明確為：

```txt
Pencil MCP extraction
→ representation classification + provenance resolution
→ resolved Flutter owner mapping
→ TDD / visual acceptance
```

Flutter mapping不再自行補font fallback、icon equivalence、vector/raster或static/dynamic decision。

Result：PASS。

### Representation classes

Reference明確定義六類：Layout primitive、Typography、Approved package icon、Vector asset、Raster asset、Dynamic drawing。

Result：PASS。

### Fail-closed boundaries

- Missing font family／weight → `Typography authority unresolved`。
- Visual不等價的package替代 → `approximate icon`，不能只靠語意相同接受。
- Byte-changing raster／vector處理 → 必須記錄`derived transformation`與`content hash`。
- Unresolved representation／provenance → production UI blocked。

Result：PASS。

### Anti-overbuild

- `raster-everything shortcut`明文禁止。
- `static CustomPainter overbuild`明文禁止。
- Dynamic drawing只由runtime value/state-driven geometry正當化。
- Candidate-driven pixel chasing不能反推representation。

Result：PASS。

## Findings and Disposition

### F-34-2-01 — Provenance不應膨脹成global registry

- Severity：P2。
- Finding：若把每個asset都集中到新全域manifest，會超出confirmed gap並建立新的長期authority。
- Resolution：reference只要求Task mapping evidence + existing visual manifest + Git history；明文不建立global asset registry。
- Fresh re-review：PASS。

### F-34-2-02 — Guide不能提前變成decision owner

- Severity：P2。
- Finding：Task 34-2若同步human Guide完整matrix，會混入34-4 scope並製造平行authority。
- Resolution：34-2只修改domain Skill/reference；Guide延後34-4只作摘要routing。
- Fresh re-review：PASS。

## Whole-Task Review

此Task仍維持一個`implementing-pencil-flutter-design` domain Skill，沒有新增第二Skill、第二renderer或新的Flutter architecture owner。Representation classification只是Flutter mapping的前置gate，不會取代accepted `.pen`、Design System、Feature First或visual validation。

Open P0：0。

Open P1 without disposition：0。

## Validation

Completion需fresh執行：

```powershell
python tools/docs/test_pencil_representation_mapping_policy.py
python tools/docs/test_pencil_single_renderer_policy.py
dart run melos run docs_check
git diff --check
```

Expected：34-1的7個representation RED全部轉GREEN；既有single-renderer與docs contract持續GREEN。

