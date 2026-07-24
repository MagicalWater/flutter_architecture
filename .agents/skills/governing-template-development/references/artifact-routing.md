# Artifact and Superpowers Routing

| Requirement | L0 | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|---|
| Requirement Decision | brief | required | required | required | formal | formal |
| Behavioral requirements | no | optional | required | required | required | required |
| Brainstorming | no | optional | required | required | required | required |
| Design Spec | no | usually no | required | required | required | required |
| Implementation Plan | no | inline | required | required | required | required |
| ADR gate | no | no | conditional | required when stable boundary changes | required | required when architecture changes |
| Two-layer Task mode | minimal | simplified | standard | full | full | full-critical |
| Worktree／branch | no | optional | recommended | required | required | required |
| Regression | focused | affected | feature/integration | affected workspace | full | full + compatibility/platform |
| Release | no | conditional | conditional | usually | required by Milestone disposition | required |
| Post-release | no | no | conditional | conditional | required | required |

## Artifact ownership

- Behavioral requirements and technical design live in the approved Design Spec.
- ADR owns stable architecture decisions, not task sequencing.
- Implementation Plan owns ordered steps, file scope, validation and commit boundaries.
- Audits own findings, re-review and evidence.
- Source, tests and CI own runtime truth.
- Project Context and Guides own current state and reusable policy.
- VERSION and CHANGELOG own release identity and release history.

## Superpowers order

```txt
Classification
→ brainstorming when routed
→ Design Spec
→ Design Task governance and user approval
→ writing-plans
→ Plan Task governance and user approval
→ worktree when routed
→ TDD／systematic debugging
→ executing-plans or subagent-driven-development
→ requesting／receiving code review
→ verification-before-completion
→ finishing-development-branch
→ repository release and post-release closure
```

Repository gates override a Superpowers shortcut. In particular, writing-plans cannot begin before the Design Spec is accepted, and implementation cannot begin before the Plan is accepted.


## Acceptance state transitions

```txt
Design proposed → full Design Task gate → user approval → Design accepted
Plan proposed → full Plan Task gate → user approval → Plan accepted
Accepted Plan → implementation Tasks
Local final review → push／clean-checkout／remote validation → Milestone closure
```

A failed gate leaves the current artifact proposed, active, blocked or rejected. Do not label it accepted merely because its file or commit exists.
