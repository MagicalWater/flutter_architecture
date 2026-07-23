---
document_type: final-review
status: accepted
authoritative_for:
  - change-aware-ci-holistic-final-review
last_reviewed_baseline: 1.8.0
---

# Change-aware CI Holistic Final Review

## Review Scope

本review不是各Task review的摘要，而是重新從整體角度交叉審查：

- Design spec與formal spec review。
- Implementation plan與formal plan review。
- `tools/ci/change_classifier.py`與完整classifier tests。
- `.github/workflows/ci.yml`、`android.yml`、`ios.yml`。
- Required-check naming、job skip／same-job no-op與failure propagation。
- Android／iOS artifact、runner、retention與secret boundary。
- ADR-023、CI operations guide與current project context。
- Local full regression、documentation-only remote acceptance與manual full-matrix evidence。
- Repository tracked-path classification audit。

Review範圍以release baseline `1.8.0`、implementation commits `4c8a939`至`dd6ee2d`及目前working tree follow-up fixes為準。

## Review Method

1. 逐項比對spec goals、non-goals與acceptance criteria。
2. 逐Task比對plan outputs、phase reviews與actual source。
3. 對repository所有tracked paths執行classifier classification audit。
4. 檢查PR、push、manual、invalid range、unknown path與classifier failure語意。
5. 檢查stable required jobs是否永遠建立，以及docs-only是否只在同job no-op。
6. 檢查Android summary與iOS dynamic runner是否fail-closed。
7. 重新執行Python contracts、workflow YAML parser、docs checker、shell syntax與whitespace gate。
8. 對照GitHub-hosted run IDs、job labels與artifacts。

## Findings

| ID | Severity | Finding | Disposition |
|---|---|---|---|
| CA-CI-FR-R01 | P1 | App-level `apps/flutter_architecture/pubspec.yaml`被分類為`full_ci=true`，但Android／iOS build均為false；plugin、asset或build dependency變更可能未建立代表產物 | 退回Task 1；新增failing regression test，將App pubspec列為shared App build input，兩平台build均為true |
| CA-CI-FR-R02 | P1 | `apps/flutter_architecture/assets/**`被分類為full CI但不建兩平台artifact；bundled resource變更可能未被代表build驗證 | 退回Task 1；新增failing regression test，將App assets列為shared App build input |
| CA-CI-FR-R03 | P1 | `apps/flutter_architecture/l10n.yaml`可改變generated localization與runtime資源，但只跑full CI、不做兩平台build | 退回Task 1；新增regression test，將App localization config列為shared App build input |
| CA-CI-FR-R04 | P2 | Task 6原plan的Python discovery從`tools/`開始只發現0 tests | 已在Task 6 evidence改用`tools/ci` discovery並實際執行contracts；final review沿用有效命令 |
| CA-CI-FR-R05 | P2 | Existing remote evidence驗證的是修正前classifier SHA；不能直接證明新增shared App build inputs已在GitHub-hosted workflow生效 | 保留為open revalidation requirement；修正commit推送後需確認CI、Android與iOS完整矩陣均成功 |

## Repository Path Audit

Holistic review對所有tracked paths逐一分類，並特別檢查`apps/flutter_architecture/**`中`full_ci=true`但兩平台build均false的項目。

修正後保留為不觸發native build的App paths主要為：

- Unit／widget tests。
- Integration test source。
- Flutter `.metadata`。
- Web-only SQLite assets。

這些路徑只執行full CI屬可接受。App runtime source、configuration、assets、pubspec與localization config則會觸發Android與iOS代表build。

## Re-review Evidence

修正後本地結果：

```txt
Python CI contracts: 57 passed
Workflow YAML parse: passed
Documentation check: passed
Shell syntax checks: passed
git diff --check: passed
```

Focused classification：

```txt
apps/flutter_architecture/pubspec.yaml → full CI + Android + iOS
apps/flutter_architecture/assets/** → full CI + Android + iOS
apps/flutter_architecture/l10n.yaml → full CI + Android + iOS
apps/flutter_architecture/test/** → full CI only
apps/flutter_architecture/web/** → full CI only
docs/** → documentation-only
```

既有remote evidence仍證明：

- Docs-only stable CI jobs成功且重量steps no-op。
- Android artifact jobs skipped、summary成功。
- iOS Simulator在Ubuntu同名no-op成功且未啟動macOS。
- Manual dispatch與source／workflow push可執行完整CI及兩平台代表build。
- Artifact SHA naming、digests、retention、minimal permissions與secret boundary有效。

## Cross-cutting Review

### Required checks

- `CI / Quality`、`CI / Generated Consistency`、`CI / Tests`名稱未漂移。
- `iOS / Simulator Build`沒有job-level skip，docs-only使用Ubuntu同job no-op。
- Android非required artifact jobs可合理skipped，`Android / Summary`fail-closed。

### Failure safety

- Unknown path、empty／invalid range與classifier execution failure均回退完整矩陣。
- Manual dispatch與`VERSION`強制完整矩陣。
- Requested Android build任一失敗會令summary失敗。
- iOS requested build failure直接反映在原job，不使用替代summary掩蓋。

### Security and artifacts

- Workflow只使用`contents: read`。
- 沒有`pull_request_target`或repository signing／Store secrets。
- External Actions維持immutable full SHA pin。
- Verification artifacts仍使用full commit SHA與bounded retention。

### Documentation authority

- ADR-023保存durable policy。
- CI operations guide保存trigger matrix與操作方式。
- Project context只保存current摘要。
- Audit evidence不取代current architecture authority。

## Final Gate

```txt
Open P0: 0
Open P1 code findings: 0
Open P1 evidence requirement: 0
Local re-review: Passed
Remote revalidation after classifier fix: Passed
Holistic final review status: Accepted
Initiative formal closure: Completed
```

## Targeted Re-review Evidence

Classifier修正commit：

```txt
84d6e7cf625b10a02dbc27f14c79ad2ecfe4d9c0
```

GitHub-hosted push runs：

```txt
CI:      29986372624 — success
Android: 29986372639 — success
iOS:     29986372623 — success
```

Re-review確認：

- CI的Classify Changes、Quality、Generated Consistency與Tests均在`ubuntu-24.04`成功。
- Android Development Debug APK、Release APK與Summary均在`ubuntu-24.04`成功。
- iOS Simulator Build與Production Release Build均在`macos-15`成功。
- Android建立兩個full-SHA artifacts；iOS建立兩個build artifacts與兩個toolchain artifacts。
- Artifact retention維持14天，名稱、SHA與digest完整。
- 修正沒有改變required-check名稱、failure propagation、permissions、Action pin或secret boundary。
- 沒有新增P0／P1 finding。

因此三個classifier漏判finding已完成code fix、local regression與remote revalidation closure。
