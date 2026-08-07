---
document_type: governance-policy
status: accepted
authoritative_for:
  - template-development-workflow-governance-overview
last_reviewed_baseline: 1.14.0
---

# Template Development Workflow Governance

## Purpose

本文件是人類可讀的治理總覽。可執行工作分類、artifact routing、Superpowers協作與雙層Task流程由repository-local Skill擁有：

- [`.agents/skills/governing-template-development/SKILL.md`](../../.agents/skills/governing-template-development/SKILL.md)

本文件不複製Skill完整矩陣，避免形成第二份executable authority。

## Responsibility model

```txt
AGENTS.md
→ 強制入口與不可違反policy

Workflow Governance Skill
→ Requirement Decision、Level 0～5、流程路由、雙層Task模式

Superpowers
→ brainstorming、planning、TDD、debugging、execution、review、verification

Repository artifacts
→ current truth、architecture decision、evidence、release與history
```

## Standard lifecycle

```txt
Idea／Bug／Request
→ Requirement Decision
→ Work Classification
→ Accept／Reduced／Defer／Reject
→ routed Superpowers workflow
→ routed Task governance
→ authority sync
→ validation／release／post-release as classified
```

Level 0／1使用minimal或simplified治理，禁止因流程本身而建立不必要的Spec、Plan或Milestone。Level 2～5依風險逐步要求Behavioral Requirements、Design、Plan、ADR、完整regression與release closure。

## Authority boundaries

- Skill不能取代`AGENTS.md`、ADR、Guides、source、tests、CI、VERSION或CHANGELOG。
- Design Spec擁有已核准需求行為與technical design；Implementation Plan擁有執行順序與commit boundary。
- Audit保存findings與evidence，不成為current state。
- 最後一個implementation Task通過不等於Milestone完成；release、push與post-release validation必須依分類完成。

## Skill adoption

新增Skill必須先做confirmed gap、overlap、authority、permission、version、rollback與pressure-scenario審查。Approved、Approved with restrictions、Pilot、Deprecated與Rejected disposition由Workflow Governance Skill reference定義。

Repository-authored Skill的`SKILL.md`、references、範例與pressure scenarios預設使用繁體中文；Skill名稱、檔名、路徑、status values與必要技術識別保留英文。翻譯trigger或gate wording後必須重新執行focused adoption review，不能把語言修正當成不需驗證的純排版變更。

Unmodified third-party Skill保留上游原始語言、結構與raw bytes。只有root `skills-lock.json`以immutable commit、exact install path、逐檔raw SHA-256、repository-local exact license bytes與license SHA-256完整驗證，且整份lock零issues時，對應Markdown才能豁免中文檢查。Path-only或name-only標示無效；任何managed bytes修改後即視為repository-maintained fork，重新適用repository-authored語言、identity與focused adoption governance。

`docs_check`會先執行ownership-aware Skill lock檢查，再把零issue的`third-party-unmodified` Markdown exact paths傳給語言checker。Missing file、unknown file、hash drift、path escape、duplicate install path、non-immutable commit、missing license或license hash drift都會fail closed並撤銷整份lock的所有豁免。Lock只擁有provenance／integrity，不擁有trigger、workflow、approval、Task、release或closure authority；這些仍由中央治理Skill、registry與accepted artifacts擁有。

### Adopted Skill registry

