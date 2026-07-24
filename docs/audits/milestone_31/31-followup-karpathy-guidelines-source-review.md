---
document_type: phase-review
status: completed
authoritative_for:
  - karpathy-guidelines-adoption-source-evidence
last_reviewed_baseline: 1.13.0
---

# Karpathy Guidelines Skill Source Review

## Review scope

- Accepted Design：`docs/superpowers/specs/2026-07-25-karpathy-guidelines-adoption-design.md`
- Source repository：`https://github.com/multica-ai/andrej-karpathy-skills`
- Pinned commit：`2c606141936f1eeef17fa3043a72095b4765b9c2`
- Fetched files：`skills/karpathy-guidelines/SKILL.md`、`README.md`、`CLAUDE.md`

只在`/tmp/karpathy-adoption.BUKpRX/upstream`建立暫存clone並checkout固定commit；Task 1未安裝上游Skill，也未將上游`CLAUDE.md`寫入repository。

## Isolated execution evidence

- Worktree：`/Users/water/.devspace/worktrees/flutter_architecture-0ff9768c`
- Branch：`feat/karpathy-guidelines-adoption`
- Linked worktree：Yes；git dir位於主repository的`.git/worktrees/flutter_architecture-0ff9768c`。
- Base SHA：`973abf8bf844ff5b904f70afba6195d242508872`
- `main` SHA at start：`973abf8bf844ff5b904f70afba6195d242508872`
- Initial status：clean。
- Baseline validation：`python3 -m unittest tools.docs.test_check_docs`通過17 tests；`dart run melos run docs_check`通過。

目前已是外部建立的隔離worktree，因此依`using-git-worktrees`規則不再建立巢狀worktree。

## Reproducible source snapshot

暫存clone的`git rev-parse HEAD`輸出：

```txt
2c606141936f1eeef17fa3043a72095b4765b9c2
```

SHA-256：

```txt
6e22cc54cb02a5e98ae42d06d9d7292db0c1b43894831b32879beb0166b2aea7  skills/karpathy-guidelines/SKILL.md
daf314efb31894b86d68b67786c820bd8470bb2126e578ba9cd0e3e2667883f8  README.md
694a2d721e41c385f3db492838c23299826df5ba9809e3b0721aac70021e196a  CLAUDE.md
```

Source size：

| File | Lines | Words |
|---|---:|---:|
| `skills/karpathy-guidelines/SKILL.md` | 67 | 371 |
| `README.md` | 171 | 865 |
| `CLAUDE.md` | 65 | 358 |

## Source observations

上游Skill frontmatter包含：

```yaml
name: karpathy-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
license: MIT
```

正文包含`Think Before Coding`、`Simplicity First`、`Surgical Changes`與`Goal-Driven Execution`四項原則。Skill本身不呼叫外部工具、不要求credential或network，也沒有repository mutation命令；README另提供Claude plugin與直接寫入`CLAUDE.md`的安裝方式，但這些方式不屬本Pilot採用範圍。

## License evidence

- `SKILL.md` frontmatter宣告`license: MIT`。
- README的License段落寫明`MIT`。
- 固定commit的repository root及兩層範圍內沒有找到`LICENSE*`、`COPYING*`或`NOTICE*`檔案。

因此可記錄上游文字宣告MIT，但缺少獨立license file可供核對完整授權條款；本review不推論比現有證據更強的法律結論。Pilot只建立具provenance的受限制改寫，不鏡像整個repository。

## Focused review

- Pin與Design／Plan一致，且checkout結果精確相符。
- 上游四原則與預定Pilot責任相符，但原始「不確定就停止詢問」及「不處理不可能錯誤」若直接採用，可能違反repository的自動繼續、安全與必要error-handling規則；後續只能依RED證據做受限制改寫。
- 上游README的`CLAUDE.md`安裝法會形成平行入口，明確排除。
- Open P0：0。
- Open P1 without disposition：0。

## Validation

- `git diff --check`：Task 1 commit前fresh執行並通過。
