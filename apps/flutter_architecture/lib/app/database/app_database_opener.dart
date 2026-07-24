export 'app_database_opener_stub.dart'
    if (dart.library.io) 'app_database_opener_native.dart'
    if (dart.library.js_interop) 'app_database_opener_web.dart';
