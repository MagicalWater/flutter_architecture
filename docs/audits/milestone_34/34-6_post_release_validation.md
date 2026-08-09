---
document_type: runtime-evidence
status: completed
authoritative_for:
  - milestone-34-post-release-validation
  - milestone-34-final-closure
last_reviewed_baseline: 1.15.2
---

# Milestone 34 — Template Baseline 1.15.2 Post-release Validation

## Release identity

```txt
Template Baseline: 1.15.2
Release commit: 7504b7949047239044595c019cc28cad7640af1f
Main integration: fast-forward
Remote publication: origin/main
Force push: no
```

發布後fresh fetch／main verification確認：

```txt
local main  = 7504b7949047239044595c019cc28cad7640af1f
origin/main = 7504b7949047239044595c019cc28cad7640af1f
VERSION     = 1.15.2
working tree before closure docs = clean
```

## Fresh published-main verification

在已發布的`D:\Developer\flutter_architecture` main checkout執行：

```powershell
python tools/docs/test_pencil_representation_mapping_policy.py
python tools/docs/test_pencil_single_renderer_policy.py
dart run melos run docs_check
git diff --check
```

結果：

```txt
Representation mapping policy: 7 / 7 PASS
Single-renderer policy: 5 / 5 PASS
Documentation check: PASS
git diff --check: PASS
```

本Milestone沒有Flutter production source、dependency或runtime mutation，因此依accepted Plan與34-5 Final Review不重跑無關的full Flutter test suite／bundle；published-main驗證聚焦changed Skill／docs contract。

## Behavioral evidence continuity

Task 34-3的provider-neutral external evidence在release後仍為current accepted proof：

- RED：PTF-13～PTF-18六題皆already-safe baseline，沒有捏造baseline failure。
- DISCOVERY：fresh ChatGPT未被告知domain Skill名稱時，自行找到`governing-template-development → implementing-pencil-flutter-design → asset-and-typography-mapping.md`，6/6 PASS。
- EXPLICIT GREEN：另一fresh ChatGPT明確載入domain Skill/reference，PTF-13～PTF-18 6/6 PASS。
- Open P0：0。
- Open P1 without disposition：0。

Codex CLI `401 Unauthorized`只保留為historical optional-harness failure，不影響provider-neutral validation completion，也不是模板dependency。

## Governance closure

- Design、Plan、Tasks 34-1～34-4、34-5 Holistic Final Review均已accepted／PASS。
- 1.15.2 release已由使用者明確授權。
- main以fast-forward整合Milestone branch並正常push；沒有force push。
- published `origin/main`已fresh驗證release commit與VERSION一致。
- Human Guide、Skill registry、pressure scenarios、policy tests與current routing已對齊1.15.2。

Final disposition：**Template Baseline 1.15.2 release與Milestone 34正式Completed / Archived。**
