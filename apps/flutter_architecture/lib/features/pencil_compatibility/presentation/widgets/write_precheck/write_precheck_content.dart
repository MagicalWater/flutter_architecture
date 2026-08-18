import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content_components.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_visual_primitives.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

typedef _ProjectionTextScaler = ProjectionTextScaler;
typedef _ProjectionScope = ProjectionScope;
typedef _ProjectedDecoratedBox = ProjectedDecoratedBox;
typedef _ProjectedPadding = ProjectedPadding;
typedef _ProjectedClipRRect = ProjectedClipRRect;
typedef _ProjectedIcon = ProjectedIcon;
typedef _ProjectedHairline = ProjectedHairline;
typedef _ProjectedComponent = ProjectedComponent;
typedef _ProjectedTranslate = ProjectedTranslate;
typedef _ProjectedStack = ProjectedStack;
typedef _CanonicalBackground = WritePrecheckBackground;
typedef _CanonicalAmbientGlows = WritePrecheckAmbientGlows;
typedef _ShieldAuthority = WritePrecheckShieldAuthority;
typedef _Orbit = WritePrecheckOrbit;
typedef _RadialGlow = WritePrecheckRadialGlow;
typedef _CanonicalStep = WritePrecheckStep;
typedef _CanonicalDataRow = WritePrecheckDataRow;
typedef _CanonicalRecordTile = WritePrecheckRecordTile;
typedef _CanonicalSecondaryAction = WritePrecheckSecondaryAction;

double _px(BuildContext context, double designPixels) =>
    projectedPx(context, designPixels);

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

class _ProjectedScreen extends StatelessWidget {
  const _ProjectedScreen({required this.copy});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) {
    final projection = _ProjectionScope.of(context);
    return SizedBox(
      width: projection.px(WritePrecheckProjection.designWidth),
      child: ClipRect(
        child: Stack(
          alignment: AlignmentDirectional.topStart,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            const Positioned.fill(child: _CanonicalBackground()),
            Positioned.fill(
              child: _CanonicalAmbientGlows(projection: projection),
            ),
            ..._primarySupplementalGlows(projection),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _flowRegion(
                  context,
                  designHeight: 220,
                  children: <Widget>[
                    _topChrome(context),
                    _progressComponent(context),
                  ],
                ),
                _flowGap(context, 12),
                _flowRegion(
                  context,
                  designHeight: 254,
                  children: <Widget>[_hero(context)],
                ),
                _flowGap(context, 8),
                _flowRegion(
                  context,
                  designHeight: 260,
                  children: <Widget>[_summaryCard(context)],
                ),
                _flowGap(context, 5),
                _flowRegion(
                  context,
                  designHeight: 286,
                  children: <Widget>[_resultsCard(context)],
                ),
                _flowGap(context, 5),
                _flowRegion(
                  context,
                  designHeight: 219,
                  children: <Widget>[_recordsCard(context)],
                ),
                _flowGap(context, 8),
                _flowRegion(
                  context,
                  designHeight: 171,
                  children: <Widget>[
                    _guidanceCard(context),
                    _guidanceTrailingGlow(),
                  ],
                ),
                _flowRegion(
                  context,
                  designHeight: 7,
                  children: <Widget>[_primaryLeadingGlow()],
                ),
                _flowRegion(
                  context,
                  designHeight: 72,
                  children: <Widget>[_primaryAction(context)],
                ),
                _flowGap(context, 9),
                _flowRegion(
                  context,
                  designHeight: 60,
                  children: _secondaryActions(context),
                ),
                _flowGap(context, 10),
                _flowRegion(
                  context,
                  designHeight: 66,
                  children: _footer(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowGap(BuildContext context, double designHeight) =>
      SizedBox(height: _px(context, designHeight));

  Widget _flowRegion(
    BuildContext context, {
    required double designHeight,
    required List<Widget> children,
  }) => SizedBox(
    width: _px(context, WritePrecheckProjection.designWidth),
    height: _px(context, designHeight),
    child: _ProjectedStack(children: children),
  );

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
              color: WritePrecheckPalette.text,
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
      color: WritePrecheckPalette.muted,
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
            state: WritePrecheckStepState.completed,
          ),
          _CanonicalStep(
            left: 248,
            top: 131,
            number: 2,
            label: copy.steps[1],
            state: WritePrecheckStepState.completed,
          ),
          _CanonicalStep(
            left: 487,
            top: 131,
            number: 3,
            label: copy.steps[2],
            state: WritePrecheckStepState.active,
          ),
          _CanonicalStep(
            left: 720,
            top: 131,
            number: 4,
            label: copy.steps[3],
            state: WritePrecheckStepState.pending,
          ),
        ],
      ),
    ),
  ];

  Widget _hero(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckHero'),
    left: 37,
    top: 0,
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
                  color: WritePrecheckPalette.muted,
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
              : WritePrecheckPalette.muted,
          valueColor: index == 3
              ? const Color(0xFFF5B941)
              : WritePrecheckPalette.text,
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
              : WritePrecheckPalette.muted,
          valueColor: index == 4
              ? const Color(0xFFF5B941)
              : WritePrecheckPalette.text,
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
                  style: _style(size: 16, color: WritePrecheckPalette.muted),
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
        color: WritePrecheckPalette.dim,
      ),
      _localText(
        text: copy.recordsNotice,
        left: 54,
        top: 190,
        width: 316,
        height: 22,
        size: 15,
        rasterWeight: 450,
        color: WritePrecheckPalette.dim,
      ),
    ],
  );

  Widget _guidanceCard(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckGuidance'),
    left: 36,
    top: 0,
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
                      color: WritePrecheckPalette.muted,
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

  Widget _guidanceTrailingGlow() => const Positioned(
    left: 19,
    top: 163,
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
  );

  Widget _primaryLeadingGlow() => const Positioned(
    left: 19,
    top: 0,
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
  );

  Widget _primaryAction(BuildContext context) => Positioned(
    key: const ValueKey<String>('precheckPrimaryAction'),
    left: 36,
    top: 0,
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

  List<Widget> _primarySupplementalGlows(WritePrecheckProjection projection) =>
      <Widget>[
        Positioned(
          left: projection.px(19),
          top: projection.px(1529),
          width: projection.px(889),
          height: projection.px(17),
          child: const _ProjectedComponent(
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
      top: 0,
      width: 853,
      height: 1,
      child: _ProjectedHairline(color: Color(0xFF244056)),
    ),
    Positioned(
      key: const ValueKey<String>('precheckEndFlowAction'),
      left: 351,
      top: 12,
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
                  color: WritePrecheckPalette.dim,
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
                    color: WritePrecheckPalette.muted,
                  ),
                ),
              ),
              _ProjectedPadding(
                padding: const EdgeInsets.only(top: 6),
                child: _ProjectedIcon(
                  PhosphorIcons.caretRightLight,
                  size: 22,
                  color: WritePrecheckPalette.dim,
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
    top: 0,
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
  Color color = WritePrecheckPalette.text,
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
  Color color = WritePrecheckPalette.text,
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
  Color color = WritePrecheckPalette.text,
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
  Color color = WritePrecheckPalette.text,
  double? lineHeight,
  double? letterSpacing,
  double? rasterWeight,
}) => writePrecheckTextStyle(
  size: size,
  weight: weight,
  color: color,
  lineHeight: lineHeight,
  letterSpacing: letterSpacing,
  rasterWeight: rasterWeight,
);
