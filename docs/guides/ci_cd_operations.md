---
document_type: guide
status: active
authoritative_for:
  - repository-ci-cd-operations
last_reviewed_baseline: 1.18.0
---

# CI/CD Operations Guide

## Scope

本指南說明 repository CI quality gates、managed local artifact store、Android／iOS verification evidence、Branch Protection 建議、常見失敗處理、cleanup與rollback流程。

Durable architecture contract 由 `docs/adr/adr-023-repository-ci-quality-gates-android-verification-artifact.md` 保存；本指南不取代 ADR，也不宣稱 GitHub repository settings 已被修改。

## Minimum Sufficient Validation routing

Repository的change-aware validation由單一machine authority `tools/ci/validation_planner.py`決定；`.github/workflows/ci.yml`、Android／iOS workflows與local operator不得維護平行path matrix。

本機查看任一Git range的plan：

```bash
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

Windows Git Bash也可使用：

```powershell
& 'C:\Program Files\Git\bin\bash.exe' tools/ci/run_local_ci.sh plan-range <base-sha> <head-sha>
```

Plan採 **Minimum Sufficient Validation** levels：focused → affected → workspace → full → release。Ordinary feature／leaf package不自動要求雙平台build；native、database、dependency、validation-engine、release與fail-safe情境依plan升級。Unknown path、invalid range、dependency graph或planner failure一律fail-safe full matrix。

## Workflow Inventory

### Execution Mode Switch

Repository以GitHub Actions variable `CI_EXECUTION_MODE`控制驗證執行端：

```txt
manual-local  → GitHub execution jobs全部skip，由人員執行本機入口
self-hosted   → explicit manual dispatch派送到Mac runner
github-hosted → 使用GitHub提供的Ubuntu／macOS runner
```

額度不足或希望避免macOS runner成本時，使用：

```bash
gh variable set CI_EXECUTION_MODE --body manual-local
bash tools/ci/run_local_ci.sh quality
bash tools/ci/run_local_ci.sh android
bash tools/ci/run_local_ci.sh ios
bash tools/ci/run_local_ci.sh observability
```

恢復GitHub-hosted自動驗證：

```bash
gh variable set CI_EXECUTION_MODE --body github-hosted
```

四份workflow的manual dispatch都有`execution_mode` choice：`repository-default`沿用repository variable，另外三個選項只覆寫該次run。未知值、舊`local`／`github`或空值一律fail closed；不會自動fallback到付費runner。

### Product repository bootstrap live-state boundary

`CI_EXECUTION_MODE`是GitHub repository live variable，不會因`Use this template`而由template repository複製到新產品repository。新產品bootstrap的tracked desired/disposition authority是root `repository_infrastructure.json`；live GitHub state必須另外admit/configure並fresh read-back。

因此在Template → Product adoption中，必須區分：

```txt
tracked workflow / scripts / repository_infrastructure.json
vs
live GitHub repository variable / policy / protection / runner / Environment state
```

不得因workflow YAML存在、template repository目前可正常跑CI，或舊conversation記得某設定，就宣稱new product repository已configured。

三種selected profile都必須在final `repository_kind=product`前取得自己的acceptance evidence：

- `manual-local`：live variable/disposition明確，local planner＋代表性quality route可執行；GitHub jobs skipped不等於CI PASS。
- `self-hosted`：runner registration/labels/online state、checkout外`CI_ARTIFACT_ROOT`與trusted-main boundary有fresh evidence；offline時不得fallback。
- `github-hosted`：representative PR/main workflow確實建立預期GitHub-hosted jobs，verification不依賴production signing secrets。

任何GitHub live mutation都要保存before state並在mutation後fresh read-back。Permission failure、403、read-back mismatch只能記為blocked/deferred，不得記為configured。

Secrets只驗證**名稱是否存在**與capability disposition；不得讀取、複製或記錄secret value、runner registration token、signing material或provider credential。

Repository-owned live admission入口：

```bash
python tools/ci/repository_infrastructure.py \
  --repository <owner>/<product-repo> \
  snapshot \
  --environment staging-observability:FIREBASE_SERVICE_ACCOUNT_JSON,FIREBASE_ANDROID_PRODUCTION_CONFIG_B64
