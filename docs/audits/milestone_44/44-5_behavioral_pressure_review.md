---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-44-task-44-5-behavioral-pressure-color-bounded-hardening
last_reviewed_baseline: 1.22.0
---

# Milestone 44 — Task 44-5 Behavioral Pressure / Same-Semantic Color Review

## Scope

本Task讓future Pencil→Flutter consumer Agent能區分component-local fixed-canvas laundering與合法bounded spatial overlay，並驗證same-semantic color reconciliation不會膨脹成Theme/Design System production refactor。

本Task沒有修改production Flutter UI、Theme／Design System production source，也沒有新增Flow/Coordinator framework、mandatory `flows/`或新的Presentation/Color governance Skill。

## Authority changes

- `pressure-scenarios.md`新增PTF-47～58，逐一對應accepted Plan的12個required fresh pressure cases；
- `flutter-mapping.md`補same-semantic color固定decision order，並維持bounded component normal-content relationship ownership；
- human guide只補相同兩個bounded rules，沒有建立第二套authority；
- `test_presentation_responsibility_policy.py`加入scenario coverage與mapping/guide consistency assertions。

## Test Authoring Decision

**Required, policy-owner extension only**。本Task修改consumer Skill/reference behavioral contract，因此既有docs policy owner增加最小static assertions；不新增重複Agent harness或Flutter runtime tests。Static Markdown／keyword test不能取代fresh isolated-agent behavior，所以另外依`docs/guides/skill_behavioral_validation.md`執行production ChatGPT Web fresh contexts。

## Fresh behavioral method

Production route：

```txt
chatgpt-web-generation.org.default.generate_chatgpt_web_generation
surface = chat
result_policy = image_or_text
```

每個正式scenario使用獨立fresh ChatGPT Web context；prompt只描述情境與要求architecture verdict，不提供repository預期答案。

第一次PTF-47 discovery call沒有傳`result_policy=image_or_text`，雖取得文字reply，但wrapper回`IMAGE_GENERATION_INPUT_REQUIRED` error；依protocol不計verdict，改以另一fresh context重跑。PTF-48第一次response過長且含一段generic screen-canonical ownership措辭，review不把該泛化升格為repository authority；正式verdict使用另一個5句fresh rerun。

## PTF-47 — Bounded component fixed-canvas laundering

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：screen root 已用 Column 與 section flow，但每個 bounded Card、Step、Button 內的普通 Text、DataRow、button label 仍全部依設計稿 canonical x/y 用 Stack + Positioned 排列。這樣是否合理？為什麼？
```

Actual response：

> 不合理：root 用 Column 只解決 section 層級的 flow，不代表內部 bounded component 已具備 responsive layout。 在 Card、Step、Button 內把普通 Text、DataRow、button label 以 canonical x/y 固定 Stack + Positioned，本質上仍是 pixel-positioned layout，容易在文字長度、字體、螢幕寬度、localization、accessibility text scaling 下失效。 正確 ownership 應是：parent 負責 component 的排列與尺寸約束；component 自己負責內部 semantic/content layout，優先使用 Row、Column、Flex、Expanded、Flexible、Wrap 等 constraint-driven primitives。 Stack + Positioned 應保留給真正需要 overlay／裝飾／非流式定位的元素，而不是一般文字與資料欄位。 因此目前是「外層 responsive、內層仍 fixed-layout」，production architecture 不應以此宣稱完整 responsive。

Verdict：**PASS**。

## PTF-48 — Public left/top component API

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：Reusable InfoRow 公開 labelLeft、labelTop、valueLeft、valueTop，screen 直接把設計稿 canonical 座標傳進來；作者認為 component 有 local bounds，所以這種 public coordinate API 不算 fixed-canvas。這樣合理嗎？正確 ownership 是什麼？
```

Actual response：

