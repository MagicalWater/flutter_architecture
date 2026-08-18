import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckHeroSection extends StatelessWidget {
  const WritePrecheckHeroSection({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(left: projectedPx(context, 37)),
      child: SizedBox(
        key: const ValueKey<String>('precheckHero'),
        width: projectedPx(context, 853),
        height: projectedPx(context, 254),
        child: ProjectedComponent(
          designWidth: 853,
          designHeight: 254,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: copy.heroTitle,
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF5B941)),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Color(0xFF0A2032),
                    Color(0xFF071726),
                    Color(0xFF0D1A25),
                  ],
                  stops: <double>[0, 0.62, 1],
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ProjectedClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ProjectedStack(
                  children: <Widget>[
                    const Positioned(
                      left: 620,
                      top: -90,
                      width: 340,
                      height: 330,
                      child: WritePrecheckRadialGlow(
                        centerColor: Color(0x30F5B941),
                      ),
                    ),
                    const Positioned(
                      left: 690,
                      top: 18,
                      width: 220,
                      height: 220,
                      child: WritePrecheckOrbit(color: Color(0x66F5B941)),
                    ),
                    const Positioned(
                      left: 745,
                      top: 73,
                      width: 110,
                      height: 110,
                      child: WritePrecheckOrbit(color: Color(0x40F5B941)),
                    ),
                    const Positioned(
                      left: 760,
                      top: 42,
                      width: 9,
                      height: 9,
                      child: ProjectedDecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF5B941),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 820,
                      top: 186,
                      width: 7,
                      height: 7,
                      child: ProjectedDecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF5B941),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 30,
                      top: 33,
                      width: 176,
                      height: 176,
                      child: WritePrecheckShieldAuthority(),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(227, 39, 30, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 290,
                              height: 49,
                              child: Transform.scale(
                                alignment: Alignment.centerLeft,
                                scaleX: 0.996,
                                child: Text(
                                  copy.heroTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: _style(
                                    size: 34,
                                    weight: FontWeight.w700,
                                    rasterWeight: 650,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: SizedBox(
                                width: 570,
                                height: 56,
                                child: Transform.scale(
                                  alignment: Alignment.centerLeft,
                                  scaleX: 0.989,
                                  child: Text(
                                    copy.heroDescription,
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                    style: _style(
                                      size: 20,
                                      lineHeight: 1.42,
                                      color: WritePrecheckPalette.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: _statusPill(context),
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
  );

  Widget _statusPill(BuildContext context) {
    final statusStyle = _style(
      size: 19,
      weight: FontWeight.w600,
      color: const Color(0xFFF5B941),
    );
    final statusPainter = TextPainter(
      text: TextSpan(text: copy.heroStatus, style: statusStyle),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final requiredDesignWidth = 15 + 24 + 10 + statusPainter.width;
    statusPainter.dispose();
    final usesAcceptedDesignWidth = requiredDesignWidth <= 186;
    final content = ProjectedDecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF102B22),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFF5E8E55)),
      ),
      child: Row(
        mainAxisSize: usesAcceptedDesignWidth
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: projectedPx(context, 15)),
          const ProjectedIcon(
            PhosphorIcons.checkCircleLight,
            size: 24,
            color: Color(0xFFF5B941),
          ),
          SizedBox(width: projectedPx(context, 10)),
          Text(copy.heroStatus, style: statusStyle),
        ],
      ),
    );

    return SizedBox(
      width: usesAcceptedDesignWidth ? 186 : 320,
      height: 42,
      child: usesAcceptedDesignWidth
          ? content
          : Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 186, maxWidth: 320),
                child: IntrinsicWidth(child: content),
              ),
            ),
    );
  }
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