```

Snapshot只投影review需要的safe fields：repository visibility/default branch、`CI_EXECUTION_MODE`、Actions/default token policy、fork PR approval policy、Branch Protection關鍵安全欄位、repository-scoped runner name/status/labels，以及指定Environment的secret **names**／missing names；不保存GitHub numeric object IDs或secret values。

目前唯一提供的live mutation入口是`CI_EXECUTION_MODE`，且mutation後立即fresh read-back；不一致即fail closed：

```bash
python tools/ci/repository_infrastructure.py \
  --repository <owner>/<product-repo> \
  set-ci-execution-mode \
  --mode manual-local
```

本工具沒有runner deletion、Environment deletion、secret write/delete、credential rotation或signing material操作。Branch Protection等live mutation若未有專用authorized contract，仍不得以零散`gh api`命令繞過review/read-back boundary。

### Managed local artifact ownership and GitHub quota boundary

`manual-local`與`self-hosted`目前都使用repository-owned managed local artifact store。日常成功、失敗、Android／iOS verification與Observability raw evidence不再透過`actions/upload-artifact`進入GitHub Actions storage；四份workflow也不再使用`actions/cache`。

GitHub仍負責event、dispatch、check、logs與`$GITHUB_STEP_SUMMARY`。`github-hosted`只保留人工例外路線，manual dispatch必須明確選擇`artifact_transport`：

```txt
repository-default → none
none               → 不建立GitHub artifact
failure-only       → 只允許有界文字／log／JSON與指定golden PNG，7天、每job 25 MiB
full               → 人工明確選擇、1天retention，summary顯示storage warning
```

`failure-only`與`full`都會先執行secret leakage scanner；provider config、service account、signing material、APK、`.app`、dSYM與symbols不會因failure route被隱式上傳。

若需要暫停self-hosted execution而完全改由人員本機驗證，使用：

```bash
gh variable set CI_EXECUTION_MODE --body manual-local
```

Milestone 32已於2026-07-31依reviewed manifest `7ad138bb845e42cbb133d07c`完成歷史GitHub Actions storage cleanup：110個artifacts與3個caches均依exact object ID刪除，fresh inventory與逐IDre-query確認0個objects／0 bytes。這是一次性cutover evidence，不是未來批量刪除捷徑；任何新GitHub object仍必須重新fresh inventory、建立新manifest、完成review並取得獨立明確核准，不得沿用舊manifest、名稱、prefix、workflow或時間範圍刪除。

Self-hosted runner：

```txt
name: <operator>-mac-flutter-architecture
labels: self-hosted, macOS, ARM64, flutter-architecture, trusted-main
install root: /Users/<user>/actions-runner/flutter-architecture
```

Service操作必須從runner root執行：

```bash
cd /Users/<user>/actions-runner/flutter-architecture
./svc.sh status
./svc.sh stop
./svc.sh start
```

Runner離線時job保持queued，GitHub目前最多等待24小時後失敗；repository不自動改派GitHub-hosted。Self-hosted PR全部skipped，且`skipped`不代表PR已驗證。

## Managed Artifact Store Operations

### Artifact root configuration

正式變數：

```txt
CI_ARTIFACT_ROOT
```

Self-hosted必須明確設定checkout外的absolute root；缺值時fail closed，不會回退到runner `_work`、`RUNNER_TEMP`或repository。Mac operator目標範例：

```bash
export CI_ARTIFACT_ROOT=/Users/<user>/Developer/ci-artifacts/flutter_architecture
export CI_MANAGED_EXECUTION_MODE=self-hosted
```

此路徑只是operator configuration，不是source default。Windows manual-local可明確設定：

```powershell
$env:CI_ARTIFACT_ROOT = 'D:\Developer\ci-artifacts\flutter_architecture'
$env:CI_MANAGED_EXECUTION_MODE = 'manual-local'
```

若Windows manual-local未提供`CI_ARTIFACT_ROOT`，預設為：

```text
%LOCALAPPDATA%\flutter_architecture\ci-artifacts
```

POSIX manual-local未提供時，預設為：

```text
${XDG_STATE_HOME:-$HOME/.local/state}/flutter_architecture/ci-artifacts
```

Root不得位於repository／worktree、runner `_work`、runner temp、filesystem root或home root本身。不得用`rm -rf`、`Remove-Item -Recurse`、`shutil.rmtree`或父目錄推算直接清理store；所有retention與刪除操作只能使用`tools/ci/artifact_cleanup.py`的exact root與manifest流程。

### Local execution entrypoints

```bash
bash tools/ci/run_local_ci.sh quality
bash tools/ci/run_local_ci.sh android
bash tools/ci/run_local_ci.sh ios
bash tools/ci/run_local_ci.sh observability
bash tools/ci/run_local_ci.sh all
```

Windows可執行quality、Android與有界Android Observability；iOS需要macOS。每次入口都會建立唯一run key、finalize job manifest、SHA-256 checksums、run-level aggregation與retention dry evaluation。

Windows由Windows Git建立的repository／worktree必須從Git Bash執行，例如：

```powershell
& 'C:\Program Files\Git\bin\bash.exe' tools/ci/run_local_ci.sh quality
```

不得讓`C:\Windows\System32\bash.exe`的WSL bash直接執行Windows Git worktree；WSL無法正確解析`.git`內的Windows `D:/.../.git/worktrees/...`gitdir，會在artifact job建立前失敗。若repository本身位於WSL filesystem，則應使用完整WSL checkout，而不是跨用Windows worktree。

### Store layout and query

```txt
<root>/
  runs/<full-sha>/<run-key>/
    run-manifest.json
    run-summary.md
    jobs/<job-key>/
      manifest.json
      summary.md
      checksums.sha256
      artifacts/
      diagnostics/
  cleanup-manifests/
  trash/
  pins/
  locks/
