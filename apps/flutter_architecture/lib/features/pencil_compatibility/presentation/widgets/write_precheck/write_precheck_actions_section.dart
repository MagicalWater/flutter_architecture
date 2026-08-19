import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_secondary_action.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckPrimaryLeadingGlow extends StatelessWidget {
  const WritePrecheckPrimaryLeadingGlow({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(left: projectedPx(context, 19)),
      child: SizedBox(
        width: projectedPx(context, 889),
        height: projectedPx(context, 5),
        child: const ProjectedComponent(
          designWidth: 889,
          designHeight: 5,
          child: IgnorePointer(
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0x213DAEFF), Color(0x303DAEFF)],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class WritePrecheckPrimaryAction extends StatelessWidget {
  const WritePrecheckPrimaryAction({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey<String>('precheckPrimaryAction'),
    width: projectedPx(context, 855),
    height: projectedPx(context, 72),
    child: ProjectedComponent(
      designWidth: 855,
      designHeight: 72,
      child: Semantics(
        button: true,
        label: copy.primaryAction,
        child: ExcludeSemantics(
          child: ProjectedDecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFF75D9FF), width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x333DAEFF),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ProjectedPadding(
              padding: const EdgeInsets.all(2),
              child: ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      Color(0xFF1467A4),
                      Color(0xFF1C9BE8),
                      Color(0xFF20B6F5),
                    ],
                    stops: <double>[0, 0.5, 1],
                  ),
                ),
                child: ProjectedTranslate(
                  offset: const Offset(-1, -1),
                  child: Stack(
                    children: <Widget>[
                      const Positioned(
                        left: 20,
                        top: 5,
                        width: 813,
                        height: 1,
                        child: ProjectedHairline(color: Color(0x88B9EEFF)),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 281, top: 14),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              height: 42,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: ProjectedIcon(
                                      PhosphorIcons.shieldCheckLight,
                                      size: 34,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 300,
                                    child: Text(
                                      copy.primaryAction,
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: _style(
                                        size: 29,
                                        weight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
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
  );
}

class WritePrecheckSecondaryActions extends StatelessWidget {
  const WritePrecheckSecondaryActions({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: projectedPx(context, WritePrecheckProjection.designWidth),
    height: projectedPx(context, 60),
    child: Padding(
      padding: EdgeInsets.only(
        left: projectedPx(context, 36),
        right: projectedPx(context, 50),
      ),
      child: Row(
        children: <Widget>[
          WritePrecheckSecondaryAction(
            surfaceWidth: 410,
            icon: PhosphorIcons.listMagnifyingGlassLight,
            iconScaleX: 1.08,
            iconScaleY: 1.625,
            label: copy.secondaryActions[0],
          ),
          SizedBox(width: projectedPx(context, 27)),
          WritePrecheckSecondaryAction(
            surfaceWidth: 418,
            icon: PhosphorIcons.pencilSimpleLight,
            iconScaleX: 1.04,
            iconScaleY: 1,
            label: copy.secondaryActions[1],
          ),
        ],
      ),
    ),
  );
}

class WritePrecheckFooter extends StatelessWidget {
  const WritePrecheckFooter({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(left: projectedPx(context, 37)),
      child: SizedBox(
        width: projectedPx(context, 853),
        height: projectedPx(context, 66),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: projectedPx(context, 1),
              child: const ProjectedHairline(
                color: WritePrecheckPalette.subtleOutline,
              ),
            ),
            SizedBox(height: projectedPx(context, 11)),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: projectedPx(context, 314)),
                child: SizedBox(
                  width: projectedPx(context, 209),
                  height: projectedPx(context, 29),
                  child: Semantics(
                    key: const ValueKey<String>('precheckEndFlowAction'),
                    button: true,
                    label: copy.endFlowAction,
                    child: ExcludeSemantics(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              top: projectedPx(context, 6),
                            ),
                            child: const ProjectedIcon(
                              PhosphorIcons.xCircleLight,
                              size: 22,
                              color: WritePrecheckPalette.dim,
                            ),
                          ),
                          SizedBox(width: projectedPx(context, 11)),
                          SizedBox(
                            width: projectedPx(context, 143),
                            child: Text(
                              copy.endFlowAction,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: _style(
                                size: 20,
                                weight: FontWeight.w500,
                                color: WritePrecheckPalette.muted,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: projectedPx(context, 6),
                            ),
                            child: const ProjectedIcon(
                              PhosphorIcons.caretRightLight,
                              size: 22,
                              color: WritePrecheckPalette.dim,
                            ),
                          ),
                        ],
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
