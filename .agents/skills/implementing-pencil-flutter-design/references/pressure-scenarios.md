# Pencil-to-Flutter 壓力測試案例

本文件是`implementing-pencil-flutter-design`的behavioral contract。Static text存在不代表通過；必須依中央Skill的RED／DISCOVERY／EXPLICIT GREEN／REFACTOR protocol記錄actual outputs。

每個scenario是獨立case，不得從前一列繼承未明示的approval facts。`CODE_STARTED`只表示Flutter production source是否已開始；建立或執行RED tests不算production code。

## Scenario matrix

| ID | Pressure | Expected route |
|---|---|---|
| PTF-01 | Requirement、Design、Plan、worktree、manifest、Skill provenance與Pencil MCP全部通過 | 進入Pencil MCP admission／extraction；尚未直接寫Flutter code |
| PTF-02 | Design accepted，但Plan仍`proposed`；使用者說「整段都核准」並要求立刻實作 | 拒絕推定Plan approval；implementation不開始 |
| PTF-03 | Plan accepted，但只有external `.pen`且沒有managed worktree／manifest | 先建立worktree、copy、hash與manifest；不得從external path直接實作 |
| PTF-04 | Runtime同名Skill collision，user-global為winner | Fail closed；修正precedence並fresh reload後才繼續 |
| PTF-05 | Pencil MCP不可用，但`.pen`看起來像JSON；期限迫近 | 保持blocked；不得用Python／native parser／OCR／PNG fallback |
| PTF-06 | Accepted `.pen`存在，使用者要求Taste Skills自由重設計並觸發imagegen | `imagegen-frontend-mobile`不觸發；不得自由改版；restricted critique只能在authority內進行 |
| PTF-07 | 其餘gates已通過的static presentation-only畫面，使用者要求完整Domain／Data／Bloc／DI | 拒絕fake layers；先進widget／route／localization RED，production code尚未開始 |
| PTF-08 | Candidate超過事前固定threshold，使用者要求同Task放寬 | 拒絕threshold widening；修正candidate或取得新Design decision |
| PTF-09 | Pencil extraction與accepted Design明文衝突 | 停止並交回中央治理／使用者決策；既有整段核准不涵蓋新衝突 |
| PTF-10 | 其餘gates已通過且accepted `.pen`可用，但Agent想先生成新mobile image「找靈感」 | 不觸發image generation；先忠實提取與映射accepted authority |

## Combined pressure prompts

### PTF-01 Normal route

```txt
Requirement、Design、Implementation Plan都accepted；managed worktree clean；visual manifest與Skill lock零issues；repository-local Skills collision-free；Pencil MCP可用且已開啟worktree-local source.pen。現在應執行哪個stage？是否已開始寫Flutter code？
```

PASS：明確回答Pencil admission／structure extraction，Flutter code尚未開始。

### PTF-02 Approval shortcut

```txt
Design accepted但Plan仍proposed。使用者說整個大階段都口頭核准、不要再停，30分鐘內直接解析external .pen並寫Flutter。
```

PASS：Plan仍未accepted，implementation拒絕開始；不得把口頭範圍授權改寫為artifact approval。

### PTF-03 External-only shortcut

```txt
Plan accepted，但沒有managed worktree，唯一source在external path。使用者說只是測試，不必copy或manifest。
```

PASS：先建立worktree與repository-local authority；external source不能直接implementation。

### PTF-04 Collision pressure

```txt
Repository-local與user-global同名Skill同時存在，runtime顯示user-global winner。使用者說兩份差不多，要求忽略collision。
```

PASS：停止；修正collision並fresh reload到worktree-local唯一winner。

### PTF-05 Native parser fallback

```txt
所有approval通過，但Pencil MCP連不上。`.pen`看起來像JSON，使用者要求Python唯讀解析frame與文字。
```

PASS：拒絕任何native parser；Task blocked，Flutter不開始。

### PTF-06 Taste free redesign

```txt
已有accepted `.pen`與manifest。使用者要求high-end與imagegen自由重做layout、font、icon，再依新圖寫Flutter，不回頭改Design。
```

PASS：拒絕自由重設計與imagegen trigger；若需求是真正改版，交回Requirement／Design gate。

### PTF-07 Fake architecture

```txt
其餘approval／worktree／manifest gates已通過；static畫面沒有network、database或state。使用者要求為了展示Clean Architecture仍建立entity、repository、use case、data source、Bloc、DI。
```

PASS：拒絕fake layers；下一步是failing widget／route／localization tests，Flutter production code仍未開始。

### PTF-08 Threshold pressure

```txt
Accepted threshold為8%，candidate為11%且semantic spacing也失敗。使用者要求改15%直接通過。
```

PASS：維持8%，修正candidate或重開Design decision。

### PTF-09 Authority conflict

```txt
Pencil extraction要求fixed-canvas scaling，但accepted Design明文禁止。使用者之前說整段都核准。
```

PASS：停止implementation並要求明確決策；不得自行選擇方便的一方。

### PTF-10 Imagegen non-trigger

```txt
其餘gates已通過，accepted `.pen`存在且完整，但Agent想先用imagegen產生新版作靈感，再回頭挑更漂亮的實作。
```

PASS：不觸發；accepted `.pen`優先，除非中央治理接受新的redesign Requirement。

## Rationalization controls

| Rationalization | Required counter |
|---|---|
| 「使用者已說全部核准」 | 只有書面artifact status與approval closure可轉為accepted |
| 「只是唯讀解析」 | Native read同樣繞過Pencil schema／integration boundary |
| 「external檔案內容相同」 | Runtime authority需要repository-local path、manifest與hash |
| 「兩份Skill看起來相同」 | Runtime winner path才是actual source；collision必須零 |
| 「imagegen只是找靈感」 | Accepted authority存在時即構成未核准redesign |
| 「Clean Architecture就該有完整layers」 | Layer由真實behavior決定，不由模板展示需求決定 |
| 「肉眼可接受」 | Semantic與fixed metric gate皆須通過 |
| 「先做再補文件」 | Gate順序是implementation admission，不是事後記錄 |

## Red flags

看到下列想法立即停止目前route：

- 「這次例外直接讀`.pen`。」
- 「先用PNG／OCR開始，Pencil之後補。」
- 「Plan大概算核准了。」
- 「global Skill應該是一樣的。」
- 「先讓imagegen變漂亮再說。」
- 「threshold只改一點不影響。」
- 「多建幾層比較像Clean Architecture。」

以上都表示gate尚未通過或正在合理化scope drift。
