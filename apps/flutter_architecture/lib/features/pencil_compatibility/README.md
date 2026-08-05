# Pencil Compatibility

此feature是Milestone 33的presentation-only Pencil-to-Flutter compatibility proof。

## Authority

- Primary visual authority：`docs/design_sources/pencil-compatibility-write-precheck/source.pen`
- Manifest：`docs/visual_authority/pencil-compatibility-write-precheck/manifest.md`
- Flutter mapping：`docs/audits/milestone_33/33-6_flutter_mapping_matrix.md`

## Boundary

- 只包含presentation page、widgets、localized copy與feature-local visual specification。
- 不建立Domain、Data、Repository、Use Case、Bloc或DI registration。
- Route是非initial、無guard、非Shell tab的standalone route。
- Exact Pencil values只有第二個真實consumer證明穩定共用後，才可提升至Design System。
