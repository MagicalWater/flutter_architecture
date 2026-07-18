import 'package:design_system/src/tokens/ds_space.dart';
import 'package:flutter/material.dart';

/// Material Button 內部可共用的 label / loading presentation。
final class DsButtonContent extends StatelessWidget {
  const DsButtonContent({
    required this.label,
    this.isLoading = false,
    this.progressSemanticsLabel,
    super.key,
  });

  final String label;
  final bool isLoading;
  final String? progressSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return Text(label);
    }

    return Semantics(
      label: progressSemanticsLabel ?? '$label in progress',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: DsSpace.xs),
            Flexible(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
