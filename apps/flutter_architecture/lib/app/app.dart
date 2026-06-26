import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:flutter_architecture/app/router/app_router.dart';

/// App 入口 Widget。
///
/// ## 所屬 Layer
///
/// App composition layer。
///
/// 它負責把 Router、Theme、全域設定組合起來。
class ArchitectureApp extends StatefulWidget {
  const ArchitectureApp({super.key});

  @override
  State<ArchitectureApp> createState() => _ArchitectureAppState();
}

class _ArchitectureAppState extends State<ArchitectureApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = getIt<AppRouter>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: _router.config(),
    );
  }
}