| Skill | Status | Trigger | Responsibility | Forbidden responsibility | Companion | Rollback |
|---|---|---|---|---|---|---|
| `governing-template-development` | Approved | 所有新需求、Bug、Refactor、Migration、Architecture、Release與治理工作 | Requirement Decision、Level 0～5、artifact／Superpowers／Task routing | 取代repository authority、source、tests、CI或release evidence | Superpowers | 移除`AGENTS.md` wiring前須先完成替代治理與pressure validation |
| `starting-feature-work` | Approved | 新功能、新畫面、user flow或Figma-driven implementation | 接收短feature brief並強制委派中央治理 | Level、approval、branch、Task、validation、release與closure policy | `governing-template-development` | 移除Skill與本registry row；中央治理入口不受影響 |
| `karpathy-guidelines` | Pilot／Approved with restrictions | 已完成分類與必要核准後的production code implementation、refactor與code review | simplicity、surgical changes、explicit assumptions與verifiable goals | Level、scope approval、branch、Task acceptance、release／closure；不得移除安全、migration、accessibility或validation evidence | `governing-template-development`＋routed Superpowers | 移除中央routing與`.agents/skills/karpathy-guidelines/`；中央治理不受影響 |
| `adopting-template-product-identity` | Approved | 已接受的跨Android／iOS模板產品identity或三環境display-name mapping採用 | 接收短input、authority routing、pre-inventory、manifest-first與evidence boundary | Level、approval、environment contract、signing、Store、release與closure | `governing-template-development`；只有實際進入production code／script implementation時才搭配`karpathy-guidelines` | 移除Skill、中央route、registry row與Guide entry；既有authority不受影響 |
| `implementing-pencil-flutter-design` | Pilot／Approved with restrictions | Accepted repository-local `.pen`要透過Pencil MCP映射為Flutter，且Design／Plan／worktree／manifest已通過 | Pencil admission、visual authority validation、structure extraction、Flutter mapping、TDD與visual acceptance orchestration | Requirement classification、Design／Plan acceptance、native `.pen` parsing、free redesign、fake layers、release／closure | `governing-template-development`＋`executor-local-mcp`＋`pencil-local-mcp`＋TDD／visual review Skills | 移除Skill、中央route、registry row與Pencil-to-Flutter Guide routing；accepted ADR／visual sources不受影響 |
| `brandkit` | Pilot／Loaded, non-triggered for accepted `.pen` proof | 只有明確要求建立或重新探索brand identity／brand-kit image時 | Brand strategy、logo metaphor與identity-board image direction companion | 已核准`.pen`的visual authority、Flutter architecture、Task approval、Pencil structure、implementation或release | `implementing-pencil-flutter-design`僅在未核准brand direction時按需路由 | 移除`.agents/skills/brandkit/`、lock row與registry row；不影響既有`.pen`或Flutter source |
| `high-end-visual-design` | Pilot／Approved with restrictions | 已核准visual authority進入高階visual critique，且中央workflow明確路由時 | Spacing、hierarchy、texture、surface與anti-generic critique companion | 其Web／React／Tailwind execution rules、font／icon bans不得覆蓋`.pen`、Flutter、Material、Accessibility、Localization、Design System或repository authority | `implementing-pencil-flutter-design`＋accepted visual authority | 移除Skill、lock row與registry row；保留accepted `.pen`與review evidence |
| `imagegen-frontend-mobile` | Pilot／Loaded, non-triggered for accepted `.pen` proof | 只有缺少visual authority並明確要求生成mobile screen images時 | Mobile image concept、multi-screen consistency與phone-mockup direction companion | Code generation、image-to-code、Pencil structure、Flutter architecture、Task approval或既有accepted `.pen`重設計 | `implementing-pencil-flutter-design`只在visual authority尚未核准時按需路由 | 移除Skill、lock row與registry row；不影響既有`.pen`或Flutter source |

#### Taste Skill immutable source admission

- Source repository：`https://github.com/Leonxlnx/taste-skill.git`。
- Immutable commit：`e988add20dab0fa97d7a76781c48961c8184288e`。
- License：MIT；exact repository-local bytes位於`third_party/skills/taste-skill/LICENSE`並由root`skills-lock.json`鎖定。
- Ownership：三份均為`third-party-unmodified`；repository不翻譯、不重寫trigger、不增加wrapper authority。
- Permissions：Skills本身不取得credential、filesystem mutation、network或MCP permission；實際image generation／Pencil／code tool仍由中央workflow與各自approved integration gate決定。
- Discovery：2026-08-04在managed worktree完成same-name collision RED control、fixture cleanup與fresh worktree-local GREEN；三份loaded path均位於worktree，collision count為0。
- `brandkit`與`imagegen-frontend-mobile`在本次accepted `.pen` proof不觸發；`high-end-visual-design`只可作restricted critique，不可把Web-specific absolute rules套用到Flutter。
- Upgrade trigger：commit、source path、license、任何managed byte、frontmatter trigger或runtime precedence改變時，重跑lock validation、collision pressure與focused adoption review。
- Last review：2026-08-04。
- Full evidence：`docs/audits/milestone_33/33-3_taste_skill_source_admission.md`與`33-3_taste_skill_discovery_pressure_evidence.md`。

#### Pencil workflow registry provenance／permission／upgrade extension

上方registry擁有status、trigger、responsibility、forbidden responsibility與rollback。下表補足Pencil workflow四個Skills的source、tool permission與upgrade gate；兩表合併才是完整adoption registry，不建立第二套trigger authority。

| Skill | Source | Permissions | Upgrade gate |
|---|---|---|---|
| `implementing-pencil-flutter-design` | Repository-authored；`.agents/skills/implementing-pencil-flutter-design/`，版本identity由Git＋review evidence保存 | Skill本身不取得credential、network或filesystem bypass；Pencil讀寫／export只能經中央workflow核准的`executor-local-mcp`→`pencil-local-mcp`，Flutter mutation仍受managed worktree／Task gate | Trigger wording、Pencil boundary、managed paths、permissions、workflow ordering、supported runtime、automatic routing或visual acceptance contract改變時，重跑focused Skill／pressure review |
| `brandkit` | Taste `e988add20dab0fa97d7a76781c48961c8184288e`，upstream `skills/brandkit`，install `.agents/skills/brandkit` | 無自動image generation、network、credential、Pencil或code mutation permission；只有中央workflow明確路由的brand exploration可使用對應tool | Upstream commit／path、license、managed byte、frontmatter trigger、install path或runtime precedence改變時，重跑lock、collision／discovery與focused adoption review |
| `high-end-visual-design` | Taste `e988add20dab0fa97d7a76781c48961c8184288e`，upstream `skills/soft-skill`，install `.agents/skills/high-end-visual-design` | 只有restricted visual critique；不得自行取得Pencil mutation、Flutter architecture、network、credential或image generation authority | Upstream commit／path、license、managed byte、frontmatter trigger、install path、runtime precedence或restricted boundary改變時，重跑lock、collision／discovery與focused adoption review |
| `imagegen-frontend-mobile` | Taste `e988add20dab0fa97d7a76781c48961c8184288e`，upstream `skills/imagegen-frontend-mobile`，install `.agents/skills/imagegen-frontend-mobile` | 只有visual authority尚未形成且Design明確要求candidate generation時，中央workflow才可授權image generation；無Pencil／Flutter code mutation或credential permission | Upstream commit／path、license、managed byte、frontmatter trigger、install path、runtime precedence或image-generation trigger改變時，重跑lock、collision／discovery與focused adoption review |