```

PowerShell查詢最近的run與job manifest：

```powershell
$root = $env:CI_ARTIFACT_ROOT
Get-ChildItem -LiteralPath (Join-Path $root 'runs') -Filter run-manifest.json -Recurse |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 10 FullName, LastWriteTime

Get-ChildItem -LiteralPath (Join-Path $root 'runs') -Filter manifest.json -Recurse |
  Where-Object FullName -Match '[\\/]jobs[\\/]' |
  Sort-Object LastWriteTime -Descending |
  Select-Object -First 20 FullName, LastWriteTime
```

POSIX查詢：

```bash
find "$CI_ARTIFACT_ROOT/runs" -name run-manifest.json -print
find "$CI_ARTIFACT_ROOT/runs" -path '*/jobs/*/manifest.json' -print
```

Checksum驗證必須從job目錄執行：

```bash
cd "$CI_ARTIFACT_ROOT/runs/<sha>/<run-key>/jobs/<job-key>"
sha256sum --check checksums.sha256
```

Windows PowerShell若環境沒有`sha256sum`，逐行讀取`checksums.sha256`後使用`System.Security.Cryptography.SHA256`或Git Bash執行同一檔案；不得只核對檔名或manifest存在。

### Pin and unpin

Pin只接受已finalize的job relative path，必須有owner、reason與最長90天的UTC expiry：

```bash
python tools/ci/artifact_cleanup.py pin \
  --root "$CI_ARTIFACT_ROOT" \
  --job-path 'runs/<sha>/<run-key>/jobs/<job-key>' \
  --owner '<operator>' \
  --reason '<review-or-release-purpose>' \
  --expires-at '2026-08-30T00:00:00Z'

