---
document_type: final-review
status: completed
authoritative_for:
  - milestone-28-final-review
last_reviewed_baseline: 1.10.0
---

# Milestone 28-9 — Final Holistic Review and Release

## Disposition

Milestone 28的typed connectivity contract、provider-neutral adapter、`connectivity_plus` reference implementation、startup／resume lifecycle、App-wide offline presentation、Catalog opt-in reconnect integration、cross-layer regression、platform artifact與documentation authority均已完成整體review。

```txt
Disposition: ACCEPTED
Open P0: 0
Open P1 without disposition: 0
```

## Cross-task findings disposition

- Task 28-5第一輪缺少既有`CatalogState` test helper同步，已補齊並重新執行57個Catalog presentation tests。
- Reconnect ordering已加入duplicate dedupe、manual refresh priority、query generation cancellation、failure retention與cursor replacement驗證。
- `ConnectivityController` stream／snapshot failure降級為`unknown`，不把provider error誤判為offline。
- App resume recheck與local unlock lifecycle保持獨立ownership，Auth regression通過。
- `connectivity_plus`只存在App adapter／native composition；Catalog與reusable packages沒有provider import。
- Production Android verification缺少外部`API_BASE_URL`時依既有contract fail closed；本Milestone只接受development representative artifact，不宣稱production distribution。

## Final verification

2026-07-24 final gate重新執行：

- `dart pub get`通過。
- `dart run melos run build_runner`通過；三個packages完成generation，tracked source無未提交drift。
- Workspace五個packages `flutter analyze`通過，無issues。
- Workspace全部Flutter tests通過：api_client 55、auth 154、core 4、design_system 43、App 428。
- Connectivity／Catalog／Auth focused suite 150 tests通過；Catalog presentation focused suite 57 tests通過。
- `dart run melos run docs_check`與`git diff --check`通過。
- Android development APK與iOS Development Simulator app build通過，兩端native dependency均包含`connectivity_plus`。

## Architecture and authority review

- ADR-027是typed connectivity與reachability boundary的唯一長期authority。
- App仍是唯一Composition Root；reusable packages不依賴Flutter plugin、GetIt或Injectable。
- Interface availability不等於backend reachability；operation failure仍由Repository／Result／Failure表達。
- Catalog是第一個明確opt-in consumer，不建立generic reconnect或所有API自動重試framework。
- Roadmap、Project Context、README、CHANGELOG、VERSION與Milestone routing已同步Template Baseline 1.10.0。

## Release decision

Milestone 28新增可直接採用的Connectivity與Offline State模板能力，屬MINOR release：

```txt
Previous baseline: 1.9.0
Released baseline: 1.10.0
Version class: MINOR
Milestone status: Completed / Archived
```

## Deferred scope

本release不宣稱backend reachability service、generic reconnect framework、offline write queue、automatic command retry、physical-device network toggle、production signing、AAB／IPA或Store distribution已完成。
