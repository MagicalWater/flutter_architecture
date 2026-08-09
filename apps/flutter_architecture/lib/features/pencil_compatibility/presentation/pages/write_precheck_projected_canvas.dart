import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

final class WritePrecheckProjection {
  const WritePrecheckProjection({required this.availableWidth});

  static const double designWidth = 941;
  static const double designHeight = 1672;

  final double availableWidth;

  double get scale => availableWidth / designWidth;
  double px(double designPixels) => designPixels * scale;
}

class WritePrecheckProjectedCanvas extends StatelessWidget {
  const WritePrecheckProjectedCanvas({
    required this.copy,
    required this.availableWidth,
    super.key,
  });

  final WritePrecheckCopy copy;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final projection = WritePrecheckProjection(availableWidth: availableWidth);
    final mediaQuery = MediaQuery.maybeOf(context);
    Widget child = _ProjectionScope(
      projection: projection,
      child: _ProjectedScreen(copy: copy),
    );
    if (mediaQuery != null) {
      child = MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: _ProjectionTextScaler(
            mediaQuery.textScaler,
            projection.scale,
          ),
        ),
        child: child,
      );
    }
    return child;
  }
}

final class _ProjectionTextScaler extends TextScaler {
  const _ProjectionTextScaler(this.base, this.projectionScale);

  final TextScaler base;
  final double projectionScale;

  @override
  double scale(double fontSize) => base.scale(fontSize) * projectionScale;

  @override
  double get textScaleFactor => base.scale(1) * projectionScale;
}

class _ProjectionScope extends InheritedWidget {
  const _ProjectionScope({required this.projection, required super.child});

  final WritePrecheckProjection projection;

  static WritePrecheckProjection of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ProjectionScope>()!
      .projection;

  @override
  bool updateShouldNotify(_ProjectionScope oldWidget) =>
      projection.availableWidth != oldWidget.projection.availableWidth;
}

double _px(BuildContext context, double designPixels) =>
    _ProjectionScope.of(context).px(designPixels);

class _ProjectedDecoratedBox extends StatelessWidget {
  const _ProjectedDecoratedBox({required this.decoration, this.child});

  final BoxDecoration decoration;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scale = _ProjectionScope.of(context).scale;
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

class _ProjectedPadding extends StatelessWidget {
  const _ProjectedPadding({required this.padding, required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding * _ProjectionScope.of(context).scale,
    child: child,
  );
}

class _ProjectedClipRRect extends StatelessWidget {
  const _ProjectedClipRRect({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius * _ProjectionScope.of(context).scale,
    child: child,
  );
}

class _ProjectedIcon extends StatelessWidget {
  const _ProjectedIcon(this.icon, {required this.size, this.color});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: _px(context, size), color: color);
}

class _ProjectedHairline extends StatelessWidget {
  const _ProjectedHairline({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final coverage = _ProjectionScope.of(context).scale.clamp(0.0, 1.0);
    return ColoredBox(
      color: color.withAlpha((color.a * 255 * coverage).round()),
    );
  }
}

class _ProjectedComponent extends StatelessWidget {
  const _ProjectedComponent({
    required this.designWidth,
    required this.designHeight,
    required this.child,
  });

  final double designWidth;
  final double designHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final projection = _ProjectionScope.of(context);
    final mediaQuery = MediaQuery.maybeOf(context);
    final baseTextScaler = mediaQuery?.textScaler is _ProjectionTextScaler
        ? (mediaQuery!.textScaler as _ProjectionTextScaler).base
        : mediaQuery?.textScaler;

    Widget designChild = _ProjectionScope(
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

class _ProjectedTranslate extends StatelessWidget {
  const _ProjectedTranslate({required this.offset, required this.child});

  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(_px(context, offset.dx), _px(context, offset.dy)),
    child: child,
  );
}

class _ProjectedStack extends StatelessWidget {
  const _ProjectedStack({
    this.clipBehavior = Clip.hardEdge,
    this.children = const <Widget>[],
  });

  final Clip clipBehavior;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => _RawProjectedStack(
    scale: _ProjectionScope.of(context).scale,
    clipBehavior: clipBehavior,
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

class _ProjectedScreen extends StatelessWidget {
  const _ProjectedScreen({required this.copy});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) {
    final projection = _ProjectionScope.of(context);
    return SizedBox(
      width: projection.px(WritePrecheckProjection.designWidth),
      height: projection.px(WritePrecheckProjection.designHeight),
      child: ClipRect(
        child: _ProjectedStack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            const Positioned.fill(child: _CanonicalBackground()),
            _CanonicalAmbientGlows(projection: projection),
            _topChrome(context),
            _progressComponent(context),
            _hero(context),
            _summaryCard(context),
            _resultsCard(context),
            _recordsCard(context),
            _guidanceCard(context),
            ..._primarySupplementalGlows(context),
            _primaryAction(context),
            ..._secondaryActions(context),
            ..._footer(context),
          ],
        ),
      ),
    );
  }

  Widget _topChrome(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    width: WritePrecheckProjection.designWidth,
    height: 140,
    child: _ProjectedComponent(
      designWidth: WritePrecheckProjection.designWidth,
      designHeight: 140,
      child: _ProjectedStack(
        children: <Widget>[..._statusBar(context), ..._header(context)],
      ),
    ),
  );

