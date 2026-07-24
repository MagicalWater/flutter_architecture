---
document_type: final-review
status: accepted
authoritative_for:
  - milestone-29-final-review
last_reviewed_baseline: 1.11.0
---

# Milestone 29 — Drift Persistence Migration Final Review

## Review Scope

本次針對Milestone 29全部Design、Plan與Task 29-1～29-9執行跨Task holistic review，
涵蓋single database authority、historical fixtures、schema equivalence、migration rollback、
AuthUser／Catalog invariants、native／Web opener、generated governance與platform evidence。

## Cross-task Review

### Authority

- `AppDatabase`是唯一production schema、migration、connection與lifecycle authority。
- Production `lib/`沒有sqflite import或legacy schema owner。
- sqflite與`sqflite_common_ffi`只存在dev dependency與`test/support` historical harness。
- AuthUser與Catalog共用同一個Composition Root-owned `AppDatabase` singleton。

### Historical Compatibility

- v1～v6 SQLite fixtures具checked-in binary、schema report與sentinel data。
- 每個fixture均可由Drift升級至canonical v6，且schema、index、foreign key與資料清理等價。
- migration failure不留下partial schema或推進錯誤`user_version`。
- rollback compatibility證明Drift migration沒有破壞SQLite file contract。

### Feature Invariants

- AuthUser固定single-active slot，write replace、clear idempotence與operational exception mapping保留。
- Catalog first-page replacement、append predecessor、chain revision、cycle、duplicate position、orphan／malformed cleanup與logout persistence全部保留。
- Feature與Repository只依賴DAO／data source contract，不感知platform opener或connection implementation。

### Platform and Generated Governance

- Android／iOS沿用精確`flutter_architecture.db`檔名與既有database directory。
- macOS production opener使用background executor並通過runtime smoke。
- Web使用matching Wasm／worker assets，舊experimental storage採`explicit reset`，不宣稱automatic preservation。
- v1～v6/current Drift schema snapshots、worker與generated source受clean-tree CI gate保護。
- Database-critical source、schema、asset與tooling變更觸發full CI與Android／iOS builds。

## Holistic Findings and Disposition

### Finding 1 — Current authority仍保留pre-migration wording

Roadmap、Project Context、root README與AGENTS仍存在Task 29-1 pending、sqflite production
與舊Web setup文字。

**Disposition:** 全面回寫current authority至Baseline 1.11.0，active milestone改為None，
current persistence改為Drift，Web操作命令改為worker generation。

### Finding 2 — Flutter 3.44 iOS auto-SPM與current CocoaPods contract衝突

**Disposition:** App pubspec明確關閉SPM，CI contract固定CocoaPods-compatible sequencing，
iOS Simulator artifact重新build通過。

### Finding 3 — Web與desktop capability可能被誤讀為Supported

**Disposition:** Roadmap與Project Context維持Android／iOS Supported，其餘平台Dependency-ready；
Web runtime、Windows／Linux host build未被記錄為pass。

## Re-review

- Architecture方向與Option D single-owner cutover一致。
- 所有Task review均含focused review、findings、修正、re-review、whole-task review、
  documentation authority、validation與P0/P1 gate；29-6／29-7補充證據已commit。
- Current docs不再把sqflite或舊Web initializer描述為production authority。
- Release baseline採MINOR `1.11.0`，符合模板新增／替換persistence能力的versioning policy。

## Final Validation Matrix

- Dependency resolution：passed。
- Build runner／Drift schema／worker clean generation：passed。
- Documentation check：passed。
- Workspace analyze：passed。
- Full Flutter regression：passed；App 467 tests。
- App bundle：passed。
- Android production verification APK：passed。
- iOS Development Simulator unsigned app與dSYM：passed。
- macOS production opener smoke：passed。
- no-sqflite production authority guard：passed。

## Release Gate

- Open P0：0。
- Open P1 without disposition：0。
- Version：1.11.0。
- Release disposition：accepted。
- Push與post-release validation：於release commit後執行並記錄於
  `29-10_post_release_validation.md`。
