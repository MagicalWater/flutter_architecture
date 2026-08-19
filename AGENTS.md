# AGENTS.md

本文件是 AI coding agent / assistant 的 repository hard-policy 入口。

專案 current authority 高於聊天紀錄與歷史記憶；historical spec、plan、audit、archive 只能按需追溯，不得覆蓋 current authority。

## Fresh admission

每次 fresh 進入 repository 固定只讀：

```txt
AGENTS.md
repository_identity.json
VERSION
```

接著依任務按需載入 authority；不要固定讀 `docs/project_context.md`、`docs/roadmap.md`、所有 ADR、audit、plan 或 guide。

常見 route：

```txt
一般開發／Bug／Refactor／Migration／Architecture／Release／治理
→ .agents/skills/governing-template-development/SKILL.md

Feature / Package
→ affected local README + related ADR/source/tests

Project-wide capability / active initiative / roadmap disposition
→ docs/project_context.md / docs/roadmap.md（只在需要時）

Historical investigation
→ docs/milestones/README.md / audits / completed plans / archive
```

## Development governance

任何會進入 Design、Plan、implementation 或 review 的 repository 工作，先使用：

```txt
.agents/skills/governing-template-development/SKILL.md
```

Skill 負責 Requirement Decision、lowest-sufficient Level 與必要 workflow/domain routing。不得直接用 TDD、brainstorming、writing-plans 或 debugging 跳過中央分類。

Level 0／1 不得虛構 Milestone、Spec、Plan 或 formal audit；Level 2 使用 brief decision + one final review；只有真正 cross-cutting / architecture / security / migration / platform / release risk 才升級 formal governance。

## 不可違反的 architecture / safety boundary

- Clean Architecture dependency direction：Presentation → Domain → Data → Infrastructure / External Service。
- App 是唯一 Composition Root；reusable package 不直接綁 `get_it` / `injectable`。
- Page 不跨 feature 直接讀其他 feature Bloc；跨 feature authority 使用 stable domain/app abstraction。
- Route Guard 不依賴 AuthBloc 等 presentation detail。
- Generated files（`*.freezed.dart`、`*.g.dart`、`*.gr.dart`、`injection.config.dart`）不得手改。
- Presentation responsibility / state ownership 以 ADR-032 為準；不要用固定 folder/class tree、line count、`setState` ban 或 Bloc presence 當 architecture oracle。
- UI Design Ownership 以 ADR-018 / ADR-028 與 local owner 為準；禁止建立 feature-local catch-all `*VisualSpec` / `*VisualTokens` / `*UiSpec` / `*StyleConfig` 形成第二套 Design System。

其他 architecture 細節一律按需讀 canonical ADR 與 affected local README，不在本入口重複維護。

## Testing / validation

永久 test 採 test-by-exception；temporary test 在 GREEN 後必須做 Retention Decision。完整 human semantics 只在 test authoring / retention in scope 時讀 `docs/guides/testing_governance.md`。

Validation selection 的 machine authority：

```txt
python3 tools/ci/validation_planner.py --event push --base <base-sha> --head <head-sha> --stdout-json
```

Agent 不得自行因「保守」升級成 full regression。Full 只在 planner-selected changed risk或genuine high-risk boundary要求時執行；explicit release只要求selected evidence fresh，不自行擴張validation scope。

## Domain routes

- Repository-local accepted `.pen` → Flutter：中央治理核准後路由 `implementing-pencil-flutter-design`。
- Template → Product repository bootstrap：符合 machine identity trigger 時路由 `adopting-template-repository`。
- Cross-platform product identity：符合 scope 時路由 `adopting-template-product-identity`。
- Production code implementation/refactor/review：在中央分類與必要核准後按需載入 `karpathy-guidelines`。

Domain Skill 不得重新擁有 Requirement Decision、Level、approval、release 或 closure authority。

## Documentation ownership

- Current rule 只能有一個 authoritative owner；其他文件只能短摘要 + link。
- Guide 擁有 procedure / examples，不擁有平行 workflow policy。
- Current snapshot / index 不得追加 closed Milestone journal、test counts、commit timeline 或 release evidence chronology。
- 新增或改變 stable architecture rule 時更新 canonical ADR；小型 bounded change 不為形式新增 ADR。
- 文件、README、註解與 commit message 預設使用繁體中文；技術識別保留英文。

## Commit / completion

Commit 前確認 planner-selected validation 已通過、必要 generated/build gate 已完成、文件與實作 authority 一致。使用 Conventional Commits，描述使用繁體中文。

一般 finding、test failure、implementation defect 或 stale document 直接修正並重新驗證；只有需要使用者決策、external/manual blocker、推翻 accepted Design/Plan 的 P0/P1，或完整 Milestone closure 才停止。
