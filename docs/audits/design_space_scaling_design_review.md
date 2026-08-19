---
document_type: planning-review
status: accepted
authoritative_for:
  - design-space-scaling-design-review
last_reviewed_baseline: 1.25.2
---

# Design Review — Design-space Scaling / flutter_screenutil Integration

## Disposition

PASS。

## Review summary

- Requirement、scope、non-goals 與 Level 3 classification 一致。
- `flutter_screenutil` 被限制為 measurement engine，不取得 layout architecture authority。
- 已修正先前不合理的 property blacklist：`Positioned`、x/y、left/top 等只要是正確 design-space measurement 即可 scale。
- Layout review 改以 ownership / semantics 判斷，不以 widget 名稱判斷。
- Shared Design System token promotion 不取消 scaling；App 仍擁有 design baseline initialization。
- Typography / system text scaling 與 ADR-018 accessibility contract 未被覆蓋。
- Test disposition 明確為 temporary evidence，GREEN 後刪除。
- Write Precheck 不被夾帶 migration，避免 scope creep。

## Material integration risk

`DsRadius` 目前會在 `ArchitectureThemeBuilder` 建立 `ThemeData` 時被讀取。若 Design System token 改成 runtime scale，`ScreenUtilInit` 必須位於 ThemeData 建立之前；不得只放在 `MaterialApp.builder` 或 feature/page 層。

此 finding 已納入 Implementation Plan，無 Open P0 / P1。
