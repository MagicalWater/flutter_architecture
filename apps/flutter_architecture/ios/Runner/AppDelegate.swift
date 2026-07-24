import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "AppDatabasePathPlugin"
    ) else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "flutter_architecture/database_path",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "getDatabaseDirectory" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
      )
      guard let path = paths.first?.path else {
        result(
          FlutterError(
            code: "database_path_unavailable",
            message: "Database directory is unavailable",
            details: nil
          )
        )
        return
      }
      result(path)
    }
  }
}
