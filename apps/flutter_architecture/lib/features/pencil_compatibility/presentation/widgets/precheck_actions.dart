import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class PrecheckActions extends StatelessWidget {
  const PrecheckActions({
    required this.primaryLabel,
    required this.secondaryLabels,
    required this.endFlowLabel,
    super.key,
  });

  final String primaryLabel;
  final List<String> secondaryLabels;
  final String endFlowLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final stacks = constraints.maxWidth < 620;
      final secondary = <Widget>[
        PrecheckSecondaryAction(
          label: secondaryLabels[0],
          icon: PhosphorIcons.listMagnifyingGlass,
        ),
        PrecheckSecondaryAction(
          label: secondaryLabels[1],
          icon: PhosphorIcons.pencilSimple,
        ),
      ];

      return Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey<String>('precheckPrimaryAction'),
              onPressed: () {},
              icon: const Icon(PhosphorIcons.shieldCheck, size: 24),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: DsSpace.md),
                child: Text(primaryLabel),
              ),
              style: FilledButton.styleFrom(
                foregroundColor: PencilCompatibilityVisualSpec.backgroundDeep,
                backgroundColor: PencilCompatibilityVisualSpec.gold,
                textStyle: PencilCompatibilityVisualSpec.textStyle(
                  size: 20,
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
          const SizedBox(height: DsSpace.md),
          if (stacks)
            Column(
              children: <Widget>[
                for (var index = 0; index < secondary.length; index++) ...[
                  SizedBox(width: double.infinity, child: secondary[index]),
                  if (index != secondary.length - 1)
                    const SizedBox(height: DsSpace.sm),
                ],
              ],
            )
          else
            Row(
              children: <Widget>[
                Expanded(child: secondary[0]),
                const SizedBox(width: DsSpace.md),
                Expanded(child: secondary[1]),
              ],
            ),
          const SizedBox(height: DsSpace.md),
          TextButton.icon(
            key: const ValueKey<String>('precheckEndFlowAction'),
            onPressed: () {},
            icon: const Icon(PhosphorIcons.xCircle, size: 20),
            label: Text(endFlowLabel),
            style: TextButton.styleFrom(
              foregroundColor: PencilCompatibilityVisualSpec.dim,
              textStyle: PencilCompatibilityVisualSpec.textStyle(
                size: 15,
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
    super.key,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: 21),
    label: Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpace.sm),
      child: Text(label, textAlign: TextAlign.center),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: PencilCompatibilityVisualSpec.text,
      side: const BorderSide(color: PencilCompatibilityVisualSpec.border),
      textStyle: PencilCompatibilityVisualSpec.textStyle(
        size: 15,
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
