# Milestone 15-7 Theme Preference Implementation Plan

Status: Completed

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 在 App layer 建立可恢復、可持久化、可即時切換的 Theme Identity 與 Theme Mode，並提供最小 Appearance selector UI。

**Architecture:** Design System 只提供 Theme definitions 與 registry。App-local codec/store 使用單一 versioned JSON；ThemeController 先更新 runtime，再以單一 serialized queue 保存完整 snapshot。Bootstrap 在 `runApp` 前 restore，Shell 僅提供開啟 selector 的入口。

**Tech Stack:** Flutter、ChangeNotifier、InheritedNotifier、SharedPreferences、Design System Theme Registry。

---

- [x] 建立 `ThemePreference`、`AppThemeMode` 與 Version 1 JSON codec。
- [x] 實作整體 fallback、欄位級 fallback、read exception diagnostic 與不自動寫回。
- [x] Theme mutation 採 runtime-first，並以 serialized queue 保存完整 snapshot。
- [x] 寫入失敗不回滾 runtime，且不阻止後續較新寫入。
- [x] Bootstrap 在 `runApp` 前 restore preference。
- [x] `MaterialApp.router` 使用選中 Theme 的 Light / Dark ThemeData 與 ThemeMode。
- [x] App-level selector 可分別選擇 Theme Identity 與 mode；Shell 只提供入口。
- [x] 補上 persistence、controller、selector、workspace regression 與 bundle build tests。
