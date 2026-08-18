# Pencil Compatibility

此feature是Milestone 33的presentation-only Pencil-to-Flutter compatibility proof。

## Authority

- Primary visual authority：`docs/design_sources/pencil-compatibility-write-precheck/source.pen`
- Manifest：`docs/visual_authority/pencil-compatibility-write-precheck/manifest.md`
- Flutter mapping：`docs/audits/milestone_33/33-6_flutter_mapping_matrix.md`

## Boundary

- 只包含真實需要的presentation page/view、layout、widgets、localized copy與窄責任local palette／typography owner；不建立generic visual specification。
- 不建立Domain、Data、Repository、Use Case、Bloc或DI registration。
- Route是非initial、無guard、非Shell tab的standalone route。
- Shared semantic／Theme Identity／validated reusable component才可提升至Design System；single-screen exact geometry／decoration留smallest correct component owner。
- Raster／vector／icon／font／texture仍走既有representation/provenance authority；canonical viewport／DPR只由visual-authority metadata擁有。
