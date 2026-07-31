---
document_type: design-plan-index
status: active
authoritative_for:
  - design-spec-and-implementation-plan-routing
last_reviewed_baseline: 1.14.0
---

# Design Specifications and Implementation Plans

`docs/superpowers/` 保存經討論形成的 design specification，以及核准後可執行的 implementation plan。

## Authority

- Spec 是核准設計、scope 與非目標的 artifact。
- Plan 是執行順序、檔案範圍、驗證與 commit 邊界的 artifact。

Spec 與 Plan 都不代表 implementation 已完成，也不取代 current snapshot、Architecture Decision、review evidence 或 release history。

## 目錄

```txt
docs/superpowers/specs/
  Design specifications

docs/superpowers/plans/
  Task-based implementation plans
```

目前最新計畫 routing：

- [`plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md`](plans/2026-07-31-template-baseline-1.14-project-holistic-audit.md)：Template Baseline 1.14.0 repository-wide整體總審查的proposed Execution Plan；定義A1～A9 exact evidence artifacts、validation、finding authority、commit boundaries與Audit Review Gate，未經使用者核准不得開始A1。
- [`plans/2026-07-30-milestone-32-ci-artifact-local-storage-cutover.md`](plans/2026-07-30-milestone-32-ci-artifact-local-storage-cutover.md)：Milestone 32 managed artifact store、workflow transport、retention／cleanup、runtime acceptance與GitHub storage cutover的accepted Implementation Plan；Tasks 1～11、1.14.0 release與post-release closure均已完成。
- [`plans/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery.md`](plans/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery.md)：對四個repository-local Skills繁體中文化補做Level 3 full two-layer Task governance、mechanical language gate與holistic remote closure；current execution進度見對應final review。
- [`plans/2026-07-30-adopting-template-product-identity-skill.md`](plans/2026-07-30-adopting-template-product-identity-skill.md)：薄型模板產品識別Skill的RED／GREEN、中央routing、Guide authority與clean-checkout計畫；Tasks 1–6原以restricted Pilot完成，後續fresh isolated behavioral evidence closure已將current registry狀態升級為`Approved`。
- [`plans/2026-07-25-karpathy-guidelines-adoption.md`](plans/2026-07-25-karpathy-guidelines-adoption.md)：primary-workflow recovery已完成，Karpathy companion目前為`Pilot／Approved with restrictions`；不依賴Ponytail，fresh isolated ChatGPT behavioral GREEN仍待平台能力。
- [`plans/2026-07-24-milestone-31-template-development-workflow-governance.md`](plans/2026-07-24-milestone-31-template-development-workflow-governance.md)：原計畫已降回`proposed`，等待Design Spec recovery核准後再進行Plan雙層review。
- [`plans/2026-07-24-milestone-30-test-suite-audit-rationalization-governance.md`](plans/2026-07-24-milestone-30-test-suite-audit-rationalization-governance.md)：Repository-wide test inventory、coverage ownership、production／historical boundary、controlled cleanup與execution governance。
- [`plans/2026-07-24-milestone-29-drift-persistence-migration.md`](plans/2026-07-24-milestone-29-drift-persistence-migration.md)：Drift整體遷移、historical compatibility、single-owner cutover與platform acceptance。
- [`plans/2026-07-23-milestone-27-production-observability-foundation.md`](plans/2026-07-23-milestone-27-production-observability-foundation.md)
- [`plans/2026-07-24-self-hosted-ci-execution-mode.md`](plans/2026-07-24-self-hosted-ci-execution-mode.md)：Task 27-7三種CI執行端、Mac self-hosted runner與closure實作計畫。

Milestone 30已完成release與post-release closure；Spec與Plan僅保留設計、執行順序與歷史追溯，不保存runtime pending狀態。

## Reading rule

執行某個 Milestone 或 phase 時，只讀該工作相關的 spec、plan 與 review；不要把所有歷史 plans 加入 AI 每次進入 repository 的必讀集合。

目前最新設計 routing：

- [`specs/2026-08-01-r1-current-authority-contradiction-closure-design.md`](specs/2026-08-01-r1-current-authority-contradiction-closure-design.md)：Template 1.14 holistic Audit核准後的R1有界current authority矛盾修復Design；只處理五個accepted findings，排除R2～R5、release、merge與push，Plan核准前不得修改current authority。
- [`specs/2026-07-31-template-baseline-1.14-project-holistic-audit-design.md`](specs/2026-07-31-template-baseline-1.14-project-holistic-audit-design.md)：Template Baseline 1.14.0 repository-wide整體總審查、能力分級、finding contract、A1～A9 evidence Tasks與A／B／C／D後續方向判定的accepted Design；不預設建立Milestone 33。
- [`specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md`](specs/2026-07-30-milestone-32-ci-artifact-local-storage-cutover-design.md)：Milestone 32本機artifact ownership、retention、capacity、GitHub transport、cleanup與runtime acceptance的accepted Design；1.14.0 release與post-release closure均已完成。
- [`specs/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery-design.md`](specs/2026-07-30-repository-local-skills-traditional-chinese-governance-recovery-design.md)：修復原Level 1分類不足，定義逐Skill semantic review、TDD language enforcement與holistic closure的Level 3治理設計。
- [`specs/2026-07-29-adopting-template-product-identity-skill-design.md`](specs/2026-07-29-adopting-template-product-identity-skill-design.md)：已核准的薄型模板產品識別Skill設計，保留中央治理、manifest／Guide authority與安全邊界；其Pilot upgrade conditions已由後續fresh behavioral evidence closure滿足。
- [`specs/2026-07-25-karpathy-guidelines-adoption-design.md`](specs/2026-07-25-karpathy-guidelines-adoption-design.md)：已核准的Pilot採用設計；執行期間因RED無confirmed gap而未啟用，最終Disposition見對應final review。
- [`specs/2026-07-24-milestone-31-template-development-workflow-governance-design.md`](specs/2026-07-24-milestone-31-template-development-workflow-governance-design.md)：已降回`proposed`並進行完整雙層review；既有實作不等於設計已重新核准。
- [`specs/2026-07-24-milestone-30-test-suite-audit-rationalization-governance-design.md`](specs/2026-07-24-milestone-30-test-suite-audit-rationalization-governance-design.md)：測試ownership、historical boundary、disposition evidence與execution tiers。
- [`specs/2026-07-24-milestone-29-drift-persistence-migration-design.md`](specs/2026-07-24-milestone-29-drift-persistence-migration-design.md)：Drift single-owner persistence、migration、opener與platform boundary。
- [`specs/2026-07-23-production-observability-foundation-design.md`](specs/2026-07-23-production-observability-foundation-design.md)：Production Observability Foundation scope、provider策略、platform／CI boundary與Task拆分。
- [`specs/2026-07-24-self-hosted-ci-execution-mode-design.md`](specs/2026-07-24-self-hosted-ci-execution-mode-design.md)：Task 27-7三種CI execution mode、trusted self-hosted runner與本機回退設計。

## Lifecycle

```txt
Draft / Proposed spec
→ Review and approval
→ Implementation plan
→ Phase implementation and review
→ Final review
→ Historical artifact
```

工作完成後，Spec 與 Plan 保留作為歷史與可追溯性證據，但 current state 必須回寫至其唯一 authority，而不是持續更新舊 Plan。
