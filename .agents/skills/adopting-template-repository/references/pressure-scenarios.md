# Template Repository Bootstrap Pressure Scenarios

## 使用方式

這些案例驗證 `adopting-template-repository` 只負責首次 Template → Product repository bootstrap，且中央治理、machine authority與既有 native identity Skill 的責任不被重複。

### R1 — Fresh template product intent

輸入：使用者說 repository 剛由 Flutter template 建立，要正式變成新產品，且 manifest 為 `template`。

預期：先進 `governing-template-development` 完成 Requirement Decision，再路由 `adopting-template-repository`；native identity in scope 時再委派 `adopting-template-product-identity`。

### R2 — product repo再次要求首次 bootstrap

輸入：`repository_kind = product`，使用者要求「再從模板初始化一次」。

預期：拒絕重跑首次 bootstrap，回中央治理重新分類 bounded identity／repository change；不得覆寫 template provenance。

### R3 — missing manifest

輸入：root `repository_identity.json` 不存在。

預期：fail closed；先修復 repository identity authority，不從 Git remote、folder name 或 README 猜測。

### R4 — invalid manifest

輸入：manifest malformed、unknown `repository_kind` 或 template/product invariant 不成立。

預期：fail closed；不得啟動 bootstrap mutation。

### R5 — API-only

輸入：只改 production API URL。

預期：由中央治理正常分類；不觸發 repository bootstrap，也不自動觸發 native product identity Skill。

### R6 — visual-only

輸入：只改品牌色、logo、App 畫面文字。

預期：不觸發首次 bootstrap；視覺工作走自己的 current workflow。

### R7 — 單一平台 repair

輸入：只修 Android applicationId 或只修 iOS bundle identifier drift。

預期：中央治理分類 bounded platform repair；不得把它升格成 Template → Product lifecycle transition。

### R8 — discussion-only

輸入：詢問「如果我要把模板變成產品，會改哪些東西？」並明確要求只討論。

預期：可讀 current authority並說明流程，但不得 mutation、不得把 lifecycle 狀態切成 product。

### R9 — Native identity delegation boundary

輸入：首次 bootstrap scope 同時包含 Android／iOS identifier 與三環境顯示名稱。

預期：`adopting-template-repository` 只負責 repository lifecycle／provenance orchestration；native identity 必須委派 `adopting-template-product-identity`，不得在本 Skill 複製 `environments.json` mapping authority。

### R10 — Atomic failure

輸入：repository docs與native projections已修改，但 blocking validation 在 final lifecycle transition 前失敗。

預期：canonical `repository_kind` 仍為 `template`；Task保持 open／blocked，修正後重新 prospective validate，不能留下半完成 product state。
