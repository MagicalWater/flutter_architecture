---
document_type: design-spec
status: accepted
authoritative_for:
  - generated-platform-owner-alignment-design
last_reviewed_baseline: 1.25.2
---

# Generated / Platform Validation Owner Alignment — Design

## Requirement Decision

### Request

修正Android Production workflow額外執行`verify_generated.sh`、但iOS platform workflow不執行的責任不一致，並確認generated consistency由誰主導。

### Problem

`verify_generated.sh`會執行Dart／Flutter repository-level code generation與Git tree consistency assertion；它不是Android build preparation。Current release fan-out同一exact SHA已由`CI / Generated Consistency`執行一次，但Android Production又重跑一次，形成重複authority與critical-path成本。iOS沒有同類重跑。

### Classification

Level 5 — release/platform validation contract。Scope bounded，不建立新Milestone。

### Decision

- `CI / Generated Consistency`成為唯一workflow-level generated consistency owner。
- Android與iOS workflow只負責platform build evidence，不內嵌repository-level generated consistency。
- Planner決定需要哪些evidence；orchestrator依plan組合CI／Android／iOS families。
- Platform workflow不需要知道其他workflow是否同步執行，也不得靠跨workflow偵測決定是否跳過generated。
- Standalone「完整platform validation」若需要generated evidence，應由上層orchestrator組合`CI + platform`，不把generated塞回platform workflow。

### Compatibility / rollback

- Android Development與iOS現有build contract不變。
- Android Production仍保留自身runner必要的dependency resolution與artifact verification。
- 若remote evidence顯示Android build實際依賴`verify_generated.sh`副作用，可直接rollback Android workflow removal；既有tracked generated source contract不變。

### Non-goals

- 不移除CI Generated Consistency。
- 不共享不同GitHub runner的`.dart_tool`／Pods／build cache。
- 不修改build-kind selection。
- 不新增新的classifier或generic orchestration framework。
