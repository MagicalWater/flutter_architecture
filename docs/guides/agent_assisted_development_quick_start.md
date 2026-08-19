---
document_type: guide
status: active
authoritative_for:
  - agent-assisted-development-user-entry
last_reviewed_baseline: 1.25.0
---

# AI Agent 協作開發快速使用指南

本 Guide 只提供「怎麼開始一段工作」與可複製 prompt。Classification、approval、test retention、validation scope、release 與 architecture authority 不由本文件擁有。

## 新對話最短入口

Windows：

```txt
@bridge-win 請開啟：
D:\Developer\flutter_architecture

[直接描述需求]
```

macOS：

```txt
@bridge-mac 請開啟：
/Users/<user>/Developer/projects/flutter_architecture

[直接描述需求]
```

Fresh Agent 會依 `AGENTS.md` 自行完成最小 admission；不要在 prompt 複製 project context、roadmap、ADR 或歷史 Milestone。

## 入口選擇

| 工作 | 建議入口 |
|---|---|
| 新 feature / 新畫面 / user flow | `starting-feature-work` |
| Bug / Refactor / Migration / Architecture / CI / governance | `governing-template-development` |
| Discussion-only | 對應入口 + 明確寫「只討論，不修改」 |
| 首次 Template → Product | 直接提供新 repo path + product identity；Agent自行 routing |
| 已核准 repository-local `.pen` → Flutter | `governing-template-development`；通過 gates 後自動 route domain Skill |

`karpathy-guidelines`、Pencil domain Skill 與其他 companion 不需要使用者手動疊加；中央 routing 在適用時載入。

## 常用範本

### 新功能

```txt
請使用 repository-local `starting-feature-work`。

我要新增：
[功能]

預期行為：
[成功條件 / failure behavior]

限制：
[不做什麼]
```

### Bug

```txt
請使用 repository-local `governing-template-development`。

問題：
[實際行為]

重現：
[最短步驟]

預期：
[正確行為]

請先確認 root cause，再做最小修正；不要順便重構無關範圍。
```

### Refactor / 技術債

```txt
請使用 repository-local `governing-template-development`。

範圍：
[目前責任混雜 / coupling / performance problem]

目標：
[希望改善什麼]

限制：
- 不改外部行為，除非先取得明確 decision。
- 不建立沒有實際需求的 framework / abstraction。
```

### Architecture / Migration

```txt
請使用 repository-local `governing-template-development`。

我要評估：
[architecture / migration change]

要求：
- 先確認 scope、risk、compatibility / rollback。
- Design / Plan 需要時先完成並等我核准，不要直接 implementation。
```

### 只討論

```txt
本次只討論與評估，不修改 repository、不建立 branch / Design / Plan / commit。

[問題]
```

### Template → Product

```txt
@bridge-win 請開啟：
D:\Developer\<new-product-repo>

這是剛從 flutter_architecture template 建立的新產品 repository。

產品名稱：<name>
Base identifier：<com.example.product>
CI profile：manual-local | self-hosted | github-hosted
```

詳細 adoption procedure 見 `docs/guides/template_repository_adoption.md`。

### Accepted Pencil → Flutter

```txt
請使用 repository-local `governing-template-development`。

我要依 repository 中已接受的 `.pen` 實作 Flutter 畫面。
請確認 accepted Requirement / Design / Plan、managed worktree 與 visual manifest 後再進入 Pencil-to-Flutter domain route。
```

完整 procedure 見 `docs/guides/pencil_to_flutter_workflow.md`。

## 不要在 prompt 重貼的內容

- repository architecture 全文；
- fixed test / validation commands；
- closed Milestone history；
-所有 Skill 名稱與 references；
- Design / Plan review 規則全文。

Agent 應從 current authority 自行 routing。若必須靠使用者每次貼完整治理規則才能正確工作，代表 repository routing 本身有問題。

## Authority links

- Agent hard policy：`AGENTS.md`
- Central routing：`.agents/skills/governing-template-development/SKILL.md`
- Documentation taxonomy：`docs/README.md`
- Current architecture snapshot（按需）：`docs/project_context.md`
- Architecture Decisions：`docs/adr/README.md`
- Testing semantics：`docs/guides/testing_governance.md`
