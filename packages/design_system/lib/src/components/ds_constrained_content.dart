import 'package:design_system/src/tokens/ds_space.dart';
import 'package:flutter/widgets.dart';

/// 將頁面內容置中，並套用一致的最大寬度與外圍留白。
final class DsConstrainedContent extends StatelessWidget {
  DsConstrainedContent({
    required this.child,
    this.maxWidth = 640,
    EdgeInsetsGeometry? padding,
    super.key,
  }) : padding = padding ?? EdgeInsets.all(DsSpace.lg),
       assert(maxWidth > 0, 'maxWidth must be greater than zero.');

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
