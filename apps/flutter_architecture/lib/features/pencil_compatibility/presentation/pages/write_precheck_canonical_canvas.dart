import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckCanonicalCanvas extends StatelessWidget {
  const WritePrecheckCanonicalCanvas({required this.copy, super.key});

  final WritePrecheckCopy copy;

  static const Size size = Size(941, 1672);

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: size,
    child: ClipRect(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          const Positioned.fill(child: _CanonicalBackground()),
          const _CanonicalAmbientGlows(),
          ..._statusBar(),
          ..._header(),
          ..._progress(),
          _hero(),
          _summaryCard(),
          _resultsCard(),
          _recordsCard(),
          _guidanceCard(),
          ..._primarySupplementalGlows(),
          _primaryAction(),
          ..._secondaryActions(),
          ..._footer(),
        ],
      ),
    ),
  );

  List<Widget> _statusBar() => <Widget>[
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

  List<Widget> _header() => <Widget>[
    const Positioned(
      left: 0,
      top: 48,
      width: 941,
      height: 1,
      child: ColoredBox(color: Color(0xFF163147)),
    ),
    Positioned(
      left: 29,
      top: 64,
      width: 50,
      height: 50,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF071725),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF284A62)),
          ),
          child: const Center(
            child: Icon(
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

  List<Widget> _progress() => <Widget>[
    const Positioned(
      left: 112,
      top: 148,
      width: 482,
      height: 21,
      child: IgnorePointer(
        child: DecoratedBox(
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
      child: DecoratedBox(
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
      child: DecoratedBox(
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
      child: Stack(
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

  Widget _hero() => Positioned(
    key: const ValueKey<String>('precheckHero'),
    left: 37,
    top: 232,
    width: 853,
    height: 254,
    child: Semantics(
      container: true,
      label: copy.heroTitle,
      child: DecoratedBox(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
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
                child: DecoratedBox(
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
                child: DecoratedBox(
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
              Positioned(
                left: 228,
                top: 192,
                width: 186,
                height: 42,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF102B22),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: const Color(0xFF5E8E55)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 15),
                      const Icon(
                        PhosphorIcons.checkCircle,
                        size: 24,
                        color: Color(0xFFF5B941),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        copy.heroStatus,
                        style: _style(
                          size: 19,
                          weight: FontWeight.w600,
                          color: const Color(0xFFF5B941),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _summaryCard() => _card(
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

  Widget _resultsCard() => _card(
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF081F31),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1A5277)),
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 12),
              const Icon(
                PhosphorIcons.infoLight,
                size: 20,
                color: Color(0xFF3DAEFF),
              ),
              const SizedBox(width: 10),
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

  Widget _recordsCard() => _card(
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

  Widget _guidanceCard() => Positioned(
    key: const ValueKey<String>('precheckGuidance'),
    left: 36,
    top: 1277,
    width: 855,
    height: 171,
    child: Semantics(
      container: true,
      label: copy.guidanceTitle,
      child: DecoratedBox(
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
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF493A1B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF574118),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF30250F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Transform.translate(
                              offset: const Offset(-1, -1),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(width: 11),
                                  const Icon(
                                    PhosphorIcons.warningLight,
                                    size: 18,
                                    color: Color(0xFFF5B941),
                                  ),
                                  const SizedBox(width: 9),
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
  );

  Widget _primaryAction() => Positioned(
    key: const ValueKey<String>('precheckPrimaryAction'),
    left: 36,
    top: 1455,
    width: 855,
    height: 72,
    child: Semantics(
      button: true,
      label: copy.primaryAction,
      child: DecoratedBox(
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
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
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
            child: Transform.translate(
              offset: const Offset(-1, -1),
              child: Stack(
                children: <Widget>[
                  const Positioned(
                    left: 20,
                    top: 5,
                    width: 813,
                    height: 1,
                    child: ColoredBox(color: Color(0x88B9EEFF)),
                  ),
                  const Positioned(
                    left: 281,
                    top: 18,
                    width: 34,
                    height: 34,
                    child: Icon(
                      PhosphorIcons.shieldCheck,
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
  );

  List<Widget> _primarySupplementalGlows() => const <Widget>[
    Positioned(
      left: 19,
      top: 1440,
      width: 889,
      height: 8,
      child: IgnorePointer(
        child: DecoratedBox(
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
    Positioned(
      left: 19,
      top: 1448,
      width: 889,
      height: 5,
      child: IgnorePointer(
        child: DecoratedBox(
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
    Positioned(
      left: 19,
      top: 1529,
      width: 889,
      height: 17,
      child: IgnorePointer(
        child: DecoratedBox(
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
  ];

  List<Widget> _secondaryActions() => <Widget>[
    _CanonicalSecondaryAction(
      left: 37,
      width: 408,
      iconLeft: 78,
      labelLeft: 122,
      icon: PhosphorIcons.listMagnifyingGlass,
      label: copy.secondaryActions[0],
    ),
    _CanonicalSecondaryAction(
      left: 474,
      width: 416,
      iconLeft: 82,
      labelLeft: 126,
      icon: PhosphorIcons.pencilSimple,
      label: copy.secondaryActions[1],
    ),
  ];

  List<Widget> _footer() => <Widget>[
    const Positioned(
      left: 37,
      top: 1606,
      width: 853,
      height: 1,
      child: ColoredBox(color: Color(0xFF244056)),
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
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  PhosphorIcons.xCircleLight,
                  size: 22,
                  color: PencilCompatibilityVisualSpec.dim,
                ),
              ),
              const SizedBox(width: 11),
              SizedBox(
                width: 143,
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
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
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
    child: Semantics(
      container: true,
      label: semanticsLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2E4151), width: 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF0A1927), Color(0xFF06121E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
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
  Widget build(BuildContext context) => const DecoratedBox(
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
  const _CanonicalAmbientGlows();

  @override
  Widget build(BuildContext context) => const Stack(
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
          child: Stack(
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
                child: DecoratedBox(
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
    child: Stack(
      children: <Widget>[
        if (dividerVisible)
          Positioned(
            left: 0,
            bottom: 0,
            width: 820,
            height: 1,
            child: const ColoredBox(color: Color(0xFF244056)),
          ),
        Positioned(
          left: 18,
          top: height == 44 ? 9 : 6,
          width: iconSize,
          height: iconSize,
          child: Icon(icon, size: iconSize, color: iconColor),
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
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF162B3C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF071522),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Transform.translate(
            offset: const Offset(-1, -1),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 10,
                  top: 7,
                  width: 62,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2440),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0A4A82)),
                    ),
                    child: Center(
                      child: Icon(
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
                  child: DecoratedBox(
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
                    child: const Icon(
                      PhosphorIcons.caretRight,
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
    required this.label,
  });

  final double left;
  final double width;
  final double iconLeft;
  final double labelLeft;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left - 1,
    top: 1536,
    width: width + 2,
    height: 60,
    child: Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFF3DAEFF), width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x223DAEFF), blurRadius: 10),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF08233A), Color(0xFF020A12)],
              ),
            ),
            child: Transform.translate(
              offset: const Offset(-1, -1),
              child: ExcludeSemantics(
                child: Stack(
                  children: <Widget>[
                  Positioned(
                    left: iconLeft - 1,
                    top: 14,
                      width: 30,
                      height: 30,
                      child: Transform.scale(
                        scaleX: 1.08,
                        scaleY: 1.625,
                        child: Icon(
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
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: _style(
                          size: 24,
                          weight: FontWeight.w500,
                          color: const Color(0xFF3DAEFF),
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
  );
}

class _ShieldAuthority extends StatelessWidget {
  const _ShieldAuthority();

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      const Positioned.fill(child: _RadialGlow(centerColor: Color(0x503DAEFF))),
      Positioned(
        left: 18,
        top: 18,
        width: 140,
        height: 140,
        child: DecoratedBox(
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
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: DecoratedBox(
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
        child: Icon(
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
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color),
    ),
  );
}

class _ActiveStepGlow extends StatelessWidget {
  const _ActiveStepGlow();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
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
  Widget build(BuildContext context) => DecoratedBox(
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
    child: Icon(icon, size: size, color: color),
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
  if (weight.index <= FontWeight.w200.index) {
    return weight;
  }
  if (weight.index >= FontWeight.w700.index) {
    return FontWeight.w600;
  }
  if (weight.index >= FontWeight.w500.index) {
    return FontWeight.w400;
  }
  return FontWeight.w300;
}
