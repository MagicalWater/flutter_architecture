import 'package:flutter/material.dart';
import 'package:flutter_architecture/app/app.dart';
import 'package:flutter_architecture/app/database/database_initializer.dart';
import 'package:flutter_architecture/app/di/injection.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App 啟動時先初始化跨平台 SQLite databaseFactory。
  //
  // Mobile、Desktop、Web 對 sqflite 的初始化方式不同，
  // 因此透過條件匯入隔離平台差異，避免 Web 編譯碰到 dart:io。
  await initializeDatabaseFactory();

  // App 啟動時先完成 DI 註冊；ApiConfig 由 App Composition Root 提供。
  await configureDependencies();

  runApp(
    HookedBlocConfigProvider(
      // hooked_bloc 會透過這個 injector 從 get_it 取得 Bloc/Cubit。
      injector: () => getIt.get,
      child: const ArchitectureApp(),
    ),
  );
}
