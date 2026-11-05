import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/core/db/migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<AppDatabase> openTestDatabase({List<Migration>? migrations, String? path}) {
  sqfliteFfiInit();
  return AppDatabase.open(factory: databaseFactoryFfi, path: path ?? inMemoryDatabasePath, migrations: migrations);
}
