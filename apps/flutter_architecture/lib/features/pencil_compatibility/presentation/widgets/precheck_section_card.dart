import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';

class PrecheckSectionCard extends StatelessWidget {
  const PrecheckSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.accent = PencilCompatibilityVisualSpec.cyan,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: title,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpace.lg),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withAlpha(24),
                  borderRadius: BorderRadius.circular(DsRadius.lg),
                  border: Border.all(color: accent.withAlpha(100)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 21, color: accent),
              ),
              const SizedBox(width: DsSpace.sm),
              Expanded(
                child: Text(
                  title,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: 22,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpace.md),
          child,
        ],
      ),
    ),
  );
}
