import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';

class PrecheckRecordTile extends StatelessWidget {
  const PrecheckRecordTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.badge,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final String badge;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacks = constraints.maxWidth < 360;
      final badgeWidget = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpace.sm,
          vertical: DsSpace.xxs,
        ),
        decoration: BoxDecoration(
          color: PencilCompatibilityVisualSpec.cyan.withAlpha(24),
          borderRadius: BorderRadius.circular(
            PencilCompatibilityVisualSpec.pillRadius,
          ),
          border: Border.all(
            color: PencilCompatibilityVisualSpec.cyan.withAlpha(100),
          ),
        ),
        child: Text(
          badge,
          style: PencilCompatibilityVisualSpec.textStyle(
            size: 12,
            color: PencilCompatibilityVisualSpec.cyanBright,
            weight: FontWeight.w700,
          ),
        ),
      );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DsSpace.md),
        decoration: BoxDecoration(
          color: PencilCompatibilityVisualSpec.surfaceRaised,
          borderRadius: BorderRadius.circular(
            PencilCompatibilityVisualSpec.recordRadius,
          ),
          border: Border.all(color: PencilCompatibilityVisualSpec.borderSoft),
        ),
        child: stacks
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RecordContent(icon: icon, title: title, value: value),
                  const SizedBox(height: DsSpace.sm),
                  badgeWidget,
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _RecordContent(
                      icon: icon,
                      title: title,
                      value: value,
                    ),
                  ),
                  const SizedBox(width: DsSpace.md),
                  badgeWidget,
                ],
              ),
      );
    },
  );
}

class _RecordContent extends StatelessWidget {
  const _RecordContent({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: PencilCompatibilityVisualSpec.cyan.withAlpha(20),
          borderRadius: BorderRadius.circular(DsRadius.lg),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 21,
          color: PencilCompatibilityVisualSpec.cyanBright,
        ),
      ),
      const SizedBox(width: DsSpace.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: 15,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DsSpace.xxs),
            Text(
              value,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: 14,
                color: PencilCompatibilityVisualSpec.muted,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
