---
document_type: phase-review
status: completed
authoritative_for:
  - adopting-template-product-identity-task-5-guide-authority
last_reviewed_baseline: 1.13.0
---

# Adopting Template Product Identity Task 5 Guide and Authority Review

## Task scope

本Task只在Native Environment Adoption Guide加入簡短Agent入口，並驗證Skill、Guide、ADR、manifest與verifier沒有形成重疊authority。

## Authority matrix

| Artifact | Sole responsibility |
|---|---|
| `AGENTS.md` | mandatory central governance entry |
| `governing-template-development` | classification、approval and Task routing |
| `adopting-template-product-identity` | optional trigger、input／scope safety and reading route |
| ADR-014 | Dart environment／API mode architecture |
| ADR-025 + `environments.json` | cross-platform identity mapping contract |
| Native Adoption Guide | complete procedure and exact commands |
| verifier／tests／build artifacts | mechanical and runtime truth |

## Focused review findings

### F1 — Guide entry可能複製Skill或觸發矩陣

- Severity：P1。
- Fix：Guide只加入一段入口、委派與authority聲明；未複製Skill input／stop rules。
- Fresh re-review：完整操作步驟與exact commands仍只存在Guide。

### F2 — Skill可能複製產品mapping

- Severity：P1。
- Search：Skill不含`com.example.flutterarchitecture`、default display-name表格或任何產品mapping值。
- Disposition：No open finding。

### F3 — Skill可能複製完整build command authority

- Severity：P1。
- Search：Skill只引用Guide路徑，沒有`flutter build`、`build_android_environment.sh`或`build_ios_environment.sh`命令block。
- Disposition：No open finding。

### F4 — Guide entry可能改變current environment contract

- Severity：P1。
- Review：只新增navigation text；manifest、native projection、verifier與tests均未修改。
- Disposition：以完整environment contract suite驗證。

### F5 — Local build command test used a POSIX filesystem assumption on Windows

- Severity：P1。
- RED：`test_local_ci_switch_entrypoint_exists`在Windows以`Path.stat().st_mode & 0o111`檢查executable bit，fresh suite固定失敗。
- Root cause：Git index正確保存`tools/ci/run_local_ci.sh`為`100755`，但Windows checkout使用`core.filemode=false`且NTFS `stat()`呈現`100666`；測試把POSIX filesystem mode誤當跨平台truth。
- Fix：Windows驗證Git index mode `100755`；非Windows維持實際filesystem executable-bit驗證。
- Fresh re-review：測試仍會捕捉script在repository中失去executable contract，且不再因Windows filesystem模型產生false failure。

## Whole-Task review

- Skill維持薄型，未成為procedure或mapping authority。
- Guide仍完整保存Android／iOS replacement order、API boundary、secret boundary與exact commands。
- ADR-014、ADR-025與`environments.json`ownership未改變。
- 本Task未宣稱新產品identity、Android artifact或iOS build已完成。

## Validation scope

本Task執行current verifier、environment contract、workflow matrix、local build command、iOS workflow與shell portability tests。結果只證明文件／Skill變更未削弱現有template projection contract，不是產品runtime acceptance。

依Testing Governance，本次只修正Platform／CI test的跨平台oracle，未新增、刪除、搬移或合併test scenario，不需要deletion manifest。

## Severity gate

- Open P0：0。
- Open P1 without disposition：0。
- Open P2 without disposition：0。
- Task 5 disposition：Passed after fresh contract validation。
- Next Task：Task 6 — Clean-checkout Discovery and Holistic Final Review。
