# Milestone 21 Biometric-gated Local Session Unlock Implementation Plan

> 本計畫依Milestone 21-0 Planning Review執行。每個Task完成後立即review並修正；每個子階段完成後做整體implementation review，通過才提交。

## Global constraints

- Biometric只驗證local user presence，不建立Server Session。
- Locked時`SessionManager.currentSession == null`。
- `local_auth`與Native implementation只在App layer。
- Route Guard不依賴AuthBloc。
- 不修改OTP challenge authority、Refresh authority或Secure credential source of truth。
- 不提前加入Device Binding、Passkey、TOTP、Firebase Auth、Root detection或iOS runtime support。
- VERSION只在21-5 final baseline decision可能調整。

## 21-1 Local User Presence Contract與App Adapter

### Task 1：建立純Dart contract

- 在`packages/auth`新增`LocalUserPresenceVerifier`、capability與verification sealed result。
- 不暴露plugin type、platform error code或biometric type。
- 匯出public API並加入contract tests。

### Task 2：加入App-only local_auth dependency與isolated adapter

- 在App `pubspec.yaml`加入經實際解析確認的`local_auth`版本。
- 建立`LocalAuthUserPresenceVerifier`，固定biometric-only policy，不允許device credential fallback。
- 將cancel、not enrolled、no hardware、temporary / permanent lockout與unknown error映射至typed result / exception。

### Task 3：DI與adapter regression

- App Composition Root註冊adapter；startup尚不消費它。
- Mock / fake verifier供unit與widget test使用。
- 驗證packages不依賴`local_auth`，production logging與`toString()`不洩漏prompt資料。

### 21-1 review gate

- Targeted adapter / contract tests。
- Workspace analyze與完整tests。
- 確認未修改Android Native、startup restore與VERSION。
- 建立`docs/audits/milestone_21/21-1_local_presence_review.md`後提交。

## 21-2 Enable / Disable Policy與Persistence

### Task 1：Preference contract與codec

- 建立`LocalUnlockPreference` version 1與`enabled / disabled`狀態。
- 建立sealed read taxonomy：absent / present / corrupted；operational error不可當absence。
- Storage key固定且不保存biometric type、userId、credential或enrollment identity。

### Task 2：App-owned store與serialized write

- 使用App一般preference boundary實作store。
- 寫入採serialized latest-snapshot contract；read corruption fail-closed。
- unknown error保留caught stack，不被降級。

### Task 3：Enable workflow

- 只允許目前authenticated Session進入。
- 流程：capability available → successful prompt → preference write success。
- Prompt success但write失敗時維持disabled並回typed failure。
- Enable過程被Logout / account switch取代時不得寫enabled。

### Task 4：Disable / cleanup workflow

- Disable只修改preference，不清credential或Session。
- Logout cleanup加入local unlock preference；所有cleanup仍全部嘗試。
- Restore發現無credential時best-effort清stale enabled preference。

### 21-2 review gate

- Corruption、read/write failure、enable race、logout cleanup與process-restart persistence tests。
- Workspace analyze、完整tests與App bundle。
- 確認startup gate仍未啟用、Android Native未改、VERSION不變。
- 建立`21-2_policy_persistence_review.md`後提交。

## 21-3 Gated Restore與Session Authority

### Task 1：定義gated restore application contract

- 拆分「判斷是否需要unlock」與「Repository restore commit」。
- 建立不可由任意UI繞過的狹窄startup orchestration；禁止用boolean參數`skipBiometric`。
- Repository仍是credential / User / Session commit owner。

### Task 2：App-owned startup unlock coordinator

- 啟動時先讀preference，不再由navigation coordinator無條件dispatch restore。
- Disabled：直接gated restore。
- Enabled：進locked state；prompt success後才restore。
- Cancel / lockout / unavailable維持Session null。

### Task 3：Latest-intent與single prompt

- Unlock取得App presentation generation與shared Auth lifecycle operation。
- Logout、Login、OTP、re-login escape、external clear均invalidate pending prompt / restore。
- 重複unlock tap只允許一個plugin call。

### Task 4：Authority regression

- Locked時Guard拒絕Protected Route。
- Locked時Auth token provider、Refresh、Profile與navigation不得看到Session。
- Prompt success本身不直接建立Session；只有restore成功才authenticated。
- Credential absent / corrupted / operational failure依Planning Review policy收斂。

### 21-3 review gate

- Cold start enabled / disabled、cancel、unavailable、logout race、account switch與stale prompt tests。
- M21-PR01 P0必須以implementation evidence關閉。
- Workspace analyze、完整tests與App bundle。
- 建立`21-3_gated_restore_review.md`後提交。

## 21-4 Unlock UI、Navigation與Lifecycle Concurrency

### Task 1：Unlock presentation state與surface

- 建立localUnlockRequired / prompting / failure presentation contract。
- UI提供retry與重新登入安全出口，不顯示credential或raw capability細節。
- English / zh_TW localization、Semantics、large text與narrow viewport。

### Task 2：App navigation integration

- `AuthNavigationDestination`新增locked destination與route。
- App coordinator仍是唯一navigation owner；Auth Page不import Shell tab或Router。
- Guard維持只依SessionManager。

### Task 3：Resume grace period

- App-owned lifecycle coordinator使用可注入monotonic clock與5分鐘default grace period。
- 超時resume先清runtime Session並要求unlock，再restore。
- Grace period內不prompt；prompt-owned lifecycle抖動不建立第二prompt。

### Task 4：Lifecycle race regression

- background during prompt、rapid resume、prompt cancel、Logout during prompt、resume re-lock during refresh等race。
- 確認舊Session / refresh response不能在re-lock後復活。

### 21-4 review gate

- Widget、navigation、lifecycle、Theme / Locale與accessibility tests。
- Workspace analyze、完整tests與App bundle。
- 建立`21-4_ui_navigation_lifecycle_review.md`後提交。

## 21-5 Android Native、Security Review與封存

### Task 1：Android Native configuration

- 依已鎖定`local_auth`版本官方contract修改MainActivity、manifest與必要theme。
- 不加入不需要的permission或device credential fallback。
- 更新Android scaffold contract tests。

### Task 2：Full security / leakage audit

- 搜尋credential、userId、prompt reason、plugin error與biometric result的production log / `toString()`風險。
- Reconcile M21-PR01至M21-PR12。
- 確認沒有Device Binding、iOS runtime或root detection誤宣稱。

### Task 3：完整驗證

- `dart pub get`
- build_runner（若source generator input有變更）
- workspace analyze
- workspace完整Flutter tests
- Android release APK build
- merged manifest / minSdk / permission / activity contract
- API 35 emulator install、startup、enable、cold-start unlock、cancel、success、logout與not-enrolled / unavailable可重現範圍smoke

### Task 4：文件與baseline decision

- 同步README、CHANGELOG、Project Context、Architecture Decision、Roadmap與Backlog。
- 建立Milestone 21 holistic final review。
- 只有final review認定形成新的可交付Template能力時才調整VERSION與建立release entry。

### 21-5 final gate

- 無Open P0 / P1。
- 所有安全claim與runtime evidence相符。
- `git diff --check`通過後提交與推送。
