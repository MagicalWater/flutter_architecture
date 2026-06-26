# Protected Feature

Protected feature 示範需要登入才能開啟的頁面。

## 負責什麼？

- 顯示受保護頁面內容
- 驗證 Route Guard 是否正常運作

## 不負責什麼？

- 判斷是否登入
- 導回 LoginPage

這些責任屬於 `AuthGuard`。

## Runtime Flow

```txt
AppBar action
  ↓
ProtectedRoute
  ↓
AuthGuard
  ↓
已登入：進入 ProtectedPage
未登入：導回 LoginPage
```
