import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_actions_section.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_guidance_section.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_hero_section.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_information_cards.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_top_area.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';

class WritePrecheckProjectedCanvas extends StatelessWidget {
  const WritePrecheckProjectedCanvas({
    required this.copy,
    required this.availableWidth,
    super.key,
  });

  final WritePrecheckCopy copy;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final projection = WritePrecheckProjection(availableWidth: availableWidth);
    final mediaQuery = MediaQuery.maybeOf(context);
    Widget child = ProjectionScope(
      projection: projection,
      child: _ProjectedScreen(copy: copy),
    );
    if (mediaQuery != null) {
      child = MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: ProjectionTextScaler(
            mediaQuery.textScaler,
            projection.scale,
          ),
        ),
        child: child,
      );
    }
    return child;
  }
}

class _ProjectedScreen extends StatelessWidget {
  const _ProjectedScreen({required this.copy});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) {
    final projection = ProjectionScope.of(context);
    return SizedBox(
      width: projection.px(WritePrecheckProjection.designWidth),
      child: ClipRect(
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            const Positioned.fill(child: WritePrecheckBackground()),
            Positioned.fill(
              child: WritePrecheckAmbientGlows(projection: projection),
            ),
            Positioned(
              left: projection.px(19),
              top: projection.px(1529),
              width: projection.px(889),
              height: projection.px(17),
              child: const ProjectedComponent(
                designWidth: 889,
                designHeight: 17,
                child: IgnorePointer(
                  child: ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Color(0x303DAEFF), Color(0x0D3DAEFF)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _flowRegion(
                  context,
                  designHeight: 220,
                  child: WritePrecheckTopArea(copy: copy),
                ),
                _gap(context, 12),
                _flowRegion(
                  context,
                  designHeight: 254,
                  child: WritePrecheckHeroSection(copy: copy),
                ),
                _gap(context, 8),
                _flowRegion(
                  context,
                  designHeight: 260,
                  child: WritePrecheckSummaryCard(copy: copy),
                ),
                _gap(context, 5),
                _flowRegion(
                  context,
                  designHeight: 286,
                  child: WritePrecheckResultsCard(copy: copy),
                ),
                _gap(context, 5),
                _flowRegion(
                  context,
                  designHeight: 219,
                  child: WritePrecheckRecordsCard(copy: copy),
                ),
                _gap(context, 8),
                _flowRegion(
                  context,
                  designHeight: 171,
                  child: Stack(
                    children: <Widget>[
                      WritePrecheckGuidanceSection(copy: copy),
                      Positioned(
                        left: projectedPx(context, 19),
                        top: projectedPx(context, 163),
                        width: projectedPx(context, 889),
                        height: projectedPx(context, 8),
                        child: const ProjectedComponent(
                          designWidth: 889,
                          designHeight: 8,
                          child: IgnorePointer(
                            child: ProjectedDecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Color(0x0A3DAEFF),
                                    Color(0x163DAEFF),
                                    Color(0x133DAEFF),
                                  ],
                                  stops: <double>[0, 0.7, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _flowRegion(
                  context,
                  designHeight: 7,
                  child: const WritePrecheckPrimaryLeadingGlow(),
                ),
                _flowRegion(
                  context,
                  designHeight: 81,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: projectedPx(context, 36),
                      right: projectedPx(context, 50),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        WritePrecheckPrimaryAction(copy: copy),
                        SizedBox(height: projectedPx(context, 9)),
                      ],
                    ),
                  ),
                ),
                _flowRegion(
                  context,
                  designHeight: 60,
                  child: WritePrecheckSecondaryActions(copy: copy),
                ),
                _gap(context, 10),
                _flowRegion(
                  context,
                  designHeight: 66,
                  child: WritePrecheckFooter(copy: copy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gap(BuildContext context, double designHeight) =>
      SizedBox(height: projectedPx(context, designHeight));

  Widget _flowRegion(
    BuildContext context, {
    required double designHeight,
    required Widget child,
  }) => SizedBox(
    width: projectedPx(context, WritePrecheckProjection.designWidth),
    height: projectedPx(context, designHeight),
    child: Align(alignment: Alignment.topCenter, child: child),
  );
}
