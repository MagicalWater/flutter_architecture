import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_content_components.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckSummaryCard extends StatelessWidget {
  const WritePrecheckSummaryCard({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => _InfoCardFrame(
    key: const ValueKey<String>('precheckSummary'),
    semanticsLabel: copy.summaryTitle,
    height: 258,
    title: copy.summaryTitle,
    titleIcon: PhosphorIcons.clipboardTextLight,
    titleTop: 15,
    iconTop: 19,
    rows: <Widget>[
      for (var index = 0; index < copy.summaryRows.length; index++)
        SizedBox(
          height: 41,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minHeight: 44,
            maxHeight: 44,
            child: WritePrecheckDataRow(
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
          ),
        ),
    ],
  );
}

class WritePrecheckResultsCard extends StatelessWidget {
  const WritePrecheckResultsCard({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => _InfoCardFrame(
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
        WritePrecheckDataRow(
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
      const SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(left: 21, right: 21),
        child: SizedBox(
          height: 30,
          child: ProjectedDecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF081F31),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1A5277)),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(width: projectedPx(context, 12)),
                const ProjectedIcon(
                  PhosphorIcons.infoLight,
                  size: 20,
                  color: Color(0xFF3DAEFF),
                ),
                SizedBox(width: projectedPx(context, 10)),
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
      ),
    ],
  );
}

class WritePrecheckRecordsCard extends StatelessWidget {
  const WritePrecheckRecordsCard({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => _InfoCardFrame(
    key: const ValueKey<String>('precheckRecords'),
    semanticsLabel: copy.recordsTitle,
    height: 217,
    title: copy.recordsTitle,
    titleIcon: PhosphorIcons.filesLight,
    titleTop: 13,
    iconTop: 17,
    titleRasterWeight: 650,
    rows: <Widget>[
      const SizedBox(height: 2),
      WritePrecheckRecordTile(
        icon: PhosphorIcons.textTLight,
        record: copy.records[0],
      ),
      const SizedBox(height: 1),
      WritePrecheckRecordTile(
        icon: PhosphorIcons.linkLight,
        record: copy.records[1],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 29, top: 2, right: 19),
        child: SizedBox(
          height: 25,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: ProjectedIcon(
                  PhosphorIcons.infoLight,
                  size: 17,
                  color: WritePrecheckPalette.dim,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 316,
                height: 22,
                child: Text(
                  copy.recordsNotice,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: _style(
                    size: 15,
                    rasterWeight: 450,
                    color: WritePrecheckPalette.dim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _InfoCardFrame extends StatelessWidget {
  const _InfoCardFrame({
    required this.semanticsLabel,
    required this.height,
    required this.title,
    required this.titleIcon,
    required this.titleTop,
    required this.iconTop,
    required this.rows,
    this.titleRasterWeight,
    super.key,
  });

  final String semanticsLabel;
  final double height;
  final String title;
  final IconData titleIcon;
  final double titleTop;
  final double iconTop;
  final double? titleRasterWeight;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: EdgeInsets.only(left: projectedPx(context, 36)),
      child: SizedBox(
        width: projectedPx(context, 855),
        height: projectedPx(context, height + 2),
        child: ProjectedComponent(
          designWidth: 855,
          designHeight: height + 2,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: semanticsLabel,
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E4151), width: 2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFF0A1927), Color(0xFF06121E)],
                ),
              ),
              child: ProjectedPadding(
                padding: const EdgeInsets.all(1),
                child: ProjectedClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 49,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 19),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: iconTop),
                                child: ProjectedIcon(
                                  titleIcon,
                                  size: 28,
                                  color: const Color(0xFF3DAEFF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: EdgeInsets.only(top: titleTop),
                                child: SizedBox(
                                  width: 300,
                                  height: 39,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: _style(
                                      size: 27,
                                      weight: FontWeight.w700,
                                      rasterWeight: titleRasterWeight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ...rows,
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
