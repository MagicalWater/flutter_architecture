import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Desktop SQLite 初始化。
///
/// Android / iOS 的 sqflite 會使用原生實作，不需要 FFI。
///
/// Windows / macOS / Linux 則需要使用 sqflite_common_ffi，
/// 否則呼叫 openDatabase 時會出現 databaseFactory 尚未初始化的錯誤。
Future<void> initializeDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
