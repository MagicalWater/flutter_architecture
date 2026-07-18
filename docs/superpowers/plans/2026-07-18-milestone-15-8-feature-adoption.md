# Milestone 15-8 Feature Adoption Implementation Plan

Status: Completed

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 將 Protected、Profile 與 Login 頁面導入已完成的 Design System primitives，同時保持既有 Auth、Profile、Logout 與 Route Guard 行為。

**Architecture:** Page 保留既有 Bloc／router orchestration，將純呈現拆至可直接 widget test 的 view。Blocking page state 使用 Design System surfaces；正常內容與表單使用 constrained content、Typography、spacing、component themes 與 loading button primitive。

**Tech Stack:** Flutter、flutter_hooks、hooked_bloc、Design System package、Flutter widget tests。

---

### Task 1: Protected message surface

- [x] 以 `DsMessageState`、Typography 與 icon token 取代手寫 Column。
- [x] 保留 Protected route 與 AppBar 行為。
- [x] 更新 widget test。

### Task 2: Profile state surfaces

- [x] 將 unauthenticated、loading、blocking error 與 content 分支集中於 `ProfileView`。
- [x] 保留 requested、retry、logout 與 tab navigation 行為。
- [x] 補 state mapping、Theme、窄畫面與 2.0 text scaling tests。

### Task 3: Login form adoption

- [x] 導入 `DsConstrainedContent`、Typography、spacing 與 Theme InputDecoration。
- [x] 導入 `DsButtonContent` 並保留 disabled loading contract。
- [x] 使用 scrollable layout 支援鍵盤與大型文字。
- [x] 補 Dark/Ocean、keyboard inset、窄畫面與 2.0 text scaling tests。

### Task 4: Regression and documentation

- [x] 執行定向 tests、workspace analyze、完整 tests 與 development bundle。
- [x] 同步 Roadmap、Project Context、Architecture Decisions 與 Changelog。
