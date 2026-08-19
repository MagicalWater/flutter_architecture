import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckGuidanceSection extends StatelessWidget {
  const WritePrecheckGuidanceSection({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(left: projectedPx(context, 36)),
      child: SizedBox(
        key: const ValueKey<String>('precheckGuidance'),
        width: projectedPx(context, 855),
        height: projectedPx(context, 171),
        child: ProjectedComponent(
          designWidth: 855,
          designHeight: 171,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: copy.guidanceTitle,
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF513F22), width: 2),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Color(0xFF1A1710),
                    Color(0xFF0B1720),
                    Color(0xFF07131E),
                  ],
                  stops: <double>[0, 0.55, 1],
                ),
              ),
              child: ProjectedPadding(
                padding: const EdgeInsets.all(1),
                child: ProjectedClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Stack(
                    children: <Widget>[
                      const Positioned(
                        left: -90,
                        top: -130,
                        width: 340,
                        height: 340,
                        child: WritePrecheckRadialGlow(
                          centerColor: Color(0x26F5B941),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(19, 13, 19, 7),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 36,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(width: 6),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: ProjectedIcon(
                                        PhosphorIcons.lightbulbLight,
                                        size: 27,
                                        color: Color(0xFFF5B941),
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    SizedBox(
                                      width: 220,
                                      child: OverflowBox(
                                        alignment: Alignment.topLeft,
                                        minHeight: 39,
                                        maxHeight: 39,
                                        child: SizedBox(
                                          height: 39,
                                          child: Text(
                                            copy.guidanceTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.clip,
                                            style: _style(
                                              size: 27,
                                              weight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _guidanceLine(copy.guidanceLines[0], 29),
                              _guidanceLine(copy.guidanceLines[1], 29),
                              _guidanceLine(copy.guidanceLines[2], 27),
                              SizedBox(
                                height: 28,
                                child: ProjectedDecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF493A1B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ProjectedPadding(
                                    padding: const EdgeInsets.all(1),
                                    child: ProjectedDecoratedBox(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF574118),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: ProjectedPadding(
                                        padding: const EdgeInsets.all(1),
                                        child: ProjectedDecoratedBox(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF30250F),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ProjectedTranslate(
                                            offset: const Offset(-1, -1),
                                            child: Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: projectedPx(
                                                    context,
                                                    11,
                                                  ),
                                                ),
                                                const ProjectedIcon(
                                                  PhosphorIcons.warningLight,
                                                  size: 18,
                                                  color: Color(0xFFF5B941),
                                                ),
                                                SizedBox(
                                                  width: projectedPx(
                                                    context,
                                                    9,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Transform.scale(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    scaleX: 0.99,
                                                    child: Text(
                                                      copy.commitmentNotice,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      style: _style(
                                                        size: 15,
                                                        weight: FontWeight.w500,
                                                        letterSpacing: 0.15,
                                                        rasterWeight: 330,
                                                        color: const Color(
                                                          0xFFF5B941,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _guidanceLine(String line, double slotHeight) => SizedBox(
    height: slotHeight,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: 10),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: ProjectedIcon(
            PhosphorIcons.checkCircle,
            size: 20,
            color: Color(0xFFF5B941),
          ),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: 590,
          height: 25,
          child: Transform.scale(
            alignment: Alignment.centerLeft,
            scaleX: 1.009,
            child: Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: _style(
                size: 17,
                weight: FontWeight.w300,
                letterSpacing: -0.2,
                rasterWeight: 250,
                color: WritePrecheckPalette.muted,
              ),
            ),
          ),
        ),
      ],
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