  Widget _progressComponent(BuildContext context) => Positioned(
    left: 0,
    top: 0,
    width: WritePrecheckProjection.designWidth,
    height: 220,
    child: _ProjectedComponent(
      designWidth: WritePrecheckProjection.designWidth,
      designHeight: 220,
      child: _ProjectedStack(children: _progress(context)),
    ),
  );

  List<Widget> _statusBar(BuildContext context) => <Widget>[
    _positionedText(
      text: '10:42',
      left: 37,
      top: 16,
      width: 80,
      height: 33,
      size: 23,
      weight: FontWeight.w600,
      rasterWeight: 600,
    ),
    _positionedIcon(
      icon: PhosphorIcons.wifiHighLight,
      left: 758,
      top: 16,
      width: 25,
      height: 25,
      size: 25,
    ),
    _positionedIcon(
      icon: PhosphorIcons.cellSignalHigh,
      left: 799,
      top: 16,
      width: 24,
      height: 24,
      size: 24,
      scaleX: 1.3,
      scaleY: 1.38,
    ),
    _positionedIcon(
      icon: PhosphorIcons.batteryFullLight,
      left: 846,
      top: 15,
      width: 28,
      height: 24,
      size: 24,
    ),
    _positionedText(
      text: '100',
      left: 878,
      top: 14,
      width: 35,
      height: 29,
      size: 20,
      weight: FontWeight.w500,
      rasterWeight: 450,
    ),
  ];

