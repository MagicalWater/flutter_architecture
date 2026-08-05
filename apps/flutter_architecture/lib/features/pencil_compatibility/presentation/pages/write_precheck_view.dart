import 'package:flutter/material.dart';
import 'package:flutter_architecture/features/pencil_compatibility/presentation/write_precheck_copy.dart';

class WritePrecheckView extends StatelessWidget {
  const WritePrecheckView({required this.copy, super.key});

  final WritePrecheckCopy copy;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: Text(copy.title))),
  );
}
