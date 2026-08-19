import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';

class WritePrecheckDataRow extends StatelessWidget {
  const WritePrecheckDataRow({
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

  static const _compactHeight = 44.0;
  static const _iconColumnWidth = 40.0;

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
  Widget build(BuildContext context) {
    final compact = height == _compactHeight;
    final textTop = compact ? 8.0 : 5.0;
    final textHeight = compact ? 28.0 : 25.0;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 17),
      child: SizedBox(
        height: height,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: compact ? 9 : 6),
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: ProjectedIcon(
                          icon,
                          size: iconSize,
                          color: iconColor,
                        ),
                      ),
                    ),
                    SizedBox(width: _iconColumnWidth - iconSize),
                    Padding(
                      padding: EdgeInsets.only(top: textTop),
                      child: SizedBox(
                        width: 260,
                        height: textHeight,
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
                    ),
                    const SizedBox(width: 67),
                    Padding(
                      padding: EdgeInsets.only(top: textTop),
                      child: SizedBox(
                        width: 415,
                        height: textHeight,
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
                    ),
                  ],
                ),
              ),
            ),
            if (dividerVisible)
              const SizedBox(
                width: double.infinity,
                height: 1,
                child: ProjectedHairline(
                  color: WritePrecheckPalette.subtleOutline,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