  List<Widget> _header(BuildContext context) => <Widget>[
    const Positioned(
      left: 0,
      top: 48,
      width: 941,
      height: 1,
      child: _ProjectedHairline(color: Color(0xFF163147)),
    ),
    Positioned(
      left: 29,
      top: 64,
      width: 50,
      height: 50,
      child: ExcludeSemantics(
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF071725),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF284A62)),
          ),
          child: const Center(
            child: _ProjectedIcon(
              PhosphorIcons.arrowLeftLight,
              size: 28,
              color: PencilCompatibilityVisualSpec.text,
            ),
          ),
        ),
      ),
    ),
    _positionedText(
      key: const ValueKey<String>('precheckHeader'),
      semanticsLabel: copy.title,
      text: copy.title,
      left: 96,
      top: 61,
      width: 180,
      height: 49,
      size: 34,
      weight: FontWeight.w700,
      letterSpacing: -0.3,
      rasterWeight: 650,
    ),
    _positionedText(
      text: copy.flowStep,
      left: 97,
      top: 105,
      width: 260,
      height: 29,
      size: 20,
      letterSpacing: 0.05,
      color: PencilCompatibilityVisualSpec.muted,
    ),
  ];

  List<Widget> _progress(BuildContext context) => <Widget>[
    const Positioned(
      left: 112,
      top: 148,
      width: 482,
      height: 21,
      child: IgnorePointer(
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x003DAEFF),
                Color(0x0A3DAEFF),
                Color(0x1A3DAEFF),
                Color(0x1A3DAEFF),
                Color(0x0A3DAEFF),
                Color(0x003DAEFF),
              ],
              stops: <double>[0, 0.2, 0.43, 0.57, 0.8, 1],
            ),
          ),
        ),
      ),
    ),
    const Positioned(
      left: 116,
      top: 157,
      width: 708,
      height: 3,
      child: _ProjectedDecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF29475D),
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    ),
    Positioned(
      left: 116,
      top: 157,
      width: 476,
      height: 3,
      child: _ProjectedDecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(2),
            right: Radius.circular(2),
          ),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF3DAEFF), Color(0xFFF5B941)],
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x663DAEFF), blurRadius: 8),
          ],
        ),
      ),
    ),
    Semantics(
      key: const ValueKey<String>('precheckProgress'),
      container: true,
      explicitChildNodes: true,
      label: copy.flowStep,
      child: _ProjectedStack(
        children: <Widget>[
          _CanonicalStep(
            left: 15,
            top: 131,
            number: 1,
            label: copy.steps[0],
            state: _CanonicalStepState.completed,
          ),
          _CanonicalStep(
            left: 248,
            top: 131,
            number: 2,
            label: copy.steps[1],
            state: _CanonicalStepState.completed,
          ),
          _CanonicalStep(
            left: 487,
            top: 131,
            number: 3,
            label: copy.steps[2],
            state: _CanonicalStepState.active,
          ),
          _CanonicalStep(
            left: 720,
            top: 131,
            number: 4,
            label: copy.steps[3],
            state: _CanonicalStepState.pending,
          ),
        ],
      ),
    ),
  ];

  Widget _hero(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckHero'),
    left: 37,
    top: 232,
    width: 853,
    height: 254,
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      label: copy.heroTitle,
      child: _ProjectedComponent(
        designWidth: 853,
        designHeight: 254,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF5B941)),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Color(0xFF0A2032),
                Color(0xFF071726),
                Color(0xFF0D1A25),
              ],
              stops: <double>[0, 0.62, 1],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: _ProjectedClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _ProjectedStack(
              children: <Widget>[
                const Positioned(
                  left: 620,
                  top: -90,
                  width: 340,
                  height: 330,
                  child: _RadialGlow(centerColor: Color(0x30F5B941)),
                ),
                const Positioned(
                  left: 690,
                  top: 18,
                  width: 220,
                  height: 220,
                  child: _Orbit(color: Color(0x66F5B941)),
                ),
                const Positioned(
                  left: 745,
                  top: 73,
                  width: 110,
                  height: 110,
                  child: _Orbit(color: Color(0x40F5B941)),
                ),
                const Positioned(
                  left: 760,
                  top: 42,
                  width: 9,
                  height: 9,
                  child: _ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5B941),
                    ),
                  ),
                ),
                const Positioned(
                  left: 820,
                  top: 186,
                  width: 7,
                  height: 7,
                  child: _ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5B941),
                    ),
                  ),
                ),
                const Positioned(
                  left: 30,
                  top: 33,
                  width: 176,
                  height: 176,
                  child: _ShieldAuthority(),
                ),
                _localText(
                  text: copy.heroTitle,
                  left: 227,
                  top: 39,
                  width: 290,
                  height: 49,
                  size: 34,
                  weight: FontWeight.w700,
                  rasterWeight: 650,
                  scaleX: 0.996,
                ),
                _localText(
                  text: copy.heroDescription,
                  left: 228,
                  top: 88,
                  width: 570,
                  height: 56,
                  size: 20,
                  lineHeight: 1.42,
                  color: PencilCompatibilityVisualSpec.muted,
                  scaleX: 0.989,
                  maxLines: 2,
                ),
                _heroStatusPill(context),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _heroStatusPill(BuildContext context) {
    final statusStyle = _style(
      size: 19,
      weight: FontWeight.w600,
      color: const Color(0xFFF5B941),
    );
    final statusPainter = TextPainter(
      text: TextSpan(text: copy.heroStatus, style: statusStyle),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final requiredDesignWidth = 15 + 24 + 10 + statusPainter.width;
    statusPainter.dispose();
    final usesAcceptedDesignWidth = requiredDesignWidth <= 186;
    final content = _ProjectedDecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF102B22),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFF5E8E55)),
      ),
      child: Row(
        mainAxisSize: usesAcceptedDesignWidth
            ? MainAxisSize.max
            : MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: _px(context, 15)),
          _ProjectedIcon(
            PhosphorIcons.checkCircleLight,
            size: 24,
            color: const Color(0xFFF5B941),
          ),
          SizedBox(width: _px(context, 10)),
          Text(copy.heroStatus, style: statusStyle),
        ],
      ),
    );

    return Positioned(
      left: 228,
      top: 192,
      width: usesAcceptedDesignWidth ? 186 : 320,
      height: 42,
      child: usesAcceptedDesignWidth
          ? content
          : Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 186, maxWidth: 320),
                child: IntrinsicWidth(child: content),
              ),
            ),
    );
  }

  Widget _summaryCard(BuildContext context) => _card(
    context: context,
    key: const ValueKey<String>('precheckSummary'),
    semanticsLabel: copy.summaryTitle,
    top: 495,
    height: 258,
    title: copy.summaryTitle,
    titleIcon: PhosphorIcons.clipboardTextLight,
    titleTop: 15,
    iconTop: 19,
    titleRasterWeight: null,
    rows: <Widget>[
      for (var index = 0; index < copy.summaryRows.length; index++)
        _CanonicalDataRow(
          top: 49 + index * 41,
          height: 44,
          icon: _summaryIcons[index],
          label: copy.summaryRows[index].label,
          value: copy.summaryRows[index].value,
          iconColor: index == 3
              ? const Color(0xFFF5B941)
              : PencilCompatibilityVisualSpec.muted,
          valueColor: index == 3
              ? const Color(0xFFF5B941)
              : PencilCompatibilityVisualSpec.text,
          labelSize: 19,
          valueSize: 18,
          iconSize: 26,
          dividerVisible: index != copy.summaryRows.length - 1,
        ),
    ],
  );

  Widget _resultsCard(BuildContext context) => _card(
    context: context,
    key: const ValueKey<String>('precheckResults'),
    semanticsLabel: copy.resultsTitle,
    top: 760,
    height: 284,
    title: copy.resultsTitle,
    titleIcon: PhosphorIcons.checksLight,
    titleTop: 14,
    iconTop: 18,
    titleRasterWeight: 650,
    rows: <Widget>[
      for (var index = 0; index < copy.resultRows.length; index++)
        _CanonicalDataRow(
          top: 49 + index * 38,
          height: 38,
          icon: _resultIcons[index],
          label: copy.resultRows[index].label,
          value: copy.resultRows[index].value,
          iconColor: index == 4
              ? const Color(0xFFF5B941)
              : PencilCompatibilityVisualSpec.muted,
          valueColor: index == 4
              ? const Color(0xFFF5B941)
              : PencilCompatibilityVisualSpec.text,
          labelSize: 17,
          valueSize: 17,
          iconSize: 24,
          dividerVisible: index != copy.resultRows.length - 1,
        ),
      Positioned(
        left: 21,
        top: 244,
        width: 811,
        height: 30,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF081F31),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1A5277)),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: _px(context, 12)),
              _ProjectedIcon(
                PhosphorIcons.infoLight,
                size: 20,
                color: const Color(0xFF3DAEFF),
              ),
              SizedBox(width: _px(context, 10)),
              Expanded(
                child: Text(
                  copy.technicalDetail,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: _style(
                    size: 16,
                    color: PencilCompatibilityVisualSpec.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _recordsCard(BuildContext context) => _card(
    context: context,
    key: const ValueKey<String>('precheckRecords'),
    semanticsLabel: copy.recordsTitle,
    top: 1051,
    height: 217,
    title: copy.recordsTitle,
    titleIcon: PhosphorIcons.filesLight,
    titleTop: 13,
    iconTop: 17,
    titleRasterWeight: 650,
    rows: <Widget>[
      _CanonicalRecordTile(
        top: 52,
        icon: PhosphorIcons.textTLight,
        record: copy.records[0],
      ),
      _CanonicalRecordTile(
        top: 121,
        icon: PhosphorIcons.linkLight,
        record: copy.records[1],
      ),
      _localIcon(
        icon: PhosphorIcons.infoLight,
        left: 29,
        top: 193,
        width: 17,
        height: 17,
        size: 17,
        color: PencilCompatibilityVisualSpec.dim,
      ),
      _localText(
        text: copy.recordsNotice,
        left: 54,
        top: 190,
        width: 316,
        height: 22,
        size: 15,
        rasterWeight: 450,
        color: PencilCompatibilityVisualSpec.dim,
      ),
    ],
  );

  Widget _guidanceCard(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckGuidance'),
    left: 36,
    top: 1277,
    width: 855,
    height: 171,
    child: _ProjectedComponent(
      designWidth: 855,
      designHeight: 171,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: copy.guidanceTitle,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF513F22), width: 2),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Color(0xFF1A1710),
                Color(0xFF0B1720),
                Color(0xFF07131E),
              ],
              stops: <double>[0, 0.55, 1],
            ),
          ),
          child: _ProjectedPadding(
            padding: const EdgeInsets.all(1),
            child: _ProjectedClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: _ProjectedStack(
                children: <Widget>[
                  const Positioned(
                    left: -90,
                    top: -130,
                    width: 340,
                    height: 340,
                    child: _RadialGlow(centerColor: Color(0x26F5B941)),
                  ),
                  _localIcon(
                    icon: PhosphorIcons.lightbulbLight,
                    left: 25,
                    top: 17,
                    width: 27,
                    height: 27,
                    size: 27,
                    color: const Color(0xFFF5B941),
                  ),
                  _localText(
                    text: copy.guidanceTitle,
                    left: 63,
                    top: 13,
                    width: 220,
                    height: 39,
                    size: 27,
                    weight: FontWeight.w700,
                  ),
                  for (
                    var index = 0;
                    index < copy.guidanceLines.length;
                    index++
                  ) ...<Widget>[
                    _localIcon(
                      icon: PhosphorIcons.checkCircle,
                      left: 29,
                      top: 51 + index * 29,
                      width: 20,
                      height: 20,
                      size: 20,
                      color: const Color(0xFFF5B941),
                    ),
                    _localText(
                      text: copy.guidanceLines[index],
                      left: 60,
                      top: 49 + index * 29,
                      width: 590,
                      height: 25,
                      size: 17,
                      weight: FontWeight.w300,
                      letterSpacing: -0.2,
                      rasterWeight: 250,
                      color: PencilCompatibilityVisualSpec.muted,
                      scaleX: 1.009,
                    ),
                  ],
                  Positioned(
                    left: 19,
                    top: 134,
                    width: 815,
                    height: 28,
                    child: _ProjectedDecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF493A1B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _ProjectedPadding(
                        padding: const EdgeInsets.all(1),
                        child: _ProjectedDecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF574118),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: _ProjectedPadding(
                            padding: const EdgeInsets.all(1),
                            child: _ProjectedDecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFF30250F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _ProjectedTranslate(
                                offset: const Offset(-1, -1),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: _px(context, 11)),
                                    _ProjectedIcon(
                                      PhosphorIcons.warningLight,
                                      size: 18,
                                      color: const Color(0xFFF5B941),
                                    ),
                                    SizedBox(width: _px(context, 9)),
                                    Expanded(
                                      child: Transform.scale(
                                        alignment: Alignment.centerLeft,
                                        scaleX: 0.99,
                                        scaleY: 1,
                                        child: Text(
                                          copy.commitmentNotice,
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                          style: _style(
                                            size: 15,
                                            weight: FontWeight.w500,
                                            letterSpacing: 0.15,
                                            rasterWeight: 330,
                                            color: const Color(0xFFF5B941),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _primaryAction(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckPrimaryAction'),
    left: 36,
    top: 1455,
    width: 855,
    height: 72,
    child: _ProjectedComponent(
      designWidth: 855,
      designHeight: 72,
      child: Semantics(
        button: true,
        label: copy.primaryAction,
        child: ExcludeSemantics(
          child: _ProjectedDecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFF75D9FF), width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x333DAEFF),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _ProjectedPadding(
              padding: const EdgeInsets.all(2),
              child: _ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[
                      Color(0xFF1467A4),
                      Color(0xFF1C9BE8),
                      Color(0xFF20B6F5),
                    ],
                    stops: <double>[0, 0.5, 1],
                  ),
                ),
                child: _ProjectedTranslate(
                  offset: const Offset(-1, -1),
                  child: _ProjectedStack(
                    children: <Widget>[
                      const Positioned(
                        left: 20,
                        top: 5,
                        width: 813,
                        height: 1,
                        child: _ProjectedHairline(color: Color(0x88B9EEFF)),
                      ),
                      const Positioned(
                        left: 281,
                        top: 18,
                        width: 34,
                        height: 34,
                        child: _ProjectedIcon(
                          PhosphorIcons.shieldCheckLight,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      _localText(
                        text: copy.primaryAction,
                        left: 331,
                        top: 14,
                        width: 300,
                        height: 42,
                        size: 29,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> _primarySupplementalGlows(BuildContext context) =>
      const <Widget>[
        Positioned(
          left: 19,
          top: 1440,
          width: 889,
          height: 8,
          child: _ProjectedComponent(
            designWidth: 889,
            designHeight: 8,
            child: IgnorePointer(
              child: _ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x0A3DAEFF),
                      Color(0x163DAEFF),
                      Color(0x133DAEFF),
                    ],
                    stops: <double>[0, 0.7, 1],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 19,
          top: 1448,
          width: 889,
          height: 5,
          child: _ProjectedComponent(
            designWidth: 889,
            designHeight: 5,
            child: IgnorePointer(
              child: _ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x213DAEFF), Color(0x303DAEFF)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 19,
          top: 1529,
          width: 889,
          height: 17,
          child: _ProjectedComponent(
            designWidth: 889,
            designHeight: 17,
            child: IgnorePointer(
              child: _ProjectedDecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x303DAEFF), Color(0x0D3DAEFF)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ];

  List<Widget> _secondaryActions(BuildContext context) => <Widget>[
    _CanonicalSecondaryAction(
      left: 37,
      width: 408,
      iconLeft: 78,
      labelLeft: 122,
      icon: PhosphorIcons.listMagnifyingGlassLight,
      iconScaleX: 1.08,
      iconScaleY: 1.625,
      label: copy.secondaryActions[0],
    ),
    _CanonicalSecondaryAction(
      left: 474,
      width: 416,
      iconLeft: 82,
      labelLeft: 126,
      icon: PhosphorIcons.pencilSimpleLight,
      iconScaleX: 1.04,
      iconScaleY: 1,
      label: copy.secondaryActions[1],
    ),
  ];

  List<Widget> _footer(BuildContext context) => <Widget>[
    const Positioned(
      left: 37,
      top: 1606,
      width: 853,
      height: 1,
      child: _ProjectedHairline(color: Color(0xFF244056)),
    ),
    Positioned(
      key: const ValueKey<String>('precheckEndFlowAction'),
      left: 351,
      top: 1618,
      width: 209,
      height: 29,
      child: Semantics(
        button: true,
        label: copy.endFlowAction,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ProjectedPadding(
                padding: const EdgeInsets.only(top: 6),
                child: _ProjectedIcon(
                  PhosphorIcons.xCircleLight,
                  size: 22,
                  color: PencilCompatibilityVisualSpec.dim,
                ),
              ),
              SizedBox(width: _px(context, 11)),
              SizedBox(
                width: _px(context, 143),
                child: Text(
                  copy.endFlowAction,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: _style(
                    size: 20,
                    weight: FontWeight.w500,
                    color: PencilCompatibilityVisualSpec.muted,
                  ),
                ),
              ),
              _ProjectedPadding(
                padding: const EdgeInsets.only(top: 6),
                child: _ProjectedIcon(
                  PhosphorIcons.caretRightLight,
                  size: 22,
                  color: PencilCompatibilityVisualSpec.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ];

  Widget _card({
    required BuildContext context,
    required Key key,
    required String semanticsLabel,
    required double top,
    required double height,
    required String title,
    required IconData titleIcon,
    required double titleTop,
    required double iconTop,
    required double? titleRasterWeight,
    required List<Widget> rows,
  }) => Positioned(
    key: key,
    left: 36,
    top: top - 1,
    width: 855,
    height: height + 2,
    child: _ProjectedComponent(
      designWidth: 855,
      designHeight: height + 2,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticsLabel,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2E4151), width: 2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFF0A1927), Color(0xFF06121E)],
            ),
          ),
          child: _ProjectedPadding(
            padding: const EdgeInsets.all(1),
            child: _ProjectedClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: _ProjectedStack(
                children: <Widget>[
                  _localIcon(
                    icon: titleIcon,
                    left: 25,
                    top: iconTop,
                    width: 28,
                    height: 28,
                    size: 28,
                    color: const Color(0xFF3DAEFF),
                  ),
                  _localText(
                    text: title,
                    left: 63,
                    top: titleTop,
                    width: 300,
                    height: 39,
                    size: 27,
                    weight: FontWeight.w700,
                    rasterWeight: titleRasterWeight,
                  ),
                  ...rows,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

const _summaryIcons = <IconData>[
  PhosphorIcons.tagLight,
  PhosphorIcons.filesLight,
  PhosphorIcons.databaseLight,
  PhosphorIcons.arrowsClockwiseLight,
  PhosphorIcons.lockKeyLight,
];

const _resultIcons = <IconData>[
  PhosphorIcons.sealCheckLight,
  PhosphorIcons.hardDrivesLight,
  PhosphorIcons.lockOpenLight,
  PhosphorIcons.broadcastLight,
  PhosphorIcons.shieldCheckLight,
];

class _CanonicalBackground extends StatelessWidget {
  const _CanonicalBackground();

  @override
  Widget build(BuildContext context) => const _ProjectedDecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF06111D),
          Color(0xFF020A12),
          Color(0xFF01060B),
        ],
        stops: <double>[0, 0.46, 1],
      ),
    ),
  );
}

class _CanonicalAmbientGlows extends StatelessWidget {
  const _CanonicalAmbientGlows({required this.projection});

  final WritePrecheckProjection projection;

  @override
  Widget build(BuildContext context) => const _ProjectedStack(
    children: <Widget>[
      Positioned(
        left: 470,
        top: -180,
        width: 560,
        height: 430,
        child: _RadialGlow(centerColor: Color(0x401D91D9)),
      ),
      Positioned(
        left: -240,
        top: 100,
        width: 520,
        height: 520,
        child: _RadialGlow(centerColor: Color(0x2C064974)),
      ),
    ],
  );
}

enum _CanonicalStepState { completed, active, pending }

class _CanonicalStep extends StatelessWidget {
  const _CanonicalStep({
    required this.left,
    required this.top,
    required this.number,
    required this.label,
    required this.state,
  });

  final double left;
  final double top;
  final int number;
  final String label;
  final _CanonicalStepState state;

  @override
  Widget build(BuildContext context) {
    final active = state == _CanonicalStepState.active;
    final completed = state == _CanonicalStepState.completed;
    final glyphLeft = active || number == 4 ? 96.0 : 94.0;
    final glyphWidth = active
        ? 15.0
        : number == 4
        ? 14.0
        : 18.0;
    final glyphHeight = active || number == 4 ? 35.0 : 36.0;
    final glyphSize = active || number == 4 ? 24.0 : 25.0;
    final glowColor = active
        ? const Color(0x66F5B941)
        : completed
        ? const Color(0x443DAEFF)
        : const Color(0x18536B7E);
    final circleFill = active
        ? const Color(0xFF0A2033)
        : completed
        ? const Color(0xFF082A46)
        : const Color(0xFF05111C);
    final accent = active
        ? const Color(0xFFF5B941)
        : completed
        ? const Color(0xFF3DAEFF)
        : const Color(0xFF4B6173);
    final contentColor = active
        ? const Color(0xFFF5B941)
        : completed
        ? const Color(0xFF74D8FF)
        : const Color(0xFF7F94A7);

    return Positioned(
      left: left,
      top: top,
      width: 205,
      height: 88,
      child: Semantics(
        container: true,
        label: '$number. $label',
        child: ExcludeSemantics(
          child: _ProjectedStack(
            children: <Widget>[
              if (completed)
                const Positioned(
                  left: 65,
                  top: -10,
                  width: 76,
                  height: 76,
                  child: _RadialGlow(centerColor: Color(0x553DAEFF)),
                ),
              Positioned(
                left: active ? 65 : 75,
                top: active ? -10 : 0,
                width: active ? 76 : 56,
                height: active ? 76 : 56,
                child: active
                    ? const _ActiveStepGlow()
                    : _RadialGlow(centerColor: glowColor),
              ),
              Positioned(
                left: 81,
                top: 6,
                width: 44,
                height: 44,
                child: _ProjectedDecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleFill,
                    border: Border.all(color: accent, width: active ? 2 : 1),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: active
                            ? const Color(0x33F5B941)
                            : completed
                            ? const Color(0x333DAEFF)
                            : Colors.transparent,
                        blurRadius: active ? 14 : 12,
                        spreadRadius: active ? 2 : 1,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: glyphLeft,
                top: number == 4 ? 11 : 10,
                width: glyphWidth,
                height: glyphHeight,
                child: Text(
                  completed ? '✓' : '$number',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: _style(
                    size: glyphSize,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: contentColor,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 60,
                width: 205,
                height: 25,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: _style(
                    size: 17,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    rasterWeight: 450,
                    color: active
                        ? const Color(0xFFF5B941)
                        : completed
                        ? PencilCompatibilityVisualSpec.muted
                        : PencilCompatibilityVisualSpec.dim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanonicalDataRow extends StatelessWidget {
  const _CanonicalDataRow({
    required this.top,
    required this.height,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.valueColor,
    required this.labelSize,
    required this.valueSize,
    required this.iconSize,
    required this.dividerVisible,
  });

  final double top;
  final double height;
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color valueColor;
  final double labelSize;
  final double valueSize;
  final double iconSize;
  final bool dividerVisible;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 16,
    top: top,
    width: 820,
    height: height,
    child: _ProjectedStack(
      children: <Widget>[
        if (dividerVisible)
          Positioned(
            left: 0,
            bottom: 0,
            width: 820,
            height: 1,
            child: const _ProjectedHairline(color: Color(0xFF244056)),
          ),
        Positioned(
          left: 18,
          top: height == 44 ? 9 : 6,
          width: iconSize,
          height: iconSize,
          child: _ProjectedIcon(icon, size: iconSize, color: iconColor),
        ),
        Positioned(
          left: 58,
          top: height == 44 ? 8 : 5,
          width: 260,
          height: height == 44 ? 28 : 25,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: _style(
              size: labelSize,
              weight: FontWeight.w500,
              rasterWeight: 350,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
        Positioned(
          left: 385,
          top: height == 44 ? 8 : 5,
          width: 415,
          height: height == 44 ? 28 : 25,
          child: Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.clip,
            style: _style(
              size: valueSize,
              rasterWeight: 400,
              color: valueColor,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CanonicalRecordTile extends StatelessWidget {
  const _CanonicalRecordTile({
    required this.top,
    required this.icon,
    required this.record,
  });

  final double top;
  final IconData icon;
  final WritePrecheckRecordCopy record;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 15,
    top: top - 1,
    width: 822,
    height: 68,
    child: _ProjectedDecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF162B3C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: _ProjectedPadding(
        padding: const EdgeInsets.all(2),
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF071522),
            borderRadius: BorderRadius.circular(13),
          ),
          child: _ProjectedTranslate(
            offset: const Offset(-1, -1),
            child: _ProjectedStack(
              children: <Widget>[
                Positioned(
                  left: 10,
                  top: 7,
                  width: 62,
                  height: 52,
                  child: _ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2440),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0A4A82)),
                    ),
                    child: Center(
                      child: _ProjectedIcon(
                        icon,
                        size: 30,
                        color: const Color(0xFF74D8FF),
                      ),
                    ),
                  ),
                ),
                _localText(
                  text: record.title,
                  left: 91,
                  top: 8,
                  width: 400,
                  height: 29,
                  size: 20,
                  weight: FontWeight.w500,
                  rasterWeight: 450,
                ),
                _localText(
                  text: record.value,
                  left: 92,
                  top: 35,
                  width: 450,
                  height: 25,
                  size: 17,
                  color: PencilCompatibilityVisualSpec.muted,
                ),
                Positioned(
                  left: 665,
                  top: 16,
                  width: 108,
                  height: 34,
                  child: _ProjectedDecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1A2A),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFF244056)),
                    ),
                    child: Center(
                      child: Text(
                        record.badge,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: _style(
                          size: 15,
                          weight: FontWeight.w500,
                          rasterWeight: 450,
                          color: PencilCompatibilityVisualSpec.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 785,
                  top: 21,
                  width: 22,
                  height: 22,
                  child: Transform.scale(
                    alignment: Alignment.topCenter,
                    scaleY: 1.75,
                    child: const _ProjectedIcon(
                      PhosphorIcons.caretRightLight,
                      size: 22,
                      color: PencilCompatibilityVisualSpec.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _CanonicalSecondaryAction extends StatelessWidget {
  const _CanonicalSecondaryAction({
    required this.left,
    required this.width,
    required this.iconLeft,
    required this.labelLeft,
    required this.icon,
    required this.iconScaleX,
    required this.iconScaleY,
    required this.label,
  });

  final double left;
  final double width;
  final double iconLeft;
  final double labelLeft;
  final IconData icon;
  final double iconScaleX;
  final double iconScaleY;
  final String label;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left - 1,
    top: 1536,
    width: width + 2,
    height: 60,
    child: _ProjectedComponent(
      designWidth: width + 2,
      designHeight: 60,
      child: Semantics(
        button: true,
        label: label,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFF3DAEFF), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x223DAEFF), blurRadius: 10),
            ],
          ),
          child: _ProjectedPadding(
            padding: const EdgeInsets.all(2),
            child: _ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFF08233A), Color(0xFF020A12)],
                ),
              ),
              child: _ProjectedTranslate(
                offset: const Offset(-1, -1),
                child: ExcludeSemantics(
                  child: _ProjectedStack(
                    children: <Widget>[
                      Positioned(
                        left: iconLeft - 1,
                        top: 14,
                        width: 30,
                        height: 30,
                        child: Transform.scale(
                          scaleX: iconScaleX,
                          scaleY: iconScaleY,
                          child: _ProjectedIcon(
                            icon,
                            size: 30,
                            color: const Color(0xFF3DAEFF),
                          ),
                        ),
                      ),
                      Positioned(
                        left: labelLeft,
                        top: 10,
                        width: 190,
                        height: 35,
                        child: Transform.scale(
                          alignment: Alignment.centerLeft,
                          scaleX: 0.986,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: _style(
                              size: 24,
                              weight: FontWeight.w500,
                              rasterWeight: 500,
                              color: const Color(0xFF3DAEFF),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ShieldAuthority extends StatelessWidget {
  const _ShieldAuthority();

  @override
  Widget build(BuildContext context) => _ProjectedStack(
    children: <Widget>[
      const Positioned.fill(child: _RadialGlow(centerColor: Color(0x503DAEFF))),
      Positioned(
        left: 18,
        top: 18,
        width: 140,
        height: 140,
        child: _ProjectedDecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2676A7), width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x553DAEFF),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const _ProjectedPadding(
            padding: EdgeInsets.all(2),
            child: _ProjectedDecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF061726),
              ),
            ),
          ),
        ),
      ),
      const Positioned(
        left: 45,
        top: 44,
        width: 86,
        height: 86,
        child: _ProjectedIcon(
          PhosphorIcons.shieldCheck,
          size: 86,
          color: Color(0xFF74D8FF),
        ),
      ),
    ],
  );
}

class _Orbit extends StatelessWidget {
  const _Orbit({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => _ProjectedDecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color),
    ),
  );
}

class _ActiveStepGlow extends StatelessWidget {
  const _ActiveStepGlow();

  @override
  Widget build(BuildContext context) => const _ProjectedDecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: <Color>[
          Color(0x66F5B941),
          Color(0x223DAEFF),
          Color(0x003DAEFF),
        ],
        stops: <double>[0, 0.55, 1],
      ),
    ),
  );
}

class _RadialGlow extends StatelessWidget {
  const _RadialGlow({required this.centerColor});

  final Color centerColor;

  @override
  Widget build(BuildContext context) => _ProjectedDecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: <Color>[centerColor, centerColor.withAlpha(0)],
      ),
    ),
  );
}

Positioned _positionedText({
  Key? key,
  String? semanticsLabel,
  required String text,
  required double left,
  required double top,
  required double width,
  required double height,
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = PencilCompatibilityVisualSpec.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
  double scaleX = 1,
  TextAlign textAlign = TextAlign.left,
  int maxLines = 1,
}) => Positioned(
  key: key,
  left: left,
  top: top,
  width: width,
  height: height,
  child: Transform.scale(
    alignment: Alignment.topLeft,
    scaleX: scaleX,
    scaleY: 1,
    child: semanticsLabel == null
        ? Text(
            text,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: TextOverflow.clip,
            style: _style(
              size: size,
              weight: weight,
              color: color,
              lineHeight: lineHeight,
              letterSpacing: letterSpacing,
              rasterWeight: rasterWeight,
            ),
          )
        : Semantics(
            label: semanticsLabel,
            child: ExcludeSemantics(
              child: Text(
                text,
                maxLines: maxLines,
                textAlign: textAlign,
                overflow: TextOverflow.clip,
                style: _style(
                  size: size,
                  weight: weight,
                  color: color,
                  lineHeight: lineHeight,
                  letterSpacing: letterSpacing,
                  rasterWeight: rasterWeight,
                ),
              ),
            ),
          ),
  ),
);

Positioned _positionedIcon({
  required IconData icon,
  required double left,
  required double top,
  required double width,
  required double height,
  required double size,
  Color color = PencilCompatibilityVisualSpec.text,
  double scaleX = 1,
  double scaleY = 1,
}) => Positioned(
  left: left,
  top: top,
  width: width,
  height: height,
  child: Transform.scale(
    scaleX: scaleX,
    scaleY: scaleY,
    child: _ProjectedIcon(icon, size: size, color: color),
  ),
);

Positioned _localText({
  required String text,
  required double left,
  required double top,
  required double width,
  required double height,
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = PencilCompatibilityVisualSpec.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
  double scaleX = 1,
  int maxLines = 1,
}) => _positionedText(
  text: text,
  left: left,
  top: top,
  width: width,
  height: height,
  size: size,
  weight: weight,
  color: color,
  lineHeight: lineHeight,
  letterSpacing: letterSpacing,
  rasterWeight: rasterWeight,
  scaleX: scaleX,
  maxLines: maxLines,
);

Positioned _localIcon({
  required IconData icon,
  required double left,
  required double top,
  required double width,
  required double height,
  required double size,
  required Color color,
}) => _positionedIcon(
  icon: icon,
  left: left,
  top: top,
  width: width,
  height: height,
  size: size,
  color: color,
);

TextStyle _style({
  required double size,
  FontWeight weight = FontWeight.w400,
  Color color = PencilCompatibilityVisualSpec.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
}) => TextStyle(
  fontFamily: PencilCompatibilityVisualSpec.fontFamily,
  fontFamilyFallback: PencilCompatibilityVisualSpec.fontFamilyFallback,
  fontSize: size,
  fontWeight: _pencilRasterWeight(weight),
  fontVariations: rasterWeight == null
      ? null
      : <ui.FontVariation>[ui.FontVariation('wght', rasterWeight)],
  height: lineHeight,
  letterSpacing: letterSpacing,
  color: color,
);

FontWeight _pencilRasterWeight(FontWeight weight) {
  if (weight.value <= FontWeight.w200.value) {
    return weight;
  }
  if (weight.value >= FontWeight.w700.value) {
    return FontWeight.w600;
  }
  if (weight.value >= FontWeight.w500.value) {
    return FontWeight.w400;
  }
  return FontWeight.w300;
}
