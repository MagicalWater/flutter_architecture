# Milestone 25-8 — GitHub-hosted iOS Build Gate Review

## 結論

Task 25-8已建立獨立`iOS / Simulator Build`workflow contract。Open P0／P1為0；remote GitHub-hosted execution必須在commit推送後取得，未推送前不得宣稱remote runner已通過。

## Workflow Contract

- Workflow：`.github/workflows/ios.yml`
- Workflow name：`iOS`
- Job check name：`Simulator Build`
- Required-check完整名稱：`iOS / Simulator Build`
- Events：Pull Request到`main`、push到`main`、manual dispatch
- Runner：`macos-15`
- Permission：`contents: read`
- Concurrency：同一PR／ref只保留最新run
- Flutter：由`.github/versions.env`取得exact `3.41.6`
- External Actions：全部full-SHA pinned
- Build authority：`bash tools/ci/build_ios_simulator.sh`

## Security and Artifact Boundary

- Checkout停用credential persistence。
- 不使用`pull_request_target`。
- 不讀取repository或environment secrets。
- 不配置Apple Team、certificate或provisioning profile。
- 不上傳`.app`或archive作為distribution artifact。
- 只在失敗時上傳`toolchain.txt`與`build.log`，retention為7天。

## TDD Evidence

先新增`tools/ci/test_ios_workflow_contract.py`，初次執行因`.github/workflows/ios.yml`不存在而失敗。建立workflow後，contract test驗證stable naming、runner、exact toolchain、minimal permission、safe concurrency、full-SHA actions與bounded diagnostics。

## Review Findings

| Finding | Severity | Disposition |
|---|---|---|
| Repository沒有GitHub-hosted iOS gate | P1 | 新增獨立workflow與穩定check名稱 |
| iOS build不得依賴personal signing state | P1 | 只呼叫unsigned Simulator build script，沒有secret或Team設定 |
| Build failure需要可診斷但不得產生distribution artifact | P1 | 僅failure diagnostics，7天retention，不上傳`.app` |
| Workflow contract test若只存在本機，未來drift不會被CI阻擋 | P1 | 接入`CI / Quality`與iOS job本身 |
| Remote run在commit未push前無法建立 | Operational gate | 本Task commit後仍維持未push；remote runner／Xcode evidence必須在後續明確push後補記，不宣稱已通過 |

## Validation

- `python3 -m unittest tools.ci.test_ios_workflow_contract`：5 tests passed。
- Ruby YAML syntax/static inspection：`ios.yml`與`ci.yml`parsed。
- `bash tools/ci/build_ios_simulator.sh`：passed，產出unsigned Simulator app並通過identity／deployment target／plugin checks。
- `dart run melos run docs_check`：passed。
- `dart run melos run analyze`：passed。
- `dart run melos exec -- flutter test`：passed。
- `python3 -m unittest tools.docs.test_check_docs tools.ci.test_ios_workflow_contract`：19 tests passed。
- `git diff --check`：passed。

## Final Disposition

Workflow、security boundary、cache scope、diagnostics與required-check naming均已review。Remote GitHub-hosted result仍是明確的post-push operational evidence，不影響repository contract完成，但在取得真實run前不能將GitHub runner/Xcode版本標為verified。
