import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web SQLite 初始化。
///
/// Flutter Web 不能使用 dart:io，也不能直接使用 sqflite 的 mobile 實作。
///
/// sqflite_common_ffi_web 會提供 Web 專用的 databaseFactory，
/// 讓同一套 openDatabase API 可以在 Web 環境運作。
Future<void> initializeDatabaseFactory() async {
  databaseFactory = databaseFactoryFfiWeb;
}
