import 'package:sqflite/sqflite.dart' show DatabaseFactory;

import 'database_factory_io.dart' if (dart.library.js_interop) 'database_factory_web.dart' as platform;

abstract final class AppDatabaseFactory {
  static DatabaseFactory create() => platform.createDatabaseFactory();
}