Exact逐檔hash與license hash只由root`skills-lock.json`擁有，不在本registry複製。可重複的Pencil-to-Flutter人類操作流程見[`docs/guides/pencil_to_flutter_workflow.md`](../guides/pencil_to_flutter_workflow.md)。

#### 2026-07-30 repository-local Skill language revalidation

- `governing-template-development`：Level 0～5、artifact routing、Design／Plan gate、雙層Task、stop／continue、Skill adoption與pressure protocol完成逐檔semantic review。
- `adopting-template-product-identity`：trigger／non-trigger、input gate、manifest-first、secret／signing hard stop與R1～R10完成review；過期restricted Pilot固定文字已修正為保留current registry status。
- `starting-feature-work`：short brief、central delegation、discussion-only與skip-governance pressure完成review。
- `karpathy-guidelines`：pinned source、subordinate routing、anti-overengineering、non-trigger與restricted Pilot boundary完成review。
- Mechanical evidence：`tools/docs/check_docs.py`加入`agent-skill-language`；英文-only description與reference body的RED tests已轉GREEN。
- Full evidence：`docs/audits/repository_local_skills_zh_tw_task_1_central_governance_review.md`至`repository_local_skills_zh_tw_task_5_language_governance_review.md`。

#### `adopting-template-product-identity` admission details

- Source：repository-original；無外部version pin。
- Overlaps：`governing-template-development`、`starting-feature-work`、`karpathy-guidelines`、`native_environment_adoption.md`；責任以中央治理與Guide authority切分。
- Repository mutations：Skill path、narrow central route、registry row、Guide entry與audit evidence。
- Permissions：不需要network、external credential、MCP或signing access。
- Validation evidence：Task 1 RED、Task 3 pressure validation、Task 5 authority review、Task 6 final review、remote clean-checkout discovery與2026-07-30 fresh isolated behavioral approval closure。
- Approval basis：未指定Skill名稱的discovery／discussion-only、明確跳過治理＋secret pressure，以及API-only non-trigger三個獨立新對話均通過。
- Last review：2026-07-30。
- Upgrade triggers：trigger wording、managed paths、permissions、workflow order、automatic loading或supported runtime變更。

### Feature shortcut

新功能或新畫面可只指定：

```txt
使用 repository-local starting-feature-work Skill。

[功能需求]
Figma：[網址，如有]
```

該Skill只是快捷入口；使用者不需要再同時指定`governing-template-development`，因為委派中央治理是快捷Skill的強制責任。其他工作仍可直接指定中央治理Skill並提供簡短自然語言需求。

完整跨Android／iOS模板產品identity採用也可只指定`adopting-template-product-identity`並提供簡短產品brief；該Skill必須先委派中央治理。API-only、visual-only、單一平台bounded repair、environment architecture、signing與Store工作仍由中央治理直接分類，不由此shortcut自動接管。

`karpathy-guidelines`不是使用者入口。中央治理在進入production code implementation／refactor／review後自動載入；純需求討論、Design／Plan核准、Level 0文件修正、roadmap與release closure不觸發。

Repository-local `.pen`到Flutter implementation可由中央治理在所有approval gates通過後自動路由`implementing-pencil-flutter-design`。使用者不需要同時指定Taste Skills；accepted `.pen`存在時imagegen不是normal route。Pencil MCP unavailable、runtime Skill collision、manifest drift或Design conflict都必須fail closed。

完整source／manifest layout、Skill pin與worktree-local discovery、Pencil admission、Flutter mapping、visual acceptance與copyable short prompt由[Pencil-to-Flutter Workflow Guide](../guides/pencil_to_flutter_workflow.md)提供；本治理總覽不複製其操作步驟。

完整日常使用情境、入口選擇與可直接複製的功能／畫面／除錯／測試失敗／Refactor／Migration Prompt，見[AI Agent協作開發快速使用指南](../guides/agent_assisted_development_quick_start.md)。該Guide只提供使用者操作範例，不複製或取代本文件與中央Skill的治理authority。

## Change policy

修改工作治理時，必須同時review：

1. `AGENTS.md`強制入口。
2. Workflow Governance Skill與references。
3. 本人類總覽是否仍準確。
4. Docs checker與pressure scenarios是否需要更新。
5. 是否影響既有Design／Plan／Task／release authority。
