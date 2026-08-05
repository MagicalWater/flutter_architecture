import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_actions.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_data_row.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_progress.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_record_tile.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/precheck_section_card.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckView extends StatelessWidget {
  const WritePrecheckView({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: PencilCompatibilityVisualSpec.background,
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: PencilCompatibilityVisualSpec.pageGradient,
      ),
      child: Stack(
        children: <Widget>[
          const _AmbientGlow(
            alignment: Alignment(-1.2, -0.8),
            color: PencilCompatibilityVisualSpec.cyan,
          ),
          const _AmbientGlow(
            alignment: Alignment(1.25, -0.25),
            color: PencilCompatibilityVisualSpec.gold,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dense = constraints.maxWidth >= 800;
                final sectionGap = dense ? 12.0 : DsSpace.lg;
                final horizontalPadding = constraints.maxWidth >= 900
                    ? 44.0
                    : constraints.maxWidth >= 600
                    ? DsSpace.xl
                    : constraints.maxWidth >= 320
                    ? DsSpace.md
                    : DsSpace.sm;

                return SingleChildScrollView(
                  key: const ValueKey<String>('writePrecheckScrollView'),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    DsSpace.sm,
                    horizontalPadding,
                    dense ? DsSpace.xs : DsSpace.xl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: PencilCompatibilityVisualSpec.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const _StatusBar(),
                          SizedBox(height: dense ? DsSpace.xxs : DsSpace.sm),
                          _Header(copy: copy, dense: dense),
                          SizedBox(height: sectionGap),
                          Semantics(
                            key: const ValueKey<String>('precheckProgress'),
                            container: true,
                            explicitChildNodes: true,
                            label: copy.flowStep,
                            child: PrecheckProgress(
                              labels: copy.steps,
                              dense: dense,
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          _Hero(copy: copy, dense: dense),
                          SizedBox(height: sectionGap),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckSummary'),
                            title: copy.summaryTitle,
                            icon: PhosphorIcons.clipboardText,
                            dense: dense,
                            child: Column(
                              children: <Widget>[
                                for (
                                  var index = 0;
                                  index < copy.summaryRows.length;
                                  index++
                                )
                                  PrecheckDataRow(
                                    icon: _summaryIcons[index],
                                    label: copy.summaryRows[index].label,
                                    value: copy.summaryRows[index].value,
                                    showDivider:
                                        index != copy.summaryRows.length - 1,
                                    dense: dense,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckResults'),
                            title: copy.resultsTitle,
                            icon: PhosphorIcons.checks,
                            dense: dense,
                            child: Column(
                              children: <Widget>[
                                for (
                                  var index = 0;
                                  index < copy.resultRows.length;
                                  index++
                                )
                                  PrecheckDataRow(
                                    icon: _resultIcons[index],
                                    label: copy.resultRows[index].label,
                                    value: copy.resultRows[index].value,
                                    compact: true,
                                    showDivider: true,
                                    accent: PencilCompatibilityVisualSpec.gold,
                                    dense: dense,
                                  ),
                                _TechnicalBar(
                                  label: copy.technicalDetail,
                                  dense: dense,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckRecords'),
                            title: copy.recordsTitle,
                            icon: PhosphorIcons.files,
                            dense: dense,
                            child: Column(
                              children: <Widget>[
                                for (
                                  var index = 0;
                                  index < copy.records.length;
                                  index++
                                ) ...<Widget>[
                                  PrecheckRecordTile(
                                    icon: index == 0
                                        ? PhosphorIcons.textT
                                        : PhosphorIcons.link,
                                    title: copy.records[index].title,
                                    value: copy.records[index].value,
                                    badge: copy.records[index].badge,
                                    dense: dense,
                                  ),
                                  if (index != copy.records.length - 1)
                                    SizedBox(
                                      height: dense ? DsSpace.xs : DsSpace.sm,
                                    ),
                                ],
                                SizedBox(
                                  height: dense ? DsSpace.xs : DsSpace.md,
                                ),
                                _Notice(
                                  label: copy.recordsNotice,
                                  color: PencilCompatibilityVisualSpec.cyan,
                                  icon: PhosphorIcons.info,
                                  dense: dense,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckGuidance'),
                            title: copy.guidanceTitle,
                            icon: PhosphorIcons.lightbulb,
                            accent: PencilCompatibilityVisualSpec.gold,
                            dense: dense,
                            child: Column(
                              children: <Widget>[
                                for (
                                  var index = 0;
                                  index < copy.guidanceLines.length;
                                  index++
                                ) ...<Widget>[
                                  _GuidanceLine(
                                    icon: _guidanceIcons[index],
                                    label: copy.guidanceLines[index],
                                    dense: dense,
                                  ),
                                  if (index != copy.guidanceLines.length - 1)
                                    SizedBox(
                                      height: dense ? DsSpace.xs : DsSpace.sm,
                                    ),
                                ],
                                SizedBox(
                                  height: dense ? DsSpace.xs : DsSpace.md,
                                ),
                                _Notice(
                                  label: copy.commitmentNotice,
                                  color: PencilCompatibilityVisualSpec.gold,
                                  icon: PhosphorIcons.warning,
                                  dense: dense,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sectionGap),
                          PrecheckActions(
                            primaryLabel: copy.primaryAction,
                            secondaryLabels: copy.secondaryActions,
                            endFlowLabel: copy.endFlowAction,
                            dense: dense,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

const _summaryIcons = <IconData>[
  PhosphorIcons.tag,
  PhosphorIcons.files,
  PhosphorIcons.database,
  PhosphorIcons.arrowsClockwise,
  PhosphorIcons.lockKey,
];

const _resultIcons = <IconData>[
  PhosphorIcons.sealCheck,
  PhosphorIcons.hardDrives,
  PhosphorIcons.lockOpen,
  PhosphorIcons.broadcast,
  PhosphorIcons.checkCircle,
];

const _guidanceIcons = <IconData>[
  PhosphorIcons.tag,
  PhosphorIcons.broadcast,
  PhosphorIcons.shieldCheck,
];

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Row(
      children: <Widget>[
        Text(
          '9:41',
          style: PencilCompatibilityVisualSpec.textStyle(
            size: 14,
            weight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        const Icon(
          PhosphorIcons.cellSignalHigh,
          size: 17,
          color: PencilCompatibilityVisualSpec.text,
        ),
        const SizedBox(width: DsSpace.xs),
        const Icon(
          PhosphorIcons.wifiHigh,
          size: 17,
          color: PencilCompatibilityVisualSpec.text,
        ),
        const SizedBox(width: DsSpace.xs),
        const Icon(
          PhosphorIcons.batteryFull,
          size: 19,
          color: PencilCompatibilityVisualSpec.text,
        ),
        const SizedBox(width: DsSpace.xxs),
        Text('100%', style: PencilCompatibilityVisualSpec.textStyle(size: 12)),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.copy, required this.dense});

  final WritePrecheckCopy copy;
  final bool dense;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const ValueKey<String>('precheckHeader'),
    container: true,
    explicitChildNodes: true,
    label: copy.title,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: dense ? 2 : DsSpace.sm),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: PencilCompatibilityVisualSpec.borderSoft),
        ),
      ),
      child: Row(
        children: <Widget>[
          ExcludeSemantics(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                PhosphorIcons.arrowLeft,
                color: PencilCompatibilityVisualSpec.text,
              ),
            ),
          ),
          SizedBox(width: dense ? DsSpace.xxs : DsSpace.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  copy.title,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: dense ? 24 : 28,
                    weight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: dense ? 2 : DsSpace.xxs),
                Text(
                  copy.flowStep,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: dense ? 12 : 14,
                    color: PencilCompatibilityVisualSpec.muted,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.copy, required this.dense});

  final WritePrecheckCopy copy;
  final bool dense;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const ValueKey<String>('precheckHero'),
    container: true,
    explicitChildNodes: true,
    label: copy.heroTitle,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final stacks = constraints.maxWidth < 560;
        final shield = _ShieldHalo(dense: dense);
        final content = Column(
          crossAxisAlignment: stacks
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              copy.heroTitle,
              textAlign: stacks ? TextAlign.center : TextAlign.left,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: dense ? 24 : 30,
                weight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            SizedBox(height: dense ? DsSpace.xs : DsSpace.sm),
            Text(
              copy.heroDescription,
              textAlign: stacks ? TextAlign.center : TextAlign.left,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: dense ? 13 : 15,
                color: PencilCompatibilityVisualSpec.muted,
                height: dense ? 1.35 : 1.55,
              ),
            ),
            SizedBox(height: dense ? DsSpace.xs : DsSpace.md),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: dense ? DsSpace.sm : DsSpace.md,
                vertical: dense ? DsSpace.xxs : DsSpace.xs,
              ),
              decoration: BoxDecoration(
                color: PencilCompatibilityVisualSpec.gold.withAlpha(28),
                borderRadius: BorderRadius.circular(
                  PencilCompatibilityVisualSpec.pillRadius,
                ),
                border: Border.all(
                  color: PencilCompatibilityVisualSpec.gold.withAlpha(140),
                ),
              ),
              child: Text(
                copy.heroStatus,
                style: PencilCompatibilityVisualSpec.textStyle(
                  size: dense ? 12 : 14,
                  color: PencilCompatibilityVisualSpec.gold,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(dense ? DsSpace.md : DsSpace.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                PencilCompatibilityVisualSpec.surfaceRaised,
                PencilCompatibilityVisualSpec.surface,
                Color(0xFF131A20),
              ],
            ),
            borderRadius: BorderRadius.circular(
              PencilCompatibilityVisualSpec.cardRadius,
            ),
            border: Border.all(
              color: PencilCompatibilityVisualSpec.gold,
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: PencilCompatibilityVisualSpec.gold.withAlpha(58),
                blurRadius: 22,
                spreadRadius: 1,
              ),
            ],
          ),
          child: stacks
              ? Column(
                  children: <Widget>[
                    shield,
                    SizedBox(height: dense ? DsSpace.sm : DsSpace.lg),
                    content,
                  ],
                )
              : Row(
                  children: <Widget>[
                    shield,
                    SizedBox(width: dense ? DsSpace.md : DsSpace.xl),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    ),
  );
}

class _ShieldHalo extends StatelessWidget {
  const _ShieldHalo({this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: dense ? 88 : 112,
      height: dense ? 88 : 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            PencilCompatibilityVisualSpec.gold.withAlpha(75),
            PencilCompatibilityVisualSpec.gold.withAlpha(10),
          ],
        ),
        border: Border.all(
          color: PencilCompatibilityVisualSpec.gold.withAlpha(150),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: PencilCompatibilityVisualSpec.gold.withAlpha(90),
            blurRadius: 22,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: dense ? 58 : 74,
        height: dense ? 58 : 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PencilCompatibilityVisualSpec.backgroundDeep.withAlpha(190),
          border: Border.all(color: PencilCompatibilityVisualSpec.gold),
        ),
        alignment: Alignment.center,
        child: Icon(
          PhosphorIcons.shieldCheck,
          size: dense ? 32 : 42,
          color: PencilCompatibilityVisualSpec.gold,
        ),
      ),
    ),
  );
}

class _TechnicalBar extends StatelessWidget {
  const _TechnicalBar({required this.label, required this.dense});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: dense ? DsSpace.xs : DsSpace.md),
    padding: EdgeInsets.all(dense ? DsSpace.xs : DsSpace.sm),
    decoration: BoxDecoration(
      color: PencilCompatibilityVisualSpec.cyan.withAlpha(16),
      borderRadius: BorderRadius.circular(DsRadius.lg),
      border: Border.all(
        color: PencilCompatibilityVisualSpec.cyan.withAlpha(75),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          PhosphorIcons.listMagnifyingGlass,
          size: dense ? 16 : 19,
          color: PencilCompatibilityVisualSpec.cyanBright,
        ),
        SizedBox(width: dense ? DsSpace.xxs : DsSpace.xs),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: dense ? 11.5 : 13,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuidanceLine extends StatelessWidget {
  const _GuidanceLine({
    required this.icon,
    required this.label,
    required this.dense,
  });

  final IconData icon;
  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(dense ? DsSpace.xs : DsSpace.sm),
    decoration: BoxDecoration(
      color: PencilCompatibilityVisualSpec.background.withAlpha(120),
      borderRadius: BorderRadius.circular(
        PencilCompatibilityVisualSpec.guidanceRadius,
      ),
      border: Border.all(color: PencilCompatibilityVisualSpec.borderSoft),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: dense ? 16 : 20,
          color: PencilCompatibilityVisualSpec.gold,
        ),
        SizedBox(width: dense ? DsSpace.xs : DsSpace.sm),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: dense ? 12 : 14,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.label,
    required this.color,
    required this.icon,
    required this.dense,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(dense ? DsSpace.xs : DsSpace.sm),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(DsRadius.lg),
      border: Border.all(color: color.withAlpha(100)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: dense ? 16 : 19, color: color),
        SizedBox(width: dense ? DsSpace.xxs : DsSpace.xs),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: dense ? 11.5 : 13,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.alignment, required this.color});

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: ExcludeSemantics(
        child: Align(
          alignment: alignment,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[color.withAlpha(30), Colors.transparent],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
