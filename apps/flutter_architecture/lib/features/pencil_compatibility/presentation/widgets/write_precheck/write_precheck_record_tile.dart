import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckRecordTile extends StatelessWidget {
  const WritePrecheckRecordTile({
    required this.icon,
    required this.record,
    super.key,
  });

  static const _tileHeight = 68.0;
  static const _caretOpticalScaleY = 1.75;

  final IconData icon;
  final WritePrecheckRecordCopy record;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 15, right: 16),
    child: SizedBox(
      height: _tileHeight,
      child: ProjectedDecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF162B3C),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ProjectedPadding(
          padding: const EdgeInsets.all(2),
          child: ProjectedDecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF071522),
              borderRadius: BorderRadius.circular(13),
            ),
            child: ProjectedTranslate(
              offset: const Offset(-1, -1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: SizedBox(
                      width: 62,
                      height: 52,
                      child: ProjectedDecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A2440),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF0A4A82)),
                        ),
                        child: Center(
                          child: ProjectedIcon(
                            icon,
                            size: 30,
                            color: WritePrecheckPalette.cyanAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 19),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 27,
                            child: OverflowBox(
                              alignment: Alignment.topLeft,
                              minHeight: 29,
                              maxHeight: 29,
                              child: SizedBox(
                                width: 400,
                                height: 29,
                                child: Text(
                                  record.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: writePrecheckTextStyle(
                                    size: 20,
                                    weight: FontWeight.w500,
                                    rasterWeight: 450,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 1),
                            child: SizedBox(
                              width: 449,
                              height: 25,
                              child: Text(
                                record.value,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: writePrecheckTextStyle(
                                  size: 17,
                                  color: WritePrecheckPalette.muted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 124),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 108,
                      height: 34,
                      child: ProjectedDecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1A2A),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: WritePrecheckPalette.subtleOutline,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            record.badge,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: writePrecheckTextStyle(
                              size: 15,
                              weight: FontWeight.w500,
                              rasterWeight: 450,
                              color: WritePrecheckPalette.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 21),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Transform.scale(
                        alignment: Alignment.topCenter,
                        scaleY: _caretOpticalScaleY,
                        child: const ProjectedIcon(
                          PhosphorIcons.caretRightLight,
                          size: 22,
                          color: WritePrecheckPalette.muted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
