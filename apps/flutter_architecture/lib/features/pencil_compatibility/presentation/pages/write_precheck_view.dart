import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/pages/write_precheck_projected_canvas.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/visual_spec/pencil_compatibility_visual_spec.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';

class WritePrecheckView extends StatelessWidget {
  const WritePrecheckView({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: PencilCompatibilityVisualSpec.background,
    body: LayoutBuilder(
      builder: (context, constraints) {
        final projectedWidth = math.min(
          constraints.maxWidth,
          WritePrecheckProjection.designWidth,
        );
        return SingleChildScrollView(
          key: const ValueKey<String>('writePrecheckScrollView'),
          child: Center(
            child: WritePrecheckProjectedCanvas(
              copy: copy,
              availableWidth: projectedWidth,
            ),
          ),
        );
      },
    ),
  );
}
