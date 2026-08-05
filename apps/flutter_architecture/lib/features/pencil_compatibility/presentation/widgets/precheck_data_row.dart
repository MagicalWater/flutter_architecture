import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';

class PrecheckDataRow extends StatelessWidget {
  const PrecheckDataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
    this.showDivider = true,
    this.accent = PencilCompatibilityVisualSpec.cyan,
    this.dense = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;
  final bool showDivider;
  final Color accent;
  final bool dense;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacks = constraints.maxWidth < 430;
      final content = stacks
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Label(icon: icon, label: label, accent: accent, dense: dense),
                SizedBox(height: dense ? DsSpace.xxs : DsSpace.xs),
                Padding(
                  padding: EdgeInsets.only(left: dense ? 28 : 38),
                  child: Text(
                    value,
                    style: PencilCompatibilityVisualSpec.textStyle(
                      size: dense
                          ? 13
                          : compact
                          ? 14
                          : 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: _Label(
                    icon: icon,
                    label: label,
                    accent: accent,
                    dense: dense,
                  ),
                ),
                const SizedBox(width: DsSpace.md),
                Expanded(
                  flex: 5,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: PencilCompatibilityVisualSpec.textStyle(
                      size: dense
                          ? 13
                          : compact
                          ? 14
                          : 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: dense
              ? 6
              : compact
              ? DsSpace.sm
              : DsSpace.md,
        ),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(
                    color: PencilCompatibilityVisualSpec.borderSoft,
                  ),
                )
              : null,
        ),
        child: content,
      );
    },
  );
}

class _Label extends StatelessWidget {
  const _Label({
    required this.icon,
    required this.label,
    required this.accent,
    required this.dense,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final bool dense;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: dense ? 24 : 30,
        height: dense ? 24 : 30,
        decoration: BoxDecoration(
          color: accent.withAlpha(20),
          borderRadius: BorderRadius.circular(DsRadius.lg),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: dense ? 15 : 18, color: accent),
      ),
      SizedBox(width: dense ? DsSpace.xxs : DsSpace.xs),
      Expanded(
        child: Text(
          label,
          style: PencilCompatibilityVisualSpec.textStyle(
            size: dense ? 12.5 : 14,
            color: PencilCompatibilityVisualSpec.muted,
            weight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
