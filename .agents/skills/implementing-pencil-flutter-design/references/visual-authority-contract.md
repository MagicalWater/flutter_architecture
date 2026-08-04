# Visual Authority Contract

## Source ranking

```txt
repository-local .pen               → primary structural／visual authority
Pencil renderer preview             → derived evidence
original PNG                        → supplementary intent reference
historical Flutter screenshot       → benchmark only
runtime screenshot／golden／diff     → implementation evidence
```

只有manifest的`primary-source`可標記`primary`。不同roles不得共享同一physical file。

## Admission

執行前必須以`tools.visual.verify_visual_authority.verify_visual_authority()`或repository `docs_check`確認：

- Manifest位於`docs/visual_authority/<initiative>/manifest.md`。
- `authority_file`位於repository內且與primary row一致。
- Required roles唯一、paths不escape、files存在、raw hashes一致。
- Canonical width、height、DPR為positive finite values。
- Benchmark沒有被提升為primary。

## External source denial

External filesystem path只可作一次性admission input。Copy與destination hash驗證完成後，後續Pencil、Flutter與visual validation只可使用managed worktree內source。不得因external檔案「已核准」或「內容相同」跳過repository copy、manifest或hash。

## Drift與supersession

- Derived preview更新：同一Task更新file、hash與review evidence。
- Primary `.pen` hash改變：先分類source drift；必要時重開Design／Plan。
- Manifest與file不一致：Task blocked；不得只改hash掩蓋未審查內容。
- Accepted `.pen`與Design衝突：交回中央治理與使用者決策，不自行選擇較方便的一方。
