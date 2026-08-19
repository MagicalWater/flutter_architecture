import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';

enum WritePrecheckStepState { completed, active, pending }

class WritePrecheckStep extends StatelessWidget {
  const WritePrecheckStep({
    required this.number,
    required this.label,
    required this.state,
    super.key,
  });

  static const _surfaceWidth = 205.0;
  static const _surfaceHeight = 88.0;
  static const _circleSize = 44.0;
  static const _circleLeft = 81.0;
  static const _circleTop = 6.0;
  static const _labelHeight = 25.0;

  final int number;
  final String label;
  final WritePrecheckStepState state;

  @override
  Widget build(BuildContext context) {
    final active = state == WritePrecheckStepState.active;
    final completed = state == WritePrecheckStepState.completed;
    final isFourthStepGlyph = number == 4;
    final isNarrowGlyph = active || isFourthStepGlyph;
    final glowColor = active
        ? const Color(0x66F5B941)
        : completed
        ? const Color(0x443DAEFF)
        : const Color(0x18536B7E);
    final circleFill = active
        ? const Color(0xFF0A2033)
        : completed
        ? const Color(0xFF082A46)
        : const Color(0xFF05111C);
    final accent = active
        ? WritePrecheckPalette.goldAccent
        : completed
        ? WritePrecheckPalette.blueAccent
        : const Color(0xFF4B6173);
    final contentColor = active
        ? WritePrecheckPalette.goldAccent
        : completed
        ? WritePrecheckPalette.cyanAccent
        : WritePrecheckPalette.dim;
    final glyphLeft = isNarrowGlyph ? 96.0 : 94.0;
    final glyphWidth = active ? 15.0 : (isFourthStepGlyph ? 14.0 : 18.0);
    final glyphHeight = isNarrowGlyph ? 35.0 : 36.0;
    final glyphSize = isNarrowGlyph ? 24.0 : 25.0;

    return SizedBox(
      width: _surfaceWidth,
      height: _surfaceHeight,
      child: Semantics(
        container: true,
        label: '$number. $label',
        child: ExcludeSemantics(
          child: ProjectedStack(
            children: <Widget>[
              if (completed)
                const Positioned(
                  left: 65,
                  top: -10,
                  width: 76,
                  height: 76,
                  child: WritePrecheckRadialGlow(
                    centerColor: Color(0x553DAEFF),
                  ),
                ),
              Positioned(
                left: active ? 65 : 75,
                top: active ? -10 : 0,
                width: active ? 76 : 56,
                height: active ? 76 : 56,
                child: active
                    ? const WritePrecheckActiveStepGlow()
                    : WritePrecheckRadialGlow(centerColor: glowColor),
              ),
              Positioned(
                left: _circleLeft,
                top: _circleTop,
                width: _circleSize,
                height: _circleSize,
                child: ProjectedDecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleFill,
                    border: Border.all(color: accent, width: active ? 2 : 1),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: active
                            ? const Color(0x33F5B941)
                            : completed
                            ? const Color(0x333DAEFF)
                            : Colors.transparent,
                        blurRadius: active ? 14 : 12,
                        spreadRadius: active ? 2 : 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: glyphLeft,
                top: isFourthStepGlyph ? 11 : 10,
                width: glyphWidth,
                height: glyphHeight,
                child: Text(
                  completed ? '✓' : '$number',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: writePrecheckTextStyle(
                    size: glyphSize,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: contentColor,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: projectedPx(context, 3)),
                  child: SizedBox(
                    width: projectedPx(context, _surfaceWidth),
                    height: projectedPx(context, _labelHeight),
                    child: Text(
                      label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: writePrecheckTextStyle(
                        size: 17,
                        weight: active ? FontWeight.w700 : FontWeight.w500,
                        rasterWeight: 450,
                        color: active
                            ? WritePrecheckPalette.goldAccent
                            : completed
                            ? WritePrecheckPalette.muted
                            : WritePrecheckPalette.dim,
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
}
