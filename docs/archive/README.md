# Archive

此資料夾存放已完成 milestone、歷史協作紀錄與舊版進度文件。

這些文件僅作為歷史參考，不代表目前 active roadmap 或目前開發進度。

目前repository的歷史artifact尚未全部集中至本目錄：部分Planning Review、phase review、final review與runtime evidence仍位於`docs/audits/`，implementation plan與spec仍位於`docs/superpowers/`。Milestone 22會先建立統一索引與authority，再分階段決定是否物理搬移；在manifest與link review完成前不得直接大量移動或刪除。

目前 current 文件請依 `docs/README.md` 與 `AGENTS.md` 的最小讀取契約選擇，不再從 Archive README 維護另一份完整必讀清單。

Current Roadmap：

- `docs/roadmap.md`
- `docs/roadmap/active.md`
- `docs/roadmap/candidates.md`

## Files

- `progress_v1.0.0.md`：Template 1.0.0 建立過程與 Milestone 1-8 的歷史紀錄。
- `milestone_14_offline_cache.md`：Milestone 14 Offline Cache 的封存摘要、完成範圍與驗證基線。

## Historical routing

```txt
Milestone 18
→ docs/audits/milestone_18_holistic_audit.md
→ docs/audits/milestone_18/

Milestone 19
→ docs/audits/milestone_19_planning_review.md
→ docs/audits/milestone_19/
→ docs/audits/milestone_19_holistic_final_review.md

Milestone 20
→ docs/audits/milestone_20_planning_review.md
→ docs/audits/milestone_20/

Milestone 21
→ docs/audits/milestone_21_planning_review.md
→ docs/audits/milestone_21/

Milestone 22
→ docs/audits/milestone_22_planning_review.md
→ docs/audits/milestone_22/
→ docs/audits/milestone_22/22-7_final_review.md
```

Milestone 1 至 17 與所有 closed milestone 的完整 routing 由 `docs/milestones/README.md` 統一管理。Roadmap migration disposition 位於 `docs/migrations/m22_roadmap_manifest.md`。

上述路徑是歷史 review／evidence 入口，不代表 active roadmap。Current baseline 仍以 `VERSION` 與 current project documentation 為準。

## Physical archive policy

Artifact 不需要因為 milestone completed 就立即搬進本目錄。只要 current index 能穩定導向、status 與 authority 清楚、historical artifact 不在 AI 最小讀取集，而且 link checker 可驗證 target，就可以保留原路徑。

未來若要搬移，必須先建立 migration manifest 與 transitional routing，禁止為了目錄整齊而一次大量搬檔。
