---
name: adopting-template-product-identity
description: 當此 Flutter 模板要正式採用為具體產品，並需同步調整 Android、iOS 產品識別或 development、staging、production 顯示名稱映射時使用。
---

# 採用模板產品識別

## 核心規則

這是一個薄型、可選的使用者入口。它不負責工作分類、核准、worktree、Task、驗證、發布、environment contract、簽署或 Store 政策。

**必要子 Skill：**在進行採用分析、Design、Plan 或任何 repository mutation 前，必須先使用 `governing-template-development`。

Repository policy、已核准的 Design／Plan／ADR、目前 source、tests 與 runtime evidence 的權威高於此 Skill。

## 觸發邊界

只有在工作已被接受，且要將模板採用為具體產品，並同步修改 Android／iOS 產品識別或 development／staging／production 顯示名稱映射時，才使用此 Skill。

下列情況不可視為自動觸發：

- 只做視覺品牌調整、App icon 或畫面標題修改；
- 只修改 API 設定；
- 有界的單一平台 identifier 修復；
- 新增、重新命名、調整 environment 順序或 suffix；
- production signing、credential custody 或 Store distribution。

這些需求必須回到 `governing-template-development` 重新分類。

## 輸入與 mutation gate

必須區分三種範圍：

1. **只討論／盤點**：可以檢查目前 authority 並提出候選值，但不得 mutation。
2. **產品識別 projection mutation**：必須提供明確的 base identifier，並確認 development、staging、production 三個顯示名稱。
3. **Real API build／runtime closure**：若 staging 與 production 被納入已接受的 evidence scope，還必須提供有效的 staging 與 production API domains。

不得猜測 base identifier。可以依產品名稱提出顯示名稱候選值，但不得視為使用者已默認確認。缺少 API domains 時，相關 build／runtime evidence 必須維持 `Pending`；不得以模板 placeholder 冒充證據。

不得在 tracked files 中寫入或保留 keystore 密碼、private keys、Apple certificates、provisioning credentials、service-account secrets、API tokens 或其他 credentials。

## 必讀文件

中央分類完成後，讀取下列文件的 current version：

```txt
VERSION
docs/adr/adr-014-app-configuration-environment-entrypoints.md
docs/adr/adr-025-native-environment-mapping-product-identity-contract.md
docs/guides/native_environment_adoption.md
apps/flutter_architecture/config/environments.json
Android 與 iOS 目前的 projections
tools/ci/verify_environment_contract.py
tools/ci/test_environment_contract.py
相關 build scripts 與 tests
```

`AGENTS.md`、`repository_identity.json` 已由 fresh admission 處理；`docs/project_context.md` 不再是此 domain 的固定必讀，只有需要 project-wide current capability 時才按需讀。

此 Skill 只保存閱讀路由，不複製 mapping values、platform procedures 或 exact verification commands。

## 必要行為

1. 保留使用者原始 scope，以及任何「只討論」限制。
2. 先委派 `governing-template-development`，並產生其 Requirement Decision。
3. 將需求分類為完整模板採用、有界修復或 architecture change。
4. mutation 前先盤點 `environments.json`、Dart entrypoints、Android projection、iOS projection 與 verifier expectations。
5. 套用新 identity 前，先處置任何 pre-existing drift。
6. 採用 manifest-first 順序：先更新已接受的 manifest authority，再同步各平台 projections。
7. 以 `docs/guides/native_environment_adoption.md` 作為完整 procedure 與 current exact-command authority。
8. Evidence 只能標記為 `Verified`、`Statically verified`、`Pending`、`Blocked` 或 `Not in scope`。
9. 不得把 iOS static projection check 描述成 Xcode build。

## 強制停止與升級條件

遇到下列任一情況，停止 mutation 或回到中央治理重新分類：

- base identifier 缺失或無效；
- 顯示名稱尚未確認；
- environment identifiers 重複或 suffix 衝突；
- 新增、重新命名、調整 environment 順序或 entrypoint；
- tracked secrets、signing credentials 或 credential custody；
- production signing 或 Store distribution；
- 尚未處置的 manifest／native drift；
- 所需 platform 或 runtime evidence 無法取得。

不得削弱 verifier rules、改變 supported-platform claims、建立第二份 identity mapping，或把 Guide 的完整 exact command suite 複製進此 Skill。

## 禁止承擔的責任

此 Skill 不得自行分類工作、核准 Design 或 Plan、決定 branch／worktree policy、接受 Tasks、關閉 releases、修改 environment contract、承擔 signing，或宣稱 Store readiness。

壓力測試協議：[references/pressure-scenarios.md](references/pressure-scenarios.md)。
