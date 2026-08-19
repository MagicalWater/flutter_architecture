import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/layout/write_precheck_projection.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/widgets/write_precheck/write_precheck_palette.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WritePrecheckBackground extends StatelessWidget {
  const WritePrecheckBackground({super.key});

  @override
  Widget build(BuildContext context) => const ProjectedDecoratedBox(
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

class WritePrecheckAmbientGlows extends StatelessWidget {
  const WritePrecheckAmbientGlows({required this.projection, super.key});

  final WritePrecheckProjection projection;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: projection.px(470),
          top: projection.px(-180),
          width: projection.px(560),
          height: projection.px(430),
          child: const WritePrecheckRadialGlow(centerColor: Color(0x401D91D9)),
        ),
        Positioned(
          left: projection.px(-240),
          top: projection.px(100),
          width: projection.px(520),
          height: projection.px(520),
          child: const WritePrecheckRadialGlow(centerColor: Color(0x2C064974)),
        ),
      ],
    ),
  );
}

class WritePrecheckShieldAuthority extends StatelessWidget {
  const WritePrecheckShieldAuthority({super.key});

  @override
  Widget build(BuildContext context) => ProjectedStack(
    children: <Widget>[
      const Positioned.fill(
        child: WritePrecheckRadialGlow(centerColor: Color(0x503DAEFF)),
      ),
      Positioned(
        left: 18,
        top: 18,
        width: 140,
        height: 140,
        child: ProjectedDecoratedBox(
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
          child: const ProjectedPadding(
            padding: EdgeInsets.all(2),
            child: ProjectedDecoratedBox(
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
        child: ProjectedIcon(
          PhosphorIcons.shieldCheck,
          size: 86,
          color: WritePrecheckPalette.cyanAccent,
        ),
      ),
    ],
  );
}

class WritePrecheckOrbit extends StatelessWidget {
  const WritePrecheckOrbit({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) => ProjectedDecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color),
    ),
  );
}

class WritePrecheckActiveStepGlow extends StatelessWidget {
  const WritePrecheckActiveStepGlow({super.key});

  @override
  Widget build(BuildContext context) => const ProjectedDecoratedBox(
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

class WritePrecheckRadialGlow extends StatelessWidget {
  const WritePrecheckRadialGlow({required this.centerColor, super.key});

  final Color centerColor;

  @override
  Widget build(BuildContext context) => ProjectedDecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: <Color>[centerColor, centerColor.withAlpha(0)],
      ),
    ),
  );
}