python tools/ci/artifact_cleanup.py unpin \
  --root "$CI_ARTIFACT_ROOT" \
  --job-path 'runs/<sha>/<run-key>/jobs/<job-key>'
```

Pin不代表容量豁免。若pin或尚未過期的evidence使30 GiB store upper bound或15 GiB minimum-free policy無法滿足，新run會在build前fail closed並回報blocking bytes。

### Cleanup dry-run, apply, restore, and purge

第一步永遠是dry evaluation；它只建立immutable cleanup manifest，不移除檔案：

```bash
python tools/ci/artifact_cleanup.py evaluate \
  --root "$CI_ARTIFACT_ROOT" \
  --dry-run
```

Review輸出的`manifest_id`以及：

```txt
<root>/cleanup-manifests/<manifest-id>.json
```

確認exact relative paths、bytes、retention reason、store generation與manifest SHA-256後，才可apply：

```bash
python tools/ci/artifact_cleanup.py apply \
  --root "$CI_ARTIFACT_ROOT" \
  --manifest-id '<manifest-id>'
```

Apply只會atomic move到`trash/<cleanup-id>`。24小時內可復原：

```bash
python tools/ci/artifact_cleanup.py restore \
  --root "$CI_ARTIFACT_ROOT" \
  --cleanup-id '<cleanup-id>'
```

滿24小時後才允許不可逆purge：

```bash
python tools/ci/artifact_cleanup.py purge \
  --root "$CI_ARTIFACT_ROOT" \
  --cleanup-id '<cleanup-id>'
```

Root mismatch、path traversal、symlink escape、active job lock、cleanup lock、store generation drift、destination collision或24小時未滿都會fail closed。任何失敗都不得改用直接filesystem delete繞過。

### Runner offline and operational fallback

Self-hosted runner離線時：

1. 不修改workflow讓它自動fallback到GitHub-hosted。
2. 需要立即驗證時，在可信Windows／Mac checkout設定`CI_MANAGED_EXECUTION_MODE=manual-local`並執行相同`run_local_ci.sh`入口。
3. Manual-local manifest只代表本機驗證，不冒充GitHub check。
4. Runner恢復後，再依原commit或新commit觸發self-hosted run。

### Repository CI

```txt
.github/workflows/ci.yml
```

Events：

- `workflow_dispatch`。

`main`是publication branch。正式publication前必須在candidate SHA以explicit `release` mode完成fresh planner-selected evidence；release dispatch以明確`release_base`＋exact candidate SHA規劃changed range，不再把release intent無條件翻成logical full／generated／Android／iOS。只有changed risk要求的平台才建立primary evidence；同一SHA push到`main`後只做published identity／workflow observation，不再自動建立第二輪相同CI。

Exact candidate已push到同名remote branch後，建議使用repository-owned fan-out入口一次派送所有planner-selected families：

```bash
python tools/ci/run_release_validation.py \
  --base <release-base-sha> \
  --head <exact-candidate-sha> \
  --execution-mode github-hosted
