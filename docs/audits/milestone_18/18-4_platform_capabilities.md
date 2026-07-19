# Milestone 18-4 — Platform Capability & Build Audit

## 狀態

Reviewed / Closed；尚未進入remediation。

本文件保存六平台scaffold、dependency、static compatibility、host build與runtime evidence。所有正式finding的唯一Single Source of Truth為`docs/audits/milestone_18/findings.md`。

---

## 1. Evidence taxonomy

本階段依Milestone 18 contract區分repository evidence、dependency declaration、tracked scaffold、static compatibility、host-available build、runtime smoke與external-host verification。

Review後進一步把platform evidence拆成三層，避免component test被誤讀為application capability：

```txt
Component evidence
  package、database adapter或conditional initializer在host test中的證據。

Application artifact evidence
  對應platform runner可產生APK / AAB / Web output / desktop executable等artifact。

Application runtime evidence
  實際啟動App並驗證bootstrap、plugin registration、database、preferences與核心flow。
```

Capability只可使用Supported、Verification pending、Scaffold only、Dependency-ready與Not supported。

---

## 2. Tracked platform inventory

`apps/flutter_architecture`目前沒有tracked Flutter platform scaffold：

```txt
android/   absent
ios/       absent
web/       runner scaffold absent
windows/   absent
macos/     absent
linux/     absent
.metadata  absent（輔助inventory，不是artifact失敗的核心原因）
```

Tracked Web檔案只有SQLite runtime assets：

```txt
web/sqflite_sw.js
web/sqlite3.wasm
```

這兩個檔案不能取代`index.html`、manifest、icons與Flutter Web runner metadata。

---

## 3. Dependency與static compatibility

App已宣告`sqflite`、`sqflite_common_ffi`、`sqflite_common_ffi_web`、`shared_preferences`與`path_provider`。Database initializer使用conditional export：Android / iOS保留native sqflite factory，Windows / macOS / Linux切換FFI，Web切換`databaseFactoryFfiWeb`。

Dart / package boundary具備跨平台設計，但缺少任何可建立artifact的platform project。

---

## 4. Build evidence

Audit host：Windows，Flutter 3.41.6 stable，Dart 3.11.4。

`flutter build bundle --release`成功；此結果只屬framework / Dart bundle compilation evidence，證明Dart、generated references、assets與部分conditional imports可編譯，不是Android `.aab`、APK、Web或Desktop application artifact。

`flutter build web --release`失敗：

```txt
This project is not configured for the web.
```

`flutter build windows --release`失敗：

```txt
No Windows desktop project configured.
```

Android、iOS、macOS與Linux同樣缺少tracked scaffold。本階段沒有執行會修改repository的`flutter create`。

---

## 5. Six-platform capability matrix

| Platform | Component evidence | Tracked scaffold | Application artifact evidence | Application runtime evidence | Classification |
|---|---|---|---|---|---|
| Android | sqflite native path與Dart code相容設計 | 無 | 無 | 無 | Dependency-ready |
| iOS | sqflite native path與Dart code相容設計 | 無 | 無 | 無 | Dependency-ready |
| Web | Web database initializer與SQLite assets存在 | 無完整Web runner | Web build明確失敗 | 無browser smoke | Dependency-ready |
| Windows | FFI initializer與Windows-host SQLite component tests | 無 | Windows build明確失敗 | 無Windows App runtime smoke | Dependency-ready |
| macOS | FFI initializer與dependency存在 | 無 | 無；需macOS host | 無 | Dependency-ready |
| Linux | FFI initializer與dependency存在 | 無 | 無 | 無 | Dependency-ready |

沒有任何平台符合Supported、Verification pending或Scaffold only，因為三者至少需要tracked platform scaffold。

---

## 6. Native configuration inventory

Platform directories不存在，因此沒有可audit的Android Manifest / Gradle、iOS Info.plist / entitlements、macOS entitlements、Windows / Linux CMake runner或完整Web manifest / index。

這不是個別設定錯誤，而是platform project尚未建立。

---

## 7. Documentation consistency

README、Project Context、ADR與archive已明確記錄App只有Dart / SQLite Web assets，Web需先執行`flutter create . --platforms web`才可build，其他platform scaffold尚未建立。

目前沒有文件宣稱六平台Supported的矛盾；問題是模板capability仍停留在Dependency-ready。

---

## 8. Test evidence與coverage gaps

Existing component / framework evidence：workspace tests可在Windows host執行、Windows FFI SQLite tests涵蓋schema與migration、conditional initializer避免Web static import `dart:io`、framework bundle compilation成功。

Coverage gaps：六平台均無runner、沒有platform artifact、沒有browser SQLite smoke、沒有mobile runtime smoke，也沒有完整Desktop App runtime smoke。

---

## 9. Finding

`M18-C01`：App沒有任何tracked Flutter platform scaffold，六平台目前全部只能分類為Dependency-ready；模板不能直接建立或執行platform artifact。

Audit Review Gate必須逐平台拍板disposition，例如Supported target、Verification pending target、維持Dependency-ready或Not supported，不能只做一個籠統的「加入platform scaffold」決定。

單純執行`flutter create . --platforms ...`最多只能先取得Scaffold only；要提升為Supported，仍需每個平台獨立驗證dependency resolution、generated code、release artifact、native configuration、database factory、SharedPreferences、bootstrap / routing、Theme / Locale restore、Mock API核心流程與runtime smoke。

---

## 10. 18-4 conclusion

目前跨平台成果是Dart / dependency / database-factory design，而不是可交付platform support。

```txt
Android  Dependency-ready
iOS      Dependency-ready
Web      Dependency-ready
Windows  Dependency-ready
macOS    Dependency-ready
Linux    Dependency-ready
```

本階段已完成audit與review，不執行`flutter create`，也不修改production scaffold。Finding需等Audit Review Gate逐平台決定Supported target、Verification pending target、維持Dependency-ready或Not supported；或正式將Template Baseline能力限制為Dart / architecture starter。