> 不合理：即使 InfoRow 有 local bounds，只要 public API 接受 screen/design canonical 座標，它本質上仍把 screen-owned geometry 洩漏進 component contract，屬於 fixed-canvas coupling 的變體。 正確 ownership 是 Screen/Layout 層決定 canonical 座標與外部排版位置，InfoRow 只擁有自身 local layout（padding、label/value arrangement、intrinsic size）。 InfoRow 應接收語意化的 content/state 與必要的 layout configuration，而不是 labelLeft/Top/valueLeft/Top 這類絕對位置。 如果確實需要可調整間距，應暴露 EdgeInsets、gap、alignment、constraints 等 local/layout tokens，由 screen 以 canonical design system constraints 組合。 因此，「有 local bounds ≠ 可以公開 screen coordinates」；coordinate ownership 應留在 screen/layout parent，而 component ownership 應限於 local geometry。

Verdict：**PASS core ownership**。Fresh Agent對「component不可公開screen/canvas coordinates」判定正確；其generic「screen決定canonical座標」措辭不覆蓋ADR-028，一般App screen仍不得把canonical page x/y當runtime placement model。

## PTF-49 — Generic positioned-text engine

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：為避免重複碼，作者建立 `_localText(text,left,top,width,height,...)` 與 `_positionedIcon(...)`，所有 Card、Header、Button 的普通內容都透過這些 helper 排版；整個 screen 只有一套 renderer。這種做法是否合理？
```

Actual response：

> 不合理，production architecture 上這是在用「座標 renderer」抽象化重複碼，而不是建立正確的 layout abstraction。 _localText()、_positionedIcon() 只是把 Stack + Positioned 的問題集中起來，並沒有解決內容尺寸、文字換行、accessibility、不同螢幕尺寸與 dynamic content 的適應性。 「整個 screen 只有一套 renderer」也不代表架構更好，反而會讓 Card、Header、Button 的 layout ownership 全部耦合到同一套 canonical 座標系。 正確 ownership 應由各 bounded component 自己負責內部 layout，普通內容優先使用 Row、Column、Wrap、Padding、Align、Expanded/Flexible 等 constraint-based layout。 只有真正需要像素級重疊、背景裝飾或固定視覺 artwork 的局部區域，才適合由 Stack/Positioned 或專用 renderer 擁有座標。

Verdict：**PASS**。

## PTF-50 — Relationship-owned DataRow

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：DataRow 用 Row 放 icon、label、value；label/value 用 Expanded、Align、Padding 與 sibling gaps 分配空間，沒有 public left/top。這種 normal-content layout 是否合理？需要注意什麼？
```

Actual response：

> 合理，這是典型且推薦的 normal-content / intrinsic layout，由 Row、Expanded、Align、Padding 與 gap 共同決定內容流，不暴露螢幕座標。 正確 ownership 是 DataRow 負責內容的相對排列規則，screen 負責提供資料與語意，不負責 pixel placement。 Expanded 的使用要注意文字長度與極端螢幕寬度，避免 label / value 互相擠壓或 overflow。 另外應明確定義 label 與 value 的 flex、alignment、min/max constraints，避免不同 DataRow 自行產生不一致的 column geometry。 只要沒有把 left/top/x/y 之類的 canvas 座標變成 public API，這個 production architecture 是合理的。

Verdict：**PASS**。