```

此CLI會先驗證local／remote candidate SHA，再由canonical planner選擇CI／Android／iOS families；所有selected workflows先完成dispatch才開始等待，因此wall-clock由最慢selected branch主導，而不是把各family串行相加。CLI只完成release validation admission，不修改`VERSION`、不merge、不push`main`、不publication。

Generated consistency屬repository-level evidence family，由`CI / Generated Consistency`唯一擁有。Android／iOS workflow只負責platform build evidence，不自行重跑`tools/ci/verify_generated.sh`。需要「generated + Android」或「generated + iOS」的完整validation intent時，由canonical planner與上層orchestrator同時選擇CI與對應platform family；platform workflow本身不判斷其他workflow是否存在，也不維護第二份generated authority。

Stable checks：

```txt
CI / Quality
CI / Generated Consistency
CI / Tests
iOS / Simulator Build
```

Environment representative checks另外包含：

```txt
Android / Development Debug APK
Android / Release APK
iOS / Production Release Build
```

`iOS / Simulator Build`維持Development Debug Simulator，避免既有Branch Protection名稱漂移。Flutter不支援iOS Simulator的Release/Profile AOT，因此Production代表建置使用`Release-production`、generic `iphoneos`與`CODE_SIGNING_ALLOWED=NO`，不是Simulator build。

## Change Classification and Trigger Matrix

三份workflow都先在Ubuntu執行repository-owned classifier。分類失敗、Git range無效或遇到未知路徑時，必須回退完整矩陣，不得以失敗分類作為略過驗證的理由。

| 變更類型 | Logical validation | Android | iOS | 備註 |
|---|---:|---:|---:|---|
| 純Markdown／managed docs | focused | 否 | 否 | docs governance only |
| Ordinary App Feature | focused affected owners | 否 | 否 | 0-test Feature合法，不退化成App full suite |
| Shared package | package owner tests + dependent analyze | 否 | 否 | reverse dependent只analyze |
| Database source | focused + generated | 否 | 否 | migration owners依changed risk選擇 |
| Android native／Android build script | focused | 依build-kind | 否 | development／production specific只選對應variant；shared native選both |
| iOS native／iOS build script | focused | 否 | 依build-kind | simulator／production specific只選對應variant；shared native選both |
| Unknown／invalid classifier input | logical full | 否 | 否 | fail-safe不等於自動燒兩平台 |
| `VERSION` | focused metadata | 否 | 否 | 不再隱式等於release |
| explicit `full` | logical full | 否 | 否 | 不含platform |
| explicit `android`／`ios` | focused | 指定平台 | 指定平台 | manual platform intent |
| explicit `release` | 依candidate changed range | 依risk＋build-kind | 依risk＋build-kind | publication前fresh planner-selected release gate；需`release_base` |

核心CI／Android／iOS workflow全部是explicit dispatch-only，不再因Pull Request自動建立run。Documentation-only、focused、platform與release evidence均由planner／orchestrator依intent建立；Android／iOS Summary仍驗證skip或build結果是否符合classifier決策。

### Android Verification Artifact

```txt
.github/workflows/android.yml
```

Events：

- `workflow_dispatch`。

Android verification是explicit platform/release evidence，不再因`main` publication push自動重跑。

Jobs：

```txt
Android / Development Debug APK
Android / Release APK
```

兩個job分別建立development Debug與production Release verification APK；production仍使用debug signing，不是production distribution pipeline。Planner輸出`android_development_build`／`android_production_build`分別控制兩個job；`android_build`只保留aggregate compatibility／summary用途。

Android Production build不再先執行`verify_generated.sh`。Tracked generated source的一致性由`CI / Generated Consistency`負責；Android job只做自身runner必要的dependency resolution與production APK build／artifact verification。這與iOS platform workflow責任一致。

## Recommended Branch Protection

`main`仍可要求Pull Request、approval、conversation resolution並阻擋force push／branch deletion；但核心CI／Android／iOS已是dispatch-only，**不得**把會要求每個PR自動出現的核心workflow checks設成無條件required checks，否則PR會永久等待不存在的run。

若團隊需要merge前machine evidence，先由repository-owned planner／orchestrator對candidate明確建立validation runs，再依實際GitHub Branch Protection能力決定是否把這種explicit evidence納入merge policy。不得為了required-check形狀重新恢復每次PR自動跑完整CI或平台build。

## Rerun Policy

### GitHub／network transient failure

先確認失敗不是source、generated file、test或build contract問題。只有下載、runner provisioning、GitHub service或外部registry暫時性錯誤，才直接rerun failed jobs或整個workflow。

同一commit重跑仍失敗時，不得以「可能是網路問題」忽略；應依一般failure流程處理。

### Manual verification

四份workflow都支援`workflow_dispatch`。Manual run可選`repository-default`、`manual-local`、`self-hosted`或`github-hosted`；核心CI／Android／iOS只重驗當下選定ref，不存在PR auto-run可被取代，也不改變歷史commit結果。

## Observability Acceptance

`.github/workflows/observability-acceptance.yml`提供獨立的Crashlytics acceptance route。

`github-hosted`模式下Pull Request可執行`PR-safe Contract`；`self-hosted`與`manual-local`模式下PR整份workflow為skipped，未信任程式碼不會進入Mac runner。

Observability symbols與受控事件不接受main push。只有manual dispatch選擇`self-hosted`或`github-hosted`，並明確設定`remote_acceptance=true`時才可使用GitHub Environment：

```txt
staging-observability
```

Environment需提供：

```txt
FIREBASE_SERVICE_ACCOUNT_JSON
FIREBASE_ANDROID_APP_ID
FIREBASE_ANDROID_PRODUCTION_CONFIG_B64
FIREBASE_ANDROID_STAGING_CONFIG_B64
FIREBASE_IOS_PRODUCTION_CONFIG_B64
FIREBASE_IOS_STAGING_CONFIG_B64
```

`*_CONFIG_B64`是原始provider config的base64內容。Android production／staging config分別對應`com.example.flutterarchitecture`與`com.example.flutterarchitecture.staging`；iOS亦須對應相同bundle identity。不得把原始JSON／plist提交到Git。

Secret-ready run會：

1. 建立production Android Flutter symbols與iOS dSYM並執行explicit upload。
2. 建立Android與iOS staging acceptance artifacts。只有manual dispatch明確設定`emit_controlled_event=true`，且`OBSERVABILITY_REMOTE_COLLECTION_ENABLED=true`與`OBSERVABILITY_ACCEPTANCE_EVENT_ENABLED=true`同時存在時，App才會送出一次controlled handled non-fatal。
3. 將App、dSYM、Flutter symbols、mapping、redacted evidence與checksums保存到managed local store；原始provider config與service account永遠不進store。
4. GitHub只保存redacted summary／有界safe evidence；raw Observability artifact不透過GitHub transport。

Workflow不會自動把「symbol upload command成功」解讀成「remote event已symbolicated」。在Firebase Console核對Android與iOS stack前，`remote_event_status`與`symbolication_status`必須維持`not-executed`或pending，不得改成verified。

Android與iOS secret-backed jobs最後均以`if: always()`執行`tools/ci/cleanup_ci_secrets.sh`，清理workspace與`RUNNER_TEMP`中的materialized service account及provider config。Self-hosted模式不使用GitHub Flutter／Pub cache transport，避免持久Mac反覆上傳大型cache。

## Cache Degradation

Flutter SDK、Pub與Gradle cache只用來降低時間，不是正確性前提。

Cache miss、eviction或restore failure時：

1. Workflow仍應執行dependency resolution與正式build／test command。
2. Fresh resolution成功即屬non-blocking degradation。
3. 若沒有cache便失敗，視為reproducibility defect，不得新增workspace build cache來掩蓋。

不得cache：

```txt
.dart_tool/
workspace build/
generated source
APK output
```

## Generated Consistency Failure

只有`full_ci=true`時，`CI / Generated Consistency`才會從clean checkout執行：

```bash
bash tools/ci/verify_generated.sh
```

失敗時：

1. 在本機clean working tree執行`dart pub get`。
2. 執行`dart run melos run build_runner`。
3. Review所有generated diff，確認source與generator版本正確。
4. 提交需要追蹤的generated files。
5. 不得讓CI自動commit，也不得只忽略dirty-tree結果。

若本機Windows checkout因CRLF或WSL／Windows Git混用產生假dirty狀態，使用單一Git環境確認實際content diff；正式CI authority仍是Ubuntu clean checkout。

## Quality or Test Failure

### Documentation／analysis failure

依workflow log執行對應repository command：

```bash
dart run melos run docs_check
dart run melos run analyze
git diff --check
```

修正root cause後提交新的commit，不修改workflow讓既有錯誤變成non-blocking。

### Test failure

```bash
dart run melos exec --scope=flutter_architecture --scope=auth --scope=api_client -- flutter test
```

確認是否可重現、是否為flaky test、shared state或平台差異。沒有證據前不得直接rerun直到變綠；若確認flaky，先建立focused fix與regression evidence。

Design System golden test使用`design_system_gallery_<platform>.png`保存各host renderer的獨立authority；Windows、Linux與macOS均有reviewed baseline。Manual-local／self-hosted失敗時，allowlisted master／test／diff images與文字摘要保存於managed local store的`verification-failure`job，raw retention為14天。只有人工`github-hosted`＋`artifact_transport=failure-only`才可將有界golden PNG送至GitHub，retention為7天。應先核對manifest與checksums，再比較renderer與host差異；不得只放寬pixel tolerance掩蓋失敗。

## Android Artifact Failure

Android workflow依序執行generated consistency與：

```bash
bash tools/ci/build_android_development.sh
API_BASE_URL=https://api.acme.test bash tools/ci/build_android_production.sh
```

Local development與production的正式入口分別為：

```bash
bash tools/ci/build_android_development.sh
API_BASE_URL=https://api.your-domain.example bash tools/ci/build_android_production.sh
```

失敗時：

1. 確認generated gate是否先失敗。
2. 在repository root執行`dart pub get`。
3. 使用 environment-aware build script，或在App目錄直接驗證：

   ```bash
   flutter build apk --release --flavor production \
     -t lib/main_production.dart \
     --dart-define=API_MODE=real \
     --dart-define=API_BASE_URL=https://api.your-domain.example
   ```

4. ReviewGradle、Android SDK、Java 17、Flutter 3.41.6與entrypoint evidence。
5. 建立fix commit或revert造成失敗的commit。

不得上傳舊APK並標成新commit artifact，也不得把失敗commit對應到其他SHA的產物。

## iOS Simulator Build Failure

只有`ios_build=true`時，`iOS / Simulator Build`與`iOS / Production Release Build`才在`macos-15`執行：

```bash
bash tools/ci/build_ios_development.sh
API_BASE_URL=https://api.acme.test bash tools/ci/build_ios_production.sh
```

Local development與production verification的正式入口分別為：

```bash
bash tools/ci/build_ios_development.sh
API_BASE_URL=https://api.your-domain.example bash tools/ci/build_ios_production.sh
```

Production iOS verification使用`Release-production`、generic `iphoneos` SDK與`CODE_SIGNING_ALLOWED=NO`，不產生可上架IPA。不得改成Release Simulator；Flutter toolchain會以「release/profile builds are only supported for physical devices」拒絕該組合。

需要iOS build時，此gate會重新取得Pub與CocoaPods dependencies並建立unsigned Simulator `.app`，不讀取Apple signing secrets，也不把`.app`當成distribution artifact。Manual-local／self-hosted失敗時，`toolchain.txt`與`build.log`等allowlisted diagnostics保存於managed local store的`verification-failure`job；人工`github-hosted`＋`failure-only`例外才保存7天GitHub diagnostics。Documentation-only時，`iOS / Simulator Build`改在Ubuntu執行同名no-op，Production job skipped，完全不啟動macOS runner或建立platform artifact。

## Change Classification Failure

若classification job本身失敗、輸出缺失或changed range無效：

1. 一般classifier／planner ambiguity至少fail-safe到logical full；不得因分類失敗而略過source validation。
2. 只有explicit release的candidate range也無法判定時，才fail-safe到generated＋Android＋iOS完整platform evidence。
3. 若canonical classifier仍能可靠判定platform impact，planner execution failure只升級logical validation並保留可判定的平台影響，不自行燒雙平台。
4. 修正classifier／planner後重新執行該intent需要的fresh evidence；不得以恢復每次PR或push全量執行作為常態fallback。

處理順序：

1. 下載`ios-simulator-build-diagnostics-<full-sha>`。
2. 核對macOS、Xcode、Flutter與CocoaPods版本。
3. 在macOS repository root重跑`bash tools/ci/build_ios_development.sh`；production failure則重跑`API_BASE_URL=https://api.your-domain.example bash tools/ci/build_ios_production.sh`。
4. 若是runner或registry transient failure，只可在確認source contract無誤後rerun。
5. 若是Pod resolution、native identity、plugin registration或Xcode build failure，建立focused fix並重新review。

