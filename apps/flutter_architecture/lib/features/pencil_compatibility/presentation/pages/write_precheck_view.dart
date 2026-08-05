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
                    DsSpace.xl,
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
                          const SizedBox(height: DsSpace.sm),
                          _Header(copy: copy),
                          const SizedBox(height: DsSpace.lg),
                          Semantics(
                            key: const ValueKey<String>('precheckProgress'),
                            container: true,
                            label: copy.flowStep,
                            child: PrecheckProgress(labels: copy.steps),
                          ),
                          const SizedBox(height: DsSpace.lg),
                          _Hero(copy: copy),
                          const SizedBox(height: DsSpace.lg),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckSummary'),
                            title: copy.summaryTitle,
                            icon: PhosphorIcons.clipboardText,
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
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: DsSpace.lg),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckResults'),
                            title: copy.resultsTitle,
                            icon: PhosphorIcons.checks,
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
                                  ),
                                _TechnicalBar(label: copy.technicalDetail),
                              ],
                            ),
                          ),
                          const SizedBox(height: DsSpace.lg),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckRecords'),
                            title: copy.recordsTitle,
                            icon: PhosphorIcons.files,
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
                                  ),
                                  if (index != copy.records.length - 1)
                                    const SizedBox(height: DsSpace.sm),
                                ],
                                const SizedBox(height: DsSpace.md),
                                _Notice(
                                  label: copy.recordsNotice,
                                  color: PencilCompatibilityVisualSpec.cyan,
                                  icon: PhosphorIcons.info,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: DsSpace.lg),
                          PrecheckSectionCard(
                            key: const ValueKey<String>('precheckGuidance'),
                            title: copy.guidanceTitle,
                            icon: PhosphorIcons.lightbulb,
                            accent: PencilCompatibilityVisualSpec.gold,
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
                                  ),
                                  if (index != copy.guidanceLines.length - 1)
                                    const SizedBox(height: DsSpace.sm),
                                ],
                                const SizedBox(height: DsSpace.md),
                                _Notice(
                                  label: copy.commitmentNotice,
                                  color: PencilCompatibilityVisualSpec.gold,
                                  icon: PhosphorIcons.warning,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: DsSpace.lg),
                          PrecheckActions(
                            primaryLabel: copy.primaryAction,
                            secondaryLabels: copy.secondaryActions,
                            endFlowLabel: copy.endFlowAction,
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
  const _Header({required this.copy});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const ValueKey<String>('precheckHeader'),
    container: true,
    explicitChildNodes: true,
    label: copy.title,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: DsSpace.sm),
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
          const SizedBox(width: DsSpace.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  copy.title,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: 28,
                    weight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: DsSpace.xxs),
                Text(
                  copy.flowStep,
                  style: PencilCompatibilityVisualSpec.textStyle(
                    size: 14,
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
  const _Hero({required this.copy});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Semantics(
    key: const ValueKey<String>('precheckHero'),
    container: true,
    explicitChildNodes: true,
    label: copy.heroTitle,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final stacks = constraints.maxWidth < 560;
        final shield = const _ShieldHalo();
        final content = Column(
          crossAxisAlignment: stacks
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              copy.heroTitle,
              textAlign: stacks ? TextAlign.center : TextAlign.left,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: 30,
                weight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: DsSpace.sm),
            Text(
              copy.heroDescription,
              textAlign: stacks ? TextAlign.center : TextAlign.left,
              style: PencilCompatibilityVisualSpec.textStyle(
                size: 15,
                color: PencilCompatibilityVisualSpec.muted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: DsSpace.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DsSpace.md,
                vertical: DsSpace.xs,
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
                  size: 14,
                  color: PencilCompatibilityVisualSpec.gold,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DsSpace.lg),
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
                    const SizedBox(height: DsSpace.lg),
                    content,
                  ],
                )
              : Row(
                  children: <Widget>[
                    shield,
                    const SizedBox(width: DsSpace.xl),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    ),
  );
}

class _ShieldHalo extends StatelessWidget {
  const _ShieldHalo();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 112,
      height: 112,
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
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: PencilCompatibilityVisualSpec.backgroundDeep.withAlpha(190),
          border: Border.all(color: PencilCompatibilityVisualSpec.gold),
        ),
        alignment: Alignment.center,
        child: const Icon(
          PhosphorIcons.shieldCheck,
          size: 42,
          color: PencilCompatibilityVisualSpec.gold,
        ),
      ),
    ),
  );
}

class _TechnicalBar extends StatelessWidget {
  const _TechnicalBar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: DsSpace.md),
    padding: const EdgeInsets.all(DsSpace.sm),
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
        const Icon(
          PhosphorIcons.listMagnifyingGlass,
          size: 19,
          color: PencilCompatibilityVisualSpec.cyanBright,
        ),
        const SizedBox(width: DsSpace.xs),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: 13,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GuidanceLine extends StatelessWidget {
  const _GuidanceLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(DsSpace.sm),
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
        Icon(icon, size: 20, color: PencilCompatibilityVisualSpec.gold),
        const SizedBox(width: DsSpace.sm),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: 14,
              color: PencilCompatibilityVisualSpec.muted,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(DsSpace.sm),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(DsRadius.lg),
      border: Border.all(color: color.withAlpha(100)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 19, color: color),
        const SizedBox(width: DsSpace.xs),
        Expanded(
          child: Text(
            label,
            style: PencilCompatibilityVisualSpec.textStyle(
              size: 13,
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
