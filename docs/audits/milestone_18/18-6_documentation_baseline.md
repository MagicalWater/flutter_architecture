# Milestone 18-6 — Documentation & Provisional Baseline Assessment

## 狀態

Completed audit；尚待review，尚未進入Audit Review Gate或remediation。

本文件保存README、ADR、Roadmap、Backlog、Project Context、CHANGELOG與VERSION的一致性證據，以及Template Baseline的provisional判定。所有正式finding的唯一Single Source of Truth為`docs/audits/milestone_18/findings.md`。

---

## 1. Version inventory

Current Template Baseline：

```txt
VERSION     1.1.0
README      1.1.0
CHANGELOG   [1.1.0] - 2026-07-17
```

三個主要version surfaces一致。`VERSION`仍是唯一version source，README與CHANGELOG沒有出現不同的current baseline number。

Baseline 1.1.0正式封存Milestone 14 Offline Cache。Milestone 15 Design System、Milestone 16 Localization與Milestone 17 Exception & Failure Architecture均在其後完成，目前只存在於`[Unreleased]`與project history，尚未發布新的Template Baseline。

因此1.1.0並非錯誤版本號，但已落後於`main`的實際能力。是否發布新baseline必須等Audit Review Gate、approved remediation與18-8 final validation後決定。

---

## 2. README capability statement

README開頭將repository描述為：

```txt
可直接作為企業專案起點的 Flutter Enterprise Template
```

README也提供多組`flutter run`命令，但目前App沒有Android、iOS、Windows、macOS、Linux或完整Web runner scaffold，clone後無法直接build或run任何platform application。

README的Web段落有說明需要先執行`flutter create . --platforms web`，但首頁定位、專案狀態與一般run command附近沒有清楚揭露整個repository目前只有Dependency-ready Dart / Flutter application layer。

這不是六平台支援謊稱；README從未列出六平台Supported。問題是「可直接作為企業專案起點」與「沒有任何可執行platform project」之間存在重要定位落差。正式記錄為`M18-D01`。

---

## 3. Platform terminology consistency

多數新文件已正確記錄：

- Web只有`sqflite_sw.js`與`sqlite3.wasm`。
- 完整Web runner尚未建立。
- `flutter build bundle`不是Android appbundle或platform artifact。
- 六平台目前皆為Dependency-ready。

但部分較早文件仍使用過度寬鬆措辭：

```txt
Decision 014
  專案目前只有 Dart / Flutter Web scaffold

Milestone 2C歷史完成語意
  Flutter Web不再因databaseFactory未初始化而白畫面
```

實際上repository從未有完整Web runner；只有Web SQLite assets與conditional initializer。這些句子應改成「Web dependency preparation / SQLite assets」，並保留當時未取得browser runtime evidence的限制。

正式記錄為`M18-D02`。這是文件準確性問題，不代表database initializer設計本身失效。

---

## 4. Architecture rule consistency

README、AGENTS與conversation rules明確要求：

```txt
跨Feature不直接依賴對方的Bloc
```

目前production code存在`M18-A01`與`M18-A02`所記錄的跨Feature Presentation coupling。文件規則本身清楚，不應為了保留現況而模糊化；Gate需修正production boundary，或明確修訂architecture claim並記錄accepted risk。

這個矛盾已由`M18-A01/A02`承載，不另建立documentation duplicate finding。

---

## 5. Build與validation terminology

歷史文件多次記錄development / staging / production `bundle build`通過。這些結果可以證明entrypoint與framework compilation，但不能證明Android、Web或Desktop artifact。

18-4與18-5已建立正確taxonomy。18-6後續文件同步應統一使用：

```txt
framework / Dart bundle compilation
platform release artifact build
application runtime smoke
```

歷史commit與CHANGELOG記錄不需要全部重寫，但current README、Project Context、Roadmap summary與baseline release notes不得再把bundle compilation簡稱為platform build。

這個要求由`M18-C01`與`M18-D02`共同承載，不另建立finding。

---

## 6. Backlog consistency

Backlog仍在「第二階段可以考慮」列出：

- ADR。
- Unit / Bloc / Repository Test完整範例。
- Localizations。

其中ADR、測試範例與Localization均已有大量實作；Localization雖有完成註記，仍與未完成項目混列。Backlog同時保留已排入且已完成的Milestone 10、12至17。

這不會導致runtime錯誤，但會降低Backlog作為「尚未做」清單的可信度。正式記錄為`M18-D03`（P3），建議在18-7或18-8將completed / deferred / future ideas分開，而不是持續累積註解。

---

## 7. Current finding inventory

Phase A目前共有9項正式findings：

```txt
P1
  M18-A01
  M18-R01
  M18-P01
  M18-C01
  M18-D01

P2
  M18-A02
  M18-P02
  M18-D02

P3
  M18-D03
```

沒有P0。

P1均需在Audit Review Gate被Resolved、能力降級或明確Accepted risk，否則不能發布新的Template Baseline。

---

## 8. Provisional baseline assessment

### Current 1.1.0

維持1.1.0作為最後已發布baseline是正確的。Milestone 18 Phase A期間不得更新VERSION，也不得把未完成disposition的`main`宣告為新baseline。

### Release now

Provisional decision：

```txt
Do not release now
```

原因：

- 5項P1尚未disposition。
- Auth ordering與persisted identity有confirmed correctness risk。
- Platform capability與README定位尚未拍板。
- Documentation與capability matrix尚未完成Gate同步。

### Version after approved remediation

若Gate核准並完成必要remediation，provisional version recommendation為：

```txt
1.2.0 (MINOR)
```

理由：Milestone 15至17加入Design System、Localization、typed Exception / Failure與Error Reporting等明確新增模板能力，符合現有SemVer文件對MINOR的定義。已知architecture與persistence修正目前沒有證據要求MAJOR；若Gate決定大幅改變模板定位、platform ownership或使用方式，18-8仍可重新評估MAJOR。

若Gate選擇把repository正式降級為Dart / architecture starter且不提供任何可執行platform project，也可以維持不發布，或在完成清楚定位後再決定是否發布；不得只靠文件改名掩蓋Auth correctness findings。

---

## 9. New baseline release conditions

新baseline至少需要：

1. 所有P1有符合contract的disposition。
2. Approved remediation完成並有對應regression。
3. Gate逐平台拍板Supported / Verification pending / Dependency-ready / Not supported。
4. README首頁、run instructions、platform matrix與build terminology一致。
5. VERSION、README、CHANGELOG與release validation同步。
6. 382項既有regression與新增targeted tests通過。
7. 對所有Supported target取得release artifact與runtime smoke；Dependency-ready平台不得被宣稱Supported。

CI/CD目前仍是Deferred，不是既有baseline capability。若Gate將automatic verification列為release條件，需明確納入approved remediation。

---

## 10. 18-6 conclusion

目前文件大部分能追蹤Milestone 1至17的決策與歷史，VERSION surfaces也一致；主要問題是current README產品定位與實際無platform scaffold的差距、早期Web scaffold / runtime措辭不精確，以及Backlog混入已完成項目。

本階段新增`M18-D01`、`M18-D02`與`M18-D03`。Provisional baseline decision為現在不發布；若Gate與remediation完成且沒有新的breaking scope，傾向發布`1.2.0`。

本階段只完成audit與落檔，不修改current documentation claims、production code或VERSION。下一步為18-6 Review，之後才可進入Audit Review Gate。
