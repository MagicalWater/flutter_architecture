---
document_type: design-spec
status: accepted
authoritative_for:
  - public-repository-readiness-security-privacy-design
last_reviewed_baseline: 1.17.0
---

# Public Repository Readiness — Security & Privacy Hardening Design

## 1. Goal

在不破壞歷史 audit traceability、不中斷其他平行需求、且不改變 GitHub visibility 的前提下，建立 `flutter_architecture` 在未來切換為 Public 前的最小充分安全基線。

本 Design 不把「公開 repository」誤解成「所有本機資訊都必須消失」。安全性與文件衛生分開處理：

1. 真正 credentials、provider config、signing material 必須 fail closed。
2. Public fork／PR 不得取得 privileged secrets 或把不可信程式碼送進 trusted self-hosted runner。
3. Current reusable guides應使用可移植 operator-neutral 範例。
4. Historical runtime／audit evidence可保留當時真實路徑，除非其中包含 credential 或高敏感資訊。

## 2. Accepted Privacy Boundary

### 2.1 Explicitly accepted public information

- Git commit author email `crazydennies@gmail.com`。
- Git author names如 `Water`、`MagicalWater`。
- Historical audit evidence中的一般 local usernames `crazy`／`water` 與 filesystem paths，只要它們不包含 credential、secret value、private key material或其他高敏感資料。

因此本工作**禁止**為了隱藏這些資料而 rewrite Git history 或批量改寫 historical evidence。

### 2.2 Information to normalize in current reusable documentation

Current guide、README或可複製 operator procedure若把個人路徑當成一般使用者固定值，例如：

```text
/Users/water/actions-runner/flutter-architecture
```

應改成 placeholder、environment variable或明確標示為 operator example，使其不形成錯誤 portability contract。

Historical audit／spec evidence如果只是描述「當時在哪執行」，原則上保留。

## 3. Secret & Sensitive-file Boundary

### 3.1 Prevent accidental future commits

Root `.gitignore` 應至少覆蓋 repository 不應追蹤的常見 private material：

- `.env` 與 environment-local variants，保留明確 template/example exceptions。
- Android keystore／signing material。
- Apple certificate/private-key exports。
- generic private-key files。
- Firebase／Google platform provider config（Android／iOS）。
- service-account credential files。

Pattern 必須避免把 repository 需要追蹤的 public fixtures、tests或 example templates 一併忽略；必要時採 allowlist exception。

### 3.2 Current-tree and Git-history scan

Public readiness review需分開檢查：

- sensitive filenames；
- high-confidence token／private-key patterns；
- provider configuration markers；
- known test fixtures。

Scanner命中不能僅靠字串決定 failure。Repository-owned security tests刻意包含假的 `gho_...` 與 private-key header，因此 review必須能區分 fixture與實際 secret candidate，避免「有測試 scanner 的 repo 永遠無法通過 scanner」。

若找到無法證明為 fixture的真實 credential candidate，Design立即 fail closed：不得切 Public，需先 rotate／revoke並視情況清理 history。

## 4. GitHub Actions Trust Boundary

### 4.1 Fork / pull request

來自 fork 或一般 `pull_request` 的不可信程式碼：

- 不得讀取 Firebase／provider repository secrets。
- 不得進入 protected environment secret job。
- 不得執行於標記為 trusted 的 self-hosted runner。
- `actions/checkout` 不應保留可寫 repository credential。
- Workflow token維持 minimum required permissions。

### 4.2 Trusted self-hosted execution

Self-hosted runner只允許 trusted context，例如 repository-owned `push` 到受保護 branch或人工 `workflow_dispatch`。若 expression 因 Public transition可能讓 PR context落到 self-hosted，必須修正並增加 executable contract test。

### 4.3 Privileged secret jobs

Firebase／remote observability acceptance等 privileged jobs必須維持明確人工或 trusted-event gate。Fork PR contract job只能驗證 workflow contract，不能因同一 workflow file存在 secrets references 就讀取 secrets。

## 5. Documentation Strategy

不做 repository-wide path replacement。採 ownership-aware cleanup：

- `docs/audits/**`：歷史 evidence，原則保留。
- historical `docs/superpowers/**`：保留當時 accepted/proposed evidence，除非它仍被 current guide直接複製為 operator instruction。
- `docs/guides/**`、root/app README：若為 current reusable instruction，個人 absolute path改為 placeholder／environment variable或清楚標記 example。
- Source／CI config：不允許依賴 operator-specific absolute path作 portability contract；如果只是 runtime variable default且已有跨平台策略，按現有 authority判斷。

## 6. Validation Design

### 6.1 Test Authoring Decision

Security failure mode若目前沒有直接 owner，新增 focused contract test是 `Required`；已存在完整 owner時則 `no-new-test justified`，不得為每個 pattern／workflow複製一份測試。

可能的 owner：

- secret ignore／leakage：既有 `tools/ci/test_secret_leakage.py` 或新的 narrow repository-hygiene test。
- workflow trust boundary：既有 workflow contract tests優先擴充。
- docs portability：既有 docs checker可表達穩定規則時才擴充；不為一次性字串 cleanup發明大型 scanner framework。

### 6.2 Validation Execution

每個 implementation Task完成後，以實際 base/head交給 `tools/ci/validation_planner.py`；依 planner輸出跑 Minimum Sufficient Validation。

Final readiness review另需：

- fresh tracked sensitive filename scan；
- fresh high-confidence secret candidate scan；
- workflow trust-boundary focused tests；
- docs check；
- `git status` clean（只針對此 managed worktree）；
- P0 = 0；undisposed P1 = 0。

## 7. Rollback / Recovery

- `.gitignore`／Guide／workflow contract hardening皆應用 ordinary Git commits，可直接 revert。
- 不 rewrite history，因此沒有 force-push recovery風險。
- 不切 visibility，因此這個 initiative失敗時 repository仍保持原 private state。
- 若發現真實 secret，停止 Public readiness；先 revoke／rotate，再另行決定 history remediation，不在本 initiative默認執行 destructive rewrite。

## 8. Non-goals

- 不在本 Design 中執行 GitHub `private → public`。
- 不設定 Branch Protection／Rulesets，除非 final review證明 Public 安全必須依賴某個尚不存在的 repository setting；那會形成新的 user-owned scope decision。
- 不改產品功能、API contract、native product identity或 Template-to-Product bootstrap。
- 不因 path hygiene重寫數百份 historical audit files。
- 不把假的 security fixture移除來讓 scanner「看起來乾淨」。

## 9. Acceptance Criteria

Design implementation完成時，必須能以 evidence回答：

1. Current tracked tree與reachable Git history是否存在未處置的真實 credential candidate？
2. 未來常見 `.env`、signing、provider credential是否有合理防誤提交 guard？
3. Fork／PR是否被隔離於 trusted self-hosted runner與privileged secrets之外？
4. Current reusable docs是否避免把個人 absolute path冒充通用固定路徑？
5. Historical audit evidence是否在無安全必要時保持不動？
6. 所有實際修改是否有 planner-selected validation與focused security evidence？

只有六項皆能回答 PASS，才可把「repository code/content ready for Public」列為 accepted；GitHub visibility本身仍需之後的獨立人工／tool action與fresh settings確認。

