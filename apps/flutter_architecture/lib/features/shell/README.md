# Shell Feature

Shell feature 負責 App 的外層框架。

## 負責什麼？

- AppBar
- BottomNavigationBar
- Login / Profile 的 nested route 容器
- ProtectedPage 的入口按鈕

## 頁面關係

```txt
ShellPage(A)
  ├── LoginPage(B)
  ├── ProfilePage(C)
  └── ProtectedPage(D)
```

LoginPage 與 ProfilePage 是 ShellPage 的內層頁面。

ProtectedPage 是獨立頁面，透過 AppBar action 開啟。
