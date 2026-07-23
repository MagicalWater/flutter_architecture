---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-26-task-26-6-ci-review
last_reviewed_baseline: 1.7.0
---

# Task 26-6 — CI Representative Environment Matrix Review

## Scope

本Task只建立Development與Production的代表性CI建置，不加入Store signing、keystore、provisioning profile、IPA／AAB發布或任何GitHub secret。

## Final representative set

| Check | Native selector | Dart entrypoint | Artifact boundary |
|---|---|---|---|
| `Android / Development Debug APK` | `developmentDebug` | `lib/main_development.dart` | debug-signed verification APK |
| `Android / Release APK` | `productionRelease` | `lib/main_production.dart` | debug-signed verification APK |
| `iOS / Simulator Build` | `Development` + `Debug-development` + `iphonesimulator` | `lib/main_development.dart` | unsigned Simulator `.app` |
| `iOS / Production Release Build` | `Production` + `Release-production` + `iphoneos` | `lib/main_production.dart` | unsigned device `.app` |

既有穩定名稱`iOS / Simulator Build`與`Android / Release APK`未變更；新增checks不要求Branch Protection同步改名。

## Review findings and dispositions

### M26-6-R01 — Quality gate未執行environment contracts

- Severity：P1
- Fix：`CI / Quality`加入environment mapping、workflow matrix、local build與既有iOS／shell contracts。
- Re-review：27個Python contract tests通過。

### M26-6-R02 — Production artifact metadata缺少commit SHA與iOS SDK

- Severity：P1
- Fix：Android／iOS metadata加入`commit_sha`，iOS另加入`sdk`。
- Re-review：本機production build metadata已輸出`commit_sha`、`sdk=iphoneos`與正確bundle ID。

### M26-6-R03 — Production Release Simulator不可建置

- Severity：P1
- Evidence：`Production` + `Release-production` + `iphonesimulator`可穩定重現Flutter錯誤：`release/profile builds are only supported for physical devices`。
- Root cause：Flutter iOS Release/Profile採AOT，只支援device target；Simulator只支援Debug execution model。
- Fix：保留Development Debug Simulator，Production改用generic `iphoneos` unsigned Release build。
- Re-review：`build_ios_production.sh`實際建置成功，`bundle_id=com.example.flutterarchitecture`、`sdk=iphoneos`、`distribution=not production-ready`。

### M26-6-R04 — Workflow可能讀取Store secrets

- Severity：P0 safety review
- Result：Android／iOS workflows不含`secrets.*`、keystore、provisioning、Match或App Store credential。

### M26-6-R05 — Artifact retention與identity邊界

- Severity：P1
- Fix：四個verification artifacts以environment與full SHA命名並保留14天；iOS failure diagnostics保留7天。所有metadata維持`distribution=not production-ready`。

## Local validation

- Workflow YAML由Ruby YAML parser讀取成功。
- External actions維持full SHA pinning。
- Shell syntax通過。
- Production unsigned iOS device Release build實際成功。
- Open P0／P1 without disposition：0。

## Remote validation status

GitHub-hosted CI、Android與iOS representative matrix均已成功，artifact identity與toolchain evidence已下載核對。完整run IDs、runner／Xcode版本、artifact metadata與M26-6-R06 disposition見：

```txt
docs/audits/milestone_26/26-6_remote_validation.md
```
