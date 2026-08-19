import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content_components.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckTopArea extends StatelessWidget {
  const WritePrecheckTopArea({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: projectedPx(context, WritePrecheckProjection.designWidth),
    height: projectedPx(context, 220),
    child: Stack(
      children: <Widget>[
        Align(alignment: Alignment.topCenter, child: _topChrome(context)),
        Align(alignment: Alignment.topCenter, child: _progress(context)),
      ],
    ),
  );

  Widget _topChrome(BuildContext context) => SizedBox(
    width: projectedPx(context, WritePrecheckProjection.designWidth),
    height: projectedPx(context, 140),
    child: ProjectedComponent(
      designWidth: WritePrecheckProjection.designWidth,
      designHeight: 140,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.only(left: 37, right: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 80,
                      height: 33,
                      child: Text(
                        '10:42',
                        style: _style(
                          size: 23,
                          weight: FontWeight.w600,
                          rasterWeight: 600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: ProjectedIcon(
                        PhosphorIcons.wifiHighLight,
                        size: 25,
                        color: WritePrecheckPalette.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Transform.scale(
                        scaleX: 1.3,
                        scaleY: 1.38,
                        child: const ProjectedIcon(
                          PhosphorIcons.cellSignalHigh,
                          size: 24,
                          color: WritePrecheckPalette.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 23),
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: SizedBox(
                      width: 28,
                      height: 24,
                      child: Center(
                        child: ProjectedIcon(
                          PhosphorIcons.batteryFullLight,
                          size: 24,
                          color: WritePrecheckPalette.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: SizedBox(
                      width: 35,
                      height: 29,
                      child: Text(
                        '100',
                        style: _style(
                          size: 20,
                          weight: FontWeight.w500,
                          rasterWeight: 450,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: ProjectedHairline(color: Color(0xFF163147)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(29, 12, 29, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: ExcludeSemantics(
                        child: ProjectedDecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF071725),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF284A62)),
                          ),
                          child: const Center(
                            child: ProjectedIcon(
                              PhosphorIcons.arrowLeftLight,
                              size: 28,
                              color: WritePrecheckPalette.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 44,
                          child: Text(
                            key: const ValueKey<String>('precheckHeader'),
                            copy.title,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            semanticsLabel: copy.title,
                            style: _style(
                              size: 34,
                              weight: FontWeight.w700,
                              letterSpacing: -0.3,
                              rasterWeight: 650,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 1),
                          child: SizedBox(
                            width: 260,
                            height: 29,
                            child: Text(
                              copy.flowStep,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: _style(
                                size: 20,
                                letterSpacing: 0.05,
                                color: WritePrecheckPalette.muted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _progress(BuildContext context) => SizedBox(
    width: projectedPx(context, WritePrecheckProjection.designWidth),
    height: projectedPx(context, 220),
    child: ProjectedComponent(
      designWidth: WritePrecheckProjection.designWidth,
      designHeight: 220,
      child: Semantics(
        key: const ValueKey<String>('precheckProgress'),
        container: true,
        explicitChildNodes: true,
        label: copy.flowStep,
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: 112,
              top: 148,
              width: 482,
              height: 21,
              child: IgnorePointer(
                child: ProjectedDecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0x003DAEFF),
                        Color(0x0A3DAEFF),
                        Color(0x1A3DAEFF),
                        Color(0x1A3DAEFF),
                        Color(0x0A3DAEFF),
                        Color(0x003DAEFF),
                      ],
                      stops: <double>[0, 0.2, 0.43, 0.57, 0.8, 1],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 116,
              top: 157,
              width: 708,
              height: 3,
              child: ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF29475D),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
            const Positioned(
              left: 116,
              top: 157,
              width: 476,
              height: 3,
              child: ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(2),
                    right: Radius.circular(2),
                  ),
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF3DAEFF), Color(0xFFF5B941)],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Color(0x663DAEFF), blurRadius: 8),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: WritePrecheckProjection.designWidth,
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 131),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 205,
                          height: 88,
                          child: WritePrecheckStep(
                            number: 1,
                            label: copy.steps[0],
                            state: WritePrecheckStepState.completed,
                          ),
                        ),
                        const SizedBox(width: 28),
                        SizedBox(
                          width: 205,
                          height: 88,
                          child: WritePrecheckStep(
                            number: 2,
                            label: copy.steps[1],
                            state: WritePrecheckStepState.completed,
                          ),
                        ),
                        const SizedBox(width: 34),
                        SizedBox(
                          width: 205,
                          height: 88,
                          child: WritePrecheckStep(
                            number: 3,
                            label: copy.steps[2],
                            state: WritePrecheckStepState.active,
                          ),
                        ),
                        const SizedBox(width: 28),
                        SizedBox(
                          width: 205,
                          height: 88,
                          child: WritePrecheckStep(
                            number: 4,
                            label: copy.steps[3],
                            state: WritePrecheckStepState.pending,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

TextStyle _style({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = WritePrecheckPalette.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
}) => writePrecheckTextStyle(
  size: size,
  weight: weight,
  color: color,
  lineHeight: lineHeight,
  letterSpacing: letterSpacing,
  rasterWeight: rasterWeight,
);
