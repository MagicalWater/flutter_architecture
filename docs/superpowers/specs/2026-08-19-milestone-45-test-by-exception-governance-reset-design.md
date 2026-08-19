---
document_type: design-spec
status: accepted
authoritative_for:
  - milestone-45-test-by-exception-governance-reset-design
last_reviewed_baseline: 1.23.1
---

# Milestone 45 — Test-by-Exception Portfolio Reset & Development Governance Simplification Design

## 1. Design objective

將repository testing哲學從coverage-preservation改為**test-by-exception**：test是驗證工具，不天然是永久repository資產。永久test必須反向證明其長期failure-protection價值。

Canonical lifecycle：

```txt
change / bug / refactor
→ 是否需要automation幫助驗證？
→ 可選temporary test / focused runtime evidence
→ implementation GREEN
→ Retention Decision
   ├─ critical long-term owner → keep minimum permanent test
   └─ temporary / low-value / obvious / duplicated → delete before closure
```

## 2. Permanent-test admission

永久test只有在以下條件大致同時成立時才保留：

1. failure cost高或不可逆；
2. 人工／runtime快速檢查不容易可靠發現；
3. 有合理再發機率；
4. deterministic且失敗訊號能定位；
5. automation比人工長期成本低；
6. 沒有更便宜、更直接的owner；
7. fixture／mock／maintenance成本可接受。

典型永久owner：security／authorization／credential lifecycle、database migration／destructive persistence、concurrency／race／stale completion、retry／idempotency／ordering、核心business invariant、critical platform／release contract與極少量integration smoke。

以下預設不具永久資格：trivial widget rendering、copy／style、ordinary responsive/layout、framework behavior、getter／forwarding／passthrough、DI source shape、class/file ownership、architecture prose/static-source contract、documentation wording、mechanical golden、reference feature completeness、普通deterministic UI bug regression。

## 3. Test Authoring vs Test Retention

ADR-029 current `Required | Recommended | no-new-test justified | Should-not-add`保留「是否需要在change期間建立automation」的價值，但新增獨立Retention Decision：

```txt
Retain permanently
Delete temporary evidence
Merge into existing critical owner
Convert to smoke
```

`Required`不再自動代表永久保留；例如普通bug可先建立RED重現，但fix後若failure便宜可見、低風險或不值得長期維護，Retention Decision可刪除。

## 4. Deletion semantics

Milestone 30的replacement-preservation規則被stable policy supersede：

```txt
Delete critical protection
→ replacement owner/evidence required

Retire low-value protection
→ replacement = NONE is valid
```

Deletion reason可包含：low-value、temporary validation completed、manually obvious、cheaply observable、duplicate、framework-owned、architecture/document prose、style/copy/visual-only、maintenance cost exceeds detection value、historical regression no longer valuable。

不再要求逐case deletion manifest。Portfolio reset只保留**bucket-level disposition + critical keep matrix + before/after metrics**。

## 5. Foundation policy reset

刪除「Template foundation tests可合理高密度」作為保留理由。Foundation只代表更可能存在critical risks，不代表任何density quota或preservation exemption。Auth、Catalog、Profile必須與所有其他domain一樣逐組證明永久價值。

## 6. Portfolio target

Baseline：179 files／30,749 LOC／1,127 static cases。

Acceptance minimum：刪除>=80% files與LOC。

Stretch：刪除>=90%。

0～100% retention都合法；數字不是Keep理由。預估critical portfolio落在15～35 files、約3k～7k LOC、100～250 static cases，但實際以risk audit為準。

## 7. Portfolio disposition by domain

### Default Delete

- Widget/Page/Dialog rendering matrices。
- Theme／Locale／copy／style／ordinary semantics tests。
- Ordinary golden與visual-diff duplication。
- DI registration/source-shape tests。
- Architecture responsibility/source scanners。
- Documentation／Skill wording contracts。
- Pencil governance/static mapping contracts，除非它是唯一critical runtime acceptance owner。
- Framework/generator behavior與trivial serialization/forwarding。

