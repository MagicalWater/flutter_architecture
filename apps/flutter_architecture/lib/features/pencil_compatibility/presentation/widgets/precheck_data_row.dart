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
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;
  final bool showDivider;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacks = constraints.maxWidth < 430;
      final content = stacks
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Label(icon: icon, label: label, accent: accent),
                const SizedBox(height: DsSpace.xs),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    value,
                    style: PencilCompatibilityVisualSpec.textStyle(
                      size: compact ? 14 : 15,
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
                  child: _Label(icon: icon, label: label, accent: accent),
                ),
                const SizedBox(width: DsSpace.md),
                Expanded(
                  flex: 5,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: PencilCompatibilityVisualSpec.textStyle(
                      size: compact ? 14 : 15,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: compact ? DsSpace.sm : DsSpace.md,
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
  const _Label({required this.icon, required this.label, required this.accent});

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accent.withAlpha(20),
          borderRadius: BorderRadius.circular(DsRadius.lg),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: accent),
      ),
      const SizedBox(width: DsSpace.xs),
      Expanded(
        child: Text(
          label,
          style: PencilCompatibilityVisualSpec.textStyle(
            size: 14,
            color: PencilCompatibilityVisualSpec.muted,
            weight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
