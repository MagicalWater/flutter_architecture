import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';

class PrecheckSectionCard extends StatelessWidget {
  const PrecheckSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.accent = PencilCompatibilityVisualSpec.cyan,
    this.dense = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color accent;
  final bool dense;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: title,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 14 : DsSpace.lg),
      decoration: BoxDecoration(
        gradient: PencilCompatibilityVisualSpec.surfaceGradient,
        borderRadius: BorderRadius.circular(
          PencilCompatibilityVisualSpec.cardRadius,
        ),
        border: Border.all(color: PencilCompatibilityVisualSpec.borderSoft),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PencilCompatibilityVisualSpec.backgroundDeep.withAlpha(170),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: dense ? 30 : 38,
                height: dense ? 30 : 38,
                decoration: BoxDecoration(
                  color: accent.withAlpha(24),
                  borderRadius: BorderRadius.circular(DsRadius.lg),
                  border: Border.all(color: accent.withAlpha(100)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: dense ? 17 : 21, color: accent),
              ),
              SizedBox(width: dense ? DsSpace.xs : DsSpace.sm),
              Expanded(
                child: Text(
                  title,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: dense ? 18 : 22,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: dense ? DsSpace.xs : DsSpace.md),
          child,
        ],
      ),
    ),
  );
}
