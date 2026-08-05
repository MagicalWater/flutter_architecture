import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum PrecheckStepState { completed, active, pending }

class PrecheckProgress extends StatelessWidget {
  const PrecheckProgress({
    required this.labels,
    this.activeIndex = 2,
    this.dense = false,
    super.key,
  });

  final List<String> labels;
  final int activeIndex;
  final bool dense;

  @override
  Widget build(BuildContext context) => Row(
    key: const ValueKey<String>('precheckProgressItems'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (var index = 0; index < labels.length; index++)
        Expanded(
          child: PrecheckStepItem(
            label: labels[index],
            number: index + 1,
            state: index < activeIndex
                ? PrecheckStepState.completed
                : index == activeIndex
                ? PrecheckStepState.active
                : PrecheckStepState.pending,
            isFirst: index == 0,
            isLast: index == labels.length - 1,
            dense: dense,
          ),
        ),
    ],
  );
}

class PrecheckStepItem extends StatelessWidget {
  const PrecheckStepItem({
    required this.label,
    required this.number,
    required this.state,
    required this.isFirst,
    required this.isLast,
    this.dense = false,
    super.key,
  });

  final String label;
  final int number;
  final PrecheckStepState state;
  final bool isFirst;
  final bool isLast;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isActive = state == PrecheckStepState.active;
    final isCompleted = state == PrecheckStepState.completed;
    final lineColor = isCompleted || isActive
        ? PencilCompatibilityVisualSpec.cyan
        : PencilCompatibilityVisualSpec.borderSoft;
    final circleColor = isActive
        ? PencilCompatibilityVisualSpec.gold
        : isCompleted
        ? PencilCompatibilityVisualSpec.cyan
        : PencilCompatibilityVisualSpec.surfaceRaised;
    final contentColor = isActive || isCompleted
        ? PencilCompatibilityVisualSpec.text
        : PencilCompatibilityVisualSpec.dim;

    return Semantics(
      container: true,
      label: '$number. $label',
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 1,
                    color: isFirst ? Colors.transparent : lineColor,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: dense ? 26 : 32,
                  height: dense ? 26 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    border: Border.all(
                      color: isActive
                          ? PencilCompatibilityVisualSpec.gold
                          : lineColor,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? <BoxShadow>[
                            BoxShadow(
                              color: PencilCompatibilityVisualSpec.gold
                                  .withAlpha(90),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? Icon(
                          PhosphorIcons.checks,
                          size: dense ? 14 : 17,
                          color: PencilCompatibilityVisualSpec.backgroundDeep,
                        )
                      : Text(
                          '$number',
                          style: PencilCompatibilityVisualSpec.textStyle(
                            size: dense ? 12 : 14,
                            color: isActive
                                ? PencilCompatibilityVisualSpec.backgroundDeep
                                : contentColor,
                            weight: FontWeight.w700,
                          ),
                        ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: isLast ? Colors.transparent : lineColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: dense ? DsSpace.xxs : DsSpace.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsSpace.xxs),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: PencilCompatibilityVisualSpec.textStyle(
                  size: dense ? 11 : 12,
                  color: contentColor,
                  weight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
