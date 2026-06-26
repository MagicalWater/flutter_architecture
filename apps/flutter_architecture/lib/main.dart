import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App 啟動時先完成 DI 註冊。
  await configureDependencies();

  runApp(
    HookedBlocConfigProvider(
      // hooked_bloc 會透過這個 injector 從 get_it 取得 Bloc/Cubit。
      injector: () => getIt.get,
      child: const ArchitectureApp(),
    ),
  );
}