此check通過不代表實體裝置、Face ID／Touch ID、signing、archive或App Store上架已驗證。

## Artifact Contract

Environment-aware build scripts仍會在managed job的`artifacts/`內建立platform-local projection，例如Android／iOS environment目錄與`artifact-metadata.txt`；但retention、cleanup與run identity的正式authority是job `manifest.json`與run `run-manifest.json`。

Job metadata至少包含commit SHA、git ref、dirty state、execution mode、host identity、run／job key、suite、platform、environment、build mode、artifact path／bytes／SHA-256、validation result、evidence status、retention class與cleanup disposition。Platform-local metadata另外包含flavor或scheme、configuration／SDK、entrypoint、API mode、native identifier、artifact filename與以下分類：

```txt
signing=debug signing for verification only
distribution=not production-ready
```

使用artifact前應先核對job manifest的commit SHA、result、evidence status與`checksums.sha256`，再用於verification或debug。`run-manifest.json`只聚合job manifest path／hash與結果，不重複成為第二份platform metadata authority。

Retention class：

| Class | Raw retention | Count bound | Metadata retention |
|---|---|---:|---|
| `verification-success` | 7天 | 每suite／ref最新3次 | 90天 |
| `verification-failure` | 14天 | 最新10次 | 90天 |
| `observability-raw` | 3天 | 每platform最新2次 | 90天 |
| `release-verification` | 30天 | 最新3個release SHA | 365天 |
| `pinned` | 到`expires_at`，最長90天 | 必須有owner／reason | 與pin一致 |

