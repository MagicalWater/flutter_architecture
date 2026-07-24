package com.example.flutterarchitecture

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "flutter_architecture/database_path",
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDatabaseDirectory") {
                val directory = applicationContext
                    .getDatabasePath("flutter_architecture.db")
                    .parentFile
                if (directory == null) {
                    result.error("database_path_unavailable", "Database directory is unavailable", null)
                } else {
                    result.success(directory.absolutePath)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
