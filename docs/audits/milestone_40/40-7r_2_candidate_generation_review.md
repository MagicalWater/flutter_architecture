---
document_type: phase-review
status: completed
authoritative_for:
  - milestone-40-hero-candidate-generation-evidence
last_reviewed_baseline: 1.20.0
---

# Task 40-7R-2 — Executor Admission & Candidate Generation Evidence

## Executor admission

Fresh production-scope admission：

```txt
EXECUTOR_SCOPE_VERIFIED
ScopePath=D:\Developer\gpt-computer-bridge
DaemonState=Present
```

Fresh discovery returned the production route：

```txt
chatgpt-web-image.org.default.generate_chatgpt_web_image
```

Generate schema confirmed `prompt` + bounded `source_images` and native MCP image output.

Generation sources were exactly：

- `docs/assets/architecture/productized-topology.png`
- `docs/assets/architecture/c4-dependency-contract.png`

The old rejected 40-7 Hero was **not** used as a generation source.

## C01 generation

```txt
Job: a3484043-69e9-42ba-8a62-e42c91cd6678
Output: PNG 2172 × 724
SHA-256: E63BF4470420B81B12B7B0BC9ABD73F123046D037261D74AD857FCC63605F3D9
```

The native `type:image` result was delivered through `bridge-win.call_executor_tool` and then copied byte-for-byte into repository review evidence. Source output SHA-256 and repository copy SHA-256 were identical.

After focused visual review C01 was rejected because its overall direction was usable but execution violated critical gates：

- left-side cards contained tiny bar/dot marks that read as pseudo-text／status glyphs；
- the right-side application object read too much like a generic app UI／phone panel；
- source-family structure was present, so this was classified as a bounded execution defect rather than immediate Design-direction invalidation。

C01 was moved to historical rejected evidence：

`docs/assets/readme/rejected/flutter-enterprise-architecture-hero-40-7r-c01.png`

## C02 replacement generation

Per accepted Plan regeneration budget, one replacement was allowed for C01's local execution defects.

```txt
Job: 1244880b-ddf6-4aa7-863a-f7465075c9e3
Output: PNG 1774 × 887
SHA-256: 811AFB5CD78260D06155B386F3906D242817A9EADBA8EF3AF1F47CAD7572CFE7
```

Again, native image delivery and repository bytes were verified identical before review.

C02 was also rejected. It removed the C01 pseudo-text contamination, but produced a heavy hardware／server-rack visual identity and a `~2:1` image instead of the required `~3:1` low-height Hero band. Because the second candidate failed critical **Product recognition / Mobile foundation / Repository-family consistency** gates, the accepted Plan forbids C03 and requires return to Design.

Historical rejected evidence：

`docs/assets/readme/rejected/flutter-enterprise-architecture-hero-40-7r-c02.png`

## Result

```txt
Executor admission: PASS
Source-image authority: PASS
Native image transport: PASS
Byte identity: PASS for C01 / C02
C01: REJECTED
C02: REJECTED
C03: FORBIDDEN by accepted regeneration budget
README promotion: NOT ALLOWED
```
