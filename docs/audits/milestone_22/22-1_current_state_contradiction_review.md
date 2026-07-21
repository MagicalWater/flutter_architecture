# Milestone 22-1 — Current-State Contradiction Remediation Review

## Scope

本階段只修正會讓讀者或AI誤判Template Baseline 1.5.0 current state的P0／P1文件矛盾。

不執行：

- 大型文件拆分、搬移或刪除。
- Decision 001至022 extraction。
- Project Context完整重寫。
- Roadmap responsibility separation。
- Production code修改。

## Task Review Log

### Task 1 — Root README current-state correction

狀態：Passed。

修正：

- 保留Secure credential storage的能力邊界。
- 明確指出OTP Step-Up Authentication與Android biometric-gated local session unlock已屬Template Baseline 1.5.0。
- 明確區分OTP、Biometric、Device Binding與Passkey的security claim。
- 不再將已完成的OTP與Biometric描述為future或non-baseline。

Review evidence：

- `VERSION`為`1.5.0`。
- Root README頂部Milestone狀態與Android capability matrix均為Completed / Archived及Supported。
- 修正後的security claim與Milestone 20、21 final review邊界一致。

### Task 2 — Auth README current authority

狀態：Passed。

修正：

- Production credential authority更新為`FlutterSecureAuthCredentialStore`／Flutter Secure Storage。
- Legacy SharedPreferences明確限制為migration／cleanup用途。
- 補入OTP challenge、Verify、Resend與credential commit boundary。
- 補入`StartupLocalUnlockCoordinator`、locked Session與biometric-only restore gate。
- 明確標示App-owned navigation與plugin adapter責任。

Review evidence：

- Production DI與Milestone 19 final review均以Secure store為default authority。
- `OtpRoute`、`LocalUnlockRoute`、`AuthNavigationCoordinator`與`StartupLocalUnlockCoordinator`存在於current source。
- README不再把SharedPreferences描述為production credential authority。

### Task 3 — Shell README navigation authority

狀態：Passed。

修正：

- 更新Shell tabs為Login／Catalog／Profile。
- 補入Appearance、Locale與Local Unlock設定入口。
- 明確限制Shell只擁有layout、tab selection與使用者主動action。
- Authentication transition由App-owned `AuthNavigationCoordinator`負責。
- Protected access仍由`AuthGuard`與`SessionManager`決定。

Review evidence：

- Current `ShellPage`使用`AutoTabsRouter`組合Login、Catalog與Profile routes。
- Current `AuthNavigationCoordinator`映射Login、OTP、Local Unlock與Profile destination。
- Shell source沒有依賴`AuthBloc`。

### Task 4 — Legacy path warnings

狀態：Passed。

修正：

- `docs/adr/000`至`005`統一標示為historical placeholder，且明確指出它們不是ADR。
- `docs/architecture/000`至`002`統一標示為第一階段historical／superseded guidance。
- Warning提供current snapshot與accepted decision的authoritative routing。
- 保留所有原始正文、檔名與編號，沒有搬移、刪除或重新解釋歷史內容。

Review evidence：

- 九份legacy path文件的第一個正文區塊均包含warning。
- Warning不宣稱本階段已完成Decision extraction。
- 原始歷史內容保持不變。

### Task 5 — Interim Docs / Archive routing

狀態：Passed。

修正：

- `docs/README.md`更新為migration期間的真實文件分類與暫時reading route。
- 明確區分Current、Decision、Audit／Evidence、Plan／Spec、Archive、Guide與Legacy paths。
- `docs/archive/README.md`補充歷史artifact目前分散於Archive、Audits與Superpowers的事實。
- 為Milestone 18至21提供interim historical routing。
- 沒有宣稱22-2 final documentation hub已完成。

Review evidence：

- 索引涵蓋目前實際存在的主要文件類型。
- `docs/adr/`與`docs/architecture/`均標示legacy status。
- Archive說明不要求本階段進行物理搬移。

## Finding Status

| Finding | Severity | Status | Evidence |
|---|---|---|---|
| M22-PR03 | P1 | Closed | Root README已移除OTP／Biometric non-baseline矛盾 |
| M22-PR04 | P1 | Closed | Auth與Shell README已同步current authority |
| M22-PR01 | P0 | Mitigated | Legacy ADR／architecture paths已加入不可作為current authority的醒目warning；最終routing留待22-2與後續extraction |
| M22-PR05 | P1 | Closed for 22-1 | Docs與Archive入口已反映current repository分類；final hub與完整indexes留待22-2 |

其餘22-1 findings將於後續Task完成後更新。

## Whole-Phase Implementation Review

狀態：Passed after review。

### Review scope

- Root README baseline與security capability。
- Auth persistence、OTP、local unlock與navigation authority。
- Shell layout、tab與authentication transition boundary。
- Legacy `docs/adr/`及`docs/architecture/`誤讀風險。
- Docs與Archive interim routing。
- Change scope、link target與diff hygiene。

### Review findings

1. Legacy architecture正文仍包含第一階段current-tense語句，但每份文件頂部已在正文前加入醒目warning，符合本階段「保留歷史、不重寫正文」的核准策略。
2. `SharedPreferencesAuthCredentialStore`名稱仍存在於source與部分regression tests；Auth README已明確限制其非production authority語意，沒有錯誤宣稱class已移除。
3. `docs/README.md`目前仍列出大型aggregate current documents；這是22-2與22-3前的interim route，不構成final minimal reading contract。
4. 沒有發現新的current-state capability衝突或App／Package boundary誤述。

### Verification

- `git diff --check`：Passed。
- stale phrase scan：Root README已無OTP／Biometric non-baseline衝突。
- credential authority scan：Auth README只在明確否定production authority的語境提及`SharedPreferencesAuthCredentialStore`。
- legacy path scan：所有九份legacy文件均在首段加入warning。
- scope scan：只修改Markdown；沒有production code、generated file、dependency或platform configuration變更。
- repository structure：沒有搬移、刪除或重新編號既有文件。

## Final Finding Disposition

| Finding | Severity | 22-1 disposition |
|---|---|---|
| M22-PR01 | P0 | Mitigated；legacy paths不可再被無警告地當成current authority，最終index／extraction留待後續phase |
| M22-PR02 | P0 | Not targeted；mandatory reading path收斂屬22-2 |
| M22-PR03 | P1 | Closed |
| M22-PR04 | P1 | Closed |
| M22-PR05 | P1 | Closed for interim routing；final hub屬22-2 |
| M22-PR06 | P1 | Not targeted；README coverage屬22-5 |
| M22-PR07 | P1 | Not targeted；Project Context rewrite屬22-3 |
| M22-PR08 | P1 | Not targeted；Roadmap separation屬22-4 |
| M22-PR09 | P1 | Not targeted；Decision extraction gate屬22-7與後續Milestone |

## Phase Conclusion

Milestone 22-1完成核准範圍。Current reader不再會從Root、Auth、Shell或未標示的legacy architecture paths直接取得已知錯誤的1.5.0能力與authority資訊。

下一階段可進入Milestone 22-2 — Documentation Index & AI Reading Contract。
