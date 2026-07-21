# Milestone 21-5 Android Native、Security與Runtime Review

狀態：Reviewed / Closed。

## Native contract

- `MainActivity`使用`FlutterFragmentActivity`。
- Source manifest包含`android.permission.USE_BIOMETRIC`。
- Launch / Normal theme使用AppCompat且保留Flutter background contract。
- Release merged manifest：minSdk 24、targetSdk 36、`allowBackup=false`。
- `USE_FINGERPRINT`由AndroidX / plugin compatibility manifest合併產生，不是額外業務permission。

## Runtime evidence

- Release APK：59,850,883 bytes。
- SHA-256：`6fb6d3a82073a77e001a0b1d9749fcf755308f1476e8f8c2406cac4ace0a6ba6`。
- API 35 emulator：install成功、MainActivity visible / resumed、startup無Flutter / AndroidRuntime crash。
- Emulator未配置biometric enrollment，因此not-enrolled / unavailable可重現；success path不宣稱為實機runtime觀察，而由adapter、policy、startup、lifecycle與widget deterministic tests覆蓋。

## Security audit

- Production logging / `toString()`未輸出credential、userId、biometric type、plugin error code或raw result。
- Preference只保存version與enabled / disabled state。
- Prompt reason為localized generic copy，不含account、userId或credential。
- Locked / prompting期間Session為null，Guard、Dio token provider、Refresh與Profile無authenticated authority。

## Finding

| ID | Severity | Finding | Disposition |
| --- | --- | --- | --- |
| M21-5-R01 | P1 | 21-1至21-4雖已有policy與gate，但production UI沒有enable / disable入口，無法完成真實enable → cold-start unlock旅程。 | Closed：新增App-level localized settings dialog與Shell入口；enable使用authenticated-only policy並先prompt，disable只改preference。 |

## Verification

- `dart pub get`通過。
- Workspace analyze通過。
- Workspace Flutter tests：626項通過。
- Android release APK build通過。
- Android scaffold / local_auth contract tests通過。
- `git diff --check`於final commit前執行。
