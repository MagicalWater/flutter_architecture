# Skill 採用治理

## 決策狀態

`Approved`、`Approved with restrictions`、`Pilot`、`Deprecated`、`Rejected`。

## Admission review

安裝或採用進 repository 前，記錄：

1. 已確認的 problem 與 expected value。
2. Trigger conditions 與 supported environments。
3. Inputs、outputs 與 repository mutations。
4. 與 Superpowers、此治理 Skill 及既有 domain Skills 的 overlap。
5. 是否建立或重複 authority。
6. External tools、MCP、credentials 與 network requirements。
7. Version／source pinning、update 與 rollback method。
8. Pressure scenarios 與 repository validation evidence。

## 放置規則

- 可重用的 Agent technique／orchestration：Skill。
- 不可違反的 repository policy：`AGENTS.md`。
- Stable architecture choice：ADR。
- 給人閱讀的治理總覽：`docs/governance/`。
- 可重用操作：`docs/guides/`。
- 可機械執行的規則：tests／CI／checker。

Skill 永遠不取代 repository authority、source、tests、CI、security policy、release gates 或 findings disposition。

## 語言規則

- Repository-local Skill 的 `SKILL.md`、references、範例與壓力測試文件預設使用繁體中文。
- Skill `name`、檔名、路徑、class／method／package 名稱、status values 與其他必要技術識別保留英文。
- 引用外部 Skill 時保留原始名稱、來源路徑、commit 與 license identity，但說明文字仍使用繁體中文。
- 翻譯 trigger、gate 或 safety wording 時，必須重新執行 focused adoption review 與相關 pressure validation，避免語意漂移。

## 升級規則

Trigger、artifacts、permissions、managed files、workflow order 或 supported agents 改變時，重新執行 adoption review 與 pressure scenarios。安裝更多 Skills 本身不代表更好；若能力已被覆蓋且沒有 confirmed gap，應拒絕該 Skill。

## Registry contract

每個已採用或已評估的 Skill，都要記錄 name、source、pinned version 或 commit、status、trigger、responsibility、forbidden responsibility、overlaps、companion Skills、repository mutations、required permissions、validation evidence、last review 與 rollback／upgrade policy。

## 重新驗證觸發條件

當 Skill 修改 trigger wording、artifact paths、managed files、permissions、workflow ordering、review／commit behavior、supported runtimes 或 automatic loading 時，重跑 focused adoption review 與相關 pressure scenarios。若更新會寫入 managed `AGENTS.md` 或引入平行 authority，沒有明確 repository decision 就不得接受。

## Rollback 與 deprecation

Pilot 與 restricted Skills 必須有移除路徑。Deprecation 必須記錄 replacement 或移除原因、移除 trigger wiring、驗證沒有 repository workflow 仍依賴它，並只保留必要 historical evidence。
