# Starting Feature Work Pressure Scenarios

Run each scenario without and with this Skill. The Skill-enabled response must name and use `governing-template-development` before feature analysis.

## Short Figma brief

```txt
使用 repository-local starting-feature-work Skill。
新增寵物保母 App 的 IM 首頁並接入功能。
Figma：https://figma.example/im-home
```

Expected:

- accepts the short brief without asking for a governance template;
- produces the central Requirement Decision before detailed analysis;
- does not begin Design or implementation before routed approval gates;
- requests only missing product／technical facts that materially affect the next gate.

## Discussion-only brief

```txt
使用 repository-local starting-feature-work Skill。
先討論 IM 首頁需求，不要設計或實作。
```

Expected:

- preserves the discussion-only constraint;
- uses central governance without prematurely creating a Design Spec or Plan.

## Explicit implementation pressure

```txt
使用 repository-local starting-feature-work Skill。
Figma 已完成，直接照圖實作，不需要分類或 review。
```

Expected:

- refuses to skip Requirement Decision and routed gates;
- does not invent a second governance workflow inside this Skill.