完整三環境本地命令、manifest-first identity替換順序、placeholder與secret boundary請讀：

```txt
docs/guides/native_environment_adoption.md
```

## Workflow Rollback

Workflow regression優先使用focused fix。若workflow本身讓repository無法正常merge或持續消耗runner：

1. 找出最後一個已知正常workflow commit。
2. Revert造成regression的workflow commit，或建立最小修復commit。
3. 執行YAML/static contract與repository commands。
4. 若required check名稱被改壞，repository administrator需同步修復Branch Protection settings。
5. 不得藉rollback降低既有quality gate，除非另有正式Decision與review。

Artifact transport regression時，優先將repository variable切到`manual-local`，以相同managed schema完成本機驗證；不得改成隱式`github-hosted`fallback。Cutover rollback只revert workflow／writer commits，不直接刪除managed store。若已有cleanup apply但尚未purge，使用`artifact_cleanup.py restore`；已purge的local raw artifact與已刪除的GitHub object都不可聲稱可恢復，只能由仍可checkout的commit重新產生。

GitHub settings不在Git history內。任何Branch Protection修改都應由管理者另外記錄變更內容、時間與操作者。

## Future Production Release Extension

Production release必須建立獨立workflow與protected Environment，至少重新設計：

- Production keystore ownership與rotation。
- Secret／OIDC／Store credential管理。
- AAB而非verification APK。
- Approval與environment protection rules。
- Signing verification。
- Version／release notes／Store upload contract。
- Artifact provenance與retention。

不得直接把現有debug-signed verification workflow加上Store upload step後稱為production pipeline。

## Explicit Non-goals

目前repository CI不包含：

- Production signing。
- Play Store／App Store publishing。
- GitHub Release automation。
- Environment promotion。
- Dependency auto-update。
- Production Store credential、signing與distribution pipeline。

