# Skill Adoption Governance

## Decision states

Approved、Approved with restrictions、Pilot、Deprecated、Rejected。

## Admission review

Before installation or repository adoption, record:

1. Confirmed problem and expected value.
2. Trigger conditions and supported environments.
3. Inputs, outputs and repository mutations.
4. Overlap with Superpowers, this governance skill and existing domain skills.
5. Whether it creates or duplicates authority.
6. External tools, MCP, credentials and network requirements.
7. Version/source pinning, update and rollback method.
8. Pressure scenarios and repository validation evidence.

## Placement rule

- Reusable agent technique／orchestration：Skill。
- Non-negotiable repository policy：`AGENTS.md`。
- Stable architecture choice：ADR。
- Human governance overview：`docs/governance/`。
- Reusable operations：`docs/guides/`。
- Mechanically enforceable rule：tests／CI／checker。

A skill never replaces repository authority, source, tests, CI, security policy, release gates or findings disposition.

## Upgrade rule

Re-run adoption review and pressure scenarios when triggers, artifacts, permissions, managed files, workflow order or supported agents change. More installed skills are not inherently better; reject a skill whose value is already covered without a clear gap.


## Registry contract

For every adopted or evaluated Skill, record name, source, pinned version or commit, status, trigger, responsibility, forbidden responsibility, overlaps, companion Skills, repository mutations, required permissions, validation evidence, last review and rollback／upgrade policy.

## Revalidation triggers

Re-run focused adoption review and relevant pressure scenarios when the Skill changes trigger wording, artifact paths, files it manages, permissions, workflow ordering, review／commit behavior, supported runtimes or automatic loading. An update that writes managed `AGENTS.md` or introduces a parallel authority cannot be accepted without an explicit repository decision.

## Rollback and deprecation

Pilot and restricted Skills must have a removal path. Deprecation records the replacement or reason for removal, removes trigger wiring, verifies no repository workflow still depends on it and preserves only necessary historical evidence.
