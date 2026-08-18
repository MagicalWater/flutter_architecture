import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum WritePrecheckStepState { completed, active, pending }

class WritePrecheckStep extends StatelessWidget {
  const WritePrecheckStep({
    required this.left,
    required this.top,
    required this.number,
    required this.label,
    required this.state,
    super.key,
  });

  final double left;
  final double top;
  final int number;
  final String label;
  final WritePrecheckStepState state;

  @override
  Widget build(BuildContext context) {
    final active = state == WritePrecheckStepState.active;
    final completed = state == WritePrecheckStepState.completed;
    final glyphLeft = active || number == 4 ? 96.0 : 94.0;
    final glyphWidth = active
        ? 15.0
        : number == 4
        ? 14.0
        : 18.0;
    final glyphHeight = active || number == 4 ? 35.0 : 36.0;
    final glyphSize = active || number == 4 ? 24.0 : 25.0;
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
        ? const Color(0xFFF5B941)
        : completed
        ? const Color(0xFF3DAEFF)
        : const Color(0xFF4B6173);
    final contentColor = active
        ? const Color(0xFFF5B941)
        : completed
        ? const Color(0xFF74D8FF)
        : const Color(0xFF7F94A7);

    return Positioned(
      left: left,
      top: top,
      width: 205,
      height: 88,
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
                left: 81,
                top: 6,
                width: 44,
                height: 44,
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
                top: number == 4 ? 11 : 10,
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
              Positioned(
                left: 0,
                top: 60,
                width: 205,
                height: 25,
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
                        ? const Color(0xFFF5B941)
                        : completed
                        ? WritePrecheckPalette.muted
                        : WritePrecheckPalette.dim,
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

class WritePrecheckDataRow extends StatelessWidget {
  const WritePrecheckDataRow({
    required this.top,
    required this.height,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.valueColor,
    required this.labelSize,
    required this.valueSize,
    required this.iconSize,
    required this.dividerVisible,
    super.key,
  });

  final double top;
  final double height;
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color valueColor;
  final double labelSize;
  final double valueSize;
  final double iconSize;
  final bool dividerVisible;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    top: top,
    width: 820,
    height: height,
    child: ProjectedStack(
      children: <Widget>[
        if (dividerVisible)
          const Positioned(
            left: 0,
            bottom: 0,
            width: 820,
            height: 1,
            child: ProjectedHairline(color: Color(0xFF244056)),
          ),
        Positioned(
          left: 18,
          top: height == 44 ? 9 : 6,
          width: iconSize,
          height: iconSize,
          child: ProjectedIcon(icon, size: iconSize, color: iconColor),
        ),
        Positioned(
          left: 58,
          top: height == 44 ? 8 : 5,
          width: 260,
          height: height == 44 ? 28 : 25,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: writePrecheckTextStyle(
              size: labelSize,
              weight: FontWeight.w500,
              rasterWeight: 350,
              color: WritePrecheckPalette.muted,
            ),
          ),
        ),
        Positioned(
          left: 385,
          top: height == 44 ? 8 : 5,
          width: 415,
          height: height == 44 ? 28 : 25,
          child: Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.clip,
            style: writePrecheckTextStyle(
              size: valueSize,
              rasterWeight: 400,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

class WritePrecheckRecordTile extends StatelessWidget {
  const WritePrecheckRecordTile({
    required this.top,
    required this.icon,
    required this.record,
    super.key,
  });

  final double top;
  final IconData icon;
  final WritePrecheckRecordCopy record;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 15,
    top: top - 1,
    width: 822,
    height: 68,
    child: ProjectedDecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF162B3C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ProjectedPadding(
        padding: const EdgeInsets.all(2),
        child: ProjectedDecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF071522),
            borderRadius: BorderRadius.circular(13),
          ),
          child: ProjectedTranslate(
            offset: const Offset(-1, -1),
            child: ProjectedStack(
              children: <Widget>[
                Positioned(
                  left: 10,
                  top: 7,
                  width: 62,
                  height: 52,
                  child: ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2440),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0A4A82)),
                    ),
                    child: Center(
                      child: ProjectedIcon(
                        icon,
                        size: 30,
                        color: const Color(0xFF74D8FF),
                      ),
                    ),
                  ),
                ),
                _localText(
                  text: record.title,
                  left: 91,
                  top: 8,
                  width: 400,
                  height: 29,
                  size: 20,
                  weight: FontWeight.w500,
                  rasterWeight: 450,
                ),
                _localText(
                  text: record.value,
                  left: 92,
                  top: 35,
                  width: 450,
                  height: 25,
                  size: 17,
                  color: WritePrecheckPalette.muted,
                ),
                Positioned(
                  left: 665,
                  top: 16,
                  width: 108,
                  height: 34,
                  child: ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1A2A),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFF244056)),
                    ),
                    child: Center(
                      child: Text(
                        record.badge,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: writePrecheckTextStyle(
                          size: 15,
                          weight: FontWeight.w500,
                          rasterWeight: 450,
                          color: WritePrecheckPalette.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 785,
                  top: 21,
                  width: 22,
                  height: 22,
                  child: Transform.scale(
                    alignment: Alignment.topCenter,
                    scaleY: 1.75,
                    child: const ProjectedIcon(
                      PhosphorIcons.caretRightLight,
                      size: 22,
                      color: WritePrecheckPalette.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class WritePrecheckSecondaryAction extends StatelessWidget {
  const WritePrecheckSecondaryAction({
    required this.left,
    required this.width,
    required this.iconLeft,
    required this.labelLeft,
    required this.icon,
    required this.iconScaleX,
    required this.iconScaleY,
    required this.label,
    super.key,
  });

  final double left;
  final double width;
  final double iconLeft;
  final double labelLeft;
  final IconData icon;
  final double iconScaleX;
  final double iconScaleY;
  final String label;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left - 1,
    top: 0,
    width: width + 2,
    height: 60,
    child: ProjectedComponent(
      designWidth: width + 2,
      designHeight: 60,
      child: Semantics(
        button: true,
        label: label,
        child: ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFF3DAEFF), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x223DAEFF), blurRadius: 10),
            ],
          ),
          child: ProjectedPadding(
            padding: const EdgeInsets.all(2),
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFF08233A), Color(0xFF020A12)],
                ),
              ),
              child: ProjectedTranslate(
                offset: const Offset(-1, -1),
                child: ExcludeSemantics(
                  child: ProjectedStack(
                    children: <Widget>[
                      Positioned(
                        left: iconLeft - 1,
                        top: 14,
                        width: 30,
                        height: 30,
                        child: Transform.scale(
                          scaleX: iconScaleX,
                          scaleY: iconScaleY,
                          child: ProjectedIcon(
                            icon,
                            size: 30,
                            color: const Color(0xFF3DAEFF),
                          ),
                        ),
                      ),
                      Positioned(
                        left: labelLeft,
                        top: 10,
                        width: 190,
                        height: 35,
                        child: Transform.scale(
                          alignment: Alignment.centerLeft,
                          scaleX: 0.986,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: writePrecheckTextStyle(
                              size: 24,
                              weight: FontWeight.w500,
                              rasterWeight: 500,
                              color: const Color(0xFF3DAEFF),
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

Positioned _localText({
  required String text,
  required double left,
  required double top,
  required double width,
  required double height,
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = WritePrecheckPalette.text,
  double? rasterWeight,
}) => Positioned(
  left: left,
  top: top,
  width: width,
  height: height,
  child: Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.clip,
    style: writePrecheckTextStyle(
      size: size,
      weight: weight,
      color: color,
      rasterWeight: rasterWeight,
    ),
  ),
);
