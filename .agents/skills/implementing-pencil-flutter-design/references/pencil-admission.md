# Pencil Admission

## 前置gate

開始任何Pencil讀取前必須確認：

- managed worktree absolute path與branch正確。
- Manifest零issues，primary source位於worktree內。
- Runtime實際載入worktree-local orchestration／Taste Skills，same-name collision為0。
- `executor-local-mcp`與`pencil-session-mcp`可用；版本差異已有compatibility disposition。
- Current normal route為isolated session：每個conversation／client fresh `session_create`，保存自己的exact `sessionId`，並立即以`session_get_app_state`驗證active document identity後才可繼續。
- Visible Pencil Desktop／`pencil-local-mcp`不屬normal concurrent route；除非中央治理對特定single-client情境另有accepted disposition，不得把共享active-editor state當作fallback。

## 操作順序

1. 只以`pencil-session-mcp`對manifest指定的repository-local `.pen`建立isolated session。
2. Fresh `session_create`後，以該exact `sessionId`執行`session_get_app_state`確認schema／canvas／active target；scripts／browser保持關閉。
3. 驗證open document identity與pre-operation source hash。
4. Guidelines先無參數查詢，再只載入當前需要的`Code`與`Design System`指引。
5. 使用Pencil MCP inventory root frame、components、variables、text、layout、effects與unsupported constructs。
6. 需要改動或export時只透過Pencil MCP，完成後重新hash並更新manifest／evidence。

## 禁止fallback

`.pen`看起來像JSON也不得用Python、PowerShell、Dart、text editor、regex、native JSON parser或direct file mutation讀取／修改。Read-only parser同樣違反boundary，因為它繞過Pencil schema、runtime semantics與integration evidence。

Pencil unavailable、session建立失敗、document identity錯誤或tool failure時：

```txt
Task status: BLOCKED
Flutter implementation: NOT STARTED／STOPPED
Next action: repair Pencil admission or obtain governed disposition
```

不得改用visible Pencil Desktop／`pencil-local-mcp`共享active-editor state、PNG、OCR或過去記憶猜測structure。

Session lifecycle同樣受authority限制：conversation只可關閉自己持有的exact `sessionId`；不得kill broker、重啟bridge來清理其他conversation的live session，也不得替其他conversation執行`session_close`。

## Canonical export

Canonical comparison image必須由Pencil MCP直接從accepted root frame fresh export至manifest固定尺寸與DPR。不得upscale既有thumbnail、重新截圖外部檔案或以image editor補尺寸。Export後驗證dimensions、raw SHA-256與manifest，再進入Flutter mapping／implementation。