### Keep minimum critical owners

- Auth：credential migration/corruption、refresh single-flight、token rotation、latest-intent/stale completion、authorization、OTP ordering、secret redaction。
- Database：migration、rollback、foreign-key/destructive compatibility、transaction atomicity、partial migration failure。
- Catalog：stale response/generation cancellation、append/refresh ordering、cursor cycle、dedupe/order、critical cache revision/rollback。
- CI/tooling：fail-safe selection、destructive cleanup safety、path traversal/symlink/lock、secret leakage、trusted-runner boundary。
- Platform：少量會真正阻止supported build/security contract drift的native checks。
- Integration：極少量核心runtime smoke。

## 8. Development governance simplification

Work classification改為**lowest sufficient level by evidence**，移除「模糊先升高」。只有具體security、irreversible persistence、public/stable cross-boundary、platform/release infrastructure等訊號才升級。

Task governance目標：

```txt
L0: change → relevant check
L1: change → focused validation → review
L2: brief design decision → implementation → one final review
L3: Design → Plan → implementation → one holistic review
L4/L5: only genuinely critical architecture/security/migration/release work使用formal evidence
```

不再要求每個implementation subtask建立獨立audit file、independent commit與whole-Task formal review。Critical findings可追加evidence，但artifact數不再與Task數成正比。

## 9. Validation simplification

`validation_planner.py`仍可保留為single selector，但contract簡化：

- ordinary source change：analyze + focused critical tests（若有）。
- UI/copy/style：analyze + runtime/manual/visual acceptance即可，無critical tests時合法0 test。
- shared/cross-boundary：affected critical owners，不自動跑所有feature tests。
- `VERSION` metadata change不自動變release full。
- `workflow_dispatch`不自動等價manual release；提供explicit focused/full/platform/release intent。
- full只供explicit release candidate、major dependency/validation-engine、真正高風險cross-cutting與explicit manual full。

## 10. Release evidence reuse

Same exact SHA：

```txt
candidate
→ one fresh logical full regression
→ required Android/iOS verification once
→ publish same SHA
→ verify published SHA / workflow / artifact identity
```

post-release不得因phase名稱不同再跑同一full source suite。只有source SHA、selected inputs、toolchain或artifact不同才需要fresh relevant validation。

## 11. CI simplification

Ordinary CI收斂為：

```txt
Quality
Critical Tests (when selected)
```

Android／iOS只有native change、explicit platform verification或release時啟動。Observability acceptance改為observability-related change／explicit staging acceptance／必要release trigger，不再成為所有main push/PR的固定execution surface。

Workflow YAML不再重複大量classification semantics；platform workflows只消費明確selection result。

## 12. Inventory simplification

Inventory不再要求每個test擁有大量taxonomy metadata。Reset後只需要：path、LOC、case count、permanent rationale／critical risk、runtime cost class。刪除後若portfolio已很小，inventory tooling本身可進一步退休或降為簡單report command。

## 13. Implementation strategy

1. 先改governance authority，解除replacement-test、foundation-density、permanent-regression與high-by-ambiguity bias。
2. 更新validation／release／CI contract，避免刪除過程仍被舊full/fresh規則拖住。
3. Zero-regret purge：UI、docs prose、architecture source scanners、goldens、DI/forwarding等。
4. Critical-owner collapse：Auth／Catalog／Observability／CI matrices縮成最小owner。
5. Database/platform/integration risk review，保留最小必要suite。
6. Fresh before/after inventory、runtime measurement與holistic review。

## 14. Design acceptance criteria

- current testing philosophy由preserve-existing改為permanent-test-by-exception。
- Temporary test具有正式delete-at-closure lifecycle。
- replacement=NONE合法。
- foundation exemption移除。
- no test-count minimum。
- governance classification與Task artifacts明顯簡化。
- VERSION／manual／same-SHA full duplication被移除。
- CI platform execution只在必要boundary觸發。
- Critical failure matrix仍有直接owner。

