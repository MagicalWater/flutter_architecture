import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_text_style.dart';

class WritePrecheckSecondaryAction extends StatelessWidget {
  const WritePrecheckSecondaryAction({
    required this.surfaceWidth,
    required this.icon,
    required this.iconScaleX,
    required this.iconScaleY,
    required this.label,
    super.key,
  });

  static const _referenceSurfaceWidth = 410.0;
  static const _referenceLeadingInset = 77.0;
  static const _labelOpticalScaleX = 0.986;

  final double surfaceWidth;
  final IconData icon;
  final double iconScaleX;
  final double iconScaleY;
  final String label;

  double get _centeredLeadingInset =>
      _referenceLeadingInset + (surfaceWidth - _referenceSurfaceWidth) / 2;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: projectedPx(context, surfaceWidth),
    height: projectedPx(context, 60),
    child: ProjectedComponent(
      designWidth: surfaceWidth,
      designHeight: 60,
      child: Semantics(
        button: true,
        label: label,
        child: ProjectedDecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: WritePrecheckPalette.blueAccent,
              width: 2,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x223DAEFF), blurRadius: 10),
            ],
          ),
          child: ProjectedPadding(
            padding: const EdgeInsets.all(2),
            child: ProjectedDecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFF08233A), Color(0xFF020A12)],
                ),
              ),
              child: ProjectedTranslate(
                offset: const Offset(-1, -1),
                child: ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _centeredLeadingInset,
                      top: 10,
                    ),
                    child: SizedBox(
                      width: 235,
                      height: 35,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Transform.scale(
                              scaleX: iconScaleX,
                              scaleY: iconScaleY,
                              child: ProjectedIcon(
                                icon,
                                size: 30,
                                color: WritePrecheckPalette.blueAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: 190,
                            height: 35,
                            child: Transform.scale(
                              alignment: Alignment.centerLeft,
                              scaleX: _labelOpticalScaleX,
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: writePrecheckTextStyle(
                                  size: 24,
                                  weight: FontWeight.w500,
                                  rasterWeight: 500,
                                  color: WritePrecheckPalette.blueAccent,
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
      ),
    ),
  );
}
