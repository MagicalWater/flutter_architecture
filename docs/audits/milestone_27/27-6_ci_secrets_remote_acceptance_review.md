---
document_type: phase-review
status: active
authoritative_for:
  - milestone-27-task-27-6-ci-secrets-remote-acceptance-review
last_reviewed_baseline: 1.8.0
---

# Task 27-6 — CI Secrets and Remote Acceptance Review

## Scope

審查GitHub Actions fork PR secret boundary、Android／iOS symbol upload、controlled staging non-fatal入口、release evidence與真實provider acceptance狀態。

## Completed implementation

- 新增`Observability Acceptance` workflow；Pull Request只執行static contract且完全不讀取provider secrets。
- 只有manual explicit acceptance可使用`staging-observability` GitHub Environment secrets；main push不再自動執行symbols jobs。
- Android production build保存Flutter symbols並透過Firebase CLI執行explicit upload。
- iOS production build保存dSYM並透過`upload-symbols`執行explicit upload。
- Android／iOS均可建立只在兩個build-time flag同時啟用時產生一次handled non-fatal的staging acceptance artifact。
- App bootstrap已實際組裝Firebase adapter；所有environment仍預設remote collection off。
- Provider initialization失敗仍降級到local reporter，不阻止App composition。
- Evidence固定保存commit SHA、release、environment、remote event status與symbolication status；未執行時寫入`not-executed`。

## Secret contract

GitHub Environment：`staging-observability`。

Required secrets：

```txt
FIREBASE_SERVICE_ACCOUNT_JSON
FIREBASE_ANDROID_APP_ID
FIREBASE_ANDROID_PRODUCTION_CONFIG_B64
FIREBASE_ANDROID_STAGING_CONFIG_B64
FIREBASE_IOS_PRODUCTION_CONFIG_B64
FIREBASE_IOS_STAGING_CONFIG_B64
```

Secrets只在non-PR jobs materialize到runner temporary filesystem或ignored provider config path，不進artifact、不進log、不進Git。

## Review findings and fixes

- P1：Firebase adapter原本只有unit-test composition，實際bootstrap未使用；已加入App-owned runtime composition與release keys。
- P1：沒有受控remote acceptance event；已新增staging-only、double opt-in handled non-fatal入口。
- P1：初次review時repository沒有observability secrets；目前GitHub Environment已配置並完成真實symbol upload與Android console verification。
- P2：CI build未注入commit SHA；Android與iOS build wrapper現在固定注入`APP_COMMIT_SHA`。

## Current evidence

- Local focused runtime tests：passed。
- Workflow contract tests：passed。
- GitHub authentication：available。
- Repository observability secrets：configured in protected Environment。
- Android remote symbol upload：executed。
- Android remote event／symbolication：verified。
- iOS matching dSYM upload：executed；最新本機Simulator build的Runner與App.framework UUID已核對並提交。
- iOS report transport：Crashlytics endpoint HTTP 200。
- iOS Firebase Console ingestion／symbolication：pending manual confirmation。
- 舊missing UUID屬於先前binary；除非找回原始archive／dSYM，不能由新build UUID補救。

## Disposition

IMPLEMENTATION ACCEPTED；iOS CONSOLE CLOSURE PENDING。

Open implementation P0／P1 = 0。剩餘external closure只有人工在Firebase Console確認最新iOS event ingestion與symbolicated stack；在此之前不得標成verified。

