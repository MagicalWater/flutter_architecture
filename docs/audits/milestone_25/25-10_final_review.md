---
document_type: final-review
status: active
authoritative_for:
  - milestone-25-final-review
last_reviewed_baseline: 1.6.1
---

# Milestone 25-10 — Final Holistic Review and Release Gate

## Disposition

Milestone 25的repository implementation、local build、Simulator runtime、security plugin、lifecycle與macOS golden evidence已完成整體review；目前 **不發布1.7.0、不封存Milestone 25，也不宣稱iOS Supported**。

唯一未關閉的release gate是新加入的GitHub-hosted `iOS / Simulator Build`尚未在remote `macos-15` runner實際執行。相關workflow commit仍未push，因此沒有可引用的runner、Xcode、CocoaPods與workflow run evidence。Physical-device validation依Task 25-9正式defer，不是本次release blocker，但必須持續揭露。

## Planning Findings Closure

| ID | Disposition |
|---|---|
| M25-PR01 | Closed：tracked iOS runner與application artifact已建立 |
| M25-PR02 | Closed：build／simulator／device／Supported分級已建立 |
| M25-PR03 | Closed：current toolchain維持CocoaPods-compatible integration |
| M25-PR04 | Closed：禁止pure-SPM claim |
| M25-PR05 | Closed：Keychain write／restart／read／Logout delete通過 |
| M25-PR06 | Closed：single-prompt、grace與fail-closed通過 |
| M25-PR07 | Closed：temporary generation與逐檔review完成 |
| M25-PR08 | Closed：iOS 13.0 contract完成 |
| M25-PR09 | Closed：template identity完成 |
| M25-PR10 | Closed：personal signing data未進repository |
| M25-PR11 | Closed：macOS golden authority完成 |
| M25-PR12 | Implementation closed／remote evidence pending |
| M25-PR13 | Disposition closed：physical device正式defer |
| M25-PR14 | Closed：CocoaPods與future SPM gate已記錄 |

Open implementation P0／P1為0；release evidence blocker為remote workflow尚未執行。

## Evidence Classification

| Claim | Current state |
|---|---|
| iOS build-verified | Yes |
| iOS simulator-verified | Yes |
| iOS device-verified | No；正式defer |
| iOS Supported | No |
| Distribution-ready | No |

## Final Local Verification

Final gate重新執行docs check、analyze、全部Flutter tests、generated consistency、Android release build、clean iOS Simulator build、workflow／shell contract與whitespace check。

Final gate期間發現並修正兩個macOS shell portability P1：

- `verify_generated.sh`使用Bash 4 `mapfile`，在macOS Bash 3.2失敗。
- `build_android_release.sh`在`pipefail`下以`head`截取版本，可能因SIGPIPE在APK成功後回傳失敗。

## Release Gate

解除blocked狀態需要：

1. Push目前Milestone 25 commits。
2. 確認GitHub-hosted `iOS / Simulator Build`成功。
3. 記錄實際run ID、runner image、Xcode、CocoaPods與Flutter evidence。
4. 重新執行final documentation review。
5. 屆時才可將VERSION升為1.7.0、更新CHANGELOG release section、封存Milestone 25並使用release commit。

在上述證據完成前，Baseline維持1.6.1，Milestone 25維持active／release-blocked。
