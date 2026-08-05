import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class PrecheckActions extends StatelessWidget {
  const PrecheckActions({
    required this.primaryLabel,
    required this.secondaryLabels,
    required this.endFlowLabel,
    this.dense = false,
    super.key,
  });

  final String primaryLabel;
  final List<String> secondaryLabels;
  final String endFlowLabel;
  final bool dense;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacks = constraints.maxWidth < 620;
      final secondary = <Widget>[
        PrecheckSecondaryAction(
          label: secondaryLabels[0],
          icon: PhosphorIcons.listMagnifyingGlass,
          dense: dense,
        ),
        PrecheckSecondaryAction(
          label: secondaryLabels[1],
          icon: PhosphorIcons.pencilSimple,
          dense: dense,
        ),
      ];

      return Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey<String>('precheckPrimaryAction'),
              onPressed: () {},
              icon: Icon(PhosphorIcons.shieldCheck, size: dense ? 20 : 24),
              label: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: dense ? DsSpace.xs : DsSpace.md,
                ),
                child: Text(primaryLabel),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: PencilCompatibilityVisualSpec.backgroundDeep,
                backgroundColor: PencilCompatibilityVisualSpec.gold,
                textStyle: PencilCompatibilityVisualSpec.textStyle(
                  size: dense ? 16 : 20,
                  color: PencilCompatibilityVisualSpec.backgroundDeep,
                  weight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    PencilCompatibilityVisualSpec.buttonRadius,
                  ),
                ),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: dense ? DsSpace.xs : DsSpace.md),
          if (stacks)
            Column(
              children: <Widget>[
                for (var index = 0; index < secondary.length; index++) ...[
                  SizedBox(width: double.infinity, child: secondary[index]),
                  if (index != secondary.length - 1)
                    SizedBox(height: dense ? DsSpace.xs : DsSpace.sm),
                ],
              ],
            )
          else
            Row(
              children: <Widget>[
                Expanded(child: secondary[0]),
                SizedBox(width: dense ? DsSpace.sm : DsSpace.md),
                Expanded(child: secondary[1]),
              ],
            ),
          SizedBox(height: dense ? DsSpace.xxs : DsSpace.md),
          TextButton.icon(
            key: const ValueKey<String>('precheckEndFlowAction'),
            onPressed: () {},
            icon: Icon(PhosphorIcons.xCircle, size: dense ? 17 : 20),
            label: Text(endFlowLabel),
            style: TextButton.styleFrom(
              foregroundColor: PencilCompatibilityVisualSpec.dim,
              textStyle: PencilCompatibilityVisualSpec.textStyle(
                size: dense ? 13 : 15,
                color: PencilCompatibilityVisualSpec.dim,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PrecheckSecondaryAction extends StatelessWidget {
  const PrecheckSecondaryAction({
    required this.label,
    required this.icon,
    this.dense = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: dense ? 17 : 21),
    label: Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 6 : DsSpace.sm),
      child: Text(label, textAlign: TextAlign.center),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: PencilCompatibilityVisualSpec.text,
      side: const BorderSide(color: PencilCompatibilityVisualSpec.border),
      textStyle: PencilCompatibilityVisualSpec.textStyle(
        size: dense ? 13 : 15,
        weight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          PencilCompatibilityVisualSpec.buttonRadius,
        ),
      ),
    ),
  );
}
