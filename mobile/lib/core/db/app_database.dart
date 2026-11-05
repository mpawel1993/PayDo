import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_factory.dart';
import 'migration.dart';
import 'migrations.dart';

const appDatabaseFileName = 'paydo.db';

final class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  bool get isOpen => db.isOpen;

  static Future<AppDatabase> open({DatabaseFactory? factory, String? path, List<Migration>? migrations}) async {
    final steps = migrations ?? appMigrations;
    Migration.validate(steps);
    final dbFactory = factory ?? AppDatabaseFactory.create();
    final dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), appDatabaseFileName);

    Future<void> migrate(Database db, int from, int to) => db.transaction((txn) async {
      for (final m in steps.where((m) => m.version > from && m.version <= to)) {
        await m.up(txn);
      }
    });

    final db = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: steps.last.version,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => migrate(db, 0, version),
        onUpgrade: migrate,
      ),
    );
    return AppDatabase._(db);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) => db.transaction(action);

  Future<void> close() => db.close();
}
