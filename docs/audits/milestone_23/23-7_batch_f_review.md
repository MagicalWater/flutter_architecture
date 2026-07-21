---
document_type: phase-review
status: accepted
authoritative_for:
  - milestone-23-task-23-7-batch-f-review
last_reviewed_baseline: 1.5.1
---

# Milestone 23-7 — Batch F Authentication Security Umbrella Review

## Scope

本 Task擷取 ADR-022，完成 ADR-015／022 credential-storage scope的 reciprocal supersession，並更新 migration-aware index與 manifest。Aggregate `docs/architecture_decisions.md`正文保持不變，正式 authority尚未 cutover。

## ADR-022 Section Disposition

| Aggregate section | Disposition | Canonical result |
|---|---|---|
| Status／implementation status／baseline | route evidence | 不進 ADR body |
| Capability split | retain/normalize | secure credential、OTP、local unlock三種獨立能力 |
| Milestone sequencing | remove journal | 只保留 capability dependency與 scope separation |
| M19 credential boundary | retain | secure authority、legacy identity、fail-closed migration、App plugin ownership |
| M20 OTP boundary | retain | typed union、challenge replacement、OTP前不建立 Session、latest-intent |
| M21 local unlock boundary | retain | user-presence gate、locked Session null、fail closed、App coordinator |
| Package／App responsibility | retain | pure Dart narrow abstraction、App-owned adapters與 Composition Root |
| Planning supplement details | route evidence | audit／plan持有；只保留已成為 durable contract的規則 |
| Review gates／dates／version rules | route governance/history | 不進 ADR body |
| Final decisions／test findings | route audits/CHANGELOG | 不進 ADR body |
| Security non-goals | retain/normalize | 不宣稱 Device Binding、provider／rooted-device／server compromise defense |

## Security Semantic Review

- Credential-at-rest、server authentication與 local device access control沒有互相冒充。
- OTP pending與 locked startup皆維持 `SessionManager` unauthenticated。
- Secure read operational failure不被降級為 absence；corruption與 identity mismatch採 fail closed。
- OTP challenge只保存 opaque identity與 server metadata，不持久化 OTP code。
- Biometric只表達本機 user presence，不擴張為 Device Binding或 server authentication。
- Package contract不暴露 plugin／native type；App仍是唯一 Composition Root。
- Android以外平台沒有因 dependency存在而被宣稱 runtime supported。
- Password、OTP、Token與 raw challenge identity維持 sensitive-data限制。

## Supersession Review

已建立：

```txt
ADR-022 supersedes ADR-015
ADR-015 superseded_by ADR-022
```

此 relation只適用 credential-at-rest implementation scope。ADR-015維持 `accepted`，其 refresh concurrency、single-flight、Session identity、safe replay、failure classification與 credential commit ordering沒有被取代。

## Non-ADR Routing

- M19–21 threat models、decision matrices與 planning findings保留於對應 planning review。
- Implementation phases與 task sequencing保留於 plans。
- Test counts、runtime evidence與 finding closure保留於 audits。
- Template Baseline 1.3.0／1.4.0／1.5.0 release decisions保留於 `CHANGELOG.md`與 Git history。
- Canonical ADR不保存日期、commit、review gate流水帳或版本承諾。

## Link and Compatibility Review

- Canonical evidence links指向現存 Auth／API／App README及 M19–21 audits。
- Current README與 Documentation Hub仍可指向 aggregate，符合 Task 23-8前 compatibility contract。
- Legacy `docs/adr/000-*`至`005-*`尚未修改。
- Aggregate Decision 022正文未刪除、未縮減、未轉 stub。

## Validation

```txt
python -m unittest tools.docs.test_check_docs
→ 11 tests passed

dart run melos run docs_check
→ Documentation check passed

git diff --check
→ Passed

git diff --quiet -- docs/architecture_decisions.md
→ Passed；aggregate未修改

ADR index
→ 22 extracted / 0 aggregate

Canonical journal scan
→ 無 implementation status、日期、release baseline、finding count或 version bump journal
```

## Rollback

若 Batch F需要 rollback，revert本 batch commit即可移除 ADR-022、撤銷 ADR-015 reciprocal edge及 index／manifest更新；aggregate authority仍完整存在。

## Review Decision

Batch F semantic、security、relation、link與 checker gate通過。Open P0／P1：0。