## PTF-51 — Legal Hero overlay

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：Hero section 由 screen Column 正常放置；Hero 文字內容用 Padding + Column，只有背景 glow、badge、orbit、shield artwork 在 Hero bounds 內用 Stack + Positioned 疊層。是否應該把這些 Positioned 全部改掉？
```

Actual response：

> 不需要全部改掉，這種 ownership 是合理的 production architecture。 Hero 的文字屬於正常 document/layout flow，應由 Padding + Column 決定尺寸與位置；背景 glow、badge、orbit、shield artwork 則是 Hero 內的視覺疊層，使用 Stack + Positioned 很合適。 關鍵是 Positioned 只負責裝飾性/視覺定位，不要拿來排普通文字、資料列或互動內容。 因此這裡應保留 Stack，並讓 Hero component 自己 ownership 這些 bounded decorative layers；只有當 artwork 本身需要隨內容高度流動時，才考慮改用其他 layout。

Verdict：**PASS**。

## PTF-52 — Blanket Stack ban

Exact prompt：

```txt
請只做 Flutter production architecture review 判斷，不修改任何檔案，回答控制在 5 句內。情境：Reviewer 看到 production source 還有十多個 Stack/Positioned，就直接判定失敗並要求全部改成 Row/Column，沒有區分 normal content、decorative glow、badge、ornament 或 artwork。這個 review 方法合理嗎？
```

Actual response：

> 不合理；Stack/Positioned 的數量本身不是 production architecture 的失敗條件。 應先依 ownership 與用途區分：normal content 應優先用 Row/Column/Flex/Align/Padding，而 decorative glow、badge、ornament、artwork、overlay 等本來就合理使用 Stack/Positioned。 真正該 review 的是：是否存在可避免的 fixed-coordinate content layout、是否破壞 responsive/adaptive behavior，以及元件是否把座標細節錯誤暴露給 screen。 因此「看到十多個就全部改掉」是形式審查，不是有效的 Flutter production architecture review。

Verdict：**PASS**。

## PTF-53 — Line-count splitting oracle

Exact prompt：

```txt
請只做 Flutter production architecture review 判斷，不修改任何檔案，回答控制在 5 句內。情境：一個 cohesive presentation owner 約 420 行，包含同一 change reason 的 private helpers；Agent 設定「超過 300 行必拆檔」，因此要求每個 widget 各拆一檔。這能當 architecture rule 嗎？
```

Actual response：

> 不能，「超過 300 行必拆檔」不應單獨成為 production architecture rule。 420 行本身不是問題；若這 420 行仍由單一 cohesive presentation owner 負責、private helpers 都服務同一 change reason，強制「一 widget 一檔」反而會破壞 locality、增加跨檔案理解成本。 正確的拆分依據應是 ownership、change reason、reusability、testability 與責任邊界，而不是單純 LOC。 300 行最多只能作為 review signal / smell threshold，超過後要求檢查 cohesion，而不是自動拆檔。

Verdict：**PASS**。

## PTF-54 — Generic Flow framework inflation

Exact prompt：

```txt
請只做 Flutter production architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：目前畫面沒有多步 workflow、async ordering 或跨 surface coordination，但 Agent 說 Presentation 治理完整就必須新增 Flow/Coordinator base class 與 `features/*/presentation/flows/` 資料夾。這樣合理嗎？
```

Actual response：

> 不合理；Production architecture 應由實際的 workflow、async ordering、跨 surface coordination 等複雜度驅動，而不是為了「治理完整」預先建立抽象。 目前沒有這些需求時，強制 Flow/Coordinator base class 與 presentation/flows/ 只會增加 ceremony、indirection 與維護成本。 Presentation 治理可以先以清楚的 screen/state/widget ownership、dependency boundaries 與可測試性為主。 等真正出現多步流程或 coordination complexity 時，再引入具體且有用途的 Flow/Coordinator abstraction 才合理。

Verdict：**PASS**。

## PTF-55 — Same-semantic RGB drift duplication

Exact prompt：

```txt
請只做 Flutter UI ownership / Design System architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：Login、Home、Checkout 的 primary CTA 被 accepted product design 定義為同一 semantic role；Pencil extraction 分別得到 #3DAEFF、#3CAEFE、#3DAEFE 的小幅 RGB 差。Agent 因此想在三個 feature 各自建立 local CTA color。這樣合理嗎？
```

Actual response：

> 不合理；既然三個 CTA 已被 accepted product design 定義為同一 semantic role，RGB 微差不能成為建立三份 feature-local token 的理由。 正確 ownership 應在 Design System／shared theme 層定義單一 primary CTA semantic token，Login、Home、Checkout 只引用它。 Pencil extraction 的 #3DAEFF／#3CAEFE／#3DAEFE 應視為量測或取色誤差，除非 product design 明確宣告它們是有意的 state／context variation。 若實際需要不同視覺值，也應先提升為有命名語意的 shared variant，而不是各 feature 私有化。

Verdict：**PASS**。

## PTF-56 — Near-identical literals, different semantics

Exact prompt：

```txt
請只做 Flutter UI ownership / Design System architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：Informational card border 是 #5A7184，disabled decorative ornament 是 #5B7083；兩者 raw color 很接近，但產品語意與 change reason 明確獨立。是否應合併成同一 Design System color token？
```

Actual response：

> 不應合併成同一 Design System color token。 Token ownership 應以語意與 change reason為主，而非 raw color 是否接近；Informational card border 與 disabled decorative ornament 的產品責任不同。 即使目前值分別是 #5A7184 與 #5B7083，也應維持兩個 semantic token。 未來若兩者需要同步變更，應先證明它們具有相同 semantic ownership，再考慮合併，而不是因色值接近而提前耦合。

Verdict：**PASS**。

## PTF-57 — Intentional component-local decorative color

Exact prompt：

```txt
請只做 Flutter UI ownership / Design System architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：只有一個 Hero ornament 使用 accepted exact #C88A32，沒有第二 consumer、沒有 Theme Identity 語意，也不會與其他 component 共同演進。是否應新增 global Design System token？
```

Actual response：

> 不應新增 global Design System token。 這是單一 Feature Hero 的局部視覺常數，沒有跨 component 的共同語意、consumer 或共同演進理由，ownership 應留在該 Feature。 直接使用 feature-local constant / style 定義即可。 只有當第二個以上 consumer 出現相同語意且需要一致治理時，才有理由提升為 Design System token。

Verdict：**PASS**。

## PTF-58 — Theme/Design System scope creep

Exact prompt：

```txt
請只做 Flutter UI ownership / Design System architecture 判斷，不修改任何檔案，回答控制在 5 句內。情境：目前只發現 Pencil 同一 semantic CTA 有少量 RGB drift，production 沒有 Theme misuse 或 public token 缺陷證據。Agent 要求趁機重構整個 Theme/Design System color API 與所有 consumer。這樣合理嗎？
```

Actual response：

> 不合理，這屬於以局部視覺 drift 為由擴大 ownership scope，證據不足。 目前應先把同一 semantic CTA 的 canonical token / semantic role 對齊，而不是趁機重構整套 Theme/Design System API。 既然 production 尚無 Theme misuse 或 public token 缺陷證據，就不應要求所有 consumer 一併改動。 合理的 production architecture 是最小修正、維持既有 Design System contract，只有被證實有問題的 consumer 才調整。 下一步可先確認 CTA semantic token 的唯一 ownership 與 Pencil drift 是否只是 extraction noise。

Verdict：**PASS**。

## Layer 1 — Focused review

- PTF-47～49直接拒絕bounded component fixed-canvas laundering；
- PTF-50接受relationship-owned normal data row；
- PTF-51接受Hero bounded spatial overlay；
- PTF-52拒絕blanket Stack/Positioned ban；
- PTF-53拒絕line-count architecture oracle；
- PTF-54拒絕generic Flow/mandatory folder formalism；
- PTF-55拒絕same-semantic RGB drift拆成多個feature owners；
- PTF-56拒絕只因raw value接近就錯誤合併不同semantics；
- PTF-57保留single-component intentional decoration在smallest owner；
- PTF-58拒絕沒有production misuse evidence的Theme/Design System scope creep。

Focused behavioral review：**PASS**。

## Fresh focused re-review

Fresh policy/docs validation：

```txt
python -m unittest discover -s tools/docs -p "test_*.py"
→ 101 tests PASS

dart run melos run docs_check
→ PASS

git diff --check
→ PASS
```

Fresh re-review確認：PTF-47～58與consumer mapping/human guide使用同一stable semantics；沒有新增parallel authority、generic Flow framework、Theme/Design System production refactor或production UI修改。PTF-48 fresh response中的generic screen-coordinate措辭已明確以ADR-028 ceiling disposition，不形成authority drift。

Fresh focused re-review：**PASS**。

## Layer 2 — Whole-Task review

```txt
Task 44-5 = accepted
Open behavioral P0 = 0
Open behavioral P1 without disposition = 0
Next = Task 44-6 holistic final review / release disposition
```

## Validation planner

Validation snapshot：`6db6a532aa0da9cb53f40cc33dac9a0855773f40`，base：`1470240746f2378fcc670d29ea72873fdeb3b9b2`。

Planner result：

```txt
change_classes = docs_content, governance, test_only
validation_level = focused
docs_check = true
python_test_scopes = tools/docs, tools/docs/test_presentation_responsibility_policy.py
full_regression = false
android_build = false
ios_build = false
fail_safe = false
```

Planner-selected fresh validation與本Task behavioral evidence均PASS；沒有open P0/P1。
