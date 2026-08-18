import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final class WritePrecheckProjection {
  const WritePrecheckProjection({required this.availableWidth});

  static const double designWidth = 941;

  final double availableWidth;

  double get scale => availableWidth / designWidth;
  double px(double designPixels) => designPixels * scale;
}

final class ProjectionTextScaler extends TextScaler {
  const ProjectionTextScaler(this.base, this.projectionScale);

  final TextScaler base;
  final double projectionScale;

  @override
  double scale(double fontSize) => base.scale(fontSize) * projectionScale;

  @override
  double get textScaleFactor => base.scale(1) * projectionScale;
}

class ProjectionScope extends InheritedWidget {
  const ProjectionScope({
    required this.projection,
    required super.child,
    super.key,
  });

  final WritePrecheckProjection projection;

  static WritePrecheckProjection of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProjectionScope>()!.projection;

  @override
  bool updateShouldNotify(ProjectionScope oldWidget) =>
      projection.availableWidth != oldWidget.projection.availableWidth;
}

double _px(BuildContext context, double designPixels) =>
    ProjectionScope.of(context).px(designPixels);

double projectedPx(BuildContext context, double designPixels) =>
    ProjectionScope.of(context).px(designPixels);

class ProjectedDecoratedBox extends StatelessWidget {
  const ProjectedDecoratedBox({
    required this.decoration,
    this.child,
    super.key,
  });

  final BoxDecoration decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scale = ProjectionScope.of(context).scale;
    final border = decoration.border;
    return DecoratedBox(
      decoration: decoration.copyWith(
        borderRadius: decoration.borderRadius == null
            ? null
            : decoration.borderRadius! * scale,
        border: border is Border ? border.scale(scale) : border,
        boxShadow: decoration.boxShadow
            ?.map((shadow) => shadow.scale(scale))
            .toList(growable: false),
      ),
      child: child,
    );
  }
}

class ProjectedPadding extends StatelessWidget {
  const ProjectedPadding({
    required this.padding,
    required this.child,
    super.key,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding * ProjectionScope.of(context).scale,
    child: child,
  );
}

class ProjectedClipRRect extends StatelessWidget {
  const ProjectedClipRRect({
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius * ProjectionScope.of(context).scale,
    child: child,
  );
}

class ProjectedIcon extends StatelessWidget {
  const ProjectedIcon(this.icon, {required this.size, this.color, super.key});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: _px(context, size), color: color);
}

class ProjectedHairline extends StatelessWidget {
  const ProjectedHairline({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final coverage = ProjectionScope.of(context).scale.clamp(0.0, 1.0);
    return ColoredBox(
      color: color.withAlpha((color.a * 255 * coverage).round()),
    );
  }
}

class ProjectedComponent extends StatelessWidget {
  const ProjectedComponent({
    required this.designWidth,
    required this.designHeight,
    required this.child,
    super.key,
  });

  final double designWidth;
  final double designHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final projection = ProjectionScope.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);
    final baseTextScaler = mediaQuery?.textScaler is ProjectionTextScaler
        ? (mediaQuery!.textScaler as ProjectionTextScaler).base
        : mediaQuery?.textScaler;

    Widget designChild = ProjectionScope(
      projection: const WritePrecheckProjection(
        availableWidth: WritePrecheckProjection.designWidth,
      ),
      child: child,
    );
    if (mediaQuery != null && baseTextScaler != null) {
      designChild = MediaQuery(
        data: mediaQuery.copyWith(textScaler: baseTextScaler),
        child: designChild,
      );
    }

    return OverflowBox(
      alignment: Alignment.topLeft,
      minWidth: designWidth,
      maxWidth: designWidth,
      minHeight: designHeight,
      maxHeight: designHeight,
      child: Transform.scale(
        alignment: Alignment.topLeft,
        scale: projection.scale,
        filterQuality: FilterQuality.high,
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: designChild,
        ),
      ),
    );
  }
}

class ProjectedTranslate extends StatelessWidget {
  const ProjectedTranslate({
    required this.offset,
    required this.child,
    super.key,
  });

  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(_px(context, offset.dx), _px(context, offset.dy)),
    child: child,
  );
}

class ProjectedStack extends StatelessWidget {
  const ProjectedStack({this.children = const <Widget>[], super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => _RawProjectedStack(
    scale: ProjectionScope.of(context).scale,
    clipBehavior: Clip.hardEdge,
    children: children,
  );
}

class _RawProjectedStack extends MultiChildRenderObjectWidget {
  const _RawProjectedStack({
    required this.scale,
    required this.clipBehavior,
    required super.children,
  });

  final double scale;
  final Clip clipBehavior;

  @override
  _RenderProjectedStack createRenderObject(BuildContext context) =>
      _RenderProjectedStack(
        scale: scale,
        alignment: AlignmentDirectional.topStart,
        textDirection: Directionality.maybeOf(context),
        fit: StackFit.loose,
        clipBehavior: clipBehavior,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderProjectedStack renderObject,
  ) {
    renderObject
      ..scale = scale
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior;
  }
}

final class _RenderProjectedStack extends RenderStack {
  _RenderProjectedStack({
    required double scale,
    required super.alignment,
    required super.textDirection,
    required super.fit,
    required super.clipBehavior,
  }) : _scale = scale;

  double _scale;

  double get scale => _scale;
  set scale(double value) {
    if (_scale == value) {
      return;
    }
    _scale = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (_scale == 1) {
      super.performLayout();
      return;
    }

    final snapshots = <StackParentData, _StackParentDataSnapshot>{};
    for (
      RenderBox? child = firstChild;
      child != null;
      child = childAfter(child)
    ) {
      final data = child.parentData! as StackParentData;
      if (!data.isPositioned) {
        continue;
      }
      snapshots[data] = _StackParentDataSnapshot.from(data);
      data
        ..left = _scaled(data.left)
        ..top = _scaled(data.top)
        ..right = _scaled(data.right)
        ..bottom = _scaled(data.bottom)
        ..width = _scaled(data.width)
        ..height = _scaled(data.height);
    }

    try {
      super.performLayout();
    } finally {
      for (final entry in snapshots.entries) {
        entry.value.restore(entry.key);
      }
    }
  }

  double? _scaled(double? value) => value == null ? null : value * _scale;
}

final class _StackParentDataSnapshot {
  const _StackParentDataSnapshot({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.width,
    required this.height,
  });

  factory _StackParentDataSnapshot.from(StackParentData data) =>
      _StackParentDataSnapshot(
        left: data.left,
        top: data.top,
        right: data.right,
        bottom: data.bottom,
        width: data.width,
        height: data.height,
      );

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  void restore(StackParentData data) {
    data
      ..left = left
      ..top = top
      ..right = right
      ..bottom = bottom
      ..width = width
      ..height = height;
  }
}
